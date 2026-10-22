import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/drivers/data/assignment_repository.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';

const _salary = SalaryPay(monthly: Money.taka(15000));
const _salary2 = SalaryPay(monthly: Money.taka(18000));

Matcher _throwsAssignment(AssignmentError e) =>
    throwsA(isA<AssignmentException>().having((x) => x.error, 'error', e));

void main() {
  late Fixture f;
  setUp(() => f = Fixture());
  tearDown(() => f.close());

  Future<List<AssignmentRow>> rows() => f.db.select(f.db.assignments).get();

  test('assigns a driver and reads it back with names', () async {
    final v = await f.vehicle(name: 'Pickup 1');
    final d = await f.driver();
    final id = await f.assignments.assign(
      vehicleId: v,
      driverId: d,
      payModel: _salary,
      start: day(2026, 3, 1),
    );

    final active = await f.assignments.watchActiveForVehicle(v).first;
    expect(active!.assignment.id, id);
    expect(active.driverName, 'Karim');
    expect(active.vehicleNickname, 'Pickup 1');
    expect(active.assignment.payModel, _salary);
    expect(active.assignment.isActive, isTrue);
    expect(active.assignment.start, day(2026, 3, 1));
  });

  group('one active assignment per vehicle', () {
    test('the database itself rejects a second active row', () async {
      final v = await f.vehicle();
      final d = await f.driver();
      await f.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: _salary,
        start: day(2026, 3, 1),
      );
      // Bypass the repository: raw insert of another active assignment.
      await expectLater(
        f.db
            .into(f.db.assignments)
            .insert(
              AssignmentsCompanion.insert(
                vehicleId: v,
                driverId: d,
                payModelJson: _salary.encode(),
                startDay: day(2026, 4, 1).epochDay,
                activeVehicleKey: Value(v),
              ),
            ),
        throwsA(anything),
      );
    });

    test(
      'ended assignments do not block new ones (NULLs are distinct)',
      () async {
        final v = await f.vehicle();
        final d = await f.driver();
        final a = await f.assignments.assign(
          vehicleId: v,
          driverId: d,
          payModel: _salary,
          start: day(2026, 1, 1),
        );
        await f.assignments.end(a, day(2026, 1, 31));
        final b = await f.assignments.assign(
          vehicleId: v,
          driverId: d,
          payModel: _salary,
          start: day(2026, 2, 1),
        );
        final c = await f.assignments.assign(
          vehicleId: v,
          driverId: d,
          payModel: _salary2,
          start: day(2026, 3, 1),
        );
        expect({a, b, c}, hasLength(3));
        final active = (await rows()).where((r) => r.endDay == null);
        expect(active, hasLength(1));
      },
    );

    test('different vehicles can each have a driver', () async {
      final d = await f.driver();
      for (final name in ['A', 'B', 'C']) {
        final v = await f.vehicle(name: name);
        await f.assignments.assign(
          vehicleId: v,
          driverId: d,
          payModel: _salary,
          start: day(2026, 1, 1),
        );
      }
      expect((await rows()).where((r) => r.endDay == null), hasLength(3));
      expect(await f.assignments.activeForDriver(d), hasLength(3));
    });
  });

  group('switching drivers', () {
    test(
      'the previous assignment ends the day before the new one starts',
      () async {
        final v = await f.vehicle();
        final karim = await f.driver();
        final rahim = await f.driver(name: 'Rahim');
        final first = await f.assignments.assign(
          vehicleId: v,
          driverId: karim,
          payModel: _salary,
          start: day(2026, 1, 1),
        );
        final second = await f.assignments.assign(
          vehicleId: v,
          driverId: rahim,
          payModel: _salary2,
          start: day(2026, 3, 15),
        );

        final history = await f.assignments.watchForVehicle(v).first;
        expect(history.map((h) => h.assignment.id), [second, first]);
        expect(history.first.assignment.end, isNull);
        expect(history.last.assignment.end, day(2026, 3, 14));
        expect(history.last.driverName, 'Karim');
      },
    );

    test('revising pay terms with the same driver keeps history', () async {
      final v = await f.vehicle();
      final d = await f.driver();
      await f.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: _salary,
        start: day(2026, 1, 1),
      );
      await f.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: _salary2,
        start: day(2026, 2, 1),
      );
      final history = await f.assignments.watchForVehicle(v).first;
      expect(history.map((h) => h.assignment.payModel), [_salary2, _salary]);
    });

    test('the new start must be after the current start', () async {
      final v = await f.vehicle();
      final d = await f.driver();
      await f.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: _salary,
        start: day(2026, 3, 10),
      );
      for (final start in [day(2026, 3, 10), day(2026, 3, 1)]) {
        await expectLater(
          f.assignments.assign(
            vehicleId: v,
            driverId: d,
            payModel: _salary2,
            start: start,
          ),
          _throwsAssignment(AssignmentError.startNotAfterCurrent),
        );
      }
      // The failed attempts changed nothing.
      expect(await rows(), hasLength(1));
      expect((await rows()).single.endDay, isNull);
    });

    test('cannot start before an earlier assignment ended', () async {
      final v = await f.vehicle();
      final d = await f.driver();
      final a = await f.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: _salary,
        start: day(2026, 1, 1),
      );
      await f.assignments.end(a, day(2026, 2, 28));
      await expectLater(
        f.assignments.assign(
          vehicleId: v,
          driverId: d,
          payModel: _salary,
          start: day(2026, 2, 15),
        ),
        _throwsAssignment(AssignmentError.overlapsHistory),
      );
      // Starting the day after it ended is fine.
      await f.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: _salary,
        start: day(2026, 3, 1),
      );
    });
  });

  group('rules', () {
    test('rejects an invalid pay model', () async {
      final v = await f.vehicle();
      final d = await f.driver();
      await expectLater(
        f.assignments.assign(
          vehicleId: v,
          driverId: d,
          payModel: const SalaryPay(monthly: Money.zero),
          start: day(2026, 1, 1),
        ),
        _throwsAssignment(AssignmentError.payModelInvalid),
      );
    });

    test('pay type must suit the vehicle business model', () async {
      final jamaVehicle = await f.vehicle(model: BusinessModel.jama);
      final d = await f.driver();
      await expectLater(
        f.assignments.assign(
          vehicleId: jamaVehicle,
          driverId: d,
          payModel: _salary,
          start: day(2026, 1, 1),
        ),
        _throwsAssignment(AssignmentError.payTypeNotAllowed),
      );
      await f.assignments.assign(
        vehicleId: jamaVehicle,
        driverId: d,
        payModel: const JamaPay(amount: Money.taka(600)),
        start: day(2026, 1, 1),
      );
    });

    test('self-driven vehicles cannot have a driver', () async {
      final v = await f.vehicle(model: BusinessModel.self);
      final d = await f.driver();
      await expectLater(
        f.assignments.assign(
          vehicleId: v,
          driverId: d,
          payModel: _salary,
          start: day(2026, 1, 1),
        ),
        _throwsAssignment(AssignmentError.noDriverForSelfDriven),
      );
    });

    test('unknown vehicle or driver', () async {
      final v = await f.vehicle();
      final d = await f.driver();
      await expectLater(
        f.assignments.assign(
          vehicleId: 'nope',
          driverId: d,
          payModel: _salary,
          start: day(2026, 1, 1),
        ),
        _throwsAssignment(AssignmentError.vehicleNotFound),
      );
      await expectLater(
        f.assignments.assign(
          vehicleId: v,
          driverId: 'nope',
          payModel: _salary,
          start: day(2026, 1, 1),
        ),
        _throwsAssignment(AssignmentError.driverNotFound),
      );
    });

    test('a driver who has left cannot be assigned', () async {
      final v = await f.vehicle();
      final d = await f.driver(status: DriverStatus.left);
      await expectLater(
        f.assignments.assign(
          vehicleId: v,
          driverId: d,
          payModel: _salary,
          start: day(2026, 1, 1),
        ),
        _throwsAssignment(AssignmentError.driverInactive),
      );
    });

    test('a failed switch leaves the current assignment untouched', () async {
      final v = await f.vehicle();
      final d = await f.driver();
      final gone = await f.driver(name: 'Gone', status: DriverStatus.left);
      await f.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: _salary,
        start: day(2026, 1, 1),
      );
      await expectLater(
        f.assignments.assign(
          vehicleId: v,
          driverId: gone,
          payModel: _salary,
          start: day(2026, 2, 1),
        ),
        _throwsAssignment(AssignmentError.driverInactive),
      );
      final active = await f.assignments.watchActiveForVehicle(v).first;
      expect(active!.driverName, 'Karim');
    });
  });

  group('ending', () {
    test('end sets the end date and frees the vehicle', () async {
      final v = await f.vehicle();
      final d = await f.driver();
      final a = await f.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: _salary,
        start: day(2026, 1, 1),
      );
      await f.assignments.end(a, day(2026, 1, 31));
      expect(await f.assignments.watchActiveForVehicle(v).first, isNull);
      expect((await f.assignments.get(a))!.end, day(2026, 1, 31));
    });

    test('end validation', () async {
      final v = await f.vehicle();
      final d = await f.driver();
      final a = await f.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: _salary,
        start: day(2026, 3, 10),
      );
      await expectLater(
        f.assignments.end(a, day(2026, 3, 9)),
        _throwsAssignment(AssignmentError.endBeforeStart),
      );
      // Ending on the start day is a one-day assignment.
      await f.assignments.end(a, day(2026, 3, 10));
      await expectLater(
        f.assignments.end(a, day(2026, 3, 20)),
        _throwsAssignment(AssignmentError.alreadyEnded),
      );
      await expectLater(
        f.assignments.end('nope', day(2026, 3, 20)),
        _throwsAssignment(AssignmentError.assignmentNotFound),
      );
    });

    test('endAllForDriver ends every running assignment', () async {
      final d = await f.driver();
      final other = await f.driver(name: 'Other');
      final v1 = await f.vehicle(name: 'V1');
      final v2 = await f.vehicle(name: 'V2');
      final v3 = await f.vehicle(name: 'V3');
      await f.assignments.assign(
        vehicleId: v1,
        driverId: d,
        payModel: _salary,
        start: day(2026, 1, 1),
      );
      await f.assignments.assign(
        vehicleId: v2,
        driverId: d,
        payModel: _salary,
        start: day(2026, 6, 1),
      );
      await f.assignments.assign(
        vehicleId: v3,
        driverId: other,
        payModel: _salary,
        start: day(2026, 1, 1),
      );

      await f.assignments.endAllForDriver(d, day(2026, 3, 31));

      expect(await f.assignments.activeForDriver(d), isEmpty);
      expect(await f.assignments.activeForDriver(other), hasLength(1));
      final v2a =
          (await f.assignments.watchForVehicle(v2).first).single.assignment;
      expect(v2a.end, day(2026, 6, 1), reason: 'cannot end before it started');
    });
  });

  test('every change is written to the audit log', () async {
    final v = await f.vehicle();
    final d = await f.driver();
    final a = await f.assignments.assign(
      vehicleId: v,
      driverId: d,
      payModel: _salary,
      start: day(2026, 1, 1),
    );
    final b = await f.assignments.assign(
      vehicleId: v,
      driverId: d,
      payModel: _salary2,
      start: day(2026, 2, 1),
    );
    await f.assignments.end(b, day(2026, 2, 28));

    final all = await f.audit('assignment');
    expect(all.map((r) => (r.entityId, r.action)).toList(), [
      (a, 'create'),
      (a, 'end'),
      (b, 'create'),
      (b, 'end'),
    ]);
  });
}
