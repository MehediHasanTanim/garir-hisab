import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/settings/app_settings.dart';
import 'package:vehicle_khata/core/settings/settings_repository.dart';

Future<SettingsRepository> _repo([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return SettingsRepository(await SharedPreferences.getInstance());
}

void main() {
  test('defaults: Bangla, Bangla numerals, lakh/crore, cash', () async {
    final s = (await _repo()).load();
    expect(s, const AppSettings());
    expect(s.languageCode, 'bn');
    expect(s.numerals, NumeralStyle.bangla);
    expect(s.grouping, GroupingStyle.southAsian);
    expect(s.profitView, ProfitView.cash);
  });

  test('save then load round-trips', () async {
    final repo = await _repo();
    const next = AppSettings(
      languageCode: 'en',
      numerals: NumeralStyle.latin,
      grouping: GroupingStyle.international,
      profitView: ProfitView.accrual,
    );
    await repo.save(next);
    expect(repo.load(), next);
  });

  test('corrupt values fall back to defaults', () async {
    final repo = await _repo({
      'settings.language': 'fr',
      'settings.numerals': 'roman',
      'settings.grouping': 7.toString(),
      'settings.profitView': '',
    });
    expect(repo.load(), const AppSettings());
  });
}
