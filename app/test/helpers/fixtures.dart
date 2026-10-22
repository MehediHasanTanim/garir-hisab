import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/field_cipher.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/data/advance_repository.dart';
import 'package:vehicle_khata/features/drivers/data/assignment_repository.dart';
import 'package:vehicle_khata/features/drivers/data/attendance_repository.dart';
import 'package:vehicle_khata/features/drivers/data/driver_repository.dart';
import 'package:vehicle_khata/features/drivers/data/payout_service.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/vehicles/data/vehicle_repository.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import 'memory_secret_store.dart';

/// An in-memory database with every repository, for data-layer tests.
class Fixture {
  new({DateTime Function()? clock}) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.inMemory();
    secrets = MemorySecretStore();
    cipher = AesGcmFieldCipher(secrets);
    vehicles = VehicleRepository(db);
    drivers = DriverRepository(db, cipher);
    assignments = AssignmentRepository(db);
    attendance = AttendanceRepository(db);
    advances = AdvanceRepository(db);
    payouts = PayoutService(
      db,
      assignments,
      attendance,
      advances,
      clock: clock ?? () => DateTime.utc(2026, 4, 1, 9),
    );
  }

  late final AppDatabase db;
  late final MemorySecretStore secrets;
  late final AesGcmFieldCipher cipher;
  late final VehicleRepository vehicles;
  late final DriverRepository drivers;
  late final AssignmentRepository assignments;
  late final AttendanceRepository attendance;
  late final AdvanceRepository advances;
  late final PayoutService payouts;

  Future<void> close() => db.close();

  Future<String> vehicle({
    String name = 'Rahim CNG',
    BusinessModel model = BusinessModel.salaried,
    VehicleType type = VehicleType.cng,
  }) => vehicles.create(
    VehicleDraft(
      nickname: name,
      type: type,
      fuelType: type.defaultFuel,
      businessModel: model,
    ),
  );

  Future<String> driver({
    String name = 'Karim',
    String? phone,
    DriverStatus status = DriverStatus.active,
    String? nid,
  }) => drivers.create(
    DriverDraft(name: name, phone: phone, status: status, nid: nid),
  );

  /// Audit rows for one entity, oldest first.
  Future<List<AuditLog>> audit(String entity, [String? id]) async {
    final rows = await db.select(db.auditLogs).get();
    return rows
        .where((r) => r.entity == entity && (id == null || r.entityId == id))
        .toList()
      ..sort((a, b) => a.at.compareTo(b.at));
  }
}

CalendarDay day(int y, int m, int d) => CalendarDay.of(y, m, d);

/// A salaried CNG for tests that need a vehicle accepting a salaried driver.
VehicleDraft salariedVehicle({String name = 'Rahim CNG'}) => VehicleDraft(
  nickname: name,
  type: VehicleType.cng,
  fuelType: FuelType.cng,
  businessModel: BusinessModel.salaried,
);

const salary15000 = SalaryPay(monthly: Money.taka(15000));

VehicleDraft vehicleFor(BusinessModel model, {String name = 'Pickup 1'}) =>
    VehicleDraft(
      nickname: name,
      type: VehicleType.cng,
      fuelType: FuelType.cng,
      businessModel: model,
    );
