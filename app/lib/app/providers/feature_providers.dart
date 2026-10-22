import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/features/auth/data/local_only_auth_repository.dart';
import 'package:vehicle_khata/features/auth/domain/auth_repository.dart';
import 'package:vehicle_khata/features/onboarding/data/onboarding_repository.dart';
import 'package:vehicle_khata/features/onboarding/domain/onboarding_state.dart';
import 'package:vehicle_khata/features/vehicles/data/photo_store.dart';
import 'package:vehicle_khata/features/vehicles/data/vehicle_repository.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_rules.dart';

// ---- Auth ----------------------------------------------------------------

/// Overridden at startup with the Supabase implementation when configured.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const LocalOnlyAuthRepository(),
);

/// Emits the signed-in user (or null) and follows sign-in/out.
final authUserProvider = StreamProvider<AuthUser?>((ref) async* {
  final auth = ref.watch(authRepositoryProvider);
  yield auth.currentUser;
  yield* auth.authChanges();
});

// ---- Vehicles ------------------------------------------------------------

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) => VehicleRepository(ref.watch(appDatabaseProvider)),
);

final photoStoreProvider = Provider<PhotoStore>(
  (ref) => PhotoStore.appStorage(),
);

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => ImagePickerPhotoPicker(),
);

final vehicleListProvider = StreamProvider.autoDispose
    .family<List<Vehicle>, VehicleFilter>(
      (ref, filter) => ref.watch(vehicleRepositoryProvider).watch(filter),
    );

final vehicleProvider = StreamProvider.autoDispose.family<Vehicle?, String>(
  (ref, id) => ref.watch(vehicleRepositoryProvider).watchOne(id),
);

// ---- Onboarding ----------------------------------------------------------

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(ref.watch(sharedPreferencesProvider)),
);

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => ref.watch(onboardingRepositoryProvider).load();

  Future<void> _set(OnboardingState next) async {
    state = next;
    await ref.read(onboardingRepositoryProvider).save(next);
  }

  Future<void> _goTo(OnboardingStep step) => _set(state.copyWith(step: step));

  /// Language chosen (the choice itself lives in settings).
  Future<void> languageDone() => _goTo(OnboardingStep.account);

  /// Account step finished (signed in) or skipped (local-only).
  Future<void> accountDone() => _goTo(OnboardingStep.role);

  Future<void> chooseRole(UserRole role) =>
      _set(state.copyWith(role: role, step: OnboardingStep.vehicle));

  Future<void> saveVehicleBasics({
    required String nickname,
    required VehicleType type,
  }) => _set(
    state.copyWith(
      vehicleNickname: VehicleRules.cleanText(nickname),
      vehicleType: type,
      step: OnboardingStep.model,
    ),
  );

  /// Creates the first vehicle with the chosen model and ends onboarding.
  Future<String> finish(BusinessModel model) async {
    final id = await ref
        .read(vehicleRepositoryProvider)
        .create(
          VehicleDraft(
            nickname: state.vehicleNickname,
            type: state.vehicleType,
            fuelType: state.vehicleType.defaultFuel,
            businessModel: model,
          ),
        );
    await _goTo(OnboardingStep.done);
    return id;
  }

  /// Skip creating a vehicle for now.
  Future<void> skipVehicle() => _goTo(OnboardingStep.done);

  Future<void> back() async {
    final previous = switch (state.step) {
      OnboardingStep.account => OnboardingStep.language,
      OnboardingStep.role => OnboardingStep.account,
      OnboardingStep.vehicle => OnboardingStep.role,
      OnboardingStep.model => OnboardingStep.vehicle,
      _ => null,
    };
    if (previous != null) await _goTo(previous);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
