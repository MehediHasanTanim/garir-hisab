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
  String get entriesEmptyTitle => 'এখনো কোনো এন্ট্রি নেই';

  @override
  String get entriesEmptyMessage => 'ট্রিপ ও দৈনিক আয় এখানে দেখা যাবে।';

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
}
