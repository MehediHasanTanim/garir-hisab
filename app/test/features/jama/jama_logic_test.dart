import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/jama/domain/jama_logic.dart';

CalendarDay d(int y, int m, int day) => CalendarDay.of(y, m, day);
const taka600 = Money.taka(600);

void main() {
  group('scheduledDueDays', () {
    test('daily skips off weekdays (Friday)', () {
      // 1 Mar 2026 is a Sunday; Fridays: 6, 13, 20, 27.
      final days = scheduledDueDays(
        pay: const JamaPay(amount: taka600, offWeekdays: {5}),
        start: d(2026, 3, 1),
        through: d(2026, 3, 31),
      );
      expect(days, hasLength(31 - 4));
      expect(days.any((x) => x.day.weekday == 5), isFalse);
      expect(days.first, DueDay(d(2026, 3, 1), taka600));
    });

    test('26 working days with Fridays off in a 30-day month: spec §13', () {
      // April 2026: 30 days, 4 Fridays (3, 10, 17, 24) -> 26 due days.
      final days = scheduledDueDays(
        pay: const JamaPay(amount: taka600, offWeekdays: {5}),
        start: d(2026, 4, 1),
        through: d(2026, 4, 30),
      );
      expect(days, hasLength(26));
      expect(
        days.map((x) => x.expected).fold(Money.zero, (a, b) => a + b),
        const Money.taka(15600),
      );
    });

    test('starting mid-month only counts from the start day', () {
      final days = scheduledDueDays(
        pay: const JamaPay(amount: taka600),
        start: d(2026, 3, 18),
        through: d(2026, 3, 31),
      );
      expect(days, hasLength(14));
      expect(days.first.day, d(2026, 3, 18));
    });

    test('crosses month and year boundaries, including leap day', () {
      final days = scheduledDueDays(
        pay: const JamaPay(amount: taka600),
        start: d(2027, 12, 30),
        through: d(2028, 3, 1),
      );
      // 30,31 Dec + 31 Jan + 29 Feb (2028 is a leap year) + 1 Mar.
      expect(days, hasLength(2 + 31 + 29 + 1));
      expect(days.any((x) => x.day == d(2028, 2, 29)), isTrue);
    });

    test('nothing before the start or when through < start', () {
      expect(
        scheduledDueDays(
          pay: const JamaPay(amount: taka600),
          start: d(2026, 3, 10),
          through: d(2026, 3, 9),
        ),
        isEmpty,
      );
    });

    test('weekly falls due on the start weekday', () {
      final days = scheduledDueDays(
        pay: const JamaPay(
          amount: Money.taka(3000),
          frequency: JamaFrequency.weekly,
          offWeekdays: {1}, // ignored for weekly
        ),
        start: d(2026, 3, 4), // Wednesday
        through: d(2026, 3, 31),
      );
      expect(days.map((x) => x.day.day), [4, 11, 18, 25]);
      expect(days.every((x) => x.day.weekday == 3), isTrue);
    });
  });

  group('JamaEntryState', () {
    JamaEntryState s({int expected = 600, int waived = 0, int paid = 0}) =>
        JamaEntryState(
          day: d(2026, 3, 1),
          expected: Money.taka(expected),
          waived: Money.taka(waived),
          paid: Money.taka(paid),
        );

    test('statuses', () {
      expect(s().status, JamaStatus.unpaid);
      expect(s(paid: 200).status, JamaStatus.partial);
      expect(s(paid: 600).status, JamaStatus.paid);
      expect(s(waived: 600).status, JamaStatus.waived);
      expect(s(waived: 200, paid: 400).status, JamaStatus.paid);
      expect(s(expected: 0).status, JamaStatus.none);
    });

    test('due never goes negative', () {
      expect(s(paid: 700).due, Money.zero);
      expect(s(waived: 200, paid: 100).due, const Money.taka(300));
    });
  });

  group('allocateOldestFirst', () {
    OpenEntry e(String id, int day, int due) =>
        OpenEntry(id, d(2026, 3, day), Money.taka(due));

    test('pays the oldest first, partially if needed', () {
      final a = allocateOldestFirst(const Money.taka(900), [
        e('c', 3, 600),
        e('a', 1, 600),
        e('b', 2, 600),
      ]);
      expect(a.map((x) => x.entryId), ['a', 'b']);
      expect(a.map((x) => x.amount), [
        const Money.taka(600),
        const Money.taka(300),
      ]);
    });

    test('skips entries with nothing due', () {
      final a = allocateOldestFirst(const Money.taka(100), [
        e('a', 1, 0),
        e('b', 2, 600),
      ]);
      expect(a.single.entryId, 'b');
    });

    test('property: allocations never exceed the payment or any entry', () {
      final rnd = Random(42);
      for (var i = 0; i < 500; i++) {
        final entries = [
          for (var k = 0; k < rnd.nextInt(8); k++)
            OpenEntry(
              'e$k',
              d(2026, 3, 1 + rnd.nextInt(28)),
              Money(rnd.nextInt(80000)),
            ),
        ];
        final payment = Money(rnd.nextInt(300000));
        final out = allocateOldestFirst(payment, entries);
        final total = out.fold(Money.zero, (a, b) => a + b.amount);
        final owed = entries.fold(Money.zero, (a, b) => a + b.due);
        expect(total <= payment, isTrue);
        expect(
          total,
          payment < owed ? payment : owed,
          reason: 'uses as much as is owed, up to the payment',
        );
        for (final a in out) {
          final entry = entries.firstWhere((x) => x.id == a.entryId);
          expect(a.amount <= entry.due, isTrue);
          expect(a.amount.isPositive, isTrue);
        }
        // Oldest first: an entry is only partly paid if no later entry got money.
        final ids = out.map((x) => x.entryId).toList();
        final sorted = [...entries]
          ..sort((a, b) {
            final c = a.day.compareTo(b.day);
            return c != 0 ? c : a.id.compareTo(b.id);
          });
        final order = sorted
            .where((x) => x.due.isPositive)
            .map((x) => x.id)
            .toList();
        expect(ids, order.take(ids.length).toList());
      }
    });
  });

  test('collection rate rounds to a whole percent', () {
    expect(
      collectionRatePercent(const Money.taka(15600), const Money.taka(15600)),
      100,
    );
    expect(collectionRatePercent(const Money.taka(1), const Money.taka(3)), 33);
    expect(collectionRatePercent(const Money.taka(2), const Money.taka(3)), 67);
    expect(collectionRatePercent(Money.zero, Money.zero), 0);
  });
}
