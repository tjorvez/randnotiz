import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/backup_service.dart';
import 'backup_key_store.dart';
import 'backup_restorer.dart';
import 'backup_writer.dart';
import 'crypto/backup_cipher.dart';
import 'crypto/key_ring.dart';
import 'google_account.dart';
import 'remote/remote_store.dart';

/// [BackupService] on the hidden app folder of the user's Google Drive.
///
/// Layout of the folder: `keyring.json` (wrapped data keys, no secret in the
/// clear), `snapshot-<time>.bin` (the encrypted diary, the newest two are
/// kept) and `b-<hmac>` (encrypted photos, named by an HMAC of their
/// content). All actions run one after the other.
class DriveBackupService implements BackupService {
  DriveBackupService({
    required this.account,
    required this.remote,
    required this.keys,
    required this.prefs,
    required this.writer,
    required this.restorer,
    this.kdf = KdfParams.standard,
    this.interval = const Duration(days: 1),
    this.afterRestore,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _status = _loadStatus();
  }

  final GoogleAccount account;
  final RemoteStore remote;
  final BackupKeyStore keys;
  final SharedPreferencesWithCache prefs;
  final BackupWriter writer;
  final BackupRestorer restorer;
  final KdfParams kdf;

  /// Automatic backups run at most this often.
  final Duration interval;

  /// E.g. refresh the home-screen widget.
  final Future<void> Function()? afterRestore;
  final DateTime Function() _clock;

  static const _kConnected = 'backup.connected';
  static const _kAccount = 'backup.account';
  static const _kLastAt = 'backup.lastAt';
  static const _kLastNotes = 'backup.lastNotes';
  static const _kLastPhotos = 'backup.lastPhotos';
  static const _kMarkSnapshot = 'backup.markSnapshot';
  static const _kMarkHash = 'backup.markHash';
  static const _kRestorePending = 'backup.restorePending';

  /// Preference keys (for the allow-list in main.dart).
  static const preferenceKeys = {
    _kConnected,
    _kAccount,
    _kLastAt,
    _kLastNotes,
    _kLastPhotos,
    _kMarkSnapshot,
    _kMarkHash,
    _kRestorePending,
  };

  final _changes = StreamController<BackupStatus>.broadcast();
  late BackupStatus _status;
  Future<void> _queue = Future.value();

  @override
  BackupStatus get status => _status;

  @override
  Stream<BackupStatus> get statusChanges => _changes.stream;

  void _emit(BackupStatus s) {
    _status = s;
    _changes.add(s);
  }

  /// Runs [action] after all earlier ones.
  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  BackupStatus _loadStatus() {
    final at = prefs.getInt(_kLastAt);
    return BackupStatus(
      // Optimistic until refresh() has asked Google and Drive.
      phase: prefs.getBool(_kConnected) ?? false
          ? BackupPhase.ready
          : BackupPhase.signedOut,
      account: prefs.getString(_kAccount),
      lastBackupAt: at == null ? null : DateTime.fromMillisecondsSinceEpoch(at),
      lastNotes: prefs.getInt(_kLastNotes),
      lastPhotos: prefs.getInt(_kLastPhotos),
      restorePending: prefs.getBool(_kRestorePending) ?? false,
    );
  }

  Future<void> _setRestorePending(bool pending) async {
    if (pending) {
      await prefs.setBool(_kRestorePending, true);
    } else {
      await prefs.remove(_kRestorePending);
    }
  }

  BackupStatus _signedOut({BackupProblem? problem}) => BackupStatus(
    phase: BackupPhase.signedOut,
    lastBackupAt: _status.lastBackupAt,
    lastNotes: _status.lastNotes,
    lastPhotos: _status.lastPhotos,
    problem: problem,
    restorePending: _status.restorePending,
  );

  static BackupProblem _problemOf(Object e) => switch (e) {
    RemoteUnavailableException() => BackupProblem.offline,
    RemoteAuthException() => BackupProblem.auth,
    RemoteQuotaException() => BackupProblem.quota,
    BackupIntegrityException() || FormatException() => BackupProblem.damaged,
    _ => BackupProblem.unknown,
  };

  @override
  Future<void> refresh() => _serial(() async {
    if (!await account.isConfigured()) {
      _emit(BackupStatus.off);
      return;
    }
    if (!(prefs.getBool(_kConnected) ?? false)) {
      _emit(_signedOut());
      return;
    }
    final known = prefs.getString(_kAccount);
    final String? email;
    try {
      email = known == null ? null : await account.restore(known);
    } on Object catch (e) {
      debugPrint('Google account check failed: $e');
      _emit(_status.copyWith(problem: () => BackupProblem.offline));
      return;
    }
    if (email == null) {
      // Permission probably gone (revoked, signed out) – or Google could
      // not be asked silently. Offer to connect again; a backup that is
      // refused by the server signs out for good.
      _emit(_status.copyWith(problem: () => BackupProblem.auth));
      return;
    }
    await prefs.setString(_kAccount, email);
    try {
      await _readServer(email);
    } on Object catch (e) {
      debugPrint('Backup refresh failed: $e');
      _emit(_status.copyWith(account: email, problem: () => _problemOf(e)));
    }
  });

  /// Sets the phase from what is on the server.
  Future<({KeyRing ring, RemoteFile file})?> _readServer(String email) async {
    final files = await remote.list();
    final ring = await _keyRing(files);
    final snapshots = BackupLayout.snapshots(files);
    final remoteAt = snapshots.isEmpty
        ? null
        : _snapshotTime(snapshots.first.name);
    if (ring == null) {
      await _setRestorePending(false);
      _emit(
        BackupStatus(
          phase: BackupPhase.needsSetup,
          account: email,
          lastBackupAt: _status.lastBackupAt,
        ),
      );
      return null;
    }
    final local = await keys.read();
    _emit(
      _status.copyWith(
        phase: local?.keyId == ring.ring.keyId
            ? BackupPhase.ready
            : BackupPhase.needsUnlock,
        account: email,
        remoteBackupAt: remoteAt,
        problem: () => null,
      ),
    );
    return ring;
  }

  static DateTime? _snapshotTime(String name) {
    final digits = name.substring(
      BackupLayout.snapshotPrefix.length,
      name.length - BackupLayout.snapshotSuffix.length,
    );
    final ms = int.tryParse(digits);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// The key ring on the server; with several (should not happen), the
  /// newest one.
  Future<({KeyRing ring, RemoteFile file})?> _keyRing(
    List<RemoteFile> files,
  ) async {
    final rings = files.where((f) => f.name == KeyRing.fileName).toList()
      ..sort(
        (a, b) => (b.modifiedAt ?? DateTime(0)).compareTo(
          a.modifiedAt ?? DateTime(0),
        ),
      );
    if (rings.isEmpty) return null;
    final bytes = await remote.read(rings.first.id);
    return (ring: KeyRing.decode(utf8.decode(bytes)), file: rings.first);
  }

  @override
  Future<bool> connect() async {
    final email = await account.signIn();
    if (email == null) return false;
    await prefs.setBool(_kConnected, true);
    await prefs.setString(_kAccount, email);
    _emit(_status.copyWith(account: email, problem: () => null));
    await _serial(() async {
      try {
        await _readServer(email);
      } on Object catch (e) {
        _emit(_status.copyWith(problem: () => _problemOf(e)));
        throw BackupFailedException(_problemOf(e));
      }
    });
    return true;
  }

  @override
  Future<String> setUp(String password) => _serial(() async {
    final email = _status.account ?? '';
    final existing = await _keyRing(await remote.list());
    if (existing != null) {
      // Created meanwhile on another device: open that one instead.
      await _readServer(email);
      throw StateError('A backup already exists');
    }
    final created = await KeyRing.create(password, kdf: kdf);
    await remote.create(KeyRing.fileName, utf8.encode(created.ring.encode()));
    await keys.write((keyId: created.ring.keyId, dataKey: created.dataKey));
    await _clearMark();
    await _setRestorePending(false);
    _emit(
      _status.copyWith(
        phase: BackupPhase.ready,
        problem: () => null,
        restorePending: false,
      ),
    );
    return created.recoveryCode.formatted;
  });

  @override
  Future<void> unlock(String passwordOrEmergencyKey) => _serial(() async {
    final files = await remote.list();
    final ring = await _keyRing(files);
    if (ring == null) throw StateError('No backup on the server');
    try {
      final dataKey = await ring.ring.unlock(passwordOrEmergencyKey);
      await keys.write((keyId: ring.ring.keyId, dataKey: dataKey));
    } on WrongSecretException {
      throw const WrongBackupSecretException();
    }
    await _clearMark();
    // The backup holds entries this device may not have: until they are
    // taken over, a backup from here would replace them.
    final pending = BackupLayout.snapshots(files).isNotEmpty;
    await _setRestorePending(pending);
    _emit(
      _status.copyWith(
        phase: BackupPhase.ready,
        problem: () => null,
        restorePending: pending,
      ),
    );
  });

  Future<({KeyRing ring, RemoteFile file, StoredBackupKey key})>
  _unlockedRing() async {
    final ring = await _keyRing(await remote.list());
    final key = await keys.read();
    if (ring == null || key == null || key.keyId != ring.ring.keyId) {
      await _readServer(_status.account ?? '');
      throw StateError('Backup not unlocked');
    }
    return (ring: ring.ring, file: ring.file, key: key);
  }

  @override
  Future<void> changePassword(String newPassword) => _serial(() async {
    final r = await _unlockedRing();
    final ring = await r.ring.withNewPassword(r.key.dataKey, newPassword);
    await remote.update(r.file.id, utf8.encode(ring.encode()));
  });

  @override
  Future<String> renewEmergencyKey() => _serial(() async {
    final r = await _unlockedRing();
    final renewed = await r.ring.withNewRecoveryCode(r.key.dataKey);
    await remote.update(r.file.id, utf8.encode(renewed.ring.encode()));
    return renewed.recoveryCode.formatted;
  });

  @override
  Future<BackupReport?> backupNow({bool onlyIfDue = false}) => _serial(
    () async {
      if (_status.phase != BackupPhase.ready) return null;
      if (_status.restorePending) {
        if (onlyIfDue) return null;
        await _restore();
      }
      final last = _status.lastBackupAt;
      if (onlyIfDue &&
          last != null &&
          _clock().difference(last) < interval &&
          _status.problem == null) {
        return null;
      }
      _emit(_status.copyWith(running: true, progress: () => 0));
      try {
        final key = await keys.read();
        final ring = await _keyRing(await remote.list());
        if (key == null || ring == null || ring.ring.keyId != key.keyId) {
          // Backup removed or replaced on another device.
          await _readServer(_status.account ?? '');
          return null;
        }
        final cipher = await BackupCipher.create(key.dataKey, keyId: key.keyId);
        final result = await writer.run(
          cipher,
          previous: _mark(),
          onProgress: (done, total) => _emit(
            _status.copyWith(progress: () => total == 0 ? null : done / total),
          ),
        );
        await prefs.setString(_kMarkSnapshot, result.mark.snapshotName);
        await prefs.setString(_kMarkHash, result.mark.contentHash);
        await prefs.setInt(_kLastAt, result.finishedAt.millisecondsSinceEpoch);
        await prefs.setInt(_kLastNotes, result.notes);
        await prefs.setInt(_kLastPhotos, result.photos);
        _emit(
          _status.copyWith(
            running: false,
            progress: () => null,
            problem: () => null,
            lastBackupAt: result.finishedAt,
            lastNotes: result.notes,
            lastPhotos: result.photos,
            remoteBackupAt: _snapshotTime(result.mark.snapshotName),
          ),
        );
        return BackupReport(
          notes: result.notes,
          photos: result.photos,
          finishedAt: result.finishedAt,
          unchanged: result.unchanged,
        );
      } on Object catch (e) {
        debugPrint('Backup failed: $e');
        final problem = _problemOf(e);
        if (problem == BackupProblem.auth) {
          await prefs.setBool(_kConnected, false);
          _emit(_signedOut(problem: problem));
        } else {
          _emit(
            _status.copyWith(
              running: false,
              progress: () => null,
              problem: () => problem,
            ),
          );
        }
        throw BackupFailedException(problem);
      } finally {
        if (_status.running) {
          _emit(_status.copyWith(running: false, progress: () => null));
        }
      }
    },
  );

  @override
  Future<RestoreSummary> restore() => _serial(_restore);

  Future<RestoreSummary> _restore() async {
    _emit(_status.copyWith(running: true, progress: () => 0));
    try {
      final key = await keys.read();
      if (key == null) throw StateError('Backup not unlocked');
      final cipher = await BackupCipher.create(key.dataKey, keyId: key.keyId);
      final report = await restorer.restore(
        cipher,
        onProgress: (done, total) => _emit(
          _status.copyWith(progress: () => total == 0 ? null : done / total),
        ),
      );
      if (report == null) {
        throw const BackupFailedException(BackupProblem.damaged);
      }
      // The diary changed: the next backup must not be skipped.
      await _clearMark();
      await _setRestorePending(false);
      await afterRestore?.call();
      _emit(
        _status.copyWith(
          running: false,
          progress: () => null,
          problem: () => null,
          restorePending: false,
        ),
      );
      return RestoreSummary(
        added: report.added,
        updated: report.updated,
        unchanged: report.unchanged,
        backupAt: report.snapshotAt,
      );
    } on BackupFailedException {
      rethrow;
    } on Object catch (e) {
      debugPrint('Restore failed: $e');
      _emit(
        _status.copyWith(
          running: false,
          progress: () => null,
          problem: () => _problemOf(e),
        ),
      );
      throw BackupFailedException(_problemOf(e));
    } finally {
      if (_status.running) {
        _emit(_status.copyWith(running: false, progress: () => null));
      }
    }
  }

  @override
  Future<void> disconnect({bool deleteBackup = false}) => _serial(() async {
    if (deleteBackup) {
      for (final f in await remote.list()) {
        await remote.delete(f.id);
      }
    }
    await keys.delete();
    await account.signOut();
    for (final k in preferenceKeys) {
      await prefs.remove(k);
    }
    _emit(const BackupStatus(phase: BackupPhase.signedOut));
  });

  BackupMark? _mark() {
    final name = prefs.getString(_kMarkSnapshot);
    final hash = prefs.getString(_kMarkHash);
    return name == null || hash == null
        ? null
        : (snapshotName: name, contentHash: hash);
  }

  Future<void> _clearMark() async {
    await prefs.remove(_kMarkSnapshot);
    await prefs.remove(_kMarkHash);
  }
}
