import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';

/// Facts about the pay period that the pay model is applied to.
@immutable
class PayInputs {
  const new({
    this.attendance = const {},
    this.tripCount = 0,
    this.totalFare = Money.zero,
    this.totalExpenses = Money.zero,
  });

  /// Explicitly marked days. Days not listed are "unmarked".
  final Map<CalendarDay, AttendanceStatus> attendance;
  final int tripCount;
  final Money totalFare;

  /// Trip expenses, for commission calculated after expenses.
  final Money totalExpenses;
}

enum PayLineKind { salary, wages, tripFees, commission }

@immutable
class PayLine {
  const new(this.kind, this.amount, {this.quantity});

  final PayLineKind kind;
  final Money amount;

  /// Salary: payable half-days. Wages: worked half-days. Trip fees: trips.
  final int? quantity;
}

@immutable
class PayResult {
  const new(this.lines);

  final List<PayLine> lines;

  Money get earned => lines.map((l) => l.amount).sum();
}

/// Applies [model] to [period] and returns what the driver earned.
///
/// Attendance rules:
/// * **Salary** (and the base of Mixed): every day counts as worked unless it
///   is marked absent (lose the day) or half-day (lose half). Unmarked = worked.
/// * **Daily wage**: only days marked present or half-day are paid. Unmarked =
///   not worked.
PayResult calculatePay(PayModel model, DayRange period, PayInputs inputs) {
  return switch (model) {
    SalaryPay(:final monthly) => PayResult([
      _salary(monthly, period, inputs.attendance),
    ]),
    DailyWagePay() => PayResult([_wages(model, period, inputs.attendance)]),
    PerTripPay(:final perTrip) => PayResult([
      PayLine(
        PayLineKind.tripFees,
        perTrip * inputs.tripCount,
        quantity: inputs.tripCount,
      ),
    ]),
    CommissionPay(:final rateBps, :final basis) => PayResult([
      _commission(rateBps, basis, inputs),
    ]),
    JamaPay() => const PayResult([]),
    MixedPay(:final baseMonthly, :final rateBps, :final basis) => PayResult([
      _salary(baseMonthly, period, inputs.attendance),
      _commission(rateBps, basis, inputs),
    ]),
  };
}

PayLine _salary(
  Money monthly,
  DayRange period,
  Map<CalendarDay, AttendanceStatus> attendance,
) {
  var total = Money.zero;
  var payableHalfDays = 0;
  // Pay each calendar month separately: monthly * payable / days-in-month.
  var cursor = period.start;
  while (!cursor.isAfter(period.end)) {
    final monthEnd = cursor.lastOfMonth;
    final segmentEnd = monthEnd.isAfter(period.end) ? period.end : monthEnd;
    final segment = DayRange(cursor, segmentEnd);

    var lostHalfDays = 0;
    for (final day in segment.days) {
      lostHalfDays += switch (attendance[day]) {
        AttendanceStatus.absent => 2,
        AttendanceStatus.halfDay => 1,
        AttendanceStatus.present || null => 0,
      };
    }
    final payable = segment.length * 2 - lostHalfDays;
    payableHalfDays += payable;
    total += monthly.proportion(payable, cursor.daysInMonth * 2);
    cursor = segmentEnd.addDays(1);
  }
  return PayLine(PayLineKind.salary, total, quantity: payableHalfDays);
}

PayLine _wages(
  DailyWagePay model,
  DayRange period,
  Map<CalendarDay, AttendanceStatus> attendance,
) {
  var full = 0;
  var half = 0;
  for (final day in period.days) {
    switch (attendance[day]) {
      case AttendanceStatus.present:
        full++;
      case AttendanceStatus.halfDay:
        half++;
      case AttendanceStatus.absent || null:
        break;
    }
  }
  final amount =
      model.perDay * full + model.perDay.percentOf(model.halfDayBps) * half;
  return PayLine(PayLineKind.wages, amount, quantity: full * 2 + half);
}

PayLine _commission(int rateBps, CommissionBasis basis, PayInputs inputs) {
  var base = inputs.totalFare;
  if (basis == CommissionBasis.afterExpenses) {
    base = inputs.totalFare - inputs.totalExpenses;
    if (base.isNegative) base = Money.zero;
  }
  return PayLine(PayLineKind.commission, base.percentOf(rateBps));
}
