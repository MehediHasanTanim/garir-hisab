import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/features/vehicles/data/photo_store.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/pump_app.dart';

VehicleDraft _draft(
  String name, {
  VehicleType type = VehicleType.cng,
  String? regNo,
  VehicleStatus status = VehicleStatus.active,
}) => VehicleDraft(
  nickname: name,
  type: type,
  fuelType: type.defaultFuel,
  businessModel: type.defaultModel,
  regNo: regNo,
  status: status,
);

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _openMenu(WidgetTester tester, String vehicle) async {
  final tile = find.ancestor(
    of: find.text(vehicle),
    matching: find.byType(ListTile),
  );
  await tester.tap(
    find.descendant(of: tile, matching: find.byIcon(Icons.more_vert)),
  );
  await tester.pumpAndSettle();
}

/// Lets real file IO (outside the fake-async zone) finish and be processed.
Future<void> _settleIo(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  group('add vehicle', () {
    testWidgets('empty Home -> form -> list', (tester) async {
      final app = await pumpApp(tester);
      expect(find.text('No vehicles yet'), findsOneWidget);

      await _tap(tester, 'Add your first vehicle');
      expect(find.text('New vehicle'), findsOneWidget);

      // Nickname is required.
      await _tap(tester, 'Save');
      expect(find.text('Enter a nickname'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nickname'),
        'Rahim CNG',
      );
      await _tap(tester, 'Save');

      expect(find.text('Rahim CNG'), findsOneWidget);
      expect(find.text('Vehicle saved'), findsOneWidget);
      final rows = await app.db.select(app.db.vehicles).get();
      expect(rows.single.nickname, 'Rahim CNG');
      expect(rows.single.type, VehicleType.cng);
      expect(rows.single.businessModel, BusinessModel.self);
    });

    testWidgets('choosing a type applies fuel and business model defaults', (
      tester,
    ) async {
      final app = await pumpApp(tester, location: '/vehicles/new');
      await _tap(tester, 'Truck');
      expect(find.text('Per-trip contract'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nickname'),
        'Big truck',
      );
      await tester.pumpAndSettle();
      await _tap(tester, 'Save');

      final v = (await app.db.select(app.db.vehicles).get()).single;
      expect(v.fuelType, FuelType.diesel);
      expect(v.businessModel, BusinessModel.contract);
    });

    testWidgets('validates year and price', (tester) async {
      await pumpApp(tester, location: '/vehicles/new');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nickname'),
        'A',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Year (Optional)'),
        '1900',
      );
      await tester.pumpAndSettle();
      await _tap(tester, 'Save');
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid year'), findsOneWidget);
    });

    testWidgets(
      'warns about a duplicate registration but still allows saving',
      (tester) async {
        final app = await pumpApp(tester, location: '/vehicles/new');
        await app.container
            .read(vehicleRepositoryProvider)
            .create(_draft('Existing', regNo: 'DM HA 11-1111'));

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Registration number (Optional)'),
          'dm-ha 11 1111',
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(
          find.text('Another vehicle (Existing) already has this number.'),
          findsOneWidget,
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nickname'),
          'Twin',
        );
        await tester.pumpAndSettle();
        await _tap(tester, 'Save');
        expect(await app.db.select(app.db.vehicles).get(), hasLength(2));
      },
    );

    testWidgets('a vehicle is not a duplicate of itself, but is of another', (
      tester,
    ) async {
      final app = await pumpApp(tester);
      final repo = app.container.read(vehicleRepositoryProvider);
      final a = await repo.create(_draft('Alpha', regNo: 'AB 1'));
      await repo.create(_draft('Beta', regNo: 'CD 2'));
      await tester.pumpAndSettle();

      Future<void> typeReg(String text) async {
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Registration number (Optional)'),
          text,
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
      }

      app.container.read(routerProvider).go('/vehicles/$a/edit');
      await tester.pumpAndSettle();

      await typeReg('ab-1'); // its own number
      expect(find.textContaining('already has this number'), findsNothing);

      await typeReg('cd 2'); // Beta's number
      expect(
        find.text('Another vehicle (Beta) already has this number.'),
        findsOneWidget,
      );
    });
  });

  group('list', () {
    Future<TestApp> seeded(WidgetTester tester) async {
      final app = await pumpApp(tester);
      final repo = app.container.read(vehicleRepositoryProvider);
      await repo.create(_draft('Rahim CNG', regNo: 'DM 11'));
      await repo.create(_draft('Karim Pickup', type: VehicleType.pickup));
      await repo.create(
        _draft(
          'Old Truck',
          type: VehicleType.truck,
          status: VehicleStatus.inGarage,
        ),
      );
      await tester.pumpAndSettle();
      return app;
    }

    testWidgets('shows vehicles with type, registration and status', (
      tester,
    ) async {
      await seeded(tester);
      expect(find.text('Rahim CNG'), findsOneWidget);
      expect(find.text('CNG auto-rickshaw · DM 11'), findsOneWidget);
      expect(find.text('Pickup'), findsWidgets);
      expect(find.text('In garage'), findsWidgets);
    });

    testWidgets('search narrows the list; clearing restores it', (
      tester,
    ) async {
      await seeded(tester);
      await tester.enterText(find.byType(SearchBar), 'karim');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Karim Pickup'), findsOneWidget);
      expect(find.text('Rahim CNG'), findsNothing);

      await tester.enterText(find.byType(SearchBar), 'nothing here');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('No vehicles match your search.'), findsOneWidget);

      await tester.enterText(find.byType(SearchBar), '');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Rahim CNG'), findsOneWidget);
    });

    testWidgets('status chips filter the list', (tester) async {
      await seeded(tester);
      await tester.tap(find.widgetWithText(FilterChip, 'In garage'));
      await tester.pumpAndSettle();
      expect(find.text('Old Truck'), findsOneWidget);
      expect(find.text('Rahim CNG'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'All'));
      await tester.pumpAndSettle();
      expect(find.text('Rahim CNG'), findsOneWidget);
    });

    testWidgets(
      'archive hides a vehicle, Show archived reveals it, restore brings it back',
      (tester) async {
        final app = await seeded(tester);

        await _openMenu(tester, 'Rahim CNG');
        await _tap(tester, 'Archive');
        expect(find.text('Archive this vehicle?'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
        await tester.pumpAndSettle();
        expect(find.text('Vehicle archived'), findsOneWidget);
        expect(find.text('Rahim CNG'), findsNothing);

        // The filter chips scroll horizontally; bring the last one into view.
        await tester.drag(
          find.ancestor(
            of: find.text('Show archived'),
            matching: find.byType(SingleChildScrollView),
          ),
          const Offset(-400, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilterChip, 'Show archived'));
        await tester.pumpAndSettle();
        expect(find.text('Rahim CNG'), findsOneWidget);
        expect(find.text('Archived'), findsOneWidget);

        await _openMenu(tester, 'Rahim CNG');
        await _tap(tester, 'Restore');
        expect(find.text('Vehicle restored'), findsOneWidget);
        final row = (await app.db.select(app.db.vehicles).get()).firstWhere(
          (v) => v.nickname == 'Rahim CNG',
        );
        expect(row.archived, isFalse);
      },
    );

    testWidgets('cancelling the archive dialog keeps the vehicle', (
      tester,
    ) async {
      await seeded(tester);
      await _openMenu(tester, 'Rahim CNG');
      await _tap(tester, 'Archive');
      await _tap(tester, 'Cancel');
      expect(find.text('Rahim CNG'), findsOneWidget);
    });

    testWidgets('change status from the menu', (tester) async {
      final app = await seeded(tester);
      await _openMenu(tester, 'Rahim CNG');
      await _tap(tester, 'Change status');
      await tester.tap(find.widgetWithText(SimpleDialogOption, 'Sold'));
      await tester.pumpAndSettle();
      final row = (await app.db.select(app.db.vehicles).get()).firstWhere(
        (v) => v.nickname == 'Rahim CNG',
      );
      expect(row.status, VehicleStatus.sold);
    });

    testWidgets('tapping a vehicle opens it for editing and saves changes', (
      tester,
    ) async {
      final app = await seeded(tester);
      await _tap(tester, 'Rahim CNG');
      expect(find.text('Edit vehicle'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Rahim CNG'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Rahim CNG'),
        'Rahim Renamed',
      );
      await tester.pumpAndSettle();
      await _tap(tester, 'Save');

      expect(find.text('Rahim Renamed'), findsOneWidget);
      expect(
        (await app.db.select(app.db.vehicles).get()).map((v) => v.nickname),
        contains('Rahim Renamed'),
      );
    });

    testWidgets('editing an unknown vehicle shows not found', (tester) async {
      await pumpApp(tester, location: '/vehicles/nope/edit');
      expect(find.text('Vehicle not found'), findsOneWidget);
    });
  });

  group('photos', () {
    testWidgets('picked photo is stored, referenced and replaced cleanly', (
      tester,
    ) async {
      final dir = Directory.systemTemp.createTempSync('khata_photos');
      addTearDown(() => dir.deleteSync(recursive: true));
      final src = File('${dir.path}/src.jpg')..writeAsBytesSync([1, 2, 3]);
      final storeDir = Directory('${dir.path}/store');
      final picker = FakePhotoPicker()..next = src.path;

      final app = await pumpApp(
        tester,
        location: '/vehicles/new',
        photoPicker: picker,
        photoStore: PhotoStore(() async => storeDir),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nickname'),
        'Snap',
      );
      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      await _settleIo(tester);

      await tester.pumpAndSettle();
      await _tap(tester, 'Save');
      await _settleIo(tester);

      final row = (await app.db.select(app.db.vehicles).get()).single;
      expect(row.photoFile, isNotNull);
      expect(File('${storeDir.path}/${row.photoFile}').existsSync(), isTrue);
    });

    testWidgets('a photo picked but never saved is deleted', (tester) async {
      final dir = Directory.systemTemp.createTempSync('khata_photos2');
      addTearDown(() => dir.deleteSync(recursive: true));
      final src = File('${dir.path}/src.jpg')..writeAsBytesSync([1, 2, 3]);
      final storeDir = Directory('${dir.path}/store');

      await pumpApp(
        tester,
        location: '/vehicles/new',
        photoPicker: FakePhotoPicker()..next = src.path,
        photoStore: PhotoStore(() async => storeDir),
      );
      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      await _settleIo(tester);
      expect(storeDir.listSync(), hasLength(1));

      // Leave the form without saving.
      await tester.pumpWidget(const SizedBox());
      await _settleIo(tester);
      expect(storeDir.listSync(), isEmpty);
    });
  });

  test('PhotoStore saves, resolves and deletes files', () async {
    final dir = Directory.systemTemp.createTempSync('khata_store');
    addTearDown(() => dir.deleteSync(recursive: true));
    final src = File('${dir.path}/in.jpg')..writeAsBytesSync([9, 9]);
    final store = PhotoStore(() async => Directory('${dir.path}/photos'));

    final name = await store.save(src.path);
    expect(name, endsWith('.jpg'));
    expect((await store.resolve(name))!.readAsBytesSync(), [9, 9]);
    expect(await store.resolve(null), isNull);
    expect(await store.resolve('missing.jpg'), isNull);

    await store.delete(name);
    expect(await store.resolve(name), isNull);
    await store.delete(null); // no-op
  });
}
