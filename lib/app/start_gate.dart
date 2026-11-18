import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/paper.dart';
import '../features/backup/presentation/lost_notes_prompt.dart';
import '../features/intro/presentation/intro_controller.dart';
import '../features/intro/presentation/intro_screen.dart';
import '../features/lock/presentation/lock_controller.dart';
import '../features/lock/presentation/lock_screen.dart';
import '../features/whats_new/presentation/whats_new_dialog.dart';
import 'router.dart';
import 'start_splash.dart';

/// Wraps the app (MaterialApp.builder): on the very first start the
/// introduction covers everything, afterwards the lock works as always.
///
/// The introduction shows no user data, so it may come before unlocking;
/// it never replaces the lock – once it is gone, a locked app shows the lock
/// screen (see [LockGate.cover]).
///
/// After an update, "Neu in Randnotiz" appears once nothing covers the app
/// any more – never over the start screen, the introduction or the lock.
class StartGate extends ConsumerWidget {
  const StartGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover = switch (ref.watch(introGateProvider)) {
      // A blank page for the few milliseconds of the check, so neither the
      // journal nor the lock screen flashes up first.
      IntroGate.checking => const Material(
        child: PaperBackground(child: SizedBox.expand()),
      ),
      IntroGate.showing => IntroScreen(
        onAction: (action) {
          unawaited(ref.read(introGateProvider.notifier).finish());
          startAfterIntro(ref.read(routerProvider), action);
        },
      ),
      IntroGate.done => null,
    };
    final locked = ref.watch(lockProvider.select((s) => s.locked));
    final covered = cover != null || locked || StartSplash.coversOf(context);
    final router = ref.watch(routerProvider);
    return LostNotesPrompt(
      covered: covered,
      navigatorKey: router.routerDelegate.navigatorKey,
      onRestore: () => router.push('/settings/backup?restore=1&from=lost'),
      // The news can wait until the notes are back.
      child: WhatsNewPrompt(
        covered: covered || ref.watch(lostNotesProvider),
        navigatorKey: router.routerDelegate.navigatorKey,
        child: LockGate(cover: cover, child: child),
      ),
    );
  }
}
