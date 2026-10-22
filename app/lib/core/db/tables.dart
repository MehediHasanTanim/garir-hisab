import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/db/synced_columns.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
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
