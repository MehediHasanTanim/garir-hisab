import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/db/app_database.dart';

import '../../generated_migrations/app/generated/schema.dart';
import '../../generated_migrations/app/generated/schema_v1.dart' as v1;
import '../../generated_migrations/app/generated/schema_v2.dart' as v2;

/// Data-preservation tests for real upgrades. The generated
/// `test/generated_migrations/app/migration_test.dart` covers pure schema
/// validation for every version pair.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 -> v2 keeps audit rows and adds an empty vehicles table', () async {
    const row = v1.AuditLogsData(
      id: 'a1',
      ownerId: 'local',
      createdAt: 1000,
      updatedAt: 1000,
      rev: 0,
      dirty: 1,
      entity: 'trip',
      entityId: 't1',
      action: 'create',
      diffJson: '{}',
      at: 1000,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(oldDb.auditLogs, row),
      validateItems: (newDb) async {
        final logs = await newDb.select(newDb.auditLogs).get();
        expect(logs.map((l) => l.id), ['a1']);
        expect(await newDb.select(newDb.vehicles).get(), isEmpty);
      },
    );
  });
}
