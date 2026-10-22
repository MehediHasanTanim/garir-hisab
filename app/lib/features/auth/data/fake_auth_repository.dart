import 'dart:async';

import 'package:vehicle_khata/features/auth/domain/auth_repository.dart';

/// In-memory auth for tests and for running without a backend.
class FakeAuthRepository implements AuthRepository {
  new({this.validCode = '123456', this.configured = true});

  final String validCode;
  final bool configured;

  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _user;

  /// Set to make the next call fail.
  AuthFailure? failNext;
  final sentTo = <String>[];

  @override
  bool get isConfigured => configured;

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> authChanges() => _controller.stream;

  @override
  Future<void> sendOtp(String phoneE164) async {
    _maybeFail();
    sentTo.add(phoneE164);
  }

  @override
  Future<AuthUser> verifyOtp({
    required String phoneE164,
    required String code,
  }) async {
    _maybeFail();
    if (code != validCode) throw const AuthException(AuthFailure.invalidCode);
    final user = AuthUser(id: 'user-$phoneE164', phone: phoneE164);
    _user = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  void _maybeFail() {
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw AuthException(f);
    }
  }
}
