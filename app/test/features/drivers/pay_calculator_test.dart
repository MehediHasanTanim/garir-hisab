import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_calculator.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';

CalendarDay _d(int y, int m, int d) => CalendarDay.of(y, m, d);

Map<CalendarDay, AttendanceStatus> _marks({
  int year = 2026,
  int month = 3,
  List<int> absent = const [],
  List<int> half = const [],
  List<int> present = const [],
}) => {
  for (final d in absent) _d(year, month, d): AttendanceStatus.absent,
  for (final d in half) _d(year, month, d): AttendanceStatus.halfDay,
  for (final d in present) _d(year, month, d): AttendanceStatus.present,
};

void main() {
  final march = DayRange.month(2026, 3); // 31 days

  group('salary', () {
    const salary = SalaryPay(monthly: Money.taka(15000));

    test('table', () {
      final cases = <(String, DayRange, PayInputs, int)>[
        ('full month, unmarked = worked', march, const PayInputs(), 1500000),
        (
          '3 absent days of 31',
          march,
          PayInputs(attendance: _marks(absent: [3, 4, 5])),
          1354839, // 15000 * 56/62
        ),
        (
          '1 half day',
          march,
          PayInputs(attendance: _marks(half: [10])),
          1475806, // 15000 * 61/62
        ),
        (
          'absent + half',
          march,
          PayInputs(
            attendance: _marks(absent: [1], half: [2]),
          ),
          1500000 * 59 ~/ 62 + 1, // 59/62 -> 1427419.35 -> 1427419
        ),
        (
          'first 10 days only',
          DayRange(_d(2026, 3, 1), _d(2026, 3, 10)),
          const PayInputs(),
          483871, // 15000 * 20/62
        ),
        (
          'every day absent',
          march,
          PayInputs(
            attendance: _marks(absent: List.generate(31, (i) => i + 1)),
          ),
          0,
        ),
      ];
      for (final (name, period, inputs, expected) in cases) {
        // Compute the "absent + half" literal precisely below instead of the
        // integer-division hack above.
        if (name == 'absent + half') {
          expect(
            calculatePay(salary, period, inputs).earned,
            const Money(1500000).proportion(59, 62),
            reason: name,
          );
          continue;
        }
        expect(
          calculatePay(salary, period, inputs).earned,
          Money(expected),
          reason: name,
        );
      }
    });

    test('a period spanning two months pays each month by its own length', () {
      final period = DayRange(_d(2026, 2, 20), _d(2026, 3, 10));
      // Feb: 9 days of 28 -> 15000*18/56; Mar: 10 days of 31 -> 15000*20/62.
      expect(
        calculatePay(salary, period, const PayInputs()).earned,
        const Money(482143 + 483871),
      );
    });

    test('absences in each month reduce only that month', () {
      final period = DayRange(_d(2026, 2, 20), _d(2026, 3, 10));
      final inputs = PayInputs(
        attendance: {
          _d(2026, 2, 25): AttendanceStatus.absent,
          _d(2026, 3, 2): AttendanceStatus.absent,
        },
      );
      final expected =
          const Money(1500000).proportion(18 - 2, 56) +
          const Money(1500000).proportion(20 - 2, 62);
      expect(calculatePay(salary, period, inputs).earned, expected);
    });

    test('marks outside the period are ignored', () {
      final inputs = PayInputs(
        attendance: {_d(2026, 4, 1): AttendanceStatus.absent},
      );
      expect(
        calculatePay(salary, march, inputs).earned,
        const Money.taka(15000),
      );
    });

    test(
      'a full calendar month is exactly the monthly salary for any month',
      () {
        for (var m = 1; m <= 12; m++) {
          expect(
            calculatePay(
              salary,
              DayRange.month(2027, m),
              const PayInputs(),
            ).earned,
            const Money.taka(15000),
            reason: 'month $m',
          );
        }
      },
    );

    test('reports payable half-days', () {
      final result = calculatePay(
        salary,
        march,
        PayInputs(
          attendance: _marks(absent: [1], half: [2]),
        ),
      );
      expect(result.lines.single.kind, PayLineKind.salary);
      expect(result.lines.single.quantity, 62 - 2 - 1);
    });
  });

  group('daily wage', () {
    const wage = DailyWagePay(perDay: Money.taka(800));

    test('only marked days are paid; half day pays the half-day rate', () {
      final inputs = PayInputs(
        attendance: _marks(
          present: [1, 2, 3, 4, 5],
          half: [6, 7],
          absent: [8, 9, 10],
        ),
      );
      expect(
        calculatePay(wage, march, inputs).earned,
        const Money.taka(5 * 800 + 2 * 400),
      );
    });

    test('no marks means no pay', () {
      expect(calculatePay(wage, march, const PayInputs()).earned, Money.zero);
    });

    test('custom half-day rate', () {
      const w = DailyWagePay(perDay: Money.taka(800), halfDayBps: 4000);
      final inputs = PayInputs(attendance: _marks(half: [1, 2]));
      expect(calculatePay(w, march, inputs).earned, const Money.taka(640));
    });

    test('days outside the period are not paid', () {
      final period = DayRange(_d(2026, 3, 1), _d(2026, 3, 3));
      final inputs = PayInputs(attendance: _marks(present: [1, 2, 3, 4, 5]));
      expect(calculatePay(wage, period, inputs).earned, const Money.taka(2400));
    });
  });

  group('per trip', () {
    const perTrip = PerTripPay(perTrip: Money.taka(250));

    test('multiplies by the trip count', () {
      expect(
        calculatePay(perTrip, march, const PayInputs(tripCount: 12)).earned,
        const Money.taka(3000),
      );
      expect(
        calculatePay(perTrip, march, const PayInputs()).earned,
        Money.zero,
      );
    });
  });

  group('commission', () {
    test('before expenses uses the full fare', () {
      const c = CommissionPay(
        rateBps: 2000,
        basis: CommissionBasis.beforeExpenses,
      );
      const inputs = PayInputs(
        totalFare: Money.taka(10000),
        totalExpenses: Money.taka(3000),
      );
      expect(calculatePay(c, march, inputs).earned, const Money.taka(2000));
    });

    test('after expenses uses fare minus expenses', () {
      const c = CommissionPay(
        rateBps: 2000,
        basis: CommissionBasis.afterExpenses,
      );
      const inputs = PayInputs(
        totalFare: Money.taka(10000),
        totalExpenses: Money.taka(3000),
      );
      expect(calculatePay(c, march, inputs).earned, const Money.taka(1400));
    });

    test('expenses above the fare never make the commission negative', () {
      const c = CommissionPay(
        rateBps: 2000,
        basis: CommissionBasis.afterExpenses,
      );
      const inputs = PayInputs(
        totalFare: Money.taka(1000),
        totalExpenses: Money.taka(3000),
      );
      expect(calculatePay(c, march, inputs).earned, Money.zero);
    });

    test('fractional rates round to the nearest poisha', () {
      const c = CommissionPay(
        rateBps: 1250,
        basis: CommissionBasis.beforeExpenses,
      );
      const inputs = PayInputs(totalFare: Money(333)); // 41.625 -> 42
      expect(calculatePay(c, march, inputs).earned, const Money(42));
    });
  });

  test('jama drivers earn nothing from the owner', () {
    const jama = JamaPay(amount: Money.taka(600));
    final result = calculatePay(
      jama,
      march,
      PayInputs(
        attendance: _marks(present: [1]),
        tripCount: 5,
        totalFare: const Money.taka(9999),
      ),
    );
    expect(result.lines, isEmpty);
    expect(result.earned, Money.zero);
  });

  group('mixed', () {
    const mixed = MixedPay(
      baseMonthly: Money.taka(8000),
      rateBps: 500,
      basis: CommissionBasis.beforeExpenses,
    );

    test('base salary plus commission, as separate lines', () {
      final result = calculatePay(
        mixed,
        march,
        const PayInputs(totalFare: Money.taka(20000)),
      );
      expect(result.earned, const Money.taka(9000));
      expect(result.lines.map((l) => l.kind), [
        PayLineKind.salary,
        PayLineKind.commission,
      ]);
      expect(result.lines.first.amount, const Money.taka(8000));
      expect(result.lines.last.amount, const Money.taka(1000));
    });

    test('absences reduce only the base', () {
      final result = calculatePay(
        mixed,
        march,
        PayInputs(
          attendance: _marks(
            absent: [
              1,
              2,
              3,
              4,
              5,
              6,
              7,
              8,
              9,
              10,
              11,
              12,
              13,
              14,
              15,
              16,
              17,
              18,
              19,
              20,
              21,
              22,
              23,
              24,
              25,
              26,
              27,
              28,
              29,
              30,
              31,
            ],
          ),
          totalFare: const Money.taka(20000),
        ),
      );
      expect(result.earned, const Money.taka(1000));
    });
  });
}
