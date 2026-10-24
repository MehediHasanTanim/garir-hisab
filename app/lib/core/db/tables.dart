import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/db/synced_columns.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

/// Local record of every mutation (technical design §5.2).
class AuditLogs extends Table with SyncedColumns {
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get diffJson => text().withDefault(const Constant('{}'))();
  IntColumn get at => integer().clientDefault(utcNowMs)();
}

@DataClassName('VehicleRow')
class Vehicles extends Table with SyncedColumns {
  TextColumn get nickname => text()();
  TextColumn get type => textEnum<VehicleType>()();
  TextColumn get regNo => text().nullable()();

  /// Normalised registration number used for duplicate detection.
  TextColumn get regNoKey => text().nullable()();
  TextColumn get model => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get fuelType => textEnum<FuelType>()();
  TextColumn get businessModel => textEnum<BusinessModel>()();
  TextColumn get status =>
      textEnum<VehicleStatus>().withDefault(const Constant('active'))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get photoFile => text().nullable()();
  IntColumn get purchaseDate => integer().nullable()();
  IntColumn get purchasePriceMinor => integer().nullable()();
}

@DataClassName('DriverRow')
class Drivers extends Table with SyncedColumns {
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get licenseNo => text().nullable()();

  /// Calendar day (days since 1970-01-01).
  IntColumn get licenseExpiry => integer().nullable()();

  /// National ID, AES-GCM encrypted (`v1:...`); never plaintext.
  TextColumn get nidEncrypted => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get emergencyContact => text().nullable()();
  IntColumn get joinDay => integer().nullable()();
  TextColumn get photoFile => text().nullable()();
  TextColumn get status =>
      textEnum<DriverStatus>().withDefault(const Constant('active'))();
}

@DataClassName('AssignmentRow')
class Assignments extends Table with SyncedColumns {
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get driverId => text().references(Drivers, #id)();

  /// Versioned pay model JSON (`PayModel.encode`).
  TextColumn get payModelJson => text()();
  IntColumn get startDay => integer()();
  IntColumn get endDay => integer().nullable()();

  /// Equals [vehicleId] while the assignment is active, NULL once ended.
  /// The unique constraint below therefore allows at most one active
  /// assignment per vehicle (NULLs are distinct in SQLite).
  TextColumn get activeVehicleKey => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {activeVehicleKey},
  ];
}

@DataClassName('AttendanceRow')
class AttendanceRecords extends Table with SyncedColumns {
  TextColumn get driverId => text().references(Drivers, #id)();
  IntColumn get day => integer()();
  TextColumn get status => textEnum<AttendanceStatus>()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {driverId, day},
  ];
}

@DataClassName('AdvanceRow')
class Advances extends Table with SyncedColumns {
  TextColumn get driverId => text().references(Drivers, #id)();
  IntColumn get amountMinor => integer()();
  IntColumn get givenDay => integer()();
  TextColumn get note => text().nullable()();
}

@DataClassName('PayoutRow')
class Payouts extends Table with SyncedColumns {
  TextColumn get driverId => text().references(Drivers, #id)();
  TextColumn get assignmentId =>
      text().nullable().references(Assignments, #id)();
  IntColumn get periodStartDay => integer()();
  IntColumn get periodEndDay => integer()();
  IntColumn get earnedMinor => integer()();
  IntColumn get adjustmentMinor => integer().withDefault(const Constant(0))();
  TextColumn get adjustmentNote => text().nullable()();
  IntColumn get deductedMinor => integer().withDefault(const Constant(0))();
  IntColumn get netMinor => integer()();
  IntColumn get paidAt => integer()();
  TextColumn get note => text().nullable()();

  /// `driver|assignment|start|end` while the payout stands; NULL once voided.
  /// Unique, so recording the same period twice cannot create a duplicate.
  TextColumn get periodKey => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {periodKey},
  ];
}

/// How much of each advance a payout recovered.
@DataClassName('PayoutAllocationRow')
class PayoutAdvanceAllocations extends Table with SyncedColumns {
  TextColumn get payoutId => text().references(Payouts, #id)();
  TextColumn get advanceId => text().references(Advances, #id)();
  IntColumn get amountMinor => integer()();
}

@DataClassName('ExpenseCategoryRow')
class ExpenseCategories extends Table with SyncedColumns {
  /// Built-in category key; NULL for custom categories.
  TextColumn get key => text().nullable()();

  /// Name of a custom category; NULL for built-in ones (localized instead).
  TextColumn get name => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

@DataClassName('TripRow')
@TableIndex(name: 'trips_by_vehicle_time', columns: {#vehicleId, #startedAt})
@TableIndex(name: 'trips_by_day', columns: {#tripDay})
class Trips extends Table with SyncedColumns {
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get driverId => text().nullable().references(Drivers, #id)();
  IntColumn get startedAt => integer()();

  /// Local calendar day (days since 1970-01-01), for grouping and filters.
  IntColumn get tripDay => integer()();
  TextColumn get fromPlace => text().nullable()();
  TextColumn get toPlace => text().nullable()();

  /// Distance in metres.
  IntColumn get distanceM => integer().nullable()();
  IntColumn get fareMinor => integer()();
  IntColumn get receivedMinor => integer().withDefault(const Constant(0))();
  IntColumn get driverPayMinor => integer().withDefault(const Constant(0))();
  BoolColumn get driverPayOverridden =>
      boolean().withDefault(const Constant(false))();
  TextColumn get loadNote => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get returnOfTripId => text().nullable()();
}

@DataClassName('ExpenseRow')
@TableIndex(name: 'expenses_by_vehicle_time', columns: {#vehicleId, #spentAt})
@TableIndex(name: 'expenses_by_trip', columns: {#tripId})
class Expenses extends Table with SyncedColumns {
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get tripId => text().nullable().references(Trips, #id)();
  TextColumn get categoryId => text().references(ExpenseCategories, #id)();
  IntColumn get amountMinor => integer()();
  IntColumn get spentAt => integer()();
  TextColumn get paidBy => textEnum<PaidBy>()();
  BoolColumn get reimbursable => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  TextColumn get receiptFile => text().nullable()();

  /// Fuel quantity ×1000 (litres or m³).
  IntColumn get qtyMilli => integer().nullable()();

  /// Odometer in metres.
  IntColumn get odometerM => integer().nullable()();

  /// Local calendar day the money was spent (days since 1970-01-01).
  IntColumn get spentDay => integer().withDefault(const Constant(0))();
}

/// One vehicle's income per day when trips are not logged one by one.
@DataClassName('DayLogRow')
class DayLogs extends Table with SyncedColumns {
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get driverId => text().nullable().references(Drivers, #id)();
  IntColumn get logDay => integer()();
  IntColumn get collectionMinor => integer().withDefault(const Constant(0))();
  IntColumn get distanceM => integer().nullable()();
  IntColumn get hoursMin => integer().nullable()();
  TextColumn get note => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {vehicleId, logDay},
  ];
}

/// Per-vehicle, per-day totals derived from trips, day logs and expenses so
/// that reports do not rescan raw rows. Local only (never synced); it can
/// always be rebuilt from the source tables.
@DataClassName('DailyRollupRow')
@TableIndex(name: 'rollups_by_day', columns: {#day})
class DailyRollups extends Table {
  TextColumn get vehicleId => text()();
  IntColumn get day => integer()();
  IntColumn get trips => integer().withDefault(const Constant(0))();
  IntColumn get fareMinor => integer().withDefault(const Constant(0))();
  IntColumn get receivedMinor => integer().withDefault(const Constant(0))();
  IntColumn get collectionMinor => integer().withDefault(const Constant(0))();
  IntColumn get variableMinor => integer().withDefault(const Constant(0))();
  IntColumn get fixedMinor => integer().withDefault(const Constant(0))();
  IntColumn get fixedAmortizedMinor =>
      integer().withDefault(const Constant(0))();
  IntColumn get tripPayMinor => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {vehicleId, day};
}

/// Sync bookkeeping (cursor, owner, last run). Local only.
@DataClassName('SyncMetaRow')
class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Rows the sync could not push or apply, kept so one bad row never blocks the
/// rest and the person can see what is stuck. Local only.
@DataClassName('SyncIssueRow')
class SyncIssues extends Table {
  TextColumn get entity => text()();
  TextColumn get rowId => text()();
  // 'push' or 'pull'
  TextColumn get direction => text()();
  TextColumn get reason => text()();
  IntColumn get attempts => integer().withDefault(const Constant(1))();
  IntColumn get at => integer()();

  @override
  Set<Column<Object>> get primaryKey => {entity, rowId, direction};
}
