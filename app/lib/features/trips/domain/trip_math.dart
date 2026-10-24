import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';

/// The money picture of one trip.
@immutable
class TripProfit {
  const new({
    required this.fare,
    required this.expenses,
    required this.driverPay,
  });

  final Money fare;

  /// Expenses that cost the owner (see [ownerBears]).
  final Money expenses;
  final Money driverPay;

  Money get profit => fare - expenses - driverPay;
}

/// Trip profit = fare − owner-borne expenses − driver pay.
TripProfit tripProfit({
  required Money fare,
  required Iterable<ExpenseDraft> expenses,
  required Money driverPay,
}) => TripProfit(
  fare: fare,
  expenses: expenses.where((e) => e.isOwnerBorne).map((e) => e.amount).sum(),
  driverPay: driverPay,
);

/// What a driver earns from one trip under [model]. Salary and daily-wage
/// drivers earn nothing per trip (they accrue by attendance), and jama drivers
/// are not paid by the owner at all.
///
/// [ownerExpenses] is only used by commission calculated after expenses.
Money tripDriverPay({
  required PayModel? model,
  required Money fare,
  required Money ownerExpenses,
}) {
  Money commission(int rateBps, CommissionBasis basis) {
    var base = fare;
    if (basis == CommissionBasis.afterExpenses) {
      base = fare - ownerExpenses;
      if (base.isNegative) base = Money.zero;
    }
    return base.percentOf(rateBps);
  }

  return switch (model) {
    PerTripPay(:final perTrip) => perTrip,
    CommissionPay(:final rateBps, :final basis) => commission(rateBps, basis),
    MixedPay(:final rateBps, :final basis) => commission(rateBps, basis),
    SalaryPay() || DailyWagePay() || JamaPay() || null => Money.zero,
  };
}
