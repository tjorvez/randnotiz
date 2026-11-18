import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:randnotiz/features/backup/data/backup_key_store.dart';
import 'package:randnotiz/features/backup/data/drive_backup_service.dart';
import 'package:randnotiz/features/backup/data/google_account.dart';
import 'package:randnotiz/features/backup/data/remote/remote_store.dart';
import 'package:randnotiz/features/backup/domain/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'backup_fixtures.dart';
import 'fake_remote_store.dart';

class FakeAccount implements GoogleAccount {
  String? email = 'ich@example.com';
  var signedIn = false;
  var configured = true;

  /// Simulates revoked consent: the server refuses tokens.
  var revoked = false;

  @override
  Future<bool> isConfigured() async => configured;

  @override
  Future<String?> restore(String known) async =>
      signedIn && !revoked && known == email ? email : null;

  @override
  Future<String?> signIn() async {
    signedIn = email != null;
    revoked = false;
    return email;
  }

  @override
  Future<void> signOut() async => signedIn = false;

  @override
  Future<String> accessToken() async =>
      revoked ? throw const RemoteAuthException() : 'token';

  @override
  Future<void> invalidate(String token) async {}
}

class MemoryKeyStore implements BackupKeyStore {
  StoredBackupKey? key;

  @override
  Future<StoredBackupKey?> read() async => key;

  @override
  Future<void> write(StoredBackupKey k) async => key = k;

  @override
  Future<void> delete() async => key = null;
}

/// Lets the account refuse access like the Drive server would.
class AuthCheckingStore implements RemoteStore {
  AuthCheckingStore(this.inner, this.account);

  final FakeRemoteStore inner;
  final FakeAccount account;

  Future<T> _check<T>(Future<T> Function() f) async {
    await account.accessToken();
    return f();
  }

  @override
  Future<List<RemoteFile>> list() => _check(inner.list);

  @override
  Future<Uint8List> read(String id) => _check(() => inner.read(id));

  @override
  Future<RemoteFile> create(String name, Uint8List bytes) =>
      _check(() => inner.create(name, bytes));

  @override
  Future<RemoteFile> update(String id, Uint8List bytes) =>
      _check(() => inner.update(id, bytes));

  @override
  Future<void> delete(String id) => _check(() => inner.delete(id));
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory tmp;
  late FakeRemoteStore server;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('randnotiz_service_');
    server = FakeRemoteStore();
  });

  tearDown(() => tmp.delete(recursive: true));

  /// One installation of the app: device, account, key store, service.
  Future<
    ({
      Device device,
      FakeAccount account,
      MemoryKeyStore keys,
      DriveBackupService service,
    })
  >
  install(String name) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: DriveBackupService.preferenceKeys,
      ),
    );
    final device = Device(Directory(p.join(tmp.path, name)));
    addTearDown(device.db.close);
    final account = FakeAccount();
    final keys = MemoryKeyStore();
    final remote = AuthCheckingStore(server, account);
    final service = DriveBackupService(
      account: account,
      remote: remote,
      keys: keys,
      prefs: prefs,
      writer: device.writer(remote),
      restorer: device.restorer(remote),
      kdf: fastKdf,
      clock: device.clock,
    );
    return (device: device, account: account, keys: keys, service: service);
  }

  test('without OAuth client the feature is off', () async {
    final app = await install('phone');
    app.account.configured = false;
    await app.service.refresh();
    expect(app.service.status.phase, BackupPhase.notConfigured);
  });

  test('set up, back up, restore on a new phone with the password', () async {
    final phone = await install('phone');
    await phone.service.refresh();
    expect(phone.service.status.phase, BackupPhase.signedOut);

    expect(await phone.service.connect(), isTrue);
    expect(phone.service.status.phase, BackupPhase.needsSetup);
    expect(phone.service.status.account, 'ich@example.com');

    final code = await phone.service.setUp('mein Backup-Passwort');
    expect(code, matches(RegExp(r'^([0-9A-Z]{4}-){6}[0-9A-Z]{4}$')));
    expect(phone.service.status.phase, BackupPhase.ready);
    expect(utf8.decode(server.bytesOf('keyring.json')), isNot(contains(code)));

    await phone.device.addGalleryNote('1', 'Erster Eintrag');
    final report = await phone.service.backupNow();
    expect(report!.notes, 1);
    expect(phone.service.status.lastBackupAt, isNotNull);
    expect(phone.service.status.lastNotes, 1);

    // Automatic backups wait a day.
    expect(await phone.service.backupNow(onlyIfDue: true), isNull);

    final newPhone = await install('new');
    await newPhone.service.connect();
    expect(newPhone.service.status.phase, BackupPhase.needsUnlock);
    expect(newPhone.service.status.remoteBackupAt, isNotNull);

    await expectLater(
      newPhone.service.unlock('falsch'),
      throwsA(isA<WrongBackupSecretException>()),
    );
    expect(newPhone.service.status.phase, BackupPhase.needsUnlock);

    await newPhone.service.unlock('mein Backup-Passwort');
    expect(newPhone.service.status.phase, BackupPhase.ready);
    final summary = await newPhone.service.restore();
    expect(summary.added, 1);
    final rows = await newPhone.device.db
        .select(newPhone.device.db.notes)
        .get();
    expect(rows.single.body, 'Erster Eintrag');
  });

  test(
    'the emergency key opens the backup, also after a new password',
    () async {
      final phone = await install('phone');
      await phone.service.connect();
      final code = await phone.service.setUp('altes Passwort');
      await phone.service.changePassword('neues Passwort');

      final second = await install('second');
      await second.service.connect();
      await expectLater(
        second.service.unlock('altes Passwort'),
        throwsA(isA<WrongBackupSecretException>()),
      );
      await second.service.unlock(code.toLowerCase().replaceAll('-', ' '));
      expect(second.service.status.phase, BackupPhase.ready);

      final third = await install('third');
      await third.service.connect();
      await third.service.unlock('neues Passwort');
      expect(third.service.status.phase, BackupPhase.ready);
    },
  );

  test('a renewed emergency key replaces the old one', () async {
    final phone = await install('phone');
    await phone.service.connect();
    final oldCode = await phone.service.setUp('Passwort123');
    final newCode = await phone.service.renewEmergencyKey();
    expect(newCode, isNot(oldCode));

    final other = await install('other');
    await other.service.connect();
    await expectLater(
      other.service.unlock(oldCode),
      throwsA(isA<WrongBackupSecretException>()),
    );
    await other.service.unlock(newCode);
    expect(other.service.status.phase, BackupPhase.ready);
  });

  test('a second device does not overwrite an existing backup', () async {
    final phone = await install('phone');
    await phone.service.connect();
    final other = await install('other');
    await other.service.connect();
    expect(other.service.status.phase, BackupPhase.needsSetup);

    await phone.service.setUp('zuerst da');
    await expectLater(other.service.setUp('später'), throwsStateError);
    expect(other.service.status.phase, BackupPhase.needsUnlock);
    expect(server.names.where((n) => n == 'keyring.json'), hasLength(1));
  });

  test('revoked access signs out on the next backup', () async {
    final phone = await install('phone');
    await phone.service.connect();
    await phone.service.setUp('Passwort123');
    await phone.device.addGalleryNote('1', 'Eintrag');
    phone.account.revoked = true;
    await expectLater(
      phone.service.backupNow(),
      throwsA(
        isA<BackupFailedException>().having(
          (e) => e.problem,
          'problem',
          BackupProblem.auth,
        ),
      ),
    );
    expect(phone.service.status.phase, BackupPhase.signedOut);
    expect(phone.service.status.problem, BackupProblem.auth);

    await phone.service.connect();
    expect(phone.service.status.phase, BackupPhase.ready);
    expect(await phone.service.backupNow(), isNotNull);
  });

  test('the start check asks only about the connected account', () async {
    final phone = await install('phone');
    await phone.service.connect();
    await phone.service.setUp('Passwort123');
    await phone.service.refresh();
    expect(phone.service.status.phase, BackupPhase.ready);
    expect(phone.service.status.problem, isNull);

    // Google no longer knows that account here: connect again.
    phone.account.email = 'andere@example.com';
    await phone.service.refresh();
    expect(phone.service.status.problem, BackupProblem.auth);
  });

  test('disconnecting can delete the backup', () async {
    final phone = await install('phone');
    await phone.service.connect();
    await phone.service.setUp('Passwort123');
    await phone.device.addGalleryNote('1', 'Eintrag');
    await phone.service.backupNow();
    expect(server.files, isNotEmpty);

    await phone.service.disconnect(deleteBackup: true);
    expect(server.files, isEmpty);
    expect(phone.keys.key, isNull);
    expect(phone.service.status.phase, BackupPhase.signedOut);
    expect(phone.service.status.lastBackupAt, isNull);
  });

  // Found on the phone: unlocking on a new device and choosing "Später"
  // made the next automatic backups replace the old snapshots with the
  // nearly empty new device – after two of them the diary backup was gone.
  test('a new device that postpones the restore keeps the backup', () async {
    final phone = await install('phone');
    await phone.service.connect();
    await phone.service.setUp('Passwort123');
    await phone.device.addGalleryNote('1', 'Vom alten Handy');
    await phone.service.backupNow();
    final before = server.names.where((n) => n.startsWith('snapshot-'));

    final newPhone = await install('new');
    await newPhone.service.connect();
    await newPhone.service.unlock('Passwort123');
    expect(newPhone.service.status.restorePending, isTrue);
    await newPhone.device.addGalleryNote('2', 'Vom neuen Handy', seed: 2);

    // Automatic backups wait for the restore.
    for (var i = 0; i < 3; i++) {
      expect(await newPhone.service.backupNow(onlyIfDue: true), isNull);
    }
    expect(server.names.where((n) => n.startsWith('snapshot-')), before);

    // "Jetzt sichern" first takes over the backup, then saves both.
    final report = await newPhone.service.backupNow();
    expect(report!.notes, 2);
    expect(newPhone.service.status.restorePending, isFalse);
    final bodies = await newPhone.device.db
        .select(newPhone.device.db.notes)
        .map((n) => n.body)
        .get();
    expect(bodies, unorderedEquals(['Vom alten Handy', 'Vom neuen Handy']));
  });

  test('restoring ends the pause; an empty backup needs none', () async {
    final phone = await install('phone');
    await phone.service.connect();
    await phone.service.setUp('Passwort123');
    expect(phone.service.status.restorePending, isFalse);

    // Nothing backed up yet: a second device has nothing to take over.
    final second = await install('second');
    await second.service.connect();
    await second.service.unlock('Passwort123');
    expect(second.service.status.restorePending, isFalse);

    await phone.device.addGalleryNote('1', 'Eintrag');
    await phone.service.backupNow();
    final third = await install('third');
    await third.service.connect();
    await third.service.unlock('Passwort123');
    expect(third.service.status.restorePending, isTrue);
    await third.service.restore();
    expect(third.service.status.restorePending, isFalse);
    expect(await third.service.backupNow(onlyIfDue: true), isNotNull);
  });

  test('a backup replaced on another device needs unlocking again', () async {
    final phone = await install('phone');
    await phone.service.connect();
    await phone.service.setUp('Passwort123');

    // Another device deletes everything and starts a new backup.
    final other = await install('other');
    await other.service.connect();
    await other.service.disconnect(deleteBackup: true);
    await other.service.connect();
    await other.service.setUp('anderes Passwort');

    expect(await phone.service.backupNow(), isNull);
    expect(phone.service.status.phase, BackupPhase.needsUnlock);
  });
}
