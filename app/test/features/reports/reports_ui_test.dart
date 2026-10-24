import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/flavor.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

// Sunday 15 March 2026. The week (Saturday first) began on 14 March.
DateTime _clock() => DateTime(2026, 3, 15, 10);
DateTime _at(int d) => DateTime(2026, 3, d, 9).toUtc();

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  late TestApp app;
  late String vehicleId;

  Future<void> open(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    double textScale = 1,
  }) async {
    app = await pumpApp(
      tester,
      location: '/reports',
      clock: _clock,
      prefs: prefs,
      textScale: textScale,
    );
    vehicleId = await app.container
        .read(vehicleRepositoryProvider)
        .create(vehicleFor(BusinessModel.self, name: 'Rahim CNG'));
    await app.container.read(categoryRepositoryProvider).ensureDefaults();
    await tester.pumpAndSettle();
  }

  Future<void> income(int taka, int d) => app.container
      .read(dayLogRepositoryProvider)
      .addIncome(
        vehicleId: vehicleId,
        day: day(2026, 3, d),
        amount: Money.taka(taka),
      );

  Future<void> expense(
    String cat,
    int taka,
    int d, {
    PaidBy by = PaidBy.owner,
  }) => app.container
      .read(expenseRepositoryProvider)
      .create(
        vehicleId,
        ExpenseDraft(
          categoryId: 'default:$cat',
          amount: Money.taka(taka),
          spentAt: _at(d),
          paidBy: by,
        ),
      );

  testWidgets('with nothing recorded it says so', (tester) async {
    await open(tester);
    expect(find.text('No reports yet'), findsOneWidget);
    expect(find.text('Nothing recorded for this period yet.'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('the month summary adds up', (tester) async {
    await open(tester);
    await income(2800, 5);
    await income(2000, 9);
    await expense('fuel', 600, 5);
    await expense('fuel', 400, 9);
    await expense('repair', 500, 12);
    await tester.pumpAndSettle();

    expect(find.text('Profit summary'), findsOneWidget);
    expect(find.text('৳ 4,800'), findsWidgets); // income
    expect(find.text('-৳ 1,000'), findsOneWidget); // running costs
    expect(find.text('৳ 3,800'), findsOneWidget); // operating profit
    expect(find.text('-৳ 500'), findsOneWidget); // vehicle costs
    expect(find.text('৳ 3,300'), findsWidgets); // net profit
    expect(find.text('Per working day: ৳ 1,650'), findsOneWidget);
  });

  testWidgets('shows the charts, the expense mix and the vehicle ranking', (
    tester,
  ) async {
    await open(tester);
    await income(2800, 5);
    await expense('fuel', 600, 5);
    await expense('repair', 300, 6);
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(PieChart), 300);
    expect(find.byType(PieChart), findsOneWidget);
    // The legend states the exact figures.
    expect(find.text('Fuel / CNG gas'), findsOneWidget);
    expect(find.text('৳ 600 · 66%'), findsOneWidget);
    expect(find.text('৳ 300 · 33%'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Rahim CNG'), 300);
    expect(find.text('Rahim CNG'), findsOneWidget);
    expect(find.text('Income: ৳ 2,800'), findsOneWidget);
  });

  testWidgets('client-paid expenses are not in the mix', (tester) async {
    await open(tester);
    await income(1000, 5);
    await expense('toll', 999, 5, by: PaidBy.client);
    await expense('fuel', 100, 5);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(PieChart), 300);
    expect(find.text('Toll'), findsNothing);
    expect(find.text('Fuel / CNG gas'), findsOneWidget);
  });

  testWidgets('today and this week narrow the period', (tester) async {
    await open(tester);
    await income(1000, 2); // earlier this month
    await income(300, 14); // this week (Saturday)
    await income(200, 15); // today
    await tester.pumpAndSettle();
    expect(find.text('৳ 1,500'), findsWidgets);

    await _tap(tester, 'This week');
    expect(find.text('৳ 500'), findsWidgets);
    expect(find.text('৳ 1,500'), findsNothing);

    await _tap(tester, 'Today');
    expect(find.text('৳ 200'), findsWidgets);
    expect(
      find.byType(LineChart),
      findsNothing,
      reason: 'one day has no trend',
    );
  });

  testWidgets('accrual counts fares that have not been received yet', (
    tester,
  ) async {
    await open(tester);
    await app.container
        .read(tripRepositoryProvider)
        .create(
          TripDraft(
            vehicleId: vehicleId,
            startedAt: _at(5),
            fare: const Money.taka(1000),
            received: const Money.taka(250),
            driverPay: Money.zero,
          ),
        );
    await tester.pumpAndSettle();
    expect(find.text('৳ 250'), findsWidgets);
    expect(find.text('Not yet received: ৳ 750'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await open(tester, prefs: {'settings.profitView': 'accrual'});
    await app.container
        .read(tripRepositoryProvider)
        .create(
          TripDraft(
            vehicleId: vehicleId,
            startedAt: _at(5),
            fare: const Money.taka(1000),
            received: const Money.taka(250),
            driverPay: Money.zero,
          ),
        );
    await tester.pumpAndSettle();
    expect(find.text('৳ 1,000'), findsWidgets);
  });

  testWidgets('vehicle costs can be spread over the month from Settings', (
    tester,
  ) async {
    await open(tester);
    await income(10000, 1);
    await expense('insurance', 3100, 20);
    await tester.pumpAndSettle();
    await _tap(tester, 'Today');
    expect(find.text('৳ 0'), findsWidgets);

    app.container.read(settingsProvider.notifier);
    await app.container
        .read(settingsProvider.notifier)
        .setAmortizeFixed(value: true);
    await tester.pumpAndSettle();
    expect(
      find.text('-৳ 100'),
      findsWidgets,
      reason: '1/31 of 3,100 lands on any day',
    );
  });

  testWidgets('Settings has the spread switch', (tester) async {
    app = await pumpApp(tester, location: '/more/settings', clock: _clock);
    final tile = find.widgetWithText(
      SwitchListTile,
      'Spread vehicle costs over the month',
    );
    await tester.scrollUntilVisible(tile, 200);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(app.container.read(settingsProvider).amortizeFixed, isTrue);
  });

  testWidgets('the demo-data tile exists only outside production', (
    tester,
  ) async {
    app = await pumpApp(tester, location: '/more', clock: _clock);
    expect(find.text('Generate demo data'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    app = await pumpApp(
      tester,
      location: '/more',
      clock: _clock,
      overrides: [flavorProvider.overrideWithValue(Flavor.dev)],
    );
    expect(find.text('Generate demo data'), findsOneWidget);
  });

  testWidgets('reports fit at 200% text size', (tester) async {
    await open(tester, textScale: 2);
    await income(2800, 5);
    await expense('fuel', 600, 5);
    await expense('repair', 300, 6);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Rahim CNG'), 400);
    expect(tester.takeException(), isNull);
  });
}
