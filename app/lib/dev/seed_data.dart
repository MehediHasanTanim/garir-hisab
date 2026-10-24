import 'dart:math';

import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/data/category_repository.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/reports/data/rollup_service.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

/// Fills the database with a year of believable activity, for performance
/// checks and for trying the app out. **Development builds only.**
///
/// Rows are inserted in bulk (not through the repositories), then the
/// rollups are rebuilt once.
Future<void> seedDemoData(
  AppDatabase db, {
  int vehicles = 5,
  int days = 365,
  DateTime? today,
  int seed = 1,
}) async {
  final rng = Random(seed);
  final end = CalendarDay.fromDate(today ?? DateTime.now());
  final start = end.addDays(-(days - 1));
  await CategoryRepository(db).ensureDefaults();

  const models = [
    BusinessModel.self,
    BusinessModel.salaried,
    BusinessModel.contract,
    BusinessModel.jama,
    BusinessModel.dailyWage,
  ];
  const types = [
    VehicleType.cng,
    VehicleType.pickup,
    VehicleType.truck,
    VehicleType.cng,
    VehicleType.rickshaw,
  ];

  String fuel(int i) => ExpenseCategory.defaultId(DefaultCategory.fuel);
  int taka(int v) => v * 100;
  int ms(CalendarDay d, int hour) =>
      DateTime(d.year, d.month, d.day, hour).toUtc().millisecondsSinceEpoch;

  for (var v = 0; v < vehicles; v++) {
    final model = models[v % models.length];
    final vehicleId = newId();
    final driverId = newId();
    await db
        .into(db.vehicles)
        .insert(
          VehiclesCompanion.insert(
            id: Value(vehicleId),
            nickname: 'Demo ${v + 1}',
            type: types[v % types.length],
            fuelType: types[v % types.length].defaultFuel,
            businessModel: model,
          ),
        );

    if (model != BusinessModel.self) {
      await db
          .into(db.drivers)
          .insert(
            DriversCompanion.insert(
              id: Value(driverId),
              name: 'Driver ${v + 1}',
              status: const Value(DriverStatus.active),
            ),
          );
      final payModel = switch (model) {
        BusinessModel.salaried => const SalaryPay(monthly: Money.taka(15000)),
        BusinessModel.contract => const PerTripPay(perTrip: Money.taka(250)),
        BusinessModel.jama => const JamaPay(amount: Money.taka(600)),
        _ => const DailyWagePay(perDay: Money.taka(800)),
      };
      await db
          .into(db.assignments)
          .insert(
            AssignmentsCompanion.insert(
              vehicleId: vehicleId,
              driverId: driverId,
              payModelJson: payModel.encode(),
              startDay: start.epochDay,
              activeVehicleKey: Value(vehicleId),
            ),
          );
    }

    await db.batch((b) {
      for (var d = start; !d.isAfter(end); d = d.addDays(1)) {
        final worked = rng.nextInt(100) >= 8; // a day off now and then
        if (model != BusinessModel.self &&
            worked &&
            model != BusinessModel.jama) {
          b.insert(
            db.attendanceRecords,
            AttendanceRecordsCompanion.insert(
              driverId: driverId,
              day: d.epochDay,
              status: AttendanceStatus.present,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
        if (!worked) continue;

        if (model == BusinessModel.contract) {
          for (var t = 0; t < 1 + rng.nextInt(3); t++) {
            final tripId = newId();
            final fare = taka(2000 + rng.nextInt(4000));
            b
              ..insert(
                db.trips,
                TripsCompanion.insert(
                  id: Value(tripId),
                  vehicleId: vehicleId,
                  driverId: Value(driverId),
                  startedAt: ms(d, 7 + t * 4),
                  tripDay: d.epochDay,
                  fareMinor: fare,
                  receivedMinor: Value(rng.nextInt(10) == 0 ? 0 : fare),
                  driverPayMinor: Value(taka(250)),
                ),
              )
              ..insert(
                db.expenses,
                ExpensesCompanion.insert(
                  vehicleId: vehicleId,
                  tripId: Value(tripId),
                  categoryId: fuel(v),
                  amountMinor: taka(300 + rng.nextInt(700)),
                  spentAt: ms(d, 7 + t * 4),
                  paidBy: PaidBy.owner,
                  spentDay: Value(d.epochDay),
                ),
              );
          }
        } else {
          b
            ..insert(
              db.dayLogs,
              DayLogsCompanion.insert(
                vehicleId: vehicleId,
                logDay: d.epochDay,
                collectionMinor: Value(taka(1800 + rng.nextInt(1800))),
              ),
            )
            ..insert(
              db.expenses,
              ExpensesCompanion.insert(
                vehicleId: vehicleId,
                categoryId: fuel(v),
                amountMinor: taka(400 + rng.nextInt(400)),
                spentAt: ms(d, 18),
                paidBy: PaidBy.owner,
                spentDay: Value(d.epochDay),
              ),
            );
        }
        // A vehicle cost on the first of every month.
        if (d.day == 1) {
          b.insert(
            db.expenses,
            ExpensesCompanion.insert(
              vehicleId: vehicleId,
              categoryId: ExpenseCategory.defaultId(
                rng.nextBool()
                    ? DefaultCategory.repair
                    : DefaultCategory.insurance,
              ),
              amountMinor: taka(1500 + rng.nextInt(3500)),
              spentAt: ms(d, 12),
              paidBy: PaidBy.owner,
              spentDay: Value(d.epochDay),
            ),
          );
        }
      }
    });
  }
  await RollupService(db).rebuildAll();
}
