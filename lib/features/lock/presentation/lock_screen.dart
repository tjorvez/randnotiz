import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/paper.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/authenticator.dart';
import 'lock_controller.dart';

/// Covers the whole app while it is locked. The app content below is not
/// built visible (Offstage) so nothing leaks through.
///
/// A [cover] (the first-start introduction, which shows no user data) takes
/// precedence: the app stays hidden and the lock screen waits – it neither
/// shows nor asks for biometrics until the cover is gone. The lock state
/// itself is untouched, so a locked app is still locked afterwards.
class LockGate extends ConsumerWidget {
  const LockGate({super.key, required this.child, this.cover});

  final Widget child;
  final Widget? cover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(lockProvider.select((s) => s.locked));
    final covered = cover != null;
    return Stack(
      children: [
        Offstage(
          offstage: locked || covered,
          child: TickerMode(enabled: !locked && !covered, child: child),
        ),
        if (covered)
          Positioned.fill(child: cover!)
        else if (locked)
          const Positioned.fill(child: LockScreen()),
      ],
    );
  }
}

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  @override
  void initState() {
    super.initState();
    // Ask right away; the button stays for a second try.
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  void _unlock() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    unawaited(ref.read(lockProvider.notifier).unlock(l10n.lockReason));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(lockProvider);
    final message = switch (state.lastResult) {
      AuthResult.lockedOut => l10n.lockLockedOut,
      AuthResult.failed => l10n.lockFailed,
      _ => null,
    };

    return Material(
      child: PaperBackground(
        child: SafeArea(
          child: Center(
            // Scrolls with a large system font on a small screen.
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 96),
                  const SizedBox(height: 20),
                  Text(
                    l10n.lockTitle,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.lockBody,
                    textAlign: TextAlign.center,
                    style: AppTheme.noteText(
                      context,
                      size: 18,
                    ).copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: state.authenticating ? null : _unlock,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(l10n.lockButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
