import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/core/constants.dart';
import 'package:interviewdex/core/theme/app_theme.dart';
import 'package:interviewdex/features/home/presentation/screens/home_screen.dart';
import 'package:interviewdex/l10n/app_localizations.dart';

void main() {
  for (final (language, tooltip) in [
    ('en', 'GitHub repo'),
    ('ar', 'مستودع GitHub'),
  ]) {
    testWidgets('repository button launches URL in $language', (tester) async {
      Uri? launched;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          theme: AppTheme.light(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: HomeScreen(
            launchRepository: (uri) async {
              launched = uri;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip(tooltip), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
      expect(launched, Uri.parse(AppConstants.repositoryUrl));
      expect(
        launched.toString(),
        'https://github.com/abdelRahmanYoussry/interviewdex',
      );
    });
  }

  testWidgets('repository launch failure is displayed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: AppTheme.light(),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: HomeScreen(launchRepository: (_) async => false),
      ),
    );
    await tester.tap(find.byTooltip('GitHub repo'));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't open the GitHub repository."), findsOneWidget);
  });
}
