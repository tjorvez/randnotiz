import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hash;
import 'package:cryptography/cryptography.dart';

/// Thrown when an encrypted object was changed, belongs to another object
/// name or was made with another data key.
class BackupIntegrityException implements Exception {
  const BackupIntegrityException(this.message);

  final String message;

  @override
  String toString() => 'BackupIntegrityException: $message';
}

/// Encrypts every object of a backup on its own with AES-256-GCM.
///
/// Layout: `RNZ1` | keyId length (1 byte) | keyId (ASCII) | nonce (12 bytes)
/// | ciphertext | tag (16 bytes). The object name is authenticated as
/// additional data, so objects cannot be swapped or renamed unnoticed.
///
/// Two sub-keys are derived from the data key with HKDF: one encrypts, the
/// other names the photo blobs (an HMAC of the content hash), so file names
/// on the server reveal nothing and Google cannot recognise known images.
class BackupCipher {
  BackupCipher._(this.keyId, this._encKey, this._nameKey, this._random);

  static Future<BackupCipher> create(
    List<int> dataKey, {
    required String keyId,
    Random? random,
  }) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final master = SecretKey(dataKey);
    final enc = await hkdf.deriveKey(
      secretKey: master,
      nonce: hkdfNoSalt,
      info: utf8.encode('randnotiz enc v1'),
    );
    final name = await hkdf.deriveKey(
      secretKey: master,
      nonce: hkdfNoSalt,
      info: utf8.encode('randnotiz name v1'),
    );
    return BackupCipher._(
      keyId,
      enc,
      await name.extractBytes(),
      random ?? Random.secure(),
    );
  }

  /// HKDF "without salt": RFC 5869 defines that as HashLen zero bytes, and
  /// HMAC pads a shorter key with zeros, so this derives the same keys as an
  /// empty salt. An empty salt itself fails on Android: cryptography_flutter
  /// runs HMAC in Java, whose SecretKeySpec rejects empty keys.
  static const hkdfNoSalt = <int>[
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
  ];

  static const _magic = [0x52, 0x4e, 0x5a, 0x31]; // "RNZ1"
  static const _nonceLength = 12;
  static const _tagLength = 16;
  static final _aes = AesGcm.with256bits();

  final String keyId;
  final SecretKey _encKey;
  final List<int> _nameKey;
  final Random _random;

  static List<int> _aad(String objectName) =>
      utf8.encode('randnotiz-object:v1:$objectName');

  Future<Uint8List> seal(List<int> plain, {required String objectName}) async {
    final nonce = List<int>.generate(_nonceLength, (_) => _random.nextInt(256));
    final box = await _aes.encrypt(
      plain,
      secretKey: _encKey,
      nonce: nonce,
      aad: _aad(objectName),
    );
    final id = ascii.encode(keyId);
    return Uint8List.fromList([
      ..._magic,
      id.length,
      ...id,
      ...nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ]);
  }

  /// The key id an encrypted object was made with, or null if [sealed] is no
  /// Randnotiz object.
  static String? keyIdOf(List<int> sealed) {
    if (sealed.length < 5) return null;
    for (var i = 0; i < 4; i++) {
      if (sealed[i] != _magic[i]) return null;
    }
    final n = sealed[4];
    if (sealed.length < 5 + n) return null;
    return ascii.decode(sealed.sublist(5, 5 + n), allowInvalid: true);
  }

  Future<Uint8List> open(List<int> sealed, {required String objectName}) async {
    final id = keyIdOf(sealed);
    if (id == null) {
      throw const BackupIntegrityException('not an encrypted object');
    }
    if (id != keyId) {
      throw const BackupIntegrityException('made with another key');
    }
    final start = 5 + id.length;
    if (sealed.length < start + _nonceLength + _tagLength) {
      throw const BackupIntegrityException('truncated');
    }
    final nonce = sealed.sublist(start, start + _nonceLength);
    final body = sealed.sublist(start + _nonceLength);
    try {
      final plain = await _aes.decrypt(
        SecretBox(
          body.sublist(0, body.length - _tagLength),
          nonce: nonce,
          mac: Mac(body.sublist(body.length - _tagLength)),
        ),
        secretKey: _encKey,
        aad: _aad(objectName),
      );
      return Uint8List.fromList(plain);
    } on SecretBoxAuthenticationError {
      throw const BackupIntegrityException('authentication failed');
    }
  }

  /// Server-side name of a photo/cover with the given plaintext SHA-256.
  /// Content-addressed: the same image always gets the same name, so it is
  /// uploaded once.
  String blobNameFor(String sha256Hex) =>
      'b-${hash.Hmac(hash.sha256, _nameKey).convert(utf8.encode(sha256Hex))}';
}
