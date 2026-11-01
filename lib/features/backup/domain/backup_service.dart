/// Phase 3: end-to-end encrypted backup of the diary (notes, Stimmungen,
/// collections, downscaled photos) to the hidden app folder of the user's
/// own Google Drive (scope `drive.appdata`).
///
/// The local database always stays the source of truth; a backup is a copy.
/// Google only ever sees ciphertext, sizes and times. The data key is
/// protected by the backup password and by an emergency key the user writes
/// down – without one of them nobody (not even the app) can read the backup.
/// Google Cloud setup: README.md, "Google Drive".
library;

enum BackupPhase {
  /// No OAuth client configured in this build – the feature is off.
  notConfigured,

  /// Not connected to a Google account.
  signedOut,

  /// Connected; the account has no backup yet – choose a password.
  needsSetup,

  /// Connected; the account has a backup this device cannot open yet –
  /// enter the password or the emergency key.
  needsUnlock,

  /// Connected and unlocked: backups run.
  ready,
}

/// Why the last action failed.
enum BackupProblem {
  /// No connection or the server did not answer – will be retried.
  offline,

  /// Google refused access (consent revoked, signed out elsewhere) –
  /// connect again.
  auth,

  /// The Drive storage is full.
  quota,

  /// The backup on the server is damaged or was made with another key.
  damaged,
  unknown,
}

class BackupStatus {
  const BackupStatus({
    required this.phase,
    this.account,
    this.lastBackupAt,
    this.lastNotes,
    this.lastPhotos,
    this.remoteBackupAt,
    this.running = false,
    this.progress,
    this.problem,
    this.restorePending = false,
  });

  static const off = BackupStatus(phase: BackupPhase.notConfigured);

  final BackupPhase phase;

  /// E-mail address of the connected Google account.
  final String? account;

  /// Last successful backup from this device.
  final DateTime? lastBackupAt;
  final int? lastNotes;
  final int? lastPhotos;

  /// Time of the newest backup on the server (known before unlocking:
  /// from the file name).
  final DateTime? remoteBackupAt;

  /// A backup or restore is in progress.
  final bool running;

  /// 0…1 while [running], if known.
  final double? progress;

  /// Set if the last backup/restore failed.
  final BackupProblem? problem;

  /// This device unlocked an existing backup but has not taken it over
  /// yet. Until then automatic backups pause – they would replace the
  /// backup with this device's (possibly empty) diary.
  final bool restorePending;

  BackupStatus copyWith({
    BackupPhase? phase,
    String? account,
    DateTime? lastBackupAt,
    int? lastNotes,
    int? lastPhotos,
    DateTime? remoteBackupAt,
    bool? running,
    double? Function()? progress,
    BackupProblem? Function()? problem,
    bool? restorePending,
  }) => BackupStatus(
    phase: phase ?? this.phase,
    account: account ?? this.account,
    lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    lastNotes: lastNotes ?? this.lastNotes,
    lastPhotos: lastPhotos ?? this.lastPhotos,
    remoteBackupAt: remoteBackupAt ?? this.remoteBackupAt,
    running: running ?? this.running,
    progress: progress == null ? this.progress : progress(),
    problem: problem == null ? this.problem : problem(),
    restorePending: restorePending ?? this.restorePending,
  );
}

class BackupReport {
  const BackupReport({
    required this.notes,
    required this.photos,
    required this.finishedAt,
    this.unchanged = false,
  });

  final int notes;
  final int photos;
  final DateTime finishedAt;

  /// Nothing had changed since the previous backup.
  final bool unchanged;
}

class RestoreSummary {
  const RestoreSummary({
    required this.added,
    required this.updated,
    required this.unchanged,
    required this.backupAt,
  });

  final int added;
  final int updated;
  final int unchanged;
  final DateTime backupAt;
}

/// Thrown by [BackupService.unlock] for a wrong password or emergency key.
class WrongBackupSecretException implements Exception {
  const WrongBackupSecretException();
}

/// Thrown by actions that fail for one of the [BackupProblem] reasons.
class BackupFailedException implements Exception {
  const BackupFailedException(this.problem);

  final BackupProblem problem;

  @override
  String toString() => 'BackupFailedException(${problem.name})';
}

abstract interface class BackupService {
  BackupStatus get status;
  Stream<BackupStatus> get statusChanges;

  /// Re-reads the account and the server state without user interaction.
  Future<void> refresh();

  /// Interactive Google sign-in with the `drive.appdata` permission.
  /// Returns false if the user cancelled.
  Future<bool> connect();

  /// Creates the key ring for a new backup. Returns the emergency key in
  /// its display form – it is shown once and never stored.
  Future<String> setUp(String password);

  /// Opens the existing backup with the password or the emergency key.
  /// Throws [WrongBackupSecretException].
  Future<void> unlock(String passwordOrEmergencyKey);

  Future<void> changePassword(String newPassword);

  /// A new emergency key; the old one stops working.
  Future<String> renewEmergencyKey();

  /// Backs up now. With [onlyIfDue], only if the last backup is older than
  /// a day (automatic backups); returns null if nothing was done. While
  /// [BackupStatus.restorePending], automatic backups are skipped and a
  /// manual one first merges the backup into this device ([restore]).
  Future<BackupReport?> backupNow({bool onlyIfDue = false});

  /// Merges the newest backup into this device's diary.
  Future<RestoreSummary> restore();

  /// Signs out and forgets the key on this device. With [deleteBackup],
  /// first removes the backup from Drive.
  Future<void> disconnect({bool deleteBackup = false});
}

/// Used in builds without an OAuth client. The app works fully without it.
class DisabledBackupService implements BackupService {
  const DisabledBackupService();

  @override
  BackupStatus get status => BackupStatus.off;

  @override
  Stream<BackupStatus> get statusChanges => const Stream.empty();

  @override
  Future<void> refresh() async {}

  @override
  Future<bool> connect() async => false;

  @override
  Future<String> setUp(String password) => _off();

  @override
  Future<void> unlock(String passwordOrEmergencyKey) => _off();

  @override
  Future<void> changePassword(String newPassword) => _off();

  @override
  Future<String> renewEmergencyKey() => _off();

  @override
  Future<BackupReport?> backupNow({bool onlyIfDue = false}) async => null;

  @override
  Future<RestoreSummary> restore() => _off();

  @override
  Future<void> disconnect({bool deleteBackup = false}) async {}

  static Future<T> _off<T>() =>
      Future.error(UnsupportedError('Backup not configured'));
}
