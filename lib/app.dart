import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/domain/settings_preferences.dart';
import 'features/settings/presentation/settings_cubit.dart';
import 'l10n/app_localizations.dart';

class App extends StatelessWidget {
  const App({required this.router, required this.settingsCubit, super.key});

  final AppRouter router;
  final SettingsCubit settingsCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: settingsCubit,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }
          final preferences = state.preferences;
          return MaterialApp(
            onGenerateTitle:
                (context) => AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: switch (preferences.language) {
              LanguagePreference.system => null,
              LanguagePreference.english => const Locale('en'),
              LanguagePreference.arabic => const Locale('ar'),
            },
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: switch (preferences.theme) {
              ThemePreference.system => ThemeMode.system,
              ThemePreference.light => ThemeMode.light,
              ThemePreference.dark => ThemeMode.dark,
            },
            initialRoute: AppRoutes.home,
            onGenerateRoute: router.onGenerateRoute,
          );
        },
      ),
    );
  }
}
