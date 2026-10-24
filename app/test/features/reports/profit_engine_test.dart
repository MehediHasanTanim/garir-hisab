import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/settings/app_settings.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/reports/domain/profit_engine.dart';

CalendarDay _d(int day) => CalendarDay.of(2026, 3, day);

void main() {
  group('classifyExpense', () {
    test('trip costs are always variable', () {
      for (final k in [...DefaultCategory.values, null]) {
        expect(classifyExpense(key: k, tripLinked: true), CostKind.variable);
      }
    });

    test('everyday running costs on a vehicle are variable', () {
      for (final k in [
        DefaultCategory.fuel,
        DefaultCategory.toll,
        DefaultCategory.parking,
        DefaultCategory.helper,
        DefaultCategory.police,
        DefaultCategory.food,
      ]) {
        expect(
          classifyExpense(key: k, tripLinked: false),
          CostKind.variable,
          reason: '$k',
        );
      }
    });

    test('ownership costs on a vehicle are fixed, including custom ones', () {
      for (final k in [
        DefaultCategory.repair,
        DefaultCategory.parts,
        DefaultCategory.tyre,
        DefaultCategory.service,
        DefaultCategory.washing,
        DefaultCategory.insurance,
        DefaultCategory.registration,
        DefaultCategory.loan,
        DefaultCategory.other,
        null,
      ]) {
        expect(
          classifyExpense(key: k, tripLinked: false),
          CostKind.fixed,
          reason: '$k',
        );
      }
    });
  });

  group('summarize', () {
    test('CNG day from the spec: 2,800 - gas 600 - other 100 = 2,100', () {
      final s = summarize([
        DayFacts(
          day: _d(5),
          collection: const Money.taka(2800),
          variableCost: const Money.taka(600),
          fixedCost: const Money.taka(100),
        ),
      ], const ProfitOptions());
      expect(s.grossIncome, const Money.taka(2800));
      expect(s.operatingProfit, const Money.taka(2200));
      expect(s.netProfit, const Money.taka(2100));
      expect(s.workingDays, 1);
    });

    test('pickup trip from the spec: 4,500 - 1,400 - 900 = 2,200', () {
      final s = summarize([
        DayFacts(
          day: _d(5),
          trips: 1,
          fare: const Money.taka(4500),
          received: const Money.taka(4500),
          variableCost: const Money.taka(1400),
          tripPay: const Money.taka(900),
        ),
      ], const ProfitOptions());
      expect(s.netProfit, const Money.taka(2200));
      expect(s.profitPerTrip, const Money.taka(2200));
    });

    test('cash counts what was received; accrual counts fares and shows the receivable', () {
      final day = DayFacts(
        day: _d(5),
        trips: 2,
        fare: const Money.taka(10000),
        received: const Money.taka(6000),
        collection: const Money.taka(500),
        variableCost: const Money.taka(1000),
      );
      final cash = summarize([day], const ProfitOptions());
      final accrual = summarize([
        day,
      ], const ProfitOptions(view: ProfitView.accrual));
      expect(cash.grossIncome, const Money.taka(6500));
      expect(cash.netProfit, const Money.taka(5500));
      expect(accrual.grossIncome, const Money.taka(10500));
      expect(accrual.netProfit, const Money.taka(9500));
      expect(cash.receivable, const Money.taka(4000));
      expect(accrual.receivable, const Money.taka(4000));
    });

    test('driver cost is stored trip pay plus daily accrual', () {
      final s = summarize([
        DayFacts(
          day: _d(5),
          collection: const Money.taka(1000),
          tripPay: const Money.taka(100),
          accrual: const Money.taka(300),
        ),
      ], const ProfitOptions());
      expect(s.driverCost, const Money.taka(400));
      expect(s.netProfit, const Money.taka(600));
    });

    test('fixed costs: on the day paid, or spread over the month', () {
      final days = [
        DayFacts(
          day: _d(1),
          collection: const Money.taka(3000),
          fixedCost: const Money.taka(3100),
          fixedAmortized: const Money.taka(100),
        ),
        DayFacts(
          day: _d(2),
          collection: const Money.taka(3000),
          fixedAmortized: const Money.taka(100),
        ),
      ];
      expect(
        summarize(days, const ProfitOptions()).fixedCosts,
        const Money.taka(3100),
      );
      expect(
        summarize(days, const ProfitOptions()).netProfit,
        const Money.taka(2900),
      );
      final amortized = summarize(
        days,
        const ProfitOptions(amortizeFixed: true),
      );
      expect(amortized.fixedCosts, const Money.taka(200));
      expect(amortized.netProfit, const Money.taka(5800));
    });

    test(
      'losses are negative; averages are null with nothing to divide by',
      () {
        final s = summarize([
          DayFacts(day: _d(1), variableCost: const Money.taka(500)),
        ], const ProfitOptions());
        expect(s.netProfit, const Money.taka(-500));
        expect(s.profitPerTrip, isNull);
        expect(s.profitPerWorkingDay, isNull);
        expect(ProfitSummary.empty.netProfit, Money.zero);
      },
    );

    test('profit per working day only counts days that earned', () {
      final s = summarize([
        DayFacts(day: _d(1), collection: const Money.taka(2000)),
        DayFacts(day: _d(2), variableCost: const Money.taka(200)),
        DayFacts(day: _d(3), collection: const Money.taka(1000)),
      ], const ProfitOptions());
      expect(s.workingDays, 2);
      expect(s.profitPerWorkingDay, const Money.taka(1400));
    });

    test('summing days equals summing in any order', () {
      final days = [
        for (var i = 1; i <= 10; i++)
          DayFacts(
            day: _d(i),
            trips: i,
            fare: Money.taka(i * 100),
            received: Money.taka(i * 90),
            variableCost: Money.taka(i * 10),
          ),
      ];
      final a = summarize(days, const ProfitOptions());
      final b = summarize(days.reversed, const ProfitOptions());
      expect(a.netProfit, b.netProfit);
      expect(a.trips, 55);
    });
  });

  group('dailyShare', () {
    test('a month of shares adds up exactly, for every month length', () {
      for (final (y, m) in [(2026, 2), (2028, 2), (2026, 4), (2026, 3)]) {
        final first = CalendarDay.of(y, m, 1);
        var total = Money.zero;
        for (final day in DayRange.month(y, m).days) {
          total += dailyShare(const Money.taka(15000), day);
        }
        expect(total, const Money.taka(15000), reason: '$y-$m');
        expect(first.daysInMonth, DayRange.month(y, m).length);
      }
    });
  });

  group('dailyAccrual', () {
    const salary = SalaryPay(monthly: Money.taka(15500));
    final day = CalendarDay.of(2026, 3, 10); // 31 days -> 500 a day

    test('salary: worked, half, absent, unmarked', () {
      expect(dailyAccrual(salary, day, null), const Money.taka(500));
      expect(
        dailyAccrual(salary, day, AttendanceStatus.present),
        const Money.taka(500),
      );
      expect(
        dailyAccrual(salary, day, AttendanceStatus.halfDay),
        const Money.taka(250),
      );
      expect(dailyAccrual(salary, day, AttendanceStatus.absent), Money.zero);
    });

    test('daily wage: only marked days are paid', () {
      const wage = DailyWagePay(perDay: Money.taka(800));
      expect(dailyAccrual(wage, day, null), Money.zero);
      expect(dailyAccrual(wage, day, AttendanceStatus.absent), Money.zero);
      expect(
        dailyAccrual(wage, day, AttendanceStatus.present),
        const Money.taka(800),
      );
      expect(
        dailyAccrual(wage, day, AttendanceStatus.halfDay),
        const Money.taka(400),
      );
    });

    test('mixed accrues its base salary; others accrue nothing by the day', () {
      const mixed = MixedPay(
        baseMonthly: Money.taka(15500),
        rateBps: 500,
        basis: CommissionBasis.beforeExpenses,
      );
      expect(dailyAccrual(mixed, day, null), const Money.taka(500));
      for (final m in <PayModel?>[
        const PerTripPay(perTrip: Money.taka(250)),
        const CommissionPay(
          rateBps: 2000,
          basis: CommissionBasis.afterExpenses,
        ),
        const JamaPay(amount: Money.taka(600)),
        null,
      ]) {
        expect(
          dailyAccrual(m, day, AttendanceStatus.present),
          Money.zero,
          reason: '$m',
        );
      }
    });
  });
}
