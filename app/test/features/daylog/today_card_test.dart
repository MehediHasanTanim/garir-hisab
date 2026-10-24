import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

DateTime _clock() => DateTime(2026, 3, 15, 10);

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _keypad(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.widgetWithText(FilledButton, d).first);
    await tester.pump();
  }
  await tester.tap(find.widgetWithText(FilledButton, 'Done'));
  await tester.pumpAndSettle();
}

void main() {
  late TestApp app;

  Future<String> open(
    WidgetTester tester, {
    BusinessModel model = BusinessModel.self,
    String location = '/home',
  }) async {
    app = await pumpApp(tester, location: location, clock: _clock);
    final id = await app.container
        .read(vehicleRepositoryProvider)
        .create(vehicleFor(model, name: 'Rahim CNG'));
    await app.container.read(categoryRepositoryProvider).ensureDefaults();
    await tester.pumpAndSettle();
    return id;
  }

  Future<List<DayLogRow>> logs() => app.db.select(app.db.dayLogs).get();

  testWidgets('there is no card until a vehicle exists', (tester) async {
    app = await pumpApp(tester, clock: _clock);
    expect(find.textContaining('Today ·'), findsNothing);
    expect(find.text('Add income'), findsNothing);
  });

  testWidgets('shows today for the first vehicle, starting at zero', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Today · Rahim CNG'), findsOneWidget);
    expect(find.text('Income today'), findsOneWidget);
    expect(find.text('Profit today'), findsOneWidget);
    expect(find.text('৳ 0'), findsNWidgets(2));
  });

  testWidgets('a quick amount adds to today and can be undone', (tester) async {
    final v = await open(tester);
    await _tap(tester, '+৳ 100');
    expect(find.text('৳ 100'), findsWidgets);
    expect(find.text('Added ৳ 100'), findsOneWidget);
    expect((await logs()).single.collectionMinor, 10000);

    await _tap(tester, '+৳ 500');
    expect((await logs()).single.collectionMinor, 60000);

    await _tap(tester, 'Undo');
    expect((await logs()).single.collectionMinor, 10000);
    expect(find.text('Undone'), findsOneWidget);
    expect((await logs()).single.vehicleId, v);
  });

  testWidgets('Add income takes any amount and merges into the day', (
    tester,
  ) async {
    await open(tester);
    await _tap(tester, 'Add income');
    await _keypad(tester, '2800');
    expect(find.text('৳ 2,800'), findsWidgets);
    await _tap(tester, '+৳ 50');
    await tester.pumpAndSettle();
    final all = await logs();
    expect(all, hasLength(1));
    expect(all.single.collectionMinor, 285000);
    expect(find.text('৳ 2,850'), findsWidgets);
  });

  testWidgets('a zero amount adds nothing', (tester) async {
    await open(tester);
    await _tap(tester, 'Add income');
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();
    expect(await logs(), isEmpty);
  });

  testWidgets('gas goes through the expense editor and reduces profit', (
    tester,
  ) async {
    await open(tester);
    await _tap(tester, '+৳ 500');
    await _tap(tester, '+৳ 500');
    await _tap(tester, 'Gas / fuel');
    expect(find.text('Add expense'), findsOneWidget);
    expect(find.text('Fuel / CNG gas'), findsWidgets);
    await _tap(tester, 'Tap to enter');
    await _keypad(tester, '600');
    await tester.enterText(
      find.widgetWithText(TextField, 'Quantity (litres or m³) (Optional)'),
      '18',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
    await tester.pumpAndSettle();

    expect(find.text('Expense saved'), findsOneWidget);
    final e = (await app.db.select(app.db.expenses).get()).single;
    expect(e.categoryId, 'default:fuel');
    expect(e.tripId, isNull);
    expect(e.qtyMilli, 18000);
    expect(find.text('৳ 400'), findsWidgets, reason: 'profit = 1,000 - 600');
  });

  testWidgets(
    'the CNG example from the spec: 2,800 - gas 600 - other 100 = 2,100',
    (tester) async {
      final v = await open(tester);
      await _tap(tester, 'Add income');
      await _keypad(tester, '2800');
      await app.container
          .read(expenseRepositoryProvider)
          .create(
            v,
            ExpenseDraftFor.fuel(600, DateTime(2026, 3, 15, 10).toUtc()),
          );
      await app.container
          .read(expenseRepositoryProvider)
          .create(
            v,
            ExpenseDraftFor.other(100, DateTime(2026, 3, 15, 11).toUtc()),
          );
      await tester.pumpAndSettle();
      expect(find.text('৳ 2,100'), findsWidgets);
    },
  );

  testWidgets('with several vehicles the card can be switched', (tester) async {
    await open(tester);
    await app.container
        .read(vehicleRepositoryProvider)
        .create(vehicleFor(BusinessModel.self, name: 'Karim Pickup'));
    await tester.pumpAndSettle();
    expect(find.text('Today · Rahim CNG'), findsOneWidget);
    await _tap(tester, '+৳ 200');

    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Karim Pickup').last); // the menu entry
    await tester.pumpAndSettle();
    expect(find.text('Today · Karim Pickup'), findsOneWidget);
    expect(
      find.text('৳ 0'),
      findsNWidgets(2),
      reason: 'the other vehicle has nothing today',
    );
    await _tap(tester, '+৳ 50');
    expect(await logs(), hasLength(2));
  });

  testWidgets('archived vehicles are not offered', (tester) async {
    final v = await open(tester);
    await app.container
        .read(vehicleRepositoryProvider)
        .setArchived(v, archived: true);
    await tester.pumpAndSettle();
    expect(find.textContaining('Today ·'), findsNothing);
  });

  group('close the day', () {
    testWidgets("shows the day's figures", (tester) async {
      final v = await open(tester);
      await _tap(tester, 'Add income');
      await _keypad(tester, '2800');
      await app.container
          .read(expenseRepositoryProvider)
          .create(
            v,
            ExpenseDraftFor.fuel(600, DateTime(2026, 3, 15, 10).toUtc()),
          );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 6)); // the undo window ends
      await _tap(tester, 'Close day');

      expect(find.textContaining('Close the day'), findsOneWidget);
      expect(find.text('Rahim CNG'), findsOneWidget);
      expect(find.text('৳ 2,800'), findsOneWidget);
      expect(find.text('-৳ 600'), findsOneWidget);
      expect(find.text('৳ 2,200'), findsOneWidget);
      expect(find.text('No driver settlement is due.'), findsOneWidget);

      await _tap(tester, 'Done');
      expect(find.text('Today · Rahim CNG'), findsOneWidget);
    });

    testWidgets('tells you to collect jama from a jama driver', (tester) async {
      final v = await open(tester, model: BusinessModel.jama);
      final karim = await app.container
          .read(driverRepositoryProvider)
          .create(const DriverDraft(name: 'Karim'));
      await app.container
          .read(assignmentRepositoryProvider)
          .assign(
            vehicleId: v,
            driverId: karim,
            payModel: const JamaPay(amount: Money.taka(600)),
            start: day(2026, 3, 1),
          );
      await tester.pumpAndSettle();
      await _tap(tester, 'Close day');
      expect(find.text('Collect jama ৳ 600 from Karim today.'), findsOneWidget);
    });

    testWidgets('explains a salaried driver and shows their accrual', (
      tester,
    ) async {
      final v = await open(tester, model: BusinessModel.salaried);
      final karim = await app.container
          .read(driverRepositoryProvider)
          .create(const DriverDraft(name: 'Karim'));
      await app.container
          .read(assignmentRepositoryProvider)
          .assign(
            vehicleId: v,
            driverId: karim,
            payModel: const SalaryPay(monthly: Money.taka(15500)),
            start: day(2026, 3, 1),
          );
      await tester.pumpAndSettle();
      await _tap(tester, 'Close day');
      expect(
        find.text('Karim is on a monthly salary, which builds up each day.'),
        findsOneWidget,
      );
      expect(find.text('-৳ 500'), findsWidgets);
    });

    testWidgets('unknown vehicle', (tester) async {
      await open(tester, location: '/vehicles/nope/close-day');
      expect(find.text('Vehicle not found'), findsOneWidget);
    });
  });

  testWidgets('Home and the close-day page fit at 200% text size', (
    tester,
  ) async {
    app = await pumpApp(tester, clock: _clock, textScale: 2);
    final v = await app.container
        .read(vehicleRepositoryProvider)
        .create(
          vehicleFor(
            BusinessModel.jama,
            name: 'A rather long vehicle nickname',
          ),
        );
    await app.container.read(categoryRepositoryProvider).ensureDefaults();
    final karim = await app.container
        .read(driverRepositoryProvider)
        .create(const DriverDraft(name: 'Abdul Karim Uddin Ahmed'));
    await app.container
        .read(assignmentRepositoryProvider)
        .assign(
          vehicleId: v,
          driverId: karim,
          payModel: const JamaPay(amount: Money.taka(600)),
          start: day(2026, 3, 1),
        );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    app.container.read(routerProvider).go('/vehicles/$v/close-day');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
