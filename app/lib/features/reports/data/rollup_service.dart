// RollupCalc is filled in field by field and then only compared, so value
// equality on a mutable class is intended.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/reports/domain/profit_engine.dart';

/// One day's totals as stored in `daily_rollups`.
class RollupCalc {
  int trips = 0;
  int fare = 0;
  int received = 0;
  int collection = 0;
  int variable = 0;
  int fixed = 0;
  int fixedAmortized = 0;
  int tripPay = 0;

  bool get isEmpty =>
      trips == 0 &&
      fare == 0 &&
      received == 0 &&
      collection == 0 &&
      variable == 0 &&
      fixed == 0 &&
      fixedAmortized == 0 &&
      tripPay == 0;

  @override
  bool operator ==(Object other) =>
      other is RollupCalc &&
      other.trips == trips &&
      other.fare == fare &&
      other.received == received &&
      other.collection == collection &&
      other.variable == variable &&
      other.fixed == fixed &&
      other.fixedAmortized == fixedAmortized &&
      other.tripPay == tripPay;

  @override
  int get hashCode => Object.hash(
    trips,
    fare,
    received,
    collection,
    variable,
    fixed,
    fixedAmortized,
    tripPay,
  );

  @override
  String toString() =>
      'trips=$trips fare=$fare recv=$received coll=$collection var=$variable '
      'fixed=$fixed amort=$fixedAmortized pay=$tripPay';
}

/// Keeps `daily_rollups` in step with trips, day logs and expenses.
///
/// Repositories call [refresh] inside the transaction that changed the source
/// data, so a rollup is never out of date. Each refresh recomputes the whole
/// month of the changed day, because fixed costs are spread over the month.
/// [rebuildAll] and [verify] repair and check the table.
class RollupService {
  new(this._db);

  final AppDatabase _db;

  /// Recomputes every month containing one of [days] for [vehicleId].
  Future<void> refresh(String vehicleId, Iterable<CalendarDay> days) async {
    final months = {for (final d in days) (d.year, d.month)};
    for (final (year, month) in months) {
      await _writeMonth(vehicleId, year, month);
    }
  }

  /// Recomputes every rollup from the source tables.
  Future<void> rebuildAll() async {
    await _db.transaction(() async {
      await _db.delete(_db.dailyRollups).go();
      for (final (vehicleId, year, month) in await _activeMonths()) {
        await _writeMonth(vehicleId, year, month);
      }
    });
  }

  /// Compares the stored rollups with a fresh computation. Returns one line
  /// per difference; empty means consistent.
  Future<List<String>> verify() async {
    final problems = <String>[];
    final stored = <(String, int), RollupCalc>{};
    for (final r in await _db.select(_db.dailyRollups).get()) {
      stored[(r.vehicleId, r.day)] = _fromRow(r);
    }
    final fresh = <(String, int), RollupCalc>{};
    for (final (vehicleId, year, month) in await _activeMonths()) {
      (await compute(vehicleId, year, month)).forEach((day, calc) {
        fresh[(vehicleId, day)] = calc;
      });
    }
    for (final key in {...stored.keys, ...fresh.keys}) {
      if (stored[key] != fresh[key]) {
        problems.add(
          '${key.$1} ${CalendarDay(key.$2).toIso()}: '
          'stored ${stored[key]} vs actual ${fresh[key]}',
        );
      }
    }
    return problems;
  }

  Future<Set<(String, int, int)>> _activeMonths() async {
    final rows = await _db.customSelect('''
SELECT vehicle_id, trip_day AS day FROM trips WHERE deleted_at IS NULL
UNION SELECT vehicle_id, log_day FROM day_logs WHERE deleted_at IS NULL
UNION SELECT vehicle_id, spent_day FROM expenses WHERE deleted_at IS NULL
''').get();
    return {
      for (final r in rows)
        (
          r.read<String>('vehicle_id'),
          CalendarDay(r.read<int>('day')).year,
          CalendarDay(r.read<int>('day')).month,
        ),
    };
  }

  Future<void> _writeMonth(String vehicleId, int year, int month) async {
    final range = DayRange.month(year, month);
    final calc = await compute(vehicleId, year, month);
    await (_db.delete(_db.dailyRollups)..where(
          (t) =>
              t.vehicleId.equals(vehicleId) &
              t.day.isBetweenValues(range.start.epochDay, range.end.epochDay),
        ))
        .go();
    if (calc.isEmpty) return;
    await _db.batch((b) {
      calc.forEach((day, c) {
        b.insert(
          _db.dailyRollups,
          DailyRollupsCompanion.insert(
            vehicleId: vehicleId,
            day: day,
            trips: Value(c.trips),
            fareMinor: Value(c.fare),
            receivedMinor: Value(c.received),
            collectionMinor: Value(c.collection),
            variableMinor: Value(c.variable),
            fixedMinor: Value(c.fixed),
            fixedAmortizedMinor: Value(c.fixedAmortized),
            tripPayMinor: Value(c.tripPay),
          ),
        );
      });
    });
  }

  /// The month's non-empty days for one vehicle, from the source tables.
  Future<Map<int, RollupCalc>> compute(
    String vehicleId,
    int year,
    int month,
  ) async {
    final range = DayRange.month(year, month);
    final first = range.start.epochDay;
    final last = range.end.epochDay;
    final out = <int, RollupCalc>{};
    RollupCalc at(int day) => out.putIfAbsent(day, RollupCalc.new);

    final trips =
        await (_db.select(_db.trips)..where(
              (t) =>
                  t.vehicleId.equals(vehicleId) &
                  t.deletedAt.isNull() &
                  t.tripDay.isBetweenValues(first, last),
            ))
            .get();
    for (final t in trips) {
      at(t.tripDay)
        ..trips += 1
        ..fare += t.fareMinor
        ..received += t.receivedMinor
        ..tripPay += t.driverPayMinor;
    }

    final logs =
        await (_db.select(_db.dayLogs)..where(
              (t) =>
                  t.vehicleId.equals(vehicleId) &
                  t.deletedAt.isNull() &
                  t.logDay.isBetweenValues(first, last),
            ))
            .get();
    for (final l in logs) {
      at(l.logDay).collection += l.collectionMinor;
    }

    final keys = {
      for (final c in await _db.select(_db.expenseCategories).get())
        c.id: c.key == null
            ? null
            : DefaultCategory.values.firstWhere((k) => k.name == c.key),
    };
    final expenses =
        await (_db.select(_db.expenses)..where(
              (t) =>
                  t.vehicleId.equals(vehicleId) &
                  t.deletedAt.isNull() &
                  t.spentDay.isBetweenValues(first, last),
            ))
            .get();
    final fixedAmounts = <Money>[];
    for (final e in expenses) {
      if (!ownerBears(e.paidBy, reimbursable: e.reimbursable)) continue;
      final kind = classifyExpense(
        key: keys[e.categoryId],
        tripLinked: e.tripId != null,
      );
      if (kind == CostKind.variable) {
        at(e.spentDay).variable += e.amountMinor;
      } else {
        at(e.spentDay).fixed += e.amountMinor;
        fixedAmounts.add(Money(e.amountMinor));
      }
    }

    // Spread the month's fixed costs evenly over its days.
    final dim = range.length;
    for (final amount in fixedAmounts) {
      final shares = amount.split(dim);
      for (var i = 0; i < dim; i++) {
        if (shares[i].isZero) continue;
        at(first + i).fixedAmortized += shares[i].minor;
      }
    }

    out.removeWhere((_, c) => c.isEmpty);
    return out;
  }

  static RollupCalc _fromRow(DailyRollupRow r) => RollupCalc()
    ..trips = r.trips
    ..fare = r.fareMinor
    ..received = r.receivedMinor
    ..collection = r.collectionMinor
    ..variable = r.variableMinor
    ..fixed = r.fixedMinor
    ..fixedAmortized = r.fixedAmortizedMinor
    ..tripPay = r.tripPayMinor;
}
