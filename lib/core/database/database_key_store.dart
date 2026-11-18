import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The key of the encrypted on-device database: 32 random bytes as 64 hex
/// digits. Lives only in the Android Keystore-backed secure storage, which
/// is excluded from every system backup (data_extraction_rules.xml) – the
/// database file alone is unreadable on any other device or for any other
/// app.
abstract interface class DatabaseKeyStore {
  /// The stored key, or null if there is none (first start, or the Keystore
  /// was reset). Throws if the storage cannot be read at the moment.
  Future<String?> read();

  Future<void> write(String keyHex);
}

/// [DatabaseKeyStore] in the Android Keystore-backed secure storage.
class SecureDatabaseKeyStore implements DatabaseKeyStore {
  SecureDatabaseKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'database.key';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    final value = await _storage.read(key: _key);
    return value != null && isValidDatabaseKey(value) ? value : null;
  }

  @override
  Future<void> write(String keyHex) => _storage.write(key: _key, value: keyHex);
}

/// A fresh random database key (256 bit, hex).
String newDatabaseKey([Random? random]) {
  final r = random ?? Random.secure();
  return [
    for (var i = 0; i < 32; i++)
      r.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

/// 64 hex digits – the only form ever put into a PRAGMA.
bool isValidDatabaseKey(String keyHex) =>
    RegExp(r'^[0-9a-f]{64}$').hasMatch(keyHex);
