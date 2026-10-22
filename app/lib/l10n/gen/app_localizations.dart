import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// appName
  ///
  /// In en, this message translates to:
  /// **'Vehicle Khata'**
  String get appName;

  /// navHome
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// navEntries
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get navEntries;

  /// navReports
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// navMore
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// homeEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet'**
  String get homeEmptyTitle;

  /// homeEmptyMessage
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle to start tracking income.'**
  String get homeEmptyMessage;

  /// entriesEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get entriesEmptyTitle;

  /// entriesEmptyMessage
  ///
  /// In en, this message translates to:
  /// **'Trips and daily income will appear here.'**
  String get entriesEmptyMessage;

  /// reportsEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get reportsEmptyTitle;

  /// reportsEmptyMessage
  ///
  /// In en, this message translates to:
  /// **'Reports appear once you log income.'**
  String get reportsEmptyMessage;

  /// settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// uiGallery
  ///
  /// In en, this message translates to:
  /// **'UI gallery'**
  String get uiGallery;

  /// language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// languageBangla
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// languageEnglish
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// numerals
  ///
  /// In en, this message translates to:
  /// **'Numerals'**
  String get numerals;

  /// numeralsBangla
  ///
  /// In en, this message translates to:
  /// **'১২৩'**
  String get numeralsBangla;

  /// numeralsLatin
  ///
  /// In en, this message translates to:
  /// **'123'**
  String get numeralsLatin;

  /// grouping
  ///
  /// In en, this message translates to:
  /// **'Number grouping'**
  String get grouping;

  /// groupingSouthAsian
  ///
  /// In en, this message translates to:
  /// **'1,23,456'**
  String get groupingSouthAsian;

  /// groupingInternational
  ///
  /// In en, this message translates to:
  /// **'123,456'**
  String get groupingInternational;

  /// profitView
  ///
  /// In en, this message translates to:
  /// **'Profit view'**
  String get profitView;

  /// profitCash
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get profitCash;

  /// profitAccrual
  ///
  /// In en, this message translates to:
  /// **'Accrual'**
  String get profitAccrual;

  /// addIncome
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get addIncome;

  /// keypadDone
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get keypadDone;

  /// keypadDelete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get keypadDelete;

  /// amountLabel
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// chipFuel
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get chipFuel;

  /// chipToll
  ///
  /// In en, this message translates to:
  /// **'Toll'**
  String get chipToll;

  /// chipParking
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get chipParking;

  /// chipHelper
  ///
  /// In en, this message translates to:
  /// **'Helper'**
  String get chipHelper;

  /// galleryAmountSample
  ///
  /// In en, this message translates to:
  /// **'Income today'**
  String get galleryAmountSample;

  /// galleryTileTitle
  ///
  /// In en, this message translates to:
  /// **'Rahim · Jama'**
  String get galleryTileTitle;

  /// galleryTileSubtitle
  ///
  /// In en, this message translates to:
  /// **'Paid today'**
  String get galleryTileSubtitle;

  /// galleryButtons
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get galleryButtons;

  /// galleryChips
  ///
  /// In en, this message translates to:
  /// **'Quick chips'**
  String get galleryChips;

  /// galleryKeypad
  ///
  /// In en, this message translates to:
  /// **'Amount keypad'**
  String get galleryKeypad;

  /// galleryTiles
  ///
  /// In en, this message translates to:
  /// **'List tiles'**
  String get galleryTiles;

  /// galleryEmpty
  ///
  /// In en, this message translates to:
  /// **'Empty state'**
  String get galleryEmpty;

  /// onbStepOf
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onbStepOf(String current, String total);

  /// welcomeTitle
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vehicle Khata'**
  String get welcomeTitle;

  /// welcomeSubtitle
  ///
  /// In en, this message translates to:
  /// **'Keep your trips, income and profit in one simple ledger.'**
  String get welcomeSubtitle;

  /// chooseLanguage
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// continueLabel
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// backLabel
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// skip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// skipForNow
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// accountTitle
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone'**
  String get accountTitle;

  /// accountSubtitle
  ///
  /// In en, this message translates to:
  /// **'Your data is backed up and can be restored on a new phone.'**
  String get accountSubtitle;

  /// continueWithoutAccount
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get continueWithoutAccount;

  /// localOnlyNote
  ///
  /// In en, this message translates to:
  /// **'You can sign in later from More.'**
  String get localOnlyNote;

  /// phoneLabel
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneLabel;

  /// phoneHint
  ///
  /// In en, this message translates to:
  /// **'01XXXXXXXXX'**
  String get phoneHint;

  /// sendCode
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// otpTitle
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get otpTitle;

  /// otpSentTo
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String otpSentTo(String phone);

  /// otpLabel
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpLabel;

  /// verify
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// resendIn
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendIn(String seconds);

  /// resendCode
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// changeNumber
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// errInvalidPhone
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number, e.g. 01712345678'**
  String get errInvalidPhone;

  /// errRateLimited
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a while and try again.'**
  String get errRateLimited;

  /// errInvalidCode
  ///
  /// In en, this message translates to:
  /// **'That code is incorrect or has expired.'**
  String get errInvalidCode;

  /// errNetwork
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Try again, or continue without an account.'**
  String get errNetwork;

  /// errUnknown
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errUnknown;

  /// account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// signedInAs
  ///
  /// In en, this message translates to:
  /// **'Signed in as {phone}'**
  String signedInAs(String phone);

  /// signOut
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// signInToBackUp
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up your data'**
  String get signInToBackUp;

  /// signInUnavailable
  ///
  /// In en, this message translates to:
  /// **'Sign-in is not available in this version.'**
  String get signInUnavailable;

  /// roleTitle
  ///
  /// In en, this message translates to:
  /// **'How will you use the app?'**
  String get roleTitle;

  /// roleOwner
  ///
  /// In en, this message translates to:
  /// **'I own vehicles'**
  String get roleOwner;

  /// roleOwnerDesc
  ///
  /// In en, this message translates to:
  /// **'Track trips, income, drivers and profit.'**
  String get roleOwnerDesc;

  /// roleDriver
  ///
  /// In en, this message translates to:
  /// **'I drive for an owner'**
  String get roleDriver;

  /// comingSoon
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// firstVehicleTitle
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle'**
  String get firstVehicleTitle;

  /// modelTitle
  ///
  /// In en, this message translates to:
  /// **'How does this vehicle earn?'**
  String get modelTitle;

  /// finishSetup
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetup;

  /// vehicleNickname
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get vehicleNickname;

  /// vehicleNicknameHint
  ///
  /// In en, this message translates to:
  /// **'e.g. Rahim\'s CNG'**
  String get vehicleNicknameHint;

  /// vehicleType
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get vehicleType;

  /// typeCng
  ///
  /// In en, this message translates to:
  /// **'CNG auto-rickshaw'**
  String get typeCng;

  /// typeRickshaw
  ///
  /// In en, this message translates to:
  /// **'Rickshaw'**
  String get typeRickshaw;

  /// typeEasyBike
  ///
  /// In en, this message translates to:
  /// **'Easy-bike'**
  String get typeEasyBike;

  /// typePickup
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get typePickup;

  /// typeMiniTruck
  ///
  /// In en, this message translates to:
  /// **'Mini-truck'**
  String get typeMiniTruck;

  /// typeTruck
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get typeTruck;

  /// typeOther
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get typeOther;

  /// fuelCng
  ///
  /// In en, this message translates to:
  /// **'CNG gas'**
  String get fuelCng;

  /// fuelOctane
  ///
  /// In en, this message translates to:
  /// **'Octane'**
  String get fuelOctane;

  /// fuelPetrol
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get fuelPetrol;

  /// fuelDiesel
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get fuelDiesel;

  /// fuelElectric
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get fuelElectric;

  /// modelSelf
  ///
  /// In en, this message translates to:
  /// **'Self-driven'**
  String get modelSelf;

  /// modelSalaried
  ///
  /// In en, this message translates to:
  /// **'Salaried driver'**
  String get modelSalaried;

  /// modelDailyWage
  ///
  /// In en, this message translates to:
  /// **'Daily wage'**
  String get modelDailyWage;

  /// modelCommission
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get modelCommission;

  /// modelJama
  ///
  /// In en, this message translates to:
  /// **'Jama (rent)'**
  String get modelJama;

  /// modelContract
  ///
  /// In en, this message translates to:
  /// **'Per-trip contract'**
  String get modelContract;

  /// modelSelfDesc
  ///
  /// In en, this message translates to:
  /// **'I drive it myself.'**
  String get modelSelfDesc;

  /// modelSalariedDesc
  ///
  /// In en, this message translates to:
  /// **'Driver gets a monthly salary.'**
  String get modelSalariedDesc;

  /// modelDailyWageDesc
  ///
  /// In en, this message translates to:
  /// **'Driver gets a fixed amount per day.'**
  String get modelDailyWageDesc;

  /// modelCommissionDesc
  ///
  /// In en, this message translates to:
  /// **'Driver gets a share of the income.'**
  String get modelCommissionDesc;

  /// modelJamaDesc
  ///
  /// In en, this message translates to:
  /// **'Driver pays me a fixed daily rent.'**
  String get modelJamaDesc;

  /// modelContractDesc
  ///
  /// In en, this message translates to:
  /// **'I am paid per hauling job.'**
  String get modelContractDesc;

  /// statusActive
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// statusInGarage
  ///
  /// In en, this message translates to:
  /// **'In garage'**
  String get statusInGarage;

  /// statusSold
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get statusSold;

  /// statusArchived
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchived;

  /// filterAll
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// showArchived
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get showArchived;

  /// vehiclesTitle
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehiclesTitle;

  /// addVehicle
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get addVehicle;

  /// searchVehicles
  ///
  /// In en, this message translates to:
  /// **'Search by name or number'**
  String get searchVehicles;

  /// noResults
  ///
  /// In en, this message translates to:
  /// **'No vehicles match your search.'**
  String get noResults;

  /// newVehicle
  ///
  /// In en, this message translates to:
  /// **'New vehicle'**
  String get newVehicle;

  /// editVehicle
  ///
  /// In en, this message translates to:
  /// **'Edit vehicle'**
  String get editVehicle;

  /// regNo
  ///
  /// In en, this message translates to:
  /// **'Registration number'**
  String get regNo;

  /// vehicleModel
  ///
  /// In en, this message translates to:
  /// **'Make / model'**
  String get vehicleModel;

  /// vehicleYear
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get vehicleYear;

  /// fuelType
  ///
  /// In en, this message translates to:
  /// **'Fuel type'**
  String get fuelType;

  /// businessModel
  ///
  /// In en, this message translates to:
  /// **'Business model'**
  String get businessModel;

  /// statusLabel
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// photo
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// takePhoto
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// chooseFromGallery
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// removePhoto
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// purchaseDate
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get purchaseDate;

  /// purchasePrice
  ///
  /// In en, this message translates to:
  /// **'Purchase price (৳)'**
  String get purchasePrice;

  /// optional
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// errNicknameEmpty
  ///
  /// In en, this message translates to:
  /// **'Enter a nickname'**
  String get errNicknameEmpty;

  /// errNicknameTooLong
  ///
  /// In en, this message translates to:
  /// **'Nickname is too long (max {max} characters)'**
  String errNicknameTooLong(String max);

  /// errYearInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid year'**
  String get errYearInvalid;

  /// errPriceInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get errPriceInvalid;

  /// dupRegWarning
  ///
  /// In en, this message translates to:
  /// **'Another vehicle ({name}) already has this number.'**
  String dupRegWarning(String name);

  /// archive
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// restore
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// archiveConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Archive this vehicle?'**
  String get archiveConfirmTitle;

  /// archiveConfirmBody
  ///
  /// In en, this message translates to:
  /// **'It will be hidden from the list but kept in your reports.'**
  String get archiveConfirmBody;

  /// vehicleArchived
  ///
  /// In en, this message translates to:
  /// **'Vehicle archived'**
  String get vehicleArchived;

  /// vehicleRestored
  ///
  /// In en, this message translates to:
  /// **'Vehicle restored'**
  String get vehicleRestored;

  /// changeStatus
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get changeStatus;

  /// vehicleNotFound
  ///
  /// In en, this message translates to:
  /// **'Vehicle not found'**
  String get vehicleNotFound;

  /// homeEmptyAction
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle'**
  String get homeEmptyAction;

  /// security
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// appLock
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// appLockOff
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get appLockOff;

  /// appLockOn
  ///
  /// In en, this message translates to:
  /// **'PIN lock is on'**
  String get appLockOn;

  /// setPinTitle
  ///
  /// In en, this message translates to:
  /// **'Set a 4-digit PIN'**
  String get setPinTitle;

  /// confirmPinTitle
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get confirmPinTitle;

  /// pinMismatch
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
  String get pinMismatch;

  /// enterPin
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterPin;

  /// enterCurrentPin
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get enterCurrentPin;

  /// wrongPin
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// pinBlocked
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds}s.'**
  String pinBlocked(String seconds);

  /// useBiometric
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint or face'**
  String get useBiometric;

  /// biometricReason
  ///
  /// In en, this message translates to:
  /// **'Unlock Vehicle Khata'**
  String get biometricReason;

  /// biometricUnavailable
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get biometricUnavailable;

  /// lockTimeout
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get lockTimeout;

  /// timeoutImmediately
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get timeoutImmediately;

  /// timeout30
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get timeout30;

  /// timeout1m
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get timeout1m;

  /// timeout5m
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get timeout5m;

  /// changePin
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// turnOffLock
  ///
  /// In en, this message translates to:
  /// **'Turn off app lock'**
  String get turnOffLock;

  /// unlockTitle
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockTitle;

  /// vehicleSaved
  ///
  /// In en, this message translates to:
  /// **'Vehicle saved'**
  String get vehicleSaved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
