// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Vehicle Khata';

  @override
  String get navHome => 'Home';

  @override
  String get navEntries => 'Entries';

  @override
  String get navReports => 'Reports';

  @override
  String get navMore => 'More';

  @override
  String get homeEmptyTitle => 'No vehicles yet';

  @override
  String get homeEmptyMessage =>
      'Add your first vehicle to start tracking income.';

  @override
  String get entriesEmptyTitle => 'No entries yet';

  @override
  String get entriesEmptyMessage => 'Trips and daily income will appear here.';

  @override
  String get reportsEmptyTitle => 'No reports yet';

  @override
  String get reportsEmptyMessage => 'Reports appear once you log income.';

  @override
  String get settings => 'Settings';

  @override
  String get uiGallery => 'UI gallery';

  @override
  String get language => 'Language';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get numerals => 'Numerals';

  @override
  String get numeralsBangla => '১২৩';

  @override
  String get numeralsLatin => '123';

  @override
  String get grouping => 'Number grouping';

  @override
  String get groupingSouthAsian => '1,23,456';

  @override
  String get groupingInternational => '123,456';

  @override
  String get profitView => 'Profit view';

  @override
  String get profitCash => 'Cash';

  @override
  String get profitAccrual => 'Accrual';

  @override
  String get addIncome => 'Add income';

  @override
  String get keypadDone => 'Done';

  @override
  String get keypadDelete => 'Delete';

  @override
  String get amountLabel => 'Amount';

  @override
  String get chipFuel => 'Fuel';

  @override
  String get chipToll => 'Toll';

  @override
  String get chipParking => 'Parking';

  @override
  String get chipHelper => 'Helper';

  @override
  String get galleryAmountSample => 'Income today';

  @override
  String get galleryTileTitle => 'Rahim · Jama';

  @override
  String get galleryTileSubtitle => 'Paid today';

  @override
  String get galleryButtons => 'Buttons';

  @override
  String get galleryChips => 'Quick chips';

  @override
  String get galleryKeypad => 'Amount keypad';

  @override
  String get galleryTiles => 'List tiles';

  @override
  String get galleryEmpty => 'Empty state';

  @override
  String onbStepOf(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get welcomeTitle => 'Welcome to Vehicle Khata';

  @override
  String get welcomeSubtitle =>
      'Keep your trips, income and profit in one simple ledger.';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get continueLabel => 'Continue';

  @override
  String get backLabel => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get accountTitle => 'Sign in with your phone';

  @override
  String get accountSubtitle =>
      'Your data is backed up and can be restored on a new phone.';

  @override
  String get continueWithoutAccount => 'Continue without account';

  @override
  String get localOnlyNote => 'You can sign in later from More.';

  @override
  String get phoneLabel => 'Mobile number';

  @override
  String get phoneHint => '01XXXXXXXXX';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Enter the 6-digit code';

  @override
  String otpSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get otpLabel => 'Verification code';

  @override
  String get verify => 'Verify';

  @override
  String resendIn(String seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get changeNumber => 'Change number';

  @override
  String get errInvalidPhone => 'Enter a valid mobile number, e.g. 01712345678';

  @override
  String get errRateLimited =>
      'Too many attempts. Please wait a while and try again.';

  @override
  String get errInvalidCode => 'That code is incorrect or has expired.';

  @override
  String get errNetwork =>
      'No internet connection. Try again, or continue without an account.';

  @override
  String get errUnknown => 'Something went wrong. Please try again.';

  @override
  String get account => 'Account';

  @override
  String signedInAs(String phone) {
    return 'Signed in as $phone';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get signInToBackUp => 'Sign in to back up your data';

  @override
  String get signInUnavailable => 'Sign-in is not available in this version.';

  @override
  String get roleTitle => 'How will you use the app?';

  @override
  String get roleOwner => 'I own vehicles';

  @override
  String get roleOwnerDesc => 'Track trips, income, drivers and profit.';

  @override
  String get roleDriver => 'I drive for an owner';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get firstVehicleTitle => 'Add your first vehicle';

  @override
  String get modelTitle => 'How does this vehicle earn?';

  @override
  String get finishSetup => 'Finish setup';

  @override
  String get vehicleNickname => 'Nickname';

  @override
  String get vehicleNicknameHint => 'e.g. Rahim\'s CNG';

  @override
  String get vehicleType => 'Vehicle type';

  @override
  String get typeCng => 'CNG auto-rickshaw';

  @override
  String get typeRickshaw => 'Rickshaw';

  @override
  String get typeEasyBike => 'Easy-bike';

  @override
  String get typePickup => 'Pickup';

  @override
  String get typeMiniTruck => 'Mini-truck';

  @override
  String get typeTruck => 'Truck';

  @override
  String get typeOther => 'Other';

  @override
  String get fuelCng => 'CNG gas';

  @override
  String get fuelOctane => 'Octane';

  @override
  String get fuelPetrol => 'Petrol';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelElectric => 'Electric';

  @override
  String get modelSelf => 'Self-driven';

  @override
  String get modelSalaried => 'Salaried driver';

  @override
  String get modelDailyWage => 'Daily wage';

  @override
  String get modelCommission => 'Commission';

  @override
  String get modelJama => 'Jama (rent)';

  @override
  String get modelContract => 'Per-trip contract';

  @override
  String get modelSelfDesc => 'I drive it myself.';

  @override
  String get modelSalariedDesc => 'Driver gets a monthly salary.';

  @override
  String get modelDailyWageDesc => 'Driver gets a fixed amount per day.';

  @override
  String get modelCommissionDesc => 'Driver gets a share of the income.';

  @override
  String get modelJamaDesc => 'Driver pays me a fixed daily rent.';

  @override
  String get modelContractDesc => 'I am paid per hauling job.';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInGarage => 'In garage';

  @override
  String get statusSold => 'Sold';

  @override
  String get statusArchived => 'Archived';

  @override
  String get filterAll => 'All';

  @override
  String get showArchived => 'Show archived';

  @override
  String get vehiclesTitle => 'Vehicles';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get searchVehicles => 'Search by name or number';

  @override
  String get noResults => 'No vehicles match your search.';

  @override
  String get newVehicle => 'New vehicle';

  @override
  String get editVehicle => 'Edit vehicle';

  @override
  String get regNo => 'Registration number';

  @override
  String get vehicleModel => 'Make / model';

  @override
  String get vehicleYear => 'Year';

  @override
  String get fuelType => 'Fuel type';

  @override
  String get businessModel => 'Business model';

  @override
  String get statusLabel => 'Status';

  @override
  String get photo => 'Photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get purchaseDate => 'Purchase date';

  @override
  String get purchasePrice => 'Purchase price (৳)';

  @override
  String get optional => 'Optional';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get errNicknameEmpty => 'Enter a nickname';

  @override
  String errNicknameTooLong(String max) {
    return 'Nickname is too long (max $max characters)';
  }

  @override
  String get errYearInvalid => 'Enter a valid year';

  @override
  String get errPriceInvalid => 'Enter a valid amount';

  @override
  String dupRegWarning(String name) {
    return 'Another vehicle ($name) already has this number.';
  }

  @override
  String get archive => 'Archive';

  @override
  String get restore => 'Restore';

  @override
  String get archiveConfirmTitle => 'Archive this vehicle?';

  @override
  String get archiveConfirmBody =>
      'It will be hidden from the list but kept in your reports.';

  @override
  String get vehicleArchived => 'Vehicle archived';

  @override
  String get vehicleRestored => 'Vehicle restored';

  @override
  String get changeStatus => 'Change status';

  @override
  String get vehicleNotFound => 'Vehicle not found';

  @override
  String get homeEmptyAction => 'Add your first vehicle';

  @override
  String get security => 'Security';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockOff => 'Off';

  @override
  String get appLockOn => 'PIN lock is on';

  @override
  String get setPinTitle => 'Set a 4-digit PIN';

  @override
  String get confirmPinTitle => 'Confirm your PIN';

  @override
  String get pinMismatch => 'PINs don\'t match. Try again.';

  @override
  String get enterPin => 'Enter your PIN';

  @override
  String get enterCurrentPin => 'Enter your current PIN';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String pinBlocked(String seconds) {
    return 'Too many attempts. Try again in ${seconds}s.';
  }

  @override
  String get useBiometric => 'Unlock with fingerprint or face';

  @override
  String get biometricReason => 'Unlock Vehicle Khata';

  @override
  String get biometricUnavailable => 'Not available on this device';

  @override
  String get lockTimeout => 'Lock after';

  @override
  String get timeoutImmediately => 'Immediately';

  @override
  String get timeout30 => '30 seconds';

  @override
  String get timeout1m => '1 minute';

  @override
  String get timeout5m => '5 minutes';

  @override
  String get changePin => 'Change PIN';

  @override
  String get turnOffLock => 'Turn off app lock';

  @override
  String get unlockTitle => 'Unlock';

  @override
  String get vehicleSaved => 'Vehicle saved';
}
