import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/expenses/domain/fuel_efficiency.dart';

FuelFill _fill(int odoKm, double qty, int taka) => FuelFill(
  at: DateTime.utc(2026, 3).add(Duration(days: odoKm)),
  odometerM: odoKm * 1000,
  qtyMilli: (qty * 1000).round(),
  cost: Money.taka(taka),
);

void main() {
  test('needs two fills: the first is only a baseline', () {
    expect(fuelEfficiency([]).points, isEmpty);
    expect(fuelEfficiency([_fill(1000, 30, 3000)]).points, isEmpty);
    expect(fuelEfficiency([_fill(1000, 30, 3000)]).averageKmPerUnit, isNull);
  });

  test('km per unit uses the distance since the previous fill', () {
    final r = fuelEfficiency([
      _fill(1000, 30, 3000),
      _fill(
        1300,
        25,
        2500,
      ), // 300 km on the previous tank? no: on this fill's fuel
    ]);
    expect(r.points, hasLength(1));
    expect(r.points.single.distanceM, 300000);
    expect(r.points.single.kmPerUnit, closeTo(12, 1e-9));
    // 2,500 ৳ over 300 km = 8.33 ৳/km
    expect(r.points.single.costPerKm, const Money(833));
  });

  test('several fills, averaged over total distance and fuel', () {
    final r = fuelEfficiency([
      _fill(1000, 40, 4000),
      _fill(1400, 40, 4000), // 400 km / 40 = 10
      _fill(1700, 20, 2000), // 300 km / 20 = 15
    ]);
    expect(r.points.map((p) => p.kmPerUnit), [
      closeTo(10, 1e-9),
      closeTo(15, 1e-9),
    ]);
    expect(r.averageKmPerUnit, closeTo(700 / 60, 1e-9));
    expect(r.averageCostPerKm, const Money(857)); // 6000 ৳ / 700 km
  });

  test('input order does not matter', () {
    final a = [
      _fill(1000, 40, 4000),
      _fill(1400, 40, 4000),
      _fill(1700, 20, 2000),
    ];
    expect(
      fuelEfficiency(a.reversed).averageKmPerUnit,
      fuelEfficiency(a).averageKmPerUnit,
    );
  });

  test('skips a fill whose odometer did not advance or with no quantity', () {
    final r = fuelEfficiency([
      _fill(1000, 40, 4000),
      _fill(1000, 10, 1000), // same odometer: skipped
      _fill(1200, 20, 2000), // measured from the previous fill (same reading)
    ]);
    expect(r.points, hasLength(1));
    expect(r.points.single.distanceM, 200000);

    final noQty = fuelEfficiency([
      _fill(1000, 40, 4000),
      FuelFill(at: null_, odometerM: 1500000, qtyMilli: 0, cost: Money.zero),
    ]);
    expect(noQty.points, isEmpty);
  });
}

final null_ = DateTime.utc(2026);
