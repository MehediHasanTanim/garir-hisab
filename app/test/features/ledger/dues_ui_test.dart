import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';

import '../../helpers/fake_file_sharer.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

Future<void> _keypad(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.widgetWithText(FilledButton, d).first);
    await tester.pump();
  }
  await tester.tap(find.widgetWithText(FilledButton, 'Done'));
  await tester.pumpAndSettle();
}

Future<(TestApp, FakeFileSharer)> _open(
  WidgetTester tester, {
  String route = '/more/dues',
  double textScale = 1,
  Map<String, Object> prefs = const {},
}) async {
  final sharer = FakeFileSharer();
  final app = await pumpApp(
    tester,
    clock: () => DateTime(2026, 4, 20, 10),
    textScale: textScale,
    prefs: prefs,
    overrides: [fileSharerProvider.overrideWithValue(sharer)],
  );
  final c = app.container;
  final v = await c.read(vehicleRepositoryProvider).create(salariedVehicle());
  for (final (day, fare) in [(2, 1000), (10, 500)]) {
    await c
        .read(tripRepositoryProvider)
        .create(
          TripDraft(
            vehicleId: v,
            startedAt: DateTime.utc(2026, 4, day, 8),
            fare: Money.taka(fare),
            received: Money.zero,
            driverPay: Money.zero,
          ),
        );
  }
  c.read(routerProvider).go(route);
  await tester.pumpAndSettle();
  return (app, sharer);
}

void main() {
  testWidgets('lists who owes you, with the total', (tester) async {
    await _open(tester);
    expect(find.text('Customers (no name)'), findsOneWidget);
    expect(find.text('owes you ৳ 1,500'), findsOneWidget);
  });

  testWidgets('party page shows ageing and receives a payment oldest first', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(find.text('Customers (no name)'));
    await tester.pumpAndSettle();
    // 2 Apr is 18 days old (8-30), 10 Apr is 10 days old (8-30).
    expect(find.text('0–7 days'), findsOneWidget);
    expect(find.text('Unpaid fare'), findsNWidgets(2));

    await tester.tap(find.text('Receive payment'));
    await tester.pumpAndSettle();
    await _keypad(tester, '1200');
    expect(find.textContaining('Payment recorded'), findsOneWidget);
    expect(find.text('owes you ৳ 300'), findsOneWidget);
    expect(find.text('Unpaid fare'), findsOneWidget);
  });

  testWidgets('paying more than is owed is refused', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Customers (no name)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receive payment'));
    await tester.pumpAndSettle();
    await _keypad(tester, '9999');
    expect(find.text('That is more than is owed.'), findsOneWidget);
    expect(find.text('owes you ৳ 1,500'), findsOneWidget);
  });

  testWidgets('reminder and statement open the share sheet with text', (
    tester,
  ) async {
    final (_, sharer) = await _open(tester);
    await tester.tap(find.text('Customers (no name)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send reminder'));
    await tester.pump();
    expect(sharer.texts.single, contains('1,500'));
    expect(sharer.texts.single, contains('due'));

    await tester.ensureVisible(find.text('Share statement'));
    await tester.tap(find.text('Share statement'));
    await tester.pump();
    expect(sharer.texts.last, contains('Statement for Customers (no name)'));
    expect(sharer.texts.last, contains('Balance: ৳ 1,500'));
  });

  testWidgets('empty when nothing is owed', (tester) async {
    final app = await pumpApp(tester, location: '/more/dues');
    expect(find.text('Nobody owes anything.'), findsOneWidget);
    expect(app.db, isNotNull);
  });

  testWidgets('fits at 200% text size, and Bangla labels', (tester) async {
    await _open(tester, textScale: 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bangla', (tester) async {
    await _open(tester, prefs: {'settings.language': 'bn'});
    expect(find.text('গ্রাহক (নাম ছাড়া)'), findsOneWidget);
  });
}
