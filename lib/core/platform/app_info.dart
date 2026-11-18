import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_language.dart';

const _window = MethodChannel('io.github.randnotiz.app/window');

/// The privacy policy on the website (PRIVACY.md in the repository only
/// points there), in [language]: every translation has its own page, the
/// German one is the original. The trailing slash is part of the address
/// (without it the site redirects). The Play Console holds one of these
/// URLs – keep it in step.
Uri privacyPolicyUrl(AppLanguage language) =>
    Uri.https('randnotiz.info', switch (language) {
      AppLanguage.de => '/de/datenschutz/',
      AppLanguage.fr => '/fr/confidentialite/',
      AppLanguage.es => '/es/privacidad/',
      AppLanguage.en || AppLanguage.system => '/en/privacy/',
    });

/// [privacyPolicyUrl] as shown to people: without the scheme and the
/// trailing slash ("randnotiz.info/de/datenschutz").
String privacyPolicyLabel(AppLanguage language) {
  final url = privacyPolicyUrl(language);
  final path = url.path.endsWith('/')
      ? url.path.substring(0, url.path.length - 1)
      : url.path;
  return '${url.host}$path';
}

/// Copyright line under "About Randnotiz" and on the licence page.
const appCopyright = '© 2026 Even Tjorve Zankl';

/// Where the source code lives (GPL-3.0-or-later), as shown under "About
/// Randnotiz": without the scheme, like [privacyPolicyLabel].
const sourceCodeLabel = 'github.com/tjorvez/randnotiz';

/// The app's version name as built (from pubspec.yaml via Gradle), shown
/// under "Über Randnotiz". Null where the platform side is missing (tests).
final appVersionProvider = FutureProvider<String?>((ref) async {
  try {
    return await _window.invokeMethod<String>('appVersion');
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
});

/// Suffix of the separate test app "Randnotiz Dev" (see
/// android/app/build.gradle.kts, `-P randnotizDev=true` or
/// `-P randnotizDevRelease=true`).
const devInstallSuffix = '.dev';

/// True for the test app "Randnotiz Dev". It has its own database but
/// shares the Drive backup folder with the real app, so the backup screen
/// warns and asks before risky steps. Read once in main(); false in tests.
final devInstallProvider = Provider<bool>((ref) => false);

/// Asks the platform for the installed application id.
Future<bool> readIsDevInstall() async {
  try {
    final id = await _window.invokeMethod<String>('applicationId');
    return isDevApplicationId(id);
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

bool isDevApplicationId(String? id) =>
    id != null && id.endsWith(devInstallSuffix);
