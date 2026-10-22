import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/db/synced_columns.dart';
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
