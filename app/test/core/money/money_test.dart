import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';

void main() {
  group('basic arithmetic', () {
    test('add, subtract, negate, scale', () {
      expect(const Money(150) + const Money(250), const Money(400));
      expect(const Money(150) - const Money(250), const Money(-100));
      expect(-const Money(5), const Money(-5));
      expect(const Money.taka(3) * 4, const Money(1200));
    });

    test('compare', () {
      expect(const Money(1) < const Money(2), isTrue);
      expect(const Money(2) >= const Money(2), isTrue);
      expect([const Money(3), const Money(1)]..sort(), [
        const Money(1),
        const Money(3),
      ]);
    });
  });

  group("percentOf rounding (banker's)", () {
    test('exact', () {
      expect(const Money(450000).percentOf(2000), const Money(90000));
    });

    test('ties go to even poisha', () {
      // 1% of 50 poisha = 0.5 -> 0 (even); of 150 = 1.5 -> 2 (even).
      expect(const Money(50).percentOf(100), Money.zero);
      expect(const Money(150).percentOf(100), const Money(2));
      expect(const Money(250).percentOf(100), const Money(2));
    });

    test('non-ties round to nearest', () {
      expect(const Money(149).percentOf(100), const Money(1));
      expect(const Money(151).percentOf(100), const Money(2));
    });

    test('negative values are symmetric', () {
      expect(const Money(-150).percentOf(100), const Money(-2));
      expect(const Money(150).percentOf(-100), const Money(-2));
      expect(const Money(-150).percentOf(-100), const Money(2));
    });

    test('0% and 100%', () {
      expect(const Money(12345).percentOf(0), Money.zero);
      expect(const Money(12345).percentOf(10000), const Money(12345));
    });
  });

  group('split', () {
    test('distributes remainder to first shares', () {
      expect(const Money(100).split(3), [
        const Money(34),
        const Money(33),
        const Money(33),
      ]);
    });

    test('rejects non-positive parts', () {
      expect(() => Money.zero.split(0), throwsArgumentError);
    });
  });

  group('property tests (seeded)', () {
    final rng = Random(42);
    int amount() => rng.nextInt(2000001) - 1000000;

    test('addition is commutative/associative and has an inverse', () {
      for (var i = 0; i < 500; i++) {
        final a = Money(amount());
        final b = Money(amount());
        final c = Money(amount());
        expect(a + b, b + a);
        expect((a + b) + c, a + (b + c));
        expect(a + (-a), Money.zero);
      }
    });

    test('split always sums to the original and shares differ by <= 1', () {
      for (var i = 0; i < 500; i++) {
        final total = Money(amount());
        final parts = rng.nextInt(12) + 1;
        final shares = total.split(parts);
        expect(shares, hasLength(parts));
        expect(shares.sum(), total);
        final minorValues = shares.map((s) => s.minor);
        expect(
          minorValues.reduce(max) - minorValues.reduce(min),
          lessThanOrEqualTo(1),
        );
      }
    });

    test('percentOf stays within half a poisha of the exact value', () {
      for (var i = 0; i < 500; i++) {
        final m = Money(amount());
        final bps = rng.nextInt(20001) - 10000;
        final exact = m.minor * bps / 10000;
        expect((m.percentOf(bps).minor - exact).abs(), lessThanOrEqualTo(0.5));
      }
    });

    test(
      'percentOf(a) + percentOf(b) is within 1 poisha of percentOf(a+b)',
      () {
        for (var i = 0; i < 500; i++) {
          final m = Money(amount());
          final a = rng.nextInt(5000);
          final b = rng.nextInt(5000);
          final diff = (m.percentOf(a) + m.percentOf(b) - m.percentOf(a + b))
              .minor
              .abs();
          expect(diff, lessThanOrEqualTo(1));
        }
      },
    );
  });
}
