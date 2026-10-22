import 'package:meta/meta.dart';

@immutable
class AuthUser {
  const new({required this.id, required this.phone});

  final String id;

  /// E.164 phone number.
  final String phone;
}

enum AuthFailure { invalidPhone, rateLimited, invalidCode, network, unknown }

class AuthException implements Exception {
  const new(this.failure, [this.message]);

  final AuthFailure failure;
  final String? message;

  @override
  String toString() =>
      'AuthException($failure${message == null ? '' : ': $message'})';
}

/// Phone-OTP authentication. Implementations must keep the session across
/// app restarts, including while offline.
abstract interface class AuthRepository {
  /// False when no backend is configured (local-only mode).
  bool get isConfigured;

  AuthUser? get currentUser;

  Stream<AuthUser?> authChanges();

  /// Sends a 6-digit code to [phoneE164].
  Future<void> sendOtp(String phoneE164);

  Future<AuthUser> verifyOtp({required String phoneE164, required String code});

  Future<void> signOut();
}
