import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

/// Fixed "today" so dates and months are deterministic.
DateTime _clock() => DateTime(2026, 3, 15, 10);

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<TestApp> _open(
  WidgetTester tester, {
  String location = '/drivers',
  double textScale = 1,
}) => pumpApp(tester, location: location, clock: _clock, textScale: textScale);

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
  group('list and form', () {
    testWidgets('empty state offers to add a driver', (tester) async {
      await _open(tester);
      expect(find.text('No drivers yet'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Add driver'));
      await tester.pumpAndSettle();
      expect(find.text('New driver'), findsOneWidget);
    });

    testWidgets('validates the form, then saves and lists the driver', (
      tester,
    ) async {
      final app = await _open(tester, location: '/drivers/new');

      await _tap(tester, 'Save');
      expect(find.text("Enter the driver's name"), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Abdul Karim',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mobile number (Optional)'),
        '12345',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'National ID (NID) (Optional)'),
        '12345',
      );
      await _tap(tester, 'Save');
      expect(
        find.text('Enter a valid mobile number, e.g. 01712345678'),
        findsOneWidget,
      );
      expect(find.text('NID must be 10, 13 or 17 digits'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mobile number (Optional)'),
        '01712345678',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'National ID (NID) (Optional)'),
        '1990123456789',
      );
      await _tap(tester, 'Save');

      expect(find.text('Abdul Karim'), findsOneWidget);
      expect(find.text('+8801712345678'), findsOneWidget);
      final row = (await app.db.select(app.db.drivers).get()).single;
      expect(row.nidEncrypted, startsWith('v1:'));
      expect(row.nidEncrypted, isNot(contains('1990123456789')));
    });

    testWidgets('search and the Left filter', (tester) async {
      final app = await _open(tester);
      final repo = app.container.read(driverRepositoryProvider);
      await repo.create(
        const DriverDraft(name: 'Abdul Karim', phone: '01712345678'),
      );
      await repo.create(const DriverDraft(name: 'Rahim'));
      final left = await repo.create(const DriverDraft(name: 'Salam'));
      await repo.setStatus(left, DriverStatus.left);
      await tester.pumpAndSettle();

      expect(find.text('Abdul Karim'), findsOneWidget);
      expect(find.text('Rahim'), findsOneWidget);
      expect(find.text('Salam'), findsNothing);

      await tester.enterText(find.byType(SearchBar), '1712345');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Abdul Karim'), findsOneWidget);
      expect(find.text('Rahim'), findsNothing);

      await tester.enterText(find.byType(SearchBar), 'zzz');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('No drivers match your search.'), findsOneWidget);

      await tester.enterText(find.byType(SearchBar), '');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.widgetWithText(FilterChip, 'Left'));
      await tester.pumpAndSettle();
      expect(find.text('Salam'), findsOneWidget);
      expect(find.text('Rahim'), findsNothing);
    });

    testWidgets('an expired licence is flagged in the list', (tester) async {
      final app = await _open(tester);
      await app.container
          .read(driverRepositoryProvider)
          .create(
            DriverDraft(name: 'Old Licence', licenseExpiry: day(2026, 1, 1)),
          );
      await tester.pumpAndSettle();
      expect(find.text('Licence expired'), findsOneWidget);
    });

    testWidgets('editing keeps the saved NID and updates the name', (
      tester,
    ) async {
      final app = await _open(tester);
      final repo = app.container.read(driverRepositoryProvider);
      final id = await repo.create(
        const DriverDraft(name: 'Karim', nid: '1990123456789'),
      );
      app.container.read(routerProvider).go('/drivers/$id/edit');
      await tester.pumpAndSettle();

      expect(find.text('Edit driver'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, '1990123456789'),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Karim'),
        'Karim Uddin',
      );
      await _tap(tester, 'Save');

      final d = (await repo.get(id))!;
      expect(d.name, 'Karim Uddin');
      expect(d.nid, '1990123456789');
    });

    testWidgets('editing an unknown driver shows not found', (tester) async {
      await _open(tester, location: '/drivers/nope/edit');
      expect(find.text('Driver not found'), findsOneWidget);
    });
  });

  group('detail', () {
    testWidgets('overview shows contact details and licence status', (
      tester,
    ) async {
      final app = await _open(tester);
      final id = await app.container
          .read(driverRepositoryProvider)
          .create(
            DriverDraft(
              name: 'Abdul Karim',
              phone: '01712345678',
              licenseNo: 'DL-1',
              licenseExpiry: day(2027, 1, 5),
              nid: '1990123456789',
              address: 'Mirpur',
              joinDate: day(2025, 1, 10),
            ),
          );
      app.container.read(routerProvider).go('/drivers/$id');
      await tester.pumpAndSettle();

      expect(find.text('Abdul Karim'), findsWidgets);
      expect(find.text('+8801712345678'), findsOneWidget);
      expect(find.text('DL-1 · Valid until 05/01/2027'), findsOneWidget);
      expect(find.text('NID on file'), findsOneWidget);
      expect(
        find.text('1990123456789'),
        findsNothing,
        reason: 'NID is never shown',
      );
      expect(find.text('Mirpur'), findsOneWidget);
      expect(find.text('10/01/2025'), findsOneWidget);
      expect(find.text('Not assigned to a vehicle'), findsOneWidget);
    });

    testWidgets('mark as left ends assignments; reactivate restores', (
      tester,
    ) async {
      final app = await _open(tester);
      final f = app.container;
      final driverId = await f
          .read(driverRepositoryProvider)
          .create(const DriverDraft(name: 'Karim'));
      final vehicleId = await f
          .read(vehicleRepositoryProvider)
          .create(salariedVehicle());
      await f
          .read(assignmentRepositoryProvider)
          .assign(
            vehicleId: vehicleId,
            driverId: driverId,
            payModel: salary15000,
            start: day(2026, 1, 1),
          );
      f.read(routerProvider).go('/drivers/$driverId');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await _tap(tester, 'Mark as left');
      expect(find.text('Mark Karim as left?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Mark as left'));
      await tester.pumpAndSettle();

      expect(find.text('Marked as left'), findsOneWidget);
      expect(
        await f.read(assignmentRepositoryProvider).activeForDriver(driverId),
        isEmpty,
      );
      expect(
        (await f.read(driverRepositoryProvider).get(driverId))!.status,
        DriverStatus.left,
      );

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await _tap(tester, 'Mark as working again');
      expect(
        (await f.read(driverRepositoryProvider).get(driverId))!.status,
        DriverStatus.active,
      );
    });
  });

  group('attendance', () {
    Future<(TestApp, String)> openAttendance(WidgetTester tester) async {
      final app = await _open(tester);
      final id = await app.container
          .read(driverRepositoryProvider)
          .create(const DriverDraft(name: 'Karim'));
      app.container.read(routerProvider).go('/drivers/$id');
      await tester.pumpAndSettle();
      await _openTab(tester, 'Attendance');
      return (app, id);
    }

    testWidgets('shows the current month with every day unmarked', (
      tester,
    ) async {
      await openAttendance(tester);
      expect(find.text('March 2026'), findsOneWidget);
      expect(find.text('Not marked: 31'), findsOneWidget);
      expect(find.text('Present: 0'), findsOneWidget);
    });

    testWidgets('marks a day, changes it, then clears it', (tester) async {
      final (app, id) = await openAttendance(tester);

      await _tap(tester, '5');
      expect(find.text('Mark 05/03/2026'), findsOneWidget);
      await _tap(tester, 'Present');
      expect(find.text('Present: 1'), findsOneWidget);
      expect(find.text('Not marked: 30'), findsOneWidget);

      await _tap(tester, '5');
      await _tap(tester, 'Absent');
      expect(find.text('Present: 0'), findsOneWidget);
      expect(find.text('Absent: 1'), findsOneWidget);

      await _tap(tester, '5');
      await _tap(tester, 'Clear mark');
      expect(find.text('Absent: 0'), findsOneWidget);
      expect(find.text('Not marked: 31'), findsOneWidget);

      final marks = await app.container
          .read(attendanceRepositoryProvider)
          .forRange(id, DayRange.month(2026, 3));
      expect(marks, isEmpty);
    });

    testWidgets('half days are counted separately', (tester) async {
      await openAttendance(tester);
      await _tap(tester, '10');
      await _tap(tester, 'Half day');
      expect(find.text('Half day: 1'), findsOneWidget);
    });

    testWidgets('month navigation', (tester) async {
      await openAttendance(tester);
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(find.text('April 2026'), findsOneWidget);
      expect(find.text('Not marked: 30'), findsOneWidget);
      await tester.tap(find.byTooltip('Previous month'));
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('February 2026'), findsOneWidget);
      expect(find.text('Not marked: 28'), findsOneWidget);
    });

    testWidgets('marks persist when returning to a month', (tester) async {
      await openAttendance(tester);
      await _tap(tester, '7');
      await _tap(tester, 'Present');
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('Present: 1'), findsOneWidget);
    });
  });

  group('advances', () {
    Future<(TestApp, String)> openAdvances(WidgetTester tester) async {
      final app = await _open(tester);
      final id = await app.container
          .read(driverRepositoryProvider)
          .create(const DriverDraft(name: 'Karim'));
      app.container.read(routerProvider).go('/drivers/$id');
      await tester.pumpAndSettle();
      await _openTab(tester, 'Advances');
      return (app, id);
    }

    testWidgets('gives an advance and shows what is owed', (tester) async {
      await openAdvances(tester);
      expect(find.text('No advances'), findsOneWidget);

      await _tap(tester, 'Give advance');
      await tester.enterText(
        find.widgetWithText(TextField, 'Amount (৳)'),
        '4,000',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Note (optional)'),
        'Eid',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Advance recorded'), findsOneWidget);
      expect(find.text('৳ 4,000'), findsWidgets);
      expect(find.textContaining('Remaining ৳ 4,000'), findsOneWidget);
      expect(find.textContaining('Eid'), findsOneWidget);
      expect(find.text('Advances owed'), findsOneWidget);
    });

    testWidgets('rejects a zero or invalid amount', (tester) async {
      await openAdvances(tester);
      await _tap(tester, 'Give advance');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter an amount greater than zero'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Amount (৳)'), '0');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    });

    testWidgets('an unrecovered advance can be deleted', (tester) async {
      final (app, id) = await openAdvances(tester);
      await app.container
          .read(advanceRepositoryProvider)
          .give(
            driverId: id,
            amount: const Money.taka(500),
            day: day(2026, 3, 1),
          );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this advance?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('No advances'), findsOneWidget);
    });
  });

  testWidgets('every driver screen fits at 200% text size', (tester) async {
    final seed = await _open(tester, textScale: 2);
    final f = seed.container;
    final driverId = await f
        .read(driverRepositoryProvider)
        .create(
          DriverDraft(
            name: 'Abdul Karim Uddin Ahmed',
            phone: '01712345678',
            licenseNo: 'DL-1234567',
            licenseExpiry: day(2026, 1, 1),
            nid: '1990123456789',
            address: 'House 12, Road 5, Mirpur 10, Dhaka',
          ),
        );
    final router = f.read(routerProvider);
    for (final route in [
      '/drivers',
      '/drivers/new',
      '/drivers/$driverId',
      '/drivers/$driverId/edit',
      '/drivers/$driverId/payout/new',
    ]) {
      router.go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }
    router.go('/drivers/$driverId');
    await tester.pumpAndSettle();
    for (final tab in ['Attendance', 'Advances', 'Payouts']) {
      await _openTab(tester, tab);
      expect(tester.takeException(), isNull, reason: tab);
    }
  });
}
