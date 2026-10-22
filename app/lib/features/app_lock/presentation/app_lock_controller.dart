import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/features/app_lock/data/pin_lock_repository.dart';
import 'package:vehicle_khata/features/app_lock/domain/lock_policy.dart';

final pinLockRepositoryProvider = Provider<PinLockRepository>(
  (ref) => PinLockRepository(
    ref.watch(secretStoreProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);

final biometricAuthProvider = Provider<BiometricAuth>(
  (ref) => LocalAuthBiometric(),
);

/// Injectable clock for tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

@immutable
class AppLockState {
  const new({
    required this.enabled,
    required this.locked,
    required this.biometricEnabled,
    required this.timeout,
    this.failedAttempts = 0,
    this.lastFailureAt,
  });

  final bool enabled;
  final bool locked;
  final bool biometricEnabled;
  final LockTimeout timeout;
  final int failedAttempts;
  final DateTime? lastFailureAt;

  AppLockState copyWith({
    bool? enabled,
    bool? locked,
    bool? biometricEnabled,
    LockTimeout? timeout,
    int? failedAttempts,
    DateTime? Function()? lastFailureAt,
  }) => AppLockState(
    enabled: enabled ?? this.enabled,
    locked: locked ?? this.locked,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    timeout: timeout ?? this.timeout,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    lastFailureAt: lastFailureAt == null ? this.lastFailureAt : lastFailureAt(),
  );
}

enum UnlockResult { success, wrongPin, blocked }

class AppLockController extends Notifier<AppLockState> {
  DateTime? _backgroundedAt;

  PinLockRepository get _repo => ref.read(pinLockRepositoryProvider);

  @override
  AppLockState build() {
    final repo = ref.watch(pinLockRepositoryProvider);
    // Locked from the start when a PIN is set.
    return AppLockState(
      enabled: repo.isEnabled,
      locked: repo.isEnabled,
      biometricEnabled: repo.biometricEnabled,
      timeout: repo.timeout,
    );
  }

  /// Remaining lockout time after too many wrong PINs, or null.
  Duration? blockedFor() => LockPolicy.blockedFor(
    failedAttempts: state.failedAttempts,
    lastFailureAt: state.lastFailureAt,
    now: ref.read(clockProvider)(),
  );

  void onBackgrounded() {
    if (!state.enabled) return;
    _backgroundedAt = ref.read(clockProvider)();
  }

  void onResumed() {
    if (!state.enabled || state.locked) return;
    final lock = LockPolicy.shouldLock(
      backgroundedAt: _backgroundedAt,
      now: ref.read(clockProvider)(),
      timeout: state.timeout,
    );
    _backgroundedAt = null;
    if (lock) state = state.copyWith(locked: true);
  }

  Future<UnlockResult> unlockWithPin(String pin) async {
    if (blockedFor() != null) return UnlockResult.blocked;
    if (await _repo.verify(pin)) {
      state = state.copyWith(
        locked: false,
        failedAttempts: 0,
        lastFailureAt: () => null,
      );
      return UnlockResult.success;
    }
    state = state.copyWith(
      failedAttempts: state.failedAttempts + 1,
      lastFailureAt: () => ref.read(clockProvider)(),
    );
    return blockedFor() != null ? UnlockResult.blocked : UnlockResult.wrongPin;
  }

  Future<bool> unlockWithBiometric(String reason) async {
    if (!state.biometricEnabled) return false;
    final ok = await ref.read(biometricAuthProvider).authenticate(reason);
    if (ok) {
      state = state.copyWith(
        locked: false,
        failedAttempts: 0,
        lastFailureAt: () => null,
      );
    }
    return ok;
  }

  Future<bool> verifyPin(String pin) => _repo.verify(pin);

  /// Turns the lock on with a new PIN (does not lock the current session).
  Future<void> enable(String pin) async {
    await _repo.setPin(pin);
    state = state.copyWith(enabled: true, locked: false);
  }

  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    if (!await _repo.verify(currentPin)) return false;
    await _repo.setPin(newPin);
    return true;
  }

  /// Turns the lock off after verifying the current PIN.
  Future<bool> disable(String currentPin) async {
    if (!await _repo.verify(currentPin)) return false;
    await _repo.clear();
    state = state.copyWith(
      enabled: false,
      locked: false,
      biometricEnabled: false,
    );
    return true;
  }

  Future<void> setBiometric({required bool enabled}) async {
    await _repo.setBiometric(enabled: enabled);
    state = state.copyWith(biometricEnabled: enabled);
  }

  Future<void> setTimeout(LockTimeout t) async {
    await _repo.setTimeout(t);
    state = state.copyWith(timeout: t);
  }
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);
