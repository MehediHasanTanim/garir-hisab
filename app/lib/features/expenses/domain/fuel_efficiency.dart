import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';

/// One refuelling.
@immutable
class FuelFill {
  const new({
    required this.at,
    required this.odometerM,
    required this.qtyMilli,
    required this.cost,
  });

  final DateTime at;
  final int odometerM;

  /// Litres (or m³ of CNG) ×1000.
  final int qtyMilli;
  final Money cost;
}

/// Efficiency of one refuelling: the distance driven since the previous fill
/// divided by the fuel bought now (full-tank method).
@immutable
class FuelEfficiencyPoint {
  const new({
    required this.fill,
    required this.distanceM,
    required this.kmPerUnit,
    required this.costPerKm,
  });

  final FuelFill fill;
  final int distanceM;

  /// Kilometres per litre (or per m³). A plain number for display, not money.
  final double kmPerUnit;

  /// Cost of fuel per kilometre driven.
  final Money costPerKm;
}

@immutable
class FuelEfficiencyReport {
  const new({
    required this.points,
    this.averageKmPerUnit,
    this.averageCostPerKm,
  });

  final List<FuelEfficiencyPoint> points;

  /// Total distance / total fuel over all valid points.
  final double? averageKmPerUnit;
  final Money? averageCostPerKm;
}

/// Works out fuel efficiency from refuellings with odometer readings.
///
/// Fills are ordered by odometer. The first fill is only a baseline. A fill is
/// skipped (and becomes the new baseline) if the odometer did not advance or
/// no fuel quantity was recorded.
FuelEfficiencyReport fuelEfficiency(Iterable<FuelFill> fills) {
  final ordered = fills.toList()
    ..sort((a, b) => a.odometerM.compareTo(b.odometerM));
  final points = <FuelEfficiencyPoint>[];
  var totalDistance = 0;
  var totalQty = 0;
  var totalCost = Money.zero;

  for (var i = 1; i < ordered.length; i++) {
    final previous = ordered[i - 1];
    final fill = ordered[i];
    final distance = fill.odometerM - previous.odometerM;
    if (distance <= 0 || fill.qtyMilli <= 0) continue;
    points.add(
      FuelEfficiencyPoint(
        fill: fill,
        distanceM: distance,
        kmPerUnit: (distance / 1000) / (fill.qtyMilli / 1000),
        costPerKm: fill.cost.proportion(1000, distance),
      ),
    );
    totalDistance += distance;
    totalQty += fill.qtyMilli;
    totalCost += fill.cost;
  }

  if (totalDistance == 0) return FuelEfficiencyReport(points: points);
  return FuelEfficiencyReport(
    points: points,
    averageKmPerUnit: (totalDistance / 1000) / (totalQty / 1000),
    averageCostPerKm: totalCost.proportion(1000, totalDistance),
  );
}
