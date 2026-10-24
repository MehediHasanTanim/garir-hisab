import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/pump_app.dart';

CalendarDay d(int y, int m, int day) => CalendarDay.of(y, m, day);

/// Opens a jama vehicle on 5 Apr 2026 (Sunday). Friday 3 Apr is an off-day,
/// so 1, 2, 4 and 5 April are due: ৳2,400 baki.
Future<(TestApp, String, String)> _open(
  WidgetTester tester, {
  String route = '/vehicles/:v/jama',
  double textScale = 1,
  Map<String, Object> prefs = const {},
}) async {
  final app = await pumpApp(
    tester,
    clock: () => DateTime(2026, 4, 5, 10),
    textScale: textScale,
    prefs: prefs,
  );
  final c = app.container;
  final v = await c
      .read(vehicleRepositoryProvider)
      .create(
        const VehicleDraft(
          nickname: 'Rahim CNG',
          type: VehicleType.cng,
          fuelType: FuelType.cng,
          businessModel: BusinessModel.jama,
        ),
      );
  final dr = await c
      .read(driverRepositoryProvider)
      .create(const DriverDraft(name: 'Karim'));
  final a = await c
      .read(assignmentRepositoryProvider)
      .assign(
        vehicleId: v,
        driverId: dr,
        payModel: const JamaPay(amount: Money.taka(600), offWeekdays: {5}),
        start: d(2026, 4, 1),
      );
  c.read(routerProvider).go(route.replaceAll(':v', v));
  await tester.pumpAndSettle();
  return (app, v, a);
}

void main() {
  testWidgets('shows the baki and collects the usual amount in one tap', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('Karim · ৳ 600 daily'), findsOneWidget);
    expect(find.text('৳ 2,400'), findsOneWidget);

    await tester.tap(find.text('Collect ৳ 600'));
    await tester.pumpAndSettle();
    expect(find.text('৳ 1,800', skipOffstage: false), findsOneWidget);
    expect(find.text('Collected ৳ 600'), findsOneWidget);

    // Undo from the snackbar puts it back.
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('৳ 2,400'), findsOneWidget);
  });

  testWidgets('calendar colours: paid, unpaid and the off-day', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Collect ৳ 600'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('1, Paid'), findsOneWidget);
    expect(find.bySemanticsLabel('2, Not paid'), findsOneWidget);
    expect(find.bySemanticsLabel('3, No jama'), findsOneWidget);
  });

  testWidgets('tapping an unpaid day offers to waive it', (tester) async {
    await _open(tester);
    await tester.ensureVisible(find.bySemanticsLabel('2, Not paid'));
    await tester.tap(find.bySemanticsLabel('2, Not paid'));
    await tester.pumpAndSettle();
    expect(find.text('Still owed: ৳ 600'), findsOneWidget);
    await tester.tap(find.text('Waive what is owed'));
    await tester.pumpAndSettle();
    expect(find.text('৳ 1,800', skipOffstage: false), findsOneWidget);
    expect(find.bySemanticsLabel('2, Waived'), findsOneWidget);
  });

  testWidgets('the vehicle can be put in the garage and brought back', (
    tester,
  ) async {
    await _open(tester);
    await tester.ensureVisible(find.text('Vehicle is in the garage'));
    await tester.tap(find.text('Vehicle is in the garage'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No jama while off the road'));
    await tester.pumpAndSettle();
    // From today (5 Apr): that day's unpaid jama is removed.
    expect(find.text('৳ 1,800', skipOffstage: false), findsOneWidget);
    await tester.ensureVisible(find.text('Back on the road'));
    expect(find.text('Since 05/04/2026'), findsOneWidget);
    expect(find.text('Back on the road'), findsOneWidget);
  });

  testWidgets('a vehicle without a jama driver explains what to do', (
    tester,
  ) async {
    final app = await pumpApp(tester, clock: () => DateTime(2026, 4, 5, 10));
    final v = await app.container
        .read(vehicleRepositoryProvider)
        .create(
          const VehicleDraft(
            nickname: 'Pickup',
            type: VehicleType.pickup,
            fuelType: FuelType.diesel,
            businessModel: BusinessModel.contract,
          ),
        );
    app.container.read(routerProvider).go('/vehicles/$v/jama');
    await tester.pumpAndSettle();
    expect(find.textContaining('No jama driver'), findsOneWidget);
  });

  testWidgets('report: rate and who is behind', (tester) async {
    final (app, _, a) = await _open(tester, route: '/more/jama-report');
    final c = app.container;
    await c.read(jamaRepositoryProvider).generate(d(2026, 4, 5));
    await c
        .read(jamaRepositoryProvider)
        .collect(
          assignmentId: a,
          amount: const Money.taka(1200),
          day: d(2026, 4, 5),
          today: d(2026, 4, 5),
        );
    c.read(routerProvider).go('/more');
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/more/jama-report');
    await tester.pumpAndSettle();
    expect(find.text('Collected 50% of what was due'), findsOneWidget);
    expect(find.text('Behind on jama'), findsOneWidget);
    expect(find.text('Karim'), findsOneWidget);
    expect(find.text('2 days missed, since 04/04/2026'), findsOneWidget);
  });

  testWidgets('fits at 200% text size', (tester) async {
    await _open(tester, textScale: 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bangla labels', (tester) async {
    await _open(tester, prefs: {'settings.language': 'bn'});
    expect(find.text('জমা'), findsWidgets);
    expect(find.text('বাকি'), findsWidgets);
  });
}
