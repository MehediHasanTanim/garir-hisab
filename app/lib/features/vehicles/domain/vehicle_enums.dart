enum VehicleType { cng, rickshaw, easyBike, pickup, miniTruck, truck, other }

enum FuelType { cng, octane, petrol, diesel, electric }

enum VehicleStatus { active, inGarage, sold }

/// How the vehicle earns and who is paid what (feature spec F2).
enum BusinessModel {
  /// Owner drives.
  self,

  /// Driver paid a monthly salary.
  salaried,

  /// Driver paid a fixed amount per day.
  dailyWage,

  /// Driver gets a share of income or a per-trip amount.
  commission,

  /// Driver pays the owner a fixed daily/weekly rent.
  jama,

  /// Per-trip hauling contracts (trucks and pickups).
  contract,
}

extension VehicleTypeDefaults on VehicleType {
  /// Sensible default fuel for the vehicle type, to save a tap.
  FuelType get defaultFuel => switch (this) {
    VehicleType.cng => FuelType.cng,
    VehicleType.rickshaw || VehicleType.easyBike => FuelType.electric,
    VehicleType.pickup ||
    VehicleType.miniTruck ||
    VehicleType.truck => FuelType.diesel,
    VehicleType.other => FuelType.petrol,
  };

  /// Sensible default business model.
  BusinessModel get defaultModel => switch (this) {
    VehicleType.cng ||
    VehicleType.rickshaw ||
    VehicleType.easyBike => BusinessModel.self,
    VehicleType.pickup ||
    VehicleType.miniTruck ||
    VehicleType.truck => BusinessModel.contract,
    VehicleType.other => BusinessModel.self,
  };
}
