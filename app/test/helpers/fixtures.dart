import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/field_cipher.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/daylog/data/day_log_repository.dart';
import 'package:vehicle_khata/features/drivers/data/advance_repository.dart';
import 'package:vehicle_khata/features/drivers/data/assignment_repository.dart';
import 'package:vehicle_khata/features/drivers/data/attendance_repository.dart';
import 'package:vehicle_khata/features/drivers/data/driver_repository.dart';
import 'package:vehicle_khata/features/drivers/data/payout_service.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/data/category_repository.dart';
import 'package:vehicle_khata/features/expenses/data/expense_repository.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/jama/data/jama_repository.dart';
import 'package:vehicle_khata/features/ledger/data/ledger_service.dart';
import 'package:vehicle_khata/features/reports/data/report_service.dart';
import 'package:vehicle_khata/features/reports/data/rollup_service.dart';
import 'package:vehicle_khata/features/trips/data/trip_repository.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
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
    categories = CategoryRepository(db);
    dayLogs = DayLogRepository(db);
    rollups = RollupService(db);
    jama = JamaRepository(db, rollups);
    reports = ReportService(
      db,
      clock: clock ?? () => DateTime.utc(2026, 4, 1, 9),
    );
    trips = TripRepository(db);
    expenses = ExpenseRepository(
      db,
      clock: clock ?? () => DateTime.utc(2026, 4, 1, 9),
    );
    ledger = LedgerService(db, trips, jama);
    payouts = PayoutService(
      db,
      assignments,
      attendance,
      advances,
      trips: trips,
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
  late final CategoryRepository categories;
  late final DayLogRepository dayLogs;
  late final RollupService rollups;
  late final JamaRepository jama;
  late final LedgerService ledger;
  late final ReportService reports;
  late final TripRepository trips;
  late final ExpenseRepository expenses;

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

/// Small ready-made trips for tests.
abstract final class TripDraftHelper {
  static TripDraft simple(
    String vehicleId,
    String? driverId,
    DateTime at, {
    int fare = 1000,
  }) => TripDraft(
    vehicleId: vehicleId,
    driverId: driverId,
    startedAt: at,
    fare: Money.taka(fare),
    received: Money.taka(fare),
    driverPay: Money.zero,
  );
}

/// Ready-made vehicle-level expenses for tests.
abstract final class ExpenseDraftFor {
  static ExpenseDraft fuel(int taka, DateTime at) => ExpenseDraft(
    categoryId: 'default:fuel',
    amount: Money.taka(taka),
    spentAt: at,
  );

  static ExpenseDraft other(int taka, DateTime at) => ExpenseDraft(
    categoryId: 'default:other',
    amount: Money.taka(taka),
    spentAt: at,
  );
}
