import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';

/// Payouts for trip-based pay now use the pay stored on each trip.
void main() {
  late Fixture f;
  late String vehicleId;
  late String driverId;
  final march = DayRange.month(2026, 3);

  Future<String> trip({
    required int fare,
    required int pay,
    int day = 10,
    bool overridden = false,
    List<ExpenseDraft> expenses = const [],
    String? driver,
    String? vehicle,
  }) async => await f.trips.create(
    TripDraft(
      vehicleId: vehicle ?? vehicleId,
      driverId: driver ?? driverId,
      startedAt: DateTime.utc(2026, 3, day, 6),
      fare: Money.taka(fare),
      received: Money.taka(fare),
      driverPay: Money.taka(pay),
      driverPayOverridden: overridden,
      expenses: expenses,
    ),
  );

  Future<String> assign(
    PayModel model, {
    BusinessModel business = BusinessModel.contract,
  }) async {
    vehicleId = await f.vehicle(
      name: 'Pickup ${model.type.name}',
      model: business,
      type: VehicleType.pickup,
    );
    return await f.assignments.assign(
      vehicleId: vehicleId,
      driverId: driverId,
      payModel: model,
      start: day(2026, 1, 1),
    );
  }

  setUp(() async {
    f = Fixture();
    await f.categories.ensureDefaults();
    driverId = await f.driver();
  });
  tearDown(() => f.close());

  test('per-trip pay is the sum of what each trip paid', () async {
    final a = await assign(const PerTripPay(perTrip: Money.taka(250)));
    await trip(fare: 1000, pay: 250);
    await trip(fare: 1000, pay: 250, day: 11);
    await trip(fare: 1000, pay: 250, day: 12);
    final p = await f.payouts.preview(
      driverId: driverId,
      assignmentId: a,
      period: march,
    );
    expect(p.plan.earned, const Money.taka(750));
    expect(p.pay.lines.single.kind.name, 'tripFees');
    expect(p.pay.lines.single.quantity, 3);
  });

  test('an owner override on a trip is honoured in the payout', () async {
    final a = await assign(const PerTripPay(perTrip: Money.taka(250)));
    await trip(fare: 1000, pay: 250);
    await trip(
      fare: 1000,
      pay: 400,
      day: 11,
      overridden: true,
    ); // owner paid a bonus
    final p = await f.payouts.preview(
      driverId: driverId,
      assignmentId: a,
      period: march,
    );
    expect(p.plan.earned, const Money.taka(650));
  });

  test('commission is the sum of per-trip commissions', () async {
    final a = await assign(
      const CommissionPay(rateBps: 2000, basis: CommissionBasis.afterExpenses),
    );
    await trip(
      fare: 4500,
      pay: 620,
      expenses: const [
        ExpenseDraft(categoryId: 'default:fuel', amount: Money.taka(1400)),
      ],
    );
    await trip(fare: 1000, pay: 200, day: 11);
    final p = await f.payouts.preview(
      driverId: driverId,
      assignmentId: a,
      period: march,
    );
    expect(p.plan.earned, const Money.taka(820));
  });

  test('mixed pay is the base salary plus trip commissions', () async {
    final a = await assign(
      const MixedPay(
        baseMonthly: Money.taka(8000),
        rateBps: 500,
        basis: CommissionBasis.beforeExpenses,
      ),
      business: BusinessModel.commission,
    );
    await trip(fare: 20000, pay: 1000);
    final p = await f.payouts.preview(
      driverId: driverId,
      assignmentId: a,
      period: march,
    );
    expect(p.plan.earned, const Money.taka(9000));
    expect(p.pay.lines.map((l) => l.kind.name), ['salary', 'commission']);
  });

  test('only this driver, vehicle, period and live trips count', () async {
    final a = await assign(const PerTripPay(perTrip: Money.taka(250)));
    final other = await f.driver(name: 'Other');
    final otherVehicle = await f.vehicle(
      name: 'Elsewhere',
      model: BusinessModel.contract,
    );
    await trip(fare: 1000, pay: 250);
    await trip(fare: 1000, pay: 999, driver: other, day: 11);
    await trip(fare: 1000, pay: 999, vehicle: otherVehicle, day: 12);
    await trip(fare: 1000, pay: 999, day: 13).then(f.trips.delete);
    await f.trips.create(
      TripDraft(
        vehicleId: vehicleId,
        driverId: driverId,
        startedAt: DateTime.utc(2026, 4, 2, 6),
        fare: const Money.taka(1000),
        received: const Money.taka(1000),
        driverPay: const Money.taka(999),
      ),
    );
    final p = await f.payouts.preview(
      driverId: driverId,
      assignmentId: a,
      period: march,
    );
    expect(p.plan.earned, const Money.taka(250));
  });

  test(
    'can now be recorded, and recovers advances from trip earnings',
    () async {
      final a = await assign(const PerTripPay(perTrip: Money.taka(250)));
      await trip(fare: 1000, pay: 250);
      await trip(fare: 1000, pay: 250, day: 11);
      await f.advances.give(
        driverId: driverId,
        amount: const Money.taka(200),
        day: day(2026, 3, 1),
      );
      final r = await f.payouts.record(
        driverId: driverId,
        assignmentId: a,
        period: march,
      );
      expect(r.payout.earned, const Money.taka(500));
      expect(r.payout.deducted, const Money.taka(200));
      expect(r.payout.net, const Money.taka(300));
    },
  );

  test('a salaried driver is unaffected by trips', () async {
    final a = await assign(
      const SalaryPay(monthly: Money.taka(15000)),
      business: BusinessModel.salaried,
    );
    await trip(fare: 5000, pay: 0);
    final p = await f.payouts.preview(
      driverId: driverId,
      assignmentId: a,
      period: march,
    );
    expect(p.plan.earned, const Money.taka(15000));
  });
}
