import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/daylog/domain/day_log.dart';
import 'package:vehicle_khata/features/drivers/data/attendance_repository.dart';
import 'package:vehicle_khata/features/reports/data/rollup_service.dart';

enum DayLogError { amountInvalid, belowZero, vehicleNotFound, notFound }

class DayLogException implements Exception {
  const new(this.error);

  final DayLogError error;

  @override
  String toString() => 'DayLogException($error)';
}

class DayLogRepository {
  new(this._db);

  final AppDatabase _db;
  late final RollupService _rollups = RollupService(_db);

  Stream<DayLog?> watch(String vehicleId, CalendarDay day) {
    final q = _db.select(_db.dayLogs)
      ..where(
        (t) =>
            t.vehicleId.equals(vehicleId) &
            t.logDay.equals(day.epochDay) &
            t.deletedAt.isNull(),
      );
    return q.watchSingleOrNull().map((r) => r == null ? null : _toDomain(r));
  }

  Future<DayLog?> get(String vehicleId, CalendarDay day) async {
    final row =
        await (_db.select(_db.dayLogs)..where(
              (t) =>
                  t.vehicleId.equals(vehicleId) &
                  t.logDay.equals(day.epochDay) &
                  t.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// Adds [amount] to the day's collection, creating the log if needed (one
  /// log per vehicle per day, so re-entry merges). A negative amount takes
  /// money off again (undo) but never below zero. Returns the new total.
  Future<Money> addIncome({
    required String vehicleId,
    required CalendarDay day,
    required Money amount,
  }) {
    return _db.transaction(() async {
      if (amount.isZero) throw const DayLogException(DayLogError.amountInvalid);
      await _requireVehicle(vehicleId);

      final existing =
          await (_db.select(_db.dayLogs)..where(
                (t) =>
                    t.vehicleId.equals(vehicleId) &
                    t.logDay.equals(day.epochDay),
              ))
              .getSingleOrNull();
      final before = Money(existing?.collectionMinor ?? 0);
      final after = before + amount;
      if (after.isNegative) {
        throw const DayLogException(DayLogError.belowZero);
      }

      final driverId =
          existing?.driverId ?? await _assignedDriver(vehicleId, day);
      final String id;
      if (existing == null) {
        id = newId();
        await _db
            .into(_db.dayLogs)
            .insert(
              DayLogsCompanion.insert(
                id: Value(id),
                vehicleId: vehicleId,
                logDay: day.epochDay,
                collectionMinor: Value(after.minor),
                driverId: Value(driverId),
              ),
            );
      } else {
        id = existing.id;
        await (_db.update(_db.dayLogs)..where((t) => t.id.equals(id))).write(
          DayLogsCompanion(
            collectionMinor: Value(after.minor),
            driverId: Value(driverId),
            deletedAt: const Value(null),
          ),
        );
        await _db.touch(_db.dayLogs, id);
      }
      await _db.logAudit(
        entity: 'day_log',
        entityId: id,
        action: existing == null ? 'create' : 'income',
        diff: {
          'day': day.toIso(),
          'addedMinor': amount.minor,
          'totalMinor': after.minor,
        },
      );
      if (driverId != null && amount.isPositive) {
        await autoMarkPresent(_db, driverId, day);
      }
      await _rollups.refresh(vehicleId, [day]);
      return after;
    });
  }

  /// Sets the day's details (distance, hours, note) without touching income.
  Future<void> setDetails({
    required String vehicleId,
    required CalendarDay day,
    int? distanceM,
    int? hoursMin,
    String? note,
  }) {
    return _db.transaction(() async {
      final row =
          await (_db.select(_db.dayLogs)..where(
                (t) =>
                    t.vehicleId.equals(vehicleId) &
                    t.logDay.equals(day.epochDay) &
                    t.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (row == null) throw const DayLogException(DayLogError.notFound);
      final cleanNote = note?.trim();
      await (_db.update(_db.dayLogs)..where((t) => t.id.equals(row.id))).write(
        DayLogsCompanion(
          distanceM: Value(distanceM),
          hoursMin: Value(hoursMin),
          note: Value(
            cleanNote == null || cleanNote.isEmpty ? null : cleanNote,
          ),
        ),
      );
      await _db.touch(_db.dayLogs, row.id);
      await _db.logAudit(
        entity: 'day_log',
        entityId: row.id,
        action: 'details',
        diff: {'day': day.toIso()},
      );
    });
  }

  Future<void> _requireVehicle(String vehicleId) async {
    final v =
        await (_db.select(_db.vehicles)
              ..where((t) => t.id.equals(vehicleId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (v == null) throw const DayLogException(DayLogError.vehicleNotFound);
  }

  /// The driver assigned to the vehicle on [day], if any.
  Future<String?> _assignedDriver(String vehicleId, CalendarDay day) async {
    final row =
        await (_db.select(_db.assignments)
              ..where(
                (a) =>
                    a.vehicleId.equals(vehicleId) &
                    a.deletedAt.isNull() &
                    a.startDay.isSmallerOrEqualValue(day.epochDay) &
                    (a.endDay.isNull() |
                        a.endDay.isBiggerOrEqualValue(day.epochDay)),
              )
              ..limit(1))
            .getSingleOrNull();
    return row?.driverId;
  }

  DayLog _toDomain(DayLogRow r) => DayLog(
    id: r.id,
    vehicleId: r.vehicleId,
    day: CalendarDay(r.logDay),
    collection: Money(r.collectionMinor),
    driverId: r.driverId,
    distanceM: r.distanceM,
    hoursMin: r.hoursMin,
    note: r.note,
  );
}
