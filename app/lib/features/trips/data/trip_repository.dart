import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/data/attendance_repository.dart';
import 'package:vehicle_khata/features/expenses/data/expense_mapper.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/reports/data/rollup_service.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';

enum TripError {
  fareRequired,
  receivedTooHigh,
  receivedNegative,
  distanceInvalid,
  driverPayNegative,
  vehicleNotFound,
  driverNotFound,
  categoryNotFound,
  expenseAmountInvalid,
  tripNotFound,
  paymentInvalid,
}

class TripException implements Exception {
  const new(this.error);

  final TripError error;

  @override
  String toString() => 'TripException($error)';
}

@immutable
class TripFilter {
  const new({this.vehicleId, this.range, this.status, this.limit = 30});

  final String? vehicleId;
  final DayRange? range;
  final PaymentStatus? status;
  final int limit;

  TripFilter copyWith({
    String? Function()? vehicleId,
    DayRange? Function()? range,
    PaymentStatus? Function()? status,
    int? limit,
  }) => TripFilter(
    vehicleId: vehicleId == null ? this.vehicleId : vehicleId(),
    range: range == null ? this.range : range(),
    status: status == null ? this.status : status(),
    limit: limit ?? this.limit,
  );

  @override
  bool operator ==(Object other) =>
      other is TripFilter &&
      other.vehicleId == vehicleId &&
      other.range == range &&
      other.status == status &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(vehicleId, range, status, limit);
}

const _ownerExpenseSql = '''
COALESCE((SELECT SUM(e.amount_minor) FROM expenses e
          WHERE e.trip_id = t.id AND e.deleted_at IS NULL
            AND (e.paid_by = 'owner' OR (e.paid_by = 'driver' AND e.reimbursable = 1))), 0)
''';

class TripRepository {
  new(this._db);

  final AppDatabase _db;
  late final RollupService _rollups = RollupService(_db);

  Stream<List<TripSummary>> watch(TripFilter filter) {
    final where = <String>['t.deleted_at IS NULL'];
    final vars = <Variable<Object>>[];
    if (filter.vehicleId != null) {
      where.add('t.vehicle_id = ?');
      vars.add(Variable<String>(filter.vehicleId));
    }
    final range = filter.range;
    if (range != null) {
      where.add('t.trip_day BETWEEN ? AND ?');
      vars
        ..add(Variable<int>(range.start.epochDay))
        ..add(Variable<int>(range.end.epochDay));
    }
    switch (filter.status) {
      case PaymentStatus.paid:
        where.add('t.received_minor >= t.fare_minor');
      case PaymentStatus.unpaid:
        where.add('t.received_minor <= 0');
      case PaymentStatus.partial:
        where.add('t.received_minor > 0 AND t.received_minor < t.fare_minor');
      case null:
        break;
    }
    vars.add(Variable<int>(filter.limit));

    return _db
        .customSelect(
          'SELECT t.*, v.nickname AS vehicle_nickname, d.name AS driver_name, '
          '$_ownerExpenseSql AS owner_expenses '
          'FROM trips t JOIN vehicles v ON v.id = t.vehicle_id '
          'LEFT JOIN drivers d ON d.id = t.driver_id '
          'WHERE ${where.join(' AND ')} '
          'ORDER BY t.started_at DESC, t.id DESC LIMIT ?',
          variables: vars,
          readsFrom: {_db.trips, _db.expenses, _db.vehicles, _db.drivers},
        )
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              TripSummary(
                trip: _tripFromRow(r),
                vehicleNickname: r.read<String>('vehicle_nickname'),
                driverName: r.read<String?>('driver_name'),
                ownerExpenses: Money(r.read<int>('owner_expenses')),
              ),
          ],
        );
  }

  Stream<TripDetail?> watchOne(String id) {
    // Re-read both tables whenever either changes.
    return _db
        .customSelect('SELECT 1', readsFrom: {_db.trips, _db.expenses})
        .watch()
        .asyncMap((_) => get(id));
  }

  /// A trip with its expenses. A plain read (no stream), so it can be awaited
  /// from tests that run in a fake-async zone.
  Future<TripDetail?> get(String id) async {
    final row = await (_db.select(
      _db.trips,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    if (row == null) return null;
    final expenses =
        await (_db.select(_db.expenses)
              ..where((e) => e.tripId.equals(id) & e.deletedAt.isNull())
              ..orderBy([
                (e) => OrderingTerm.asc(e.createdAt),
                (e) => OrderingTerm.asc(e.id),
              ]))
            .get();
    return TripDetail(
      trip: _tripFromData(row),
      expenses: expenses.map(expenseFromRow).toList(),
    );
  }

  Future<String?> lastTripVehicleId() async {
    final row =
        await (_db.select(_db.trips)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.vehicleId;
  }

  Future<String> create(TripDraft draft) {
    return _db.transaction(() async {
      await _validate(draft);
      final id = newId();
      await _db.into(_db.trips).insert(_companion(draft, id: id));
      for (final e in draft.expenses) {
        await _insertExpense(
          e,
          vehicleId: draft.vehicleId,
          tripId: id,
          at: draft.startedAt,
        );
      }
      await _db.logAudit(
        entity: 'trip',
        entityId: id,
        action: 'create',
        diff: {
          'vehicleId': draft.vehicleId,
          'fareMinor': draft.fare.minor,
          'expenses': draft.expenses.length,
        },
      );
      final day = CalendarDay.fromDate(draft.startedAt.toLocal());
      if (draft.driverId != null) {
        await autoMarkPresent(_db, draft.driverId!, day);
      }
      await _rollups.refresh(draft.vehicleId, [day]);
      return id;
    });
  }

  Future<void> update(String id, TripDraft draft) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.trips)
                ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (existing == null) throw const TripException(TripError.tripNotFound);
      await _validate(draft);

      final before = _snapshot(_tripFromData(existing));
      await (_db.update(
        _db.trips,
      )..where((t) => t.id.equals(id))).write(_companion(draft));
      await _db.touch(_db.trips, id);

      final current = await (_db.select(
        _db.expenses,
      )..where((e) => e.tripId.equals(id) & e.deletedAt.isNull())).get();
      final keep = {
        for (final e in draft.expenses)
          if (e.id != null) e.id!,
      };
      for (final row in current.where((r) => !keep.contains(r.id))) {
        await _db.softDelete(_db.expenses, row.id);
        await _db.logAudit(
          entity: 'expense',
          entityId: row.id,
          action: 'delete',
          diff: {'tripId': id},
        );
      }
      final byId = {for (final r in current) r.id: r};
      for (final e in draft.expenses) {
        final row = e.id == null ? null : byId[e.id];
        if (row == null) {
          await _insertExpense(
            e,
            vehicleId: draft.vehicleId,
            tripId: id,
            at: draft.startedAt,
          );
        } else {
          await _updateExpense(
            row,
            e,
            vehicleId: draft.vehicleId,
            at: draft.startedAt,
          );
        }
      }

      await _db.logAudit(
        entity: 'trip',
        entityId: id,
        action: 'update',
        diff: diffFields(before, _snapshot(_tripFromDraft(id, draft))),
      );
      final day = CalendarDay.fromDate(draft.startedAt.toLocal());
      if (draft.driverId != null) {
        await autoMarkPresent(_db, draft.driverId!, day);
      }
      await _rollups.refresh(draft.vehicleId, [day]);
      await _rollups.refresh(existing.vehicleId, [
        CalendarDay(existing.tripDay),
      ]);
    });
  }

  Future<void> delete(String id) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.trips)
                ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (existing == null) throw const TripException(TripError.tripNotFound);
      final expenses = await (_db.select(
        _db.expenses,
      )..where((e) => e.tripId.equals(id) & e.deletedAt.isNull())).get();
      for (final e in expenses) {
        await _db.softDelete(_db.expenses, e.id);
      }
      await _db.softDelete(_db.trips, id);
      await _db.logAudit(
        entity: 'trip',
        entityId: id,
        action: 'delete',
        diff: {'fareMinor': existing.fareMinor, 'expenses': expenses.length},
      );
      await _rollups.refresh(existing.vehicleId, [
        CalendarDay(existing.tripDay),
      ]);
    });
  }

  /// Adds money received for the trip. The amount must be positive and no more
  /// than what is still due.
  Future<void> recordPayment(String tripId, Money amount) {
    return _db.transaction(() async {
      final row =
          await (_db.select(_db.trips)
                ..where((t) => t.id.equals(tripId) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (row == null) throw const TripException(TripError.tripNotFound);
      final due = Money(row.fareMinor - row.receivedMinor);
      if (!amount.isPositive || amount > due) {
        throw const TripException(TripError.paymentInvalid);
      }
      await (_db.update(_db.trips)..where((t) => t.id.equals(tripId))).write(
        TripsCompanion(receivedMinor: Value(row.receivedMinor + amount.minor)),
      );
      await _db.touch(_db.trips, tripId);
      await _db.logAudit(
        entity: 'trip',
        entityId: tripId,
        action: 'payment',
        diff: {'amountMinor': amount.minor},
      );
      await _rollups.refresh(row.vehicleId, [CalendarDay(row.tripDay)]);
    });
  }

  /// Places used on earlier trips that start with [prefix], most used first.
  Future<List<String>> suggestPlaces(String prefix, {int limit = 8}) async {
    final text = prefix.trim().toLowerCase();
    final like =
        '${text.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    final rows = await _db
        .customSelect(
          'SELECT MIN(place) AS place, COUNT(*) AS n FROM ( '
          'SELECT from_place AS place FROM trips WHERE deleted_at IS NULL AND from_place IS NOT NULL '
          'UNION ALL '
          'SELECT to_place AS place FROM trips WHERE deleted_at IS NULL AND to_place IS NOT NULL '
          r") WHERE lower(place) LIKE ? ESCAPE '\' "
          'GROUP BY lower(place) ORDER BY n DESC, place ASC LIMIT ?',
          variables: [Variable<String>(like), Variable<int>(limit)],
          readsFrom: {_db.trips},
        )
        .get();
    return [for (final r in rows) r.read<String>('place')];
  }

  /// A driver's trips on one vehicle over [range], for pay calculation.
  Future<DriverTripTotals> totalsForDriver({
    required String driverId,
    required String vehicleId,
    required DayRange range,
  }) async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS n, COALESCE(SUM(t.fare_minor), 0) AS fare, '
          'COALESCE(SUM(t.driver_pay_minor), 0) AS pay, '
          'COALESCE(SUM($_ownerExpenseSql), 0) AS exp '
          'FROM trips t WHERE t.deleted_at IS NULL AND t.driver_id = ? '
          'AND t.vehicle_id = ? AND t.trip_day BETWEEN ? AND ?',
          variables: [
            Variable<String>(driverId),
            Variable<String>(vehicleId),
            Variable<int>(range.start.epochDay),
            Variable<int>(range.end.epochDay),
          ],
          readsFrom: {_db.trips, _db.expenses},
        )
        .getSingle();
    return DriverTripTotals(
      count: row.read<int>('n'),
      fare: Money(row.read<int>('fare')),
      ownerExpenses: Money(row.read<int>('exp')),
      driverPay: Money(row.read<int>('pay')),
    );
  }

  // ---- internals ----------------------------------------------------------

  Future<void> _validate(TripDraft d) async {
    if (!d.fare.isPositive) {
      throw const TripException(TripError.fareRequired);
    }
    if (d.received.isNegative) {
      throw const TripException(TripError.receivedNegative);
    }
    if (d.received > d.fare) {
      throw const TripException(TripError.receivedTooHigh);
    }
    if (d.distanceM != null && d.distanceM! < 0) {
      throw const TripException(TripError.distanceInvalid);
    }
    if (d.driverPay.isNegative) {
      throw const TripException(TripError.driverPayNegative);
    }
    final vehicle =
        await (_db.select(_db.vehicles)
              ..where((t) => t.id.equals(d.vehicleId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (vehicle == null) throw const TripException(TripError.vehicleNotFound);
    if (d.driverId != null) {
      final driver =
          await (_db.select(_db.drivers)
                ..where((t) => t.id.equals(d.driverId!) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (driver == null) throw const TripException(TripError.driverNotFound);
    }
    for (final e in d.expenses) {
      if (!e.amount.isPositive) {
        throw const TripException(TripError.expenseAmountInvalid);
      }
      final category =
          await (_db.select(
                _db.expenseCategories,
              )..where((t) => t.id.equals(e.categoryId) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (category == null) {
        throw const TripException(TripError.categoryNotFound);
      }
    }
  }

  TripsCompanion _companion(TripDraft d, {String? id}) {
    final local = d.startedAt.toLocal();
    return TripsCompanion(
      id: id == null ? const Value.absent() : Value(id),
      vehicleId: Value(d.vehicleId),
      driverId: Value(d.driverId),
      startedAt: Value(d.startedAt.toUtc().millisecondsSinceEpoch),
      tripDay: Value(CalendarDay.fromDate(local).epochDay),
      fromPlace: Value(_blank(d.fromPlace)),
      toPlace: Value(_blank(d.toPlace)),
      distanceM: Value(d.distanceM),
      fareMinor: Value(d.fare.minor),
      receivedMinor: Value(d.received.minor),
      driverPayMinor: Value(d.driverPay.minor),
      driverPayOverridden: Value(d.driverPayOverridden),
      loadNote: Value(_blank(d.loadNote)),
      note: Value(_blank(d.note)),
      returnOfTripId: Value(d.returnOfTripId),
    );
  }

  Future<void> _insertExpense(
    ExpenseDraft e, {
    required String vehicleId,
    required String tripId,
    required DateTime at,
  }) async {
    final id = newId();
    await _db
        .into(_db.expenses)
        .insert(
          expenseCompanion(
            e,
            vehicleId: vehicleId,
            tripId: tripId,
            at: at,
            id: id,
          ),
        );
    await _db.logAudit(
      entity: 'expense',
      entityId: id,
      action: 'create',
      diff: {
        'tripId': tripId,
        'amountMinor': e.amount.minor,
        'categoryId': e.categoryId,
      },
    );
  }

  Future<void> _updateExpense(
    ExpenseRow row,
    ExpenseDraft e, {
    required String vehicleId,
    required DateTime at,
  }) async {
    final before = expenseSnapshot(expenseFromRow(row));
    await (_db.update(_db.expenses)..where((t) => t.id.equals(row.id))).write(
      expenseCompanion(e, vehicleId: vehicleId, tripId: row.tripId, at: at),
    );
    final after = expenseSnapshot(
      expenseFromRow(row),
      draft: e,
      at: at,
      vehicleId: vehicleId,
    );
    final diff = diffFields(before, after);
    if (diff.isEmpty) return;
    await _db.touch(_db.expenses, row.id);
    await _db.logAudit(
      entity: 'expense',
      entityId: row.id,
      action: 'update',
      diff: diff,
    );
  }

  Map<String, Object?> _snapshot(Trip t) => {
    'vehicleId': t.vehicleId,
    'driverId': t.driverId,
    'startedAt': t.startedAt.toUtc().toIso8601String(),
    'from': t.fromPlace,
    'to': t.toPlace,
    'distanceM': t.distanceM,
    'fareMinor': t.fare.minor,
    'receivedMinor': t.received.minor,
    'driverPayMinor': t.driverPay.minor,
    'driverPayOverridden': t.driverPayOverridden,
    'loadNote': t.loadNote,
    'note': t.note,
  };

  Trip _tripFromDraft(String id, TripDraft d) => Trip(
    id: id,
    vehicleId: d.vehicleId,
    driverId: d.driverId,
    startedAt: d.startedAt,
    day: CalendarDay.fromDate(d.startedAt.toLocal()),
    fromPlace: _blank(d.fromPlace),
    toPlace: _blank(d.toPlace),
    distanceM: d.distanceM,
    fare: d.fare,
    received: d.received,
    driverPay: d.driverPay,
    driverPayOverridden: d.driverPayOverridden,
    loadNote: _blank(d.loadNote),
    note: _blank(d.note),
    returnOfTripId: d.returnOfTripId,
  );

  Trip _tripFromData(TripRow r) => Trip(
    id: r.id,
    vehicleId: r.vehicleId,
    driverId: r.driverId,
    startedAt: DateTime.fromMillisecondsSinceEpoch(r.startedAt, isUtc: true),
    day: CalendarDay(r.tripDay),
    fromPlace: r.fromPlace,
    toPlace: r.toPlace,
    distanceM: r.distanceM,
    fare: Money(r.fareMinor),
    received: Money(r.receivedMinor),
    driverPay: Money(r.driverPayMinor),
    driverPayOverridden: r.driverPayOverridden,
    loadNote: r.loadNote,
    note: r.note,
    returnOfTripId: r.returnOfTripId,
  );

  Trip _tripFromRow(QueryRow r) => Trip(
    id: r.read<String>('id'),
    vehicleId: r.read<String>('vehicle_id'),
    driverId: r.read<String?>('driver_id'),
    startedAt: DateTime.fromMillisecondsSinceEpoch(
      r.read<int>('started_at'),
      isUtc: true,
    ),
    day: CalendarDay(r.read<int>('trip_day')),
    fromPlace: r.read<String?>('from_place'),
    toPlace: r.read<String?>('to_place'),
    distanceM: r.read<int?>('distance_m'),
    fare: Money(r.read<int>('fare_minor')),
    received: Money(r.read<int>('received_minor')),
    driverPay: Money(r.read<int>('driver_pay_minor')),
    driverPayOverridden: r.read<int>('driver_pay_overridden') == 1,
    loadNote: r.read<String?>('load_note'),
    note: r.read<String?>('note'),
    returnOfTripId: r.read<String?>('return_of_trip_id'),
  );

  static String? _blank(String? s) {
    final t = s?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
    return t.isEmpty ? null : t;
  }
}
