import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The data key of the backup on this device, so automatic backups need no
/// password. Kept out of every system backup (data_extraction_rules.xml).
typedef StoredBackupKey = ({String keyId, Uint8List dataKey});

abstract interface class BackupKeyStore {
  Future<StoredBackupKey?> read();

  Future<void> write(StoredBackupKey key);

  Future<void> delete();
}

/// [BackupKeyStore] in the Android Keystore-backed secure storage.
class SecureBackupKeyStore implements BackupKeyStore {
  SecureBackupKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'backup.dataKey';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredBackupKey?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, Object?>;
      return (
        keyId: json['keyId']! as String,
        dataKey: base64Decode(json['dataKey']! as String),
      );
    } on Object {
      // Unreadable (e.g. Keystore reset): the user unlocks once more.
      return null;
    }
  }

  @override
  Future<void> write(StoredBackupKey key) => _storage.write(
    key: _key,
    value: jsonEncode({
      'keyId': key.keyId,
      'dataKey': base64Encode(key.dataKey),
    }),
  );

  @override
  Future<void> delete() => _storage.delete(key: _key);
}
