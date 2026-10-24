import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/daylog/data/day_log_repository.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';

Matcher _throwsDayLog(DayLogError e) =>
    throwsA(isA<DayLogException>().having((x) => x.error, 'error', e));

void main() {
  late Fixture f;
  late String vehicleId;
  final today = day(2026, 3, 15);

  setUp(() async {
    f = Fixture();
    vehicleId = await f.vehicle(model: BusinessModel.self);
  });
  tearDown(() => f.close());

  Future<int> total() async =>
      (await f.dayLogs.get(vehicleId, today))!.collection.minor ~/ 100;

  test('adding income creates the day and re-entry merges into it', () async {
    expect(await f.dayLogs.get(vehicleId, today), isNull);
    expect(
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: today,
        amount: const Money.taka(500),
      ),
      const Money.taka(500),
    );
    await f.dayLogs.addIncome(
      vehicleId: vehicleId,
      day: today,
      amount: const Money.taka(300),
    );
    await f.dayLogs.addIncome(
      vehicleId: vehicleId,
      day: today,
      amount: const Money.taka(100),
    );
    expect(await total(), 900);
    expect(
      await f.db.select(f.db.dayLogs).get(),
      hasLength(1),
      reason: 'one log per vehicle per day',
    );
  });

  test('days and vehicles are separate', () async {
    final other = await f.vehicle(name: 'Other', model: BusinessModel.self);
    await f.dayLogs.addIncome(
      vehicleId: vehicleId,
      day: today,
      amount: const Money.taka(100),
    );
    await f.dayLogs.addIncome(
      vehicleId: vehicleId,
      day: day(2026, 3, 16),
      amount: const Money.taka(200),
    );
    await f.dayLogs.addIncome(
      vehicleId: other,
      day: today,
      amount: const Money.taka(300),
    );
    expect(await f.db.select(f.db.dayLogs).get(), hasLength(3));
  });

  test(
    'a negative amount undoes an earlier one, but never goes below zero',
    () async {
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: today,
        amount: const Money.taka(500),
      );
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: today,
        amount: const Money.taka(-200),
      );
      expect(await total(), 300);
      await expectLater(
        f.dayLogs.addIncome(
          vehicleId: vehicleId,
          day: today,
          amount: const Money.taka(-301),
        ),
        _throwsDayLog(DayLogError.belowZero),
      );
      expect(await total(), 300);
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: today,
        amount: const Money.taka(-300),
      );
      expect(await total(), 0);
    },
  );

  test('zero amounts and unknown vehicles are rejected', () async {
    await expectLater(
      f.dayLogs.addIncome(vehicleId: vehicleId, day: today, amount: Money.zero),
      _throwsDayLog(DayLogError.amountInvalid),
    );
    await expectLater(
      f.dayLogs.addIncome(
        vehicleId: 'nope',
        day: today,
        amount: const Money.taka(1),
      ),
      _throwsDayLog(DayLogError.vehicleNotFound),
    );
    expect(await f.db.select(f.db.dayLogs).get(), isEmpty);
  });

  group('driver and attendance', () {
    late String karim;
    setUp(() async {
      f = Fixture();
      vehicleId = await f.vehicle(model: BusinessModel.dailyWage);
      karim = await f.driver();
      await f.assignments.assign(
        vehicleId: vehicleId,
        driverId: karim,
        payModel: const DailyWagePay(perDay: Money.taka(800)),
        start: day(2026, 3, 1),
      );
    });

    test(
      'the day is linked to the assigned driver, who is marked present',
      () async {
        await f.dayLogs.addIncome(
          vehicleId: vehicleId,
          day: today,
          amount: const Money.taka(1000),
        );
        expect((await f.dayLogs.get(vehicleId, today))!.driverId, karim);
        final marks = await f.attendance.forRange(
          karim,
          DayRange(today, today),
        );
        expect(marks[today], AttendanceStatus.present);
      },
    );

    test('an existing mark is never overridden', () async {
      await f.attendance.mark(karim, today, AttendanceStatus.halfDay);
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: today,
        amount: const Money.taka(1000),
      );
      expect(
        (await f.attendance.forRange(karim, DayRange(today, today)))[today],
        AttendanceStatus.halfDay,
      );
    });

    test('a cleared mark is revived as present', () async {
      await f.attendance.mark(karim, today, AttendanceStatus.absent);
      await f.attendance.mark(karim, today, null);
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: today,
        amount: const Money.taka(1000),
      );
      expect(
        (await f.attendance.forRange(karim, DayRange(today, today)))[today],
        AttendanceStatus.present,
      );
      expect(await f.db.select(f.db.attendanceRecords).get(), hasLength(1));
    });

    test('a day before the assignment has no driver', () async {
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: day(2026, 2, 20),
        amount: const Money.taka(100),
      );
      expect(
        (await f.dayLogs.get(vehicleId, day(2026, 2, 20)))!.driverId,
        isNull,
      );
    });

    test('undoing does not mark attendance', () async {
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: today,
        amount: const Money.taka(100),
      );
      await f.attendance.mark(karim, today, null);
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: today,
        amount: const Money.taka(-100),
      );
      expect(
        await f.attendance.forRange(karim, DayRange(today, today)),
        isEmpty,
      );
    });

    test('a trip also marks the driver present', () async {
      await f.categories.ensureDefaults();
      await f.trips.create(
        TripDraftHelper.simple(
          vehicleId,
          karim,
          DateTime(2026, 3, 20, 9).toUtc(),
        ),
      );
      expect(
        (await f.attendance.forRange(
          karim,
          DayRange(day(2026, 3, 20), day(2026, 3, 20)),
        ))[day(2026, 3, 20)],
        AttendanceStatus.present,
      );
    });
  });

  test('details can be set once the day exists', () async {
    await expectLater(
      f.dayLogs.setDetails(vehicleId: vehicleId, day: today, distanceM: 1),
      _throwsDayLog(DayLogError.notFound),
    );
    await f.dayLogs.addIncome(
      vehicleId: vehicleId,
      day: today,
      amount: const Money.taka(100),
    );
    await f.dayLogs.setDetails(
      vehicleId: vehicleId,
      day: today,
      distanceM: 85000,
      hoursMin: 600,
      note: ' busy ',
    );
    final log = (await f.dayLogs.get(vehicleId, today))!;
    expect(log.distanceM, 85000);
    expect(log.hoursMin, 600);
    expect(log.note, 'busy');
    expect(log.collection, const Money.taka(100));
  });

  test('changes are audited', () async {
    await f.dayLogs.addIncome(
      vehicleId: vehicleId,
      day: today,
      amount: const Money.taka(500),
    );
    await f.dayLogs.addIncome(
      vehicleId: vehicleId,
      day: today,
      amount: const Money.taka(-100),
    );
    final rows = await f.audit('day_log');
    expect(rows.map((r) => r.action), ['create', 'income']);
    expect(jsonDecode(rows.last.diffJson), {
      'day': '2026-03-15',
      'addedMinor': -10000,
      'totalMinor': 40000,
    });
  });
}
