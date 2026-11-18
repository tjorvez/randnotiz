import 'dart:async';

import 'package:randnotiz/features/backup/domain/backup_service.dart';

/// The emergency key the fake hands out.
const code = 'K7QM-2XRA-9F0T-ABCD-EFGH-JKMN-PQRS';

/// A [BackupService] that only records calls. [connect] leads to
/// [connectsTo] (an account without backup by default).
class FakeBackupService implements BackupService {
  FakeBackupService(this._status, {this.connectsTo = BackupPhase.needsSetup});

  final BackupPhase connectsTo;

  BackupStatus _status;
  final _changes = StreamController<BackupStatus>.broadcast();
  final calls = <String>[];

  void _set(BackupStatus s) {
    _status = s;
    _changes.add(s);
  }

  @override
  BackupStatus get status => _status;

  @override
  Stream<BackupStatus> get statusChanges => _changes.stream;

  @override
  Future<void> refresh() async => calls.add('refresh');

  @override
  Future<bool> connect() async {
    calls.add('connect');
    _set(BackupStatus(phase: connectsTo, account: 'ich@example.com'));
    return true;
  }

  @override
  Future<String> setUp(String password) async {
    calls.add('setUp:$password');
    _set(
      const BackupStatus(phase: BackupPhase.ready, account: 'ich@example.com'),
    );
    return code;
  }

  @override
  Future<void> unlock(String secret) async {
    calls.add('unlock:$secret');
    if (secret != 'richtiges Passwort') {
      throw const WrongBackupSecretException();
    }
    _set(
      const BackupStatus(phase: BackupPhase.ready, account: 'ich@example.com'),
    );
  }

  @override
  Future<BackupReport?> backupNow({bool onlyIfDue = false}) async {
    calls.add('backupNow');
    return BackupReport(notes: 1, photos: 1, finishedAt: DateTime(2026));
  }

  @override
  Future<RestoreSummary> restore() async {
    calls.add('restore');
    return RestoreSummary(
      added: 3,
      updated: 0,
      unchanged: 0,
      backupAt: DateTime(2026),
    );
  }

  @override
  Future<void> changePassword(String newPassword) async {}

  @override
  Future<String> renewEmergencyKey() async => code;

  @override
  Future<void> disconnect({bool deleteBackup = false}) async {
    calls.add('disconnect:$deleteBackup');
    _set(const BackupStatus(phase: BackupPhase.signedOut));
  }
}
