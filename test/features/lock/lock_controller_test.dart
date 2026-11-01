import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/features/lock/domain/authenticator.dart';
import 'package:randnotiz/features/lock/presentation/lock_controller.dart';
import 'package:randnotiz/features/settings/domain/app_settings.dart';
import 'package:randnotiz/features/settings/presentation/settings_controller.dart';

class FakeAuthenticator implements Authenticator {
  bool available = true;
  AuthResult next = AuthResult.success;
  int calls = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<AuthResult> authenticate({required String reason}) async {
    calls++;
    return next;
  }
}

class FixedSettings extends SettingsController {
  FixedSettings(this.initial);
  final AppSettings initial;

  @override
  AppSettings build() => initial;
}

void main() {
  late FakeAuthenticator auth;
  late DateTime now;

  ProviderContainer container({
    bool enabled = true,
    Duration timeout = const Duration(minutes: 1),
  }) {
    final c = ProviderContainer(
      overrides: [
        authenticatorProvider.overrideWithValue(auth),
        clockProvider.overrideWithValue(() => now),
        settingsProvider.overrideWith(
          () => FixedSettings(
            AppSettings(lockEnabled: enabled, lockTimeout: timeout),
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() {
    auth = FakeAuthenticator();
    now = DateTime(2026, 10, 31, 12);
  });

  test('starts locked and unlocks with successful authentication', () async {
    final c = container();
    expect(c.read(lockProvider).locked, isTrue);
    await settle();
    await c.read(lockProvider.notifier).unlock('test');
    expect(c.read(lockProvider).locked, isFalse);
    expect(auth.calls, 1);
  });

  test('cancelled authentication keeps the app locked', () async {
    auth.next = AuthResult.canceled;
    final c = container();
    await settle();
    await c.read(lockProvider.notifier).unlock('test');
    expect(c.read(lockProvider).locked, isTrue);
    expect(c.read(lockProvider).lastResult, AuthResult.canceled);
  });

  test('disabled lock never locks', () async {
    final c = container(enabled: false);
    expect(c.read(lockProvider).locked, isFalse);
    c.read(lockProvider.notifier).onLifecycleChanged(AppLifecycleState.paused);
    now = now.add(const Duration(hours: 1));
    c.read(lockProvider.notifier).onLifecycleChanged(AppLifecycleState.resumed);
    expect(c.read(lockProvider).locked, isFalse);
  });

  test('re-locks only after the configured time in the background', () async {
    final c = container();
    await settle();
    await c.read(lockProvider.notifier).unlock('test');
    final lock = c.read(lockProvider.notifier);

    lock.onLifecycleChanged(AppLifecycleState.paused);
    now = now.add(const Duration(seconds: 30));
    lock.onLifecycleChanged(AppLifecycleState.resumed);
    expect(c.read(lockProvider).locked, isFalse, reason: '30 s < 1 min');

    lock.onLifecycleChanged(AppLifecycleState.paused);
    now = now.add(const Duration(minutes: 2));
    lock.onLifecycleChanged(AppLifecycleState.resumed);
    expect(c.read(lockProvider).locked, isTrue, reason: '2 min >= 1 min');
  });

  test('timeout "Sofort" locks as soon as the app is hidden', () async {
    final c = container(timeout: Duration.zero);
    await settle();
    await c.read(lockProvider.notifier).unlock('test');
    c.read(lockProvider.notifier).onLifecycleChanged(AppLifecycleState.hidden);
    expect(c.read(lockProvider).locked, isTrue);
  });

  test('opening from the widget always asks again', () async {
    final c = container(timeout: const Duration(minutes: 15));
    await settle();
    await c.read(lockProvider.notifier).unlock('test');
    c.read(lockProvider.notifier).lockNow();
    expect(c.read(lockProvider).locked, isTrue);
  });

  test('device without screen lock cannot be locked', () async {
    auth.available = false;
    final c = container();
    c.read(lockProvider);
    await settle();
    expect(c.read(lockProvider).locked, isFalse);
    expect(c.read(lockProvider).available, isFalse);
  });
}
