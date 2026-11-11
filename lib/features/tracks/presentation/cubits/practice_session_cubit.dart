import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../domain/entities/card_progress.dart';
import '../../domain/entities/interview_question.dart';
import '../../domain/entities/practice_card.dart';
import '../../domain/entities/saved_practice_session.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/practice_progress_repository.dart';
import '../../domain/use_cases/load_tracks.dart';
import '../../domain/use_cases/spaced_repetition.dart';

class PracticeSessionRequest {
  const PracticeSessionRequest({
    required this.trackId,
    required this.mode,
    this.topicId,
    this.savedSession,
  });

  final String trackId;
  final PracticeMode mode;
  final String? topicId;
  final SavedPracticeSession? savedSession;
}

sealed class PracticeSessionState extends Equatable {
  const PracticeSessionState();
}

final class PracticeSessionLoading extends PracticeSessionState {
  const PracticeSessionLoading();

  @override
  List<Object?> get props => const [];
}

final class PracticeSessionActive extends PracticeSessionState {
  const PracticeSessionActive({
    required this.track,
    required this.cards,
    required this.index,
    required this.revealed,
    required this.mode,
    required this.topicId,
    required this.progress,
    required this.retriedCardIds,
  });

  final InterviewTrack track;
  final List<PracticeCard> cards;
  final int index;
  final bool revealed;
  final PracticeMode mode;
  final String? topicId;
  final Map<String, CardProgress> progress;
  final Set<String> retriedCardIds;

  PracticeCard get currentCard => cards[index];

  SavedPracticeSession get savedSession => SavedPracticeSession(
    mode: mode,
    cardIds: [for (final card in cards) card.question.id],
    index: index,
    revealed: revealed,
    topicId: topicId,
    retriedCardIds: retriedCardIds,
  );

  @override
  List<Object?> get props => [
    track,
    cards,
    index,
    revealed,
    mode,
    topicId,
    progress,
    retriedCardIds,
  ];
}

final class PracticeSessionComplete extends PracticeSessionState {
  const PracticeSessionComplete(this.track);

  final InterviewTrack track;

  @override
  List<Object?> get props => [track];
}

final class PracticeSessionFailure extends PracticeSessionState {
  const PracticeSessionFailure();

  @override
  List<Object?> get props => const [];
}

class PracticeSessionCubit extends Cubit<PracticeSessionState> {
  PracticeSessionCubit({
    required LoadTracks loadTracks,
    required PracticeProgressRepository progressRepository,
    required SpacedRepetition spacedRepetition,
    required AnalyticsService analytics,
    DateTime Function()? clock,
  }) : _loadTracks = loadTracks,
       _progressRepository = progressRepository,
       _spacedRepetition = spacedRepetition,
       _analytics = analytics,
       _clock = clock ?? DateTime.now,
       super(const PracticeSessionLoading());

  final LoadTracks _loadTracks;
  final PracticeProgressRepository _progressRepository;
  final SpacedRepetition _spacedRepetition;
  final AnalyticsService _analytics;
  final DateTime Function() _clock;
  bool _ratingInProgress = false;
  final Map<(String, String), _PendingTemplateWrite> _pendingTemplates = {};

  Future<void> open(PracticeSessionRequest request) async {
    emit(const PracticeSessionLoading());
    try {
      final tracks = await _loadTracks();
      InterviewTrack? matchingTrack;
      for (final item in tracks) {
        if (item.id == request.trackId) matchingTrack = item;
      }
      final track = matchingTrack;
      if (track == null) {
        throw FormatException('Unknown interview track "${request.trackId}".');
      }
      final snapshot = await _progressRepository.load(track.id);
      var resume = request.savedSession;
      final allCardIds = {
        for (final topic in track.topics)
          for (final card in topic.interviewCards) card.id,
      };
      if (resume != null && !resume.cardIds.every(allCardIds.contains)) {
        debugPrint(
          'Discarding saved practice session for "${track.id}" because its cards no longer exist.',
        );
        await _progressRepository.clearSession(track.id);
        resume = null;
      }
      var cards = _cards(track, resume?.topicId ?? request.topicId);
      var queuedCards = resume == null ? null : _restoreQueue(cards, resume);
      if (resume != null && queuedCards == null) {
        debugPrint(
          'Discarding mismatched saved practice session for "${track.id}".',
        );
        await _progressRepository.clearSession(track.id);
        resume = null;
      }
      queuedCards ??=
          request.mode == PracticeMode.mock
              ? _mockQueue(track, snapshot.cards)
              : _orderedQueue(cards, snapshot.cards);
      if (queuedCards.isEmpty) {
        emit(const PracticeSessionFailure());
        return;
      }
      final saved = resume;
      final initial = PracticeSessionActive(
        track: track,
        cards: queuedCards,
        index: saved?.index ?? 0,
        revealed: saved?.revealed ?? false,
        mode: saved?.mode ?? request.mode,
        topicId: saved?.topicId ?? request.topicId,
        progress: snapshot.cards,
        retriedCardIds: saved?.retriedCardIds ?? const {},
      );
      await _saveSession(initial);
      emit(initial);
    } on Exception catch (error) {
      debugPrint('Unable to open practice session: $error');
      emit(const PracticeSessionFailure());
    }
  }

  Future<void> revealAnswer() async {
    final active = state;
    if (active is! PracticeSessionActive || active.revealed) return;
    unawaited(
      _analytics.interviewCardReveal(
        trackId: active.track.id,
        topic: active.currentCard.topicId,
        cardId: active.currentCard.question.id,
      ),
    );
    await _emitAndSave(_copy(active, revealed: true));
  }

  Future<void> rate(CardRating rating) async {
    final active = state;
    if (active is! PracticeSessionActive ||
        !active.revealed ||
        _ratingInProgress) {
      return;
    }
    _ratingInProgress = true;
    try {
      final question = active.currentCard.question;
      final previous =
          active.progress[question.id] ?? const CardProgress.notSeen();
      final updated = _spacedRepetition.applyRating(previous, rating, _clock());
      await _progressRepository.saveCard(active.track.id, question.id, updated);
      unawaited(
        _analytics.interviewSelfRate(
          topic: active.currentCard.topicId,
          rating: rating.name,
        ),
      );

      final cards = [...active.cards];
      final retried = {...active.retriedCardIds};
      if (rating == CardRating.missed && retried.add(question.id)) {
        cards.add(active.currentCard);
      }
      final nextIndex = active.index + 1;
      if (nextIndex >= cards.length) {
        await _progressRepository.clearSession(active.track.id);
        if (active.mode == PracticeMode.mock) {
          unawaited(_analytics.mockInterviewComplete());
        }
        emit(PracticeSessionComplete(active.track));
        return;
      }
      await _emitAndSave(
        PracticeSessionActive(
          track: active.track,
          cards: cards,
          index: nextIndex,
          revealed: false,
          mode: active.mode,
          topicId: active.topicId,
          progress: {...active.progress, question.id: updated},
          retriedCardIds: retried,
        ),
      );
    } finally {
      _ratingInProgress = false;
    }
  }

  Future<void> saveTemplateAnswer(String cardId, String fieldId, String value) {
    final active = state;
    if (active is! PracticeSessionActive) return Future<void>.value();
    final existing = active.progress[cardId] ?? const CardProgress.notSeen();
    final answers = {...existing.templateAnswers, fieldId: value};
    final updated = CardProgress(
      seen: existing.seen,
      lastRating: existing.lastRating,
      nailedItStreak: existing.nailedItStreak,
      intervalDays: existing.intervalDays,
      dueAt: existing.dueAt,
      templateAnswers: answers,
    );
    emit(
      PracticeSessionActive(
        track: active.track,
        cards: active.cards,
        index: active.index,
        revealed: active.revealed,
        mode: active.mode,
        topicId: active.topicId,
        progress: {...active.progress, cardId: updated},
        retriedCardIds: active.retriedCardIds,
      ),
    );
    final key = (active.track.id, cardId);
    final completer = Completer<void>();
    final pending = _pendingTemplates[key];
    if (pending == null) {
      _pendingTemplates[key] = _PendingTemplateWrite(
        answers: Map.unmodifiable(answers),
        completers: [completer],
      );
    } else {
      pending.timer?.cancel();
      pending.answers = Map.unmodifiable(answers);
      pending.completers.add(completer);
    }
    final next = _pendingTemplates[key]!;
    next.timer = Timer(
      const Duration(milliseconds: 400),
      () => unawaited(_flushTemplate(key, next)),
    );
    return completer.future;
  }

  Future<void> _flushTemplate(
    (String, String) key,
    _PendingTemplateWrite pending,
  ) async {
    if (!identical(_pendingTemplates[key], pending)) return;
    pending.timer?.cancel();
    _pendingTemplates.remove(key);
    try {
      await _progressRepository.saveTemplateAnswers(
        key.$1,
        key.$2,
        pending.answers,
      );
    } on Object catch (error) {
      debugPrint('Unable to save answer template: $error');
    } finally {
      for (final completer in pending.completers) {
        if (!completer.isCompleted) completer.complete();
      }
    }
  }

  Future<void> _emitAndSave(PracticeSessionActive active) async {
    await _saveSession(active);
    emit(active);
  }

  @override
  Future<void> close() async {
    final pending = _pendingTemplates.entries.toList();
    for (final entry in pending) {
      entry.value.timer?.cancel();
      await _flushTemplate(entry.key, entry.value);
    }
    await super.close();
  }

  Future<void> _saveSession(PracticeSessionActive active) =>
      _progressRepository.saveSession(active.track.id, active.savedSession);

  PracticeSessionActive _copy(
    PracticeSessionActive active, {
    required bool revealed,
  }) => PracticeSessionActive(
    track: active.track,
    cards: active.cards,
    index: active.index,
    revealed: revealed,
    mode: active.mode,
    topicId: active.topicId,
    progress: active.progress,
    retriedCardIds: active.retriedCardIds,
  );

  List<PracticeCard>? _restoreQueue(
    List<PracticeCard> cards,
    SavedPracticeSession resume,
  ) {
    final byId = {for (final card in cards) card.question.id: card};
    final restored = [
      for (final id in resume.cardIds)
        if (byId[id] case final card?) card,
    ];
    if (restored.isNotEmpty &&
        restored.length == resume.cardIds.length &&
        resume.index < restored.length) {
      return restored;
    }
    return null;
  }

  List<PracticeCard> _orderedQueue(
    List<PracticeCard> cards,
    Map<String, CardProgress> progress,
  ) {
    final ordered = _spacedRepetition.orderQueue(
      cards.map((card) => card.question),
      progress,
      _clock(),
    );
    final byId = {for (final card in cards) card.question.id: card};
    return [for (final question in ordered) byId[question.id]!];
  }

  List<PracticeCard> _mockQueue(
    InterviewTrack track,
    Map<String, CardProgress> progress,
  ) {
    final cards = _cards(track, null);
    final staged = <PracticeCard>[];
    for (final stage in [
      InterviewStage.intro,
      InterviewStage.behavioral,
      InterviewStage.technical,
    ]) {
      staged.addAll(
        _orderedQueue(
          cards.where((card) => card.question.stage == stage).toList(),
          progress,
        ),
      );
    }
    final liveCoding = cards.where(
      (card) => card.question.stage == InterviewStage.liveCoding,
    );
    if (liveCoding.isNotEmpty) {
      staged.addAll(_orderedQueue([liveCoding.first], progress));
    }
    return staged;
  }

  List<PracticeCard> _cards(InterviewTrack track, String? topicId) => [
    for (final topic in track.topics)
      if (topicId == null || topic.id == topicId)
        for (final question in topic.interviewCards)
          PracticeCard(
            topicId: topic.id,
            topicName: topic.name,
            question: question,
          ),
  ];
}

class _PendingTemplateWrite {
  _PendingTemplateWrite({required this.answers, required this.completers});

  Map<String, String> answers;
  final List<Completer<void>> completers;
  Timer? timer;
}
