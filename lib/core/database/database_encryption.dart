import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqlite3/common.dart' show CommonDatabase;
import 'package:sqlite3/sqlite3.dart';

import 'database_key_store.dart';

/// How the database is to be opened, as decided by
/// [DatabaseEncryption.prepare].
sealed class PreparedDatabase {
  const PreparedDatabase();
}

/// Open with [key]. With [replacedUnreadable] the previous database could
/// not be opened any more (its key is gone) and was moved aside: this is a
/// new, empty one, and the person should hear about it.
final class OpenEncrypted extends PreparedDatabase {
  const OpenEncrypted(this.key, {this.replacedUnreadable = false});

  final String key;
  final bool replacedUnreadable;
}

/// Open without a key: the database is (still) unencrypted, because
/// encrypting it failed or the Keystore could not be used right now. The
/// notes are all there; the next start tries again.
final class OpenUnencrypted extends PreparedDatabase {
  const OpenUnencrypted([this.reason]);

  final Object? reason;
}

/// The database is encrypted, but right now it cannot be opened (the
/// Keystore does not answer, the file is locked …). Nothing was changed;
/// trying again later may work.
final class DatabaseUnavailable extends PreparedDatabase {
  const DatabaseUnavailable(this.reason);

  final Object reason;
}

/// Keeps the on-device database encrypted (SQLite3MultipleCiphers, see the
/// `hooks` section in pubspec.yaml).
///
/// [prepare] runs at every start, before drift opens the file, decides how
/// to open it and never throws – whatever goes wrong, the notes stay as
/// they are and the app starts:
///
/// * no database yet → a new key; the database is created encrypted.
/// * an unencrypted database (Randnotiz up to 1.2.1) → it is encrypted: an
///   encrypted copy is made, checked and only then moved over the original,
///   so an interruption at any point leaves a readable database. If that
///   fails (no space left, …) the app opens it unencrypted as before and
///   the next start tries again.
/// * an encrypted database that the stored key does not open (the Keystore
///   was reset) → nothing can read it any more. It is moved aside, not
///   deleted, and the app starts empty and says so ([OpenEncrypted.
///   replacedUnreadable]); the notes come back from the backup.
/// * an encrypted database while the Keystore cannot be read, or any other
///   error → [DatabaseUnavailable], nothing is touched.
class DatabaseEncryption {
  DatabaseEncryption({required this.keys, String Function()? newKey})
    : _newKey = newKey ?? newDatabaseKey;

  final DatabaseKeyStore keys;
  final String Function() _newKey;

  static final _plainHeader = Uint8List.fromList(
    'SQLite format 3\u0000'.codeUnits,
  );

  Future<PreparedDatabase> prepare(File file) async {
    try {
      return await _prepare(file);
    } on Object catch (e) {
      debugPrint('Preparing the database failed: $e');
      try {
        if (!file.existsSync() || _isPlain(file)) return OpenUnencrypted(e);
      } on Object {
        // Fall through: nothing is known about the file.
      }
      return DatabaseUnavailable(e);
    }
  }

  Future<PreparedDatabase> _prepare(File file) async {
    String? stored;
    Object? keystoreError;
    try {
      stored = await _readKey();
    } on Object catch (e) {
      keystoreError = e;
    }
    _deleteIfExists(File('${file.path}$_encryptingSuffix'));
    _deleteIfExists(File('${file.path}$_encryptingSuffix-journal'));

    if (file.existsSync() && file.lengthSync() == 0) {
      // SQLite never wrote anything – nothing to keep.
      _deleteWithSideFiles(file);
    }

    if (!file.existsSync() || _isPlain(file)) {
      // Without a usable Keystore it stays (or starts) unencrypted for now.
      if (keystoreError != null) return OpenUnencrypted(keystoreError);
      final key = stored ?? await _createKey(); // saved before anything else
      if (!file.existsSync()) return OpenEncrypted(key);
      try {
        _encrypt(file, key);
      } on Object catch (e) {
        debugPrint('Encrypting the database failed, next start again: $e');
        _deleteIfExists(File('${file.path}$_encryptingSuffix'));
        _deleteIfExists(File('${file.path}$_encryptingSuffix-journal'));
        return OpenUnencrypted(e);
      }
      return OpenEncrypted(key);
    }

    // Encrypted. Only a key that is definitely gone or definitely wrong
    // gives the file up; anything uncertain leaves it alone.
    if (keystoreError != null) return DatabaseUnavailable(keystoreError);
    if (stored != null && opensWith(file, stored)) return OpenEncrypted(stored);

    final aside = File(
      '${file.path}.unreadable-${DateTime.now().millisecondsSinceEpoch}',
    );
    debugPrint('Database key missing or wrong – moving ${file.path} aside');
    _deleteSideFiles(file);
    file.renameSync(aside.path);
    return OpenEncrypted(await _createKey(), replacedUnreadable: true);
  }

  /// The stored key. A Keystore that cannot be read right now is not the
  /// same as a lost key (a reset Keystore reads as empty, see
  /// `AndroidOptions.resetOnError`): after one retry the error goes up and
  /// the database stays untouched for the next start.
  Future<String?> _readKey() async {
    try {
      return await keys.read();
    } on Object {
      return keys.read();
    }
  }

  Future<String> _createKey() async {
    final key = _newKey();
    await keys.write(key);
    return key;
  }

  static const _encryptingSuffix = '.encrypting';

  bool _isPlain(File file) {
    final raf = file.openSync();
    try {
      final head = raf.readSync(_plainHeader.length);
      return listEquals(head, _plainHeader);
    } finally {
      raf.closeSync();
    }
  }

  void _encrypt(File file, String key) {
    // Fold a leftover WAL/journal into the file itself.
    final original = sqlite3.open(file.path);
    final String journalMode;
    try {
      journalMode =
          original.select('PRAGMA journal_mode').first.values.first! as String;
      original.execute('PRAGMA journal_mode = DELETE');
    } finally {
      original.close();
    }

    final copy = File('${file.path}$_encryptingSuffix');
    file.copySync(copy.path);
    final db = sqlite3.open(copy.path);
    try {
      db.execute('PRAGMA rekey = ${_keyLiteral(key)}');
      if (journalMode.toLowerCase() == 'wal') {
        db.execute('PRAGMA journal_mode = WAL');
      }
    } finally {
      db.close();
    }
    if (!opensWith(copy, key, check: true)) {
      copy.deleteSync();
      throw StateError('Encrypting the database failed the integrity check');
    }
    // Side files of the unencrypted database must never be applied to the
    // encrypted one.
    _deleteSideFiles(file);
    copy.renameSync(file.path); // atomic replace
  }

  /// Whether [key] opens [file] (and, with [check], it is intact). False
  /// only when SQLite says the file is no database with this key; any other
  /// error (busy, locked, I/O) is thrown, since it says nothing about the
  /// key.
  static bool opensWith(File file, String key, {bool check = false}) {
    final db = sqlite3.open(file.path, mode: OpenMode.readWrite);
    try {
      applyDatabaseKey(db, key);
      if (check) {
        final result = db.select('PRAGMA quick_check');
        return result.length == 1 && result.first.values.first == 'ok';
      }
      return true;
    } on SqliteException catch (e) {
      if (e.resultCode == _sqliteNotADatabase) return false;
      rethrow;
    } finally {
      db.close();
    }
  }

  /// SQLITE_NOTADB: what a wrong key looks like.
  static const _sqliteNotADatabase = 26;

  static void _deleteWithSideFiles(File file) {
    _deleteSideFiles(file);
    _deleteIfExists(file);
  }

  static void _deleteSideFiles(File file) {
    for (final suffix in const ['-wal', '-shm', '-journal']) {
      _deleteIfExists(File('${file.path}$suffix'));
    }
  }

  static void _deleteIfExists(File file) {
    if (file.existsSync()) file.deleteSync();
  }
}

/// Unlocks [db] with [keyHex] and makes sure it really opened: with a wrong
/// key SQLite only notices on the first read, so this reads once.
void applyDatabaseKey(CommonDatabase db, String keyHex) {
  db.execute('PRAGMA key = ${_keyLiteral(keyHex)}');
  db.select('SELECT count(*) FROM sqlite_master');
}

String _keyLiteral(String keyHex) {
  // Raw key, no key derivation: it is random already. Validated so nothing
  // but hex digits ever ends up in the statement.
  if (!isValidDatabaseKey(keyHex)) {
    throw ArgumentError.value('…', 'keyHex', 'not a 256-bit hex key');
  }
  return "\"x'$keyHex'\"";
}
