import 'package:equatable/equatable.dart';

enum LanguagePreference { system, english, arabic }

enum ThemePreference { system, light, dark }

class SettingsPreferences extends Equatable {
  const SettingsPreferences({
    this.language = LanguagePreference.system,
    this.theme = ThemePreference.system,
  });

  final LanguagePreference language;
  final ThemePreference theme;

  @override
  List<Object> get props => [language, theme];
}
