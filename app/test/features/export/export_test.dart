import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/features/export/data/data_export_service.dart';

import '../../helpers/fake_file_sharer.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

String _read(Archive a, String name) =>
    utf8.decode(a.findFile(name)!.content as List<int>);

void main() {
  test('zip holds JSON and CSV, hides the national ID, keeps Bangla', () async {
    final fx = Fixture(clock: () => DateTime.utc(2026, 4, 1, 9));
    addTearDown(fx.close);
    final v = await fx.vehicle(name: 'রহিমের "সিএনজি", ঢাকা');
    final d = await fx.driver(name: 'করিম', nid: '1234567890123');
    await fx.trips.create(
      TripDraftHelper.simple(v, d, DateTime.utc(2026, 3, 1, 8)),
    );

    final bytes = await DataExportService(
      fx.db,
      clock: () => DateTime.utc(2026, 4, 2),
    ).build();
    final zip = ZipDecoder().decodeBytes(bytes);
    final names = zip.files.map((f) => f.name).toSet();
    expect(
      names,
      containsAll([
        'khata-export.json',
        'csv/vehicles.csv',
        'csv/trips.csv',
        'csv/drivers.csv',
      ]),
    );
    expect(
      names,
      isNot(contains('csv/payouts.csv')),
      reason: 'empty tables are skipped in CSV',
    );

    final json =
        jsonDecode(_read(zip, 'khata-export.json')) as Map<String, dynamic>;
    expect(json['exportedAt'], '2026-04-02T00:00:00.000Z');
    final tables = json['tables'] as Map<String, dynamic>;
    expect(tables['trips'] as List, hasLength(1));
    expect(tables['payouts'] as List, isEmpty);

    final all = zip.files
        .map((f) => utf8.decode(f.content as List<int>))
        .join();
    expect(all, isNot(contains('nid_encrypted')));
    expect(all, isNot(contains('1234567890123')));

    final vehiclesCsv = _read(zip, 'csv/vehicles.csv');
    // utf8.decode drops a byte-order mark, so check the raw bytes.
    expect((zip.findFile('csv/vehicles.csv')!.content as List<int>).take(3), [
      0xEF,
      0xBB,
      0xBF,
    ]);
    expect(vehiclesCsv, contains('"রহিমের ""সিএনজি"", ঢাকা"'));
  });

  test('CSV quoting', () {
    final csv = DataExportService.toCsv([
      {'a': 'x,y', 'b': null, 'c': 'line\nbreak', 'd': 5},
    ]);
    expect(csv, '﻿a,b,c,d\n"x,y",,"line\nbreak",5\n');
  });

  testWidgets('Export and share hands the zip to the share sheet', (
    tester,
  ) async {
    final sharer = FakeFileSharer();
    final app = await pumpApp(
      tester,
      location: '/more/export',
      overrides: [fileSharerProvider.overrideWithValue(sharer)],
    );
    await tester.runAsync(
      () => app.container
          .read(vehicleRepositoryProvider)
          .create(salariedVehicle()),
    );
    expect(
      find.text("Drivers' national ID numbers are not included."),
      findsOneWidget,
    );
    await tester.tap(find.text('Export and share'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    expect(sharer.shared, hasLength(1));
    expect(
      sharer.shared.single.fileName,
      matches(RegExp(r'^khata-export-\d{8}\.zip$')),
    );
    expect(sharer.shared.single.mimeType, 'application/zip');
    expect(
      ZipDecoder().decodeBytes(sharer.shared.single.bytes).files,
      isNotEmpty,
    );
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
