enum AuthResult {
  success,

  /// User closed the dialog or a system event cancelled it.
  canceled,

  /// Too many attempts; the device locked biometrics for a while.
  lockedOut,

  /// The device has no screen lock / biometrics configured.
  notAvailable,
  failed,
}

/// Device authentication (biometrics with fallback to PIN/pattern/password).
abstract interface class Authenticator {
  /// Whether the device can authenticate the user at all (screen lock set).
  Future<bool> isAvailable();

  Future<AuthResult> authenticate({required String reason});
}
