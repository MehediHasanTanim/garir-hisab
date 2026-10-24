import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/settings/app_settings.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';

/// Whether a cost depends on how much the vehicle works (variable) or is a
/// cost of owning it (fixed).
enum CostKind { variable, fixed }

/// Everything on a trip, and everyday running costs, are variable; repairs,
/// parts, tyres, service, washing, insurance, registration and loan
/// instalments bought for the vehicle (not for a trip) are fixed. Custom
/// categories bought for the vehicle are fixed.
CostKind classifyExpense({
  required DefaultCategory? key,
  required bool tripLinked,
}) {
  if (tripLinked) return CostKind.variable;
  return switch (key) {
    DefaultCategory.fuel ||
    DefaultCategory.toll ||
    DefaultCategory.parking ||
    DefaultCategory.helper ||
    DefaultCategory.police ||
    DefaultCategory.food => CostKind.variable,
    _ => CostKind.fixed,
  };
}

/// What happened to one vehicle on one day, in poisha.
@immutable
class DayFacts {
  const new({
    required this.day,
    this.trips = 0,
    this.fare = Money.zero,
    this.received = Money.zero,
    this.collection = Money.zero,
    this.variableCost = Money.zero,
    this.fixedCost = Money.zero,
    this.fixedAmortized = Money.zero,
    this.tripPay = Money.zero,
    this.accrual = Money.zero,
  });

  final CalendarDay day;
  final int trips;

  /// Fares of the day's trips (earned) and what has been received of them.
  final Money fare;
  final Money received;

  /// Money collected without trips (a CNG's daily income).
  final Money collection;

  /// Owner-borne running costs, and vehicle costs on the day they were spent.
  final Money variableCost;
  final Money fixedCost;

  /// This day's share of the month's fixed costs (spread evenly).
  final Money fixedAmortized;

  /// Driver pay stored on the day's trips.
  final Money tripPay;

  /// Driver pay that accrues by the day (salary, daily wage).
  final Money accrual;

  Money income(ProfitView view) =>
      (view == ProfitView.cash ? received : fare) + collection;

  DayFacts copyWith({Money? accrual}) => DayFacts(
    day: day,
    trips: trips,
    fare: fare,
    received: received,
    collection: collection,
    variableCost: variableCost,
    fixedCost: fixedCost,
    fixedAmortized: fixedAmortized,
    tripPay: tripPay,
    accrual: accrual ?? this.accrual,
  );
}

@immutable
class ProfitOptions {
  const new({this.view = ProfitView.cash, this.amortizeFixed = false});

  /// Cash counts only money received; accrual counts fares when earned.
  final ProfitView view;

  /// Spread fixed costs evenly over the days of their month instead of
  /// charging them on the day they were paid.
  final bool amortizeFixed;

  @override
  bool operator ==(Object other) =>
      other is ProfitOptions &&
      other.view == view &&
      other.amortizeFixed == amortizeFixed;

  @override
  int get hashCode => Object.hash(view, amortizeFixed);
}

/// The profit picture for a period (feature spec F8).
///
/// ```text
/// gross income     = trip fares (received, or earned) + day collections
/// operating profit = gross income − variable costs − driver cost
/// net profit       = operating profit − fixed costs
/// ```
@immutable
class ProfitSummary {
  const new({
    required this.grossIncome,
    required this.variableCosts,
    required this.driverCost,
    required this.fixedCosts,
    required this.receivable,
    required this.trips,
    required this.workingDays,
  });

  static const empty = ProfitSummary(
    grossIncome: Money.zero,
    variableCosts: Money.zero,
    driverCost: Money.zero,
    fixedCosts: Money.zero,
    receivable: Money.zero,
    trips: 0,
    workingDays: 0,
  );

  final Money grossIncome;
  final Money variableCosts;
  final Money driverCost;
  final Money fixedCosts;

  /// Fares earned but not yet received.
  final Money receivable;
  final int trips;

  /// Days with any income.
  final int workingDays;

  Money get operatingProfit => grossIncome - variableCosts - driverCost;
  Money get netProfit => operatingProfit - fixedCosts;

  /// Net profit per trip (null when there were no trips).
  Money? get profitPerTrip =>
      trips == 0 ? null : netProfit.proportion(1, trips);

  /// Net profit per day that earned something.
  Money? get profitPerWorkingDay =>
      workingDays == 0 ? null : netProfit.proportion(1, workingDays);
}

ProfitSummary summarize(Iterable<DayFacts> days, ProfitOptions options) {
  var gross = Money.zero;
  var variable = Money.zero;
  var driver = Money.zero;
  var fixed = Money.zero;
  var receivable = Money.zero;
  var trips = 0;
  var working = 0;
  for (final d in days) {
    final income = d.income(options.view);
    gross += income;
    variable += d.variableCost;
    driver += d.tripPay + d.accrual;
    fixed += options.amortizeFixed ? d.fixedAmortized : d.fixedCost;
    receivable += d.fare - d.received;
    trips += d.trips;
    if (income.isPositive) working++;
  }
  return ProfitSummary(
    grossIncome: gross,
    variableCosts: variable,
    driverCost: driver,
    fixedCosts: fixed,
    receivable: receivable,
    trips: trips,
    workingDays: working,
  );
}

/// This day's share of a monthly amount, so a full month adds up exactly.
Money dailyShare(Money monthly, CalendarDay day) =>
    monthly.split(day.daysInMonth)[day.day - 1];

/// Driver pay that accrues on [day] under [model]. [status] is the driver's
/// attendance mark for the day, if any.
///
/// * Salary (and the base of mixed pay): the day's share of the month; an
///   absence earns nothing, a half day half. Unmarked counts as worked.
/// * Daily wage: only marked present / half days are paid.
/// * Per-trip, commission and jama accrue nothing by the day (trip pay is
///   stored on trips; jama is rent the driver pays the owner).
Money dailyAccrual(PayModel? model, CalendarDay day, AttendanceStatus? status) {
  Money salary(Money monthly) {
    final share = dailyShare(monthly, day);
    return switch (status) {
      AttendanceStatus.absent => Money.zero,
      AttendanceStatus.halfDay => share.proportion(1, 2),
      AttendanceStatus.present || null => share,
    };
  }

  return switch (model) {
    SalaryPay(:final monthly) => salary(monthly),
    MixedPay(:final baseMonthly) => salary(baseMonthly),
    DailyWagePay(:final perDay, :final halfDayBps) => switch (status) {
      AttendanceStatus.present => perDay,
      AttendanceStatus.halfDay => perDay.percentOf(halfDayBps),
      AttendanceStatus.absent || null => Money.zero,
    },
    PerTripPay() || CommissionPay() || JamaPay() || null => Money.zero,
  };
}
