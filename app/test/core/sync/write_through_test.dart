import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/sync/sync_store.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/jama/data/jama_repository.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';

/// Every repository write must leave the rows it changed marked as waiting
/// to sync. This test runs each write against a clean database and checks
/// that every row whose content changed is dirty again.
void main() {
  late Fixture fx;
  late String vehicle;
  late String driver;
  late String assignment;
  late String trip;
  late String expense;

  Future<Map<String, Map<String, Map<String, Object?>>>> snapshot() async {
    final out = <String, Map<String, Map<String, Object?>>>{};
    for (final t in syncTableOrder) {
      final rows = await fx.db.customSelect('SELECT * FROM $t').get();
      out[t] = {
        for (final r in rows)
          r.read<String>('id'): Map.of(r.data)..remove('dirty'),
      };
    }
    return out;
  }

  Future<void> markAllClean() async {
    for (final t in syncTableOrder) {
      await fx.db.customStatement('UPDATE $t SET dirty = 0');
    }
  }

  Future<void> expectChangesDirty(
    String label,
    Future<void> Function() op,
  ) async {
    await markAllClean();
    final before = await snapshot();
    await op();
    final after = await snapshot();
    var changed = 0;
    for (final t in syncTableOrder) {
      for (final e in after[t]!.entries) {
        final was = before[t]![e.key];
        if (was != null && _same(was, e.value)) continue;
        changed++;
        final dirty =
            (await fx.db
                    .customSelect("SELECT dirty FROM $t WHERE id = '${e.key}'")
                    .getSingle())
                .read<int>('dirty');
        expect(
          dirty,
          1,
          reason: '$label: $t/${e.key} changed but is not dirty',
        );
      }
    }
    expect(changed, greaterThan(0), reason: '$label changed nothing');
  }

  setUp(() async {
    fx = Fixture();
    vehicle = await fx.vehicle();
    driver = await fx.driver();
    await fx.categories.ensureDefaults();
    assignment = await fx.assignments.assign(
      vehicleId: vehicle,
      driverId: driver,
      payModel: salary15000,
      start: day(2026, 1, 1),
    );
    trip = await fx.trips.create(
      TripDraftHelper.simple(vehicle, driver, DateTime.utc(2026, 3, 10, 8)),
    );
    expense = await fx.expenses.create(
      vehicle,
      ExpenseDraftFor.fuel(300, DateTime.utc(2026, 3, 10, 9)),
    );
  });
  tearDown(() => fx.close());

  test('vehicles', () async {
    await expectChangesDirty('vehicle update', () async {
      await fx.vehicles.update(vehicle, salariedVehicle(name: 'Renamed'));
    });
    await expectChangesDirty(
      'vehicle status',
      () => fx.vehicles.setStatus(vehicle, VehicleStatus.inGarage),
    );
    await expectChangesDirty(
      'vehicle archive',
      () => fx.vehicles.setArchived(vehicle, archived: true),
    );
    await expectChangesDirty(
      'vehicle create',
      () => fx.vehicle(name: 'Second'),
    );
  });

  test('drivers, assignments, attendance, advances', () async {
    await expectChangesDirty('driver update', () async {
      final d = (await fx.drivers.get(driver))!;
      await fx.drivers.update(driver, DriverDraft(name: '${d.name} 2'));
    });
    await expectChangesDirty(
      'attendance mark',
      () =>
          fx.attendance.mark(driver, day(2026, 3, 5), AttendanceStatus.absent),
    );
    await expectChangesDirty(
      'attendance change',
      () =>
          fx.attendance.mark(driver, day(2026, 3, 5), AttendanceStatus.halfDay),
    );
    await expectChangesDirty(
      'attendance clear',
      () => fx.attendance.mark(driver, day(2026, 3, 5), null),
    );
    late String advance;
    await expectChangesDirty('advance give', () async {
      advance = await fx.advances.give(
        driverId: driver,
        amount: const Money.taka(500),
        day: day(2026, 3, 6),
      );
    });
    await expectChangesDirty(
      'advance remove',
      () => fx.advances.remove(advance),
    );
    await expectChangesDirty(
      'assignment end',
      () => fx.assignments.end(assignment, day(2026, 3, 31)),
    );
    await expectChangesDirty(
      'driver status',
      () => fx.drivers.setStatus(driver, DriverStatus.left),
    );
  });

  test('payouts', () async {
    late String payoutId;
    await expectChangesDirty('payout record', () async {
      payoutId = (await fx.payouts.record(
        driverId: driver,
        assignmentId: assignment,
        period: DayRange.month(2026, 2),
      )).payout.id;
    });
    await expectChangesDirty(
      'payout void',
      () => fx.payouts.voidPayout(payoutId),
    );
  });

  test('categories, trips, expenses, day logs', () async {
    late String cat;
    await expectChangesDirty('category create', () async {
      cat = await fx.categories.createCustom('Wash bay');
    });
    await expectChangesDirty(
      'category rename',
      () => fx.categories.rename(cat, 'Wash'),
    );
    await expectChangesDirty(
      'category archive',
      () => fx.categories.setArchived(cat, archived: true),
    );

    final unpaid = await fx.trips.create(
      TripDraft(
        vehicleId: vehicle,
        driverId: driver,
        startedAt: DateTime.utc(2026, 3, 12, 8),
        fare: const Money.taka(1000),
        received: Money.zero,
        driverPay: Money.zero,
      ),
    );
    await expectChangesDirty(
      'trip payment',
      () => fx.trips.recordPayment(unpaid, const Money.taka(100)),
    );
    await expectChangesDirty('trip update', () async {
      final d = (await fx.trips.get(trip))!;
      await fx.trips.update(
        trip,
        TripDraftHelper.simple(
          vehicle,
          driver,
          DateTime.utc(2026, 3, 10, 8),
          fare: 1500,
        ),
      );
      expect(d, isNotNull);
    });
    await expectChangesDirty(
      'expense update',
      () => fx.expenses.update(
        expense,
        ExpenseDraftFor.fuel(450, DateTime.utc(2026, 3, 10, 9)),
      ),
    );
    await expectChangesDirty(
      'expense delete',
      () => fx.expenses.delete(expense),
    );
    await expectChangesDirty(
      'day log income',
      () => fx.dayLogs.addIncome(
        vehicleId: vehicle,
        day: day(2026, 3, 11),
        amount: const Money.taka(2800),
      ),
    );
    await expectChangesDirty(
      'day log details',
      () => fx.dayLogs.setDetails(
        vehicleId: vehicle,
        day: day(2026, 3, 11),
        note: 'rain',
      ),
    );
    await expectChangesDirty('trip delete', () => fx.trips.delete(trip));
  });

  test('jama', () async {
    final jv = await fx.vehicle(name: 'Jama CNG', model: BusinessModel.jama);
    final jd = await fx.driver(name: 'Rahim');
    final ja = await fx.assignments.assign(
      vehicleId: jv,
      driverId: jd,
      payModel: const JamaPay(amount: Money.taka(600)),
      start: day(2026, 3, 1),
    );
    await expectChangesDirty(
      'jama generate',
      () => fx.jama.generate(day(2026, 3, 5)),
    );
    late String payment;
    await expectChangesDirty('jama collect', () async {
      payment = await fx.jama.collect(
        assignmentId: ja,
        amount: const Money.taka(900),
        day: day(2026, 3, 5),
        today: day(2026, 3, 5),
      );
    });
    final entry = (await fx.jama.entriesForVehicle(
      jv,
      DayRange.month(2026, 3),
    ))[3];
    await expectChangesDirty('jama waive', () => fx.jama.waive(entry.id));
    await expectChangesDirty('jama void', () => fx.jama.voidPayment(payment));
    late String pause;
    await expectChangesDirty('garage start', () async {
      pause = await fx.jama.startGarage(
        vehicleId: jv,
        start: day(2026, 3, 4),
        mode: GarageMode.pause,
      );
    });
    await expectChangesDirty(
      'garage end',
      () => fx.jama.endGarage(pause, day(2026, 3, 4)),
    );
    await expectChangesDirty(
      'deposit',
      () => fx.jama.addDeposit(
        assignmentId: ja,
        kind: DepositKind.received,
        amount: const Money.taka(5000),
        day: day(2026, 3, 1),
      ),
    );
  });
}

bool _same(Map<String, Object?> a, Map<String, Object?> b) {
  if (a.length != b.length) return false;
  for (final k in a.keys) {
    if (a[k] != b[k]) return false;
  }
  return true;
}
