import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vehicle_khata/core/db/app_database.steps.dart';
import 'package:vehicle_khata/core/db/database_key_store.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/db/synced_repository.dart';
import 'package:vehicle_khata/core/db/tables.dart';

part 'app_database.g.dart';

QueryExecutor _openEncrypted(File file, String key) {
  return NativeDatabase(
    file,
    // Must be the first statement on the connection.
    setup: (raw) => raw.execute("PRAGMA key = '$key';"),
  );
}

@DriftDatabase(tables: [AuditLogs])
class AppDatabase extends _$AppDatabase with SyncedHelpers {
  new(super.e);

  /// In-memory database for tests.
  new inMemory() : super(NativeDatabase.memory());

  /// Encrypted on-disk database; the key lives in the Android Keystore.
  factory encrypted(DatabaseKeyStore keyStore) {
    return AppDatabase(
      LazyDatabase(() async {
        final key = await keyStore.getOrCreateKey();
        final dir = await getApplicationSupportDirectory();
        return _openEncrypted(File(p.join(dir.path, 'khata.db')), key);
      }),
    );
  }

  /// Encrypted database at an explicit [file] (used by tests).
  new file(File file, {required String key}) : super(_openEncrypted(file, key));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
