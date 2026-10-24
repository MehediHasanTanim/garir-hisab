import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/expenses/data/expense_mapper.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/expenses/domain/fuel_efficiency.dart';

enum ExpenseError {
  amountInvalid,
  quantityInvalid,
  odometerInvalid,
  vehicleNotFound,
  categoryNotFound,
  expenseNotFound,
  belongsToTrip,
}

class ExpenseException implements Exception {
  const new(this.error);

  final ExpenseError error;

  @override
  String toString() => 'ExpenseException($error)';
}

/// Vehicle-level expenses (repairs, insurance, fuel bought outside a trip…).
/// Expenses that belong to a trip are managed with the trip.
class ExpenseRepository {
  new(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Newest first.
  Stream<List<Expense>> watchForVehicle(String vehicleId, {int limit = 200}) {
    final q = _db.select(_db.expenses)
      ..where(
        (e) =>
            e.vehicleId.equals(vehicleId) &
            e.tripId.isNull() &
            e.deletedAt.isNull(),
      )
      ..orderBy([
        (e) => OrderingTerm.desc(e.spentAt),
        (e) => OrderingTerm.desc(e.id),
      ])
      ..limit(limit);
    return q.watch().map((rows) => rows.map(expenseFromRow).toList());
  }

  Future<Expense?> get(String id) async {
    final row = await (_db.select(
      _db.expenses,
    )..where((e) => e.id.equals(id) & e.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : expenseFromRow(row);
  }

  Future<String> create(String vehicleId, ExpenseDraft draft) {
    return _db.transaction(() async {
      await _validate(draft, vehicleId: vehicleId);
      final id = newId();
      await _db
          .into(_db.expenses)
          .insert(
            expenseCompanion(
              draft,
              vehicleId: vehicleId,
              tripId: null,
              at: _clock(),
              id: id,
            ),
          );
      await _db.logAudit(
        entity: 'expense',
        entityId: id,
        action: 'create',
        diff: {
          'vehicleId': vehicleId,
          'amountMinor': draft.amount.minor,
          'categoryId': draft.categoryId,
        },
      );
      return id;
    });
  }

  Future<void> update(String id, ExpenseDraft draft) {
    return _db.transaction(() async {
      final row = await _live(id);
      await _validate(draft, vehicleId: row.vehicleId);
      final before = expenseSnapshot(expenseFromRow(row));
      await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
        expenseCompanion(
          draft,
          vehicleId: row.vehicleId,
          tripId: null,
          at: DateTime.fromMillisecondsSinceEpoch(row.spentAt, isUtc: true),
        ),
      );
      await _db.touch(_db.expenses, id);
      await _db.logAudit(
        entity: 'expense',
        entityId: id,
        action: 'update',
        diff: diffFields(
          before,
          expenseSnapshot(
            expenseFromRow(row),
            draft: draft,
            at: DateTime.fromMillisecondsSinceEpoch(row.spentAt, isUtc: true),
          ),
        ),
      );
    });
  }

  Future<void> delete(String id) {
    return _db.transaction(() async {
      final row = await _live(id);
      await _db.softDelete(_db.expenses, id);
      await _db.logAudit(
        entity: 'expense',
        entityId: id,
        action: 'delete',
        diff: {'amountMinor': row.amountMinor},
      );
    });
  }

  /// Every refuelling of [vehicleId] that has both a quantity and an odometer
  /// reading (trip or not), oldest first.
  Future<List<FuelFill>> fuelFills(String vehicleId) async {
    final rows =
        await (_db.select(_db.expenses)
              ..where(
                (e) =>
                    e.vehicleId.equals(vehicleId) &
                    e.categoryId.equals(
                      ExpenseCategory.defaultId(DefaultCategory.fuel),
                    ) &
                    e.deletedAt.isNull() &
                    e.qtyMilli.isNotNull() &
                    e.odometerM.isNotNull(),
              )
              ..orderBy([(e) => OrderingTerm.asc(e.spentAt)]))
            .get();
    return [
      for (final r in rows)
        FuelFill(
          at: DateTime.fromMillisecondsSinceEpoch(r.spentAt, isUtc: true),
          odometerM: r.odometerM!,
          qtyMilli: r.qtyMilli!,
          cost: Money(r.amountMinor),
        ),
    ];
  }

  Future<ExpenseRow> _live(String id) async {
    final row = await (_db.select(
      _db.expenses,
    )..where((e) => e.id.equals(id) & e.deletedAt.isNull())).getSingleOrNull();
    if (row == null) throw const ExpenseException(ExpenseError.expenseNotFound);
    if (row.tripId != null) {
      throw const ExpenseException(ExpenseError.belongsToTrip);
    }
    return row;
  }

  Future<void> _validate(ExpenseDraft d, {required String vehicleId}) async {
    if (!d.amount.isPositive) {
      throw const ExpenseException(ExpenseError.amountInvalid);
    }
    if (d.qtyMilli != null && d.qtyMilli! <= 0) {
      throw const ExpenseException(ExpenseError.quantityInvalid);
    }
    if (d.odometerM != null && d.odometerM! < 0) {
      throw const ExpenseException(ExpenseError.odometerInvalid);
    }
    final vehicle =
        await (_db.select(_db.vehicles)
              ..where((t) => t.id.equals(vehicleId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (vehicle == null) {
      throw const ExpenseException(ExpenseError.vehicleNotFound);
    }
    final category =
        await (_db.select(_db.expenseCategories)
              ..where((t) => t.id.equals(d.categoryId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (category == null) {
      throw const ExpenseException(ExpenseError.categoryNotFound);
    }
  }
}
