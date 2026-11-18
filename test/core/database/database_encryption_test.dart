import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/core/database/database_encryption.dart';
import 'package:randnotiz/core/database/database_key_store.dart';
import 'package:sqlite3/sqlite3.dart';

class _MemoryKeyStore implements DatabaseKeyStore {
  _MemoryKeyStore([this.key]);

  String? key;
  int writes = 0;
  bool failReads = false;
  bool failWrites = false;

  @override
  Future<String?> read() async {
    if (failReads) throw StateError('Keystore unavailable');
    return key;
  }

  @override
  Future<void> write(String keyHex) async {
    if (failWrites) throw StateError('Keystore unavailable');
    writes++;
    key = keyHex;
  }
}

final _keyA = 'a1' * 32;
final _keyB = 'b2' * 32;

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('randnotiz_db_');
    file = File('${dir.path}/randnotiz.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  bool isPlain(File f) =>
      String.fromCharCodes(f.readAsBytesSync().take(15))
          .startsWith('SQLite format 3');

  void writePlainDatabase({bool wal = false}) {
    final db = sqlite3.open(file.path);
    if (wal) db.execute('PRAGMA journal_mode = WAL');
    db.execute('CREATE TABLE notes(body TEXT)');
    db.execute("INSERT INTO notes VALUES ('Mein geheimer Eintrag')");
    db.close();
  }

  List<String> readNotes(String key) {
    final db = sqlite3.open(file.path);
    try {
      applyDatabaseKey(db, key);
      return [
        for (final row in db.select('SELECT body FROM notes'))
          row['body'] as String,
      ];
    } finally {
      db.close();
    }
  }

  DatabaseEncryption encryption(_MemoryKeyStore keys) =>
      DatabaseEncryption(keys: keys, newKey: () => _keyA);

  /// The key of a normal, encrypted start.
  String keyOf(PreparedDatabase prepared) {
    expect(prepared, isA<OpenEncrypted>());
    prepared as OpenEncrypted;
    expect(prepared.replacedUnreadable, isFalse);
    return prepared.key;
  }

  Future<String> prepareKey(_MemoryKeyStore keys) async =>
      keyOf(await encryption(keys).prepare(file));

  test('a fresh install gets a new key and no file yet', () async {
    final keys = _MemoryKeyStore();
    expect(await prepareKey(keys), _keyA);
    expect(keys.key, _keyA);
    expect(file.existsSync(), isFalse);
  });

  test('an existing key is kept', () async {
    final keys = _MemoryKeyStore(_keyB);
    expect(await prepareKey(keys), _keyB);
    expect(keys.writes, 0);
  });

  test('an unencrypted database is encrypted in place', () async {
    writePlainDatabase();
    final keys = _MemoryKeyStore();

    final key = await prepareKey(keys);

    expect(key, _keyA);
    expect(keys.key, _keyA);
    expect(isPlain(file), isFalse);
    expect(file.readAsBytesSync().length, greaterThan(0));
    expect(
      String.fromCharCodes(file.readAsBytesSync()),
      isNot(contains('geheimer')),
    );
    expect(readNotes(key), ['Mein geheimer Eintrag']);
    expect(File('${file.path}.encrypting').existsSync(), isFalse);
  });

  test('a database in WAL mode keeps all its rows and its mode', () async {
    writePlainDatabase(wal: true);
    final key = await prepareKey(_MemoryKeyStore());

    expect(isPlain(file), isFalse);
    expect(readNotes(key), ['Mein geheimer Eintrag']);
    final db = sqlite3.open(file.path);
    applyDatabaseKey(db, key);
    expect(db.select('PRAGMA journal_mode').first.values.first, 'wal');
    db.close();
  });

  test('without the key the file cannot be read', () async {
    writePlainDatabase();
    await encryption(_MemoryKeyStore()).prepare(file);

    final db = sqlite3.open(file.path);
    expect(
      () => db.select('SELECT count(*) FROM sqlite_master'),
      throwsA(isA<SqliteException>()),
    );
    db.close();
    expect(() => readNotes(_keyB), throwsA(isA<SqliteException>()));
  });

  test('a second start leaves the encrypted database alone', () async {
    writePlainDatabase();
    final keys = _MemoryKeyStore();
    final key = await prepareKey(keys);
    final bytes = file.readAsBytesSync();

    expect(await prepareKey(keys), key);
    expect(file.readAsBytesSync(), bytes);
    expect(keys.writes, 1);
  });

  test('an interrupted earlier attempt is cleaned up and redone', () async {
    writePlainDatabase();
    File('${file.path}.encrypting').writeAsStringSync('half-written');
    final keys = _MemoryKeyStore(_keyB); // saved before it was interrupted

    final key = await prepareKey(keys);

    expect(key, _keyB);
    expect(readNotes(_keyB), ['Mein geheimer Eintrag']);
    expect(File('${file.path}.encrypting').existsSync(), isFalse);
  });

  test('an unreadable database is moved aside, not deleted, and the start '
      'says so', () async {
    writePlainDatabase();
    await prepareKey(_MemoryKeyStore());
    // The Keystore was reset: the key is gone.
    final keys = _MemoryKeyStore();

    final prepared = await DatabaseEncryption(
      keys: keys,
      newKey: () => _keyB,
    ).prepare(file);

    expect(prepared, isA<OpenEncrypted>());
    prepared as OpenEncrypted;
    expect(prepared.key, _keyB);
    expect(prepared.replacedUnreadable, isTrue);
    expect(file.existsSync(), isFalse);
    final aside = dir.listSync().whereType<File>().where(
      (f) => f.path.contains('.unreadable-'),
    );
    expect(aside, hasLength(1));
    // Still the old notes, for whoever finds the key again.
    final db = sqlite3.open(aside.single.path);
    applyDatabaseKey(db, _keyA);
    expect(db.select('SELECT body FROM notes'), hasLength(1));
    db.close();
  });

  test('a wrong key is a lost key too', () async {
    writePlainDatabase();
    await prepareKey(_MemoryKeyStore());
    final prepared = await DatabaseEncryption(
      keys: _MemoryKeyStore(_keyB),
      newKey: () => _keyB,
    ).prepare(file);
    expect((prepared as OpenEncrypted).replacedUnreadable, isTrue);
  });

  group('when something goes wrong the notes stay as they are', () {
    test(
      'Keystore unreadable, encrypted database: unavailable, untouched',
      () async {
        writePlainDatabase();
        await prepareKey(_MemoryKeyStore());
        final bytes = file.readAsBytesSync();
        final keys = _MemoryKeyStore(_keyA)..failReads = true;

        expect(
          await encryption(keys).prepare(file),
          isA<DatabaseUnavailable>(),
        );
        expect(file.readAsBytesSync(), bytes);
        expect(keys.writes, 0);
      },
    );

    test(
      'Keystore unreadable, unencrypted database: opened as before',
      () async {
        writePlainDatabase();
        final keys = _MemoryKeyStore()..failReads = true;

        expect(await encryption(keys).prepare(file), isA<OpenUnencrypted>());
        expect(isPlain(file), isTrue);
        expect(keys.writes, 0);

        // Next start, the Keystore is back: now it is encrypted.
        keys.failReads = false;
        final key = await prepareKey(keys);
        expect(readNotes(key), ['Mein geheimer Eintrag']);
      },
    );

    test(
      'Keystore unreadable on a fresh install: unencrypted for now',
      () async {
        final keys = _MemoryKeyStore()..failReads = true;
        expect(await encryption(keys).prepare(file), isA<OpenUnencrypted>());
        expect(keys.writes, 0);
      },
    );

    test('a key that cannot be saved: unencrypted for now', () async {
      writePlainDatabase();
      final keys = _MemoryKeyStore()..failWrites = true;
      expect(await encryption(keys).prepare(file), isA<OpenUnencrypted>());
      expect(isPlain(file), isTrue);

      final fresh = File('${dir.path}/fresh.sqlite');
      expect(await encryption(keys).prepare(fresh), isA<OpenUnencrypted>());
    });

    test('encrypting fails (no room for the copy): opened as before, '
        'next start again', () async {
      writePlainDatabase();
      final keys = _MemoryKeyStore();
      // A read-only folder: the encrypted copy cannot be written.
      Process.runSync('chmod', ['555', dir.path]);
      addTearDown(() => Process.runSync('chmod', ['755', dir.path]));

      expect(await encryption(keys).prepare(file), isA<OpenUnencrypted>());
      expect(isPlain(file), isTrue);
      final db = sqlite3.open(file.path, mode: OpenMode.readOnly);
      expect(db.select('SELECT body FROM notes'), hasLength(1));
      db.close();

      Process.runSync('chmod', ['755', dir.path]);
      final key = await prepareKey(keys);
      expect(key, _keyA, reason: 'the key saved the first time');
      expect(readNotes(key), ['Mein geheimer Eintrag']);
    });

    test('a locked database is not taken for a lost one', () async {
      writePlainDatabase();
      final keys = _MemoryKeyStore();
      final key = await prepareKey(keys);
      final holder = sqlite3.open(file.path);
      applyDatabaseKey(holder, key);
      holder.execute('BEGIN EXCLUSIVE');
      addTearDown(holder.close);

      expect(await encryption(keys).prepare(file), isA<DatabaseUnavailable>());
      expect(file.existsSync(), isTrue);
      expect(
        dir.listSync().where((f) => f.path.contains('.unreadable-')),
        isEmpty,
      );

      holder.execute('ROLLBACK');
      expect(await prepareKey(keys), key);
    });
  });

  test('an empty file is treated as no database', () async {
    file.writeAsBytesSync(const []);
    expect(await prepareKey(_MemoryKeyStore()), _keyA);
    expect(file.existsSync(), isFalse);
  });

  test('drift opens the encrypted database with the key', () async {
    final key = await prepareKey(_MemoryKeyStore());
    final db = AppDatabase(
      NativeDatabase(file, setup: (raw) => applyDatabaseKey(raw, key)),
    );
    await db.customStatement('SELECT 1');
    expect(await db.select(db.notes).get(), isEmpty);
    await db.close();
    expect(isPlain(file), isFalse);
    expect(DatabaseEncryption.opensWith(file, key, check: true), isTrue);
  });

  test('only 256-bit hex keys reach a PRAGMA', () {
    final db = sqlite3.openInMemory();
    expect(
      () => applyDatabaseKey(db, "x'; DROP TABLE notes; --"),
      throwsArgumentError,
    );
    db.close();
    expect(isValidDatabaseKey(newDatabaseKey()), isTrue);
  });
}
