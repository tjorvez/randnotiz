import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Controls Android's FLAG_SECURE (hides app content in the recents overview
/// and blocks screenshots/screen recording/casting).
///
/// The flag follows the app lock (see [windowShouldBeSecure]). The native
/// side remembers the last value so it is already right before the first
/// frame of the next start.
class SecureWindow {
  const SecureWindow();

  static const _channel = MethodChannel('io.github.randnotiz.app/window');

  Future<void> setSecure(bool secure) async {
    try {
      await _channel.invokeMethod<bool>('setSecure', {'secure': secure});
    } on MissingPluginException {
      // Tests / non-Android platforms.
    } on PlatformException catch (e) {
      debugPrint('SecureWindow: $e');
    }
  }
}

/// Screenshots and screen casting are blocked exactly while the app lock is
/// in effect: switched on, possible on this device (screen lock set up) and
/// not bypassed by a debug flag – and only in release builds. Debug and
/// profile builds never set FLAG_SECURE, so screenshots work during
/// development (the native side enforces the same rule).
bool windowShouldBeSecure({
  required bool lockEnabled,
  required bool lockAvailable,
  bool lockBypassed = false,
  bool releaseBuild = kReleaseMode,
}) {
  if (!releaseBuild) return false;
  return lockEnabled && lockAvailable && !lockBypassed;
}
