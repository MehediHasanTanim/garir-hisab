import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/jama/data/jama_repository.dart';
import 'package:vehicle_khata/features/jama/domain/jama_logic.dart';
import 'package:vehicle_khata/features/reports/domain/profit_engine.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';

CalendarDay d(int y, int m, int day) => CalendarDay.of(y, m, day);

void main() {
  late Fixture fx;
  late String vehicle;
  late String driver;
  late String assignment;

  Future<String> assign({
    JamaPay pay = const JamaPay(amount: Money.taka(600), offWeekdays: {5}),
    CalendarDay? start,
  }) async {
    vehicle = await fx.vehicle(model: BusinessModel.jama);
    driver = await fx.driver();
    return assignment = await fx.assignments.assign(
      vehicleId: vehicle,
      driverId: driver,
      payModel: pay,
      start: start ?? d(2026, 4, 1),
    );
  }

  Future<List<JamaEntryView>> entries(CalendarDay from, CalendarDay to) =>
      fx.jama.entriesForVehicle(vehicle, DayRange(from, to));

  setUp(() => fx = Fixture());
  tearDown(() => fx.close());

  group('generator', () {
    test('creates one entry per due day, and is idempotent', () async {
      await assign();
      expect(await fx.jama.generate(d(2026, 4, 30)), 26);
      expect(await fx.jama.generate(d(2026, 4, 30)), 0);
      expect(await entries(d(2026, 4, 1), d(2026, 4, 30)), hasLength(26));
    });

    test('backfills days missed while the app was closed', () async {
      await assign();
      await fx.jama.generate(d(2026, 4, 5));
      await fx.jama.generate(d(2026, 4, 20));
      final all = await entries(d(2026, 4, 1), d(2026, 4, 30));
      expect(all.map((e) => e.state.day.day), [
        for (var i = 1; i <= 20; i++)
          if (i != 3 && i != 10 && i != 17) i,
      ]);
    });

    test('stops at the end of a finished assignment', () async {
      await assign(pay: const JamaPay(amount: Money.taka(600)));
      await fx.assignments.end(assignment, d(2026, 4, 10));
      await fx.jama.generate(d(2026, 4, 30));
      expect(await entries(d(2026, 4, 1), d(2026, 4, 30)), hasLength(10));
    });

    test('a reassignment starts a fresh schedule for the new driver', () async {
      await assign(pay: const JamaPay(amount: Money.taka(600)));
      await fx.assignments.end(assignment, d(2026, 4, 10));
      final rahim = await fx.driver(name: 'Rahim');
      final second = await fx.assignments.assign(
        vehicleId: vehicle,
        driverId: rahim,
        payModel: const JamaPay(amount: Money.taka(700)),
        start: d(2026, 4, 11),
      );
      await fx.jama.generate(d(2026, 4, 15));
      final all = await entries(d(2026, 4, 1), d(2026, 4, 30));
      expect(all, hasLength(15));
      expect(all.where((e) => e.assignmentId == second), hasLength(5));
      expect(all.last.state.expected, const Money.taka(700));
      expect(
        await fx.jama.bakiForDriver(driver, d(2026, 4, 15)),
        const Money.taka(6000),
      );
      expect(
        await fx.jama.bakiForDriver(rahim, d(2026, 4, 15)),
        const Money.taka(3500),
      );
    });

    test('a start in the future creates nothing yet', () async {
      await assign(start: d(2026, 5, 1));
      expect(await fx.jama.generate(d(2026, 4, 30)), 0);
    });
  });

  group('collecting', () {
    test('full payment clears the day; partial leaves baki', () async {
      await assign(pay: const JamaPay(amount: Money.taka(600)));
      await fx.jama.generate(d(2026, 4, 3));
      await fx.jama.collect(
        assignmentId: assignment,
        amount: const Money.taka(600),
        day: d(2026, 4, 3),
        today: d(2026, 4, 3),
      );
      // Oldest first: the 1st is paid, 2nd and 3rd still owed.
      var all = await entries(d(2026, 4, 1), d(2026, 4, 3));
      expect(all.map((e) => e.state.status), [
        JamaStatus.paid,
        JamaStatus.unpaid,
        JamaStatus.unpaid,
      ]);
      await fx.jama.collect(
        assignmentId: assignment,
        amount: const Money.taka(300),
        day: d(2026, 4, 3),
        today: d(2026, 4, 3),
      );
      all = await entries(d(2026, 4, 1), d(2026, 4, 3));
      expect(all[1].state.status, JamaStatus.partial);
      expect(
        await fx.jama.bakiForDriver(driver, d(2026, 4, 3)),
        const Money.taka(900),
      );
    });

    test('rejects zero, nothing due, and more than is owed', () async {
      await assign(pay: const JamaPay(amount: Money.taka(600)));
      await fx.jama.generate(d(2026, 4, 1));
      Future<void> collect(Money m) => fx.jama.collect(
        assignmentId: assignment,
        amount: m,
        day: d(2026, 4, 1),
        today: d(2026, 4, 1),
      );
      await expectLater(
        collect(Money.zero),
        throwsA(
          isA<JamaException>().having(
            (e) => e.error,
            'error',
            JamaError.amountInvalid,
          ),
        ),
      );
      await expectLater(
        collect(const Money.taka(700)),
        throwsA(
          isA<JamaException>().having(
            (e) => e.error,
            'error',
            JamaError.exceedsDue,
          ),
        ),
      );
      await collect(const Money.taka(600));
      await expectLater(
        collect(const Money.taka(1)),
        throwsA(
          isA<JamaException>().having(
            (e) => e.error,
            'error',
            JamaError.nothingDue,
          ),
        ),
      );
    });

    test('voiding a payment makes the days owed again', () async {
      await assign(pay: const JamaPay(amount: Money.taka(600)));
      await fx.jama.generate(d(2026, 4, 2));
      final id = await fx.jama.collect(
        assignmentId: assignment,
        amount: const Money.taka(1200),
        day: d(2026, 4, 2),
        today: d(2026, 4, 2),
      );
      expect(await fx.jama.bakiForDriver(driver, d(2026, 4, 2)), Money.zero);
      await fx.jama.voidPayment(id);
      expect(
        await fx.jama.bakiForDriver(driver, d(2026, 4, 2)),
        const Money.taka(1200),
      );
      expect(await fx.rollups.verify(), isEmpty);
    });

    test('waiving forgives what is owed on one day', () async {
      await assign(pay: const JamaPay(amount: Money.taka(600)));
      await fx.jama.generate(d(2026, 4, 2));
      final first = (await entries(d(2026, 4, 1), d(2026, 4, 2))).first;
      await fx.jama.waive(first.id);
      final all = await entries(d(2026, 4, 1), d(2026, 4, 2));
      expect(all.first.state.status, JamaStatus.waived);
      expect(
        await fx.jama.bakiForDriver(driver, d(2026, 4, 2)),
        const Money.taka(600),
      );
    });

    test('a payment can settle the baki across months, oldest first', () async {
      await assign(
        pay: const JamaPay(amount: Money.taka(600)),
        start: d(2026, 3, 30),
      );
      await fx.jama.generate(d(2026, 4, 2));
      await fx.jama.collect(
        assignmentId: assignment,
        amount: const Money.taka(1500),
        day: d(2026, 4, 2),
        today: d(2026, 4, 2),
      );
      final all = await entries(d(2026, 3, 30), d(2026, 4, 2));
      expect(all.map((e) => e.state.paid.minor ~/ 100), [600, 600, 300, 0]);
    });
  });

  group('garage', () {
    test('pause removes unpaid days; waive keeps them as forgiven', () async {
      await assign(pay: const JamaPay(amount: Money.taka(600)));
      await fx.jama.generate(d(2026, 4, 10));
      await fx.jama.collect(
        assignmentId: assignment,
        amount: const Money.taka(600),
        day: d(2026, 4, 10),
        today: d(2026, 4, 10),
      );
      await fx.jama.startGarage(
        vehicleId: vehicle,
        start: d(2026, 4, 5),
        end: d(2026, 4, 8),
        mode: GarageMode.pause,
      );
      final all = await entries(d(2026, 4, 1), d(2026, 4, 10));
      expect(all.map((e) => e.state.day.day), [1, 2, 3, 4, 9, 10]);
      expect(
        await fx.jama.bakiForDriver(driver, d(2026, 4, 10)),
        const Money.taka(3000),
      );
    });

    test('future days inside an open garage period follow its mode', () async {
      await assign(pay: const JamaPay(amount: Money.taka(600)));
      await fx.jama.startGarage(
        vehicleId: vehicle,
        start: d(2026, 4, 3),
        mode: GarageMode.waive,
      );
      await fx.jama.generate(d(2026, 4, 6));
      final all = await entries(d(2026, 4, 1), d(2026, 4, 6));
      expect(all.map((e) => e.state.status), [
        JamaStatus.unpaid,
        JamaStatus.unpaid,
        JamaStatus.waived,
        JamaStatus.waived,
        JamaStatus.waived,
        JamaStatus.waived,
      ]);
    });

    test('ending the garage period lets later days fall due again', () async {
      await assign(pay: const JamaPay(amount: Money.taka(600)));
      final id = await fx.jama.startGarage(
        vehicleId: vehicle,
        start: d(2026, 4, 3),
        mode: GarageMode.pause,
      );
      await fx.jama.endGarage(id, d(2026, 4, 4));
      await fx.jama.generate(d(2026, 4, 6));
      expect(
        (await entries(
          d(2026, 4, 1),
          d(2026, 4, 6),
        )).map((e) => e.state.day.day),
        [1, 2, 5, 6],
      );
    });
  });

  group('deposit', () {
    test('received, refunded, and not over-refunded', () async {
      await assign();
      await fx.jama.addDeposit(
        assignmentId: assignment,
        kind: DepositKind.received,
        amount: const Money.taka(5000),
        day: d(2026, 4, 1),
      );
      await fx.jama.addDeposit(
        assignmentId: assignment,
        kind: DepositKind.deduct,
        amount: const Money.taka(800),
        day: d(2026, 6, 1),
      );
      expect(await fx.jama.depositBalance(assignment), const Money.taka(4200));
      await expectLater(
        fx.jama.addDeposit(
          assignmentId: assignment,
          kind: DepositKind.refund,
          amount: const Money.taka(4300),
          day: d(2026, 6, 2),
        ),
        throwsA(isA<JamaException>()),
      );
      await fx.jama.addDeposit(
        assignmentId: assignment,
        kind: DepositKind.refund,
        amount: const Money.taka(4200),
        day: d(2026, 6, 2),
      );
      expect(await fx.jama.depositBalance(assignment), Money.zero);
    });
  });

  group('report', () {
    test('expected vs collected, rate and defaulters', () async {
      await assign(pay: const JamaPay(amount: Money.taka(600)));
      final rahim = await fx.driver(name: 'Rahim');
      final v2 = await fx.vehicle(name: 'Second', model: BusinessModel.jama);
      final a2 = await fx.assignments.assign(
        vehicleId: v2,
        driverId: rahim,
        payModel: const JamaPay(amount: Money.taka(500)),
        start: d(2026, 4, 1),
      );
      await fx.jama.generate(d(2026, 4, 10));
      await fx.jama.collect(
        assignmentId: assignment,
        amount: const Money.taka(6000),
        day: d(2026, 4, 10),
        today: d(2026, 4, 10),
      );
      await fx.jama.collect(
        assignmentId: a2,
        amount: const Money.taka(2500),
        day: d(2026, 4, 10),
        today: d(2026, 4, 10),
      );
      final r = await fx.jama.report(DayRange.month(2026, 4), d(2026, 4, 10));
      expect(r.expected, const Money.taka(11000));
      expect(r.collected, const Money.taka(8500));
      expect(r.due, const Money.taka(2500));
      expect(r.ratePercent, 77);
      expect(r.defaulters.single.driverName, 'Rahim');
      expect(r.defaulters.single.missedDays, 5);
      expect(r.defaulters.single.oldestDue, d(2026, 4, 6));
    });
  });

  test('owner profit for a jama vehicle: spec §13 = ৳8,200', () async {
    await assign();
    await fx.categories.ensureDefaults();
    await fx.jama.generate(d(2026, 4, 30));
    for (final e in await entries(d(2026, 4, 1), d(2026, 4, 30))) {
      await fx.jama.collect(
        assignmentId: assignment,
        amount: const Money.taka(600),
        day: e.state.day,
        today: e.state.day,
      );
    }
    await fx.expenses.create(
      vehicle,
      ExpenseDraft(
        categoryId: 'default:repair',
        amount: const Money.taka(2400),
        spentAt: DateTime.utc(2026, 4, 12, 6),
      ),
    );
    await fx.expenses.create(
      vehicle,
      ExpenseDraft(
        categoryId: 'default:loan',
        amount: const Money.taka(5000),
        spentAt: DateTime.utc(2026, 4, 5, 6),
      ),
    );

    final dash = await fx.reports.dashboard(
      DayRange.month(2026, 4),
      const ProfitOptions(),
      vehicleId: vehicle,
    );
    expect(dash.summary.grossIncome, const Money.taka(15600));
    expect(dash.summary.netProfit, const Money.taka(8200));
    expect(await fx.rollups.verify(), isEmpty);
  });
}
