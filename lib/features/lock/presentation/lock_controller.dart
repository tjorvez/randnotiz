import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/platform/secure_window.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/authenticator.dart';

@immutable
class LockState {
  const LockState({
    required this.locked,
    this.authenticating = false,
    this.lastResult,
    this.available = true,
  });

  final bool locked;
  final bool authenticating;
  final AuthResult? lastResult;

  /// False if the device has no screen lock – then the app cannot lock.
  final bool available;

  LockState copyWith({
    bool? locked,
    bool? authenticating,
    AuthResult? Function()? lastResult,
    bool? available,
  }) => LockState(
    locked: locked ?? this.locked,
    authenticating: authenticating ?? this.authenticating,
    lastResult: lastResult != null ? lastResult() : this.lastResult,
    available: available ?? this.available,
  );
}

final lockProvider = NotifierProvider<LockController, LockState>(
  LockController.new,
);

/// Whether the window must block screenshots and screen casting: only while
/// the lock is in effect (see [windowShouldBeSecure]).
final secureWindowWantedProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return windowShouldBeSecure(
    lockEnabled: settings.lockEnabled,
    lockAvailable: ref.watch(lockProvider.select((s) => s.available)),
    lockBypassed: debugLockBypassed,
  );
});

/// Locks the app on start and after it was in the background longer than the
/// configured timeout; unlocks with biometrics or the device credential.
class LockController extends Notifier<LockState> {
  DateTime? _backgroundedAt;
  bool _checkedAvailability = false;

  @override
  LockState build() {
    final enabled =
        ref.read(settingsProvider).lockEnabled && !debugLockBypassed;
    // Starts locked if enabled; availability is verified asynchronously.
    if (!_checkedAvailability) {
      _checkedAvailability = true;
      unawaited(_checkAvailability());
    }
    return LockState(locked: enabled);
  }

  Future<void> _checkAvailability() async {
    final available = await ref.read(authenticatorProvider).isAvailable();
    if (!available) {
      state = state.copyWith(available: false, locked: false);
    } else {
      state = state.copyWith(available: true);
    }
  }

  bool get _enabled =>
      ref.read(settingsProvider).lockEnabled &&
      state.available &&
      !debugLockBypassed;

  /// Called by the lifecycle observer.
  void onLifecycleChanged(AppLifecycleState lifecycle) {
    if (state.authenticating) return; // the system auth dialog pauses us
    switch (lifecycle) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _backgroundedAt ??= ref.read(clockProvider)();
        if (_enabled &&
            ref.read(settingsProvider).lockTimeout == Duration.zero) {
          state = state.copyWith(locked: true, lastResult: () => null);
        }
      case AppLifecycleState.resumed:
        final since = _backgroundedAt;
        _backgroundedAt = null;
        if (since != null && _enabled) {
          final away = ref.read(clockProvider)().difference(since);
          if (away >= ref.read(settingsProvider).lockTimeout) {
            state = state.copyWith(locked: true, lastResult: () => null);
          }
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  /// Locks immediately (e.g. when opened from the home screen widget).
  void lockNow() {
    if (_enabled) state = state.copyWith(locked: true, lastResult: () => null);
  }

  /// Settings changed: disabling the lock unlocks.
  void onSettingsChanged({required bool enabled}) {
    if (!enabled && state.locked) state = state.copyWith(locked: false);
  }

  Future<void> unlock(String reason) async {
    if (state.authenticating) return;
    if (!state.available) {
      state = state.copyWith(locked: false);
      return;
    }
    state = state.copyWith(authenticating: true, lastResult: () => null);
    final result = await ref
        .read(authenticatorProvider)
        .authenticate(reason: reason);
    state = state.copyWith(
      authenticating: false,
      locked: result != AuthResult.success && result != AuthResult.notAvailable,
      lastResult: () => result,
    );
    _backgroundedAt = null;
  }
}
