import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/settings/app_settings.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/reports/domain/profit_engine.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';

void main() {
  late Fixture f;
  late String vehicleId;
  final march = DayRange.month(2026, 3);
  const cash = ProfitOptions();

  DateTime at(int d) => DateTime(2026, 3, d, 9).toUtc();

  ExpenseDraft exp(
    String cat,
    int taka, {
    DateTime? when,
    PaidBy by = PaidBy.owner,
  }) => ExpenseDraft(
    categoryId: 'default:$cat',
    amount: Money.taka(taka),
    spentAt: when,
    paidBy: by,
  );

  setUp(() async {
    // "Today" is 20 March for accrual purposes.
    f = Fixture(clock: () => DateTime(2026, 3, 20, 12));
    await f.categories.ensureDefaults();
    vehicleId = await f.vehicle(model: BusinessModel.self);
  });
  tearDown(() => f.close());

  test(
    'CNG day end to end: income 2,800, gas 600, other 100 -> 2,100',
    () async {
      final d = day(2026, 3, 5);
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: d,
        amount: const Money.taka(2800),
      );
      await f.expenses.create(vehicleId, exp('fuel', 600, when: at(5)));
      await f.expenses.create(vehicleId, exp('other', 100, when: at(5)));
      final s = await f.reports.daySummary(vehicleId, d, cash);
      expect(s.grossIncome, const Money.taka(2800));
      expect(s.variableCosts, const Money.taka(600));
      expect(s.fixedCosts, const Money.taka(100));
      expect(s.netProfit, const Money.taka(2100));
    },
  );

  test('an empty period is all zeros', () async {
    final d = await f.reports.dashboard(march, cash);
    expect(d.summary.netProfit, Money.zero);
    expect(d.days, isEmpty);
    expect(d.byVehicle, isEmpty);
    expect(d.expenseMix, isEmpty);
  });

  group('trips', () {
    test('fare, expenses and driver pay flow through', () async {
      await f.trips.create(
        TripDraft(
          vehicleId: vehicleId,
          startedAt: at(10),
          fare: const Money.taka(4500),
          received: const Money.taka(4500),
          driverPay: const Money.taka(900),
          expenses: [exp('fuel', 900), exp('toll', 500)],
        ),
      );
      final s = (await f.reports.dashboard(march, cash)).summary;
      expect(s.grossIncome, const Money.taka(4500));
      expect(s.variableCosts, const Money.taka(1400));
      expect(s.driverCost, const Money.taka(900));
      expect(s.netProfit, const Money.taka(2200));
      expect(s.trips, 1);
    });

    test('cash vs accrual and the receivable', () async {
      await f.trips.create(
        TripDraft(
          vehicleId: vehicleId,
          startedAt: at(10),
          fare: const Money.taka(1000),
          received: const Money.taka(300),
          driverPay: Money.zero,
        ),
      );
      final c = (await f.reports.dashboard(march, cash)).summary;
      final a = (await f.reports.dashboard(
        march,
        const ProfitOptions(view: ProfitView.accrual),
      )).summary;
      expect(c.grossIncome, const Money.taka(300));
      expect(a.grossIncome, const Money.taka(1000));
      expect(c.receivable, const Money.taka(700));
    });

    test('periods only include their own days', () async {
      await f.trips.create(
        TripDraftHelper.simple(vehicleId, null, at(3), fare: 100),
      );
      await f.trips.create(
        TripDraftHelper.simple(vehicleId, null, at(12), fare: 200),
      );
      await f.trips.create(
        TripDraftHelper.simple(vehicleId, null, at(25), fare: 400),
      );
      expect(
        (await f.reports.dashboard(
          DayRange(day(2026, 3, 10), day(2026, 3, 20)),
          cash,
        )).summary.grossIncome,
        const Money.taka(200),
      );
      expect(
        (await f.reports.dashboard(march, cash)).summary.grossIncome,
        const Money.taka(700),
      );
    });
  });

  group('fixed costs', () {
    test('charged when paid, or spread over the month', () async {
      await f.expenses.create(vehicleId, exp('insurance', 3100, when: at(5)));
      final asPaid = await f.reports.dashboard(
        DayRange(day(2026, 3, 1), day(2026, 3, 10)),
        cash,
      );
      expect(asPaid.summary.fixedCosts, const Money.taka(3100));
      final spread = await f.reports.dashboard(
        DayRange(day(2026, 3, 1), day(2026, 3, 10)),
        const ProfitOptions(amortizeFixed: true),
      );
      expect(
        spread.summary.fixedCosts,
        const Money.taka(1000),
        reason: '10 of 31 days',
      );
      expect(
        (await f.reports.dashboard(
          march,
          const ProfitOptions(amortizeFixed: true),
        )).summary.fixedCosts,
        const Money.taka(3100),
      );
    });

    test(
      'a day before the expense still carries its share when amortized',
      () async {
        await f.expenses.create(
          vehicleId,
          exp('insurance', 3100, when: at(25)),
        );
        final early = await f.reports.dashboard(
          DayRange(day(2026, 3, 1), day(2026, 3, 1)),
          const ProfitOptions(amortizeFixed: true),
        );
        expect(early.summary.fixedCosts, const Money.taka(100));
        final plain = await f.reports.dashboard(
          DayRange(day(2026, 3, 1), day(2026, 3, 1)),
          cash,
        );
        expect(plain.summary.fixedCosts, Money.zero);
      },
    );
  });

  group('driver pay that accrues by the day', () {
    late String karim;
    setUp(() async {
      vehicleId = await f.vehicle(name: 'Salaried');
      karim = await f.driver();
      await f.assignments.assign(
        vehicleId: vehicleId,
        driverId: karim,
        payModel: const SalaryPay(monthly: Money.taka(15500)),
        start: day(2026, 3, 1),
      );
    });

    test('salary accrues per day up to today only', () async {
      final d = await f.reports.dashboard(march, cash, vehicleId: vehicleId);
      // 1 March .. 20 March at 500 a day.
      expect(d.summary.driverCost, const Money.taka(10000));
      expect(d.summary.netProfit, const Money.taka(-10000));
    });

    test('absences and half days reduce it', () async {
      await f.attendance.mark(karim, day(2026, 3, 2), AttendanceStatus.absent);
      await f.attendance.mark(karim, day(2026, 3, 3), AttendanceStatus.halfDay);
      final d = await f.reports.dashboard(march, cash, vehicleId: vehicleId);
      expect(d.summary.driverCost, const Money.taka(10000 - 500 - 250));
    });

    test('a finished month adds up to the monthly salary', () async {
      final f2 = Fixture(clock: () => DateTime(2026, 5));
      addTearDown(f2.close);
      final v = await f2.vehicle();
      final d = await f2.driver();
      await f2.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: const SalaryPay(monthly: Money.taka(15000)),
        start: day(2026, 1, 1),
      );
      final r = await f2.reports.dashboard(
        DayRange.month(2026, 3),
        cash,
        vehicleId: v,
      );
      expect(r.summary.driverCost, const Money.taka(15000));
    });

    test('only the days of the assignment accrue', () async {
      await f.assignments.end(
        (await f.assignments.activeForDriver(karim)).single.id,
        day(2026, 3, 9),
      );
      final d = await f.reports.dashboard(march, cash, vehicleId: vehicleId);
      expect(d.summary.driverCost, const Money.taka(9 * 500));
    });

    test('daily wage is paid only for marked days; jama and per-trip accrue nothing', () async {
      final wageVehicle = await f.vehicle(
        name: 'Wage',
        model: BusinessModel.dailyWage,
      );
      final rahim = await f.driver(name: 'Rahim');
      await f.assignments.assign(
        vehicleId: wageVehicle,
        driverId: rahim,
        payModel: const DailyWagePay(perDay: Money.taka(800)),
        start: day(2026, 3, 1),
      );
      await f.attendance.mark(rahim, day(2026, 3, 4), AttendanceStatus.present);
      await f.attendance.mark(rahim, day(2026, 3, 5), AttendanceStatus.halfDay);
      expect(
        (await f.reports.dashboard(
          march,
          cash,
          vehicleId: wageVehicle,
        )).summary.driverCost,
        const Money.taka(1200),
      );

      final jamaVehicle = await f.vehicle(
        name: 'Jama',
        model: BusinessModel.jama,
      );
      final jamaDriver = await f.driver(name: 'Jamal');
      await f.assignments.assign(
        vehicleId: jamaVehicle,
        driverId: jamaDriver,
        payModel: const JamaPay(amount: Money.taka(600)),
        start: day(2026, 3, 1),
      );
      expect(
        (await f.reports.dashboard(
          march,
          cash,
          vehicleId: jamaVehicle,
        )).summary.driverCost,
        Money.zero,
      );
    });

    test('trip pay is not counted twice', () async {
      final v = await f.vehicle(name: 'Trips', model: BusinessModel.contract);
      final d = await f.driver(name: 'Tripper');
      await f.assignments.assign(
        vehicleId: v,
        driverId: d,
        payModel: const PerTripPay(perTrip: Money.taka(250)),
        start: day(2026, 3, 1),
      );
      await f.trips.create(
        TripDraft(
          vehicleId: v,
          driverId: d,
          startedAt: at(10),
          fare: const Money.taka(1000),
          received: const Money.taka(1000),
          driverPay: const Money.taka(250),
        ),
      );
      expect(
        (await f.reports.dashboard(
          march,
          cash,
          vehicleId: v,
        )).summary.driverCost,
        const Money.taka(250),
      );
    });
  });

  group('per vehicle and mix', () {
    test('vehicles are ranked by net profit, best first', () async {
      final b = await f.vehicle(name: 'Beta', model: BusinessModel.self);
      final c = await f.vehicle(name: 'Gamma', model: BusinessModel.self);
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: day(2026, 3, 5),
        amount: const Money.taka(1000),
      );
      await f.dayLogs.addIncome(
        vehicleId: b,
        day: day(2026, 3, 5),
        amount: const Money.taka(3000),
      );
      await f.expenses.create(c, exp('fuel', 500, when: at(5)));
      final d = await f.reports.dashboard(march, cash);
      expect(d.byVehicle.map((v) => v.nickname), [
        'Beta',
        'Rahim CNG',
        'Gamma',
      ]);
      expect(d.byVehicle.map((v) => v.summary.netProfit.minor ~/ 100), [
        3000,
        1000,
        -500,
      ]);
      expect(d.summary.netProfit, const Money.taka(3500));
    });

    test('a single vehicle can be asked for', () async {
      final b = await f.vehicle(name: 'Beta', model: BusinessModel.self);
      await f.dayLogs.addIncome(
        vehicleId: vehicleId,
        day: day(2026, 3, 5),
        amount: const Money.taka(1000),
      );
      await f.dayLogs.addIncome(
        vehicleId: b,
        day: day(2026, 3, 5),
        amount: const Money.taka(3000),
      );
      final d = await f.reports.dashboard(march, cash, vehicleId: b);
      expect(d.summary.grossIncome, const Money.taka(3000));
      expect(d.byVehicle, hasLength(1));
    });

    test(
      'expense mix: owner-borne amounts by category, largest first',
      () async {
        await f.expenses.create(vehicleId, exp('fuel', 600, when: at(5)));
        await f.expenses.create(vehicleId, exp('fuel', 400, when: at(6)));
        await f.expenses.create(vehicleId, exp('repair', 700, when: at(7)));
        await f.expenses.create(
          vehicleId,
          exp('toll', 999, when: at(8), by: PaidBy.client),
        );
        await f.expenses.create(
          vehicleId,
          exp('tyre', 50, when: DateTime(2026, 4, 2).toUtc()),
        );
        final mix = (await f.reports.dashboard(march, cash)).expenseMix;
        expect(mix.map((m) => (m.categoryId, m.amount.minor ~/ 100)), [
          ('default:fuel', 1000),
          ('default:repair', 700),
        ]);
      },
    );
  });

  test('days are returned oldest first with all vehicles combined', () async {
    final b = await f.vehicle(name: 'Beta', model: BusinessModel.self);
    await f.dayLogs.addIncome(
      vehicleId: vehicleId,
      day: day(2026, 3, 9),
      amount: const Money.taka(100),
    );
    await f.dayLogs.addIncome(
      vehicleId: vehicleId,
      day: day(2026, 3, 3),
      amount: const Money.taka(200),
    );
    await f.dayLogs.addIncome(
      vehicleId: b,
      day: day(2026, 3, 3),
      amount: const Money.taka(300),
    );
    final d = await f.reports.dashboard(march, cash);
    expect(d.days.map((x) => x.day.day), [3, 9]);
    expect(d.days.first.collection, const Money.taka(500));
  });

  test('the dashboard stream refreshes when data changes', () async {
    final seen = <int>[];
    final sub = f.reports
        .watchDashboard(march, cash)
        .listen((d) => seen.add(d.summary.grossIncome.minor ~/ 100));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await f.dayLogs.addIncome(
      vehicleId: vehicleId,
      day: day(2026, 3, 5),
      amount: const Money.taka(700),
    );
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await sub.cancel();
    expect(seen.first, 0);
    expect(seen.last, 700);
  });
}
