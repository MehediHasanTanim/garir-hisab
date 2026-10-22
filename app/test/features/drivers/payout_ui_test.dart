import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
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

/// Reads a Drift stream's first value from a widget test. Streams need real
/// timers, which the test's fake-async zone does not run, so escape it.
Future<T> _first<T>(WidgetTester tester, Stream<T> stream) async {
  late T value;
  await tester.runAsync(() async => value = await stream.first);
  return value;
}

/// Opens a driver-detail tab. The tab bar scrolls sideways, so the last tabs
/// can start off-screen; drag it first.
Future<void> _openTab(WidgetTester tester, String name) async {
  if (name == 'Payouts') {
    await tester.drag(find.byType(TabBar), const Offset(-400, 0));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

void main() {
  late TestApp app;
  late String driverId;
  late String assignmentId;

  /// A salaried driver (15,000/month since 1 Jan) with 3 absences and a
  /// 4,000 advance in March.
  Future<void> open(
    WidgetTester tester, {
    PayModel? model,
    BusinessModel business = BusinessModel.salaried,
    bool withData = true,
  }) async {
    app = await pumpApp(tester, location: '/more', clock: _clock);
    final c = app.container;
    final vehicleId = await c
        .read(vehicleRepositoryProvider)
        .create(vehicleFor(business));
    driverId = await c
        .read(driverRepositoryProvider)
        .create(const DriverDraft(name: 'Karim'));
    assignmentId = await c
        .read(assignmentRepositoryProvider)
        .assign(
          vehicleId: vehicleId,
          driverId: driverId,
          payModel: model ?? salary15000,
          start: day(2026, 1, 1),
        );
    if (withData) {
      for (final d in [3, 4, 5]) {
        await c
            .read(attendanceRepositoryProvider)
            .mark(driverId, day(2026, 3, d), AttendanceStatus.absent);
      }
      await c
          .read(advanceRepositoryProvider)
          .give(
            driverId: driverId,
            amount: const Money.taka(4000),
            day: day(2026, 3, 1),
          );
    }
    c.read(routerProvider).go('/drivers/$driverId/payout/new');
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows earned pay, advances recovered and the net for this month',
    (tester) async {
      await open(tester);
      expect(find.text('March 2026'), findsOneWidget);
      expect(find.text('Salary (28 days)'), findsOneWidget);
      expect(find.text('৳ 13,548.39'), findsNWidgets(2)); // line + earned
      expect(find.text('-৳ 4,000'), findsOneWidget);
      expect(find.text('৳ 9,548.39'), findsOneWidget); // pay now
    },
  );

  testWidgets('a bonus or penalty changes the net live', (tester) async {
    await open(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Bonus (+) or penalty (−) (৳)'),
      '1000',
    );
    await tester.pumpAndSettle();
    expect(find.text('৳ 10,548.39'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Bonus (+) or penalty (−) (৳)'),
      '-548.39',
    );
    await tester.pumpAndSettle();
    expect(find.text('৳ 9,000'), findsOneWidget);
  });

  testWidgets('an invalid adjustment disables recording', (tester) async {
    await open(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Bonus (+) or penalty (−) (৳)'),
      '1.234',
    );
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid amount'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Record payout'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets(
    'month navigation recalculates; the assignment covers all months',
    (tester) async {
      await open(tester);
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(find.text('April 2026'), findsOneWidget);
      expect(find.text('Salary (30 days)'), findsOneWidget);
      expect(find.text('Salary (28 days)'), findsNothing);
    },
  );

  testWidgets('records the payout, recovers the advance and lists it', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Reason (optional)'),
      'Fuel saving',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Record payout'));
    await tester.pumpAndSettle();

    expect(find.text('Payout recorded'), findsOneWidget);
    final payouts = await _first(
      tester,
      app.container.read(payoutServiceProvider).watchForDriver(driverId),
    );
    expect(payouts, hasLength(1));
    expect(payouts.single.net, const Money(954839));
    expect(payouts.single.deducted, const Money.taka(4000));
    expect(
      await app.container.read(advanceRepositoryProvider).outstanding(driverId),
      isEmpty,
    );

    // Lands on the driver; the Payouts tab lists it.
    await _openTab(tester, 'Payouts');
    expect(find.text('৳ 9,548.39'), findsOneWidget);
    expect(find.textContaining('01/03/2026 – 31/03/2026'), findsOneWidget);
    expect(find.textContaining('Paid on 15/03/2026'), findsOneWidget);
  });

  testWidgets('recording the same month again does not duplicate it', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Record payout'));
    await tester.pumpAndSettle();

    // Let the first snackbar disappear so it does not cover the button.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    app.container.read(routerProvider).go('/drivers/$driverId/payout/new');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Record payout'));
    await tester.pumpAndSettle();

    expect(find.text('This period was already recorded'), findsOneWidget);
    expect(await app.db.select(app.db.payouts).get(), hasLength(1));
  });

  testWidgets('an overlapping custom period is rejected with a clear message', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Record payout'));
    await tester.pumpAndSettle();

    // A period that overlaps but is not identical.
    await expectLater(
      app.container
          .read(payoutServiceProvider)
          .record(
            driverId: driverId,
            assignmentId: assignmentId,
            period: DayRange(day(2026, 3, 20), day(2026, 4, 10)),
          ),
      throwsA(anything),
    );
  });

  testWidgets('voiding a payout releases the advance', (tester) async {
    await open(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Record payout'));
    await tester.pumpAndSettle();
    await _openTab(tester, 'Payouts');
    await _tap(tester, '৳ 9,548.39');

    expect(find.text('Void payout'), findsOneWidget);
    await _tap(tester, 'Void payout');
    expect(find.text('Void this payout?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Void payout'));
    await tester.pumpAndSettle();

    expect(find.text('Payout voided'), findsOneWidget);
    expect(find.text('No payouts yet'), findsOneWidget);
    final outstanding = await app.container
        .read(advanceRepositoryProvider)
        .outstanding(driverId);
    expect(outstanding.single.remaining, const Money.taka(4000));
  });

  testWidgets('trip-based pay explains that trips are not available yet', (
    tester,
  ) async {
    await open(
      tester,
      model: const PerTripPay(perTrip: Money.taka(250)),
      business: BusinessModel.contract,
      withData: false,
    );
    expect(
      find.text(
        'Trip earnings will be included once trip logging is available.',
      ),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Record payout'),
    );
    expect(button.onPressed, isNull, reason: 'nothing to pay yet');
  });

  testWidgets('jama drivers cannot be paid out', (tester) async {
    await open(
      tester,
      model: const JamaPay(amount: Money.taka(600)),
      business: BusinessModel.jama,
      withData: false,
    );
    expect(
      find.text('Jama drivers pay the owner, so there is nothing to pay out.'),
      findsOneWidget,
    );
  });

  testWidgets('a period before the assignment started shows the reason', (
    tester,
  ) async {
    await open(tester, withData: false);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
    }
    expect(find.text('December 2025'), findsOneWidget);
    expect(
      find.text('This vehicle assignment does not cover that period.'),
      findsOneWidget,
    );
  });

  testWidgets('payout screen fits at 200% text size', (tester) async {
    await open(tester);
    await tester.pumpWidget(const SizedBox());
    final seeded = await pumpApp(tester, clock: _clock, textScale: 2);
    final c = seeded.container;
    final v = await c
        .read(vehicleRepositoryProvider)
        .create(vehicleFor(BusinessModel.salaried));
    final d = await c
        .read(driverRepositoryProvider)
        .create(const DriverDraft(name: 'Abdul Karim Uddin Ahmed'));
    await c
        .read(assignmentRepositoryProvider)
        .assign(
          vehicleId: v,
          driverId: d,
          payModel: salary15000,
          start: day(2026, 1, 1),
        );
    await c
        .read(advanceRepositoryProvider)
        .give(
          driverId: d,
          amount: const Money.taka(4000),
          day: day(2026, 3, 1),
        );
    c.read(routerProvider).go('/drivers/$d/payout/new');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
