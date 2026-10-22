import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/features/auth/data/fake_auth_repository.dart';
import 'package:vehicle_khata/features/auth/domain/auth_repository.dart';

import '../../helpers/pump_app.dart';

/// Opens the account page with a configured (fake) backend.
Future<FakeAuthRepository> _openAccount(WidgetTester tester) async {
  final auth = FakeAuthRepository();
  await pumpApp(tester, location: '/more/account', auth: auth);
  return auth;
}

void main() {
  testWidgets('rejects an invalid phone number without calling the backend', (
    tester,
  ) async {
    final auth = await _openAccount(tester);
    await tester.enterText(find.byType(TextField), '12345');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a valid mobile number, e.g. 01712345678'),
      findsOneWidget,
    );
    expect(auth.sentTo, isEmpty);
  });

  testWidgets('accepts Bangla digits in the phone field', (tester) async {
    final auth = await _openAccount(tester);
    await tester.enterText(find.byType(TextField), '০১৭১২৩৪৫৬৭৮');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(auth.sentTo, ['+8801712345678']);
  });

  for (final (failure, message) in [
    (
      AuthFailure.rateLimited,
      'Too many attempts. Please wait a while and try again.',
    ),
    (
      AuthFailure.network,
      'No internet connection. Try again, or continue without an account.',
    ),
    (AuthFailure.unknown, 'Something went wrong. Please try again.'),
  ]) {
    testWidgets('shows a friendly message for $failure on send', (
      tester,
    ) async {
      final auth = await _openAccount(tester);
      auth.failNext = failure;
      await tester.enterText(find.byType(TextField), '01712345678');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
      // Stays on the phone step so the user can retry.
      expect(find.text('Send code'), findsOneWidget);
    });
  }

  testWidgets('change number returns to the phone step', (tester) async {
    await _openAccount(tester);
    await tester.enterText(find.byType(TextField), '01712345678');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change number'));
    await tester.pumpAndSettle();
    expect(find.text('Send code'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('signing in shows the account, and sign out reverts', (
    tester,
  ) async {
    await _openAccount(tester);
    await tester.enterText(find.byType(TextField), '01712345678');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();

    expect(find.text('Signed in as +8801712345678'), findsOneWidget);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to back up your data'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('without a backend the account page explains sign-in is off', (
    tester,
  ) async {
    await pumpApp(tester, location: '/more/account');
    expect(
      find.text('Sign-in is not available in this version.'),
      findsOneWidget,
    );
  });

  testWidgets('More shows the signed-in phone number', (tester) async {
    final auth = FakeAuthRepository();
    await auth.verifyOtp(phoneE164: '+8801712345678', code: '123456');
    await pumpApp(tester, location: '/more', auth: auth);
    expect(find.text('+8801712345678'), findsOneWidget);
  });
}
