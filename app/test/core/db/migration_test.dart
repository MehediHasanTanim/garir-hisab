import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/db/app_database.dart';

import '../../generated_migrations/app/generated/schema.dart';
import '../../generated_migrations/app/generated/schema_v1.dart' as v1;
import '../../generated_migrations/app/generated/schema_v2.dart' as v2;
import '../../generated_migrations/app/generated/schema_v3.dart' as v3;

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

  test(
    'v2 -> v3 keeps vehicles and the new tables enforce their rules',
    () async {
      await verifier.testWithDataIntegrity(
        oldVersion: 2,
        newVersion: 3,
        createOld: v2.DatabaseAtV2.new,
        createNew: v3.DatabaseAtV3.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) => batch.customStatement(
          'INSERT INTO vehicles (id, owner_id, created_at, updated_at, rev, '
          'dirty, nickname, type, fuel_type, business_model, status, '
          "archived) VALUES ('v1', 'local', 1, 1, 0, 1, 'Rahim CNG', 'cng', "
          "'cng', 'salaried', 'active', 0)",
        ),
        validateItems: (newDb) async {
          final vehicles = await newDb
              .customSelect('SELECT nickname FROM vehicles')
              .get();
          expect(vehicles.map((r) => r.read<String>('nickname')), [
            'Rahim CNG',
          ]);
          final drivers = await newDb
              .customSelect('SELECT id FROM drivers')
              .get();
          expect(drivers, isEmpty);

          // The old vehicle can immediately be given a driver...
          await newDb.customStatement(
            'INSERT INTO drivers (id, owner_id, created_at, updated_at, rev, '
            "dirty, name, status) VALUES ('d1', 'local', 1, 1, 0, 1, "
            "'Karim', 'active')",
          );
          Future<void> assign(String id, String key) => newDb.customStatement(
            'INSERT INTO assignments (id, owner_id, created_at, updated_at, '
            'rev, dirty, vehicle_id, driver_id, pay_model_json, start_day, '
            "active_vehicle_key) VALUES ('$id', 'local', 1, 1, 0, 1, 'v1', "
            "'d1', '{}', 1, $key)",
          );
          await assign('a1', "'v1'");
          // ...but only one active assignment per vehicle is allowed.
          await expectLater(assign('a2', "'v1'"), throwsA(anything));
          // Ended assignments (NULL key) are unlimited.
          await assign('a3', 'NULL');
          await assign('a4', 'NULL');
        },
      );
    },
  );
}
