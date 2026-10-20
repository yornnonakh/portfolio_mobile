import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw StateError(
    'Settings repository must be initialized at app startup.',
  ),
);

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.animations = true,
    this.languageCode = 'en',
    this.saving = false,
    this.error,
  });
  final ThemeMode themeMode;
  final String languageCode;
  final bool animations, saving;
  final String? error;
}

final settingsProvider = NotifierProvider<SettingsViewModel, AppSettings>(
  SettingsViewModel.new,
);

class SettingsViewModel extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final store = ref.watch(settingsRepositoryProvider);
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == store.theme,
        orElse: () => ThemeMode.system,
      ),
      animations: store.animations,
      languageCode: store.languageCode,
      error: store.canPersist
          ? null
          : 'Device storage is unavailable. Settings cannot be saved right now.',
    );
  }

  Future<void> setTheme(ThemeMode mode) => _save(mode: mode);
  Future<void> setAnimations(bool value) => _save(animations: value);
  Future<void> setLanguage(String code) {
    if (!['en', 'km'].contains(code)) return Future.value();
    return _save(languageCode: code);
  }

  Future<void> _save({
    ThemeMode? mode,
    bool? animations,
    String? languageCode,
  }) async {
    if (state.saving) return;
    final previous = state;
    state = AppSettings(
      themeMode: previous.themeMode,
      animations: previous.animations,
      languageCode: previous.languageCode,
      saving: true,
    );
    try {
      final store = ref.read(settingsRepositoryProvider);
      if (mode != null) await store.saveTheme(mode.name);
      if (animations != null) await store.saveAnimations(animations);
      if (languageCode != null) await store.saveLanguage(languageCode);
      if (!ref.mounted) return;
      state = AppSettings(
        themeMode: mode ?? previous.themeMode,
        animations: animations ?? previous.animations,
        languageCode: languageCode ?? previous.languageCode,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = AppSettings(
        themeMode: previous.themeMode,
        animations: previous.animations,
        languageCode: previous.languageCode,
        error: 'Unable to save your preference. Please try again.',
      );
    }
  }
}
