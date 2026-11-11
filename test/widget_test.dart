import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interviewdex/app.dart';
import 'package:interviewdex/core/router/app_router.dart';
import 'package:interviewdex/core/theme/app_theme.dart';
import 'package:interviewdex/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:interviewdex/features/settings/domain/settings_preferences.dart';
import 'package:interviewdex/features/settings/domain/settings_repository.dart';
import 'package:interviewdex/features/settings/presentation/settings_cubit.dart';
import 'package:interviewdex/features/settings/presentation/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('English settings work at a 400px viewport', (tester) async {
    final repository = MemorySettingsRepository();
    final cubit = await _loadedCubit(repository);
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(App(router: AppRouter(), settingsCubit: cubit));
    await tester.pumpAndSettle();

    expect(find.text('Prepare for your next interview'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byIcon(Icons.style_outlined)).dx,
      tester.getTopLeft(find.text('Prepare for your next interview')).dx,
    );
    expect(
      find.text(
        'Real interview questions for Flutter developers. Built with Flutter.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Language')).dy, lessThan(220));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic settings render RTL and persist preferences', (
    tester,
  ) async {
    final repository = MemorySettingsRepository();
    final cubit = await _loadedCubit(repository);
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(App(router: AppRouter(), settingsCubit: cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('languagePreference')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية').last);
    await tester.pumpAndSettle();

    expect(find.text('اختر اللغة والمظهر المناسبين لك.'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(SettingsScreen))),
      TextDirection.rtl,
    );

    await tester.tap(find.byKey(const ValueKey('themePreference')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('داكن').last);
    await tester.pumpAndSettle();

    expect(repository.preferences.language, LanguagePreference.arabic);
    expect(repository.preferences.theme, ThemePreference.dark);
    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });

  test('theme colors expose the specified light and dark tokens', () {
    expect(AppColors.lightColors.background, const Color(0xFFEEF2F9));
    expect(AppColors.lightColors.heart, const Color(0xFFE9405A));
    expect(AppColors.darkColors.background, const Color(0xFF0D1322));
    expect(AppColors.darkColors.heart, const Color(0xFFFF6B81));
  });

  test('saved unknown settings fall back to system and log warnings', () async {
    SharedPreferences.setMockInitialValues({
      'settings.language': 'klingon',
      'settings.theme': 'sepia',
    });
    final preferences = await SharedPreferences.getInstance();
    final warnings = <String>[];
    final repository = SharedPreferencesSettingsRepository(
      preferences,
      logWarning: warnings.add,
    );

    final settings = await repository.load();

    expect(settings.language, LanguagePreference.system);
    expect(settings.theme, ThemePreference.system);
    expect(warnings, hasLength(2));
    expect(warnings[0], contains('Unknown saved language preference'));
    expect(warnings[1], contains('Unknown saved theme preference'));
  });

  test('allowed text and background pairs meet WCAG AA contrast', () {
    for (final colors in [AppColors.lightColors, AppColors.darkColors]) {
      final textBackgroundPairs = <(String, Color, String, Color)>[
        ('ink', colors.ink, 'background', colors.background),
        ('ink', colors.ink, 'surface', colors.surface),
        ('ink', colors.ink, 'surface2', colors.surface2),
        ('ink', colors.ink, 'accentSoft', colors.accentSoft),
        ('ink', colors.ink, 'goodSoft', colors.goodSoft),
        ('ink', colors.ink, 'badSoft', colors.badSoft),
        ('ink', colors.ink, 'goldSoft', colors.goldSoft),
        ('muted', colors.muted, 'background', colors.background),
        ('muted', colors.muted, 'surface', colors.surface),
        ('muted', colors.muted, 'surface2', colors.surface2),
        ('onAccent', colors.onAccent, 'accent', colors.accent),
      ];

      for (final (textName, textColor, backgroundName, backgroundColor)
          in textBackgroundPairs) {
        expect(
          _contrastRatio(textColor, backgroundColor),
          greaterThanOrEqualTo(4.5),
          reason:
              '${colors == AppColors.lightColors ? 'light' : 'dark'} '
              '$textName on $backgroundName must meet WCAG AA.',
        );
      }
    }
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter =
      firstLuminance > secondLuminance ? firstLuminance : secondLuminance;
  final darker =
      firstLuminance > secondLuminance ? secondLuminance : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

Future<SettingsCubit> _loadedCubit(MemorySettingsRepository repository) async {
  final cubit = SettingsCubit(repository);
  await cubit.load();
  return cubit;
}

class MemorySettingsRepository implements SettingsRepository {
  SettingsPreferences preferences = const SettingsPreferences();

  @override
  Future<SettingsPreferences> load() async => preferences;

  @override
  Future<void> save(SettingsPreferences preferences) async {
    this.preferences = preferences;
  }
}
