import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/driver_rules.dart';
import 'package:vehicle_khata/features/drivers/domain/payout_planner.dart';

enum AdvanceError { invalidAmount, driverNotFound, alreadyRecovered }

class AdvanceException implements Exception {
  const new(this.error);

  final AdvanceError error;

  @override
  String toString() => 'AdvanceException($error)';
}

class AdvanceRepository {
  new(this._db);

  final AppDatabase _db;

  // Advances with how much of each a (non-voided) payout has recovered.
  static const _withRecovered = '''
SELECT a.id, a.driver_id, a.amount_minor, a.given_day, a.note,
  COALESCE((SELECT SUM(pa.amount_minor) FROM payout_advance_allocations pa
            WHERE pa.advance_id = a.id AND pa.deleted_at IS NULL), 0) AS recovered
FROM advances a
WHERE a.driver_id = ? AND a.deleted_at IS NULL
ORDER BY a.given_day DESC, a.id DESC
''';

  Selectable<Advance> _query(String driverId) => _db
      .customSelect(
        _withRecovered,
        variables: [Variable<String>(driverId)],
        readsFrom: {_db.advances, _db.payoutAdvanceAllocations},
      )
      .map(
        (row) => Advance(
          id: row.read<String>('id'),
          driverId: row.read<String>('driver_id'),
          amount: Money(row.read<int>('amount_minor')),
          givenOn: CalendarDay(row.read<int>('given_day')),
          recovered: Money(row.read<int>('recovered')),
          note: row.read<String?>('note'),
        ),
      );

  /// Newest first.
  Stream<List<Advance>> watchForDriver(String driverId) =>
      _query(driverId).watch();

  /// Money still owed back by the driver across all advances.
  Stream<Money> watchOutstandingTotal(String driverId) =>
      watchForDriver(driverId).map(
        (list) => list
            .where((a) => a.remaining.isPositive)
            .map((a) => a.remaining)
            .sum(),
      );

  /// Advances with a balance left, for the payout planner.
  Future<List<OutstandingAdvance>> outstanding(String driverId) async {
    final all = await _query(driverId).get();
    return [
      for (final a in all)
        if (a.remaining.isPositive)
          OutstandingAdvance(
            id: a.id,
            givenOn: a.givenOn,
            remaining: a.remaining,
          ),
    ];
  }

  Future<String> give({
    required String driverId,
    required Money amount,
    required CalendarDay day,
    String? note,
  }) {
    return _db.transaction(() async {
      if (!amount.isPositive) {
        throw const AdvanceException(AdvanceError.invalidAmount);
      }
      final driver =
          await (_db.select(_db.drivers)
                ..where((t) => t.id.equals(driverId) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (driver == null || driver.status == DriverStatus.left) {
        throw const AdvanceException(AdvanceError.driverNotFound);
      }
      final id = newId();
      await _db
          .into(_db.advances)
          .insert(
            AdvancesCompanion.insert(
              id: Value(id),
              driverId: driverId,
              amountMinor: amount.minor,
              givenDay: day.epochDay,
              note: Value(DriverRules.blankToNull(note)),
            ),
          );
      await _db.logAudit(
        entity: 'advance',
        entityId: id,
        action: 'create',
        diff: {
          'driverId': driverId,
          'amountMinor': amount.minor,
          'day': day.toIso(),
        },
      );
      return id;
    });
  }

  /// Deletes an advance that has not been recovered by any payout.
  Future<void> remove(String advanceId) {
    return _db.transaction(() async {
      final recovered =
          await (_db.selectOnly(_db.payoutAdvanceAllocations)
                ..addColumns([_db.payoutAdvanceAllocations.amountMinor.sum()])
                ..where(
                  _db.payoutAdvanceAllocations.advanceId.equals(advanceId) &
                      _db.payoutAdvanceAllocations.deletedAt.isNull(),
                ))
              .getSingle();
      final total =
          recovered.read(_db.payoutAdvanceAllocations.amountMinor.sum()) ?? 0;
      if (total > 0) {
        throw const AdvanceException(AdvanceError.alreadyRecovered);
      }
      await _db.softDelete(_db.advances, advanceId);
      await _db.logAudit(
        entity: 'advance',
        entityId: advanceId,
        action: 'delete',
      );
    });
  }
}
