import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'recovery_code.dart';

/// Thrown when a password or emergency key does not open the key ring.
class WrongSecretException implements Exception {
  const WrongSecretException();

  @override
  String toString() => 'WrongSecretException';
}

/// Argon2id cost parameters for the backup password. Stored in the key ring,
/// so they can be raised later without breaking existing backups.
class KdfParams {
  const KdfParams({
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
  });

  /// 32 MiB, 3 passes – a few seconds on a phone, only when setting up,
  /// unlocking on a new device or changing the password.
  static const standard = KdfParams(
    memoryKiB: 32 * 1024,
    iterations: 3,
    parallelism: 1,
  );

  final int memoryKiB;
  final int iterations;
  final int parallelism;

  Map<String, Object?> toJson() => {
    'alg': 'argon2id',
    'memoryKiB': memoryKiB,
    'iterations': iterations,
    'parallelism': parallelism,
  };

  static KdfParams fromJson(Map<String, Object?> json) {
    if (json['alg'] != 'argon2id') {
      throw const FormatException('Unknown key derivation');
    }
    return KdfParams(
      memoryKiB: json['memoryKiB']! as int,
      iterations: json['iterations']! as int,
      parallelism: json['parallelism']! as int,
    );
  }
}

/// The data key, AES-GCM-encrypted with a key derived from one secret and
/// its own salt.
class WrappedKey {
  const WrappedKey({
    required this.salt,
    required this.nonce,
    required this.ciphertext,
  });

  final Uint8List salt;
  final Uint8List nonce;

  /// Ciphertext followed by the 16-byte authentication tag.
  final Uint8List ciphertext;

  Map<String, Object?> toJson() => {
    'salt': base64Encode(salt),
    'nonce': base64Encode(nonce),
    'ciphertext': base64Encode(ciphertext),
  };

  static WrappedKey fromJson(Map<String, Object?> json) => WrappedKey(
    salt: base64Decode(json['salt']! as String),
    nonce: base64Decode(json['nonce']! as String),
    ciphertext: base64Decode(json['ciphertext']! as String),
  );
}

/// Result of [KeyRing.create]: the ring to upload, the data key to keep on
/// the device and the emergency key to show to the user once.
typedef NewKeyRing = ({
  KeyRing ring,
  Uint8List dataKey,
  RecoveryCode recoveryCode,
});

/// `keyring.json` in the backup folder. Holds no secret in the clear: the
/// random 256-bit data key is stored twice, wrapped with the backup password
/// (Argon2id) and with the emergency key (HKDF; it has 128 random bits, so
/// it needs no slow derivation). Each slot has its own salt: changing the
/// password re-wraps only the password slot, the backup itself and the
/// emergency key stay as they are.
class KeyRing {
  const KeyRing({
    required this.keyId,
    required this.createdAt,
    required this.kdf,
    required this.password,
    required this.recovery,
  });

  static const fileName = 'keyring.json';
  static const formatVersion = 1;
  static const dataKeyLength = 32;

  /// Random id of the data key; every encrypted object names it, so a
  /// backup made with another key is recognised instead of failing oddly.
  final String keyId;
  final DateTime createdAt;

  /// Parameters of the password slot.
  final KdfParams kdf;
  final WrappedKey password;
  final WrappedKey recovery;

  static final _aes = AesGcm.with256bits();

  static Uint8List _random(int length, Random r) =>
      Uint8List.fromList(List.generate(length, (_) => r.nextInt(256)));

  static Future<NewKeyRing> create(
    String password, {
    KdfParams kdf = KdfParams.standard,
    Random? random,
    DateTime? now,
  }) async {
    final r = random ?? Random.secure();
    final dataKey = _random(dataKeyLength, r);
    final code = RecoveryCode.generate(r);
    final keyId = _random(
      8,
      r,
    ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final ring = KeyRing(
      keyId: keyId,
      createdAt: now ?? DateTime.now(),
      kdf: kdf,
      password: await _wrapPassword(dataKey, password, keyId, kdf, r),
      recovery: await _wrapRecovery(dataKey, code, keyId, r),
    );
    return (ring: ring, dataKey: dataKey, recoveryCode: code);
  }

  Future<Uint8List> unlockWithPassword(String password) async => _unwrap(
    this.password,
    await _passwordKey(password, this.password.salt, kdf),
    _aad(keyId, 'password'),
  );

  Future<Uint8List> unlockWithRecoveryCode(RecoveryCode code) async => _unwrap(
    recovery,
    await _recoveryKey(code, recovery.salt),
    _aad(keyId, 'recovery'),
  );

  /// Opens the ring with whatever the user typed: as emergency key if the
  /// input looks like one, otherwise (or if that fails) as password.
  Future<Uint8List> unlock(String passwordOrCode) async {
    final code = RecoveryCode.tryParse(passwordOrCode);
    if (code != null) {
      try {
        return await unlockWithRecoveryCode(code);
      } on WrongSecretException {
        // A password that happens to look like a key.
      }
    }
    return unlockWithPassword(passwordOrCode);
  }

  /// Same data key, new password. The emergency key keeps working.
  Future<KeyRing> withNewPassword(
    Uint8List dataKey,
    String newPassword, {
    KdfParams? kdf,
    Random? random,
  }) async {
    final params = kdf ?? this.kdf;
    return KeyRing(
      keyId: keyId,
      createdAt: createdAt,
      kdf: params,
      password: await _wrapPassword(
        dataKey,
        newPassword,
        keyId,
        params,
        random ?? Random.secure(),
      ),
      recovery: recovery,
    );
  }

  /// Same data key and password, a fresh emergency key (the old one stops
  /// working).
  Future<({KeyRing ring, RecoveryCode recoveryCode})> withNewRecoveryCode(
    Uint8List dataKey, {
    Random? random,
  }) async {
    final r = random ?? Random.secure();
    final code = RecoveryCode.generate(r);
    final ring = KeyRing(
      keyId: keyId,
      createdAt: createdAt,
      kdf: kdf,
      password: password,
      recovery: await _wrapRecovery(dataKey, code, keyId, r),
    );
    return (ring: ring, recoveryCode: code);
  }

  String encode() => const JsonEncoder.withIndent('  ').convert({
    'format': 'randnotiz-keyring',
    'version': formatVersion,
    'keyId': keyId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'kdf': kdf.toJson(),
    'wrapped': {'password': password.toJson(), 'recovery': recovery.toJson()},
  });

  static KeyRing decode(String source) {
    final json = jsonDecode(source);
    if (json is! Map<String, Object?> ||
        json['format'] != 'randnotiz-keyring') {
      throw const FormatException('Not a Randnotiz key ring');
    }
    final version = json['version'];
    if (version is! int || version > formatVersion) {
      throw FormatException('Unsupported key ring version $version');
    }
    final wrapped = json['wrapped']! as Map<String, Object?>;
    return KeyRing(
      keyId: json['keyId']! as String,
      createdAt: DateTime.parse(json['createdAt']! as String),
      kdf: KdfParams.fromJson(json['kdf']! as Map<String, Object?>),
      password: WrappedKey.fromJson(
        wrapped['password']! as Map<String, Object?>,
      ),
      recovery: WrappedKey.fromJson(
        wrapped['recovery']! as Map<String, Object?>,
      ),
    );
  }

  static Future<WrappedKey> _wrapPassword(
    List<int> dataKey,
    String password,
    String keyId,
    KdfParams kdf,
    Random r,
  ) async {
    final salt = _random(16, r);
    return _wrap(
      dataKey,
      await _passwordKey(password, salt, kdf),
      _aad(keyId, 'password'),
      salt,
      r,
    );
  }

  static Future<WrappedKey> _wrapRecovery(
    List<int> dataKey,
    RecoveryCode code,
    String keyId,
    Random r,
  ) async {
    final salt = _random(16, r);
    return _wrap(
      dataKey,
      await _recoveryKey(code, salt),
      _aad(keyId, 'recovery'),
      salt,
      r,
    );
  }

  static List<int> _aad(String keyId, String slot) =>
      utf8.encode('randnotiz-keyring:v1:$keyId:$slot');

  static Future<SecretKey> _passwordKey(
    String password,
    List<int> salt,
    KdfParams kdf,
  ) async {
    final argon = Argon2id(
      memory: kdf.memoryKiB,
      iterations: kdf.iterations,
      parallelism: kdf.parallelism,
      hashLength: 32,
    );
    return argon.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  static Future<SecretKey> _recoveryKey(RecoveryCode code, List<int> salt) =>
      Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
        secretKey: SecretKey(code.bytes),
        nonce: salt,
        info: utf8.encode('randnotiz recovery kek v1'),
      );

  static Future<WrappedKey> _wrap(
    List<int> dataKey,
    SecretKey kek,
    List<int> aad,
    Uint8List salt,
    Random r,
  ) async {
    final nonce = _random(12, r);
    final box = await _aes.encrypt(
      dataKey,
      secretKey: kek,
      nonce: nonce,
      aad: aad,
    );
    return WrappedKey(
      salt: salt,
      nonce: nonce,
      ciphertext: Uint8List.fromList([...box.cipherText, ...box.mac.bytes]),
    );
  }

  static Future<Uint8List> _unwrap(
    WrappedKey wrapped,
    SecretKey kek,
    List<int> aad,
  ) async {
    final c = wrapped.ciphertext;
    if (c.length != dataKeyLength + 16) throw const WrongSecretException();
    try {
      final plain = await _aes.decrypt(
        SecretBox(
          c.sublist(0, dataKeyLength),
          nonce: wrapped.nonce,
          mac: Mac(c.sublist(dataKeyLength)),
        ),
        secretKey: kek,
        aad: aad,
      );
      return Uint8List.fromList(plain);
    } on SecretBoxAuthenticationError {
      throw const WrongSecretException();
    }
  }
}
