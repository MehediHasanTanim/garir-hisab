import 'package:meta/meta.dart';

/// A calendar date without a time of day (e.g. "attendance on 5 March").
///
/// Stored as days since 1970-01-01, so it is timezone-free and sorts and
/// subtracts as an integer.
@immutable
class CalendarDay implements Comparable<CalendarDay> {
  const new(this.epochDay);

  factory of(int year, int month, int day) => CalendarDay(
    DateTime.utc(year, month, day).millisecondsSinceEpoch ~/ _msPerDay,
  );

  /// The calendar date of [date] as shown on the user's wall clock.
  factory fromDate(DateTime date) =>
      CalendarDay.of(date.year, date.month, date.day);

  factory today([DateTime Function()? clock]) =>
      CalendarDay.fromDate((clock ?? DateTime.now)());

  static const _msPerDay = 86400000;

  final int epochDay;

  DateTime get _utc =>
      DateTime.fromMillisecondsSinceEpoch(epochDay * _msPerDay, isUtc: true);

  int get year => _utc.year;
  int get month => _utc.month;
  int get day => _utc.day;

  /// ISO weekday: Monday = 1 ... Sunday = 7.
  int get weekday => _utc.weekday;

  /// Local-midnight [DateTime] for pickers and display.
  DateTime toDate() => DateTime(year, month, day);

  CalendarDay addDays(int days) => CalendarDay(epochDay + days);

  CalendarDay get firstOfMonth => CalendarDay.of(year, month, 1);

  CalendarDay get lastOfMonth => CalendarDay.of(year, month + 1, 0);

  int get daysInMonth => lastOfMonth.day;

  /// Number of days from this day to [other] (negative if earlier).
  int daysUntil(CalendarDay other) => other.epochDay - epochDay;

  bool isBefore(CalendarDay other) => epochDay < other.epochDay;
  bool isAfter(CalendarDay other) => epochDay > other.epochDay;

  @override
  int compareTo(CalendarDay other) => epochDay.compareTo(other.epochDay);

  @override
  bool operator ==(Object other) =>
      other is CalendarDay && other.epochDay == epochDay;

  @override
  int get hashCode => epochDay.hashCode;

  /// `2026-03-05`.
  String toIso() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  String toString() => 'CalendarDay(${toIso()})';
}

/// An inclusive range of calendar days.
@immutable
class DayRange {
  new(this.start, this.end)
    : assert(!end.isBefore(start), 'end must not be before start');

  factory month(int year, int month) {
    final first = CalendarDay.of(year, month, 1);
    return DayRange(first, first.lastOfMonth);
  }

  final CalendarDay start;
  final CalendarDay end;

  int get length => start.daysUntil(end) + 1;

  bool contains(CalendarDay d) => !d.isBefore(start) && !d.isAfter(end);

  bool overlaps(DayRange other) =>
      !end.isBefore(other.start) && !other.end.isBefore(start);

  /// The part of this range inside [other], or null if they do not overlap.
  DayRange? intersect(DayRange other) {
    if (!overlaps(other)) return null;
    return DayRange(
      start.isAfter(other.start) ? start : other.start,
      end.isBefore(other.end) ? end : other.end,
    );
  }

  Iterable<CalendarDay> get days sync* {
    for (var d = start; !d.isAfter(end); d = d.addDays(1)) {
      yield d;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is DayRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DayRange(${start.toIso()}..${end.toIso()})';
}
