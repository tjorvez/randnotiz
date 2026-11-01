import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _window = MethodChannel('io.github.randnotiz.app/window');

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
