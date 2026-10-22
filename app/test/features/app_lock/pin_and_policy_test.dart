import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/features/app_lock/domain/lock_policy.dart';
import 'package:vehicle_khata/features/app_lock/domain/pin_hasher.dart';

void main() {
  group('PinHasher', () {
    test('only 4-digit numeric PINs are valid', () {
      expect(PinHasher.isValidPin('1234'), isTrue);
      expect(PinHasher.isValidPin('0000'), isTrue);
      for (final bad in ['', '123', '12345', 'abcd', '12a4', '१२३४', ' 123']) {
        expect(PinHasher.isValidPin(bad), isFalse, reason: bad);
      }
    });

    test('verify accepts the right PIN and rejects others', () {
      final salt = PinHasher.newSalt();
      final hash = PinHasher.hash('1234', salt);
      expect(PinHasher.verify('1234', salt: salt, hash: hash), isTrue);
      expect(PinHasher.verify('1235', salt: salt, hash: hash), isFalse);
      expect(PinHasher.verify('1234', salt: 'other', hash: hash), isFalse);
      expect(PinHasher.verify('1234', salt: salt, hash: 'short'), isFalse);
    });

    test('salts differ, so equal PINs hash differently', () {
      final a = PinHasher.newSalt();
      final b = PinHasher.newSalt();
      expect(a, isNot(b));
      expect(PinHasher.hash('1234', a), isNot(PinHasher.hash('1234', b)));
    });

    test('the hash does not contain the PIN', () {
      final salt = PinHasher.newSalt(Random(1));
      expect(PinHasher.hash('1234', salt), isNot(contains('1234')));
      expect(PinHasher.hash('1234', salt), hasLength(64));
    });
  });

  group('LockPolicy.shouldLock', () {
    final t0 = DateTime(2026, 10, 22, 12);
    test('never locks if the app was not backgrounded', () {
      expect(
        LockPolicy.shouldLock(
          backgroundedAt: null,
          now: t0,
          timeout: LockTimeout.immediately,
        ),
        isFalse,
      );
    });

    test('locks once the timeout has elapsed', () {
      bool lockAfter(Duration d, LockTimeout t) =>
          LockPolicy.shouldLock(backgroundedAt: t0, now: t0.add(d), timeout: t);
      expect(lockAfter(Duration.zero, LockTimeout.immediately), isTrue);
      expect(
        lockAfter(const Duration(seconds: 29), LockTimeout.seconds30),
        isFalse,
      );
      expect(
        lockAfter(const Duration(seconds: 30), LockTimeout.seconds30),
        isTrue,
      );
      expect(
        lockAfter(const Duration(minutes: 4), LockTimeout.minutes5),
        isFalse,
      );
      expect(
        lockAfter(const Duration(minutes: 5), LockTimeout.minutes5),
        isTrue,
      );
    });
  });

  group('LockPolicy.blockedFor', () {
    final t0 = DateTime(2026, 10, 22, 12);
    test('allows attempts below the limit', () {
      expect(
        LockPolicy.blockedFor(failedAttempts: 4, lastFailureAt: t0, now: t0),
        isNull,
      );
    });

    test('blocks after 5 failures until the lockout ends', () {
      expect(
        LockPolicy.blockedFor(
          failedAttempts: 5,
          lastFailureAt: t0,
          now: t0.add(const Duration(seconds: 10)),
        ),
        const Duration(seconds: 20),
      );
      expect(
        LockPolicy.blockedFor(
          failedAttempts: 5,
          lastFailureAt: t0,
          now: t0.add(const Duration(seconds: 30)),
        ),
        isNull,
      );
    });
  });
}
