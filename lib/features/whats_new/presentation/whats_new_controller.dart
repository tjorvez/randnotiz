import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/platform/app_info.dart';
import '../../intro/presentation/intro_controller.dart';
import '../domain/release_notes.dart';

/// The release notes still to show after an update (empty: nothing to say).
final whatsNewProvider =
    NotifierProvider<WhatsNewController, List<ReleaseNotes>>(
      WhatsNewController.new,
    );

/// Decides whether "Neu in Randnotiz" appears: once per update that brought
/// release notes, never on a fresh installation.
///
/// The version shown last is kept in the preferences. A fresh installation
/// (the introduction appears) records the version it started with and says
/// nothing – the introduction already tells everything. An installation
/// without a recorded version that skips the introduction was set up before
/// the dialog existed and updated from [versionBeforeWhatsNew].
///
/// Nothing is decided until the build's version is known and the
/// introduction has decided; where the platform cannot tell the version
/// (tests without an override), nothing is shown.
class WhatsNewController extends Notifier<List<ReleaseNotes>> {
  /// Preference key: the version name whose notes were shown last (or that
  /// a fresh installation started with).
  static const preferenceKey = 'whatsNewSeenVersion';

  @override
  List<ReleaseNotes> build() {
    final current = AppVersion.tryParse(ref.watch(appVersionProvider).value);
    final intro = ref.watch(introGateProvider);
    if (current == null || intro == IntroGate.checking) return const [];

    final prefs = ref.read(preferencesProvider);
    final stored = prefs.getString(preferenceKey);
    if (intro == IntroGate.showing) {
      // A fresh start: remember where it began. The cache is written at
      // once, so when the introduction ends (and this rebuilds) there is
      // nothing to show.
      if (stored == null) unawaited(prefs.setString(preferenceKey, '$current'));
      return const [];
    }
    return notesSince(AppVersion.tryParse(stored), current);
  }

  /// The dialog was closed: these notes are told.
  Future<void> markSeen() async {
    final current = AppVersion.tryParse(ref.read(appVersionProvider).value);
    state = const [];
    if (current == null) return;
    await ref.read(preferencesProvider).setString(preferenceKey, '$current');
  }
}
