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
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/reports/data/rollup_service.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

part 'app_database.g.dart';

QueryExecutor _openEncrypted(File file, String key) {
  return NativeDatabase(
    file,
    // Must be the first statement on the connection.
    setup: (raw) => raw.execute("PRAGMA key = '$key';"),
  );
}

@DriftDatabase(
  tables: [
    AuditLogs,
    Vehicles,
    Drivers,
    Assignments,
    AttendanceRecords,
    Advances,
    Payouts,
    PayoutAdvanceAllocations,
    ExpenseCategories,
    Trips,
    Expenses,
    DayLogs,
    DailyRollups,
    SyncMeta,
    SyncIssues,
    JamaEntries,
    JamaPayments,
    JamaAllocations,
    JamaDeposits,
    JamaPauses,
  ],
)
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
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.createTable(schema.vehicles);
      },
      from2To3: (m, schema) async {
        await m.createTable(schema.drivers);
        await m.createTable(schema.assignments);
        await m.createTable(schema.attendanceRecords);
        await m.createTable(schema.advances);
        await m.createTable(schema.payouts);
        await m.createTable(schema.payoutAdvanceAllocations);
      },
      from3To4: (m, schema) async {
        await m.createTable(schema.expenseCategories);
        await m.createTable(schema.trips);
        await m.createIndex(schema.tripsByVehicleTime);
        await m.createIndex(schema.tripsByDay);
        await m.createTable(schema.expenses);
        await m.createIndex(schema.expensesByVehicleTime);
        await m.createIndex(schema.expensesByTrip);
      },
      from4To5: (m, schema) async {
        await m.addColumn(schema.expenses, schema.expenses.spentDay);
        await m.createTable(schema.dayLogs);
        await m.createTable(schema.dailyRollups);
        await m.createIndex(schema.rollupsByDay);
        // Fill in the new day column from each expense's time, using the
        // phone's own timezone (SQL cannot know it).
        final rows = await customSelect('SELECT id, spent_at FROM expenses')
            .get();
        for (final r in rows) {
          final local = DateTime.fromMillisecondsSinceEpoch(
            r.read<int>('spent_at'),
            isUtc: true,
          ).toLocal();
          await customStatement(
            'UPDATE expenses SET spent_day = ? WHERE id = ?',
            [CalendarDay.fromDate(local).epochDay, r.read<String>('id')],
          );
        }
      },
      from5To6: (m, schema) async {
        await m.createTable(schema.syncMeta);
        await m.createTable(schema.syncIssues);
        // Everything created before sync existed still has to reach the server.
        for (final t in [
          'vehicles',
          'drivers',
          'assignments',
          'attendance_records',
          'advances',
          'payouts',
          'payout_advance_allocations',
          'expense_categories',
          'trips',
          'expenses',
          'day_logs',
        ]) {
          await customStatement('UPDATE $t SET dirty = 1');
        }
      },
      from6To7: (m, schema) async {
        await m.createTable(schema.jamaEntries);
        await m.createTable(schema.jamaPayments);
        await m.createTable(schema.jamaAllocations);
        await m.createTable(schema.jamaDeposits);
        await m.createTable(schema.jamaPauses);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Rollups are derived data: build them for databases that predate them.
      final before = details.versionBefore;
      if (before != null && before < 5 && details.versionNow >= 5) {
        await RollupService(this).rebuildAll();
      }
    },
  );
}
