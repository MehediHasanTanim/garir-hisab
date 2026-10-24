import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_khata/app/flavor.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/database_key_store.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/settings/app_settings.dart';
import 'package:vehicle_khata/core/settings/settings_repository.dart';

/// The running flavor; development tools are hidden in `prod`.
final flavorProvider = Provider<Flavor>((ref) => Flavor.prod);

/// Must be overridden at startup with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final secretStoreProvider = Provider<SecretStore>(
  (ref) => const KeystoreSecretStore(),
);

/// The encrypted app database. Tests override this with
/// `AppDatabase.inMemory()`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.encrypted(
    DatabaseKeyStore(ref.watch(secretStoreProvider)),
  );
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> _update(AppSettings next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setLanguage(String code) =>
      _update(state.copyWith(languageCode: code));
  Future<void> setNumerals(NumeralStyle v) =>
      _update(state.copyWith(numerals: v));
  Future<void> setGrouping(GroupingStyle v) =>
      _update(state.copyWith(grouping: v));
  Future<void> setProfitView(ProfitView v) =>
      _update(state.copyWith(profitView: v));
  Future<void> setAmortizeFixed({required bool value}) =>
      _update(state.copyWith(amortizeFixed: value));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

final numberFormatterProvider = Provider<NumberFormatter>(
  (ref) => ref.watch(settingsProvider).formatter,
);
