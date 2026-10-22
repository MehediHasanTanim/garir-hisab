import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/db/app_database.dart';

import '../../generated_migrations/app/schema.dart';

/// Schema snapshot + upgrade-path tests. With a single schema version this
/// verifies the live schema matches the committed snapshot; once v2 exists,
/// `testWith` upgrades every older snapshot to the latest.
void main() {
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('current schema matches committed snapshot', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, db.schemaVersion);
    await db.close();
  });

  test('every snapshot upgrades to the latest schema', () async {
    for (final from in GeneratedHelper.versions) {
      final schema = await verifier.schemaAt(from);
      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, db.schemaVersion);
      await db.close();
    }
  });
}
