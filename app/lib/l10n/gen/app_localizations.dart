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
  /// **'No trips yet'**
  String get entriesEmptyTitle;

  /// entriesEmptyMessage
  ///
  /// In en, this message translates to:
  /// **'Log a trip to see your income and profit.'**
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

  /// driversTitle
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get driversTitle;

  /// addDriver
  ///
  /// In en, this message translates to:
  /// **'Add driver'**
  String get addDriver;

  /// newDriver
  ///
  /// In en, this message translates to:
  /// **'New driver'**
  String get newDriver;

  /// editDriver
  ///
  /// In en, this message translates to:
  /// **'Edit driver'**
  String get editDriver;

  /// searchDrivers
  ///
  /// In en, this message translates to:
  /// **'Search by name, phone or licence'**
  String get searchDrivers;

  /// driversEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'No drivers yet'**
  String get driversEmptyTitle;

  /// driversEmptyMessage
  ///
  /// In en, this message translates to:
  /// **'Add the people who drive your vehicles.'**
  String get driversEmptyMessage;

  /// driversNoResults
  ///
  /// In en, this message translates to:
  /// **'No drivers match your search.'**
  String get driversNoResults;

  /// driverStatusActive
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get driverStatusActive;

  /// driverStatusLeft
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get driverStatusLeft;

  /// driverName
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get driverName;

  /// licenseNo
  ///
  /// In en, this message translates to:
  /// **'Licence number'**
  String get licenseNo;

  /// licenseExpiry
  ///
  /// In en, this message translates to:
  /// **'Licence expiry'**
  String get licenseExpiry;

  /// nid
  ///
  /// In en, this message translates to:
  /// **'National ID (NID)'**
  String get nid;

  /// nidHelper
  ///
  /// In en, this message translates to:
  /// **'Stored encrypted on this phone.'**
  String get nidHelper;

  /// nidOnFile
  ///
  /// In en, this message translates to:
  /// **'NID on file'**
  String get nidOnFile;

  /// address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// emergencyContact
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get emergencyContact;

  /// joinDate
  ///
  /// In en, this message translates to:
  /// **'Joining date'**
  String get joinDate;

  /// errNameEmpty
  ///
  /// In en, this message translates to:
  /// **'Enter the driver\'s name'**
  String get errNameEmpty;

  /// errNameTooLong
  ///
  /// In en, this message translates to:
  /// **'Name is too long (max {max} characters)'**
  String errNameTooLong(String max);

  /// errNidInvalid
  ///
  /// In en, this message translates to:
  /// **'NID must be 10, 13 or 17 digits'**
  String get errNidInvalid;

  /// driverSaved
  ///
  /// In en, this message translates to:
  /// **'Driver saved'**
  String get driverSaved;

  /// driverNotFound
  ///
  /// In en, this message translates to:
  /// **'Driver not found'**
  String get driverNotFound;

  /// markAsLeft
  ///
  /// In en, this message translates to:
  /// **'Mark as left'**
  String get markAsLeft;

  /// reactivate
  ///
  /// In en, this message translates to:
  /// **'Mark as working again'**
  String get reactivate;

  /// markLeftTitle
  ///
  /// In en, this message translates to:
  /// **'Mark {name} as left?'**
  String markLeftTitle(String name);

  /// markLeftBody
  ///
  /// In en, this message translates to:
  /// **'Their current vehicle assignments will end today.'**
  String get markLeftBody;

  /// driverMarkedLeft
  ///
  /// In en, this message translates to:
  /// **'Marked as left'**
  String get driverMarkedLeft;

  /// driverReactivated
  ///
  /// In en, this message translates to:
  /// **'Marked as working'**
  String get driverReactivated;

  /// licenseExpired
  ///
  /// In en, this message translates to:
  /// **'Licence expired'**
  String get licenseExpired;

  /// licenseExpiresSoon
  ///
  /// In en, this message translates to:
  /// **'Licence expires {date}'**
  String licenseExpiresSoon(String date);

  /// licenseValidUntil
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String licenseValidUntil(String date);

  /// tabOverview
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tabOverview;

  /// tabAttendance
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get tabAttendance;

  /// tabAdvances
  ///
  /// In en, this message translates to:
  /// **'Advances'**
  String get tabAdvances;

  /// tabPayouts
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get tabPayouts;

  /// workingOn
  ///
  /// In en, this message translates to:
  /// **'Working on'**
  String get workingOn;

  /// notAssigned
  ///
  /// In en, this message translates to:
  /// **'Not assigned to a vehicle'**
  String get notAssigned;

  /// advancesOwed
  ///
  /// In en, this message translates to:
  /// **'Advances owed'**
  String get advancesOwed;

  /// sinceDate
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String sinceDate(String date);

  /// contactDetails
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get contactDetails;

  /// attPresent
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attPresent;

  /// attAbsent
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attAbsent;

  /// attHalfDay
  ///
  /// In en, this message translates to:
  /// **'Half day'**
  String get attHalfDay;

  /// attUnmarked
  ///
  /// In en, this message translates to:
  /// **'Not marked'**
  String get attUnmarked;

  /// attClear
  ///
  /// In en, this message translates to:
  /// **'Clear mark'**
  String get attClear;

  /// prevMonth
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get prevMonth;

  /// nextMonth
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// markDay
  ///
  /// In en, this message translates to:
  /// **'Mark {date}'**
  String markDay(String date);

  /// month1
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get month1;

  /// month2
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get month2;

  /// month3
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get month3;

  /// month4
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get month4;

  /// month5
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month5;

  /// month6
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get month6;

  /// month7
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get month7;

  /// month8
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get month8;

  /// month9
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get month9;

  /// month10
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get month10;

  /// month11
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get month11;

  /// month12
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get month12;

  /// wdMon
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get wdMon;

  /// wdTue
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get wdTue;

  /// wdWed
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wdWed;

  /// wdThu
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get wdThu;

  /// wdFri
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get wdFri;

  /// wdSat
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get wdSat;

  /// wdSun
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get wdSun;

  /// advancesEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'No advances'**
  String get advancesEmptyTitle;

  /// advancesEmptyMessage
  ///
  /// In en, this message translates to:
  /// **'Advances you give are deducted from the next payout.'**
  String get advancesEmptyMessage;

  /// giveAdvance
  ///
  /// In en, this message translates to:
  /// **'Give advance'**
  String get giveAdvance;

  /// advanceAmount
  ///
  /// In en, this message translates to:
  /// **'Amount (৳)'**
  String get advanceAmount;

  /// advanceDate
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get advanceDate;

  /// advanceNote
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get advanceNote;

  /// advanceSaved
  ///
  /// In en, this message translates to:
  /// **'Advance recorded'**
  String get advanceSaved;

  /// errAmountInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get errAmountInvalid;

  /// advanceRecovered
  ///
  /// In en, this message translates to:
  /// **'Recovered {amount}'**
  String advanceRecovered(String amount);

  /// advanceRemaining
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount}'**
  String advanceRemaining(String amount);

  /// advanceSettled
  ///
  /// In en, this message translates to:
  /// **'Fully recovered'**
  String get advanceSettled;

  /// deleteAdvanceTitle
  ///
  /// In en, this message translates to:
  /// **'Delete this advance?'**
  String get deleteAdvanceTitle;

  /// errAdvanceRecovered
  ///
  /// In en, this message translates to:
  /// **'This advance was already recovered in a payout. Void that payout first.'**
  String get errAdvanceRecovered;

  /// deleteLabel
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// editLabel
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// payoutsEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'No payouts yet'**
  String get payoutsEmptyTitle;

  /// payoutsEmptyMessage
  ///
  /// In en, this message translates to:
  /// **'Record a payout to settle salary and advances.'**
  String get payoutsEmptyMessage;

  /// newPayout
  ///
  /// In en, this message translates to:
  /// **'New payout'**
  String get newPayout;

  /// payoutTitle
  ///
  /// In en, this message translates to:
  /// **'Record payout'**
  String get payoutTitle;

  /// payPeriod
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get payPeriod;

  /// customRange
  ///
  /// In en, this message translates to:
  /// **'Custom dates'**
  String get customRange;

  /// payVehicle
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get payVehicle;

  /// payEarned
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get payEarned;

  /// payAdjustment
  ///
  /// In en, this message translates to:
  /// **'Bonus (+) or penalty (−) (৳)'**
  String get payAdjustment;

  /// payAdjustmentNote
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get payAdjustmentNote;

  /// payAdvancesDeducted
  ///
  /// In en, this message translates to:
  /// **'Advances recovered'**
  String get payAdvancesDeducted;

  /// payNet
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get payNet;

  /// payAdvancesCarried
  ///
  /// In en, this message translates to:
  /// **'Advances still owed after this payout'**
  String get payAdvancesCarried;

  /// recordPayout
  ///
  /// In en, this message translates to:
  /// **'Record payout'**
  String get recordPayout;

  /// payoutRecorded
  ///
  /// In en, this message translates to:
  /// **'Payout recorded'**
  String get payoutRecorded;

  /// payoutAlreadyRecorded
  ///
  /// In en, this message translates to:
  /// **'This period was already recorded'**
  String get payoutAlreadyRecorded;

  /// payoutVoid
  ///
  /// In en, this message translates to:
  /// **'Void payout'**
  String get payoutVoid;

  /// payoutVoidTitle
  ///
  /// In en, this message translates to:
  /// **'Void this payout?'**
  String get payoutVoidTitle;

  /// payoutVoidBody
  ///
  /// In en, this message translates to:
  /// **'Advance recoveries are released and the period can be paid again.'**
  String get payoutVoidBody;

  /// payoutVoided
  ///
  /// In en, this message translates to:
  /// **'Payout voided'**
  String get payoutVoided;

  /// payoutPeriodClipped
  ///
  /// In en, this message translates to:
  /// **'Only {start} to {end} is covered by this assignment.'**
  String payoutPeriodClipped(String start, String end);

  /// payoutTripsNote
  ///
  /// In en, this message translates to:
  /// **'Trip pay is taken from the trips you log for this driver.'**
  String get payoutTripsNote;

  /// payErrNotPayable
  ///
  /// In en, this message translates to:
  /// **'Jama drivers pay the owner, so there is nothing to pay out.'**
  String get payErrNotPayable;

  /// payErrOutside
  ///
  /// In en, this message translates to:
  /// **'This vehicle assignment does not cover that period.'**
  String get payErrOutside;

  /// payErrOverlap
  ///
  /// In en, this message translates to:
  /// **'Another payout already covers part of this period.'**
  String get payErrOverlap;

  /// payErrNothing
  ///
  /// In en, this message translates to:
  /// **'There is nothing to pay for this period.'**
  String get payErrNothing;

  /// payLineSalary
  ///
  /// In en, this message translates to:
  /// **'Salary ({days} days)'**
  String payLineSalary(String days);

  /// payLineWages
  ///
  /// In en, this message translates to:
  /// **'Wages ({days} days)'**
  String payLineWages(String days);

  /// payLineTripFees
  ///
  /// In en, this message translates to:
  /// **'Trip fees ({count} trips)'**
  String payLineTripFees(String count);

  /// payLineCommission
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get payLineCommission;

  /// paidOn
  ///
  /// In en, this message translates to:
  /// **'Paid on {date}'**
  String paidOn(String date);

  /// dateRange
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String dateRange(String start, String end);

  /// driverAndPay
  ///
  /// In en, this message translates to:
  /// **'Driver & pay'**
  String get driverAndPay;

  /// assignDriver
  ///
  /// In en, this message translates to:
  /// **'Assign driver'**
  String get assignDriver;

  /// changeDriver
  ///
  /// In en, this message translates to:
  /// **'Change driver or pay'**
  String get changeDriver;

  /// endAssignment
  ///
  /// In en, this message translates to:
  /// **'End assignment'**
  String get endAssignment;

  /// endAssignmentTitle
  ///
  /// In en, this message translates to:
  /// **'End this assignment?'**
  String get endAssignmentTitle;

  /// endAssignmentBody
  ///
  /// In en, this message translates to:
  /// **'{driver} will no longer drive {vehicle} after today.'**
  String endAssignmentBody(String driver, String vehicle);

  /// assignmentEnded
  ///
  /// In en, this message translates to:
  /// **'Assignment ended'**
  String get assignmentEnded;

  /// currentDriver
  ///
  /// In en, this message translates to:
  /// **'Current driver'**
  String get currentDriver;

  /// assignmentHistory
  ///
  /// In en, this message translates to:
  /// **'Past drivers'**
  String get assignmentHistory;

  /// noDriverAssigned
  ///
  /// In en, this message translates to:
  /// **'No driver assigned'**
  String get noDriverAssigned;

  /// noDriverAssignedHint
  ///
  /// In en, this message translates to:
  /// **'Assign a driver and choose how they are paid.'**
  String get noDriverAssignedHint;

  /// selectDriver
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get selectDriver;

  /// startDate
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get startDate;

  /// replacesNote
  ///
  /// In en, this message translates to:
  /// **'{driver} will stop on {date}.'**
  String replacesNote(String driver, String date);

  /// noActiveDrivers
  ///
  /// In en, this message translates to:
  /// **'Add a driver first.'**
  String get noActiveDrivers;

  /// selfDrivenNoDriver
  ///
  /// In en, this message translates to:
  /// **'Self-driven vehicles don\'t have a driver. Change the vehicle\'s business model to assign one.'**
  String get selfDrivenNoDriver;

  /// assignmentSaved
  ///
  /// In en, this message translates to:
  /// **'Driver assigned'**
  String get assignmentSaved;

  /// errAssignStartAfter
  ///
  /// In en, this message translates to:
  /// **'The new start date must be after the current assignment began.'**
  String get errAssignStartAfter;

  /// errAssignOverlap
  ///
  /// In en, this message translates to:
  /// **'That date overlaps an earlier assignment.'**
  String get errAssignOverlap;

  /// errAssignPayType
  ///
  /// In en, this message translates to:
  /// **'That pay type does not suit this vehicle.'**
  String get errAssignPayType;

  /// errAssignDriverLeft
  ///
  /// In en, this message translates to:
  /// **'This driver has left.'**
  String get errAssignDriverLeft;

  /// ongoing
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get ongoing;

  /// ptSalary
  ///
  /// In en, this message translates to:
  /// **'Monthly salary'**
  String get ptSalary;

  /// ptDailyWage
  ///
  /// In en, this message translates to:
  /// **'Daily wage'**
  String get ptDailyWage;

  /// ptPerTrip
  ///
  /// In en, this message translates to:
  /// **'Per trip'**
  String get ptPerTrip;

  /// ptCommission
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get ptCommission;

  /// ptJama
  ///
  /// In en, this message translates to:
  /// **'Jama (rent)'**
  String get ptJama;

  /// ptMixed
  ///
  /// In en, this message translates to:
  /// **'Salary + commission'**
  String get ptMixed;

  /// payTypeLabel
  ///
  /// In en, this message translates to:
  /// **'How is the driver paid?'**
  String get payTypeLabel;

  /// fMonthly
  ///
  /// In en, this message translates to:
  /// **'Monthly salary (৳)'**
  String get fMonthly;

  /// fBaseSalary
  ///
  /// In en, this message translates to:
  /// **'Base salary per month (৳)'**
  String get fBaseSalary;

  /// fPerDay
  ///
  /// In en, this message translates to:
  /// **'Pay per day (৳)'**
  String get fPerDay;

  /// fHalfDay
  ///
  /// In en, this message translates to:
  /// **'Half-day pay (% of a full day)'**
  String get fHalfDay;

  /// fPerTrip
  ///
  /// In en, this message translates to:
  /// **'Pay per trip (৳)'**
  String get fPerTrip;

  /// fRate
  ///
  /// In en, this message translates to:
  /// **'Commission (% of fare)'**
  String get fRate;

  /// fBasis
  ///
  /// In en, this message translates to:
  /// **'Commission on'**
  String get fBasis;

  /// basisBefore
  ///
  /// In en, this message translates to:
  /// **'Fare before expenses'**
  String get basisBefore;

  /// basisAfter
  ///
  /// In en, this message translates to:
  /// **'Fare after expenses'**
  String get basisAfter;

  /// fJamaAmount
  ///
  /// In en, this message translates to:
  /// **'Jama amount (৳)'**
  String get fJamaAmount;

  /// fFrequency
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get fFrequency;

  /// freqDaily
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get freqDaily;

  /// freqWeekly
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get freqWeekly;

  /// fOffDays
  ///
  /// In en, this message translates to:
  /// **'Days with no jama'**
  String get fOffDays;

  /// errPayAmount
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get errPayAmount;

  /// errPayRate
  ///
  /// In en, this message translates to:
  /// **'Enter a percentage between 0 and 100'**
  String get errPayRate;

  /// errPayOffDays
  ///
  /// In en, this message translates to:
  /// **'Leave at least one day when jama is collected'**
  String get errPayOffDays;

  /// sumSalary
  ///
  /// In en, this message translates to:
  /// **'{amount} per month'**
  String sumSalary(String amount);

  /// sumDailyWage
  ///
  /// In en, this message translates to:
  /// **'{amount} per day (half day {rate}%)'**
  String sumDailyWage(String amount, String rate);

  /// sumPerTrip
  ///
  /// In en, this message translates to:
  /// **'{amount} per trip'**
  String sumPerTrip(String amount);

  /// sumCommissionBefore
  ///
  /// In en, this message translates to:
  /// **'{rate}% of fare before expenses'**
  String sumCommissionBefore(String rate);

  /// sumCommissionAfter
  ///
  /// In en, this message translates to:
  /// **'{rate}% of fare after expenses'**
  String sumCommissionAfter(String rate);

  /// sumJamaDaily
  ///
  /// In en, this message translates to:
  /// **'{amount} per day'**
  String sumJamaDaily(String amount);

  /// sumJamaWeekly
  ///
  /// In en, this message translates to:
  /// **'{amount} per week'**
  String sumJamaWeekly(String amount);

  /// sumMixed
  ///
  /// In en, this message translates to:
  /// **'{amount} per month + {rate}% commission'**
  String sumMixed(String amount, String rate);

  /// today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// errSelectDriver
  ///
  /// In en, this message translates to:
  /// **'Choose a driver'**
  String get errSelectDriver;

  /// catFuel
  ///
  /// In en, this message translates to:
  /// **'Fuel / CNG gas'**
  String get catFuel;

  /// catToll
  ///
  /// In en, this message translates to:
  /// **'Toll'**
  String get catToll;

  /// catParking
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get catParking;

  /// catHelper
  ///
  /// In en, this message translates to:
  /// **'Helper'**
  String get catHelper;

  /// catPolice
  ///
  /// In en, this message translates to:
  /// **'Police / informal'**
  String get catPolice;

  /// catFood
  ///
  /// In en, this message translates to:
  /// **'Driver food'**
  String get catFood;

  /// catRepair
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get catRepair;

  /// catParts
  ///
  /// In en, this message translates to:
  /// **'Spare parts'**
  String get catParts;

  /// catTyre
  ///
  /// In en, this message translates to:
  /// **'Tyre'**
  String get catTyre;

  /// catService
  ///
  /// In en, this message translates to:
  /// **'Oil change / service'**
  String get catService;

  /// catWashing
  ///
  /// In en, this message translates to:
  /// **'Washing'**
  String get catWashing;

  /// catInsurance
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get catInsurance;

  /// catRegistration
  ///
  /// In en, this message translates to:
  /// **'Registration / tax token'**
  String get catRegistration;

  /// catLoan
  ///
  /// In en, this message translates to:
  /// **'Loan installment'**
  String get catLoan;

  /// catOther
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// addTrip
  ///
  /// In en, this message translates to:
  /// **'Add trip'**
  String get addTrip;

  /// newTrip
  ///
  /// In en, this message translates to:
  /// **'New trip'**
  String get newTrip;

  /// editTrip
  ///
  /// In en, this message translates to:
  /// **'Edit trip'**
  String get editTrip;

  /// tripTitle
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get tripTitle;

  /// needVehicleFirst
  ///
  /// In en, this message translates to:
  /// **'Add a vehicle before logging trips.'**
  String get needVehicleFirst;

  /// noDriverOption
  ///
  /// In en, this message translates to:
  /// **'No driver'**
  String get noDriverOption;

  /// tripFare
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get tripFare;

  /// tapToEnter
  ///
  /// In en, this message translates to:
  /// **'Tap to enter'**
  String get tapToEnter;

  /// tripFrom
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get tripFrom;

  /// tripTo
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get tripTo;

  /// tripDistance
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get tripDistance;

  /// tripLoad
  ///
  /// In en, this message translates to:
  /// **'Load or passengers'**
  String get tripLoad;

  /// tripWhen
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get tripWhen;

  /// expensesTitle
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// addExpenseMore
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get addExpenseMore;

  /// noExpenses
  ///
  /// In en, this message translates to:
  /// **'No expenses added'**
  String get noExpenses;

  /// expenseCategory
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// paidBy
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get paidBy;

  /// paidByOwner
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get paidByOwner;

  /// paidByDriver
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get paidByDriver;

  /// paidByClient
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get paidByClient;

  /// reimbursable
  ///
  /// In en, this message translates to:
  /// **'I will pay the driver back'**
  String get reimbursable;

  /// fuelQty
  ///
  /// In en, this message translates to:
  /// **'Quantity (litres or m³)'**
  String get fuelQty;

  /// odometer
  ///
  /// In en, this message translates to:
  /// **'Odometer (km)'**
  String get odometer;

  /// receipt
  ///
  /// In en, this message translates to:
  /// **'Receipt photo'**
  String get receipt;

  /// addReceipt
  ///
  /// In en, this message translates to:
  /// **'Add receipt photo'**
  String get addReceipt;

  /// editExpense
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpense;

  /// addExpense
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// newCategory
  ///
  /// In en, this message translates to:
  /// **'New category…'**
  String get newCategory;

  /// categoryName
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// paymentTitle
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// payPaid
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payPaid;

  /// payPartial
  ///
  /// In en, this message translates to:
  /// **'Partly paid'**
  String get payPartial;

  /// payUnpaid
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get payUnpaid;

  /// amountReceived
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get amountReceived;

  /// dueAmount
  ///
  /// In en, this message translates to:
  /// **'Due {amount}'**
  String dueAmount(String amount);

  /// errReceivedTooHigh
  ///
  /// In en, this message translates to:
  /// **'Received cannot be more than the fare'**
  String get errReceivedTooHigh;

  /// recordPayment
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get recordPayment;

  /// paymentRecorded
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get paymentRecorded;

  /// markFullyPaid
  ///
  /// In en, this message translates to:
  /// **'Mark fully paid'**
  String get markFullyPaid;

  /// errPaymentInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter an amount up to {amount}'**
  String errPaymentInvalid(String amount);

  /// driverPayLabel
  ///
  /// In en, this message translates to:
  /// **'Driver pay'**
  String get driverPayLabel;

  /// driverPayAuto
  ///
  /// In en, this message translates to:
  /// **'calculated'**
  String get driverPayAuto;

  /// driverPayCustom
  ///
  /// In en, this message translates to:
  /// **'set by you'**
  String get driverPayCustom;

  /// resetToAuto
  ///
  /// In en, this message translates to:
  /// **'Use calculated amount'**
  String get resetToAuto;

  /// profitLabel
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profitLabel;

  /// lossLabel
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get lossLabel;

  /// errFareRequired
  ///
  /// In en, this message translates to:
  /// **'Enter the fare'**
  String get errFareRequired;

  /// errDistanceInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid distance'**
  String get errDistanceInvalid;

  /// errQtyInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity'**
  String get errQtyInvalid;

  /// errOdoInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid odometer reading'**
  String get errOdoInvalid;

  /// errVehicleRequired
  ///
  /// In en, this message translates to:
  /// **'Choose a vehicle'**
  String get errVehicleRequired;

  /// repeatTrip
  ///
  /// In en, this message translates to:
  /// **'Repeat trip'**
  String get repeatTrip;

  /// addReturnLeg
  ///
  /// In en, this message translates to:
  /// **'Add return leg'**
  String get addReturnLeg;

  /// returnLegBadge
  ///
  /// In en, this message translates to:
  /// **'Return leg'**
  String get returnLegBadge;

  /// deleteTrip
  ///
  /// In en, this message translates to:
  /// **'Delete trip'**
  String get deleteTrip;

  /// deleteTripTitle
  ///
  /// In en, this message translates to:
  /// **'Delete this trip?'**
  String get deleteTripTitle;

  /// deleteTripBody
  ///
  /// In en, this message translates to:
  /// **'The trip and its expenses are removed from your reports.'**
  String get deleteTripBody;

  /// tripDeleted
  ///
  /// In en, this message translates to:
  /// **'Trip deleted'**
  String get tripDeleted;

  /// tripSaved
  ///
  /// In en, this message translates to:
  /// **'Trip saved'**
  String get tripSaved;

  /// tripNotFound
  ///
  /// In en, this message translates to:
  /// **'Trip not found'**
  String get tripNotFound;

  /// filterPeriodAll
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get filterPeriodAll;

  /// filterToday
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// filterThisMonth
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get filterThisMonth;

  /// filterLastMonth
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get filterLastMonth;

  /// filterVehicleAll
  ///
  /// In en, this message translates to:
  /// **'All vehicles'**
  String get filterVehicleAll;

  /// noTripsMatch
  ///
  /// In en, this message translates to:
  /// **'No trips match these filters.'**
  String get noTripsMatch;

  /// vehicleExpenses
  ///
  /// In en, this message translates to:
  /// **'Vehicle expenses'**
  String get vehicleExpenses;

  /// vehicleExpensesEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get vehicleExpensesEmptyTitle;

  /// vehicleExpensesEmptyMessage
  ///
  /// In en, this message translates to:
  /// **'Repairs, service, insurance and other costs of this vehicle go here.'**
  String get vehicleExpensesEmptyMessage;

  /// fuelEfficiency
  ///
  /// In en, this message translates to:
  /// **'Fuel efficiency'**
  String get fuelEfficiency;

  /// fuelEffAverage
  ///
  /// In en, this message translates to:
  /// **'{value} km per litre / m³'**
  String fuelEffAverage(String value);

  /// fuelCostPerKm
  ///
  /// In en, this message translates to:
  /// **'{amount} per km'**
  String fuelCostPerKm(String amount);

  /// fuelEffNeedMore
  ///
  /// In en, this message translates to:
  /// **'Add two fuel entries with quantity and odometer to see efficiency.'**
  String get fuelEffNeedMore;

  /// expenseDeleteTitle
  ///
  /// In en, this message translates to:
  /// **'Delete this expense?'**
  String get expenseDeleteTitle;

  /// expenseSaved
  ///
  /// In en, this message translates to:
  /// **'Expense saved'**
  String get expenseSaved;

  /// expenseDeleted
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// expenseCategories
  ///
  /// In en, this message translates to:
  /// **'Expense categories'**
  String get expenseCategories;

  /// addCategory
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// renameCategory
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameCategory;

  /// categoriesHint
  ///
  /// In en, this message translates to:
  /// **'Archived categories are hidden from new expenses but keep your old records.'**
  String get categoriesHint;

  /// errCategoryDuplicate
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists'**
  String get errCategoryDuplicate;

  /// errCategoryEmpty
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get errCategoryEmpty;

  /// unitKm
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKm;

  /// todayWithVehicle
  ///
  /// In en, this message translates to:
  /// **'Today · {vehicle}'**
  String todayWithVehicle(String vehicle);

  /// incomeToday
  ///
  /// In en, this message translates to:
  /// **'Income today'**
  String get incomeToday;

  /// profitToday
  ///
  /// In en, this message translates to:
  /// **'Profit today'**
  String get profitToday;

  /// gasFuel
  ///
  /// In en, this message translates to:
  /// **'Gas / fuel'**
  String get gasFuel;

  /// closeDay
  ///
  /// In en, this message translates to:
  /// **'Close day'**
  String get closeDay;

  /// incomeAdded
  ///
  /// In en, this message translates to:
  /// **'Added {amount}'**
  String incomeAdded(String amount);

  /// undo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// incomeUndone
  ///
  /// In en, this message translates to:
  /// **'Undone'**
  String get incomeUndone;

  /// closeDayTitle
  ///
  /// In en, this message translates to:
  /// **'Close the day'**
  String get closeDayTitle;

  /// closeDayIncome
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get closeDayIncome;

  /// closeDayRunning
  ///
  /// In en, this message translates to:
  /// **'Running costs'**
  String get closeDayRunning;

  /// closeDayDriver
  ///
  /// In en, this message translates to:
  /// **'Driver cost'**
  String get closeDayDriver;

  /// closeDayVehicleCosts
  ///
  /// In en, this message translates to:
  /// **'Vehicle costs'**
  String get closeDayVehicleCosts;

  /// closeDayNet
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get closeDayNet;

  /// settlementTitle
  ///
  /// In en, this message translates to:
  /// **'Settle with the driver'**
  String get settlementTitle;

  /// settlementJama
  ///
  /// In en, this message translates to:
  /// **'Collect jama {amount} from {driver} today.'**
  String settlementJama(String amount, String driver);

  /// settlementSalary
  ///
  /// In en, this message translates to:
  /// **'{driver} is on a monthly salary, which builds up each day.'**
  String settlementSalary(String driver);

  /// settlementDaily
  ///
  /// In en, this message translates to:
  /// **'{driver} is paid per day worked. Record a payout when you pay.'**
  String settlementDaily(String driver);

  /// settlementPerTrip
  ///
  /// In en, this message translates to:
  /// **'{driver} is paid from trips. Record a payout when you pay.'**
  String settlementPerTrip(String driver);

  /// settlementNone
  ///
  /// In en, this message translates to:
  /// **'No driver settlement is due.'**
  String get settlementNone;

  /// periodWeek
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get periodWeek;

  /// profitSummary
  ///
  /// In en, this message translates to:
  /// **'Profit summary'**
  String get profitSummary;

  /// repIncome
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get repIncome;

  /// repRunning
  ///
  /// In en, this message translates to:
  /// **'Running costs'**
  String get repRunning;

  /// repDriver
  ///
  /// In en, this message translates to:
  /// **'Driver cost'**
  String get repDriver;

  /// repOperating
  ///
  /// In en, this message translates to:
  /// **'Operating profit'**
  String get repOperating;

  /// repVehicleCosts
  ///
  /// In en, this message translates to:
  /// **'Vehicle costs'**
  String get repVehicleCosts;

  /// repNet
  ///
  /// In en, this message translates to:
  /// **'Net profit'**
  String get repNet;

  /// repReceivable
  ///
  /// In en, this message translates to:
  /// **'Not yet received'**
  String get repReceivable;

  /// repPerTrip
  ///
  /// In en, this message translates to:
  /// **'Per trip'**
  String get repPerTrip;

  /// repPerDay
  ///
  /// In en, this message translates to:
  /// **'Per working day'**
  String get repPerDay;

  /// vehiclesRanking
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehiclesRanking;

  /// trendTitle
  ///
  /// In en, this message translates to:
  /// **'Profit trend'**
  String get trendTitle;

  /// incomeVsCost
  ///
  /// In en, this message translates to:
  /// **'Income and costs'**
  String get incomeVsCost;

  /// expenseMixTitle
  ///
  /// In en, this message translates to:
  /// **'Where the money went'**
  String get expenseMixTitle;

  /// noDataYet
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded for this period yet.'**
  String get noDataYet;

  /// amortizeFixed
  ///
  /// In en, this message translates to:
  /// **'Spread vehicle costs over the month'**
  String get amortizeFixed;

  /// amortizeFixedHint
  ///
  /// In en, this message translates to:
  /// **'Repairs, insurance and loan instalments are shared across the days of the month instead of the day they were paid.'**
  String get amortizeFixedHint;

  /// chartIncome
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get chartIncome;

  /// chartCosts
  ///
  /// In en, this message translates to:
  /// **'Costs'**
  String get chartCosts;

  /// chartProfit
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get chartProfit;

  /// generateDemo
  ///
  /// In en, this message translates to:
  /// **'Generate demo data'**
  String get generateDemo;

  /// demoDone
  ///
  /// In en, this message translates to:
  /// **'Demo data created'**
  String get demoDone;
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
