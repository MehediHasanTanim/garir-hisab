# vehicle_khata

A new Flutter project.

## Database migrations

After changing tables, bump `schemaVersion` in `app_database.dart`, then:

```bash
cd app
dart run drift_dev make-migrations
```

This snapshots the schema to `drift_schemas/`, regenerates
`lib/core/db/app_database.steps.dart` and the test helpers in
`test/generated_migrations/`. Add a `from(N-1)To(N)` step in
`onUpgrade` and extend `test/core/db/migration_test.dart`.
