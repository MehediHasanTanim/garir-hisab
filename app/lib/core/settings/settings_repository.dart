import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/settings/app_settings.dart';

/// Persists [AppSettings] in shared preferences. Unknown or missing values
/// fall back to defaults so a bad write can never break startup.
class SettingsRepository {
  new(this._prefs);

  static const _language = 'settings.language';
  static const _numerals = 'settings.numerals';
  static const _grouping = 'settings.grouping';
  static const _profitView = 'settings.profitView';
  static const _amortize = 'settings.amortizeFixed';

  final SharedPreferences _prefs;

  AppSettings load() {
    const defaults = AppSettings();
    final language = _prefs.getString(_language);
    return AppSettings(
      languageCode: AppSettings.supportedLanguages.contains(language)
          ? language!
          : defaults.languageCode,
      numerals:
          _enum(NumeralStyle.values, _prefs.getString(_numerals)) ??
          defaults.numerals,
      grouping:
          _enum(GroupingStyle.values, _prefs.getString(_grouping)) ??
          defaults.grouping,
      profitView:
          _enum(ProfitView.values, _prefs.getString(_profitView)) ??
          defaults.profitView,
      amortizeFixed: _prefs.getBool(_amortize) ?? defaults.amortizeFixed,
    );
  }

  Future<void> save(AppSettings s) async {
    await _prefs.setString(_language, s.languageCode);
    await _prefs.setString(_numerals, s.numerals.name);
    await _prefs.setString(_grouping, s.grouping.name);
    await _prefs.setString(_profitView, s.profitView.name);
    await _prefs.setBool(_amortize, s.amortizeFixed);
  }

  static T? _enum<T extends Enum>(List<T> values, String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
