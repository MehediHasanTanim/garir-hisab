import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/payout_planner.dart';

OutstandingAdvance _adv(String id, int day, int taka) => OutstandingAdvance(
  id: id,
  givenOn: CalendarDay.of(2026, 3, day),
  remaining: Money.taka(taka),
);

void main() {
  test('no advances: net is earned plus adjustment', () {
    final plan = planPayout(
      earned: const Money.taka(15000),
      adjustment: const Money.taka(500),
      advances: const [],
    );
    expect(plan.net, const Money.taka(15500));
    expect(plan.deductions, isEmpty);
    expect(plan.deducted, Money.zero);
    expect(plan.advancesCarriedOver, Money.zero);
  });

  test('spec example: 15,000 salary, 4,000 advance -> 11,000', () {
    final plan = planPayout(
      earned: const Money.taka(15000),
      advances: [_adv('a', 5, 4000)],
    );
    expect(plan.net, const Money.taka(11000));
    expect(plan.deducted, const Money.taka(4000));
  });

  test('recovers oldest advance first regardless of input order', () {
    final plan = planPayout(
      earned: const Money.taka(5000),
      advances: [_adv('new', 20, 3000), _adv('old', 2, 3000)],
    );
    expect(plan.deductions.map((d) => (d.advanceId, d.amount)), [
      ('old', const Money.taka(3000)),
      ('new', const Money.taka(2000)),
    ]);
    expect(plan.net, Money.zero);
    expect(plan.advancesCarriedOver, const Money.taka(1000));
  });

  test('advances larger than earnings carry over and net stays zero', () {
    final plan = planPayout(
      earned: const Money.taka(2000),
      advances: [_adv('a', 1, 10000)],
    );
    expect(plan.net, Money.zero);
    expect(plan.deducted, const Money.taka(2000));
    expect(plan.advancesCarriedOver, const Money.taka(8000));
  });

  test('a bonus increases what can be recovered; a penalty reduces it', () {
    final bonus = planPayout(
      earned: const Money.taka(2000),
      adjustment: const Money.taka(1000),
      advances: [_adv('a', 1, 5000)],
    );
    expect(bonus.deducted, const Money.taka(3000));

    final penalty = planPayout(
      earned: const Money.taka(2000),
      adjustment: const Money.taka(-500),
      advances: [_adv('a', 1, 5000)],
    );
    expect(penalty.deducted, const Money.taka(1500));
    expect(penalty.net, Money.zero);
  });

  test('a penalty larger than earnings pays nothing and recovers nothing', () {
    final plan = planPayout(
      earned: const Money.taka(1000),
      adjustment: const Money.taka(-3000),
      advances: [_adv('a', 1, 500)],
    );
    expect(plan.net, Money.zero);
    expect(plan.deductions, isEmpty);
    expect(plan.advancesCarriedOver, const Money.taka(500));
  });

  test('zero-remaining advances are ignored', () {
    final plan = planPayout(
      earned: const Money.taka(1000),
      advances: [_adv('a', 1, 0), _adv('b', 2, 100)],
    );
    expect(plan.deductions.map((d) => d.advanceId), ['b']);
  });

  test('equal dates are ordered by id for determinism', () {
    final plan = planPayout(
      earned: const Money.taka(100),
      advances: [_adv('b', 1, 100), _adv('a', 1, 100)],
    );
    expect(plan.deductions.single.advanceId, 'a');
  });

  test('invariants hold for random inputs', () {
    final rng = Random(11);
    for (var i = 0; i < 500; i++) {
      final advances = [
        for (var k = 0; k < rng.nextInt(6); k++)
          OutstandingAdvance(
            id: 'a$k',
            givenOn: CalendarDay.of(2026, 1, 1 + rng.nextInt(28)),
            remaining: Money(rng.nextInt(500000)),
          ),
      ];
      final earned = Money(rng.nextInt(2000000));
      final adjustment = Money(rng.nextInt(400000) - 200000);
      final plan = planPayout(
        earned: earned,
        adjustment: adjustment,
        advances: advances,
      );

      expect(plan.net.isNegative, isFalse);
      // Nothing is created or lost.
      final gross = earned + adjustment;
      final payable = gross.isPositive ? gross : Money.zero;
      expect(plan.net + plan.deducted, payable);
      final totalRemaining = advances.map((a) => a.remaining).sum();
      expect(plan.deducted + plan.advancesCarriedOver, totalRemaining);
      // Never recover more than an advance's balance.
      for (final d in plan.deductions) {
        final source = advances.firstWhere((a) => a.id == d.advanceId);
        expect(d.amount <= source.remaining, isTrue);
        expect(d.amount.isPositive, isTrue);
      }
    }
  });
}
