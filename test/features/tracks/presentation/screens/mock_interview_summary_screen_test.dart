import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/core/theme/app_theme.dart';
import 'package:interviewdex/features/tracks/domain/entities/card_progress.dart';
import 'package:interviewdex/features/tracks/domain/use_cases/summarize_mock_interview.dart';
import 'package:interviewdex/features/tracks/presentation/screens/mock_interview_summary_screen.dart';
import 'package:interviewdex/l10n/app_localizations.dart';

import '../../support/practice_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final track = practiceTrack();
  final summary = const SummarizeMockInterview()(track, const {
    'intro': CardRating.missed,
    'behavioral': CardRating.partly,
    'technical': CardRating.nailedIt,
  });

  for (final (language, direction, weakTopic, scoreText) in [
    ('en', TextDirection.ltr, 'Core concepts', '25%'),
    ('ar', TextDirection.rtl, 'مفاهيم أساسية', '25%'),
  ]) {
    testWidgets('summary renders in $language at 400px', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light(),
          home: MockInterviewSummaryScreen(track: track, summary: summary),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(weakTopic), findsWidgets);
      expect(find.text(scoreText), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(
        find.text(
          language == 'en'
              ? 'Mock interview results'
              : 'نتائج المقابلة التجريبية',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          language == 'en' ? 'Practice this topic' : 'تدرب على هذا الموضوع',
        ),
        findsOneWidget,
      );
      expect(
        Directionality.of(
          tester.element(find.byType(MockInterviewSummaryScreen)),
        ),
        direction,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
