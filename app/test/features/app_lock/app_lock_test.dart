import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/features/app_lock/data/pin_lock_repository.dart';
import 'package:vehicle_khata/features/app_lock/domain/lock_policy.dart';
import 'package:vehicle_khata/features/app_lock/domain/pin_hasher.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';

import '../../helpers/memory_secret_store.dart';
import '../../helpers/pump_app.dart';

/// Preferences + secrets as they would be after the user enabled a PIN.
({Map<String, Object> prefs, MemorySecretStore secrets}) _lockedStorage(
  String pin, {
  bool biometric = false,
}) {
  final salt = PinHasher.newSalt();
  final secrets = MemorySecretStore()
    ..values[PinLockRepository.saltKey] = salt
    ..values[PinLockRepository.hashKey] = PinHasher.hash(pin, salt);
  return (
    prefs: {'lock.enabled': true, 'lock.biometric': biometric},
    secrets: secrets,
  );
}

Future<ProviderContainer> _controllerContainer({
  Map<String, Object> prefs = const {},
  MemorySecretStore? secrets,
  DateTime Function()? clock,
  BiometricAuth? biometric,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),
      secretStoreProvider.overrideWithValue(secrets ?? MemorySecretStore()),
      if (clock != null) clockProvider.overrideWithValue(clock),
      biometricAuthProvider.overrideWithValue(biometric ?? FakeBiometric()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('AppLockController', () {
    test('starts disabled and unlocked on a fresh install', () async {
      final c = await _controllerContainer();
      final s = c.read(appLockProvider);
      expect(s.enabled, isFalse);
      expect(s.locked, isFalse);
      expect(s.timeout, LockTimeout.seconds30);
    });

    test('enable stores only a salted hash, never the PIN', () async {
      final secrets = MemorySecretStore();
      final c = await _controllerContainer(secrets: secrets);
      await c.read(appLockProvider.notifier).enable('1234');

      final s = c.read(appLockProvider);
      expect(s.enabled, isTrue);
      expect(s.locked, isFalse, reason: 'current session stays unlocked');
      expect(secrets.values.values.any((v) => v.contains('1234')), isFalse);
      expect(secrets.values[PinLockRepository.hashKey], hasLength(64));
    });

    test('a new process starts locked once a PIN exists', () async {
      final storage = _lockedStorage('1234');
      final c = await _controllerContainer(
        prefs: storage.prefs,
        secrets: storage.secrets,
      );
      expect(c.read(appLockProvider).locked, isTrue);
    });

    test('wrong PIN counts attempts; correct PIN unlocks and resets', () async {
      final storage = _lockedStorage('1234');
      final c = await _controllerContainer(
        prefs: storage.prefs,
        secrets: storage.secrets,
      );
      final lock = c.read(appLockProvider.notifier);

      expect(await lock.unlockWithPin('0000'), UnlockResult.wrongPin);
      expect(c.read(appLockProvider).failedAttempts, 1);
      expect(c.read(appLockProvider).locked, isTrue);

      expect(await lock.unlockWithPin('1234'), UnlockResult.success);
      expect(c.read(appLockProvider).locked, isFalse);
      expect(c.read(appLockProvider).failedAttempts, 0);
    });

    test('5 wrong PINs block further attempts for 30 seconds', () async {
      var now = DateTime(2026, 10, 22, 12);
      final storage = _lockedStorage('1234');
      final c = await _controllerContainer(
        prefs: storage.prefs,
        secrets: storage.secrets,
        clock: () => now,
      );
      final lock = c.read(appLockProvider.notifier);

      for (var i = 0; i < 4; i++) {
        expect(await lock.unlockWithPin('0000'), UnlockResult.wrongPin);
      }
      expect(await lock.unlockWithPin('0000'), UnlockResult.blocked);

      // Even the right PIN is refused while blocked.
      expect(await lock.unlockWithPin('1234'), UnlockResult.blocked);
      expect(c.read(appLockProvider).locked, isTrue);

      now = now.add(const Duration(seconds: 31));
      expect(await lock.unlockWithPin('1234'), UnlockResult.success);
    });

    test('locks after the background timeout, not before', () async {
      var now = DateTime(2026, 10, 22, 12);
      final c = await _controllerContainer(clock: () => now);
      final lock = c.read(appLockProvider.notifier);
      await lock.enable('1234');

      lock.onBackgrounded();
      now = now.add(const Duration(seconds: 10));
      lock.onResumed();
      expect(c.read(appLockProvider).locked, isFalse);

      lock.onBackgrounded();
      now = now.add(const Duration(seconds: 31));
      lock.onResumed();
      expect(c.read(appLockProvider).locked, isTrue);
    });

    test('immediate timeout locks on every resume', () async {
      final now = DateTime(2026, 10, 22, 12);
      final c = await _controllerContainer(clock: () => now);
      final lock = c.read(appLockProvider.notifier);
      await lock.enable('1234');
      await lock.setTimeout(LockTimeout.immediately);

      lock
        ..onBackgrounded()
        ..onResumed();
      expect(c.read(appLockProvider).locked, isTrue);
    });

    test('background events do nothing while the lock is off', () async {
      var now = DateTime(2026, 10, 22, 12);
      final c = await _controllerContainer(clock: () => now);
      final lock = c.read(appLockProvider.notifier)..onBackgrounded();
      now = now.add(const Duration(hours: 1));
      lock.onResumed();
      expect(c.read(appLockProvider).locked, isFalse);
    });

    test('changePin and disable require the current PIN', () async {
      final c = await _controllerContainer();
      final lock = c.read(appLockProvider.notifier);
      await lock.enable('1234');

      expect(await lock.changePin(currentPin: '9999', newPin: '5555'), isFalse);
      expect(await lock.changePin(currentPin: '1234', newPin: '5555'), isTrue);
      expect(await lock.verifyPin('5555'), isTrue);
      expect(await lock.verifyPin('1234'), isFalse);

      expect(await lock.disable('1234'), isFalse);
      expect(c.read(appLockProvider).enabled, isTrue);
      expect(await lock.disable('5555'), isTrue);
      expect(c.read(appLockProvider).enabled, isFalse);
      expect(c.read(appLockProvider).biometricEnabled, isFalse);
    });

    test('biometric unlock works only when enabled', () async {
      final biometric = FakeBiometric();
      final storage = _lockedStorage('1234');
      final c = await _controllerContainer(
        prefs: storage.prefs,
        secrets: storage.secrets,
        biometric: biometric,
      );
      final lock = c.read(appLockProvider.notifier);

      expect(await lock.unlockWithBiometric('why'), isFalse);
      expect(biometric.prompts, 0);

      await lock.setBiometric(enabled: true);
      biometric.succeeds = false;
      expect(await lock.unlockWithBiometric('why'), isFalse);
      expect(c.read(appLockProvider).locked, isTrue);

      biometric.succeeds = true;
      expect(await lock.unlockWithBiometric('why'), isTrue);
      expect(c.read(appLockProvider).locked, isFalse);
    });

    test('settings survive a restart', () async {
      final secrets = MemorySecretStore();
      final c1 = await _controllerContainer(secrets: secrets);
      final lock = c1.read(appLockProvider.notifier);
      await lock.enable('1234');
      await lock.setTimeout(LockTimeout.minutes5);
      await lock.setBiometric(enabled: true);

      final prefs = await SharedPreferences.getInstance();
      final c2 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secretStoreProvider.overrideWithValue(secrets),
        ],
      );
      addTearDown(c2.dispose);
      final s = c2.read(appLockProvider);
      expect(s.enabled, isTrue);
      expect(s.timeout, LockTimeout.minutes5);
      expect(s.biometricEnabled, isTrue);
    });
  });

  group('lock screen', () {
    testWidgets('app opens on the lock screen and the right PIN unlocks', (
      tester,
    ) async {
      final storage = _lockedStorage('1234');
      await pumpApp(tester, prefs: storage.prefs, secrets: storage.secrets);
      expect(find.text('Enter your PIN'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await enterPin(tester, '1234');
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Enter your PIN'), findsNothing);
    });

    testWidgets('a wrong PIN shows an error and stays locked', (tester) async {
      final storage = _lockedStorage('1234');
      await pumpApp(tester, prefs: storage.prefs, secrets: storage.secrets);
      await enterPin(tester, '0000');
      expect(find.text('Wrong PIN'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('too many wrong PINs show the lockout message', (tester) async {
      final storage = _lockedStorage('1234');
      await pumpApp(tester, prefs: storage.prefs, secrets: storage.secrets);
      for (var i = 0; i < 5; i++) {
        await enterPin(tester, '0000');
      }
      expect(
        find.textContaining('Too many attempts. Try again in'),
        findsOneWidget,
      );
    });

    testWidgets('biometric prompt appears automatically and unlocks', (
      tester,
    ) async {
      final storage = _lockedStorage('1234', biometric: true);
      final biometric = FakeBiometric();
      await pumpApp(
        tester,
        prefs: storage.prefs,
        secrets: storage.secrets,
        biometric: biometric,
      );
      expect(biometric.prompts, 1);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('failed biometric falls back to the PIN pad', (tester) async {
      final storage = _lockedStorage('1234', biometric: true);
      await pumpApp(
        tester,
        prefs: storage.prefs,
        secrets: storage.secrets,
        biometric: FakeBiometric(succeeds: false),
      );
      expect(find.text('Enter your PIN'), findsOneWidget);
      await enterPin(tester, '1234');
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('locking mid-session sends the user to the lock screen', (
      tester,
    ) async {
      final storage = _lockedStorage('1234');
      final app = await pumpApp(
        tester,
        prefs: storage.prefs,
        secrets: storage.secrets,
      );
      await enterPin(tester, '1234');
      expect(find.byType(NavigationBar), findsOneWidget);

      await app.container
          .read(appLockProvider.notifier)
          .setTimeout(LockTimeout.immediately);
      app.container.read(appLockProvider.notifier)
        ..onBackgrounded()
        ..onResumed();
      await tester.pumpAndSettle();
      expect(find.text('Enter your PIN'), findsOneWidget);
      // Let drift's stream-cleanup timer (from the disposed Home) fire.
      await tester.pump(const Duration(milliseconds: 10));
    });
  });

  group('settings', () {
    testWidgets('enable app lock with a confirmed PIN', (tester) async {
      final app = await pumpApp(tester, location: '/more/settings');
      await tester.scrollUntilVisible(find.text('App lock'), 200);
      await tester.tap(find.text('App lock'));
      await tester.pumpAndSettle();
      expect(find.text('Set a 4-digit PIN'), findsOneWidget);

      await enterPin(tester, '4321');
      expect(find.text('Confirm your PIN'), findsOneWidget);
      await enterPin(tester, '4321');

      expect(app.container.read(appLockProvider).enabled, isTrue);
      expect(find.text('PIN lock is on'), findsOneWidget);
    });

    testWidgets('mismatched confirmation restarts with an error', (
      tester,
    ) async {
      final app = await pumpApp(tester, location: '/pin/enable');
      await enterPin(tester, '1111');
      await enterPin(tester, '2222');
      expect(find.text("PINs don't match. Try again."), findsOneWidget);
      expect(find.text('Set a 4-digit PIN'), findsOneWidget);
      expect(app.container.read(appLockProvider).enabled, isFalse);
    });

    testWidgets('turning the lock off needs the current PIN', (tester) async {
      final storage = _lockedStorage('1234');
      final app = await pumpApp(
        tester,
        prefs: storage.prefs,
        secrets: storage.secrets,
      );
      await enterPin(tester, '1234'); // unlock the app first
      expect(app.container.read(appLockProvider).locked, isFalse);

      unawaited(app.container.read(routerProvider).push('/pin/disable'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your current PIN'), findsOneWidget);

      await enterPin(tester, '0000');
      expect(find.text('Wrong PIN'), findsOneWidget);
      expect(app.container.read(appLockProvider).enabled, isTrue);

      await enterPin(tester, '1234');
      expect(app.container.read(appLockProvider).enabled, isFalse);
      expect(find.text('Enter your current PIN'), findsNothing);
    });

    testWidgets('changing the PIN needs the current one, then confirms', (
      tester,
    ) async {
      final storage = _lockedStorage('1234');
      final app = await pumpApp(
        tester,
        prefs: storage.prefs,
        secrets: storage.secrets,
      );
      await enterPin(tester, '1234');

      unawaited(app.container.read(routerProvider).push('/pin/change'));
      await tester.pumpAndSettle();
      await enterPin(tester, '1234');
      expect(find.text('Set a 4-digit PIN'), findsOneWidget);
      await enterPin(tester, '5678');
      await enterPin(tester, '5678');

      final lock = app.container.read(appLockProvider.notifier);
      expect(await lock.verifyPin('5678'), isTrue);
      expect(await lock.verifyPin('1234'), isFalse);
    });
  });
}
