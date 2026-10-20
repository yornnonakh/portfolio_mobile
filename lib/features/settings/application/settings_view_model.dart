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
    this.saving = false,
    this.error,
  });
  final ThemeMode themeMode;
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
      error: store.canPersist
          ? null
          : 'Device storage is unavailable. Settings cannot be saved right now.',
    );
  }

  Future<void> setTheme(ThemeMode mode) => _save(mode: mode);
  Future<void> setAnimations(bool value) => _save(animations: value);
  Future<void> _save({ThemeMode? mode, bool? animations}) async {
    if (state.saving) return;
    final previous = state;
    state = AppSettings(
      themeMode: previous.themeMode,
      animations: previous.animations,
      saving: true,
    );
    try {
      final store = ref.read(settingsRepositoryProvider);
      if (mode != null) await store.saveTheme(mode.name);
      if (animations != null) await store.saveAnimations(animations);
      if (!ref.mounted) return;
      state = AppSettings(
        themeMode: mode ?? previous.themeMode,
        animations: animations ?? previous.animations,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = AppSettings(
        themeMode: previous.themeMode,
        animations: previous.animations,
        error: 'Unable to save your preference. Please try again.',
      );
    }
  }
}
