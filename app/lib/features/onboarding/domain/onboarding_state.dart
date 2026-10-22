import 'package:meta/meta.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

enum UserRole { owner, driver }

/// Wizard steps, in order. `done` means onboarding is finished.
enum OnboardingStep { language, account, role, vehicle, model, done }

@immutable
class OnboardingState {
  const new({
    this.step = OnboardingStep.language,
    this.role = UserRole.owner,
    this.vehicleNickname = '',
    this.vehicleType = VehicleType.cng,
  });

  final OnboardingStep step;
  final UserRole role;

  /// Partial first-vehicle data carried between the `vehicle` and `model`
  /// steps so the flow survives the app being killed.
  final String vehicleNickname;
  final VehicleType vehicleType;

  bool get isDone => step == OnboardingStep.done;

  /// 1-based position for the progress indicator (excludes `done`).
  int get stepNumber => step.index + 1;
  static int get totalSteps => OnboardingStep.done.index;

  OnboardingState copyWith({
    OnboardingStep? step,
    UserRole? role,
    String? vehicleNickname,
    VehicleType? vehicleType,
  }) => OnboardingState(
    step: step ?? this.step,
    role: role ?? this.role,
    vehicleNickname: vehicleNickname ?? this.vehicleNickname,
    vehicleType: vehicleType ?? this.vehicleType,
  );
}
