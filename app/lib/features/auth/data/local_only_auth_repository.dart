import 'package:vehicle_khata/features/auth/domain/auth_repository.dart';

/// Used when no backend is configured: sign-in is unavailable and the app
/// runs purely on-device.
class LocalOnlyAuthRepository implements AuthRepository {
  const new();

  @override
  bool get isConfigured => false;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> authChanges() => const Stream.empty();

  @override
  Future<void> sendOtp(String phoneE164) =>
      Future.error(const AuthException(AuthFailure.unknown, 'not configured'));

  @override
  Future<AuthUser> verifyOtp({
    required String phoneE164,
    required String code,
  }) =>
      Future.error(const AuthException(AuthFailure.unknown, 'not configured'));

  @override
  Future<void> signOut() async {}
}
