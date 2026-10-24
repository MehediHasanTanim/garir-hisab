import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/vehicles/data/photo_store.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

DateTime _clock() => DateTime(2026, 3, 15, 10);

/// Lets real file IO (outside the fake-async zone) finish.
Future<void> _settleIo(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

/// Scrolls the sideways filter row until [target] is on screen.
Future<void> _reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    120,
    scrollable: find
        .ancestor(of: target, matching: find.byType(Scrollable))
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

/// Replaces the keypad's current value with [digits].
Future<void> _keypadFresh(WidgetTester tester, String digits) async {
  for (var i = 0; i < 9; i++) {
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
  }
  await _keypad(tester, digits);
}

/// Scrolls to and taps the expense row with this label.
Future<void> _tapRow(WidgetTester tester, String label) async {
  final row = find.widgetWithText(ListTile, label);
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

/// Types [digits] on the on-screen keypad and presses Done.
Future<void> _keypad(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.widgetWithText(FilledButton, d).first);
    await tester.pump();
  }
  await tester.tap(find.widgetWithText(FilledButton, 'Done'));
  await tester.pumpAndSettle();
}

TripDraft _trip({
  required String vehicle,
  String? driver,
  int fare = 1000,
  int? received,
  DateTime? at,
  String? from,
  String? to,
  int pay = 0,
  List<ExpenseDraft> expenses = const [],
  bool overridden = false,
}) => TripDraft(
  vehicleId: vehicle,
  driverId: driver,
  startedAt: at ?? DateTime(2026, 3, 10, 8).toUtc(),
  fare: Money.taka(fare),
  received: Money.taka(received ?? fare),
  driverPay: Money.taka(pay),
  driverPayOverridden: overridden,
  fromPlace: from,
  toPlace: to,
  expenses: expenses,
);

const _fuel = 'default:fuel';

void main() {
  late TestApp app;
  late String vehicleId;

  Future<void> open(
    WidgetTester tester, {
    String location = '/entries',
    BusinessModel model = BusinessModel.contract,
    double textScale = 1,
    PhotoPicker? picker,
    PhotoStore? store,
  }) async {
    app = await pumpApp(
      tester,
      location: '/more',
      clock: _clock,
      textScale: textScale,
      photoPicker: picker,
      photoStore: store,
    );
    vehicleId = await app.container
        .read(vehicleRepositoryProvider)
        .create(vehicleFor(model));
    await app.container.read(categoryRepositoryProvider).ensureDefaults();
    app.container.read(routerProvider).go(location);
    await tester.pumpAndSettle();
  }

  Future<String> seedTrip(TripDraft d) =>
      app.container.read(tripRepositoryProvider).create(d);

  Future<List<TripRow>> trips() => app.db.select(app.db.trips).get();
  Future<List<ExpenseRow>> expenses() => app.db.select(app.db.expenses).get();

  group('entries tab', () {
    testWidgets('no vehicles: adding a trip asks for a vehicle first', (
      tester,
    ) async {
      app = await pumpApp(tester, location: '/entries', clock: _clock);
      await tester.tap(find.widgetWithText(FilledButton, 'Add trip'));
      await tester.pumpAndSettle();
      expect(find.text('Add a vehicle before logging trips.'), findsOneWidget);
    });

    testWidgets('empty state with a vehicle', (tester) async {
      await open(tester);
      expect(find.text('No trips yet'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Add trip'));
      await tester.pumpAndSettle();
      expect(find.text('New trip'), findsOneWidget);
    });

    testWidgets(
      'lists trips grouped by day with route, fare, profit and payment',
      (tester) async {
        await open(tester);
        final karim = await app.container
            .read(driverRepositoryProvider)
            .create(const DriverDraft(name: 'Karim'));
        await seedTrip(
          _trip(
            vehicle: vehicleId,
            driver: karim,
            fare: 4500,
            pay: 900,
            from: 'Dhaka',
            to: 'Savar',
            expenses: const [
              ExpenseDraft(categoryId: _fuel, amount: Money.taka(1400)),
            ],
          ),
        );
        await seedTrip(
          _trip(
            vehicle: vehicleId,
            fare: 2000,
            received: 1500,
            at: DateTime(2026, 3, 12, 9).toUtc(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('10/03/2026'), findsOneWidget);
        expect(find.text('12/03/2026'), findsOneWidget);
        expect(find.text('Dhaka → Savar'), findsOneWidget);
        expect(find.text('Pickup 1 · Karim · Fare ৳ 4,500'), findsOneWidget);
        expect(find.text('৳ 2,200'), findsOneWidget); // 4500 - 1400 - 900
        // One is the filter chip, one the trip's payment label.
        expect(find.text('Paid'), findsNWidgets(2));
        expect(find.text('Due ৳ 500'), findsOneWidget);
        expect(
          find.text('Trip'),
          findsOneWidget,
          reason: 'no route -> generic title',
        );
      },
    );

    testWidgets('payment, vehicle and period filters', (tester) async {
      await open(tester);
      final other = await app.container
          .read(vehicleRepositoryProvider)
          .create(vehicleFor(BusinessModel.contract, name: 'Truck 2'));
      await seedTrip(_trip(vehicle: vehicleId, from: 'A', to: 'B'));
      await seedTrip(
        _trip(
          vehicle: vehicleId,
          fare: 2000,
          received: 0,
          from: 'C',
          to: 'D',
          at: DateTime(2026, 2, 1, 8).toUtc(),
        ),
      );
      await seedTrip(
        _trip(vehicle: other, fare: 3000, received: 100, from: 'E', to: 'F'),
      );
      await tester.pumpAndSettle();
      expect(find.text('A → B'), findsOneWidget);
      expect(find.text('C → D'), findsOneWidget);

      await _reveal(tester, find.widgetWithText(FilterChip, 'Unpaid'));
      await tester.tap(find.widgetWithText(FilterChip, 'Unpaid'));
      await tester.pumpAndSettle();
      expect(find.text('C → D'), findsOneWidget);
      expect(find.text('A → B'), findsNothing);

      await _reveal(tester, find.widgetWithText(FilterChip, 'All'));
      await tester.tap(find.widgetWithText(FilterChip, 'All'));
      await tester.pumpAndSettle();
      await _reveal(tester, find.text('All time'));
      await tester.tap(find.text('All time'));
      await tester.pumpAndSettle();
      await _tap(tester, 'This month');
      expect(find.text('C → D'), findsNothing, reason: 'February trip');
      expect(find.text('A → B'), findsOneWidget);

      await _reveal(tester, find.text('All vehicles'));
      await tester.tap(find.text('All vehicles'));
      await tester.pumpAndSettle();
      await _tap(tester, 'Truck 2');
      expect(find.text('E → F'), findsOneWidget);
      expect(find.text('A → B'), findsNothing);

      await _reveal(tester, find.widgetWithText(FilterChip, 'Paid'));
      await tester.tap(find.widgetWithText(FilterChip, 'Paid'));
      await tester.pumpAndSettle();
      expect(find.text('No trips match these filters.'), findsOneWidget);
    });
  });

  group('quick add', () {
    testWidgets(
      'a trip with a fare and one expense takes 6 taps (not counting digits)',
      (tester) async {
        await open(tester);
        var taps = 0;

        Future<void> tap(Finder f) async {
          taps++;
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        Future<void> digits(String d) async {
          for (final c in d.split('')) {
            await tester.tap(find.widgetWithText(FilledButton, c).first);
            await tester.pump();
          }
        }

        await tap(find.byType(FloatingActionButton)); // 1: Add trip
        await tap(find.text('Tap to enter').first); // 2: fare
        await digits('4500');
        await tap(find.widgetWithText(FilledButton, 'Done')); // 3
        await tap(
          find.widgetWithText(ActionChip, 'Fuel / CNG gas'),
        ); // 4: expense
        await digits('900');
        await tap(find.widgetWithText(FilledButton, 'Done')); // 5
        expect(find.text('৳ 3,600'), findsWidgets, reason: 'live profit');
        await tap(find.widgetWithText(FilledButton, 'Save')); // 6

        expect(taps, 6);
        final t = (await trips()).single;
        expect(t.vehicleId, vehicleId);
        expect(t.fareMinor, 450000);
        expect(t.receivedMinor, 450000, reason: 'paid by default');
        final e = (await expenses()).single;
        expect(e.amountMinor, 90000);
        expect(e.categoryId, _fuel);
        expect(e.paidBy, PaidBy.owner);
        expect(find.text('Trip saved'), findsOneWidget);
        expect(
          find.text('৳ 3,600'),
          findsOneWidget,
          reason: 'profit in the list',
        );
      },
    );

    testWidgets('the fare is required', (tester) async {
      await open(tester, location: '/trips/new');
      await _tap(tester, 'Save');
      expect(find.text('Enter the fare'), findsOneWidget);
      expect(await trips(), isEmpty);
    });

    testWidgets('live profit follows the fare, expenses and who paid', (
      tester,
    ) async {
      await open(tester, location: '/trips/new');
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '5000');
      await tester.tap(find.widgetWithText(ActionChip, 'Toll'));
      await tester.pumpAndSettle();
      await _keypad(tester, '200');
      expect(find.text('৳ 4,800'), findsWidgets);

      // The client paid the toll, so it does not cost the owner.
      await _tapRow(tester, 'Toll');
      await _tap(tester, 'Client');
      await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
      await tester.pumpAndSettle();
      expect(find.text('৳ 5,000'), findsWidgets);
    });

    testWidgets('a zero expense is ignored', (tester) async {
      await open(tester, location: '/trips/new');
      await tester.tap(find.widgetWithText(ActionChip, 'Parking'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Done'));
      await tester.pumpAndSettle();
      expect(find.text('No expenses added'), findsOneWidget);
    });

    testWidgets('More lets you pick any category', (tester) async {
      await open(tester, location: '/trips/new');
      await _tap(tester, 'More');
      await _tap(tester, 'Tyre');
      await _keypad(tester, '1200');
      expect(find.text('Tyre'), findsOneWidget);
      expect(find.text('৳ 1,200'), findsWidgets);
    });

    testWidgets('removing an expense takes it off the profit', (tester) async {
      await open(tester, location: '/trips/new');
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '1000');
      await tester.tap(find.widgetWithText(ActionChip, 'Fuel / CNG gas'));
      await tester.pumpAndSettle();
      await _keypad(tester, '300');
      expect(find.text('৳ 700'), findsWidgets);
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('No expenses added'), findsOneWidget);
      expect(find.text('৳ 1,000'), findsWidgets);
    });
  });

  group('payment', () {
    testWidgets('partly paid records what was received', (tester) async {
      await open(tester, location: '/trips/new');
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '2000');
      await _tap(tester, 'Partly paid');
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '500');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final t = (await trips()).single;
      expect(t.receivedMinor, 50000);
      expect(find.text('Due ৳ 1,500'), findsOneWidget);
    });

    testWidgets('received cannot exceed the fare', (tester) async {
      await open(tester, location: '/trips/new');
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '1000');
      await _tap(tester, 'Partly paid');
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '1500');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('Received cannot be more than the fare'),
        findsOneWidget,
      );
      expect(await trips(), isEmpty);
    });

    testWidgets('unpaid records nothing received', (tester) async {
      await open(tester, location: '/trips/new');
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '1000');
      await _tap(tester, 'Unpaid');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect((await trips()).single.receivedMinor, 0);
      expect(find.text('Due ৳ 1,000'), findsOneWidget);
    });
  });

  group('driver pay', () {
    late String karim;

    Future<void> withDriver(
      WidgetTester tester,
      PayModel model, {
      BusinessModel biz = BusinessModel.contract,
    }) async {
      await open(tester, location: '/more', model: biz);
      karim = await app.container
          .read(driverRepositoryProvider)
          .create(const DriverDraft(name: 'Karim'));
      await app.container
          .read(assignmentRepositoryProvider)
          .assign(
            vehicleId: vehicleId,
            driverId: karim,
            payModel: model,
            start: day(2026, 1, 1),
          );
      app.container.read(routerProvider).go('/trips/new');
      await tester.pumpAndSettle();
    }

    testWidgets('defaults to the assigned driver with their per-trip pay', (
      tester,
    ) async {
      await withDriver(tester, const PerTripPay(perTrip: Money.taka(250)));
      expect(find.text('Karim'), findsWidgets);
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '4500');
      expect(find.text('calculated'), findsOneWidget);
      expect(find.text('৳ 250'), findsWidgets);

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final t = (await trips()).single;
      expect(t.driverId, karim);
      expect(t.driverPayMinor, 25000);
      expect(t.driverPayOverridden, isFalse);
    });

    testWidgets('commission after expenses follows the expenses live', (
      tester,
    ) async {
      await withDriver(
        tester,
        const CommissionPay(
          rateBps: 2000,
          basis: CommissionBasis.afterExpenses,
        ),
      );
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '4500');
      expect(find.text('৳ 900'), findsWidgets);
      await tester.tap(find.widgetWithText(ActionChip, 'Fuel / CNG gas'));
      await tester.pumpAndSettle();
      await _keypad(tester, '1400');
      expect(find.text('৳ 620'), findsWidgets); // 20% of 3,100
    });

    testWidgets('the owner can override the pay, and reset it', (tester) async {
      await withDriver(tester, const PerTripPay(perTrip: Money.taka(250)));
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '1000');

      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();
      await _keypadFresh(tester, '400');
      expect(find.text('set by you'), findsOneWidget);
      expect(find.text('৳ 400'), findsWidgets);

      await tester.tap(find.byTooltip('Use calculated amount'));
      await tester.pumpAndSettle();
      expect(find.text('calculated'), findsOneWidget);

      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();
      await _keypadFresh(tester, '400');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final t = (await trips()).single;
      expect(t.driverPayMinor, 40000);
      expect(t.driverPayOverridden, isTrue);
    });

    testWidgets('a salaried driver earns nothing per trip', (tester) async {
      await withDriver(
        tester,
        const SalaryPay(monthly: Money.taka(15000)),
        biz: BusinessModel.salaried,
      );
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '1000');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect((await trips()).single.driverPayMinor, 0);
    });

    testWidgets('choosing no driver means no pay', (tester) async {
      await withDriver(tester, const PerTripPay(perTrip: Money.taka(250)));
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '1000');
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No driver').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final t = (await trips()).single;
      expect(t.driverId, isNull);
      expect(t.driverPayMinor, 0);
    });
  });

  group('expense editor', () {
    testWidgets('edits paid-by, reimbursement and fuel details', (
      tester,
    ) async {
      await open(tester, location: '/trips/new');
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '5000');
      await tester.tap(find.widgetWithText(ActionChip, 'Fuel / CNG gas'));
      await tester.pumpAndSettle();
      await _keypad(tester, '1000');

      await _tapRow(tester, 'Fuel / CNG gas');
      expect(find.text('Add expense'), findsOneWidget);
      await _tap(tester, 'Driver');
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Quantity (litres or m³) (Optional)'),
        '35.5',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Odometer (km) (Optional)'),
        '120,450',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Note (optional)').last,
        'Top-up',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final e = (await expenses()).single;
      expect(e.paidBy, PaidBy.driver);
      expect(e.reimbursable, isTrue);
      expect(e.qtyMilli, 35500);
      expect(e.odometerM, 120450000);
      expect(e.note, 'Top-up');
    });

    testWidgets('validates the amount and fuel quantity', (tester) async {
      await open(tester, location: '/trips/new');
      await tester.tap(find.widgetWithText(ActionChip, 'Fuel / CNG gas'));
      await tester.pumpAndSettle();
      await _keypad(tester, '100');
      await _tapRow(tester, 'Fuel / CNG gas');
      await tester.enterText(
        find.widgetWithText(TextField, 'Quantity (litres or m³) (Optional)'),
        '0',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid quantity'), findsOneWidget);
    });

    testWidgets('a new category can be created from the editor', (
      tester,
    ) async {
      await open(tester, location: '/trips/new');
      await tester.tap(find.widgetWithText(ActionChip, 'Toll'));
      await tester.pumpAndSettle();
      await _keypad(tester, '100');
      await _tapRow(tester, 'Toll');
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New category…').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Category name'),
        'Car wash',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
      await tester.pumpAndSettle();
      expect(find.text('Car wash'), findsOneWidget);
    });
  });

  group('route autocomplete', () {
    testWidgets('suggests places from earlier trips', (tester) async {
      await open(tester, location: '/more');
      await seedTrip(
        _trip(vehicle: vehicleId, from: 'Dhaka', to: 'Chattogram'),
      );
      await seedTrip(_trip(vehicle: vehicleId, from: 'Dhaka', to: 'Sylhet'));
      app.container.read(routerProvider).go('/trips/new');
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'From (Optional)'),
        'Dh',
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Dhaka'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Dhaka'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Dhaka'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'To (Optional)'),
        'S',
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Sylhet'), findsOneWidget);
    });
  });

  group('detail', () {
    late String tripId;

    Future<void> openDetail(
      WidgetTester tester, {
      int received = 1000,
      int fare = 4500,
    }) async {
      await open(tester, location: '/more');
      final karim = await app.container
          .read(driverRepositoryProvider)
          .create(const DriverDraft(name: 'Karim'));
      tripId = await seedTrip(
        _trip(
          vehicle: vehicleId,
          driver: karim,
          fare: fare,
          received: received,
          pay: 900,
          from: 'Dhaka',
          to: 'Savar',
          expenses: const [
            ExpenseDraft(categoryId: _fuel, amount: Money.taka(900)),
            ExpenseDraft(
              categoryId: 'default:toll',
              amount: Money.taka(500),
              paidBy: PaidBy.client,
              note: 'Bridge',
            ),
          ],
        ),
      );
      app.container.read(routerProvider).go('/trips/$tripId');
      await tester.pumpAndSettle();
    }

    testWidgets('shows the breakdown, expenses and payment state', (
      tester,
    ) async {
      await openDetail(tester);
      expect(find.text('Dhaka → Savar'), findsOneWidget);
      expect(find.text('৳ 4,500'), findsWidgets);
      expect(
        find.text('-৳ 900'),
        findsWidgets,
      ); // expenses (client toll excluded) and driver pay
      expect(find.text('৳ 2,700'), findsOneWidget); // 4500 - 900 - 900
      expect(find.text('Partly paid'), findsOneWidget);
      expect(find.textContaining('Due ৳ 3,500'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Client · Bridge'), 200);
      expect(find.text('Fuel / CNG gas'), findsOneWidget);
      expect(find.text('Client · Bridge'), findsOneWidget);
      expect(find.text('Karim'), findsOneWidget);
      expect(find.text('Pickup 1'), findsOneWidget);
    });

    testWidgets('records a partial payment, validating the amount', (
      tester,
    ) async {
      await openDetail(tester);
      await _tap(tester, 'Record payment');
      await tester.enterText(
        find.widgetWithText(TextField, 'Amount (৳)'),
        '9999',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter an amount up to ৳ 3,500'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Amount (৳)'),
        '1,000',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('Payment recorded'), findsOneWidget);
      expect((await trips()).single.receivedMinor, 200000);
      expect(find.textContaining('Due ৳ 2,500'), findsOneWidget);
    });

    testWidgets('mark fully paid settles the trip', (tester) async {
      await openDetail(tester);
      await _tap(tester, 'Record payment');
      await _tap(tester, 'Mark fully paid');
      expect((await trips()).single.receivedMinor, 450000);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Record payment'), findsNothing);
    });

    testWidgets('delete asks first and removes the trip', (tester) async {
      await openDetail(tester);
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await _tap(tester, 'Delete trip');
      expect(find.text('Delete this trip?'), findsOneWidget);
      await _tap(tester, 'Cancel');
      expect(find.text('Dhaka → Savar'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await _tap(tester, 'Delete trip');
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Trip deleted'), findsOneWidget);
      expect(find.text('No trips yet'), findsOneWidget);
      expect((await trips()).single.deletedAt, isNotNull);
    });

    testWidgets('repeat trip opens a pre-filled new trip', (tester) async {
      await openDetail(tester);
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await _tap(tester, 'Repeat trip');
      expect(find.text('New trip'), findsOneWidget);
      expect(find.text('৳ 4,500'), findsWidgets);
      expect(find.widgetWithText(TextField, 'Dhaka'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Savar'), findsOneWidget);
      expect(find.text('Fuel / CNG gas'), findsWidgets);

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final all = await trips();
      expect(all, hasLength(2));
      final copy = all.firstWhere((t) => t.id != tripId);
      expect(copy.fareMinor, 450000);
      expect(copy.receivedMinor, 450000, reason: 'a repeat starts as paid');
      expect(copy.returnOfTripId, isNull);
      expect(
        (await expenses()).where((e) => e.tripId == copy.id),
        hasLength(2),
      );
    });

    testWidgets('return leg swaps the route and links back', (tester) async {
      await openDetail(tester);
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await _tap(tester, 'Add return leg');
      expect(find.widgetWithText(TextField, 'Savar'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Dhaka'), findsOneWidget);
      expect(find.text('No expenses added'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final leg = (await trips()).firstWhere((t) => t.id != tripId);
      expect(leg.returnOfTripId, tripId);
      expect(leg.fromPlace, 'Savar');
      expect(leg.toPlace, 'Dhaka');

      app.container.read(routerProvider).go('/trips/${leg.id}');
      await tester.pumpAndSettle();
      expect(find.text('Return leg'), findsOneWidget);
    });

    testWidgets('unknown trip', (tester) async {
      await open(tester, location: '/trips/nope');
      expect(find.text('Trip not found'), findsOneWidget);
    });
  });

  group('edit', () {
    testWidgets('changes the fare and removes an expense', (tester) async {
      await open(tester, location: '/more');
      final id = await seedTrip(
        _trip(
          vehicle: vehicleId,
          expenses: const [
            ExpenseDraft(categoryId: _fuel, amount: Money.taka(300)),
          ],
        ),
      );
      app.container.read(routerProvider).go('/trips/$id/edit');
      await tester.pumpAndSettle();
      expect(find.text('Edit trip'), findsOneWidget);
      expect(find.text('৳ 1,000'), findsWidgets);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('৳ 1,000').first);
      await tester.pumpAndSettle();
      await _keypadFresh(tester, '1200');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      final t = (await trips()).single;
      expect(t.fareMinor, 120000);
      expect((await expenses()).where((e) => e.deletedAt == null), isEmpty);
    });

    testWidgets(
      'keeps the stored driver pay unless something that affects it changes',
      (tester) async {
        await open(tester, location: '/more');
        final karim = await app.container
            .read(driverRepositoryProvider)
            .create(const DriverDraft(name: 'Karim'));
        await app.container
            .read(assignmentRepositoryProvider)
            .assign(
              vehicleId: vehicleId,
              driverId: karim,
              payModel: const PerTripPay(
                perTrip: Money.taka(300),
              ), // terms changed since
              start: day(2026, 1, 1),
            );
        final id = await seedTrip(
          _trip(vehicle: vehicleId, driver: karim, pay: 250),
        );
        app.container.read(routerProvider).go('/trips/$id/edit');
        await tester.pumpAndSettle();

        expect(find.text('৳ 250'), findsWidgets);
        await tester.enterText(
          find.widgetWithText(TextField, 'Note (optional)'),
          'checked',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();
        expect((await trips()).single.driverPayMinor, 25000);

        app.container.read(routerProvider).go('/trips/$id/edit');
        await tester.pumpAndSettle();
        await tester.tap(find.text('৳ 1,000').first);
        await tester.pumpAndSettle();
        await _keypadFresh(tester, '1100');
        expect(
          find.text('৳ 300'),
          findsWidgets,
          reason: "recalculated at today's terms",
        );
      },
    );
  });

  group('receipts', () {
    testWidgets(
      'a receipt is stored with the expense and cleaned up when dropped',
      (tester) async {
        final dir = Directory.systemTemp.createTempSync('khata_receipts');
        addTearDown(() => dir.deleteSync(recursive: true));
        final src = File('${dir.path}/src.jpg')..writeAsBytesSync([1, 2, 3]);
        final storeDir = Directory('${dir.path}/store');
        final picker = FakePhotoPicker()..next = src.path;
        await open(
          tester,
          location: '/trips/new',
          picker: picker,
          store: PhotoStore(() async => storeDir),
        );

        await _tap(tester, 'Tap to enter');
        await _keypad(tester, '1000');
        await tester.tap(find.widgetWithText(ActionChip, 'Fuel / CNG gas'));
        await tester.pumpAndSettle();
        await _keypad(tester, '300');

        await _tapRow(tester, 'Fuel / CNG gas');
        await _tap(tester, 'Add receipt photo');
        await _tap(tester, 'Choose from gallery');
        await _settleIo(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await _settleIo(tester);

        final e = (await expenses()).single;
        expect(e.receiptFile, isNotNull);
        expect(File('${storeDir.path}/${e.receiptFile}').existsSync(), isTrue);
      },
    );

    testWidgets('a receipt picked in a trip that is never saved is deleted', (
      tester,
    ) async {
      final dir = Directory.systemTemp.createTempSync('khata_receipts2');
      addTearDown(() => dir.deleteSync(recursive: true));
      final src = File('${dir.path}/src.jpg')..writeAsBytesSync([1, 2, 3]);
      final storeDir = Directory('${dir.path}/store');
      await open(
        tester,
        location: '/trips/new',
        picker: FakePhotoPicker()..next = src.path,
        store: PhotoStore(() async => storeDir),
      );
      await tester.tap(find.widgetWithText(ActionChip, 'Fuel / CNG gas'));
      await tester.pumpAndSettle();
      await _keypad(tester, '300');
      await _tapRow(tester, 'Fuel / CNG gas');
      await _tap(tester, 'Add receipt photo');
      await _tap(tester, 'Choose from gallery');
      await _settleIo(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
      await tester.pumpAndSettle();
      expect(storeDir.listSync(), hasLength(1));

      // Leave the form without saving.
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      expect(storeDir.listSync(), isEmpty);
    });
  });

  testWidgets('trip screens fit at 200% text size', (tester) async {
    await open(tester, textScale: 2);
    final karim = await app.container
        .read(driverRepositoryProvider)
        .create(const DriverDraft(name: 'Abdul Karim Uddin'));
    final id = await seedTrip(
      _trip(
        vehicle: vehicleId,
        driver: karim,
        fare: 18000,
        received: 8000,
        pay: 1500,
        from: 'Dhaka Mirpur Section 10',
        to: 'Chattogram Agrabad Commercial Area',
        expenses: const [
          ExpenseDraft(categoryId: _fuel, amount: Money.taka(5500)),
          ExpenseDraft(
            categoryId: 'default:toll',
            amount: Money.taka(900),
            paidBy: PaidBy.driver,
            reimbursable: true,
          ),
        ],
      ),
    );
    final router = app.container.read(routerProvider);
    for (final route in [
      '/entries',
      '/trips/new',
      '/trips/$id',
      '/trips/$id/edit',
      '/vehicles/$vehicleId/expenses',
      '/more/categories',
    ]) {
      router.go(route);
      await tester.pumpAndSettle();
      final error = tester.takeException();
      expect(
        error,
        isNull,
        reason: '$route: ${error.toString().split('\n').first}',
      );
    }
    // Let Drift's stream cleanup timers fire inside the test.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
