import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/settings_preferences.dart';
import '../settings_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                if (state is! SettingsLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        localizations.settingsDescription,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<LanguagePreference>(
                        key: const ValueKey('languagePreference'),
                        value: state.preferences.language,
                        decoration: InputDecoration(
                          labelText: localizations.language,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: LanguagePreference.system,
                            child: Text(localizations.languageSystem),
                          ),
                          DropdownMenuItem(
                            value: LanguagePreference.english,
                            child: Text(localizations.languageEnglish),
                          ),
                          DropdownMenuItem(
                            value: LanguagePreference.arabic,
                            child: Text(localizations.languageArabic),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            unawaited(
                              context.read<SettingsCubit>().setLanguage(value),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<ThemePreference>(
                        key: const ValueKey('themePreference'),
                        value: state.preferences.theme,
                        decoration: InputDecoration(
                          labelText: localizations.appearance,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: ThemePreference.system,
                            child: Text(localizations.themeSystem),
                          ),
                          DropdownMenuItem(
                            value: ThemePreference.light,
                            child: Text(localizations.themeLight),
                          ),
                          DropdownMenuItem(
                            value: ThemePreference.dark,
                            child: Text(localizations.themeDark),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            unawaited(
                              context.read<SettingsCubit>().setTheme(value),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.savedAutomatically,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
