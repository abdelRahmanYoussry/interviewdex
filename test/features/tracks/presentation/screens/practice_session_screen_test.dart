import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/core/router/app_router.dart';
import 'package:interviewdex/core/theme/app_theme.dart';
import 'package:interviewdex/features/tracks/domain/entities/saved_practice_session.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/load_tracks.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/spaced_repetition.dart';
import 'package:interviewdex/features/tracks/presentation/cubits/practice_session_cubit.dart';
import 'package:interviewdex/features/tracks/presentation/cubits/track_cubit.dart';
import 'package:interviewdex/features/tracks/presentation/screens/practice_session_screen.dart';
import 'package:interviewdex/features/tracks/presentation/screens/track_screen.dart';
import 'package:interviewdex/l10n/app_localizations.dart';

import '../../support/practice_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final (
        language,
        topicLabel,
        revealLabel,
        timerLabel,
        answer,
        situationLabel,
        direction,
      )
      in [
        (
          'en',
          'Core concepts',
          'Reveal answer',
          'Start 90-second timer',
          'A complete sample answer for intro.',
          'Situation',
          TextDirection.ltr,
        ),
        (
          'ar',
          'مفاهيم أساسية',
          'اعرض الإجابة',
          'ابدأ مؤقت 90 ثانية',
          'إجابة نموذجية مكتملة عن intro.',
          'الموقف',
          TextDirection.rtl,
        ),
      ]) {
    testWidgets('practice route works in $language at 400px', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final track = practiceTrack();
      final progress = MemoryPracticeProgressRepository();
      final trackCubit = TrackCubit(
        loadTracks: LoadTracks(MemoryTrackRepository([track])),
        progressRepository: progress,
        analytics: TestAnalytics(),
      );
      final router = AppRouter(
        createPracticeSessionCubit:
            () => PracticeSessionCubit(
              loadTracks: LoadTracks(MemoryTrackRepository([track])),
              progressRepository: progress,
              spacedRepetition: const SpacedRepetition(),
              analytics: TestAnalytics(),
            ),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light(),
          home: TrackRoute(cubit: trackCubit),
          onGenerateRoute: router.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const ValueKey('practice-core')));
      await tester.tap(find.byKey(const ValueKey('practice-core')));
      await tester.pumpAndSettle();

      expect(find.text(topicLabel), findsOneWidget);
      expect(find.text(revealLabel), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(PracticeSessionScreen))),
        direction,
      );
      expect(find.text(timerLabel), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(revealLabel));
      await tester.pumpAndSettle();
      expect(find.text(answer), findsOneWidget);
      expect(find.text(language == 'en' ? 'Partly' : 'جزئيًا'), findsOneWidget);
      expect(find.text(language == 'en' ? 'Missed' : 'لم أجب'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('rate-nailed-it')));
      await tester.pumpAndSettle();
      expect(find.text(situationLabel), findsOneWidget);
      final field = find.byKey(const ValueKey('template-situation'));
      await tester.ensureVisible(field);
      await tester.enterText(
        field,
        language == 'en' ? 'Production incident' : 'حادث إنتاج',
      );
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(
        progress
            .records['flutter']!['behavioral']!
            .templateAnswers['situation'],
        language == 'en' ? 'Production incident' : 'حادث إنتاج',
      );
    });
  }

  testWidgets('resume button restores the saved session from track screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final track = practiceTrack();
    final progress = MemoryPracticeProgressRepository();
    const saved = SavedPracticeSession(
      mode: PracticeMode.topic,
      topicId: 'core',
      cardIds: ['intro', 'behavioral'],
      index: 1,
      revealed: true,
    );
    progress.sessions['flutter'] = saved;
    final cubit = TrackCubit(
      loadTracks: LoadTracks(MemoryTrackRepository([track])),
      progressRepository: progress,
      analytics: TestAnalytics(),
    );
    final router = AppRouter(
      createPracticeSessionCubit:
          () => PracticeSessionCubit(
            loadTracks: LoadTracks(MemoryTrackRepository([track])),
            progressRepository: progress,
            spacedRepetition: const SpacedRepetition(),
            analytics: TestAnalytics(),
          ),
    );

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light(),
        home: TrackRoute(cubit: cubit),
        onGenerateRoute: router.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume practice'));
    await tester.pumpAndSettle();
    expect(find.text('Question behavioral'), findsOneWidget);
    expect(
      find.text('A complete sample answer for behavioral.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('answer timer counts down from 90 seconds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder:
              (context) => Scaffold(
                body: AnswerTimerButton(strings: AppLocalizations.of(context)!),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Start 90-second timer'));
    await tester.pump();
    expect(find.text('1:30'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1:29'), findsOneWidget);
  });
}
