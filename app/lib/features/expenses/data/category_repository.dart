import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';

enum CategoryError { emptyName, duplicateName, notCustom, notFound }

class CategoryException implements Exception {
  const new(this.error);

  final CategoryError error;

  @override
  String toString() => 'CategoryException($error)';
}

/// Expense categories: the built-in set plus the owner's own.
///
/// Built-in categories have fixed ids (`default:<key>`) so devices that sync
/// never create duplicates; they are created on first use. Categories are
/// archived, never deleted, so old expenses keep their label.
class CategoryRepository {
  new(this._db);

  final AppDatabase _db;
  Future<void>? _seeded;

  Future<void> ensureDefaults() => _seeded ??= _seed();

  Future<void> _seed() async {
    await _db.batch((b) {
      for (final key in DefaultCategory.values) {
        b.insert(
          _db.expenseCategories,
          ExpenseCategoriesCompanion.insert(
            id: Value(ExpenseCategory.defaultId(key)),
            key: Value(key.name),
            sortOrder: Value(key.index * 10),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Stream<List<ExpenseCategory>> watch({bool includeArchived = false}) async* {
    await ensureDefaults();
    final q = _db.select(_db.expenseCategories)
      ..where((t) {
        final live = t.deletedAt.isNull();
        return includeArchived ? live : live & t.archived.equals(false);
      })
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.id),
      ]);
    yield* q.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<ExpenseCategory>> all({bool includeArchived = true}) async {
    await ensureDefaults();
    final q = _db.select(_db.expenseCategories)
      ..where((t) {
        final live = t.deletedAt.isNull();
        return includeArchived ? live : live & t.archived.equals(false);
      })
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.id),
      ]);
    return (await q.get()).map(_toDomain).toList();
  }

  Future<ExpenseCategory?> get(String id) async {
    await ensureDefaults();
    final row = await (_db.select(
      _db.expenseCategories,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<String> createCustom(String name) async {
    await ensureDefaults();
    final clean = _clean(name);
    return await _db.transaction(() async {
      await _checkName(clean);
      final next = await (_db.selectOnly(
        _db.expenseCategories,
      )..addColumns([_db.expenseCategories.sortOrder.max()])).getSingle();
      final order =
          (next.read(_db.expenseCategories.sortOrder.max()) ?? 0) + 10;
      final id = newId();
      await _db
          .into(_db.expenseCategories)
          .insert(
            ExpenseCategoriesCompanion.insert(
              id: Value(id),
              name: Value(clean),
              sortOrder: Value(order),
            ),
          );
      await _db.logAudit(
        entity: 'expense_category',
        entityId: id,
        action: 'create',
        diff: {'name': clean},
      );
      return id;
    });
  }

  Future<void> rename(String id, String name) async {
    await ensureDefaults();
    final clean = _clean(name);
    await _db.transaction(() async {
      final row = await _row(id);
      if (row.key != null) {
        throw const CategoryException(CategoryError.notCustom);
      }
      await _checkName(clean, exceptId: id);
      await (_db.update(_db.expenseCategories)..where((t) => t.id.equals(id)))
          .write(ExpenseCategoriesCompanion(name: Value(clean)));
      await _db.touch(_db.expenseCategories, id);
      await _db.logAudit(
        entity: 'expense_category',
        entityId: id,
        action: 'rename',
        diff: {
          'name': {'from': row.name, 'to': clean},
        },
      );
    });
  }

  Future<void> setArchived(String id, {required bool archived}) async {
    await ensureDefaults();
    await _db.transaction(() async {
      await _row(id);
      await (_db.update(_db.expenseCategories)..where((t) => t.id.equals(id)))
          .write(ExpenseCategoriesCompanion(archived: Value(archived)));
      await _db.touch(_db.expenseCategories, id);
      await _db.logAudit(
        entity: 'expense_category',
        entityId: id,
        action: archived ? 'archive' : 'restore',
      );
    });
  }

  Future<ExpenseCategoryRow> _row(String id) async {
    final row = await (_db.select(
      _db.expenseCategories,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    if (row == null) throw const CategoryException(CategoryError.notFound);
    return row;
  }

  Future<void> _checkName(String clean, {String? exceptId}) async {
    if (clean.isEmpty) throw const CategoryException(CategoryError.emptyName);
    final others = await (_db.select(
      _db.expenseCategories,
    )..where((t) => t.deletedAt.isNull() & t.name.isNotNull())).get();
    final taken = others.any(
      (r) => r.id != exceptId && r.name!.toLowerCase() == clean.toLowerCase(),
    );
    if (taken) throw const CategoryException(CategoryError.duplicateName);
  }

  static String _clean(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');

  ExpenseCategory _toDomain(ExpenseCategoryRow r) => ExpenseCategory(
    id: r.id,
    key: r.key == null
        ? null
        : DefaultCategory.values.firstWhere((k) => k.name == r.key),
    name: r.name,
    sortOrder: r.sortOrder,
    archived: r.archived,
  );
}
