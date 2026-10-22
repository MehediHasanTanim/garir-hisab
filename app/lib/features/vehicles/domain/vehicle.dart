import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

@immutable
class Vehicle {
  const new({
    required this.id,
    required this.nickname,
    required this.type,
    required this.fuelType,
    required this.businessModel,
    required this.status,
    required this.archived,
    required this.createdAt,
    this.regNo,
    this.model,
    this.year,
    this.photoFile,
    this.purchaseDate,
    this.purchasePrice,
  });

  final String id;
  final String nickname;
  final VehicleType type;
  final FuelType fuelType;
  final BusinessModel businessModel;
  final VehicleStatus status;
  final bool archived;
  final DateTime createdAt;
  final String? regNo;
  final String? model;
  final int? year;

  /// File name inside the app's photo directory (not an absolute path).
  final String? photoFile;
  final DateTime? purchaseDate;
  final Money? purchasePrice;

  bool get isActive => status == VehicleStatus.active && !archived;
}

/// Data for creating or updating a vehicle (everything the user edits).
@immutable
class VehicleDraft {
  const new({
    required this.nickname,
    required this.type,
    required this.fuelType,
    required this.businessModel,
    this.status = VehicleStatus.active,
    this.regNo,
    this.model,
    this.year,
    this.photoFile,
    this.purchaseDate,
    this.purchasePrice,
  });

  factory fromVehicle(Vehicle v) => VehicleDraft(
    nickname: v.nickname,
    type: v.type,
    fuelType: v.fuelType,
    businessModel: v.businessModel,
    status: v.status,
    regNo: v.regNo,
    model: v.model,
    year: v.year,
    photoFile: v.photoFile,
    purchaseDate: v.purchaseDate,
    purchasePrice: v.purchasePrice,
  );

  final String nickname;
  final VehicleType type;
  final FuelType fuelType;
  final BusinessModel businessModel;
  final VehicleStatus status;
  final String? regNo;
  final String? model;
  final int? year;
  final String? photoFile;
  final DateTime? purchaseDate;
  final Money? purchasePrice;
}
