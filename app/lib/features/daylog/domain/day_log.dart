import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';

/// One vehicle's income for one day when individual trips are not logged
/// (a CNG's daily takings).
@immutable
class DayLog {
  const new({
    required this.id,
    required this.vehicleId,
    required this.day,
    required this.collection,
    this.driverId,
    this.distanceM,
    this.hoursMin,
    this.note,
  });

  final String id;
  final String vehicleId;
  final CalendarDay day;
  final Money collection;
  final String? driverId;
  final int? distanceM;

  /// Hours worked, in minutes.
  final int? hoursMin;
  final String? note;
}
