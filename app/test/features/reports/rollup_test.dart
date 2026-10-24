import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';

void main() {
  late Fixture f;
  late String vehicleId;

  DateTime at(int m, int d) => DateTime(2026, m, d, 9).toUtc();

  ExpenseDraft exp(
    String cat,
    int taka, {
    PaidBy by = PaidBy.owner,
    bool reimb = false,
    DateTime? when,
  }) => ExpenseDraft(
    categoryId: 'default:$cat',
    amount: Money.taka(taka),
    paidBy: by,
    reimbursable: reimb,
    spentAt: when,
  );

  Future<String> trip({
    required DateTime when,
    int fare = 1000,
    int? received,
    int pay = 0,
    String? vehicle,
    List<ExpenseDraft> expenses = const [],
  }) => f.trips.create(
    TripDraft(
      vehicleId: vehicle ?? vehicleId,
      startedAt: when,
      fare: Money.taka(fare),
      received: Money.taka(received ?? fare),
      driverPay: Money.taka(pay),
      expenses: expenses,
    ),
  );

  Future<DailyRollupRow?> row(DateTime d, {String? vehicle}) async {
    final day = CalendarDay.fromDate(d.toLocal()).epochDay;
    final rows = await f.db.select(f.db.dailyRollups).get();
    return rows
        .where((r) => r.vehicleId == (vehicle ?? vehicleId) && r.day == day)
        .firstOrNull;
  }

  Future<void> expectConsistent() async =>
      expect(await f.rollups.verify(), isEmpty);

  setUp(() async {
    f = Fixture();
    await f.categories.ensureDefaults();
    vehicleId = await f.vehicle(
      model: BusinessModel.contract,
      type: VehicleType.pickup,
    );
  });
  tearDown(() => f.close());

  group('trips', () {
    test('a trip creates its day rollup', () async {
      await trip(
        when: at(3, 10),
        fare: 4500,
        received: 1000,
        pay: 900,
        expenses: [exp('fuel', 900), exp('toll', 500)],
      );
      final r = (await row(at(3, 10)))!;
      expect(r.trips, 1);
      expect(r.fareMinor, 450000);
      expect(r.receivedMinor, 100000);
      expect(r.tripPayMinor, 90000);
      expect(r.variableMinor, 140000);
      expect(r.fixedMinor, 0);
      await expectConsistent();
    });

    test('several trips on a day add up; other days are untouched', () async {
      await trip(when: at(3, 10));
      await trip(when: at(3, 10), fare: 2000);
      await trip(when: at(3, 11), fare: 500);
      expect((await row(at(3, 10)))!.fareMinor, 300000);
      expect((await row(at(3, 10)))!.trips, 2);
      expect((await row(at(3, 11)))!.fareMinor, 50000);
      await expectConsistent();
    });

    test(
      "client-paid and driver-own expenses are not the owner's cost",
      () async {
        await trip(
          when: at(3, 10),
          expenses: [
            exp('fuel', 100),
            exp('toll', 200, by: PaidBy.client),
            exp('parking', 300, by: PaidBy.driver),
            exp('food', 400, by: PaidBy.driver, reimb: true),
          ],
        );
        expect((await row(at(3, 10)))!.variableMinor, 50000);
      },
    );

    test('editing a trip moves it between days and vehicles', () async {
      final other = await f.vehicle(
        name: 'Other',
        model: BusinessModel.contract,
      );
      final id = await trip(when: at(3, 10));
      final draft = TripDraft.fromTrip((await f.trips.get(id))!.trip, const []);

      await f.trips.update(
        id,
        TripDraft(
          vehicleId: other,
          startedAt: at(3, 12),
          fare: draft.fare,
          received: draft.received,
          driverPay: Money.zero,
        ),
      );
      expect(await row(at(3, 10)), isNull);
      expect(await row(at(3, 12), vehicle: other), isNotNull);
      expect(await row(at(3, 12)), isNull);
      await expectConsistent();
    });

    test('deleting a trip removes its income', () async {
      final id = await trip(when: at(3, 10));
      await f.trips.delete(id);
      expect(await row(at(3, 10)), isNull);
      await expectConsistent();
    });

    test('a later payment changes cash but not the fare', () async {
      final id = await trip(when: at(3, 10), received: 200);
      await f.trips.recordPayment(id, const Money.taka(300));
      final r = (await row(at(3, 10)))!;
      expect(r.fareMinor, 100000);
      expect(r.receivedMinor, 50000);
      await expectConsistent();
    });

    test(
      'trips on the last and first days of a month land in their own months',
      () async {
        await trip(when: at(3, 31), fare: 100);
        await trip(when: at(4, 1), fare: 200);
        expect((await row(at(3, 31)))!.fareMinor, 10000);
        expect((await row(at(4, 1)))!.fareMinor, 20000);
        await expectConsistent();
      },
    );
  });

  group('expenses and fixed costs', () {
    test('a vehicle expense on a running cost is variable', () async {
      await f.expenses.create(vehicleId, exp('fuel', 600, when: at(3, 5)));
      final r = (await row(at(3, 5)))!;
      expect(r.variableMinor, 60000);
      expect(r.fixedMinor, 0);
      expect(r.fixedAmortizedMinor, 0);
    });

    test(
      'an ownership cost is fixed and spread over the month, adding up exactly',
      () async {
        await f.expenses.create(
          vehicleId,
          exp('insurance', 3100, when: at(3, 5)),
        );
        final rows = (await f.db.select(f.db.dailyRollups).get())
            .where((r) => r.vehicleId == vehicleId)
            .toList();
        expect(
          rows,
          hasLength(31),
          reason: 'every day of March carries a share',
        );
        expect(rows.fold<int>(0, (a, r) => a + r.fixedAmortizedMinor), 310000);
        expect(rows.fold<int>(0, (a, r) => a + r.fixedMinor), 310000);
        expect(
          rows
              .firstWhere((r) => r.day == CalendarDay.of(2026, 3, 5).epochDay)
              .fixedMinor,
          310000,
        );
        await expectConsistent();
      },
    );

    test('an amount that does not divide evenly still adds up', () async {
      await f.expenses.create(
        vehicleId,
        ExpenseDraft(
          categoryId: 'default:repair',
          amount: const Money(100001),
          spentAt: at(2, 10),
        ),
      );
      final rows = await f.db.select(f.db.dailyRollups).get();
      expect(rows, hasLength(28));
      expect(rows.fold<int>(0, (a, r) => a + r.fixedAmortizedMinor), 100001);
    });

    test('editing and deleting keep the rollups right', () async {
      final id = await f.expenses.create(
        vehicleId,
        exp('repair', 1000, when: at(3, 5)),
      );
      await f.expenses.update(id, exp('repair', 2000, when: at(4, 7)));
      expect(await row(at(3, 5)), isNull, reason: 'March has nothing now');
      expect((await row(at(4, 7)))!.fixedMinor, 200000);
      await f.expenses.delete(id);
      expect(await f.db.select(f.db.dailyRollups).get(), isEmpty);
      await expectConsistent();
    });

    test('a fixed cost in one vehicle does not touch another', () async {
      final other = await f.vehicle(name: 'Other');
      await f.expenses.create(
        vehicleId,
        exp('insurance', 1000, when: at(3, 5)),
      );
      expect(
        (await f.db.select(f.db.dailyRollups).get()).where(
          (r) => r.vehicleId == other,
        ),
        isEmpty,
      );
    });
  });

  group('day logs', () {
    test('collection shows up in the rollup', () async {
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: CalendarDay.of(2026, 3, 5),
        amount: const Money.taka(2800),
      );
      expect((await row(at(3, 5)))!.collectionMinor, 280000);
      await expectConsistent();
    });
  });

  group('verify and rebuild', () {
    test('verify spots a tampered row and rebuildAll repairs it', () async {
      await trip(when: at(3, 10));
      await f.db.customStatement('UPDATE daily_rollups SET fare_minor = 1');
      final problems = await f.rollups.verify();
      expect(problems, hasLength(1));
      expect(problems.single, contains('2026-03-10'));

      await f.rollups.rebuildAll();
      expect(await f.rollups.verify(), isEmpty);
      expect((await row(at(3, 10)))!.fareMinor, 100000);
    });

    test('verify spots a missing and an extra row', () async {
      await trip(when: at(3, 10));
      await f.db.delete(f.db.dailyRollups).go();
      expect(await f.rollups.verify(), isNotEmpty);
      await f.rollups.rebuildAll();
      await f.db
          .into(f.db.dailyRollups)
          .insert(
            DailyRollupsCompanion.insert(
              vehicleId: vehicleId,
              day: 1,
              fareMinor: const Value(5),
            ),
          );
      expect(await f.rollups.verify(), isNotEmpty);
    });

    test('rebuilding from nothing is a no-op', () async {
      await f.rollups.rebuildAll();
      expect(await f.db.select(f.db.dailyRollups).get(), isEmpty);
    });
  });

  test('random operations never leave the rollups inconsistent', () async {
    final rng = Random(2026);
    final other = await f.vehicle(name: 'Other', model: BusinessModel.contract);
    final vehicles = [vehicleId, other];
    final tripIds = <String>[];
    final expenseIds = <String>[];

    for (var i = 0; i < 60; i++) {
      final v = vehicles[rng.nextInt(2)];
      final when = DateTime(
        2026,
        2 + rng.nextInt(3),
        1 + rng.nextInt(28),
        8,
      ).toUtc();
      switch (rng.nextInt(6)) {
        case 0 || 1:
          tripIds.add(
            await trip(
              when: when,
              vehicle: v,
              fare: 100 + rng.nextInt(900),
              received: rng.nextBool() ? 0 : null,
              pay: rng.nextInt(50),
              expenses: [if (rng.nextBool()) exp('fuel', 10 + rng.nextInt(90))],
            ),
          );
        case 2:
          expenseIds.add(
            await f.expenses.create(
              v,
              exp(
                rng.nextBool() ? 'repair' : 'fuel',
                50 + rng.nextInt(500),
                when: when,
              ),
            ),
          );
        case 3:
          await f.dayLogs.addIncome(
            vehicleId: v,
            day: CalendarDay.fromDate(when.toLocal()),
            amount: Money.taka(100 + rng.nextInt(500)),
          );
        case 4 when tripIds.isNotEmpty:
          final id = tripIds.removeAt(rng.nextInt(tripIds.length));
          await f.trips.delete(id);
        case 5 when expenseIds.isNotEmpty:
          final id = expenseIds.removeAt(rng.nextInt(expenseIds.length));
          await f.expenses.delete(id);
      }
    }
    expect(await f.rollups.verify(), isEmpty);
  });
}
