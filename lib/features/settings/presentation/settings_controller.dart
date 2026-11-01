import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

/// Debug-only build flags, e.g.
/// `flutter run --dart-define=RANDNOTIZ_DEBUG_NO_LOCK=true`. Ignored in
/// release/profile builds.
const _debugNoLock = bool.fromEnvironment('RANDNOTIZ_DEBUG_NO_LOCK');

/// Debug builds started with RANDNOTIZ_DEBUG_NO_LOCK skip the lock at
/// runtime. This never touches the saved setting.
bool get debugLockBypassed => kDebugMode && _debugNoLock;

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(preferencesProvider)),
);

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.watch(settingsRepositoryProvider).load();
  }

  Future<void> update(AppSettings Function(AppSettings) change) async {
    final next = change(state);
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      update((s) => s.copyWith(themeMode: mode));
  Future<void> setLockEnabled(bool v) =>
      update((s) => s.copyWith(lockEnabled: v));
  Future<void> setLockTimeout(Duration d) =>
      update((s) => s.copyWith(lockTimeout: d));
  Future<void> setWidgetShowsText(bool v) =>
      update((s) => s.copyWith(widgetShowsText: v));
}
