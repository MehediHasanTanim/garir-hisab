import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/db/synced_columns.dart';

/// Local record of every mutation (technical design §5.2).
class AuditLogs extends Table with SyncedColumns {
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get diffJson => text().withDefault(const Constant('{}'))();
  IntColumn get at => integer().clientDefault(utcNowMs)();
}
