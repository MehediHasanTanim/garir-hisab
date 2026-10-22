import 'package:flutter/material.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

IconData vehicleIcon(VehicleType t) => switch (t) {
  VehicleType.cng => Icons.electric_rickshaw_outlined,
  VehicleType.rickshaw || VehicleType.easyBike => Icons.pedal_bike_outlined,
  VehicleType.pickup => Icons.local_shipping_outlined,
  VehicleType.miniTruck || VehicleType.truck => Icons.fire_truck_outlined,
  VehicleType.other => Icons.directions_car_outlined,
};

IconData modelIcon(BusinessModel m) => switch (m) {
  BusinessModel.self => Icons.person_outline,
  BusinessModel.salaried => Icons.badge_outlined,
  BusinessModel.dailyWage => Icons.today_outlined,
  BusinessModel.commission => Icons.percent,
  BusinessModel.jama => Icons.event_repeat_outlined,
  BusinessModel.contract => Icons.route_outlined,
};
