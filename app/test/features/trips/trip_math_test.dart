import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/trips/domain/trip_math.dart';

ExpenseDraft _e(
  int taka, {
  PaidBy by = PaidBy.owner,
  bool reimbursable = false,
}) => ExpenseDraft(
  categoryId: 'default:fuel',
  amount: Money.taka(taka),
  paidBy: by,
  reimbursable: reimbursable,
);

void main() {
  group('who bears an expense', () {
    test('table', () {
      final cases = <(PaidBy, bool, bool)>[
        (PaidBy.owner, false, true),
        (PaidBy.owner, true, true), // flag is meaningless for the owner
        (PaidBy.driver, true, true), // owner will pay the driver back
        (PaidBy.driver, false, false), // the driver's own cost
        (PaidBy.client, false, false),
        (PaidBy.client, true, false),
      ];
      for (final (by, reimb, expected) in cases) {
        expect(
          ownerBears(by, reimbursable: reimb),
          expected,
          reason: '$by $reimb',
        );
      }
    });
  });

  group('trip profit', () {
    test(
      'fare minus owner-borne expenses minus driver pay (spec pickup example)',
      () {
        final p = tripProfit(
          fare: const Money.taka(4500),
          expenses: [_e(900), _e(200), _e(300)],
          driverPay: const Money.taka(900),
        );
        expect(p.expenses, const Money.taka(1400));
        expect(p.profit, const Money.taka(2200));
      },
    );

    test('client-paid and driver-own expenses do not reduce the profit', () {
      final p = tripProfit(
        fare: const Money.taka(5000),
        expenses: [
          _e(1000),
          _e(500, by: PaidBy.client),
          _e(300, by: PaidBy.driver),
          _e(200, by: PaidBy.driver, reimbursable: true),
        ],
        driverPay: Money.zero,
      );
      expect(p.expenses, const Money.taka(1200));
      expect(p.profit, const Money.taka(3800));
    });

    test('a loss is negative', () {
      final p = tripProfit(
        fare: const Money.taka(1000),
        expenses: [_e(1500)],
        driverPay: const Money.taka(200),
      );
      expect(p.profit, const Money.taka(-700));
      expect(p.profit.isNegative, isTrue);
    });

    test('no expenses', () {
      final p = tripProfit(
        fare: const Money.taka(100),
        expenses: const [],
        driverPay: Money.zero,
      );
      expect(p.profit, const Money.taka(100));
    });
  });

  group('driver pay per trip', () {
    const fare = Money.taka(4500);
    const expenses = Money.taka(1400);
    Money pay(PayModel? m) =>
        tripDriverPay(model: m, fare: fare, ownerExpenses: expenses);

    test('per-trip is the fixed amount', () {
      expect(
        pay(const PerTripPay(perTrip: Money.taka(250))),
        const Money.taka(250),
      );
    });

    test('commission before expenses uses the fare', () {
      expect(
        pay(
          const CommissionPay(
            rateBps: 2000,
            basis: CommissionBasis.beforeExpenses,
          ),
        ),
        const Money.taka(900),
      );
    });

    test('commission after expenses uses fare minus expenses', () {
      expect(
        pay(
          const CommissionPay(
            rateBps: 2000,
            basis: CommissionBasis.afterExpenses,
          ),
        ),
        const Money.taka(620), // 20% of 3100
      );
    });

    test('commission after expenses never goes negative', () {
      expect(
        tripDriverPay(
          model: const CommissionPay(
            rateBps: 2000,
            basis: CommissionBasis.afterExpenses,
          ),
          fare: const Money.taka(1000),
          ownerExpenses: const Money.taka(3000),
        ),
        Money.zero,
      );
    });

    test('mixed pays only the commission part per trip', () {
      expect(
        pay(
          const MixedPay(
            baseMonthly: Money.taka(8000),
            rateBps: 500,
            basis: CommissionBasis.beforeExpenses,
          ),
        ),
        const Money.taka(225),
      );
    });

    test(
      'salary, daily wage, jama and no assignment earn nothing per trip',
      () {
        for (final m in <PayModel?>[
          const SalaryPay(monthly: Money.taka(15000)),
          const DailyWagePay(perDay: Money.taka(800)),
          const JamaPay(amount: Money.taka(600)),
          null,
        ]) {
          expect(pay(m), Money.zero, reason: '$m');
        }
      },
    );
  });

  group('payment status', () {
    test('table', () {
      const fare = Money.taka(1000);
      expect(paymentStatus(fare: fare, received: fare), PaymentStatus.paid);
      expect(
        paymentStatus(fare: fare, received: const Money.taka(1200)),
        PaymentStatus.paid,
      );
      expect(
        paymentStatus(fare: fare, received: const Money.taka(1)),
        PaymentStatus.partial,
      );
      expect(
        paymentStatus(fare: fare, received: const Money.taka(999)),
        PaymentStatus.partial,
      );
      expect(
        paymentStatus(fare: fare, received: Money.zero),
        PaymentStatus.unpaid,
      );
    });
  });
}
