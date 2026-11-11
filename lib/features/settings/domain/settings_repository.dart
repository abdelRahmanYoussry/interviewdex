import 'settings_preferences.dart';

abstract interface class SettingsRepository {
  Future<SettingsPreferences> load();

  Future<void> save(SettingsPreferences preferences);
}
