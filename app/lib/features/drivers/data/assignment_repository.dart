import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';

enum AssignmentError {
  payModelInvalid,
  payTypeNotAllowed,
  vehicleNotFound,
  driverNotFound,
  driverInactive,
  noDriverForSelfDriven,
  startNotAfterCurrent,
  overlapsHistory,
  endBeforeStart,
  assignmentNotFound,
  alreadyEnded,
}

class AssignmentException implements Exception {
  const new(this.error);

  final AssignmentError error;

  @override
  String toString() => 'AssignmentException($error)';
}

class AssignmentRepository {
  new(this._db);

  final AppDatabase _db;

  /// Every assignment of a vehicle, newest first.
  Stream<List<AssignmentView>> watchForVehicle(String vehicleId) =>
      _views(_db.assignments.vehicleId.equals(vehicleId)).watch().map(_toViews);

  /// Every assignment of a driver, newest first.
  Stream<List<AssignmentView>> watchForDriver(String driverId) =>
      _views(_db.assignments.driverId.equals(driverId)).watch().map(_toViews);

  /// The assignment currently running on [vehicleId], if any.
  Stream<AssignmentView?> watchActiveForVehicle(String vehicleId) => _views(
    _db.assignments.vehicleId.equals(vehicleId) &
        _db.assignments.endDay.isNull(),
  ).watch().map((rows) => rows.isEmpty ? null : _toViews(rows).first);

  Future<Assignment?> get(String id) async {
    final row = await (_db.select(
      _db.assignments,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : _toAssignment(row);
  }

  Future<List<Assignment>> activeForDriver(String driverId) async {
    final rows =
        await (_db.select(_db.assignments)..where(
              (t) =>
                  t.driverId.equals(driverId) &
                  t.endDay.isNull() &
                  t.deletedAt.isNull(),
            ))
            .get();
    return rows.map(_toAssignment).toList();
  }

  /// Puts [driverId] on [vehicleId] from [start]. If the vehicle already has a
  /// driver, that assignment ends the day before [start] (a switch).
  Future<String> assign({
    required String vehicleId,
    required String driverId,
    required PayModel payModel,
    required CalendarDay start,
  }) {
    return _db.transaction(() async {
      if (payModel.validate().isNotEmpty) {
        throw const AssignmentException(AssignmentError.payModelInvalid);
      }
      final vehicle =
          await (_db.select(_db.vehicles)
                ..where((t) => t.id.equals(vehicleId) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (vehicle == null) {
        throw const AssignmentException(AssignmentError.vehicleNotFound);
      }
      final allowed = allowedPayTypes(vehicle.businessModel);
      if (allowed.isEmpty) {
        throw const AssignmentException(AssignmentError.noDriverForSelfDriven);
      }
      if (!allowed.contains(payModel.type)) {
        throw const AssignmentException(AssignmentError.payTypeNotAllowed);
      }
      final driver =
          await (_db.select(_db.drivers)
                ..where((t) => t.id.equals(driverId) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (driver == null) {
        throw const AssignmentException(AssignmentError.driverNotFound);
      }
      if (driver.status != DriverStatus.active) {
        throw const AssignmentException(AssignmentError.driverInactive);
      }

      final current =
          await (_db.select(_db.assignments)..where(
                (t) =>
                    t.vehicleId.equals(vehicleId) &
                    t.endDay.isNull() &
                    t.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (current != null) {
        if (start.epochDay <= current.startDay) {
          throw const AssignmentException(AssignmentError.startNotAfterCurrent);
        }
        await _endRow(current, start.addDays(-1));
      }

      // The new, open-ended assignment must not overlap an earlier ended one.
      final clash =
          await (_db.select(_db.assignments)
                ..where(
                  (t) =>
                      t.vehicleId.equals(vehicleId) &
                      t.deletedAt.isNull() &
                      t.endDay.isNotNull() &
                      t.endDay.isBiggerOrEqualValue(start.epochDay) &
                      (current == null
                          ? const Constant(true)
                          : t.id.equals(current.id).not()),
                )
                ..limit(1))
              .get();
      if (clash.isNotEmpty) {
        throw const AssignmentException(AssignmentError.overlapsHistory);
      }

      final id = newId();
      await _db
          .into(_db.assignments)
          .insert(
            AssignmentsCompanion.insert(
              id: Value(id),
              vehicleId: vehicleId,
              driverId: driverId,
              payModelJson: payModel.encode(),
              startDay: start.epochDay,
              activeVehicleKey: Value(vehicleId),
            ),
          );
      await _db.logAudit(
        entity: 'assignment',
        entityId: id,
        action: 'create',
        diff: {
          'vehicleId': vehicleId,
          'driverId': driverId,
          'payModel': payModel.toJson(),
          'start': start.toIso(),
          if (current != null) 'replaced': current.id,
        },
      );
      return id;
    });
  }

  /// Ends an assignment on [endDay] (inclusive).
  Future<void> end(String assignmentId, CalendarDay endDay) {
    return _db.transaction(() async {
      final row =
          await (_db.select(
                _db.assignments,
              )..where((t) => t.id.equals(assignmentId) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (row == null) {
        throw const AssignmentException(AssignmentError.assignmentNotFound);
      }
      if (row.endDay != null) {
        throw const AssignmentException(AssignmentError.alreadyEnded);
      }
      if (endDay.epochDay < row.startDay) {
        throw const AssignmentException(AssignmentError.endBeforeStart);
      }
      await _endRow(row, endDay);
    });
  }

  /// Ends every running assignment of a driver (e.g. when they leave).
  /// An assignment that started after [endDay] ends on its own start day.
  Future<void> endAllForDriver(String driverId, CalendarDay endDay) {
    return _db.transaction(() async {
      final rows =
          await (_db.select(_db.assignments)..where(
                (t) =>
                    t.driverId.equals(driverId) &
                    t.endDay.isNull() &
                    t.deletedAt.isNull(),
              ))
              .get();
      for (final row in rows) {
        final day = endDay.epochDay < row.startDay
            ? CalendarDay(row.startDay)
            : endDay;
        await _endRow(row, day);
      }
    });
  }

  Future<void> _endRow(AssignmentRow row, CalendarDay endDay) async {
    await (_db.update(
      _db.assignments,
    )..where((t) => t.id.equals(row.id))).write(
      AssignmentsCompanion(
        endDay: Value(endDay.epochDay),
        activeVehicleKey: const Value(null),
      ),
    );
    await _db.touch(_db.assignments, row.id);
    await _db.logAudit(
      entity: 'assignment',
      entityId: row.id,
      action: 'end',
      diff: {'end': endDay.toIso()},
    );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _views(Expression<bool> where) {
    final a = _db.assignments;
    final q =
        _db.select(a).join([
            innerJoin(_db.drivers, _db.drivers.id.equalsExp(a.driverId)),
            innerJoin(_db.vehicles, _db.vehicles.id.equalsExp(a.vehicleId)),
          ])
          ..where(where & a.deletedAt.isNull())
          ..orderBy([OrderingTerm.desc(a.startDay), OrderingTerm.desc(a.id)]);
    return q;
  }

  List<AssignmentView> _toViews(List<TypedResult> rows) => [
    for (final r in rows)
      AssignmentView(
        assignment: _toAssignment(r.readTable(_db.assignments)),
        driverName: r.readTable(_db.drivers).name,
        vehicleNickname: r.readTable(_db.vehicles).nickname,
      ),
  ];

  Assignment _toAssignment(AssignmentRow r) => Assignment(
    id: r.id,
    vehicleId: r.vehicleId,
    driverId: r.driverId,
    payModel: PayModel.decode(r.payModelJson),
    start: CalendarDay(r.startDay),
    end: r.endDay == null ? null : CalendarDay(r.endDay!),
  );
}
