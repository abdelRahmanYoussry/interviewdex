import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/features/quiz/domain/entities/saved_quiz_session.dart';
import 'package:interviewdex/features/quiz/domain/repositories/quiz_progress_repository.dart';
import 'package:interviewdex/features/quiz/domain/use_cases/build_quiz.dart';
import 'package:interviewdex/features/quiz/domain/use_cases/score_quiz.dart';
import 'package:interviewdex/features/quiz/presentation/cubits/quiz_cubit.dart';
import 'package:interviewdex/features/tracks/domain/entities/quiz_item.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/load_tracks.dart';

import '../../../tracks/support/practice_fixtures.dart';
import '../../support/quiz_fixtures.dart';

void main() {
  late MemoryQuizProgressRepository progress;
  late TestAnalytics analytics;

  QuizCubit createCubit() => QuizCubit(
    loadTracks: LoadTracks(
      MemoryTrackRepository([quizTrack(itemsPerTopic: 2)]),
    ),
    progressRepository: progress,
    buildQuiz: const BuildQuiz(),
    scoreQuiz: const ScoreQuiz(),
    analytics: analytics,
    random: Random(4),
  );

  setUp(() {
    progress = MemoryQuizProgressRepository();
    analytics = TestAnalytics();
  });

  blocTest<QuizCubit, QuizState>(
    'locks an answer, advances without repeating it and completes once',
    build: createCubit,
    act: (cubit) async {
      await cubit.load();
      await cubit.start(topicId: 'topic_0');
      final first = (cubit.state as QuizQuestion).currentItem;
      final firstCorrect = (first as MultipleChoiceQuizItem).correctIndex;
      await Future.wait([
        cubit.answer((firstCorrect + 1) % 4),
        cubit.answer(firstCorrect),
      ]);
      expect(
        (cubit.state as QuizFeedback).chosenAnswer,
        (firstCorrect + 1) % 4,
      );
      await cubit.next();
      final second = (cubit.state as QuizQuestion).currentItem;
      await cubit.answer((second as MultipleChoiceQuizItem).correctIndex);
      await Future.wait([cubit.next(), cubit.next()]);
    },
    expect:
        () => [
          isA<QuizLoading>(),
          isA<QuizPicker>(),
          isA<QuizQuestion>(),
          isA<QuizFeedback>(),
          isA<QuizQuestion>(),
          isA<QuizFeedback>(),
          isA<QuizResults>()
              .having((state) => state.result.total, 'total', 2)
              .having((state) => state.result.score, 'score', 1)
              .having(
                (state) => state.result.wrongAnswers,
                'wrong answers',
                hasLength(1),
              ),
        ],
    verify: (_) {
      expect(progress.session, isNull);
      expect(analytics.quizCompletions, 1);
    },
  );

  blocTest<QuizCubit, QuizState>(
    'restores earlier answers and option order when resumed mid-session',
    build: () {
      final track = quizTrack(topicCount: 1, itemsPerTopic: 2);
      progress.session = SavedQuizSession(
        trackId: track.id,
        topicId: 'topic_0',
        itemIds: const ['quiz_0_0', 'quiz_0_1'],
        index: 1,
        answers: const {'quiz_0_0': 0},
        optionOrders: const {
          'quiz_0_0': [0, 1, 2, 3],
          'quiz_0_1': [3, 2, 1, 0],
        },
      );
      return QuizCubit(
        loadTracks: LoadTracks(MemoryTrackRepository([track])),
        progressRepository: progress,
        buildQuiz: const BuildQuiz(),
        scoreQuiz: const ScoreQuiz(),
        analytics: analytics,
        random: Random(4),
      );
    },
    act: (cubit) async {
      await cubit.load();
      final saved = (cubit.state as QuizPicker).resumeSession!;
      await cubit.start(resume: saved);
      final question = cubit.state as QuizQuestion;
      expect(question.currentItem.id, 'quiz_0_1');
      expect(question.answers['quiz_0_0'], 0);
      expect(question.quiz.optionOrders['quiz_0_1'], [3, 2, 1, 0]);
      await cubit.answer(0);
      await cubit.next();
    },
    expect:
        () => [
          isA<QuizLoading>(),
          isA<QuizPicker>(),
          isA<QuizQuestion>(),
          isA<QuizFeedback>(),
          isA<QuizResults>().having((state) => state.result.score, 'score', 2),
        ],
    verify: (_) => expect(analytics.quizCompletions, 1),
  );

  blocTest<QuizCubit, QuizState>(
    'retries only incorrect answers from the result',
    build: createCubit,
    act: (cubit) async {
      await cubit.load();
      await cubit.start(topicId: 'topic_0');
      final first = (cubit.state as QuizQuestion).currentItem;
      final firstCorrect = (first as MultipleChoiceQuizItem).correctIndex;
      await cubit.answer((firstCorrect + 1) % 4);
      await cubit.next();
      final second = (cubit.state as QuizQuestion).currentItem;
      await cubit.answer((second as MultipleChoiceQuizItem).correctIndex);
      await cubit.next();
      await cubit.retryWrongAnswers();
    },
    expect:
        () => [
          isA<QuizLoading>(),
          isA<QuizPicker>(),
          isA<QuizQuestion>(),
          isA<QuizFeedback>(),
          isA<QuizQuestion>(),
          isA<QuizFeedback>(),
          isA<QuizResults>(),
          isA<QuizQuestion>()
              .having((state) => state.quiz.items, 'retry items', hasLength(1))
              .having(
                (state) => state.currentItem.id,
                'retried id',
                predicate<String>((id) => id.startsWith('quiz_0_')),
              ),
        ],
    verify: (_) => expect(progress.session?.itemIds, hasLength(1)),
  );

  blocTest<QuizCubit, QuizState>(
    'clears a saved session whose item ids no longer exist',
    build: () {
      progress.session = const SavedQuizSession(
        trackId: 'flutter',
        topicId: 'topic_0',
        itemIds: ['removed_item'],
        index: 0,
        answers: {},
        optionOrders: {
          'removed_item': [0, 1, 2, 3],
        },
      );
      return createCubit();
    },
    act: (cubit) => cubit.load(),
    expect: () => [isA<QuizLoading>(), isA<QuizPicker>()],
    verify: (cubit) {
      expect((cubit.state as QuizPicker).resumeSession, isNull);
      expect(progress.session, isNull);
    },
  );
}

class MemoryQuizProgressRepository implements QuizProgressRepository {
  SavedQuizSession? session;

  @override
  Future<SavedQuizSession?> load(String trackId) async => session;

  @override
  Future<void> save(String trackId, SavedQuizSession session) async {
    this.session = session;
  }

  @override
  Future<void> clear(String trackId) async {
    session = null;
  }
}
