import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../tracks/domain/entities/quiz_item.dart';
import '../../../tracks/domain/entities/track.dart';
import '../../../tracks/domain/use_cases/load_tracks.dart';
import '../../domain/entities/built_quiz.dart';
import '../../domain/entities/quiz_result.dart';
import '../../domain/entities/saved_quiz_session.dart';
import '../../domain/repositories/quiz_progress_repository.dart';
import '../../domain/use_cases/build_quiz.dart';
import '../../domain/use_cases/score_quiz.dart';

sealed class QuizState extends Equatable {
  const QuizState();
}

final class QuizLoading extends QuizState {
  const QuizLoading();

  @override
  List<Object?> get props => const [];
}

final class QuizPicker extends QuizState {
  const QuizPicker({required this.track, required this.resumeSession});

  final InterviewTrack track;
  final SavedQuizSession? resumeSession;
  List<InterviewTopic> get availableTopics =>
      track.topics.where((topic) => topic.quizItems.isNotEmpty).toList();

  @override
  List<Object?> get props => [track, resumeSession];
}

sealed class QuizRunState extends QuizState {
  const QuizRunState({
    required this.track,
    required this.quiz,
    required this.index,
    required this.answers,
  });

  final InterviewTrack track;
  final BuiltQuiz quiz;
  final int index;
  final Map<String, int> answers;

  QuizItem get currentItem => quiz.items[index];

  @override
  List<Object?> get props => [track, quiz, index, answers];
}

final class QuizQuestion extends QuizRunState {
  const QuizQuestion({
    required super.track,
    required super.quiz,
    required super.index,
    required super.answers,
  });
}

final class QuizFeedback extends QuizRunState {
  const QuizFeedback({
    required super.track,
    required super.quiz,
    required super.index,
    required super.answers,
    required this.chosenAnswer,
  });

  final int chosenAnswer;

  @override
  List<Object?> get props => [...super.props, chosenAnswer];
}

final class QuizResults extends QuizState {
  const QuizResults({
    required this.track,
    required this.quiz,
    required this.result,
  });

  final InterviewTrack track;
  final BuiltQuiz quiz;
  final QuizResult result;

  @override
  List<Object?> get props => [track, quiz, result];
}

final class QuizFailure extends QuizState {
  const QuizFailure();

  @override
  List<Object?> get props => const [];
}

class QuizCubit extends Cubit<QuizState> {
  QuizCubit({
    required LoadTracks loadTracks,
    required QuizProgressRepository progressRepository,
    required BuildQuiz buildQuiz,
    required ScoreQuiz scoreQuiz,
    required AnalyticsService analytics,
    required Random random,
    void Function(String message)? logWarning,
  }) : _loadTracks = loadTracks,
       _progressRepository = progressRepository,
       _buildQuiz = buildQuiz,
       _scoreQuiz = scoreQuiz,
       _analytics = analytics,
       _random = random,
       _logWarning = logWarning ?? debugPrint,
       super(const QuizLoading());

  final LoadTracks _loadTracks;
  final QuizProgressRepository _progressRepository;
  final BuildQuiz _buildQuiz;
  final ScoreQuiz _scoreQuiz;
  final AnalyticsService _analytics;
  final Random _random;
  final void Function(String message) _logWarning;
  InterviewTrack? _track;
  bool _advancing = false;
  bool _answering = false;

  Future<void> load() async {
    emit(const QuizLoading());
    try {
      final tracks = await _loadTracks();
      InterviewTrack? track;
      for (final candidate in tracks) {
        if (candidate.topics.any((topic) => topic.quizItems.isNotEmpty)) {
          track = candidate;
          break;
        }
      }
      if (track == null) {
        emit(const QuizFailure());
        return;
      }
      _track = track;
      var saved = await _progressRepository.load(track.id);
      if (saved != null && !_matchesTrack(saved, track)) {
        _logWarning(
          'Discarding saved quiz session that no longer matches content.',
        );
        await _progressRepository.clear(track.id);
        saved = null;
      }
      emit(QuizPicker(track: track, resumeSession: saved));
    } on Exception catch (error) {
      _logWarning('Unable to load quick quiz: $error');
      emit(const QuizFailure());
    }
  }

  Future<void> start({String? topicId, SavedQuizSession? resume}) async {
    final track =
        _track ?? (state is QuizPicker ? (state as QuizPicker).track : null);
    if (track == null) {
      await load();
      if (state is! QuizPicker) return;
      return start(topicId: topicId, resume: resume);
    }
    if (resume != null) {
      final itemsById = {
        for (final topic in track.topics)
          for (final item in topic.quizItems) item.id: item,
      };
      final items = [
        for (final id in resume.itemIds)
          if (itemsById[id] case final item?) item,
      ];
      if (items.length != resume.itemIds.length ||
          items.isEmpty ||
          resume.itemIds.toSet().length != resume.itemIds.length) {
        await _progressRepository.clear(track.id);
        _logWarning('Discarding invalid saved quiz question ids.');
        emit(QuizPicker(track: track, resumeSession: null));
        return;
      }
      final orders = <String, List<int>>{};
      for (final entry in resume.answers.entries) {
        final item = itemsById[entry.key];
        final answerCount = item is MultipleChoiceQuizItem ? 4 : 2;
        if (item == null || entry.value < 0 || entry.value >= answerCount) {
          await _progressRepository.clear(track.id);
          _logWarning('Discarding invalid saved quiz answer.');
          emit(QuizPicker(track: track, resumeSession: null));
          return;
        }
      }
      for (final item in items) {
        final order = resume.optionOrders[item.id];
        final optionCount = item is MultipleChoiceQuizItem ? 4 : 2;
        if (order == null ||
            order.length != optionCount ||
            order.toSet().length != optionCount ||
            order.any((value) => value < 0 || value >= optionCount)) {
          await _progressRepository.clear(track.id);
          _logWarning('Discarding invalid saved quiz option order.');
          emit(QuizPicker(track: track, resumeSession: null));
          return;
        }
        orders[item.id] = order;
      }
      final quiz = BuiltQuiz(
        trackId: track.id,
        topicId: resume.topicId,
        items: List.unmodifiable(items),
        optionOrders: Map.unmodifiable(orders),
      );
      _emitQuestion(track, quiz, resume.index, resume.answers);
      return;
    }
    final quiz = _buildQuiz(track, topicId: topicId, random: _random);
    if (quiz.items.isEmpty) return;
    await _progressRepository.save(track.id, _saved(quiz, 0, const {}));
    _emitQuestion(track, quiz, 0, const {});
  }

  Future<void> answer(int canonicalAnswer) async {
    final active = state;
    if (active is! QuizQuestion || _answering) return;
    final item = active.currentItem;
    final choiceCount = item is MultipleChoiceQuizItem ? 4 : 2;
    if (canonicalAnswer < 0 || canonicalAnswer >= choiceCount) return;
    _answering = true;
    final answers = {...active.answers, item.id: canonicalAnswer};
    try {
      await _progressRepository.save(
        active.track.id,
        _saved(active.quiz, active.index, answers),
      );
      emit(
        QuizFeedback(
          track: active.track,
          quiz: active.quiz,
          index: active.index,
          answers: Map.unmodifiable(answers),
          chosenAnswer: canonicalAnswer,
        ),
      );
    } finally {
      _answering = false;
    }
  }

  Future<void> next() async {
    final active = state;
    if (active is! QuizFeedback || _advancing) return;
    _advancing = true;
    final nextIndex = active.index + 1;
    try {
      if (nextIndex >= active.quiz.items.length) {
        final result = _scoreQuiz(active.quiz.items, active.answers);
        await _progressRepository.clear(active.track.id);
        emit(
          QuizResults(track: active.track, quiz: active.quiz, result: result),
        );
        unawaited(
          _analytics.quickQuizComplete(
            score: result.score,
            total: result.total,
          ),
        );
        return;
      }
      await _progressRepository.save(
        active.track.id,
        _saved(active.quiz, nextIndex, active.answers),
      );
      emit(
        QuizQuestion(
          track: active.track,
          quiz: active.quiz,
          index: nextIndex,
          answers: active.answers,
        ),
      );
    } finally {
      _advancing = false;
    }
  }

  Future<void> retryWrongAnswers() async {
    final active = state;
    if (active is! QuizResults || active.result.wrongAnswers.isEmpty) return;
    final items =
        active.result.wrongAnswers.map((wrong) => wrong.item).toList();
    await startRetryItems(active.track, items);
  }

  Future<void> startRetryItems(
    InterviewTrack track,
    List<QuizItem> items,
  ) async {
    if (items.isEmpty) return;
    final optionOrders = <String, List<int>>{};
    for (final item in items) {
      final order = item is MultipleChoiceQuizItem ? [0, 1, 2, 3] : [0, 1];
      order.shuffle(_random);
      optionOrders[item.id] = order;
    }
    final quiz = BuiltQuiz(
      trackId: track.id,
      topicId: null,
      items: List.unmodifiable(items),
      optionOrders: Map.unmodifiable(optionOrders),
    );
    await _progressRepository.save(track.id, _saved(quiz, 0, const {}));
    _emitQuestion(track, quiz, 0, const {});
  }

  void _emitQuestion(
    InterviewTrack track,
    BuiltQuiz quiz,
    int index,
    Map<String, int> answers,
  ) {
    final selected = answers[quiz.items[index].id];
    if (selected == null) {
      emit(
        QuizQuestion(
          track: track,
          quiz: quiz,
          index: index,
          answers: Map.unmodifiable(answers),
        ),
      );
    } else {
      emit(
        QuizFeedback(
          track: track,
          quiz: quiz,
          index: index,
          answers: Map.unmodifiable(answers),
          chosenAnswer: selected,
        ),
      );
    }
  }

  SavedQuizSession _saved(
    BuiltQuiz quiz,
    int index,
    Map<String, int> answers,
  ) => SavedQuizSession(
    trackId: quiz.trackId,
    topicId: quiz.topicId,
    itemIds: [for (final item in quiz.items) item.id],
    index: index,
    answers: answers,
    optionOrders: quiz.optionOrders,
  );

  bool _matchesTrack(SavedQuizSession saved, InterviewTrack track) {
    final itemsById = {
      for (final topic in track.topics)
        for (final item in topic.quizItems) item.id: item,
    };
    final topicByItemId = {
      for (final topic in track.topics)
        for (final item in topic.quizItems) item.id: topic.id,
    };
    if (saved.trackId != track.id ||
        saved.itemIds.isEmpty ||
        saved.itemIds.toSet().length != saved.itemIds.length ||
        saved.index < 0 ||
        saved.index >= saved.itemIds.length) {
      return false;
    }
    if (saved.topicId != null &&
        !track.topics.any((topic) => topic.id == saved.topicId)) {
      return false;
    }
    if (saved.itemIds.any((id) => !itemsById.containsKey(id))) return false;
    if (saved.topicId != null &&
        saved.itemIds.any((id) => topicByItemId[id] != saved.topicId)) {
      return false;
    }
    if (saved.answers.keys.any((id) => !saved.itemIds.contains(id)) ||
        saved.optionOrders.keys.any((id) => !saved.itemIds.contains(id))) {
      return false;
    }
    for (final entry in saved.answers.entries) {
      final item = itemsById[entry.key]!;
      final answerCount = item is MultipleChoiceQuizItem ? 4 : 2;
      if (entry.value < 0 || entry.value >= answerCount) return false;
    }
    for (final id in saved.itemIds) {
      final item = itemsById[id]!;
      final optionCount = item is MultipleChoiceQuizItem ? 4 : 2;
      final order = saved.optionOrders[id];
      if (order == null ||
          order.length != optionCount ||
          order.toSet().length != optionCount ||
          order.any((value) => value < 0 || value >= optionCount)) {
        return false;
      }
    }
    return true;
  }
}
