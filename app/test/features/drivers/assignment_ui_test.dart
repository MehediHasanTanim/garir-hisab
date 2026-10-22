import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

DateTime _clock() => DateTime(2026, 3, 15, 10);

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

VehicleDraft _vehicle(String name, BusinessModel model) => VehicleDraft(
  nickname: name,
  type: VehicleType.cng,
  fuelType: FuelType.cng,
  businessModel: model,
);

Future<void> _chooseDriver(WidgetTester tester, String name) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String label, String text) =>
    tester.enterText(find.widgetWithText(TextField, label), text);

/// Reads a Drift stream's first value from a widget test. Streams need real
/// timers, which the test's fake-async zone does not run, so escape it.
Future<T> _first<T>(WidgetTester tester, Stream<T> stream) async {
  late T value;
  await tester.runAsync(() async => value = await stream.first);
  return value;
}

void main() {
  late TestApp app;
  late String vehicleId;
  late String karim;
  late String rahim;

  Future<void> open(
    WidgetTester tester,
    String location, {
    BusinessModel model = BusinessModel.salaried,
  }) async {
    app = await pumpApp(tester, location: '/more', clock: _clock);
    final c = app.container;
    vehicleId = await c
        .read(vehicleRepositoryProvider)
        .create(_vehicle('Pickup 1', model));
    karim = await c
        .read(driverRepositoryProvider)
        .create(const DriverDraft(name: 'Karim'));
    rahim = await c
        .read(driverRepositoryProvider)
        .create(const DriverDraft(name: 'Rahim'));
    c.read(routerProvider).go(location.replaceAll(':v', vehicleId));
    await tester.pumpAndSettle();
  }

  testWidgets('a vehicle without a driver offers to assign one', (
    tester,
  ) async {
    await open(tester, '/vehicles/:v/driver');
    expect(find.text('No driver assigned'), findsOneWidget);
    await _tap(tester, 'Assign driver');
    expect(find.text('Assign driver'), findsWidgets);
    expect(find.text('How is the driver paid?'), findsOneWidget);
  });

  testWidgets('assigns a salaried driver and shows the pay terms', (
    tester,
  ) async {
    await open(tester, '/vehicles/:v/assign');
    await _chooseDriver(tester, 'Karim');
    await _type(tester, 'Monthly salary (৳)', '15000');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final active = await _first(
      tester,
      app.container
          .read(assignmentRepositoryProvider)
          .watchActiveForVehicle(vehicleId),
    );
    expect(active!.driverName, 'Karim');
    expect(
      active.assignment.payModel,
      const SalaryPay(monthly: Money.taka(15000)),
    );
    expect(active.assignment.start, day(2026, 3, 15));

    expect(find.text('Driver assigned'), findsOneWidget);
    expect(find.text('Karim'), findsOneWidget);
    expect(find.textContaining('৳ 15,000 per month'), findsOneWidget);
    expect(find.textContaining('Since 15/03/2026'), findsOneWidget);
  });

  testWidgets('requires a driver and a valid pay amount', (tester) async {
    await open(tester, '/vehicles/:v/assign');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    expect(find.text('Choose a driver'), findsOneWidget);
    expect(await app.db.select(app.db.assignments).get(), isEmpty);

    await _type(tester, 'Monthly salary (৳)', 'abc');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
  });

  testWidgets('switching drivers keeps the previous one in history', (
    tester,
  ) async {
    await open(tester, '/vehicles/:v/driver');
    final repo = app.container.read(assignmentRepositoryProvider);
    await repo.assign(
      vehicleId: vehicleId,
      driverId: karim,
      payModel: salary15000,
      start: day(2026, 1, 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('Current driver'), findsOneWidget);

    await _tap(tester, 'Change driver or pay');
    expect(
      find.textContaining('Karim will stop on 14/03/2026.'),
      findsOneWidget,
    );
    await _chooseDriver(tester, 'Rahim');
    // The editor starts from the current terms.
    expect(find.widgetWithText(TextField, '15000'), findsOneWidget);
    await _type(tester, 'Monthly salary (৳)', '18000');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Rahim'), findsOneWidget);
    expect(find.textContaining('৳ 18,000 per month'), findsOneWidget);
    expect(find.text('Past drivers'), findsOneWidget);
    expect(find.text('Karim'), findsOneWidget);
    expect(find.textContaining('01/01/2026 – 14/03/2026'), findsOneWidget);
    expect(find.textContaining('৳ 15,000 per month'), findsOneWidget);
    // rahim is only used for the id check below.
    expect(rahim, isNotEmpty);
  });

  testWidgets('shows a friendly message when the new start date is too early', (
    tester,
  ) async {
    await open(tester, '/vehicles/:v/driver');
    await app.container
        .read(assignmentRepositoryProvider)
        .assign(
          vehicleId: vehicleId,
          driverId: karim,
          payModel: salary15000,
          start: day(2026, 3, 20), // after "today" (15 Mar)
        );
    await tester.pumpAndSettle();
    await _tap(tester, 'Change driver or pay');
    await _chooseDriver(tester, 'Rahim');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'The new start date must be after the current assignment began.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('ending an assignment asks first, then frees the vehicle', (
    tester,
  ) async {
    await open(tester, '/vehicles/:v/driver');
    await app.container
        .read(assignmentRepositoryProvider)
        .assign(
          vehicleId: vehicleId,
          driverId: karim,
          payModel: salary15000,
          start: day(2026, 1, 1),
        );
    await tester.pumpAndSettle();

    await _tap(tester, 'End assignment');
    expect(find.text('End this assignment?'), findsOneWidget);
    expect(
      find.text('Karim will no longer drive Pickup 1 after today.'),
      findsOneWidget,
    );
    await _tap(tester, 'Cancel');
    expect(find.text('Current driver'), findsOneWidget);

    await _tap(tester, 'End assignment');
    await tester.tap(find.widgetWithText(FilledButton, 'End assignment'));
    await tester.pumpAndSettle();
    expect(find.text('Assignment ended'), findsOneWidget);
    expect(find.text('No driver assigned'), findsOneWidget);
    final history = await _first(
      tester,
      app.container
          .read(assignmentRepositoryProvider)
          .watchForVehicle(vehicleId),
    );
    expect(history.single.assignment.end, day(2026, 3, 15));
  });

  testWidgets('self-driven vehicles explain there is no driver', (
    tester,
  ) async {
    await open(tester, '/vehicles/:v/driver', model: BusinessModel.self);
    expect(
      find.text(
        "Self-driven vehicles don't have a driver. Change the vehicle's business model to assign one.",
      ),
      findsOneWidget,
    );
    expect(find.text('Assign driver'), findsNothing);

    app.container.read(routerProvider).go('/vehicles/$vehicleId/assign');
    await tester.pumpAndSettle();
    expect(find.text('How is the driver paid?'), findsNothing);
  });

  testWidgets('with no active drivers it asks to add one first', (
    tester,
  ) async {
    await open(tester, '/vehicles/:v/assign');
    await app.container
        .read(driverRepositoryProvider)
        .setStatus(karim, DriverStatus.left);
    await app.container
        .read(driverRepositoryProvider)
        .setStatus(rahim, DriverStatus.left);
    await tester.pumpAndSettle();
    expect(find.text('Add a driver first.'), findsOneWidget);
  });

  group('pay model editor', () {
    testWidgets('only offers pay types that suit the vehicle', (tester) async {
      await open(
        tester,
        '/vehicles/:v/assign',
        model: BusinessModel.commission,
      );
      expect(find.widgetWithText(ChoiceChip, 'Commission'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Per trip'), findsOneWidget);
      expect(
        find.widgetWithText(ChoiceChip, 'Salary + commission'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ChoiceChip, 'Monthly salary'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'Jama (rent)'), findsNothing);
    });

    testWidgets(
      'commission: percentage is validated and saved in basis points',
      (tester) async {
        await open(
          tester,
          '/vehicles/:v/assign',
          model: BusinessModel.commission,
        );
        await _chooseDriver(tester, 'Karim');
        await _type(tester, 'Commission (% of fare)', '101');
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();
        expect(
          find.text('Enter a percentage between 0 and 100'),
          findsOneWidget,
        );

        await _type(tester, 'Commission (% of fare)', '12.5');
        await _tap(tester, 'Fare before expenses');
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        final active = await _first(
          tester,
          app.container
              .read(assignmentRepositoryProvider)
              .watchActiveForVehicle(vehicleId),
        );
        expect(
          active!.assignment.payModel,
          const CommissionPay(
            rateBps: 1250,
            basis: CommissionBasis.beforeExpenses,
          ),
        );
        expect(
          find.textContaining('12.5% of fare before expenses'),
          findsOneWidget,
        );
      },
    );

    testWidgets('daily wage has a half-day rate', (tester) async {
      await open(tester, '/vehicles/:v/assign', model: BusinessModel.dailyWage);
      await _chooseDriver(tester, 'Karim');
      await _type(tester, 'Pay per day (৳)', '800');
      await _type(tester, 'Half-day pay (% of a full day)', '40');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final active = await _first(
        tester,
        app.container
            .read(assignmentRepositoryProvider)
            .watchActiveForVehicle(vehicleId),
      );
      expect(
        active!.assignment.payModel,
        const DailyWagePay(perDay: Money.taka(800), halfDayBps: 4000),
      );
    });

    testWidgets('mixed pay captures a base salary and a commission', (
      tester,
    ) async {
      await open(tester, '/vehicles/:v/assign');
      await _chooseDriver(tester, 'Karim');
      await _tap(tester, 'Salary + commission');
      await _type(tester, 'Base salary per month (৳)', '8,000');
      await _type(tester, 'Commission (% of fare)', '5');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('৳ 8,000 per month + 5% commission'),
        findsOneWidget,
      );
    });

    testWidgets('jama: weekly rent with off days; all days off is rejected', (
      tester,
    ) async {
      await open(tester, '/vehicles/:v/assign', model: BusinessModel.jama);
      await _chooseDriver(tester, 'Karim');
      await _type(tester, 'Jama amount (৳)', '600');
      await _tap(tester, 'Weekly');
      await _tap(tester, 'Fri');

      // Every day off is invalid.
      for (final d in ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu']) {
        await _tap(tester, d);
      }
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('Leave at least one day when jama is collected'),
        findsOneWidget,
      );

      await _tap(tester, 'Thu'); // un-pick one
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final active = await _first(
        tester,
        app.container
            .read(assignmentRepositoryProvider)
            .watchActiveForVehicle(vehicleId),
      );
      final jama = active!.assignment.payModel as JamaPay;
      expect(jama.frequency, JamaFrequency.weekly);
      expect(jama.amount, const Money.taka(600));
      expect(jama.offWeekdays, {6, 7, 1, 2, 3, 5});
    });

    testWidgets('the home vehicle menu opens Driver & pay', (tester) async {
      await open(tester, '/home');
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await _tap(tester, 'Driver & pay');
      expect(find.text('No driver assigned'), findsOneWidget);
    });
  });

  testWidgets('assignment screens fit at 200% text size', (tester) async {
    await open(tester, '/more');
    await tester.pumpWidget(const SizedBox());
    final seeded = await pumpApp(tester, clock: _clock, textScale: 2);
    final c = seeded.container;
    final v = await c
        .read(vehicleRepositoryProvider)
        .create(
          _vehicle('A long vehicle nickname here', BusinessModel.commission),
        );
    await c
        .read(driverRepositoryProvider)
        .create(const DriverDraft(name: 'Abdul Karim Uddin Ahmed'));
    for (final route in ['/vehicles/$v/driver', '/vehicles/$v/assign']) {
      c.read(routerProvider).go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }
  });
}
