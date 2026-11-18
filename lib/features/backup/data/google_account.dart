import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'remote/google_drive_store.dart';
import 'remote/remote_store.dart';

/// The Google account that holds the backup.
abstract interface class GoogleAccount implements AccessTokenSource {
  /// False if this build has no OAuth client (google.local.json missing).
  Future<bool> isConfigured();

  /// [email] (the account connected earlier) if it still grants the Drive
  /// permission – checked without any user interaction. Null otherwise.
  Future<String?> restore(String email);

  /// Interactive sign-in and Drive permission. Returns the e-mail, or null
  /// if the user cancelled.
  Future<String?> signIn();

  /// Revokes the permission and signs out.
  Future<void> signOut();
}

/// [GoogleAccount] via `google_sign_in` (Credential Manager / Play
/// services on Android). The web client id is built into the app from
/// google.local.json (see android/app/build.gradle.kts).
class GoogleSignInAccountSource implements GoogleAccount {
  GoogleSignInAccountSource({GoogleSignIn? signIn})
    : _signIn = signIn ?? GoogleSignIn.instance;

  static const scope = 'https://www.googleapis.com/auth/drive.appdata';
  static const _channel = MethodChannel('io.github.randnotiz.app/window');

  /// Tokens live an hour; a fresh one is fetched well before.
  static const _tokenLifetime = Duration(minutes: 40);

  final GoogleSignIn _signIn;
  Future<String?>? _clientId;
  Future<void>? _initialized;

  /// The connected account. Tokens are always requested for it, so a phone
  /// with several Google accounts never gets one for the wrong account.
  String? _email;
  String? _token;
  DateTime _tokenAt = DateTime(0);

  Future<String?> _webClientId() => _clientId ??= () async {
    try {
      final id = await _channel.invokeMethod<String>('googleWebClientId');
      return id == null || id.isEmpty ? null : id;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }();

  Future<void> _init() => _initialized ??= () async {
    final id = await _webClientId();
    if (id == null) throw const RemoteAuthException('not configured');
    await _signIn.initialize(serverClientId: id);
  }();

  @override
  Future<bool> isConfigured() async => await _webClientId() != null;

  /// Only authorization, no sign-in: `attemptLightweightAuthentication`
  /// shows Google's account sheet when it cannot sign in silently – at
  /// every app start. Authorizing the known account never shows UI.
  @override
  Future<String?> restore(String email) async {
    try {
      await _init();
      final token = await _silentToken(email);
      if (token == null) return null;
      _email = email;
      _remember(token);
      return email;
    } on GoogleSignInException catch (e) {
      debugPrint('Google authorization check failed: ${e.code}');
      return null;
    }
  }

  Future<String?> _silentToken(String email) async {
    final tokens = await GoogleSignInPlatform.instance
        .clientAuthorizationTokensForScopes(
          ClientAuthorizationTokensForScopesParameters(
            request: AuthorizationRequestDetails(
              scopes: const [scope],
              userId: null,
              email: email,
              promptIfUnauthorized: false,
            ),
          ),
        );
    return tokens?.accessToken;
  }

  @override
  Future<String?> signIn() async {
    await _init();
    try {
      final user = await _signIn.authenticate(scopeHint: const [scope]);
      final authz = await user.authorizationClient.authorizeScopes([scope]);
      _email = user.email;
      _remember(authz.accessToken);
      return user.email;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      debugPrint('Google sign-in failed: ${e.code} ${e.description}');
      rethrow;
    }
  }

  void _remember(String token) {
    _token = token;
    _tokenAt = DateTime.now();
  }

  @override
  Future<String> accessToken() async {
    final cached = _token;
    if (cached != null &&
        DateTime.now().difference(_tokenAt) < _tokenLifetime) {
      return cached;
    }
    final email = _email;
    if (email == null) throw const RemoteAuthException('not connected');
    await _init();
    try {
      final token = await _silentToken(email);
      if (token == null) throw const RemoteAuthException('consent needed');
      _remember(token);
      return token;
    } on GoogleSignInException catch (e) {
      throw RemoteAuthException(e.code.name);
    }
  }

  @override
  Future<void> invalidate(String token) async {
    if (_token == token) _token = null;
    try {
      await _signIn.authorizationClient.clearAuthorizationToken(
        accessToken: token,
      );
    } on Object catch (e) {
      debugPrint('Clearing a Google token failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    _token = null;
    _email = null;
    try {
      await _init();
      await _signIn.disconnect();
    } on Object catch (e) {
      debugPrint('Google sign-out failed: $e');
      try {
        await _signIn.signOut();
      } on Object {
        // Nothing more to do; the local key is gone anyway.
      }
    }
  }
}
