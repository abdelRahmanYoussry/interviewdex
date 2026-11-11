import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/core/theme/app_theme.dart';
import 'package:interviewdex/features/tracks/domain/entities/saved_practice_session.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/load_tracks.dart';
import 'package:interviewdex/features/tracks/presentation/cubits/track_cubit.dart';
import 'package:interviewdex/features/tracks/presentation/screens/track_screen.dart';
import 'package:interviewdex/l10n/app_localizations.dart';

import '../../support/practice_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final (language, trackName, topicName, direction) in [
    ('en', 'Flutter', 'Core concepts', TextDirection.ltr),
    ('ar', 'فلاتر', 'مفاهيم أساسية', TextDirection.rtl),
  ]) {
    testWidgets('single-track dashboard works in $language at 400px', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final cubit = TrackCubit(
        loadTracks: LoadTracks(MemoryTrackRepository([practiceTrack()])),
        progressRepository: MemoryPracticeProgressRepository(),
        analytics: TestAnalytics(),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light(),
          home: TrackRoute(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(trackName), findsNWidgets(2));
      expect(find.text(topicName), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(TrackScreen))),
        direction,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('multi-track picker works in $language at 400px', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final cubit = TrackCubit(
        loadTracks: LoadTracks(
          MemoryTrackRepository([
            practiceTrack(),
            practiceTrack(id: 'another', name: 'Another'),
          ]),
        ),
        progressRepository: MemoryPracticeProgressRepository(),
        analytics: TestAnalytics(),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light(),
          home: TrackRoute(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(language == 'en' ? 'Choose a track' : 'اختر المسار'),
        findsOneWidget,
      );
      expect(
        Directionality.of(tester.element(find.byType(TrackScreen))),
        direction,
      );
      await tester.tap(find.text(trackName).first);
      await tester.pumpAndSettle();
      expect(find.text(topicName), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('stale saved sessions do not show a resume button', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final progress =
        MemoryPracticeProgressRepository()
          ..sessions['flutter'] = const SavedPracticeSession(
            mode: PracticeMode.topic,
            cardIds: ['removed-card'],
            index: 0,
            revealed: false,
          );
    final cubit = TrackCubit(
      loadTracks: LoadTracks(MemoryTrackRepository([practiceTrack()])),
      progressRepository: progress,
      analytics: TestAnalytics(),
    );

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light(),
        home: TrackRoute(cubit: cubit),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resume practice'), findsNothing);
    expect(progress.sessions, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
