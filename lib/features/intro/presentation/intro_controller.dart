import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// Whether the first-start introduction covers the app.
enum IntroGate {
  /// Deciding (the flag is not set: are there notes already?).
  checking,

  /// First start with an empty diary: show the introduction.
  showing,

  /// Seen before, or not needed – the app shows normally.
  done,
}

/// What the person chose on the last page of the introduction.
enum IntroAction {
  /// Open the backup screen to set up a new backup.
  setUpBackup,

  /// Open the backup screen with the restore path first.
  restoreBackup,

  /// Straight to the library ("Später", "Überspringen").
  later,
}

final introGateProvider = NotifierProvider<IntroController, IntroGate>(
  IntroController.new,
);

/// Shows the introduction once: on the first start, and only while the
/// diary is still empty. Installations that already hold notes (updates)
/// set the flag silently. Decided once per process at start-up – the
/// introduction never appears later in a session (e.g. after unlocking or
/// after deleting the last note).
class IntroController extends Notifier<IntroGate> {
  /// Preference key; true once the introduction was finished or skipped.
  static const preferenceKey = 'introSeen';

  @override
  IntroGate build() {
    if (ref.read(preferencesProvider).getBool(preferenceKey) ?? false) {
      return IntroGate.done;
    }
    unawaited(_decide());
    return IntroGate.checking;
  }

  Future<void> _decide() async {
    int notes;
    try {
      notes = await ref.read(noteRepositoryProvider).count();
    } on Object catch (e) {
      // Without an answer, do not cover the app; ask again next start.
      debugPrint('Intro check failed: $e');
      if (ref.mounted) state = IntroGate.done;
      return;
    }
    if (!ref.mounted) return;
    if (notes > 0) {
      await _remember();
      if (ref.mounted) state = IntroGate.done;
    } else {
      state = IntroGate.showing;
    }
  }

  /// Any action on the introduction (including "Überspringen") ends it for
  /// good.
  Future<void> finish() async {
    state = IntroGate.done;
    await _remember();
  }

  Future<void> _remember() =>
      ref.read(preferencesProvider).setBool(preferenceKey, true);
}
