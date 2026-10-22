import 'package:vehicle_khata/features/auth/domain/auth_repository.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Maps domain enums to localized labels.
extension DomainLabels on AppLocalizations {
  String vehicleTypeName(VehicleType t) => switch (t) {
    VehicleType.cng => typeCng,
    VehicleType.rickshaw => typeRickshaw,
    VehicleType.easyBike => typeEasyBike,
    VehicleType.pickup => typePickup,
    VehicleType.miniTruck => typeMiniTruck,
    VehicleType.truck => typeTruck,
    VehicleType.other => typeOther,
  };

  String fuelName(FuelType f) => switch (f) {
    FuelType.cng => fuelCng,
    FuelType.octane => fuelOctane,
    FuelType.petrol => fuelPetrol,
    FuelType.diesel => fuelDiesel,
    FuelType.electric => fuelElectric,
  };

  String modelName(BusinessModel m) => switch (m) {
    BusinessModel.self => modelSelf,
    BusinessModel.salaried => modelSalaried,
    BusinessModel.dailyWage => modelDailyWage,
    BusinessModel.commission => modelCommission,
    BusinessModel.jama => modelJama,
    BusinessModel.contract => modelContract,
  };

  String modelDescription(BusinessModel m) => switch (m) {
    BusinessModel.self => modelSelfDesc,
    BusinessModel.salaried => modelSalariedDesc,
    BusinessModel.dailyWage => modelDailyWageDesc,
    BusinessModel.commission => modelCommissionDesc,
    BusinessModel.jama => modelJamaDesc,
    BusinessModel.contract => modelContractDesc,
  };

  String statusName(VehicleStatus s) => switch (s) {
    VehicleStatus.active => statusActive,
    VehicleStatus.inGarage => statusInGarage,
    VehicleStatus.sold => statusSold,
  };

  String authFailure(AuthFailure f) => switch (f) {
    AuthFailure.invalidPhone => errInvalidPhone,
    AuthFailure.rateLimited => errRateLimited,
    AuthFailure.invalidCode => errInvalidCode,
    AuthFailure.network => errNetwork,
    AuthFailure.unknown => errUnknown,
  };
}
