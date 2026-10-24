// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'গাড়ি খাতা';

  @override
  String get navHome => 'হোম';

  @override
  String get navEntries => 'এন্ট্রি';

  @override
  String get navReports => 'রিপোর্ট';

  @override
  String get navMore => 'আরও';

  @override
  String get homeEmptyTitle => 'এখনো কোনো গাড়ি নেই';

  @override
  String get homeEmptyMessage => 'আয় লিখতে প্রথম গাড়িটি যোগ করুন।';

  @override
  String get entriesEmptyTitle => 'এখনো কোনো ট্রিপ নেই';

  @override
  String get entriesEmptyMessage => 'আয় ও লাভ দেখতে একটি ট্রিপ লিখুন।';

  @override
  String get reportsEmptyTitle => 'এখনো কোনো রিপোর্ট নেই';

  @override
  String get reportsEmptyMessage => 'আয় লিখলে রিপোর্ট দেখা যাবে।';

  @override
  String get settings => 'সেটিংস';

  @override
  String get uiGallery => 'UI গ্যালারি';

  @override
  String get language => 'ভাষা';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get numerals => 'সংখ্যার ধরন';

  @override
  String get numeralsBangla => '১২৩';

  @override
  String get numeralsLatin => '123';

  @override
  String get grouping => 'সংখ্যা সাজানো';

  @override
  String get groupingSouthAsian => '1,23,456';

  @override
  String get groupingInternational => '123,456';

  @override
  String get profitView => 'লাভের হিসাব';

  @override
  String get profitCash => 'নগদ';

  @override
  String get profitAccrual => 'বাকিসহ';

  @override
  String get addIncome => 'আয় যোগ করুন';

  @override
  String get keypadDone => 'ঠিক আছে';

  @override
  String get keypadDelete => 'মুছুন';

  @override
  String get amountLabel => 'পরিমাণ';

  @override
  String get chipFuel => 'জ্বালানি';

  @override
  String get chipToll => 'টোল';

  @override
  String get chipParking => 'পার্কিং';

  @override
  String get chipHelper => 'হেল্পার';

  @override
  String get galleryAmountSample => 'আজকের আয়';

  @override
  String get galleryTileTitle => 'রহিম · জমা';

  @override
  String get galleryTileSubtitle => 'আজ পরিশোধ';

  @override
  String get galleryButtons => 'বাটন';

  @override
  String get galleryChips => 'কুইক চিপ';

  @override
  String get galleryKeypad => 'অ্যামাউন্ট কিপ্যাড';

  @override
  String get galleryTiles => 'লিস্ট টাইল';

  @override
  String get galleryEmpty => 'খালি অবস্থা';

  @override
  String onbStepOf(String current, String total) {
    return 'ধাপ $current / $total';
  }

  @override
  String get welcomeTitle => 'গাড়ি খাতায় স্বাগতম';

  @override
  String get welcomeSubtitle =>
      'আপনার ট্রিপ, আয় ও লাভের হিসাব এক খাতায় রাখুন।';

  @override
  String get chooseLanguage => 'আপনার ভাষা বেছে নিন';

  @override
  String get continueLabel => 'এগিয়ে যান';

  @override
  String get backLabel => 'পিছনে';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get skipForNow => 'এখন থাক';

  @override
  String get accountTitle => 'ফোন নম্বর দিয়ে সাইন ইন করুন';

  @override
  String get accountSubtitle =>
      'আপনার তথ্য ব্যাকআপ থাকবে এবং নতুন ফোনে ফিরিয়ে আনা যাবে।';

  @override
  String get continueWithoutAccount => 'অ্যাকাউন্ট ছাড়া চালিয়ে যান';

  @override
  String get localOnlyNote => 'পরে \"আরও\" থেকে সাইন ইন করতে পারবেন।';

  @override
  String get phoneLabel => 'মোবাইল নম্বর';

  @override
  String get phoneHint => '০১XXXXXXXXX';

  @override
  String get sendCode => 'কোড পাঠান';

  @override
  String get otpTitle => '৬ সংখ্যার কোডটি লিখুন';

  @override
  String otpSentTo(String phone) {
    return '$phone নম্বরে কোড পাঠানো হয়েছে';
  }

  @override
  String get otpLabel => 'ভেরিফিকেশন কোড';

  @override
  String get verify => 'যাচাই করুন';

  @override
  String resendIn(String seconds) {
    return '$seconds সেকেন্ড পরে আবার পাঠান';
  }

  @override
  String get resendCode => 'আবার কোড পাঠান';

  @override
  String get changeNumber => 'নম্বর বদলান';

  @override
  String get errInvalidPhone => 'সঠিক মোবাইল নম্বর দিন, যেমন ০১৭১২৩৪৫৬৭৮';

  @override
  String get errRateLimited =>
      'অনেকবার চেষ্টা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।';

  @override
  String get errInvalidCode => 'কোডটি ভুল অথবা মেয়াদ শেষ।';

  @override
  String get errNetwork =>
      'ইন্টারনেট নেই। আবার চেষ্টা করুন, অথবা অ্যাকাউন্ট ছাড়া চালিয়ে যান।';

  @override
  String get errUnknown => 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String signedInAs(String phone) {
    return '$phone হিসেবে সাইন ইন করা আছে';
  }

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get signInToBackUp => 'ব্যাকআপের জন্য সাইন ইন করুন';

  @override
  String get signInUnavailable => 'এই সংস্করণে সাইন ইন করা যাচ্ছে না।';

  @override
  String get roleTitle => 'আপনি অ্যাপটি কীভাবে ব্যবহার করবেন?';

  @override
  String get roleOwner => 'আমি গাড়ির মালিক';

  @override
  String get roleOwnerDesc => 'ট্রিপ, আয়, ড্রাইভার ও লাভের হিসাব রাখুন।';

  @override
  String get roleDriver => 'আমি মালিকের গাড়ি চালাই';

  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get firstVehicleTitle => 'আপনার প্রথম গাড়িটি যোগ করুন';

  @override
  String get modelTitle => 'গাড়িটি থেকে কীভাবে আয় হয়?';

  @override
  String get finishSetup => 'সেটআপ শেষ করুন';

  @override
  String get vehicleNickname => 'ডাকনাম';

  @override
  String get vehicleNicknameHint => 'যেমন রহিমের সিএনজি';

  @override
  String get vehicleType => 'গাড়ির ধরন';

  @override
  String get typeCng => 'সিএনজি অটোরিকশা';

  @override
  String get typeRickshaw => 'রিকশা';

  @override
  String get typeEasyBike => 'ইজিবাইক';

  @override
  String get typePickup => 'পিকআপ';

  @override
  String get typeMiniTruck => 'মিনি ট্রাক';

  @override
  String get typeTruck => 'ট্রাক';

  @override
  String get typeOther => 'অন্যান্য';

  @override
  String get fuelCng => 'সিএনজি গ্যাস';

  @override
  String get fuelOctane => 'অকটেন';

  @override
  String get fuelPetrol => 'পেট্রোল';

  @override
  String get fuelDiesel => 'ডিজেল';

  @override
  String get fuelElectric => 'বিদ্যুৎ';

  @override
  String get modelSelf => 'নিজে চালাই';

  @override
  String get modelSalaried => 'মাসিক বেতনের ড্রাইভার';

  @override
  String get modelDailyWage => 'দৈনিক মজুরি';

  @override
  String get modelCommission => 'কমিশন';

  @override
  String get modelJama => 'জমা (ভাড়া)';

  @override
  String get modelContract => 'ট্রিপ চুক্তি';

  @override
  String get modelSelfDesc => 'আমি নিজেই চালাই।';

  @override
  String get modelSalariedDesc => 'ড্রাইভার মাসিক বেতন পান।';

  @override
  String get modelDailyWageDesc => 'ড্রাইভার প্রতিদিন নির্দিষ্ট মজুরি পান।';

  @override
  String get modelCommissionDesc => 'ড্রাইভার আয়ের একটি অংশ পান।';

  @override
  String get modelJamaDesc =>
      'ড্রাইভার আমাকে প্রতিদিন নির্দিষ্ট ভাড়া (জমা) দেন।';

  @override
  String get modelContractDesc => 'প্রতিটি ট্রিপের জন্য ভাড়া পাই।';

  @override
  String get statusActive => 'চালু';

  @override
  String get statusInGarage => 'গ্যারেজে';

  @override
  String get statusSold => 'বিক্রি হয়েছে';

  @override
  String get statusArchived => 'আর্কাইভ';

  @override
  String get filterAll => 'সব';

  @override
  String get showArchived => 'আর্কাইভ দেখান';

  @override
  String get vehiclesTitle => 'গাড়ি';

  @override
  String get addVehicle => 'গাড়ি যোগ করুন';

  @override
  String get searchVehicles => 'নাম বা নম্বর দিয়ে খুঁজুন';

  @override
  String get noResults => 'কোনো গাড়ি পাওয়া যায়নি।';

  @override
  String get newVehicle => 'নতুন গাড়ি';

  @override
  String get editVehicle => 'গাড়ি সম্পাদনা';

  @override
  String get regNo => 'রেজিস্ট্রেশন নম্বর';

  @override
  String get vehicleModel => 'মেক / মডেল';

  @override
  String get vehicleYear => 'সাল';

  @override
  String get fuelType => 'জ্বালানির ধরন';

  @override
  String get businessModel => 'আয়ের ধরন';

  @override
  String get statusLabel => 'অবস্থা';

  @override
  String get photo => 'ছবি';

  @override
  String get takePhoto => 'ছবি তুলুন';

  @override
  String get chooseFromGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get removePhoto => 'ছবি সরান';

  @override
  String get purchaseDate => 'কেনার তারিখ';

  @override
  String get purchasePrice => 'কেনার দাম (৳)';

  @override
  String get optional => 'ঐচ্ছিক';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get cancel => 'বাতিল';

  @override
  String get errNicknameEmpty => 'একটি ডাকনাম দিন';

  @override
  String errNicknameTooLong(String max) {
    return 'ডাকনাম খুব বড় (সর্বোচ্চ $max অক্ষর)';
  }

  @override
  String get errYearInvalid => 'সঠিক সাল দিন';

  @override
  String get errPriceInvalid => 'সঠিক পরিমাণ দিন';

  @override
  String dupRegWarning(String name) {
    return 'আরেকটি গাড়ির ($name) একই নম্বর আছে।';
  }

  @override
  String get archive => 'আর্কাইভ করুন';

  @override
  String get restore => 'ফিরিয়ে আনুন';

  @override
  String get archiveConfirmTitle => 'গাড়িটি আর্কাইভ করবেন?';

  @override
  String get archiveConfirmBody =>
      'তালিকা থেকে লুকানো থাকবে, কিন্তু রিপোর্টে হিসাব থাকবে।';

  @override
  String get vehicleArchived => 'গাড়ি আর্কাইভ করা হয়েছে';

  @override
  String get vehicleRestored => 'গাড়ি ফিরিয়ে আনা হয়েছে';

  @override
  String get changeStatus => 'অবস্থা বদলান';

  @override
  String get vehicleNotFound => 'গাড়িটি পাওয়া যায়নি';

  @override
  String get homeEmptyAction => 'প্রথম গাড়ি যোগ করুন';

  @override
  String get security => 'নিরাপত্তা';

  @override
  String get appLock => 'অ্যাপ লক';

  @override
  String get appLockOff => 'বন্ধ';

  @override
  String get appLockOn => 'পিন লক চালু আছে';

  @override
  String get setPinTitle => '৪ সংখ্যার পিন দিন';

  @override
  String get confirmPinTitle => 'পিনটি আবার দিন';

  @override
  String get pinMismatch => 'পিন মেলেনি। আবার চেষ্টা করুন।';

  @override
  String get enterPin => 'আপনার পিন দিন';

  @override
  String get enterCurrentPin => 'বর্তমান পিন দিন';

  @override
  String get wrongPin => 'ভুল পিন';

  @override
  String pinBlocked(String seconds) {
    return 'অনেকবার ভুল হয়েছে। $seconds সেকেন্ড পরে চেষ্টা করুন।';
  }

  @override
  String get useBiometric => 'ফিঙ্গারপ্রিন্ট বা ফেস দিয়ে খুলুন';

  @override
  String get biometricReason => 'গাড়ি খাতা খুলুন';

  @override
  String get biometricUnavailable => 'এই ফোনে পাওয়া যাচ্ছে না';

  @override
  String get lockTimeout => 'লক হবে';

  @override
  String get timeoutImmediately => 'সঙ্গে সঙ্গে';

  @override
  String get timeout30 => '৩০ সেকেন্ড পর';

  @override
  String get timeout1m => '১ মিনিট পর';

  @override
  String get timeout5m => '৫ মিনিট পর';

  @override
  String get changePin => 'পিন বদলান';

  @override
  String get turnOffLock => 'অ্যাপ লক বন্ধ করুন';

  @override
  String get unlockTitle => 'আনলক করুন';

  @override
  String get vehicleSaved => 'গাড়ি সংরক্ষণ করা হয়েছে';

  @override
  String get driversTitle => 'ড্রাইভার';

  @override
  String get addDriver => 'ড্রাইভার যোগ করুন';

  @override
  String get newDriver => 'নতুন ড্রাইভার';

  @override
  String get editDriver => 'ড্রাইভার সম্পাদনা';

  @override
  String get searchDrivers => 'নাম, ফোন বা লাইসেন্স দিয়ে খুঁজুন';

  @override
  String get driversEmptyTitle => 'এখনো কোনো ড্রাইভার নেই';

  @override
  String get driversEmptyMessage => 'যারা আপনার গাড়ি চালায় তাদের যোগ করুন।';

  @override
  String get driversNoResults => 'কোনো ড্রাইভার পাওয়া যায়নি।';

  @override
  String get driverStatusActive => 'কর্মরত';

  @override
  String get driverStatusLeft => 'ছেড়ে গেছে';

  @override
  String get driverName => 'পুরো নাম';

  @override
  String get licenseNo => 'লাইসেন্স নম্বর';

  @override
  String get licenseExpiry => 'লাইসেন্সের মেয়াদ';

  @override
  String get nid => 'জাতীয় পরিচয়পত্র (এনআইডি)';

  @override
  String get nidHelper => 'এই ফোনে এনক্রিপ্ট করে রাখা হয়।';

  @override
  String get nidOnFile => 'এনআইডি জমা আছে';

  @override
  String get address => 'ঠিকানা';

  @override
  String get emergencyContact => 'জরুরি যোগাযোগ';

  @override
  String get joinDate => 'যোগদানের তারিখ';

  @override
  String get errNameEmpty => 'ড্রাইভারের নাম দিন';

  @override
  String errNameTooLong(String max) {
    return 'নাম খুব বড় (সর্বোচ্চ $max অক্ষর)';
  }

  @override
  String get errNidInvalid => 'এনআইডি ১০, ১৩ বা ১৭ সংখ্যার হতে হবে';

  @override
  String get driverSaved => 'ড্রাইভার সংরক্ষণ করা হয়েছে';

  @override
  String get driverNotFound => 'ড্রাইভার পাওয়া যায়নি';

  @override
  String get markAsLeft => 'ছেড়ে গেছে বলে চিহ্নিত করুন';

  @override
  String get reactivate => 'আবার কর্মরত করুন';

  @override
  String markLeftTitle(String name) {
    return '$name ছেড়ে গেছে?';
  }

  @override
  String get markLeftBody => 'তার বর্তমান গাড়ির দায়িত্ব আজ শেষ হবে।';

  @override
  String get driverMarkedLeft => 'ছেড়ে গেছে বলে চিহ্নিত';

  @override
  String get driverReactivated => 'কর্মরত হিসেবে চিহ্নিত';

  @override
  String get licenseExpired => 'লাইসেন্সের মেয়াদ শেষ';

  @override
  String licenseExpiresSoon(String date) {
    return 'লাইসেন্সের মেয়াদ শেষ হবে $date';
  }

  @override
  String licenseValidUntil(String date) {
    return 'মেয়াদ $date পর্যন্ত';
  }

  @override
  String get tabOverview => 'সারসংক্ষেপ';

  @override
  String get tabAttendance => 'হাজিরা';

  @override
  String get tabAdvances => 'অগ্রিম';

  @override
  String get tabPayouts => 'পরিশোধ';

  @override
  String get workingOn => 'যে গাড়িতে কাজ করছে';

  @override
  String get notAssigned => 'কোনো গাড়িতে নেই';

  @override
  String get advancesOwed => 'অগ্রিম বাকি';

  @override
  String sinceDate(String date) {
    return '$date থেকে';
  }

  @override
  String get contactDetails => 'তথ্য';

  @override
  String get attPresent => 'উপস্থিত';

  @override
  String get attAbsent => 'অনুপস্থিত';

  @override
  String get attHalfDay => 'অর্ধদিবস';

  @override
  String get attUnmarked => 'চিহ্নিত নয়';

  @override
  String get attClear => 'চিহ্ন মুছুন';

  @override
  String get prevMonth => 'আগের মাস';

  @override
  String get nextMonth => 'পরের মাস';

  @override
  String markDay(String date) {
    return '$date চিহ্নিত করুন';
  }

  @override
  String get month1 => 'জানুয়ারি';

  @override
  String get month2 => 'ফেব্রুয়ারি';

  @override
  String get month3 => 'মার্চ';

  @override
  String get month4 => 'এপ্রিল';

  @override
  String get month5 => 'মে';

  @override
  String get month6 => 'জুন';

  @override
  String get month7 => 'জুলাই';

  @override
  String get month8 => 'আগস্ট';

  @override
  String get month9 => 'সেপ্টেম্বর';

  @override
  String get month10 => 'অক্টোবর';

  @override
  String get month11 => 'নভেম্বর';

  @override
  String get month12 => 'ডিসেম্বর';

  @override
  String get wdMon => 'সোম';

  @override
  String get wdTue => 'মঙ্গল';

  @override
  String get wdWed => 'বুধ';

  @override
  String get wdThu => 'বৃহ';

  @override
  String get wdFri => 'শুক্র';

  @override
  String get wdSat => 'শনি';

  @override
  String get wdSun => 'রবি';

  @override
  String get advancesEmptyTitle => 'কোনো অগ্রিম নেই';

  @override
  String get advancesEmptyMessage =>
      'দেওয়া অগ্রিম পরের পরিশোধ থেকে কেটে নেওয়া হবে।';

  @override
  String get giveAdvance => 'অগ্রিম দিন';

  @override
  String get advanceAmount => 'পরিমাণ (৳)';

  @override
  String get advanceDate => 'তারিখ';

  @override
  String get advanceNote => 'নোট (ঐচ্ছিক)';

  @override
  String get advanceSaved => 'অগ্রিম লেখা হয়েছে';

  @override
  String get errAmountInvalid => 'শূন্যের বেশি পরিমাণ দিন';

  @override
  String advanceRecovered(String amount) {
    return 'ফেরত $amount';
  }

  @override
  String advanceRemaining(String amount) {
    return 'বাকি $amount';
  }

  @override
  String get advanceSettled => 'পুরো ফেরত হয়েছে';

  @override
  String get deleteAdvanceTitle => 'অগ্রিমটি মুছবেন?';

  @override
  String get errAdvanceRecovered =>
      'এই অগ্রিম একটি পরিশোধে কেটে নেওয়া হয়েছে। আগে সেই পরিশোধ বাতিল করুন।';

  @override
  String get deleteLabel => 'মুছুন';

  @override
  String get editLabel => 'সম্পাদনা';

  @override
  String get payoutsEmptyTitle => 'এখনো কোনো পরিশোধ নেই';

  @override
  String get payoutsEmptyMessage =>
      'বেতন ও অগ্রিমের হিসাব মেটাতে পরিশোধ লিখুন।';

  @override
  String get newPayout => 'নতুন পরিশোধ';

  @override
  String get payoutTitle => 'পরিশোধ লিখুন';

  @override
  String get payPeriod => 'সময়কাল';

  @override
  String get customRange => 'নিজের তারিখ';

  @override
  String get payVehicle => 'গাড়ি';

  @override
  String get payEarned => 'উপার্জন';

  @override
  String get payAdjustment => 'বোনাস (+) বা জরিমানা (−) (৳)';

  @override
  String get payAdjustmentNote => 'কারণ (ঐচ্ছিক)';

  @override
  String get payAdvancesDeducted => 'অগ্রিম কাটা হলো';

  @override
  String get payNet => 'এখন দিন';

  @override
  String get payAdvancesCarried => 'এই পরিশোধের পরও বাকি অগ্রিম';

  @override
  String get recordPayout => 'পরিশোধ লিখুন';

  @override
  String get payoutRecorded => 'পরিশোধ লেখা হয়েছে';

  @override
  String get payoutAlreadyRecorded => 'এই সময়ের পরিশোধ আগেই লেখা আছে';

  @override
  String get payoutVoid => 'পরিশোধ বাতিল';

  @override
  String get payoutVoidTitle => 'পরিশোধটি বাতিল করবেন?';

  @override
  String get payoutVoidBody =>
      'কেটে নেওয়া অগ্রিম ফেরত আসবে এবং এই সময়ের জন্য আবার পরিশোধ করা যাবে।';

  @override
  String get payoutVoided => 'পরিশোধ বাতিল হয়েছে';

  @override
  String payoutPeriodClipped(String start, String end) {
    return 'এই দায়িত্বে শুধু $start থেকে $end পর্যন্ত ধরা হয়েছে।';
  }

  @override
  String get payoutTripsNote =>
      'এই ড্রাইভারের জন্য লেখা ট্রিপ থেকে ট্রিপের বেতন ধরা হয়।';

  @override
  String get payErrNotPayable =>
      'জমার ড্রাইভাররা মালিককে টাকা দেয়, তাই পরিশোধ করার কিছু নেই।';

  @override
  String get payErrOutside => 'এই সময়ে এই গাড়ির দায়িত্ব ছিল না।';

  @override
  String get payErrOverlap => 'এই সময়ের কিছু অংশের পরিশোধ আগেই লেখা আছে।';

  @override
  String get payErrNothing => 'এই সময়ের জন্য কিছু পরিশোধ করার নেই।';

  @override
  String payLineSalary(String days) {
    return 'বেতন ($days দিন)';
  }

  @override
  String payLineWages(String days) {
    return 'মজুরি ($days দিন)';
  }

  @override
  String payLineTripFees(String count) {
    return 'ট্রিপ ভাড়া ($countটি ট্রিপ)';
  }

  @override
  String get payLineCommission => 'কমিশন';

  @override
  String paidOn(String date) {
    return '$date তারিখে দেওয়া হয়েছে';
  }

  @override
  String dateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get driverAndPay => 'ড্রাইভার ও বেতন';

  @override
  String get assignDriver => 'ড্রাইভার ঠিক করুন';

  @override
  String get changeDriver => 'ড্রাইভার বা বেতন বদলান';

  @override
  String get endAssignment => 'দায়িত্ব শেষ করুন';

  @override
  String get endAssignmentTitle => 'দায়িত্ব শেষ করবেন?';

  @override
  String endAssignmentBody(String driver, String vehicle) {
    return 'আজকের পর $driver আর $vehicle চালাবে না।';
  }

  @override
  String get assignmentEnded => 'দায়িত্ব শেষ হয়েছে';

  @override
  String get currentDriver => 'বর্তমান ড্রাইভার';

  @override
  String get assignmentHistory => 'আগের ড্রাইভার';

  @override
  String get noDriverAssigned => 'কোনো ড্রাইভার নেই';

  @override
  String get noDriverAssignedHint =>
      'ড্রাইভার ঠিক করুন এবং কীভাবে বেতন পাবে তা বেছে নিন।';

  @override
  String get selectDriver => 'ড্রাইভার';

  @override
  String get startDate => 'শুরুর তারিখ';

  @override
  String replacesNote(String driver, String date) {
    return '$driver $date পর্যন্ত থাকবে।';
  }

  @override
  String get noActiveDrivers => 'আগে একজন ড্রাইভার যোগ করুন।';

  @override
  String get selfDrivenNoDriver =>
      'নিজে চালানো গাড়িতে ড্রাইভার থাকে না। ড্রাইভার দিতে গাড়ির আয়ের ধরন বদলান।';

  @override
  String get assignmentSaved => 'ড্রাইভার ঠিক করা হয়েছে';

  @override
  String get errAssignStartAfter =>
      'নতুন শুরুর তারিখ বর্তমান দায়িত্ব শুরুর পরে হতে হবে।';

  @override
  String get errAssignOverlap =>
      'এই তারিখ আগের দায়িত্বের সময়ের সাথে মিলে যাচ্ছে।';

  @override
  String get errAssignPayType => 'এই বেতনের ধরন এই গাড়ির সাথে মানায় না।';

  @override
  String get errAssignDriverLeft => 'এই ড্রাইভার ছেড়ে গেছে।';

  @override
  String get ongoing => 'চলছে';

  @override
  String get ptSalary => 'মাসিক বেতন';

  @override
  String get ptDailyWage => 'দৈনিক মজুরি';

  @override
  String get ptPerTrip => 'ট্রিপ প্রতি';

  @override
  String get ptCommission => 'কমিশন';

  @override
  String get ptJama => 'জমা (ভাড়া)';

  @override
  String get ptMixed => 'বেতন + কমিশন';

  @override
  String get payTypeLabel => 'ড্রাইভার কীভাবে বেতন পাবে?';

  @override
  String get fMonthly => 'মাসিক বেতন (৳)';

  @override
  String get fBaseSalary => 'মাসিক মূল বেতন (৳)';

  @override
  String get fPerDay => 'দৈনিক মজুরি (৳)';

  @override
  String get fHalfDay => 'অর্ধদিবসের মজুরি (পূর্ণ দিনের %)';

  @override
  String get fPerTrip => 'প্রতি ট্রিপে (৳)';

  @override
  String get fRate => 'কমিশন (ভাড়ার %)';

  @override
  String get fBasis => 'কমিশন কিসের উপর';

  @override
  String get basisBefore => 'খরচ বাদ দেওয়ার আগের ভাড়া';

  @override
  String get basisAfter => 'খরচ বাদ দেওয়ার পরের ভাড়া';

  @override
  String get fJamaAmount => 'জমার পরিমাণ (৳)';

  @override
  String get fFrequency => 'আদায়';

  @override
  String get freqDaily => 'প্রতিদিন';

  @override
  String get freqWeekly => 'প্রতি সপ্তাহে';

  @override
  String get fOffDays => 'যেদিন জমা নেই';

  @override
  String get errPayAmount => 'শূন্যের বেশি পরিমাণ দিন';

  @override
  String get errPayRate => '০ থেকে ১০০ এর মধ্যে শতাংশ দিন';

  @override
  String get errPayOffDays => 'অন্তত একদিন জমা আদায়ের জন্য রাখুন';

  @override
  String sumSalary(String amount) {
    return 'মাসে $amount';
  }

  @override
  String sumDailyWage(String amount, String rate) {
    return 'দিনে $amount (অর্ধদিবস $rate%)';
  }

  @override
  String sumPerTrip(String amount) {
    return 'ট্রিপ প্রতি $amount';
  }

  @override
  String sumCommissionBefore(String rate) {
    return 'খরচ বাদ দেওয়ার আগের ভাড়ার $rate%';
  }

  @override
  String sumCommissionAfter(String rate) {
    return 'খরচ বাদ দেওয়ার পরের ভাড়ার $rate%';
  }

  @override
  String sumJamaDaily(String amount) {
    return 'দিনে $amount';
  }

  @override
  String sumJamaWeekly(String amount) {
    return 'সপ্তাহে $amount';
  }

  @override
  String sumMixed(String amount, String rate) {
    return 'মাসে $amount + $rate% কমিশন';
  }

  @override
  String get today => 'আজ';

  @override
  String get errSelectDriver => 'একজন ড্রাইভার বেছে নিন';

  @override
  String get catFuel => 'জ্বালানি / সিএনজি গ্যাস';

  @override
  String get catToll => 'টোল';

  @override
  String get catParking => 'পার্কিং';

  @override
  String get catHelper => 'হেল্পার';

  @override
  String get catPolice => 'পুলিশ / অনানুষ্ঠানিক';

  @override
  String get catFood => 'ড্রাইভারের খাবার';

  @override
  String get catRepair => 'মেরামত';

  @override
  String get catParts => 'যন্ত্রাংশ';

  @override
  String get catTyre => 'টায়ার';

  @override
  String get catService => 'তেল বদল / সার্ভিস';

  @override
  String get catWashing => 'ধোয়া';

  @override
  String get catInsurance => 'বীমা';

  @override
  String get catRegistration => 'রেজিস্ট্রেশন / ট্যাক্স টোকেন';

  @override
  String get catLoan => 'ঋণের কিস্তি';

  @override
  String get catOther => 'অন্যান্য';

  @override
  String get addTrip => 'ট্রিপ যোগ করুন';

  @override
  String get newTrip => 'নতুন ট্রিপ';

  @override
  String get editTrip => 'ট্রিপ সম্পাদনা';

  @override
  String get tripTitle => 'ট্রিপ';

  @override
  String get needVehicleFirst => 'ট্রিপ লেখার আগে একটি গাড়ি যোগ করুন।';

  @override
  String get noDriverOption => 'ড্রাইভার নেই';

  @override
  String get tripFare => 'ভাড়া';

  @override
  String get tapToEnter => 'লিখতে ট্যাপ করুন';

  @override
  String get tripFrom => 'কোথা থেকে';

  @override
  String get tripTo => 'কোথায়';

  @override
  String get tripDistance => 'দূরত্ব (কিমি)';

  @override
  String get tripLoad => 'মাল বা যাত্রী';

  @override
  String get tripWhen => 'তারিখ ও সময়';

  @override
  String get expensesTitle => 'খরচ';

  @override
  String get addExpenseMore => 'আরও';

  @override
  String get noExpenses => 'কোনো খরচ যোগ করা হয়নি';

  @override
  String get expenseCategory => 'খাত';

  @override
  String get paidBy => 'কে দিয়েছে';

  @override
  String get paidByOwner => 'মালিক';

  @override
  String get paidByDriver => 'ড্রাইভার';

  @override
  String get paidByClient => 'গ্রাহক';

  @override
  String get reimbursable => 'আমি ড্রাইভারকে ফেরত দেব';

  @override
  String get fuelQty => 'পরিমাণ (লিটার বা ঘনমিটার)';

  @override
  String get odometer => 'ওডোমিটার (কিমি)';

  @override
  String get receipt => 'রসিদের ছবি';

  @override
  String get addReceipt => 'রসিদের ছবি যোগ করুন';

  @override
  String get editExpense => 'খরচ সম্পাদনা';

  @override
  String get addExpense => 'খরচ যোগ করুন';

  @override
  String get newCategory => 'নতুন খাত…';

  @override
  String get categoryName => 'খাতের নাম';

  @override
  String get paymentTitle => 'টাকা পাওয়া';

  @override
  String get payPaid => 'পরিশোধিত';

  @override
  String get payPartial => 'আংশিক';

  @override
  String get payUnpaid => 'বাকি';

  @override
  String get amountReceived => 'যত টাকা পেয়েছেন';

  @override
  String dueAmount(String amount) {
    return 'বাকি $amount';
  }

  @override
  String get errReceivedTooHigh => 'ভাড়ার চেয়ে বেশি পাওয়া যায় না';

  @override
  String get recordPayment => 'টাকা পাওয়া লিখুন';

  @override
  String get paymentRecorded => 'টাকা পাওয়া লেখা হয়েছে';

  @override
  String get markFullyPaid => 'পুরো পরিশোধিত';

  @override
  String errPaymentInvalid(String amount) {
    return '$amount পর্যন্ত পরিমাণ দিন';
  }

  @override
  String get driverPayLabel => 'ড্রাইভারের পাওনা';

  @override
  String get driverPayAuto => 'হিসাব করা';

  @override
  String get driverPayCustom => 'আপনার দেওয়া';

  @override
  String get resetToAuto => 'হিসাব করা পরিমাণ ব্যবহার করুন';

  @override
  String get profitLabel => 'লাভ';

  @override
  String get lossLabel => 'লোকসান';

  @override
  String get errFareRequired => 'ভাড়া দিন';

  @override
  String get errDistanceInvalid => 'সঠিক দূরত্ব দিন';

  @override
  String get errQtyInvalid => 'সঠিক পরিমাণ দিন';

  @override
  String get errOdoInvalid => 'সঠিক ওডোমিটার রিডিং দিন';

  @override
  String get errVehicleRequired => 'একটি গাড়ি বেছে নিন';

  @override
  String get repeatTrip => 'আবার একই ট্রিপ';

  @override
  String get addReturnLeg => 'ফিরতি ট্রিপ যোগ করুন';

  @override
  String get returnLegBadge => 'ফিরতি ট্রিপ';

  @override
  String get deleteTrip => 'ট্রিপ মুছুন';

  @override
  String get deleteTripTitle => 'ট্রিপটি মুছবেন?';

  @override
  String get deleteTripBody => 'ট্রিপ ও তার খরচ রিপোর্ট থেকে বাদ যাবে।';

  @override
  String get tripDeleted => 'ট্রিপ মুছে ফেলা হয়েছে';

  @override
  String get tripSaved => 'ট্রিপ সংরক্ষণ করা হয়েছে';

  @override
  String get tripNotFound => 'ট্রিপ পাওয়া যায়নি';

  @override
  String get filterPeriodAll => 'সব সময়';

  @override
  String get filterToday => 'আজ';

  @override
  String get filterThisMonth => 'এই মাস';

  @override
  String get filterLastMonth => 'গত মাস';

  @override
  String get filterVehicleAll => 'সব গাড়ি';

  @override
  String get noTripsMatch => 'এই ফিল্টারে কোনো ট্রিপ নেই।';

  @override
  String get vehicleExpenses => 'গাড়ির খরচ';

  @override
  String get vehicleExpensesEmptyTitle => 'এখনো কোনো খরচ নেই';

  @override
  String get vehicleExpensesEmptyMessage =>
      'এই গাড়ির মেরামত, সার্ভিস, বীমা ও অন্যান্য খরচ এখানে লিখুন।';

  @override
  String get fuelEfficiency => 'জ্বালানি দক্ষতা';

  @override
  String fuelEffAverage(String value) {
    return 'প্রতি লিটার / ঘনমিটারে $value কিমি';
  }

  @override
  String fuelCostPerKm(String amount) {
    return 'প্রতি কিমিতে $amount';
  }

  @override
  String get fuelEffNeedMore =>
      'দক্ষতা দেখতে পরিমাণ ও ওডোমিটারসহ দুটি জ্বালানির খরচ লিখুন।';

  @override
  String get expenseDeleteTitle => 'খরচটি মুছবেন?';

  @override
  String get expenseSaved => 'খরচ সংরক্ষণ করা হয়েছে';

  @override
  String get expenseDeleted => 'খরচ মুছে ফেলা হয়েছে';

  @override
  String get expenseCategories => 'খরচের খাত';

  @override
  String get addCategory => 'খাত যোগ করুন';

  @override
  String get renameCategory => 'নাম বদলান';

  @override
  String get categoriesHint =>
      'আর্কাইভ করা খাত নতুন খরচে দেখা যাবে না, কিন্তু পুরনো হিসাব থাকবে।';

  @override
  String get errCategoryDuplicate => 'এই নামের একটি খাত আছে';

  @override
  String get errCategoryEmpty => 'একটি নাম দিন';

  @override
  String get unitKm => 'কিমি';

  @override
  String todayWithVehicle(String vehicle) {
    return 'আজ · $vehicle';
  }

  @override
  String get incomeToday => 'আজকের আয়';

  @override
  String get profitToday => 'আজকের লাভ';

  @override
  String get gasFuel => 'গ্যাস / জ্বালানি';

  @override
  String get closeDay => 'দিন শেষ করুন';

  @override
  String incomeAdded(String amount) {
    return '$amount যোগ হয়েছে';
  }

  @override
  String get undo => 'ফিরিয়ে নিন';

  @override
  String get incomeUndone => 'ফিরিয়ে নেওয়া হয়েছে';

  @override
  String get closeDayTitle => 'দিনের হিসাব';

  @override
  String get closeDayIncome => 'আয়';

  @override
  String get closeDayRunning => 'চলতি খরচ';

  @override
  String get closeDayDriver => 'ড্রাইভারের খরচ';

  @override
  String get closeDayVehicleCosts => 'গাড়ির খরচ';

  @override
  String get closeDayNet => 'নিট লাভ';

  @override
  String get settlementTitle => 'ড্রাইভারের সাথে হিসাব';

  @override
  String settlementJama(String amount, String driver) {
    return 'আজ $driver এর কাছ থেকে জমা $amount নিন।';
  }

  @override
  String settlementSalary(String driver) {
    return '$driver মাসিক বেতনে আছেন, যা প্রতিদিন জমছে।';
  }

  @override
  String settlementDaily(String driver) {
    return '$driver কাজের দিন অনুযায়ী মজুরি পান। দেওয়ার সময় পরিশোধ লিখুন।';
  }

  @override
  String settlementPerTrip(String driver) {
    return '$driver ট্রিপ থেকে পান। দেওয়ার সময় পরিশোধ লিখুন।';
  }

  @override
  String get settlementNone => 'ড্রাইভারের সাথে কোনো হিসাব বাকি নেই।';

  @override
  String get periodWeek => 'এই সপ্তাহ';

  @override
  String get profitSummary => 'লাভের সারসংক্ষেপ';

  @override
  String get repIncome => 'আয়';

  @override
  String get repRunning => 'চলতি খরচ';

  @override
  String get repDriver => 'ড্রাইভারের খরচ';

  @override
  String get repOperating => 'পরিচালন লাভ';

  @override
  String get repVehicleCosts => 'গাড়ির খরচ';

  @override
  String get repNet => 'নিট লাভ';

  @override
  String get repReceivable => 'এখনো পাওয়া যায়নি';

  @override
  String get repPerTrip => 'ট্রিপ প্রতি';

  @override
  String get repPerDay => 'কাজের দিন প্রতি';

  @override
  String get vehiclesRanking => 'গাড়ি';

  @override
  String get trendTitle => 'লাভের ধারা';

  @override
  String get incomeVsCost => 'আয় ও খরচ';

  @override
  String get expenseMixTitle => 'খরচ কোথায় গেছে';

  @override
  String get noDataYet => 'এই সময়ে এখনো কিছু লেখা হয়নি।';

  @override
  String get amortizeFixed => 'গাড়ির খরচ মাস জুড়ে ভাগ করুন';

  @override
  String get amortizeFixedHint =>
      'মেরামত, বীমা ও কিস্তি যেদিন দেওয়া হয়েছে সেদিন না ধরে মাসের সব দিনে ভাগ করা হবে।';

  @override
  String get chartIncome => 'আয়';

  @override
  String get chartCosts => 'খরচ';

  @override
  String get chartProfit => 'লাভ';

  @override
  String get generateDemo => 'ডেমো তথ্য তৈরি করুন';

  @override
  String get demoDone => 'ডেমো তথ্য তৈরি হয়েছে';
}
