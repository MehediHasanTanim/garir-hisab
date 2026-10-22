import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:vehicle_khata/features/auth/domain/auth_repository.dart';

/// Backend configuration passed with `--dart-define`.
class BackendConfig {
  const new({this.url = '', this.anonKey = ''});

  static const fromEnvironment = BackendConfig();

  final String url;
  final String anonKey;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

/// Supabase phone-OTP auth. Supabase persists the session locally, so a
/// signed-in user stays signed in across restarts, including offline.
class SupabaseAuthRepository implements AuthRepository {
  new(this._client);

  /// Initialises Supabase; returns null when [config] is not configured.
  static Future<SupabaseAuthRepository?> initialize(
    BackendConfig config,
  ) async {
    if (!config.isConfigured) return null;
    // The publishable (anon) key; safe to ship in the app.
    await sb.Supabase.initialize(
      url: config.url,
      publishableKey: config.anonKey,
    );
    return SupabaseAuthRepository(sb.Supabase.instance.client.auth);
  }

  final sb.GoTrueClient _client;

  @override
  bool get isConfigured => true;

  @override
  AuthUser? get currentUser => _toUser(_client.currentUser);

  @override
  Stream<AuthUser?> authChanges() =>
      _client.onAuthStateChange.map((s) => _toUser(s.session?.user));

  @override
  Future<void> sendOtp(String phoneE164) => _guard(() async {
    await _client.signInWithOtp(phone: phoneE164);
  });

  @override
  Future<AuthUser> verifyOtp({
    required String phoneE164,
    required String code,
  }) => _guard(() async {
    final res = await _client.verifyOTP(
      phone: phoneE164,
      token: code,
      type: sb.OtpType.sms,
    );
    final user = _toUser(res.user ?? res.session?.user);
    if (user == null) throw const AuthException(AuthFailure.unknown);
    return user;
  });

  @override
  Future<void> signOut() => _client.signOut();

  AuthUser? _toUser(sb.User? u) =>
      u == null ? null : AuthUser(id: u.id, phone: _e164(u.phone));

  static String _e164(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    return phone.startsWith('+') ? phone : '+$phone';
  }

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on AuthException {
      rethrow;
    } on sb.AuthException catch (e) {
      throw AuthException(_classify(e), e.message);
    } on SocketException {
      throw const AuthException(AuthFailure.network);
    } on TimeoutException {
      throw const AuthException(AuthFailure.network);
    }
  }

  static AuthFailure _classify(sb.AuthException e) {
    final code = e.code ?? '';
    final status = int.tryParse(e.statusCode ?? '');
    if (status == 429 || code.contains('rate_limit')) {
      return AuthFailure.rateLimited;
    }
    if (code == 'otp_expired' ||
        code.contains('invalid') ||
        e.message.toLowerCase().contains('invalid') ||
        e.message.toLowerCase().contains('expired')) {
      return code.contains('phone')
          ? AuthFailure.invalidPhone
          : AuthFailure.invalidCode;
    }
    return AuthFailure.unknown;
  }
}
