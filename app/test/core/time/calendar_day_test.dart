import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';

void main() {
  group('CalendarDay', () {
    test('epoch day round-trips through year/month/day', () {
      expect(CalendarDay.of(1970, 1, 1).epochDay, 0);
      expect(CalendarDay.of(1970, 1, 2).epochDay, 1);
      final d = CalendarDay.of(2026, 10, 22);
      expect((d.year, d.month, d.day), (2026, 10, 22));
      expect(CalendarDay(d.epochDay), d);
    });

    test('ignores time of day and timezone offsets', () {
      expect(
        CalendarDay.fromDate(DateTime(2026, 3, 5, 23, 59, 59)),
        CalendarDay.fromDate(DateTime(2026, 3, 5)),
      );
    });

    test('addDays crosses month and year boundaries', () {
      expect(
        CalendarDay.of(2026, 12, 31).addDays(1),
        CalendarDay.of(2027, 1, 1),
      );
      expect(
        CalendarDay.of(2026, 3, 1).addDays(-1),
        CalendarDay.of(2026, 2, 28),
      );
    });

    test('month lengths including leap years', () {
      expect(CalendarDay.of(2026, 2, 10).daysInMonth, 28);
      expect(CalendarDay.of(2028, 2, 10).daysInMonth, 29);
      expect(CalendarDay.of(2100, 2, 10).daysInMonth, 28);
      expect(CalendarDay.of(2026, 4, 10).daysInMonth, 30);
      expect(CalendarDay.of(2026, 12, 10).daysInMonth, 31);
      expect(
        CalendarDay.of(2026, 12, 10).lastOfMonth,
        CalendarDay.of(2026, 12, 31),
      );
      expect(
        CalendarDay.of(2026, 12, 10).firstOfMonth,
        CalendarDay.of(2026, 12, 1),
      );
    });

    test('ISO weekday (Mon=1 .. Sun=7)', () {
      expect(CalendarDay.of(2026, 10, 19).weekday, DateTime.monday);
      expect(CalendarDay.of(2026, 10, 23).weekday, DateTime.friday);
      expect(CalendarDay.of(2026, 10, 25).weekday, DateTime.sunday);
    });

    test('ordering, daysUntil and ISO text', () {
      final a = CalendarDay.of(2026, 1, 5);
      final b = CalendarDay.of(2026, 1, 9);
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.daysUntil(b), 4);
      expect(b.daysUntil(a), -4);
      expect(a.toIso(), '2026-01-05');
      expect([b, a]..sort(), [a, b]);
    });
  });

  group('DayRange', () {
    test('length is inclusive', () {
      expect(DayRange.month(2026, 2).length, 28);
      expect(
        DayRange(CalendarDay.of(2026, 1, 1), CalendarDay.of(2026, 1, 1)).length,
        1,
      );
    });

    test('contains, overlaps and intersect', () {
      final jan = DayRange.month(2026, 1);
      final mid = DayRange(
        CalendarDay.of(2026, 1, 20),
        CalendarDay.of(2026, 2, 10),
      );
      expect(jan.contains(CalendarDay.of(2026, 1, 31)), isTrue);
      expect(jan.contains(CalendarDay.of(2026, 2, 1)), isFalse);
      expect(jan.overlaps(mid), isTrue);
      expect(
        jan.intersect(mid),
        DayRange(CalendarDay.of(2026, 1, 20), CalendarDay.of(2026, 1, 31)),
      );
      expect(jan.intersect(DayRange.month(2026, 2)), isNull);
    });

    test('adjacent ranges do not overlap', () {
      expect(
        DayRange.month(2026, 1).overlaps(DayRange.month(2026, 2)),
        isFalse,
      );
    });

    test('days iterates every day', () {
      expect(DayRange.month(2026, 2).days.length, 28);
      expect(DayRange.month(2026, 2).days.first, CalendarDay.of(2026, 2, 1));
      expect(DayRange.month(2026, 2).days.last, CalendarDay.of(2026, 2, 28));
    });
  });
}
