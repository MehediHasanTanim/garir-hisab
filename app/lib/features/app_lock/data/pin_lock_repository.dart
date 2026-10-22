import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_khata/core/db/database_key_store.dart';
import 'package:vehicle_khata/features/app_lock/domain/lock_policy.dart';
import 'package:vehicle_khata/features/app_lock/domain/pin_hasher.dart';

/// Biometric prompt abstraction (so tests don't need a device).
abstract interface class BiometricAuth {
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

class LocalAuthBiometric implements BiometricAuth {
  new([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.canCheckBiometrics) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } on Object {
      return false;
    }
  }
}

/// Stores the PIN hash and salt in the Keystore-backed secret store; simple
/// flags (enabled, biometric, timeout) live in shared preferences so the
/// lock state is known synchronously at startup.
class PinLockRepository {
  new(this._secrets, this._prefs);

  static const saltKey = 'app_lock_salt_v1';
  static const hashKey = 'app_lock_hash_v1';
  static const _enabled = 'lock.enabled';
  static const _biometric = 'lock.biometric';
  static const _timeout = 'lock.timeout';

  final SecretStore _secrets;
  final SharedPreferences _prefs;

  bool get isEnabled => _prefs.getBool(_enabled) ?? false;
  bool get biometricEnabled => _prefs.getBool(_biometric) ?? false;

  LockTimeout get timeout {
    final name = _prefs.getString(_timeout);
    return LockTimeout.values.firstWhere(
      (t) => t.name == name,
      orElse: () => LockTimeout.seconds30,
    );
  }

  Future<void> setPin(String pin) async {
    if (!PinHasher.isValidPin(pin)) throw ArgumentError('invalid PIN');
    final salt = PinHasher.newSalt();
    await _secrets.write(saltKey, salt);
    await _secrets.write(hashKey, PinHasher.hash(pin, salt));
    await _prefs.setBool(_enabled, true);
  }

  Future<bool> verify(String pin) async {
    final salt = await _secrets.read(saltKey);
    final hash = await _secrets.read(hashKey);
    if (salt == null || hash == null) return false;
    return PinHasher.verify(pin, salt: salt, hash: hash);
  }

  Future<void> clear() async {
    await _secrets.write(saltKey, '');
    await _secrets.write(hashKey, '');
    await _prefs.setBool(_enabled, false);
    await _prefs.setBool(_biometric, false);
  }

  Future<void> setBiometric({required bool enabled}) =>
      _prefs.setBool(_biometric, enabled);

  Future<void> setTimeout(LockTimeout t) => _prefs.setString(_timeout, t.name);
}
