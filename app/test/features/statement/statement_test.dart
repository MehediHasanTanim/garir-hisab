import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/statement/data/driver_statement.dart';
import 'package:vehicle_khata/features/statement/data/statement_pdf.dart';

import '../../helpers/fake_file_sharer.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

Future<Uint8List> _png(int w, int h) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    ui.Paint()..color = const ui.Color(0xFF336699),
  );
  final image = await recorder.endRecording().toImage(w, h);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

int _pageCount(Uint8List pdf) =>
    RegExp(r'/Type\s*/Page\b').allMatches(String.fromCharCodes(pdf)).length;

void main() {
  group('statement data', () {
    late Fixture fx;
    late String driver;
    late StatementService service;

    setUp(() async {
      fx = Fixture();
      final v = await fx.vehicle();
      driver = await fx.driver(phone: '01711111111');
      final a = await fx.assignments.assign(
        vehicleId: v,
        driverId: driver,
        payModel: salary15000,
        start: day(2026, 1, 1),
      );
      await fx.advances.give(
        driverId: driver,
        amount: const Money.taka(2000),
        day: day(2026, 2, 10),
      );
      await fx.payouts.record(
        driverId: driver,
        assignmentId: a,
        period: DayRange.month(2026, 3),
      );
      // Given after the payout, so it is still owed.
      await fx.advances.give(
        driverId: driver,
        amount: const Money.taka(1000),
        day: day(2026, 4, 5),
      );
      service = StatementService(fx.drivers, fx.payouts, fx.advances);
    });
    tearDown(() => fx.close());

    test('all time totals', () async {
      final s = (await service.build(driver, null))!;
      expect(s.driverName, 'Karim');
      expect(s.payouts, hasLength(1));
      expect(s.advances, hasLength(2));
      expect(
        s.advances.first.givenOn,
        day(2026, 2, 10),
        reason: 'oldest first',
      );
      expect(s.totalEarned, const Money.taka(15000));
      expect(s.totalRecovered, const Money.taka(2000));
      expect(s.totalPaid, const Money.taka(13000));
      expect(s.totalAdvancesGiven, const Money.taka(3000));
      expect(s.advancesOwed, const Money.taka(1000));
    });

    test('a period keeps only what falls in it; owed stays all-time', () async {
      final march = (await service.build(driver, DayRange.month(2026, 3)))!;
      expect(march.payouts, hasLength(1));
      expect(march.advances, isEmpty);
      expect(march.advancesOwed, const Money.taka(1000));

      final april = (await service.build(driver, DayRange.month(2026, 4)))!;
      expect(april.payouts, isEmpty);
      expect(april.advances, hasLength(1));
      expect(april.isEmpty, isFalse);

      final may = (await service.build(driver, DayRange.month(2026, 5)))!;
      expect(may.isEmpty, isTrue);
    });

    test('unknown driver', () async {
      expect(await service.build('nope', null), isNull);
    });
  });

  group('pdf', () {
    test('wraps the picture in a valid PDF', () async {
      final png = (await TestWidgetsFlutterBinding.ensureInitialized().runAsync(
        () => _png(360, 500),
      ))!;
      final pdf = await imageToPdf(png: png, widthPx: 360, heightPx: 500);
      expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
      expect(_pageCount(pdf), 1);
    });

    test('a tall statement continues on more pages', () async {
      final png = (await TestWidgetsFlutterBinding.ensureInitialized().runAsync(
        () => _png(360, 2000),
      ))!;
      // 2000 px at 360 px wide = ~3.3 A4 widths of height -> 4 pages.
      final pdf = await imageToPdf(png: png, widthPx: 360, heightPx: 2000);
      expect(_pageCount(pdf), 4);
    });
  });

  testWidgets('driver menu -> statement -> share PDF', (tester) async {
    final sharer = FakeFileSharer();
    final app = await pumpApp(
      tester,
      clock: () => DateTime(2026, 3, 15, 10),
      overrides: [fileSharerProvider.overrideWithValue(sharer)],
    );
    final c = app.container;
    final ids = await (() async {
      final v = await c
          .read(vehicleRepositoryProvider)
          .create(salariedVehicle());
      final d = await c
          .read(driverRepositoryProvider)
          .create(const DriverDraft(name: 'Karim'));
      final a = await c
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
            amount: const Money.taka(500),
            day: day(2026, 3, 2),
          );
      await c
          .read(payoutServiceProvider)
          .record(
            driverId: d,
            assignmentId: a,
            period: DayRange.month(2026, 2),
          );
      return d;
    })();

    app.container.read(routerProvider).go('/drivers/$ids');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Statement (PDF)'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Driver statement'), findsWidgets);
    expect(find.text('Karim'), findsWidgets);
    expect(find.text('Advances given'), findsWidgets);
    expect(find.text('Advances still owed'), findsOneWidget);

    await tester.ensureVisible(find.text('All time'));
    await tester.pump();
    await tester.tap(find.text('All time'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Payouts'), findsOneWidget);

    await tester.tap(find.text('Share PDF'));
    for (var i = 0; i < 20 && sharer.shared.isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump();
    }
    expect(sharer.shared, hasLength(1));
    final f = sharer.shared.single;
    expect(f.fileName, 'statement-2026-03-15.pdf');
    expect(f.mimeType, 'application/pdf');
    expect(String.fromCharCodes(f.bytes.take(5)), '%PDF-');
    expect(f.text, 'Statement for Karim');
  });
}
