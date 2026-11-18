import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/app_language.dart';

/// Android's per-app language (Android 13+: Settings → Apps → Randnotiz →
/// Language), read and written through `MainActivity`.
class NativeAppLanguage {
  const NativeAppLanguage();

  static const _channel = MethodChannel('io.github.randnotiz.app/window');

  /// The per-app language tag ("fr", "" for the system's language), or null
  /// where Android has no per-app language (before Android 13, tests).
  Future<String?> read() async {
    try {
      return await _channel.invokeMethod<String>('appLanguage');
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('Reading the app language failed: $e');
      return null;
    }
  }

  Future<void> write(String tag) async {
    try {
      await _channel.invokeMethod<void>('setAppLanguage', {'tag': tag});
    } on MissingPluginException {
      // tests
    } on PlatformException catch (e) {
      debugPrint('Setting the app language failed: $e');
    }
  }
}

/// Keeps the language setting and Android's per-app language in step, so
/// both places show the same choice and the widget speaks the app's
/// language.
///
/// The setting is what counts – except when the language was changed in
/// Android's settings since Randnotiz last wrote it; then that choice is
/// taken over. [preferenceKey] remembers what Randnotiz wrote last.
class SystemLanguageSync {
  SystemLanguageSync({
    required this.native,
    required this.prefs,
    required this.current,
    required this.adopt,
  });

  final NativeAppLanguage native;
  final SharedPreferencesWithCache prefs;

  /// The language setting right now.
  final AppLanguage Function() current;

  /// Takes over a language chosen in Android's settings.
  final Future<void> Function(AppLanguage language) adopt;

  static const preferenceKey = 'nativeAppLanguage';

  static String _tag(AppLanguage language) =>
      language == AppLanguage.system ? '' : language.name;

  static AppLanguage _fromTag(String tag) {
    final code = tag.split(RegExp('[-_,]')).first;
    return AppLanguage.fromName(code) ?? AppLanguage.system;
  }

  /// At start and whenever the system's locales change.
  Future<void> reconcile() async {
    final nativeTag = await native.read();
    if (nativeTag == null) return;
    final written = prefs.getString(preferenceKey);
    if (written != null && nativeTag != written) {
      // Changed in Android's settings.
      await prefs.setString(preferenceKey, nativeTag);
      await adopt(_fromTag(nativeTag));
      return;
    }
    await push(current());
  }

  /// After the setting changed in the app.
  Future<void> push(AppLanguage language) async {
    final nativeTag = await native.read();
    if (nativeTag == null) return;
    final tag = _tag(language);
    // Remembered first: writing makes Android report new locales, and the
    // [reconcile] that follows must recognise its own change.
    await prefs.setString(preferenceKey, tag);
    if (nativeTag != tag) await native.write(tag);
  }
}
