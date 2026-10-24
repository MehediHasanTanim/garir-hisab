import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/core/sync/sync_server.dart';
import 'package:vehicle_khata/features/auth/data/fake_auth_repository.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/memory_sync_server.dart';
import '../../helpers/pump_app.dart';

Future<FakeAuthRepository> _signedIn() async {
  final auth = FakeAuthRepository();
  await auth.verifyOtp(phoneE164: '+8801711111111', code: '123456');
  return auth;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

/// The sync engine keeps timers (periodic sync, retry). Dispose it inside the
/// test, since the framework checks for pending timers before tear-downs run.
Future<void> _end(WidgetTester tester, TestApp app) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 50));
  app.container.dispose();
}

void main() {
  testWidgets('no backend: no Sync & backup entry in More', (tester) async {
    await pumpApp(tester, location: '/more');
    expect(find.text('Sync & backup'), findsNothing);
  });

  testWidgets('with a backend the entry shows and the page says backed up', (
    tester,
  ) async {
    final server = MemorySyncServer(userId: 'user-+8801711111111');
    final app = await pumpApp(
      tester,
      location: '/more',
      auth: await _signedIn(),
      overrides: [syncServerProvider.overrideWithValue(server)],
    );
    await _settle(tester);
    expect(find.text('Sync & backup'), findsOneWidget);

    await tester.tap(find.text('Sync & backup'));
    await tester.pumpAndSettle();
    expect(find.text('Everything is backed up'), findsOneWidget);
    expect(find.textContaining('Last backed up'), findsOneWidget);
    await _end(tester, app);
  });

  testWidgets('Sync now sends what is waiting', (tester) async {
    final server = MemorySyncServer(userId: 'user-+8801711111111');
    final app = await pumpApp(
      tester,
      location: '/more/sync',
      auth: await _signedIn(),
      overrides: [syncServerProvider.overrideWithValue(server)],
    );
    await _settle(tester);

    await tester.runAsync(
      () => app.container
          .read(vehicleRepositoryProvider)
          .create(salariedVehicle()),
    );
    await tester.tap(find.text('Sync now'));
    await _settle(tester);

    expect(server.count('vehicles'), 1);
    expect(find.text('Everything is backed up'), findsOneWidget);
    expect(find.textContaining('waiting to be sent'), findsNothing);
    await _end(tester, app);
  });

  testWidgets('offline shows a plain message and Sync now recovers', (
    tester,
  ) async {
    final server = MemorySyncServer(userId: 'user-+8801711111111');
    final app = await pumpApp(
      tester,
      location: '/more/sync',
      auth: await _signedIn(),
      overrides: [syncServerProvider.overrideWithValue(server)],
    );
    await _settle(tester);
    server.failNext.add(const SyncNetworkException('down'));
    await tester.runAsync(
      () => app.container
          .read(vehicleRepositoryProvider)
          .create(salariedVehicle()),
    );
    await tester.tap(find.text('Sync now'));
    await _settle(tester);
    expect(find.text('No connection. Will try again soon.'), findsOneWidget);
    expect(find.text('1 waiting to be sent'), findsOneWidget);

    await tester.tap(find.text('Sync now'));
    await _settle(tester);
    expect(find.text('Everything is backed up'), findsOneWidget);
    await _end(tester, app);
  });

  testWidgets('a set-aside row shows "Needs attention" and Try again', (
    tester,
  ) async {
    final server = MemorySyncServer(userId: 'user-+8801711111111');
    final app = await pumpApp(
      tester,
      location: '/more/sync',
      auth: await _signedIn(),
      overrides: [syncServerProvider.overrideWithValue(server)],
    );
    await _settle(tester);
    final id = await tester.runAsync(
      () => app.container
          .read(vehicleRepositoryProvider)
          .create(salariedVehicle()),
    );
    server.rejectIds.add(id!);
    await tester.tap(find.text('Sync now'));
    await _settle(tester);
    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('1 items could not be synced'), findsOneWidget);

    server.rejectIds.clear();
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await _settle(tester);
    expect(find.text('Needs attention'), findsNothing);
    expect(server.count('vehicles'), 1);
    await _end(tester, app);
  });

  testWidgets('restore asks first, then brings the server data in', (
    tester,
  ) async {
    final server = MemorySyncServer(userId: 'user-+8801711111111');
    // A vehicle that exists only on the server.
    final other = Fixture();
    addTearDown(other.close);
    final remoteId = await tester.runAsync(other.vehicle);
    final row = await tester.runAsync(
      () => other.db
          .customSelect("SELECT * FROM vehicles WHERE id = '$remoteId'")
          .getSingle(),
    );
    server.put('vehicles', {
      for (final e in row!.data.entries)
        if (e.key != 'dirty')
          e.key: (e.key == 'archived') ? e.value == 1 : e.value,
    });

    final app = await pumpApp(
      tester,
      location: '/more/sync',
      auth: await _signedIn(),
      overrides: [syncServerProvider.overrideWithValue(server)],
    );
    await _settle(tester);
    // Already pulled by the first sync; wipe the cursor to prove restore works.
    await tester.runAsync(() => app.db.customStatement('DELETE FROM vehicles'));

    await tester.ensureVisible(find.text('Restore from backup'));
    await tester.tap(find.text('Restore from backup'));
    await tester.pumpAndSettle();
    expect(find.text('Restore from backup?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      await tester.runAsync(
        () => app.db.customSelect('SELECT id FROM vehicles').get(),
      ),
      isEmpty,
    );

    await tester.tap(find.text('Restore from backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore'));
    await _settle(tester);
    final ids = (await tester.runAsync(
      () => app.db.customSelect('SELECT id FROM vehicles').get(),
    ))!;
    expect(ids.map((r) => r.read<String>('id')), [remoteId]);
    await _end(tester, app);
  });

  testWidgets('signed out: explains that data stays on the phone', (
    tester,
  ) async {
    final server = MemorySyncServer();
    final app = await pumpApp(
      tester,
      location: '/more/sync',
      overrides: [syncServerProvider.overrideWithValue(server)],
    );
    await _settle(tester);
    expect(
      find.text('Not signed in. Your data stays on this phone only.'),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Sync now'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
    expect(server.pushCalls, 0);
    await _end(tester, app);
  });

  testWidgets('fits at 200% text size', (tester) async {
    final server = MemorySyncServer(userId: 'user-+8801711111111');
    final app = await pumpApp(
      tester,
      location: '/more/sync',
      textScale: 2,
      auth: await _signedIn(),
      overrides: [syncServerProvider.overrideWithValue(server)],
    );
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Sync now'), findsOneWidget);
    await _end(tester, app);
  });

  testWidgets('Bangla labels', (tester) async {
    final server = MemorySyncServer(userId: 'user-+8801711111111');
    final app = await pumpApp(
      tester,
      location: '/more/sync',
      prefs: const {'settings.language': 'bn'},
      auth: await _signedIn(),
      overrides: [syncServerProvider.overrideWithValue(server)],
    );
    await _settle(tester);
    expect(find.text('সিঙ্ক ও ব্যাকআপ'), findsOneWidget);
    expect(find.text('সব তথ্য ব্যাকআপ করা আছে'), findsOneWidget);
    await _end(tester, app);
  });
}
