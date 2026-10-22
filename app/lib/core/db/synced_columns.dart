import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/ids.dart';

/// Columns shared by every table that is synced to the server.
mixin SyncedColumns on Table {
  TextColumn get id => text().clientDefault(newId)();

  /// Tenant key. `local` until the user signs in and the data is claimed.
  TextColumn get ownerId => text().withDefault(const Constant('local'))();

  /// Epoch milliseconds, UTC.
  IntColumn get createdAt => integer().clientDefault(utcNowMs)();
  IntColumn get updatedAt => integer().clientDefault(utcNowMs)();

  /// Tombstone; non-null means soft-deleted.
  IntColumn get deletedAt => integer().nullable()();

  /// Local monotonic revision, bumped on every write.
  IntColumn get rev => integer().withDefault(const Constant(0))();

  /// True while the row has changes not yet pushed.
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
