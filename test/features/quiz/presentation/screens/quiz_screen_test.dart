import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/core/theme/app_theme.dart';
import 'package:interviewdex/features/quiz/domain/entities/built_quiz.dart';
import 'package:interviewdex/features/quiz/domain/entities/saved_quiz_session.dart';
import 'package:interviewdex/features/quiz/domain/repositories/quiz_progress_repository.dart';
import 'package:interviewdex/features/quiz/domain/use_cases/build_quiz.dart';
import 'package:interviewdex/features/quiz/domain/use_cases/score_quiz.dart';
import 'package:interviewdex/features/quiz/presentation/cubits/quiz_cubit.dart';
import 'package:interviewdex/features/quiz/presentation/screens/quiz_route.dart';
import 'package:interviewdex/features/quiz/presentation/screens/quiz_summary_screen.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/load_tracks.dart';
import 'package:interviewdex/l10n/app_localizations.dart';

import '../../../tracks/support/practice_fixtures.dart';
import '../../support/quiz_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final (language, direction) in [
    ('en', TextDirection.ltr),
    ('ar', TextDirection.rtl),
  ]) {
    testWidgets('question feedback fits 400px in $language', (tester) async {
      _setMobileSize(tester);
      final cubit = _createCubit();

      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light(),
          home: QuizRoute(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('quizAllTopics')), findsOneWidget);
      expect(find.byKey(const ValueKey('quiz-topic-topic_0')), findsOneWidget);
      final topic = find.text('Topic 0');
      expect(Directionality.of(tester.element(topic)), TextDirection.ltr);
      expect(
        tester.widget<Text>(topic).textAlign,
        language == 'ar' ? TextAlign.right : TextAlign.left,
      );
      await tester.tap(find.byKey(const ValueKey('quizAllTopics')));
      await tester.pumpAndSettle();

      final state = cubit.state as QuizQuestion;
      final englishQuestion = state.currentItem.question.resolve('ar');
      final contentText = find.text(englishQuestion);
      expect(contentText, findsOneWidget);
      expect(Directionality.of(tester.element(contentText)), TextDirection.ltr);
      expect(
        Directionality.of(tester.element(find.byType(QuizRoute))),
        direction,
      );

      await tester.tap(find.byKey(const ValueKey('quiz-option-0')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('quizNext')), findsOneWidget);
      expect(
        find.text(language == 'en' ? 'Correct answer' : 'الإجابة الصحيحة'),
        findsOneWidget,
      );
      expect(find.text(language == 'en' ? 'Why' : 'السبب'), findsOneWidget);
      expect(
        find.text(language == 'en' ? 'Extra tip' : 'معلومة إضافية'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('results fit 400px in $language', (tester) async {
      _setMobileSize(tester);
      final track = quizTrack(topicCount: 1, itemsPerTopic: 2);
      final items = track.topics.single.quizItems;
      final quiz = BuiltQuiz(
        trackId: track.id,
        topicId: null,
        items: items,
        optionOrders: {
          for (final item in items) item.id: [0, 1, 2, 3],
        },
      );
      final result = const ScoreQuiz()(items, {
        items.first.id: 1,
        items.last.id: 0,
      });

      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light(),
          home: QuizSummaryScreen(
            request: QuizSummaryRequest(
              track: track,
              quiz: quiz,
              result: result,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          language == 'en' ? 'Retry wrong answers' : 'أعد الأسئلة الخاطئة',
        ),
        findsOneWidget,
      );
      expect(find.text(items.first.question.resolve(language)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

void _setMobileSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

QuizCubit _createCubit() => QuizCubit(
  loadTracks: LoadTracks(MemoryTrackRepository([quizTrack(englishOnly: true)])),
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
