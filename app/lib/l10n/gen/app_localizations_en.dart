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
}
