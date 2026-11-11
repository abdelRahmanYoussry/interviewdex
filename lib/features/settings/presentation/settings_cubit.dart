import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/settings_preferences.dart';
import '../domain/settings_repository.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();

  @override
  List<Object> get props => const [];
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded(this.preferences);

  final SettingsPreferences preferences;

  @override
  List<Object> get props => [preferences];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsLoading());

  final SettingsRepository _repository;

  Future<void> load() async {
    emit(SettingsLoaded(await _repository.load()));
  }

  Future<void> setLanguage(LanguagePreference language) async {
    final preferences = _loadedPreferences().copyWith(language: language);
    await _repository.save(preferences);
    emit(SettingsLoaded(preferences));
  }

  Future<void> setTheme(ThemePreference theme) async {
    final preferences = _loadedPreferences().copyWith(theme: theme);
    await _repository.save(preferences);
    emit(SettingsLoaded(preferences));
  }

  SettingsPreferences _loadedPreferences() {
    final currentState = state;
    if (currentState is SettingsLoaded) return currentState.preferences;
    throw StateError('Settings must be loaded before they can be changed.');
  }
}

extension on SettingsPreferences {
  SettingsPreferences copyWith({
    LanguagePreference? language,
    ThemePreference? theme,
  }) {
    return SettingsPreferences(
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }
}
