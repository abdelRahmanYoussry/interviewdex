import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

import '../domain/settings_preferences.dart';
import '../domain/settings_repository.dart';

class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository(
    this._preferences, {
    void Function(String message)? logWarning,
  }) : _logWarning = logWarning ?? debugPrint;

  static const _languageKey = 'settings.language';
  static const _themeKey = 'settings.theme';

  final SharedPreferences _preferences;
  final void Function(String message) _logWarning;

  @override
  Future<SettingsPreferences> load() async {
    return SettingsPreferences(
      language: _languagePreference(_preferences.getString(_languageKey)),
      theme: _themePreference(_preferences.getString(_themeKey)),
    );
  }

  @override
  Future<void> save(SettingsPreferences preferences) async {
    await _preferences.setString(_languageKey, preferences.language.name);
    await _preferences.setString(_themeKey, preferences.theme.name);
  }

  LanguagePreference _languagePreference(String? value) {
    if (value == null) return LanguagePreference.system;
    for (final preference in LanguagePreference.values) {
      if (preference.name == value) return preference;
    }
    _logWarning('Unknown saved language preference "$value"; using system.');
    return LanguagePreference.system;
  }

  ThemePreference _themePreference(String? value) {
    if (value == null) return ThemePreference.system;
    for (final preference in ThemePreference.values) {
      if (preference.name == value) return preference;
    }
    _logWarning('Unknown saved theme preference "$value"; using system.');
    return ThemePreference.system;
  }
}
