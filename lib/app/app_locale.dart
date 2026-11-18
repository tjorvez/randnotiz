import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_language.dart';
import '../features/settings/presentation/settings_controller.dart';

/// The device's preferred locales, most preferred first. `RandnotizApp`
/// reports changes (system language changed while the app runs).
final deviceLocalesProvider = NotifierProvider<DeviceLocales, List<Locale>>(
  DeviceLocales.new,
);

class DeviceLocales extends Notifier<List<Locale>> {
  @override
  List<Locale> build() => PlatformDispatcher.instance.locales;

  void changed(List<Locale> locales) => state = locales;
}

/// The language the app shows: the setting, resolved against the device
/// for "System" (English if the device speaks none of ours).
final appLanguageProvider = Provider<AppLanguage>(
  (ref) => resolveAppLanguage(
    ref.watch(settingsProvider.select((s) => s.language)),
    ref.watch(deviceLocalesProvider),
  ),
);

/// [appLanguageProvider] as the locale handed to `MaterialApp`.
final appLocaleProvider = Provider<Locale>(
  (ref) => Locale(ref.watch(appLanguageProvider).name),
);

/// The speech recognition locale for dictation ("fr_FR").
final speechLocaleProvider = Provider<String>(
  (ref) => speechLocaleId(
    ref.watch(appLanguageProvider),
    ref.watch(deviceLocalesProvider),
  ),
);
