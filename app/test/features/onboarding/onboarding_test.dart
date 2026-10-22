import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/features/auth/data/fake_auth_repository.dart';
import 'package:vehicle_khata/features/auth/presentation/auth_flow.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/pump_app.dart';

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('fresh install is redirected to onboarding, Bangla by default', (
    tester,
  ) async {
    await pumpApp(tester, onboarded: false, prefs: {'settings.language': 'bn'});
    expect(find.text('গাড়ি খাতায় স্বাগতম'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('language choice switches the UI immediately', (tester) async {
    await pumpApp(tester, onboarded: false, prefs: {'settings.language': 'bn'});
    await _tap(tester, 'English');
    expect(find.text('Welcome to Vehicle Khata'), findsOneWidget);
  });

  testWidgets('shows step progress and supports going back', (tester) async {
    await pumpApp(tester, onboarded: false);
    expect(find.text('Step 1 of 5'), findsOneWidget);
    await _tap(tester, 'Continue');
    expect(find.text('Step 2 of 5'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 5'), findsOneWidget);
  });

  testWidgets('local-only flow creates the first vehicle and lands on Home', (
    tester,
  ) async {
    final app = await pumpApp(tester, onboarded: false);
    await _tap(tester, 'Continue'); // language
    expect(
      find.text('Sign-in is not available in this version.'),
      findsOneWidget,
    );
    await _tap(tester, 'Continue without account');
    await _tap(tester, 'I own vehicles');

    await tester.enterText(find.byType(TextField), "Rahim's CNG");
    await _tap(tester, 'Pickup');
    await _tap(tester, 'Continue');

    // Pickup defaults to a per-trip contract; change to jama.
    expect(find.text('How does this vehicle earn?'), findsOneWidget);
    await _tap(tester, 'Jama (rent)');
    await _tap(tester, 'Finish setup');

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text("Rahim's CNG"), findsOneWidget);

    final vehicles = await app.db.select(app.db.vehicles).get();
    expect(vehicles, hasLength(1));
    expect(vehicles.single.type, VehicleType.pickup);
    expect(vehicles.single.fuelType, FuelType.diesel);
    expect(vehicles.single.businessModel, BusinessModel.jama);
    expect(app.container.read(onboardingProvider).isDone, isTrue);
  });

  testWidgets('validates the vehicle nickname', (tester) async {
    await pumpApp(
      tester,
      onboarded: false,
      prefs: {'onboarding.step': 'vehicle'},
    );
    await _tap(tester, 'Continue');
    expect(find.text('Enter a nickname'), findsOneWidget);
    expect(find.text('How does this vehicle earn?'), findsNothing);
  });

  testWidgets('skipping the vehicle finishes onboarding with no vehicles', (
    tester,
  ) async {
    final app = await pumpApp(
      tester,
      onboarded: false,
      prefs: {'onboarding.step': 'vehicle'},
    );
    await _tap(tester, 'Skip for now');
    expect(find.text('No vehicles yet'), findsOneWidget);
    expect(await app.db.select(app.db.vehicles).get(), isEmpty);
  });

  testWidgets('resumes at the saved step after the app is killed', (
    tester,
  ) async {
    await pumpApp(
      tester,
      onboarded: false,
      prefs: {
        'onboarding.step': 'model',
        'onboarding.vehicleNickname': 'Saved truck',
        'onboarding.vehicleType': 'truck',
      },
    );
    expect(find.text('How does this vehicle earn?'), findsOneWidget);
    // Truck defaults to per-trip contract (selected tile shows a check).
    await _tap(tester, 'Finish setup');
    expect(find.text('Saved truck'), findsOneWidget);
  });

  testWidgets('driver role is not selectable yet', (tester) async {
    await pumpApp(tester, onboarded: false, prefs: {'onboarding.step': 'role'});
    expect(find.text('Coming soon'), findsOneWidget);
    await tester.tap(find.text('I drive for an owner'));
    await tester.pumpAndSettle();
    expect(find.text('How will you use the app?'), findsOneWidget);
  });

  group('with a configured backend', () {
    testWidgets('OTP sign-in leads to the role step', (tester) async {
      final auth = FakeAuthRepository();
      await pumpApp(
        tester,
        onboarded: false,
        prefs: {'onboarding.step': 'account'},
        auth: auth,
      );
      expect(find.text('Sign in with your phone'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '01712345678');
      await _tap(tester, 'Send code');
      expect(auth.sentTo, ['+8801712345678']);
      expect(find.text('Code sent to 01712-345678'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '000000');
      await tester.pumpAndSettle();
      expect(
        find.text('That code is incorrect or has expired.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();
      expect(find.text('How will you use the app?'), findsOneWidget);
    });

    testWidgets('can skip sign-in', (tester) async {
      await pumpApp(
        tester,
        onboarded: false,
        prefs: {'onboarding.step': 'account'},
        auth: FakeAuthRepository(),
      );
      await _tap(tester, 'Continue without account');
      expect(find.text('How will you use the app?'), findsOneWidget);
    });

    testWidgets('an already signed-in user just continues', (tester) async {
      final auth = FakeAuthRepository();
      await auth.verifyOtp(phoneE164: '+8801712345678', code: '123456');
      await pumpApp(
        tester,
        onboarded: false,
        prefs: {'onboarding.step': 'account'},
        auth: auth,
      );
      expect(find.text('Signed in as +8801712345678'), findsOneWidget);
      await _tap(tester, 'Continue');
      expect(find.text('How will you use the app?'), findsOneWidget);
    });
  });

  testWidgets('resend cooldown counts down then allows another code', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await pumpApp(
      tester,
      onboarded: false,
      prefs: {'onboarding.step': 'account'},
      auth: auth,
      overrides: [
        resendCooldownProvider.overrideWithValue(const Duration(seconds: 3)),
      ],
    );
    await tester.enterText(find.byType(TextField), '01712345678');
    await _tap(tester, 'Send code');
    expect(find.text('Resend code in 3s'), findsOneWidget);
    await tester.tap(find.text('Resend code in 3s'));
    await tester.pump();
    expect(auth.sentTo, hasLength(1));

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Resend code'), findsOneWidget);
    await tester.tap(find.text('Resend code'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(auth.sentTo, hasLength(2));

    await tester.pumpWidget(const SizedBox());
  });
}
