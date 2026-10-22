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
