import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_khata/app/app.dart';
import 'package:vehicle_khata/app/flavor.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/features/app_lock/data/pin_lock_repository.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/auth/domain/auth_repository.dart';
import 'package:vehicle_khata/features/vehicles/data/photo_store.dart';

import 'memory_secret_store.dart';

class FakeBiometric implements BiometricAuth {
  new({this.available = true, this.succeeds = true});

  bool available;
  bool succeeds;
  int prompts = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return succeeds;
  }
}

class FakePhotoPicker implements PhotoPicker {
  String? next;

  @override
  Future<String?> pick(PhotoSource source) async => next;
}

class TestApp {
  new(this.container, this.db, this.secrets);

  final ProviderContainer container;
  final AppDatabase db;
  final MemorySecretStore secrets;
}

/// Pumps the full app with an in-memory DB, mock preferences and fakes.
Future<TestApp> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  String location = Routes.home,
  double textScale = 1,

  /// Finished onboarding unless a test is about onboarding.
  bool onboarded = true,
  AuthRepository? auth,
  BiometricAuth? biometric,
  PhotoPicker? photoPicker,
  PhotoStore? photoStore,
  DateTime Function()? clock,
  List<Override> overrides = const [],
  MemorySecretStore? secrets,
}) async {
  // Tests deliberately create several in-memory databases.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  SharedPreferences.setMockInitialValues({
    if (onboarded) 'onboarding.step': 'done',
    'settings.language': 'en',
    'settings.numerals': 'latin',
    ...prefs,
  });
  final sharedPrefs = await SharedPreferences.getInstance();
  final db = AppDatabase.inMemory();
  addTearDown(db.close);
  final secretStore = secrets ?? MemorySecretStore();

  tester.view
    ..physicalSize = const Size(411, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      appDatabaseProvider.overrideWithValue(db),
      secretStoreProvider.overrideWithValue(secretStore),
      initialLocationProvider.overrideWithValue(location),
      if (auth != null) authRepositoryProvider.overrideWithValue(auth),
      biometricAuthProvider.overrideWithValue(biometric ?? FakeBiometric()),
      if (photoPicker != null)
        photoPickerProvider.overrideWithValue(photoPicker),
      if (photoStore != null) photoStoreProvider.overrideWithValue(photoStore),
      if (clock != null) clockProvider.overrideWithValue(clock),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  // Drift schedules a zero-length timer when a watched query is cancelled.
  // Unmount and pump so it fires inside this test, not the next one.
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const KhataApp(config: AppConfig(flavor: Flavor.dev)),
    ),
  );
  await tester.pumpAndSettle();
  return TestApp(container, db, secretStore);
}

/// Taps [digits] on the on-screen PIN pad.
Future<void> enterPin(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.widgetWithText(FilledButton, d));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
