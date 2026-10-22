import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

final _all = <PayModel>[
  const SalaryPay(monthly: Money.taka(15000)),
  const DailyWagePay(perDay: Money.taka(800), halfDayBps: 4000),
  const PerTripPay(perTrip: Money.taka(250)),
  const CommissionPay(rateBps: 2000, basis: CommissionBasis.afterExpenses),
  const JamaPay(
    amount: Money.taka(600),
    frequency: JamaFrequency.weekly,
    offWeekdays: {5, 1},
  ),
  const MixedPay(
    baseMonthly: Money.taka(8000),
    rateBps: 500,
    basis: CommissionBasis.beforeExpenses,
  ),
];

void main() {
  group('JSON', () {
    test('every model round-trips', () {
      for (final m in _all) {
        expect(PayModel.decode(m.encode()), m, reason: '${m.type}');
        expect(PayModel.fromJson(m.toJson()).type, m.type);
      }
    });

    test('is versioned and typed', () {
      final json = const SalaryPay(monthly: Money.taka(1)).toJson();
      expect(json['v'], PayModel.currentVersion);
      expect(json['type'], 'salary');
      expect(json['monthlyMinor'], 100);
    });

    test('off weekdays are stored sorted', () {
      final json = _all[4].toJson();
      expect(json['offWeekdays'], [1, 5]);
    });

    test('rejects malformed or unsupported documents', () {
      for (final bad in [
        'not json',
        '[]',
        '{}',
        '{"v":1}',
        '{"v":1,"type":"nope"}',
        '{"v":99,"type":"salary","monthlyMinor":1}',
        '{"v":1,"type":"salary"}',
        '{"v":1,"type":"salary","monthlyMinor":"5"}',
        '{"v":1,"type":"commission","rateBps":10,"basis":"weird"}',
        '{"v":"1","type":"salary","monthlyMinor":1}',
      ]) {
        expect(
          () => PayModel.decode(bad),
          throwsA(isA<PayModelFormatException>()),
          reason: bad,
        );
      }
    });

    test('equality is structural', () {
      expect(
        const SalaryPay(monthly: Money.taka(5)),
        const SalaryPay(monthly: Money.taka(5)),
      );
      expect(
        const SalaryPay(monthly: Money.taka(5)),
        isNot(const SalaryPay(monthly: Money.taka(6))),
      );
      expect(
        const SalaryPay(monthly: Money.taka(5)),
        isNot(const PerTripPay(perTrip: Money.taka(5))),
      );
    });
  });

  group('validation', () {
    test('valid models have no issues', () {
      for (final m in _all) {
        expect(m.validate(), isEmpty, reason: '${m.type}');
      }
    });

    test('money fields must be positive', () {
      expect(const SalaryPay(monthly: Money.zero).validate(), [
        const PayModelIssue(PayModelField.monthly, PayModelIssueKind.required),
      ]);
      expect(const DailyWagePay(perDay: Money(-1)).validate(), [
        const PayModelIssue(PayModelField.perDay, PayModelIssueKind.required),
      ]);
      expect(const PerTripPay(perTrip: Money.zero).validate(), [
        const PayModelIssue(PayModelField.perTrip, PayModelIssueKind.required),
      ]);
      expect(const JamaPay(amount: Money.zero).validate(), [
        const PayModelIssue(
          PayModelField.jamaAmount,
          PayModelIssueKind.required,
        ),
      ]);
    });

    test('commission rate must be within (0, 100%]', () {
      for (final bad in [0, -5, 10001]) {
        expect(
          CommissionPay(
            rateBps: bad,
            basis: CommissionBasis.beforeExpenses,
          ).validate(),
          [
            const PayModelIssue(
              PayModelField.rate,
              PayModelIssueKind.outOfRange,
            ),
          ],
          reason: '$bad',
        );
      }
      expect(
        const CommissionPay(
          rateBps: 10000,
          basis: CommissionBasis.beforeExpenses,
        ).validate(),
        isEmpty,
      );
    });

    test('half-day rate must be within [0, 100%]', () {
      expect(
        const DailyWagePay(perDay: Money.taka(1), halfDayBps: 0).validate(),
        isEmpty,
      );
      expect(
        const DailyWagePay(perDay: Money.taka(1), halfDayBps: 10001).validate(),
        [
          const PayModelIssue(
            PayModelField.halfDayRate,
            PayModelIssueKind.outOfRange,
          ),
        ],
      );
    });

    test('jama off days must be real weekdays and not every day', () {
      const issue = PayModelIssue(
        PayModelField.offDays,
        PayModelIssueKind.outOfRange,
      );
      expect(
        const JamaPay(amount: Money.taka(1), offWeekdays: {0}).validate(),
        [issue],
      );
      expect(
        const JamaPay(amount: Money.taka(1), offWeekdays: {8}).validate(),
        [issue],
      );
      expect(
        const JamaPay(
          amount: Money.taka(1),
          offWeekdays: {1, 2, 3, 4, 5, 6, 7},
        ).validate(),
        [issue],
      );
    });

    test('mixed reports both problems', () {
      expect(
        const MixedPay(
          baseMonthly: Money.zero,
          rateBps: 0,
          basis: CommissionBasis.beforeExpenses,
        ).validate(),
        hasLength(2),
      );
    });
  });

  group('allowed types per business model', () {
    test('self-driven vehicles have no driver pay', () {
      expect(allowedPayTypes(BusinessModel.self), isEmpty);
    });

    test('each model offers sensible types', () {
      expect(
        allowedPayTypes(BusinessModel.salaried),
        contains(PayModelType.salary),
      );
      expect(allowedPayTypes(BusinessModel.dailyWage), [
        PayModelType.dailyWage,
      ]);
      expect(allowedPayTypes(BusinessModel.jama), [PayModelType.jama]);
      expect(
        allowedPayTypes(BusinessModel.commission),
        contains(PayModelType.commission),
      );
      expect(
        allowedPayTypes(BusinessModel.contract),
        contains(PayModelType.perTrip),
      );
    });

    test('every business model with a driver offers at least one type', () {
      for (final m in BusinessModel.values.where(
        (m) => m != BusinessModel.self,
      )) {
        expect(allowedPayTypes(m), isNotEmpty, reason: '$m');
      }
    });
  });
}
