import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../domain/authenticator.dart';

class LocalAuthAuthenticator implements Authenticator {
  LocalAuthAuthenticator([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('Auth availability check failed: $e');
      return false;
    }
  }

  @override
  Future<AuthResult> authenticate({required String reason}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        // Fingerprint/face with fallback to the device PIN/pattern/password.
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      return ok ? AuthResult.success : AuthResult.canceled;
    } on LocalAuthException catch (e) {
      debugPrint('Auth failed: ${e.code}');
      return switch (e.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.timeout ||
        LocalAuthExceptionCode.authInProgress => AuthResult.canceled,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout => AuthResult.lockedOut,
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.noBiometricHardware => AuthResult.notAvailable,
        _ => AuthResult.failed,
      };
    } on PlatformException catch (e) {
      debugPrint('Auth platform error: $e');
      return AuthResult.failed;
    }
  }
}
