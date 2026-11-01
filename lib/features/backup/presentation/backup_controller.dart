import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/backup_service.dart';

/// The backup status for the UI, plus the automatic daily backup.
final backupStatusProvider = NotifierProvider<BackupController, BackupStatus>(
  BackupController.new,
);

class BackupController extends Notifier<BackupStatus> {
  /// Asking Google and Drive on every return to the app would be wasteful.
  static const refreshInterval = Duration(hours: 1);

  DateTime? _lastRefresh;
  Future<void>? _auto;

  @override
  BackupStatus build() {
    final service = ref.watch(backupServiceProvider);
    final sub = service.statusChanges.listen((s) {
      if (ref.mounted) state = s;
    });
    ref.onDispose(sub.cancel);
    return service.status;
  }

  /// At start-up and when the app comes back: checks the account now and
  /// then, and backs up if the last backup is older than a day. Failures
  /// only show in the status (settings).
  Future<void> autoBackup() => _auto ??= _runAuto().whenComplete(() {
    _auto = null;
  });

  Future<void> _runAuto() async {
    final service = ref.read(backupServiceProvider);
    final now = ref.read(clockProvider)();
    try {
      if (_lastRefresh == null ||
          now.difference(_lastRefresh!) > refreshInterval) {
        _lastRefresh = now;
        await service.refresh();
      }
      await service.backupNow(onlyIfDue: true);
    } on BackupFailedException catch (e) {
      debugPrint('Automatic backup failed: ${e.problem.name}');
    } on Object catch (e) {
      debugPrint('Automatic backup failed: $e');
    }
  }
}
