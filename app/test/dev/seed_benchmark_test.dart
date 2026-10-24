import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/dev/seed_data.dart';
import 'package:vehicle_khata/features/reports/data/report_service.dart';
import 'package:vehicle_khata/features/reports/data/rollup_service.dart';
import 'package:vehicle_khata/features/reports/domain/profit_engine.dart';

void main() {
  late AppDatabase db;
  final today = DateTime(2026, 10, 24, 12);

  setUp(() async {
    db = AppDatabase.inMemory();
    await seedDemoData(db, today: today);
  });
  tearDown(() => db.close());

  test('seeds five vehicles and a year of activity', () async {
    expect(await db.select(db.vehicles).get(), hasLength(5));
    expect((await db.select(db.dayLogs).get()).length, greaterThan(500));
    expect((await db.select(db.trips).get()).length, greaterThan(300));
    expect((await db.select(db.expenses).get()).length, greaterThan(1000));
    expect((await db.select(db.dailyRollups).get()).length, greaterThan(1000));
  });

  test('the seeded rollups match the source rows', () async {
    expect(await RollupService(db).verify(), isEmpty);
  });

  test('a year of five vehicles reports in under 300 ms', () async {
    final reports = ReportService(db, clock: () => today);
    final year = DayRange(
      CalendarDay.fromDate(today).addDays(-364),
      CalendarDay.fromDate(today),
    );
    const options = ProfitOptions(amortizeFixed: true);
    // Warm up (first call opens statements and caches).
    await reports.dashboard(year, options);

    for (final range in [
      year,
      DayRange.month(2026, 10),
      DayRange(CalendarDay.fromDate(today), CalendarDay.fromDate(today)),
    ]) {
      final sw = Stopwatch()..start();
      final d = await reports.dashboard(range, options);
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(300), reason: '$range');
      expect(d.byVehicle, isNotEmpty);
    }
    final full = await reports.dashboard(year, options);
    expect(full.summary.grossIncome.isPositive, isTrue);
    expect(full.byVehicle, hasLength(5));
  });

  test(
    'refreshing one month after a change stays fast on a full year',
    () async {
      final vehicle = (await db.select(db.vehicles).get()).first;
      final sw = Stopwatch()..start();
      await RollupService(db)
          .refresh(vehicle.id, [CalendarDay.of(2026, 10, 5)]);
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(300));
    },
  );
}
