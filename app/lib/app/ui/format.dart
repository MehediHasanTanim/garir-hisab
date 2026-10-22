import 'package:vehicle_khata/core/money/money_parser.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// `05/03/2026` in the user's numeral style.
String formatDay(NumberFormatter f, CalendarDay d) => f.digits(
  '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}',
);

String monthName(AppLocalizations l, int month) => switch (month) {
  1 => l.month1,
  2 => l.month2,
  3 => l.month3,
  4 => l.month4,
  5 => l.month5,
  6 => l.month6,
  7 => l.month7,
  8 => l.month8,
  9 => l.month9,
  10 => l.month10,
  11 => l.month11,
  _ => l.month12,
};

/// ISO weekday (Mon = 1 .. Sun = 7).
String weekdayShort(AppLocalizations l, int isoWeekday) => switch (isoWeekday) {
  1 => l.wdMon,
  2 => l.wdTue,
  3 => l.wdWed,
  4 => l.wdThu,
  5 => l.wdFri,
  6 => l.wdSat,
  _ => l.wdSun,
};

/// Half-day units as a day count: 61 -> "30.5".
String formatHalfDays(NumberFormatter f, int halfDays) =>
    f.digits(halfDays.isEven ? '${halfDays ~/ 2}' : '${halfDays ~/ 2}.5');

String payTypeName(AppLocalizations l, PayModelType t) => switch (t) {
  PayModelType.salary => l.ptSalary,
  PayModelType.dailyWage => l.ptDailyWage,
  PayModelType.perTrip => l.ptPerTrip,
  PayModelType.commission => l.ptCommission,
  PayModelType.jama => l.ptJama,
  PayModelType.mixed => l.ptMixed,
};

/// One-line description of how a driver is paid.
String payModelSummary(AppLocalizations l, NumberFormatter f, PayModel model) {
  String rate(int bps) => f.digits(MoneyParser.formatBasisPoints(bps));
  return switch (model) {
    SalaryPay(:final monthly) => l.sumSalary(f.money(monthly)),
    DailyWagePay(:final perDay, :final halfDayBps) => l.sumDailyWage(
      f.money(perDay),
      rate(halfDayBps),
    ),
    PerTripPay(:final perTrip) => l.sumPerTrip(f.money(perTrip)),
    CommissionPay(:final rateBps, :final basis) =>
      basis == CommissionBasis.beforeExpenses
          ? l.sumCommissionBefore(rate(rateBps))
          : l.sumCommissionAfter(rate(rateBps)),
    JamaPay(:final amount, :final frequency) =>
      frequency == JamaFrequency.daily
          ? l.sumJamaDaily(f.money(amount))
          : l.sumJamaWeekly(f.money(amount)),
    MixedPay(:final baseMonthly, :final rateBps) => l.sumMixed(
      f.money(baseMonthly),
      rate(rateBps),
    ),
  };
}
