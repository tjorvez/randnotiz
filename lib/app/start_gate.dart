import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/paper.dart';
import '../features/intro/presentation/intro_controller.dart';
import '../features/intro/presentation/intro_screen.dart';
import '../features/lock/presentation/lock_screen.dart';
import 'router.dart';

/// Wraps the app (MaterialApp.builder): on the very first start the
/// introduction covers everything, afterwards the lock works as always.
///
/// The introduction shows no user data, so it may come before unlocking;
/// it never replaces the lock – once it is gone, a locked app shows the lock
/// screen (see [LockGate.cover]).
class StartGate extends ConsumerWidget {
  const StartGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover = switch (ref.watch(introGateProvider)) {
      // A blank page for the few milliseconds of the check, so neither the
      // library nor the lock screen flashes up first.
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
    return LockGate(cover: cover, child: child);
  }
}
