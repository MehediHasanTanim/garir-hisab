import 'package:vehicle_khata/features/auth/domain/auth_repository.dart';
import 'package:vehicle_khata/features/drivers/data/assignment_repository.dart';
import 'package:vehicle_khata/features/drivers/data/payout_service.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/expenses/data/category_repository.dart';
import 'package:vehicle_khata/features/expenses/data/expense_repository.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/trips/data/trip_repository.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
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

  String attendanceName(AttendanceStatus s) => switch (s) {
    AttendanceStatus.present => attPresent,
    AttendanceStatus.absent => attAbsent,
    AttendanceStatus.halfDay => attHalfDay,
  };

  String driverStatusName(DriverStatus s) => switch (s) {
    DriverStatus.active => driverStatusActive,
    DriverStatus.left => driverStatusLeft,
  };

  String assignmentError(AssignmentError e) => switch (e) {
    AssignmentError.startNotAfterCurrent => errAssignStartAfter,
    AssignmentError.overlapsHistory => errAssignOverlap,
    AssignmentError.payTypeNotAllowed => errAssignPayType,
    AssignmentError.driverInactive => errAssignDriverLeft,
    AssignmentError.noDriverForSelfDriven => selfDrivenNoDriver,
    AssignmentError.payModelInvalid ||
    AssignmentError.vehicleNotFound ||
    AssignmentError.driverNotFound ||
    AssignmentError.endBeforeStart ||
    AssignmentError.assignmentNotFound ||
    AssignmentError.alreadyEnded => errUnknown,
  };

  String payoutError(PayoutError e) => switch (e) {
    PayoutError.notPayable => payErrNotPayable,
    PayoutError.periodOutsideAssignment => payErrOutside,
    PayoutError.overlapsExistingPayout => payErrOverlap,
    PayoutError.nothingToPay => payErrNothing,
    PayoutError.assignmentNotFound ||
    PayoutError.notThisDriversAssignment ||
    PayoutError.payoutNotFound => errUnknown,
  };

  String categoryLabel(ExpenseCategory c) => switch (c.key) {
    null => c.name ?? '',
    DefaultCategory.fuel => catFuel,
    DefaultCategory.toll => catToll,
    DefaultCategory.parking => catParking,
    DefaultCategory.helper => catHelper,
    DefaultCategory.police => catPolice,
    DefaultCategory.food => catFood,
    DefaultCategory.repair => catRepair,
    DefaultCategory.parts => catParts,
    DefaultCategory.tyre => catTyre,
    DefaultCategory.service => catService,
    DefaultCategory.washing => catWashing,
    DefaultCategory.insurance => catInsurance,
    DefaultCategory.registration => catRegistration,
    DefaultCategory.loan => catLoan,
    DefaultCategory.other => catOther,
  };

  String paidByName(PaidBy p) => switch (p) {
    PaidBy.owner => paidByOwner,
    PaidBy.driver => paidByDriver,
    PaidBy.client => paidByClient,
  };

  String paymentName(PaymentStatus s) => switch (s) {
    PaymentStatus.paid => payPaid,
    PaymentStatus.partial => payPartial,
    PaymentStatus.unpaid => payUnpaid,
  };

  String tripError(TripError e) => switch (e) {
    TripError.fareRequired => errFareRequired,
    TripError.receivedTooHigh => errReceivedTooHigh,
    TripError.distanceInvalid => errDistanceInvalid,
    TripError.vehicleNotFound => errVehicleRequired,
    TripError.receivedNegative ||
    TripError.driverPayNegative ||
    TripError.driverNotFound ||
    TripError.categoryNotFound ||
    TripError.expenseAmountInvalid ||
    TripError.tripNotFound ||
    TripError.paymentInvalid => errUnknown,
  };

  String expenseError(ExpenseError e) => switch (e) {
    ExpenseError.amountInvalid => errAmountInvalid,
    ExpenseError.quantityInvalid => errQtyInvalid,
    ExpenseError.odometerInvalid => errOdoInvalid,
    ExpenseError.vehicleNotFound ||
    ExpenseError.categoryNotFound ||
    ExpenseError.expenseNotFound ||
    ExpenseError.belongsToTrip => errUnknown,
  };

  String categoryError(CategoryError e) => switch (e) {
    CategoryError.emptyName => errCategoryEmpty,
    CategoryError.duplicateName => errCategoryDuplicate,
    CategoryError.notCustom || CategoryError.notFound => errUnknown,
  };
}
