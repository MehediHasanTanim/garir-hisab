import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';

class AttendanceRepository {
  new(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$AttendanceRecordsTable, AttendanceRow> _inRange(
    String driverId,
    DayRange range,
  ) => _db.select(_db.attendanceRecords)
    ..where(
      (t) =>
          t.driverId.equals(driverId) &
          t.deletedAt.isNull() &
          t.day.isBetweenValues(range.start.epochDay, range.end.epochDay),
    );

  Stream<Map<CalendarDay, AttendanceStatus>> watchRange(
    String driverId,
    DayRange range,
  ) => _inRange(driverId, range).watch().map(_toMap);

  Future<Map<CalendarDay, AttendanceStatus>> forRange(
    String driverId,
    DayRange range,
  ) async => _toMap(await _inRange(driverId, range).get());

  /// Marks [day]; a null [status] clears the mark.
  Future<void> mark(
    String driverId,
    CalendarDay day,
    AttendanceStatus? status,
  ) {
    return _db.transaction(() async {
      // Include tombstones: (driver, day) is unique, so a cleared day is
      // revived instead of inserted again.
      final existing =
          await (_db.select(_db.attendanceRecords)..where(
                (t) => t.driverId.equals(driverId) & t.day.equals(day.epochDay),
              ))
              .getSingleOrNull();
      final live = existing != null && existing.deletedAt == null;

      if (status == null) {
        if (!live) return;
        await _db.softDelete(_db.attendanceRecords, existing.id);
        await _db.logAudit(
          entity: 'attendance',
          entityId: existing.id,
          action: 'clear',
          diff: {'day': day.toIso(), 'from': existing.status.name},
        );
        return;
      }
      if (live && existing.status == status) return;

      if (existing == null) {
        final id =
            (await _db
                    .into(_db.attendanceRecords)
                    .insertReturning(
                      AttendanceRecordsCompanion.insert(
                        driverId: driverId,
                        day: day.epochDay,
                        status: status,
                      ),
                    ))
                .id;
        await _db.logAudit(
          entity: 'attendance',
          entityId: id,
          action: 'create',
          diff: {'day': day.toIso(), 'to': status.name},
        );
      } else {
        await (_db.update(
          _db.attendanceRecords,
        )..where((t) => t.id.equals(existing.id))).write(
          AttendanceRecordsCompanion(
            status: Value(status),
            deletedAt: const Value(null),
          ),
        );
        await _db.touch(_db.attendanceRecords, existing.id);
        await _db.logAudit(
          entity: 'attendance',
          entityId: existing.id,
          action: 'update',
          diff: {
            'day': day.toIso(),
            'from': live ? existing.status.name : null,
            'to': status.name,
          },
        );
      }
    });
  }

  Map<CalendarDay, AttendanceStatus> _toMap(List<AttendanceRow> rows) => {
    for (final r in rows) CalendarDay(r.day): r.status,
  };
}

/// Marks [driverId] present on [day] when the day has no mark yet (a trip or
/// day log proves they worked). An existing mark, including absent or half
/// day, is never changed. Call inside the transaction that caused it.
Future<void> autoMarkPresent(
  AppDatabase db,
  String driverId,
  CalendarDay day,
) async {
  final existing =
      await (db.select(db.attendanceRecords)..where(
            (t) => t.driverId.equals(driverId) & t.day.equals(day.epochDay),
          ))
          .getSingleOrNull();
  if (existing != null && existing.deletedAt == null) return;

  String id;
  if (existing == null) {
    id =
        (await db
                .into(db.attendanceRecords)
                .insertReturning(
                  AttendanceRecordsCompanion.insert(
                    driverId: driverId,
                    day: day.epochDay,
                    status: AttendanceStatus.present,
                  ),
                ))
            .id;
  } else {
    id = existing.id;
    await (db.update(
      db.attendanceRecords,
    )..where((t) => t.id.equals(id))).write(
      const AttendanceRecordsCompanion(
        status: Value(AttendanceStatus.present),
        deletedAt: Value(null),
      ),
    );
    await db.touch(db.attendanceRecords, id);
  }
  await db.logAudit(
    entity: 'attendance',
    entityId: id,
    action: 'auto',
    diff: {'day': day.toIso(), 'to': 'present'},
  );
}
