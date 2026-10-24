import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';

/// A day on which jama falls due.
@immutable
class DueDay {
  const new(this.day, this.expected);

  final CalendarDay day;
  final Money expected;

  @override
  bool operator ==(Object other) =>
      other is DueDay && other.day == day && other.expected == expected;

  @override
  int get hashCode => Object.hash(day, expected);

  @override
  String toString() => 'DueDay(${day.toIso()}, $expected)';
}

/// Days on which [pay] falls due from [start] through [through] (inclusive),
/// ignoring any garage pauses.
///
/// * Daily: every day except the off weekdays.
/// * Weekly: the weekday of [start], every seven days; off weekdays do not
///   apply.
///
/// Pure calendar arithmetic on epoch days, so months of any length and a
/// start in the middle of a month need no special cases.
List<DueDay> scheduledDueDays({
  required JamaPay pay,
  required CalendarDay start,
  required CalendarDay through,
}) {
  if (through.isBefore(start)) return const [];
  final out = <DueDay>[];
  switch (pay.frequency) {
    case JamaFrequency.daily:
      for (var d = start; !d.isAfter(through); d = d.addDays(1)) {
        if (!pay.offWeekdays.contains(d.weekday)) {
          out.add(DueDay(d, pay.amount));
        }
      }
    case JamaFrequency.weekly:
      for (var d = start; !d.isAfter(through); d = d.addDays(7)) {
        out.add(DueDay(d, pay.amount));
      }
  }
  return out;
}

enum JamaStatus {
  /// Fully paid.
  paid,

  /// Some paid, some still owed.
  partial,

  /// Nothing paid and the day has come.
  unpaid,

  /// Forgiven (garage waiver or owner waived it).
  waived,

  /// Not a due day (off-day, paused, or before the start).
  none,
}

@immutable
class JamaEntryState {
  const new({
    required this.day,
    required this.expected,
    required this.waived,
    required this.paid,
  });

  final CalendarDay day;
  final Money expected;
  final Money waived;
  final Money paid;

  /// What is still owed for this day.
  Money get due {
    final d = expected - waived - paid;
    return d.isPositive ? d : Money.zero;
  }

  JamaStatus get status {
    if (!expected.isPositive) return JamaStatus.none;
    if (waived >= expected) return JamaStatus.waived;
    if (due.isZero) return JamaStatus.paid;
    if (paid.isPositive) return JamaStatus.partial;
    return JamaStatus.unpaid;
  }
}

@immutable
class OpenEntry {
  const new(this.id, this.day, this.due);

  final String id;
  final CalendarDay day;
  final Money due;
}

@immutable
class Allocation {
  const new(this.entryId, this.amount);

  final String entryId;
  final Money amount;
}

/// Applies [payment] to the oldest entries first. Never allocates more than
/// an entry owes, nor more than the payment: the allocations always add up to
/// at most [payment], and to exactly the total owed when [payment] covers it.
List<Allocation> allocateOldestFirst(Money payment, List<OpenEntry> entries) {
  final sorted = [...entries]
    ..sort((a, b) {
      final c = a.day.compareTo(b.day);
      return c != 0 ? c : a.id.compareTo(b.id);
    });
  var left = payment;
  final out = <Allocation>[];
  for (final e in sorted) {
    if (!left.isPositive) break;
    if (!e.due.isPositive) continue;
    final take = left < e.due ? left : e.due;
    out.add(Allocation(e.id, take));
    left -= take;
  }
  return out;
}

/// Whether [day] falls in a garage period.
bool isInRange(CalendarDay day, CalendarDay start, CalendarDay? end) =>
    !day.isBefore(start) && (end == null || !day.isAfter(end));

/// Collection rate as a whole percent (rounded half up), 0 when nothing was
/// expected.
int collectionRatePercent(Money collected, Money expected) {
  if (!expected.isPositive) return 0;
  return ((collected.minor * 100 + expected.minor ~/ 2) ~/ expected.minor)
      .clamp(0, 100);
}
