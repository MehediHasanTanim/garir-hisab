import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_khata/features/onboarding/domain/onboarding_state.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

class OnboardingRepository {
  new(this._prefs);

  static const _step = 'onboarding.step';
  static const _role = 'onboarding.role';
  static const _nickname = 'onboarding.vehicleNickname';
  static const _type = 'onboarding.vehicleType';

  final SharedPreferences _prefs;

  OnboardingState load() => OnboardingState(
    step:
        _byName(OnboardingStep.values, _prefs.getString(_step)) ??
        OnboardingStep.language,
    role: _byName(UserRole.values, _prefs.getString(_role)) ?? UserRole.owner,
    vehicleNickname: _prefs.getString(_nickname) ?? '',
    vehicleType:
        _byName(VehicleType.values, _prefs.getString(_type)) ?? VehicleType.cng,
  );

  Future<void> save(OnboardingState s) async {
    await _prefs.setString(_step, s.step.name);
    await _prefs.setString(_role, s.role.name);
    await _prefs.setString(_nickname, s.vehicleNickname);
    await _prefs.setString(_type, s.vehicleType.name);
  }

  static T? _byName<T extends Enum>(List<T> values, String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
