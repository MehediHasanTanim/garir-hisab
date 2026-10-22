import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/db/synced_columns.dart';

/// Generic soft-delete / touch helpers for tables using [SyncedColumns].
///
/// Mix into a database or DAO: `with SyncedHelpers<...>`.
mixin SyncedHelpers on GeneratedDatabase {
  /// Marks the row deleted (tombstone), bumps `rev`/`updated_at`, sets dirty.
  /// Returns the number of rows affected.
  Future<int> softDelete<T extends Table, D>(
    TableInfo<T, D> table,
    String id,
  ) => _write(table, id, deleted: true);

  /// Clears the tombstone.
  Future<int> restore<T extends Table, D>(TableInfo<T, D> table, String id) =>
      _write(table, id, deleted: false);

  /// Bumps `rev`/`updated_at` and marks dirty without changing other fields.
  Future<int> touch<T extends Table, D>(TableInfo<T, D> table, String id) =>
      _write(table, id);

  Future<int> _write<T extends Table, D>(
    TableInfo<T, D> table,
    String id, {
    bool? deleted,
  }) {
    final cols = table.asDslTable as SyncedColumns;
    final now = utcNowMs();
    return (update(table)..where((_) => cols.id.equals(id))).write(
      RawValuesInsertable<D>({
        cols.updatedAt.name: Variable<int>(now),
        cols.rev.name: cols.rev + const Constant(1),
        cols.dirty.name: const Constant(true),
        if (deleted != null)
          cols.deletedAt.name: deleted
              ? Variable<int>(now)
              : const Constant<int>(null),
      }),
    );
  }
}

/// Query filter: rows that are not soft-deleted.
extension NotDeleted on SyncedColumns {
  Expression<bool> get isLive => deletedAt.isNull();
}
