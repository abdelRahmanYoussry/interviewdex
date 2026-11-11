import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/core/router/app_router.dart';
import 'package:interviewdex/core/theme/app_theme.dart';
import 'package:interviewdex/features/home/presentation/screens/home_screen.dart';
import 'package:interviewdex/features/quiz/domain/entities/saved_quiz_session.dart';
import 'package:interviewdex/features/quiz/domain/repositories/quiz_progress_repository.dart';
import 'package:interviewdex/features/quiz/domain/use_cases/build_quiz.dart';
import 'package:interviewdex/features/quiz/domain/use_cases/score_quiz.dart';
import 'package:interviewdex/features/quiz/presentation/cubits/quiz_cubit.dart';
import 'package:interviewdex/features/quiz/presentation/screens/quiz_summary_screen.dart';
import 'package:interviewdex/features/tracks/domain/entities/quiz_item.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/load_tracks.dart';
import 'package:interviewdex/l10n/app_localizations.dart';

import '../../../tracks/support/practice_fixtures.dart';
import '../../support/quiz_fixtures.dart';

void main() {
  testWidgets('results route replaces the quiz and Back returns home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    QuizCubit? quizCubit;
    final router = AppRouter(createQuizCubit: () => quizCubit = _createCubit());

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: router.onGenerateRoute,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.home,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quickQuiz')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quizAllTopics')));
    await tester.pumpAndSettle();

    for (var index = 0; index < 10; index++) {
      final question = quizCubit!.state as QuizQuestion;
      final correctAnswer = switch (question.currentItem) {
        MultipleChoiceQuizItem(:final correctIndex) => correctIndex,
        TrueFalseQuizItem(:final answer) => answer ? 1 : 0,
      };
      await quizCubit!.answer(
        index == 0 ? (correctAnswer + 1) % 4 : correctAnswer,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quizNext')));
      await tester.pumpAndSettle();
    }

    expect(find.byType(QuizSummaryScreen), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('retryWrongAnswers')));
    await tester.pumpAndSettle();
    final retryQuestion = quizCubit!.state as QuizQuestion;
    expect(retryQuestion.quiz.items, hasLength(1));
    final retryAnswer = switch (retryQuestion.currentItem) {
      MultipleChoiceQuizItem(:final correctIndex) => correctIndex,
      TrueFalseQuizItem(:final answer) => answer ? 1 : 0,
    };
    await quizCubit!.answer(retryAnswer);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quizNext')));
    await tester.pumpAndSettle();
    expect(find.byType(QuizSummaryScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(QuizSummaryScreen))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

QuizCubit _createCubit() => QuizCubit(
  loadTracks: LoadTracks(MemoryTrackRepository([quizTrack()])),
  progressRepository: _MemoryProgressRepository(),
  buildQuiz: const BuildQuiz(),
  scoreQuiz: const ScoreQuiz(),
  analytics: TestAnalytics(),
  random: Random(4),
);

class _MemoryProgressRepository implements QuizProgressRepository {
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
