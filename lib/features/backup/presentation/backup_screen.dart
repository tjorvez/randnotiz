import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../core/platform/app_info.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/backup_service.dart';
import 'backup_controller.dart';

/// Minimum length of the backup password.
const backupPasswordMinLength = 10;

/// Settings › Sicherung: connect, set up or unlock, back up, restore.
///
/// With [restoreFirst] (from "Ich habe schon eine Sicherung" in the
/// introduction) the screen leads with the way back to an existing backup:
/// connect, then the usual unlock form of [BackupPhase.needsUnlock].
/// [onRestored] runs after a successful restore (e.g. to show the entries).
///
/// In the test app "Randnotiz Dev" ([devInstallProvider]) a banner says
/// that the backup folder is shared with the real app, and setting up,
/// unlocking (both turn on automatic backups) and deleting the backup ask
/// once more.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key, this.restoreFirst = false, this.onRestored});

  final bool restoreFirst;
  final VoidCallback? onRestored;

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  /// An action started here is running (sign-in, key derivation …).
  var _busy = false;

  BackupService get _service => ref.read(backupServiceProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_service.refresh());
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } on BackupFailedException catch (e) {
      _snack(problemText(l10n, e.problem));
    } on WrongBackupSecretException {
      _snack(l10n.backupUnlockWrong);
    } on Object catch (e) {
      debugPrint('Backup action failed: $e');
      _snack(l10n.backupProblemUnknown);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _connect() => _run(() async {
    final l10n = AppLocalizations.of(context);
    try {
      await _service.connect();
    } on BackupFailedException {
      rethrow;
    } on Object catch (e) {
      debugPrint('Google sign-in failed: $e');
      _snack(l10n.backupConnectFailed);
    }
  });

  /// Test app only: one more question before touching the backup folder it
  /// shares with the real app. Always true in the real app.
  Future<bool> _confirmDev({
    required String body,
    required String confirm,
  }) async {
    if (!ref.read(devInstallProvider)) return true;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.science_outlined),
        title: Text(l10n.backupDevConfirmTitle),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirm),
          ),
        ],
      ),
    );
    return (ok ?? false) && mounted;
  }

  Future<void> _setUp() async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirmDev(
      body: l10n.backupDevConfirmAuto,
      confirm: l10n.backupDevConfirmContinue,
    )) {
      return;
    }
    if (!mounted) return;
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _NewPasswordDialog(title: l10n.backupPasswordTitle),
    );
    if (password == null || !mounted) return;
    String? code;
    await _run(() async => code = await _service.setUp(password));
    if (code == null || !mounted) return;
    await _showEmergencyKey(code!);
    unawaited(_backup(quiet: true));
  }

  Future<void> _showEmergencyKey(String code) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => EmergencyKeyScreen(code: code),
    ),
  );

  Future<void> _unlock(String secret) async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirmDev(
      body: l10n.backupDevConfirmAuto,
      confirm: l10n.backupDevConfirmContinue,
    )) {
      return;
    }
    var unlocked = false;
    await _run(() async {
      await _service.unlock(secret);
      unlocked = true;
    });
    if (!unlocked || !mounted) return;
    final restore = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupRestoreAskTitle),
        content: Text(l10n.backupRestoreAskBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.backupRestoreLater),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.backupRestore),
          ),
        ],
      ),
    );
    if (restore ?? false) await _restore(ask: false);
  }

  Future<void> _backup({bool quiet = false}) => _run(() async {
    final l10n = AppLocalizations.of(context);
    final report = await _service.backupNow();
    if (quiet || report == null) return;
    _snack(report.unchanged ? l10n.backupUnchanged : l10n.backupDone);
  });

  Future<void> _restore({bool ask = true}) async {
    final l10n = AppLocalizations.of(context);
    if (ask) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.backupRestoreAskTitle),
          content: Text(l10n.backupRestoreAskBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.backupRestore),
            ),
          ],
        ),
      );
      if (!(ok ?? false) || !mounted) return;
    }
    var restored = false;
    await _run(() async {
      final summary = await _service.restore();
      restored = true;
      _snack(
        [
          l10n.backupRestoreDone(summary.added),
          if (summary.updated > 0) l10n.backupRestoreUpdated(summary.updated),
        ].join(' · '),
      );
    });
    if (restored && mounted) widget.onRestored?.call();
  }

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context);
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _NewPasswordDialog(title: l10n.backupPasswordNewTitle),
    );
    if (password == null || !mounted) return;
    await _run(() async {
      await _service.changePassword(password);
      _snack(l10n.backupPasswordChanged);
    });
  }

  Future<void> _renewEmergencyKey() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupRenewEmergency),
        content: Text(l10n.backupRenewEmergencyAsk),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.backupRenewEmergencyButton),
          ),
        ],
      ),
    );
    if (!(ok ?? false) || !mounted) return;
    String? code;
    await _run(() async => code = await _service.renewEmergencyKey());
    if (code != null && mounted) await _showEmergencyKey(code!);
  }

  Future<void> _disconnect() async {
    final deleteBackup = await showDialog<bool>(
      context: context,
      builder: (_) => const _DisconnectDialog(),
    );
    if (deleteBackup == null || !mounted) return;
    if (deleteBackup) {
      final l10n = AppLocalizations.of(context);
      if (!await _confirmDev(
        body: l10n.backupDevConfirmDelete,
        confirm: l10n.backupDevConfirmDeleteButton,
      )) {
        return;
      }
    }
    await _run(() => _service.disconnect(deleteBackup: deleteBackup));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(backupStatusProvider);
    final theme = Theme.of(context);
    final working = _busy || status.running;
    final restoreFirst =
        widget.restoreFirst &&
        (status.phase == BackupPhase.signedOut ||
            status.phase == BackupPhase.needsSetup);

    final problem = status.problem;
    final children = <Widget>[
      if (working)
        LinearProgressIndicator(value: status.running ? status.progress : null)
      else
        const SizedBox(height: 4),
      if (ref.watch(devInstallProvider)) const _DevBanner(),
      if (restoreFirst)
        _RestoreGuide(
          text: status.phase == BackupPhase.signedOut
              ? l10n.backupRestoreGuide
              : l10n.backupRestoreNoBackup,
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(l10n.backupIntro, style: theme.textTheme.bodyMedium),
      ),
      if (status.account != null && status.phase != BackupPhase.signedOut)
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: Text(l10n.backupAccount),
          subtitle: Text(status.account!),
        ),
      if (problem != null)
        _ProblemCard(
          text: problemText(l10n, problem),
          action: problem == BackupProblem.auth
              ? TextButton(
                  onPressed: working ? null : _connect,
                  child: Text(l10n.backupReconnect),
                )
              : null,
        ),
      ...switch (status.phase) {
        BackupPhase.notConfigured => [
          ListTile(title: Text(l10n.settingsBackupUnavailable)),
        ],
        BackupPhase.signedOut => [
          _ActionButton(
            icon: Icons.login,
            label: l10n.backupConnect,
            onPressed: working ? null : _connect,
          ),
        ],
        BackupPhase.needsSetup => [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(l10n.backupSetupIntro),
          ),
          _ActionButton(
            icon: Icons.password,
            label: l10n.backupSetupButton,
            onPressed: working ? null : _setUp,
          ),
        ],
        BackupPhase.needsUnlock => [
          _UnlockForm(
            foundAt: status.remoteBackupAt,
            busy: working,
            onUnlock: _unlock,
          ),
        ],
        BackupPhase.ready => [
          ListTile(
            leading: const Icon(Icons.cloud_done_outlined),
            title: Text(
              status.running
                  ? l10n.settingsBackupRunning
                  : status.restorePending
                  ? l10n.backupStatusPending
                  : status.lastBackupAt == null
                  ? l10n.backupStatusNever
                  : l10n.backupStatusLast(
                      Fmt.fullDateTime(status.lastBackupAt!),
                    ),
            ),
            subtitle: Text(
              [
                if (status.lastNotes != null && status.lastPhotos != null)
                  l10n.backupStatusCounts(
                    status.lastNotes!,
                    status.lastPhotos!,
                  ),
                status.restorePending
                    ? l10n.backupStatusPendingHint
                    : l10n.backupStatusAuto,
              ].join('\n'),
            ),
          ),
          _ActionButton(
            icon: Icons.backup_outlined,
            label: l10n.backupNow,
            onPressed: working ? null : _backup,
          ),
          const SizedBox(height: 8),
          ListTile(
            enabled: !working,
            leading: const Icon(Icons.settings_backup_restore),
            title: Text(l10n.backupRestore),
            onTap: _restore,
          ),
          ListTile(
            enabled: !working,
            leading: const Icon(Icons.password),
            title: Text(l10n.backupChangePassword),
            onTap: _changePassword,
          ),
          ListTile(
            enabled: !working,
            leading: const Icon(Icons.key_outlined),
            title: Text(l10n.backupRenewEmergency),
            onTap: _renewEmergencyKey,
          ),
        ],
      },
      if (status.phase != BackupPhase.signedOut &&
          status.phase != BackupPhase.notConfigured)
        ListTile(
          enabled: !working,
          leading: const Icon(Icons.logout),
          title: Text(l10n.backupDisconnect),
          onTap: _disconnect,
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.backupPrivacyNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(children: children),
    );
  }
}

String problemText(AppLocalizations l10n, BackupProblem problem) =>
    switch (problem) {
      BackupProblem.offline => l10n.backupProblemOffline,
      BackupProblem.auth => l10n.backupProblemAuth,
      BackupProblem.quota => l10n.backupProblemQuota,
      BackupProblem.damaged => l10n.backupProblemDamaged,
      BackupProblem.unknown => l10n.backupProblemUnknown,
    };

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    ),
  );
}

/// Test app only: the Drive folder belongs to the Cloud project, not to the
/// package – "Randnotiz Dev" sees and changes the real app's backup.
class _DevBanner extends StatelessWidget {
  const _DevBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.science_outlined, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context).backupDevBanner,
                style: TextStyle(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Ich habe schon eine Sicherung": the way back comes first.
class _RestoreGuide extends StatelessWidget {
  const _RestoreGuide({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.settings_backup_restore,
              color: scheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  const _ProblemCard({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: scheme.onErrorContainer)),
            if (action != null)
              Align(alignment: Alignment.centerRight, child: action)
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _UnlockForm extends StatefulWidget {
  const _UnlockForm({
    required this.foundAt,
    required this.busy,
    required this.onUnlock,
  });

  final DateTime? foundAt;
  final bool busy;
  final Future<void> Function(String secret) onUnlock;

  @override
  State<_UnlockForm> createState() => _UnlockFormState();
}

class _UnlockFormState extends State<_UnlockForm> {
  final _controller = TextEditingController();
  var _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final secret = _controller.text;
    if (secret.trim().isEmpty || widget.busy) return;
    unawaited(widget.onUnlock(secret));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.backupUnlockIntro),
          if (widget.foundAt != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.backupUnlockFoundAt(Fmt.fullDateTime(widget.foundAt!)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.visiblePassword,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l10n.backupUnlockLabel,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: widget.busy ? null : _submit,
            icon: const Icon(Icons.lock_open),
            label: Text(l10n.backupUnlockButton),
          ),
        ],
      ),
    );
  }
}

/// Asks for a new backup password (twice). Pops with the password.
class _NewPasswordDialog extends StatefulWidget {
  const _NewPasswordDialog({required this.title});

  final String title;

  @override
  State<_NewPasswordDialog> createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends State<_NewPasswordDialog> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  var _obscure = true;
  var _tried = false;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  String? _error(AppLocalizations l10n) {
    if (_first.text.length < backupPasswordMinLength) {
      return l10n.backupPasswordTooShort(backupPasswordMinLength);
    }
    if (_first.text != _second.text) return l10n.backupPasswordMismatch;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _tried ? _error(l10n) : null;
    InputDecoration decoration(String label, {String? errorText}) =>
        InputDecoration(
          labelText: label,
          errorText: errorText,
          errorMaxLines: 2,
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        );
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.backupPasswordHint),
            const SizedBox(height: 12),
            TextField(
              controller: _first,
              autofocus: true,
              obscureText: _obscure,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (_) => setState(() {}),
              decoration: decoration(l10n.backupPasswordLabel),
            ),
            TextField(
              controller: _second,
              obscureText: _obscure,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (_) => setState(() {}),
              decoration: decoration(
                l10n.backupPasswordRepeat,
                errorText: error,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_error(l10n) == null) {
              Navigator.pop(context, _first.text);
            } else {
              setState(() => _tried = true);
            }
          },
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}

class _DisconnectDialog extends StatefulWidget {
  const _DisconnectDialog();

  @override
  State<_DisconnectDialog> createState() => _DisconnectDialogState();
}

class _DisconnectDialogState extends State<_DisconnectDialog> {
  var _delete = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.backupDisconnectTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.backupDisconnectBody),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _delete,
            onChanged: (v) => setState(() => _delete = v ?? false),
            title: Text(l10n.backupDisconnectDelete),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _delete),
          child: Text(l10n.backupDisconnect),
        ),
      ],
    );
  }
}

/// Shows the emergency key once. Leaving needs the confirmation that it
/// was written down.
class EmergencyKeyScreen extends StatefulWidget {
  const EmergencyKeyScreen({super.key, required this.code});

  final String code;

  @override
  State<EmergencyKeyScreen> createState() => _EmergencyKeyScreenState();
}

class _EmergencyKeyScreenState extends State<EmergencyKeyScreen> {
  var _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return PopScope(
      canPop: _confirmed,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l10n.backupEmergencyTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.backupEmergencyIntro),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  widget.code,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 1.5,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: widget.code));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.backupEmergencyCopied)),
                  );
                },
                icon: const Icon(Icons.copy),
                label: Text(l10n.backupEmergencyCopy),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _confirmed,
              onChanged: (v) => setState(() => _confirmed = v ?? false),
              title: Text(l10n.backupEmergencyConfirm),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _confirmed ? () => Navigator.pop(context) : null,
              child: Text(l10n.backupEmergencyDone),
            ),
          ],
        ),
      ),
    );
  }
}
