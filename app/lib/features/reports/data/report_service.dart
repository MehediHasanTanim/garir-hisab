import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/reports/domain/profit_engine.dart';

@immutable
class VehicleProfit {
  const new({
    required this.vehicleId,
    required this.nickname,
    required this.summary,
  });

  final String vehicleId;
  final String nickname;
  final ProfitSummary summary;
}

@immutable
class CategoryTotal {
  const new(this.categoryId, this.amount);

  final String categoryId;
  final Money amount;
}

/// Everything the dashboard shows for one period.
@immutable
class Dashboard {
  const new({
    required this.range,
    required this.options,
    required this.days,
    required this.summary,
    required this.byVehicle,
    required this.expenseMix,
  });

  final DayRange range;
  final ProfitOptions options;

  /// One entry per day with any activity or accrual, oldest first (all
  /// vehicles combined).
  final List<DayFacts> days;
  final ProfitSummary summary;

  /// Best net profit first.
  final List<VehicleProfit> byVehicle;

  /// Owner-borne expenses by category, largest first.
  final List<CategoryTotal> expenseMix;
}

/// Reads rollups, adds driver pay that accrues by the day, and turns them into
/// the numbers reports show.
class ReportService {
  new(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Re-runs whenever anything a report depends on changes.
  Stream<Dashboard> watchDashboard(
    DayRange range,
    ProfitOptions options, {
    String? vehicleId,
  }) {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _db.dailyRollups,
            _db.assignments,
            _db.attendanceRecords,
            _db.expenses,
            _db.vehicles,
          },
        )
        .watch()
        .asyncMap((_) => dashboard(range, options, vehicleId: vehicleId));
  }

  Future<Dashboard> dashboard(
    DayRange range,
    ProfitOptions options, {
    String? vehicleId,
  }) async {
    final perVehicle = await _factsByVehicle(range, vehicleId: vehicleId);
    final names = await _vehicleNames();

    final combined = <int, DayFacts>{};
    final vehicles = <VehicleProfit>[];
    perVehicle.forEach((id, facts) {
      for (final f in facts) {
        final prev = combined[f.day.epochDay];
        combined[f.day.epochDay] = prev == null ? f : _merge(prev, f);
      }
      vehicles.add(
        VehicleProfit(
          vehicleId: id,
          nickname: names[id] ?? '',
          summary: summarize(facts, options),
        ),
      );
    });
    vehicles.sort((a, b) => b.summary.netProfit.compareTo(a.summary.netProfit));

    final days = combined.values.toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    return Dashboard(
      range: range,
      options: options,
      days: days,
      summary: summarize(days, options),
      byVehicle: vehicles,
      expenseMix: await _expenseMix(range, vehicleId: vehicleId),
    );
  }

  /// Summary for one day of one vehicle (for the Today card).
  Future<ProfitSummary> daySummary(
    String vehicleId,
    CalendarDay day,
    ProfitOptions options,
  ) async {
    final d = await dashboard(
      DayRange(day, day),
      options,
      vehicleId: vehicleId,
    );
    return d.summary;
  }

  DayFacts _merge(DayFacts a, DayFacts b) => DayFacts(
    day: a.day,
    trips: a.trips + b.trips,
    fare: a.fare + b.fare,
    received: a.received + b.received,
    collection: a.collection + b.collection,
    variableCost: a.variableCost + b.variableCost,
    fixedCost: a.fixedCost + b.fixedCost,
    fixedAmortized: a.fixedAmortized + b.fixedAmortized,
    tripPay: a.tripPay + b.tripPay,
    accrual: a.accrual + b.accrual,
  );

  Future<Map<String, String>> _vehicleNames() async => {
    for (final v in await _db.select(_db.vehicles).get()) v.id: v.nickname,
  };

  Future<Map<String, List<DayFacts>>> _factsByVehicle(
    DayRange range, {
    String? vehicleId,
  }) async {
    final rollups =
        await (_db.select(_db.dailyRollups)..where((t) {
              final inRange = t.day.isBetweenValues(
                range.start.epochDay,
                range.end.epochDay,
              );
              return vehicleId == null
                  ? inRange
                  : inRange & t.vehicleId.equals(vehicleId);
            }))
            .get();
    final accruals = await _accruals(range, vehicleId: vehicleId);

    final byVehicle = <String, Map<int, DayFacts>>{};
    for (final r in rollups) {
      byVehicle.putIfAbsent(r.vehicleId, () => {})[r.day] = DayFacts(
        day: CalendarDay(r.day),
        trips: r.trips,
        fare: Money(r.fareMinor),
        received: Money(r.receivedMinor),
        collection: Money(r.collectionMinor),
        variableCost: Money(r.variableMinor),
        fixedCost: Money(r.fixedMinor),
        fixedAmortized: Money(r.fixedAmortizedMinor),
        tripPay: Money(r.tripPayMinor),
      );
    }
    accruals.forEach((vehicle, perDay) {
      final days = byVehicle.putIfAbsent(vehicle, () => {});
      perDay.forEach((day, amount) {
        if (amount.isZero) return;
        final existing = days[day] ?? DayFacts(day: CalendarDay(day));
        days[day] = existing.copyWith(accrual: existing.accrual + amount);
      });
    });

    return {
      for (final e in byVehicle.entries)
        e.key: (e.value.values.toList()
          ..sort((a, b) => a.day.compareTo(b.day))),
    };
  }

  /// Driver pay that accrues by the day (salary, daily wage), per vehicle and
  /// day, for days up to today.
  Future<Map<String, Map<int, Money>>> _accruals(
    DayRange range, {
    String? vehicleId,
  }) async {
    final today = CalendarDay.fromDate(_clock());
    final rows =
        await (_db.select(_db.assignments)..where((a) {
              var cond =
                  a.deletedAt.isNull() &
                  a.startDay.isSmallerOrEqualValue(range.end.epochDay) &
                  (a.endDay.isNull() |
                      a.endDay.isBiggerOrEqualValue(range.start.epochDay));
              if (vehicleId != null) {
                cond = cond & a.vehicleId.equals(vehicleId);
              }
              return cond;
            }))
            .get();
    if (rows.isEmpty) return {};

    final driverIds = {for (final r in rows) r.driverId};
    final marks = <String, Map<int, AttendanceStatus>>{};
    for (final m
        in await (_db.select(_db.attendanceRecords)..where(
              (t) =>
                  t.driverId.isIn(driverIds) &
                  t.deletedAt.isNull() &
                  t.day.isBetweenValues(
                    range.start.epochDay,
                    range.end.epochDay,
                  ),
            ))
            .get()) {
      marks.putIfAbsent(m.driverId, () => {})[m.day] = m.status;
    }

    final out = <String, Map<int, Money>>{};
    for (final a in rows) {
      final model = PayModel.decode(a.payModelJson);
      final start = a.startDay > range.start.epochDay
          ? a.startDay
          : range.start.epochDay;
      var end = a.endDay == null || a.endDay! > range.end.epochDay
          ? range.end.epochDay
          : a.endDay!;
      if (end > today.epochDay) end = today.epochDay;
      if (start > end) continue;
      final perDay = out.putIfAbsent(a.vehicleId, () => {});
      for (var d = start; d <= end; d++) {
        final amount = dailyAccrual(
          model,
          CalendarDay(d),
          marks[a.driverId]?[d],
        );
        if (amount.isPositive) {
          perDay[d] = (perDay[d] ?? Money.zero) + amount;
        }
      }
    }
    return out;
  }

  Future<List<CategoryTotal>> _expenseMix(
    DayRange range, {
    String? vehicleId,
  }) async {
    final rows = await _db
        .customSelect(
          'SELECT category_id, SUM(amount_minor) AS total FROM expenses '
          'WHERE deleted_at IS NULL AND spent_day BETWEEN ? AND ? '
          "AND (paid_by = 'owner' OR (paid_by = 'driver' AND reimbursable = 1)) "
          '${vehicleId == null ? '' : 'AND vehicle_id = ? '}'
          'GROUP BY category_id ORDER BY total DESC',
          variables: [
            Variable<int>(range.start.epochDay),
            Variable<int>(range.end.epochDay),
            if (vehicleId != null) Variable<String>(vehicleId),
          ],
          readsFrom: {_db.expenses},
        )
        .get();
    return [
      for (final r in rows)
        CategoryTotal(
          r.read<String>('category_id'),
          Money(r.read<int>('total')),
        ),
    ];
  }
}
