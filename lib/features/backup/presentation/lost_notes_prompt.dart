import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Whether the notes could not be opened at a start and a new, empty
/// database took their place (DatabaseEncryption: the key was gone) – and
/// the person has not yet decided what to do about it.
///
/// While this is true, nothing may act on the empty database as if it were
/// the diary: the start-up clean-up keeps every photo copy (they belong to
/// the lost notes, a restore needs them less than the person may) and
/// automatic backups pause, so the good backup is not replaced by an empty
/// one (only two snapshots are kept). Kept in the preferences, so it lasts
/// until [resolve]: a restore, or "continue without backup".
final lostNotesProvider = NotifierProvider<LostNotesController, bool>(
  LostNotesController.new,
);

class LostNotesController extends Notifier<bool> {
  static const preferenceKey = 'database.replacedUnreadable';

  @override
  bool build() =>
      ref.watch(preferencesProvider).getBool(preferenceKey) ?? false;

  /// Restored, or the person goes on without: back to normal.
  Future<void> resolve() async {
    if (!state) return;
    state = false;
    await ref.read(preferencesProvider).remove(preferenceKey);
  }
}

/// What the person chose in the [LostNotesDialog].
enum LostNotesChoice { restore, later, startOver }

/// Tells at every start, as soon as nothing covers the app ([covered]:
/// start screen, introduction, lock), that the notes could not be opened –
/// until the person restores the backup or decides to go on without.
class LostNotesPrompt extends ConsumerStatefulWidget {
  const LostNotesPrompt({
    super.key,
    required this.covered,
    required this.navigatorKey,
    required this.onRestore,
    required this.child,
  });

  final bool covered;
  final GlobalKey<NavigatorState> navigatorKey;

  /// Opens the backup, ready to restore.
  final VoidCallback onRestore;
  final Widget child;

  @override
  ConsumerState<LostNotesPrompt> createState() => _LostNotesPromptState();
}

class _LostNotesPromptState extends ConsumerState<LostNotesPrompt> {
  /// At most once per process.
  bool _asked = false;

  void _maybeShow(bool lost) {
    if (_asked || widget.covered || !lost) return;
    _asked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = widget.navigatorKey.currentContext;
      if (!mounted || context == null) {
        _asked = false;
        return;
      }
      final choice = await showDialog<LostNotesChoice>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LostNotesDialog(),
      );
      if (!mounted) return;
      switch (choice) {
        case LostNotesChoice.restore:
          widget.onRestore();
        case LostNotesChoice.startOver:
          await ref.read(lostNotesProvider.notifier).resolve();
        case LostNotesChoice.later || null:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeShow(ref.watch(lostNotesProvider));
    return widget.child;
  }
}

/// "Deine Notizen ließen sich nicht öffnen" – pops a [LostNotesChoice].
class LostNotesDialog extends StatelessWidget {
  const LostNotesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      // Title and text scroll together: long with a large system font.
      scrollable: true,
      icon: const Icon(Icons.lock_reset_outlined),
      title: Text(l10n.lostNotesTitle),
      content: Text('${l10n.lostNotesBody}\n\n${l10n.lostNotesMeanwhile}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, LostNotesChoice.startOver),
          child: Text(l10n.lostNotesStartOver),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, LostNotesChoice.later),
          child: Text(l10n.lostNotesLater),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, LostNotesChoice.restore),
          child: Text(l10n.lostNotesRestore),
        ),
      ],
    );
  }
}

/// Stands in for the app while the notes cannot be opened right now
/// (DatabaseUnavailable): nothing is lost, [onRetry] tries again.
class DatabaseUnavailableScreen extends StatefulWidget {
  const DatabaseUnavailableScreen({super.key, required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  State<DatabaseUnavailableScreen> createState() =>
      _DatabaseUnavailableScreenState();
}

class _DatabaseUnavailableScreenState extends State<DatabaseUnavailableScreen> {
  bool _trying = false;

  Future<void> _retry() async {
    setState(() => _trying = true);
    try {
      await widget.onRetry();
    } finally {
      if (mounted) setState(() => _trying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_clock_outlined,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.databaseUnavailableTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.databaseUnavailableBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _trying ? null : _retry,
                  child: Text(l10n.databaseUnavailableRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
