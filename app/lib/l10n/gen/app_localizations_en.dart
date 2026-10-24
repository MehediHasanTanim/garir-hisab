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
  String get entriesEmptyTitle => 'No trips yet';

  @override
  String get entriesEmptyMessage => 'Log a trip to see your income and profit.';

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

  @override
  String get driversTitle => 'Drivers';

  @override
  String get addDriver => 'Add driver';

  @override
  String get newDriver => 'New driver';

  @override
  String get editDriver => 'Edit driver';

  @override
  String get searchDrivers => 'Search by name, phone or licence';

  @override
  String get driversEmptyTitle => 'No drivers yet';

  @override
  String get driversEmptyMessage => 'Add the people who drive your vehicles.';

  @override
  String get driversNoResults => 'No drivers match your search.';

  @override
  String get driverStatusActive => 'Working';

  @override
  String get driverStatusLeft => 'Left';

  @override
  String get driverName => 'Full name';

  @override
  String get licenseNo => 'Licence number';

  @override
  String get licenseExpiry => 'Licence expiry';

  @override
  String get nid => 'National ID (NID)';

  @override
  String get nidHelper => 'Stored encrypted on this phone.';

  @override
  String get nidOnFile => 'NID on file';

  @override
  String get address => 'Address';

  @override
  String get emergencyContact => 'Emergency contact';

  @override
  String get joinDate => 'Joining date';

  @override
  String get errNameEmpty => 'Enter the driver\'s name';

  @override
  String errNameTooLong(String max) {
    return 'Name is too long (max $max characters)';
  }

  @override
  String get errNidInvalid => 'NID must be 10, 13 or 17 digits';

  @override
  String get driverSaved => 'Driver saved';

  @override
  String get driverNotFound => 'Driver not found';

  @override
  String get markAsLeft => 'Mark as left';

  @override
  String get reactivate => 'Mark as working again';

  @override
  String markLeftTitle(String name) {
    return 'Mark $name as left?';
  }

  @override
  String get markLeftBody =>
      'Their current vehicle assignments will end today.';

  @override
  String get driverMarkedLeft => 'Marked as left';

  @override
  String get driverReactivated => 'Marked as working';

  @override
  String get licenseExpired => 'Licence expired';

  @override
  String licenseExpiresSoon(String date) {
    return 'Licence expires $date';
  }

  @override
  String licenseValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabAttendance => 'Attendance';

  @override
  String get tabAdvances => 'Advances';

  @override
  String get tabPayouts => 'Payouts';

  @override
  String get workingOn => 'Working on';

  @override
  String get notAssigned => 'Not assigned to a vehicle';

  @override
  String get advancesOwed => 'Advances owed';

  @override
  String sinceDate(String date) {
    return 'Since $date';
  }

  @override
  String get contactDetails => 'Details';

  @override
  String get attPresent => 'Present';

  @override
  String get attAbsent => 'Absent';

  @override
  String get attHalfDay => 'Half day';

  @override
  String get attUnmarked => 'Not marked';

  @override
  String get attClear => 'Clear mark';

  @override
  String get prevMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String markDay(String date) {
    return 'Mark $date';
  }

  @override
  String get month1 => 'January';

  @override
  String get month2 => 'February';

  @override
  String get month3 => 'March';

  @override
  String get month4 => 'April';

  @override
  String get month5 => 'May';

  @override
  String get month6 => 'June';

  @override
  String get month7 => 'July';

  @override
  String get month8 => 'August';

  @override
  String get month9 => 'September';

  @override
  String get month10 => 'October';

  @override
  String get month11 => 'November';

  @override
  String get month12 => 'December';

  @override
  String get wdMon => 'Mon';

  @override
  String get wdTue => 'Tue';

  @override
  String get wdWed => 'Wed';

  @override
  String get wdThu => 'Thu';

  @override
  String get wdFri => 'Fri';

  @override
  String get wdSat => 'Sat';

  @override
  String get wdSun => 'Sun';

  @override
  String get advancesEmptyTitle => 'No advances';

  @override
  String get advancesEmptyMessage =>
      'Advances you give are deducted from the next payout.';

  @override
  String get giveAdvance => 'Give advance';

  @override
  String get advanceAmount => 'Amount (৳)';

  @override
  String get advanceDate => 'Date';

  @override
  String get advanceNote => 'Note (optional)';

  @override
  String get advanceSaved => 'Advance recorded';

  @override
  String get errAmountInvalid => 'Enter an amount greater than zero';

  @override
  String advanceRecovered(String amount) {
    return 'Recovered $amount';
  }

  @override
  String advanceRemaining(String amount) {
    return 'Remaining $amount';
  }

  @override
  String get advanceSettled => 'Fully recovered';

  @override
  String get deleteAdvanceTitle => 'Delete this advance?';

  @override
  String get errAdvanceRecovered =>
      'This advance was already recovered in a payout. Void that payout first.';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get editLabel => 'Edit';

  @override
  String get payoutsEmptyTitle => 'No payouts yet';

  @override
  String get payoutsEmptyMessage =>
      'Record a payout to settle salary and advances.';

  @override
  String get newPayout => 'New payout';

  @override
  String get payoutTitle => 'Record payout';

  @override
  String get payPeriod => 'Period';

  @override
  String get customRange => 'Custom dates';

  @override
  String get payVehicle => 'Vehicle';

  @override
  String get payEarned => 'Earned';

  @override
  String get payAdjustment => 'Bonus (+) or penalty (−) (৳)';

  @override
  String get payAdjustmentNote => 'Reason (optional)';

  @override
  String get payAdvancesDeducted => 'Advances recovered';

  @override
  String get payNet => 'Pay now';

  @override
  String get payAdvancesCarried => 'Advances still owed after this payout';

  @override
  String get recordPayout => 'Record payout';

  @override
  String get payoutRecorded => 'Payout recorded';

  @override
  String get payoutAlreadyRecorded => 'This period was already recorded';

  @override
  String get payoutVoid => 'Void payout';

  @override
  String get payoutVoidTitle => 'Void this payout?';

  @override
  String get payoutVoidBody =>
      'Advance recoveries are released and the period can be paid again.';

  @override
  String get payoutVoided => 'Payout voided';

  @override
  String payoutPeriodClipped(String start, String end) {
    return 'Only $start to $end is covered by this assignment.';
  }

  @override
  String get payoutTripsNote =>
      'Trip pay is taken from the trips you log for this driver.';

  @override
  String get payErrNotPayable =>
      'Jama drivers pay the owner, so there is nothing to pay out.';

  @override
  String get payErrOutside =>
      'This vehicle assignment does not cover that period.';

  @override
  String get payErrOverlap =>
      'Another payout already covers part of this period.';

  @override
  String get payErrNothing => 'There is nothing to pay for this period.';

  @override
  String payLineSalary(String days) {
    return 'Salary ($days days)';
  }

  @override
  String payLineWages(String days) {
    return 'Wages ($days days)';
  }

  @override
  String payLineTripFees(String count) {
    return 'Trip fees ($count trips)';
  }

  @override
  String get payLineCommission => 'Commission';

  @override
  String paidOn(String date) {
    return 'Paid on $date';
  }

  @override
  String dateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get driverAndPay => 'Driver & pay';

  @override
  String get assignDriver => 'Assign driver';

  @override
  String get changeDriver => 'Change driver or pay';

  @override
  String get endAssignment => 'End assignment';

  @override
  String get endAssignmentTitle => 'End this assignment?';

  @override
  String endAssignmentBody(String driver, String vehicle) {
    return '$driver will no longer drive $vehicle after today.';
  }

  @override
  String get assignmentEnded => 'Assignment ended';

  @override
  String get currentDriver => 'Current driver';

  @override
  String get assignmentHistory => 'Past drivers';

  @override
  String get noDriverAssigned => 'No driver assigned';

  @override
  String get noDriverAssignedHint =>
      'Assign a driver and choose how they are paid.';

  @override
  String get selectDriver => 'Driver';

  @override
  String get startDate => 'Starts on';

  @override
  String replacesNote(String driver, String date) {
    return '$driver will stop on $date.';
  }

  @override
  String get noActiveDrivers => 'Add a driver first.';

  @override
  String get selfDrivenNoDriver =>
      'Self-driven vehicles don\'t have a driver. Change the vehicle\'s business model to assign one.';

  @override
  String get assignmentSaved => 'Driver assigned';

  @override
  String get errAssignStartAfter =>
      'The new start date must be after the current assignment began.';

  @override
  String get errAssignOverlap => 'That date overlaps an earlier assignment.';

  @override
  String get errAssignPayType => 'That pay type does not suit this vehicle.';

  @override
  String get errAssignDriverLeft => 'This driver has left.';

  @override
  String get ongoing => 'now';

  @override
  String get ptSalary => 'Monthly salary';

  @override
  String get ptDailyWage => 'Daily wage';

  @override
  String get ptPerTrip => 'Per trip';

  @override
  String get ptCommission => 'Commission';

  @override
  String get ptJama => 'Jama (rent)';

  @override
  String get ptMixed => 'Salary + commission';

  @override
  String get payTypeLabel => 'How is the driver paid?';

  @override
  String get fMonthly => 'Monthly salary (৳)';

  @override
  String get fBaseSalary => 'Base salary per month (৳)';

  @override
  String get fPerDay => 'Pay per day (৳)';

  @override
  String get fHalfDay => 'Half-day pay (% of a full day)';

  @override
  String get fPerTrip => 'Pay per trip (৳)';

  @override
  String get fRate => 'Commission (% of fare)';

  @override
  String get fBasis => 'Commission on';

  @override
  String get basisBefore => 'Fare before expenses';

  @override
  String get basisAfter => 'Fare after expenses';

  @override
  String get fJamaAmount => 'Jama amount (৳)';

  @override
  String get fFrequency => 'Collected';

  @override
  String get freqDaily => 'Daily';

  @override
  String get freqWeekly => 'Weekly';

  @override
  String get fOffDays => 'Days with no jama';

  @override
  String get errPayAmount => 'Enter an amount greater than zero';

  @override
  String get errPayRate => 'Enter a percentage between 0 and 100';

  @override
  String get errPayOffDays => 'Leave at least one day when jama is collected';

  @override
  String sumSalary(String amount) {
    return '$amount per month';
  }

  @override
  String sumDailyWage(String amount, String rate) {
    return '$amount per day (half day $rate%)';
  }

  @override
  String sumPerTrip(String amount) {
    return '$amount per trip';
  }

  @override
  String sumCommissionBefore(String rate) {
    return '$rate% of fare before expenses';
  }

  @override
  String sumCommissionAfter(String rate) {
    return '$rate% of fare after expenses';
  }

  @override
  String sumJamaDaily(String amount) {
    return '$amount per day';
  }

  @override
  String sumJamaWeekly(String amount) {
    return '$amount per week';
  }

  @override
  String sumMixed(String amount, String rate) {
    return '$amount per month + $rate% commission';
  }

  @override
  String get today => 'Today';

  @override
  String get errSelectDriver => 'Choose a driver';

  @override
  String get catFuel => 'Fuel / CNG gas';

  @override
  String get catToll => 'Toll';

  @override
  String get catParking => 'Parking';

  @override
  String get catHelper => 'Helper';

  @override
  String get catPolice => 'Police / informal';

  @override
  String get catFood => 'Driver food';

  @override
  String get catRepair => 'Repair';

  @override
  String get catParts => 'Spare parts';

  @override
  String get catTyre => 'Tyre';

  @override
  String get catService => 'Oil change / service';

  @override
  String get catWashing => 'Washing';

  @override
  String get catInsurance => 'Insurance';

  @override
  String get catRegistration => 'Registration / tax token';

  @override
  String get catLoan => 'Loan installment';

  @override
  String get catOther => 'Other';

  @override
  String get addTrip => 'Add trip';

  @override
  String get newTrip => 'New trip';

  @override
  String get editTrip => 'Edit trip';

  @override
  String get tripTitle => 'Trip';

  @override
  String get needVehicleFirst => 'Add a vehicle before logging trips.';

  @override
  String get noDriverOption => 'No driver';

  @override
  String get tripFare => 'Fare';

  @override
  String get tapToEnter => 'Tap to enter';

  @override
  String get tripFrom => 'From';

  @override
  String get tripTo => 'To';

  @override
  String get tripDistance => 'Distance (km)';

  @override
  String get tripLoad => 'Load or passengers';

  @override
  String get tripWhen => 'Date and time';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get addExpenseMore => 'More';

  @override
  String get noExpenses => 'No expenses added';

  @override
  String get expenseCategory => 'Category';

  @override
  String get paidBy => 'Paid by';

  @override
  String get paidByOwner => 'Owner';

  @override
  String get paidByDriver => 'Driver';

  @override
  String get paidByClient => 'Client';

  @override
  String get reimbursable => 'I will pay the driver back';

  @override
  String get fuelQty => 'Quantity (litres or m³)';

  @override
  String get odometer => 'Odometer (km)';

  @override
  String get receipt => 'Receipt photo';

  @override
  String get addReceipt => 'Add receipt photo';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get addExpense => 'Add expense';

  @override
  String get newCategory => 'New category…';

  @override
  String get categoryName => 'Category name';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get payPaid => 'Paid';

  @override
  String get payPartial => 'Partly paid';

  @override
  String get payUnpaid => 'Unpaid';

  @override
  String get amountReceived => 'Amount received';

  @override
  String dueAmount(String amount) {
    return 'Due $amount';
  }

  @override
  String get errReceivedTooHigh => 'Received cannot be more than the fare';

  @override
  String get recordPayment => 'Record payment';

  @override
  String get paymentRecorded => 'Payment recorded';

  @override
  String get markFullyPaid => 'Mark fully paid';

  @override
  String errPaymentInvalid(String amount) {
    return 'Enter an amount up to $amount';
  }

  @override
  String get driverPayLabel => 'Driver pay';

  @override
  String get driverPayAuto => 'calculated';

  @override
  String get driverPayCustom => 'set by you';

  @override
  String get resetToAuto => 'Use calculated amount';

  @override
  String get profitLabel => 'Profit';

  @override
  String get lossLabel => 'Loss';

  @override
  String get errFareRequired => 'Enter the fare';

  @override
  String get errDistanceInvalid => 'Enter a valid distance';

  @override
  String get errQtyInvalid => 'Enter a valid quantity';

  @override
  String get errOdoInvalid => 'Enter a valid odometer reading';

  @override
  String get errVehicleRequired => 'Choose a vehicle';

  @override
  String get repeatTrip => 'Repeat trip';

  @override
  String get addReturnLeg => 'Add return leg';

  @override
  String get returnLegBadge => 'Return leg';

  @override
  String get deleteTrip => 'Delete trip';

  @override
  String get deleteTripTitle => 'Delete this trip?';

  @override
  String get deleteTripBody =>
      'The trip and its expenses are removed from your reports.';

  @override
  String get tripDeleted => 'Trip deleted';

  @override
  String get tripSaved => 'Trip saved';

  @override
  String get tripNotFound => 'Trip not found';

  @override
  String get filterPeriodAll => 'All time';

  @override
  String get filterToday => 'Today';

  @override
  String get filterThisMonth => 'This month';

  @override
  String get filterLastMonth => 'Last month';

  @override
  String get filterVehicleAll => 'All vehicles';

  @override
  String get noTripsMatch => 'No trips match these filters.';

  @override
  String get vehicleExpenses => 'Vehicle expenses';

  @override
  String get vehicleExpensesEmptyTitle => 'No expenses yet';

  @override
  String get vehicleExpensesEmptyMessage =>
      'Repairs, service, insurance and other costs of this vehicle go here.';

  @override
  String get fuelEfficiency => 'Fuel efficiency';

  @override
  String fuelEffAverage(String value) {
    return '$value km per litre / m³';
  }

  @override
  String fuelCostPerKm(String amount) {
    return '$amount per km';
  }

  @override
  String get fuelEffNeedMore =>
      'Add two fuel entries with quantity and odometer to see efficiency.';

  @override
  String get expenseDeleteTitle => 'Delete this expense?';

  @override
  String get expenseSaved => 'Expense saved';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get expenseCategories => 'Expense categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get renameCategory => 'Rename';

  @override
  String get categoriesHint =>
      'Archived categories are hidden from new expenses but keep your old records.';

  @override
  String get errCategoryDuplicate => 'A category with this name already exists';

  @override
  String get errCategoryEmpty => 'Enter a name';

  @override
  String get unitKm => 'km';

  @override
  String todayWithVehicle(String vehicle) {
    return 'Today · $vehicle';
  }

  @override
  String get incomeToday => 'Income today';

  @override
  String get profitToday => 'Profit today';

  @override
  String get gasFuel => 'Gas / fuel';

  @override
  String get closeDay => 'Close day';

  @override
  String incomeAdded(String amount) {
    return 'Added $amount';
  }

  @override
  String get undo => 'Undo';

  @override
  String get incomeUndone => 'Undone';

  @override
  String get closeDayTitle => 'Close the day';

  @override
  String get closeDayIncome => 'Income';

  @override
  String get closeDayRunning => 'Running costs';

  @override
  String get closeDayDriver => 'Driver cost';

  @override
  String get closeDayVehicleCosts => 'Vehicle costs';

  @override
  String get closeDayNet => 'Net profit';

  @override
  String get settlementTitle => 'Settle with the driver';

  @override
  String settlementJama(String amount, String driver) {
    return 'Collect jama $amount from $driver today.';
  }

  @override
  String settlementSalary(String driver) {
    return '$driver is on a monthly salary, which builds up each day.';
  }

  @override
  String settlementDaily(String driver) {
    return '$driver is paid per day worked. Record a payout when you pay.';
  }

  @override
  String settlementPerTrip(String driver) {
    return '$driver is paid from trips. Record a payout when you pay.';
  }

  @override
  String get settlementNone => 'No driver settlement is due.';

  @override
  String get periodWeek => 'This week';

  @override
  String get profitSummary => 'Profit summary';

  @override
  String get repIncome => 'Income';

  @override
  String get repRunning => 'Running costs';

  @override
  String get repDriver => 'Driver cost';

  @override
  String get repOperating => 'Operating profit';

  @override
  String get repVehicleCosts => 'Vehicle costs';

  @override
  String get repNet => 'Net profit';

  @override
  String get repReceivable => 'Not yet received';

  @override
  String get repPerTrip => 'Per trip';

  @override
  String get repPerDay => 'Per working day';

  @override
  String get vehiclesRanking => 'Vehicles';

  @override
  String get trendTitle => 'Profit trend';

  @override
  String get incomeVsCost => 'Income and costs';

  @override
  String get expenseMixTitle => 'Where the money went';

  @override
  String get noDataYet => 'Nothing recorded for this period yet.';

  @override
  String get amortizeFixed => 'Spread vehicle costs over the month';

  @override
  String get amortizeFixedHint =>
      'Repairs, insurance and loan instalments are shared across the days of the month instead of the day they were paid.';

  @override
  String get chartIncome => 'Income';

  @override
  String get chartCosts => 'Costs';

  @override
  String get chartProfit => 'Profit';

  @override
  String get generateDemo => 'Generate demo data';

  @override
  String get demoDone => 'Demo data created';

  @override
  String get syncTitle => 'Sync & backup';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncUpToDate => 'Everything is backed up';

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String get syncOffline => 'No connection. Will try again soon.';

  @override
  String get syncError => 'Something went wrong. Will try again soon.';

  @override
  String get syncSignedOut => 'Sign in again to keep backing up';

  @override
  String get syncDisabled =>
      'Not signed in. Your data stays on this phone only.';

  @override
  String get syncWrongAccount =>
      'This phone holds data from another account, so it is not synced.';

  @override
  String syncLast(String time) {
    return 'Last backed up $time';
  }

  @override
  String get syncNever => 'Not backed up yet';

  @override
  String syncWaiting(String count) {
    return '$count waiting to be sent';
  }

  @override
  String get syncIssuesTitle => 'Needs attention';

  @override
  String syncIssuesBody(String count) {
    return '$count items could not be synced';
  }

  @override
  String get syncRetry => 'Try again';

  @override
  String get syncRestore => 'Restore from backup';

  @override
  String get syncRestoreHelp =>
      'Fetch everything saved online onto this phone. Changes here that are not sent yet are kept.';

  @override
  String get syncRestoreConfirmTitle => 'Restore from backup?';

  @override
  String get syncRestoreConfirmBody =>
      'All your saved data will be fetched again. Nothing on this phone is deleted.';

  @override
  String get syncRestoreAction => 'Restore';

  @override
  String get exportTitle => 'Export my data';

  @override
  String get exportExplain =>
      'Creates one zip file with all your vehicles, drivers, trips, expenses and payments. It contains a JSON copy and spreadsheet (CSV) files you can open in Excel. Amounts are in poisha.';

  @override
  String get exportNidNote => 'Drivers\' national ID numbers are not included.';

  @override
  String get exportAction => 'Export and share';

  @override
  String get exportPreparing => 'Preparing…';

  @override
  String get exportFailed => 'Could not create the file. Please try again.';

  @override
  String get stmtTitle => 'Driver statement';

  @override
  String get stmtThisMonth => 'This month';

  @override
  String get stmtLastMonth => 'Last month';

  @override
  String get stmtLast3 => 'Last 3 months';

  @override
  String get stmtAllTime => 'All time';

  @override
  String get stmtPayouts => 'Payouts';

  @override
  String get stmtAdvances => 'Advances given';

  @override
  String get stmtEarned => 'Earned';

  @override
  String get stmtAdjustment => 'Bonus / penalty';

  @override
  String get stmtRecovered => 'Advances recovered';

  @override
  String get stmtPaid => 'Paid';

  @override
  String get stmtTotalPaid => 'Total paid';

  @override
  String get stmtAdvancesOwed => 'Advances still owed';

  @override
  String get stmtNone => 'Nothing in this period';

  @override
  String get stmtShare => 'Share PDF';

  @override
  String get stmtPreparing => 'Preparing…';

  @override
  String get stmtFailed => 'Could not create the PDF. Please try again.';

  @override
  String get stmtPreparedWith => 'Prepared with Vehicle Khata';

  @override
  String stmtShareText(String name) {
    return 'Statement for $name';
  }

  @override
  String stmtPaidOn(String date) {
    return 'Paid on $date';
  }

  @override
  String stmtRemaining(String amount) {
    return 'Still owed: $amount';
  }

  @override
  String stmtPeriodLine(String from, String to) {
    return '$from to $to';
  }

  @override
  String get stmtMenu => 'Statement (PDF)';

  @override
  String get jamaTitle => 'Jama';

  @override
  String get jamaReportTitle => 'Jama report';

  @override
  String get jamaNoDriver =>
      'No jama driver on this vehicle yet. Assign one with a jama pay type.';

  @override
  String jamaDriverLine(String name, String amount, String frequency) {
    return '$name · $amount $frequency';
  }

  @override
  String get jamaDaily => 'daily';

  @override
  String get jamaWeekly => 'weekly';

  @override
  String get jamaBaki => 'Baki (owed)';

  @override
  String get jamaAllPaid => 'All paid';

  @override
  String jamaCollect(String amount) {
    return 'Collect $amount';
  }

  @override
  String get jamaOtherAmount => 'Other amount';

  @override
  String get jamaCollectTitle => 'Jama received';

  @override
  String jamaCollected(String amount) {
    return 'Collected $amount';
  }

  @override
  String get jamaUndo => 'Undo';

  @override
  String get jamaStatusPaid => 'Paid';

  @override
  String get jamaStatusPartial => 'Partly paid';

  @override
  String get jamaStatusUnpaid => 'Not paid';

  @override
  String get jamaStatusWaived => 'Waived';

  @override
  String get jamaStatusOff => 'No jama';

  @override
  String jamaDayDue(String amount) {
    return 'Still owed: $amount';
  }

  @override
  String jamaDayPaid(String amount) {
    return 'Paid: $amount';
  }

  @override
  String get jamaWaive => 'Waive what is owed';

  @override
  String get jamaWaived => 'Waived';

  @override
  String get jamaPayments => 'Payments';

  @override
  String get jamaVoid => 'Cancel this payment';

  @override
  String get jamaVoided => 'Payment cancelled';

  @override
  String get jamaGarage => 'Vehicle off the road';

  @override
  String get jamaGarageStart => 'Vehicle is in the garage';

  @override
  String get jamaGaragePause => 'No jama while off the road';

  @override
  String get jamaGarageWaive => 'Jama due, but forgiven';

  @override
  String jamaGarageSince(String date) {
    return 'Since $date';
  }

  @override
  String jamaGaragePeriod(String from, String to) {
    return '$from to $to';
  }

  @override
  String get jamaGarageBack => 'Back on the road';

  @override
  String get jamaDeposit => 'Security deposit';

  @override
  String jamaDepositBalance(String amount) {
    return 'Held: $amount';
  }

  @override
  String get jamaDepositAdd => 'Add deposit';

  @override
  String get jamaDepositRefund => 'Refund';

  @override
  String get jamaDepositDeduct => 'Deduct';

  @override
  String get jamaExpected => 'Expected';

  @override
  String get jamaCollectedLabel => 'Collected';

  @override
  String jamaRate(String percent) {
    return 'Collected $percent% of what was due';
  }

  @override
  String get jamaDefaulters => 'Behind on jama';

  @override
  String get jamaNoDefaulters => 'Nobody is behind.';

  @override
  String jamaDefaulterLine(String days, String date) {
    return '$days days missed, since $date';
  }

  @override
  String get jamaNoData => 'No jama in this month';

  @override
  String get jamaErrExceeds => 'That is more than is owed.';

  @override
  String get jamaErrNothing => 'Nothing is owed right now.';

  @override
  String get jamaErrDeposit => 'That is more than the deposit held.';

  @override
  String get jamaErrGeneric => 'Could not save. Please try again.';
}
