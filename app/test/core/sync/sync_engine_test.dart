import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/sync/backoff.dart';
import 'package:vehicle_khata/core/sync/sync_engine.dart';
import 'package:vehicle_khata/core/sync/sync_server.dart';
import 'package:vehicle_khata/core/sync/sync_store.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/memory_sync_server.dart';

/// One phone: its own database and sync engine against a shared server.
class Phone {
  new(this.server, {String? user = 'user-1', int Function()? now})
    : fx = Fixture() {
    store = SyncStore(fx.db, now: now);
    engine = SyncEngine(
      db: fx.db,
      store: store,
      server: server,
      userId: () => user,
      now: now,
      random: Random(1),
      debounce: Duration.zero,
    );
  }

  final MemorySyncServer server;
  final Fixture fx;
  late final SyncStore store;
  late final SyncEngine engine;

  Future<void> sync() => engine.syncNow();

  Future<int> dirty(String table) async =>
      (await fx.db
              .customSelect('SELECT COUNT(*) c FROM $table WHERE dirty = 1')
              .getSingle())
          .read<int>('c');

  Future<List<String>> ids(String table) async =>
      (await fx.db.customSelect('SELECT id FROM $table ORDER BY id').get())
          .map((r) => r.read<String>('id'))
          .toList();

  Future<void> close() async {
    await engine.dispose();
    await fx.close();
  }
}

Future<String> addTrip(Phone p, String vehicleId, {int fare = 1000}) =>
    p.fx.trips.create(
      TripDraftHelper.simple(
        vehicleId,
        null,
        DateTime.utc(2026, 4, 1, 8),
        fare: fare,
      ),
    );

void main() {
  late MemorySyncServer server;
  late Phone a;
  late Phone b;

  setUp(() {
    server = MemorySyncServer();
    a = Phone(server);
    b = Phone(server);
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  group('push', () {
    test('sends waiting rows and clears their flag', () async {
      final v = await a.fx.vehicle();
      await addTrip(a, v);
      expect(await a.dirty('vehicles'), 1);

      await a.sync();

      expect(server.count('vehicles'), 1);
      expect(server.count('trips'), 1);
      expect(await a.dirty('vehicles'), 0);
      expect(await a.dirty('trips'), 0);
      expect(a.engine.status.phase, SyncPhase.idle);
      expect(a.engine.status.pending, 0);
      expect(a.engine.status.lastSyncedAt, isNotNull);
    });

    test('does not send local-only tables', () async {
      await a.fx.vehicle();
      await a.sync();
      expect(server.count('audit_logs'), 0);
      expect(server.count('daily_rollups'), 0);
    });

    test('batches of 200, parents before children', () async {
      final v = await a.fx.vehicle();
      for (var i = 0; i < 230; i++) {
        await addTrip(a, v, fare: 100 + i);
      }
      await a.sync();
      expect(server.count('trips'), 230);
      expect(server.pushBatchSizes.first, 200);
      expect(await a.dirty('trips'), 0);
    });

    test('an edit during the push keeps the row waiting', () async {
      final v = await a.fx.vehicle();
      await a.sync();
      await a.fx.vehicles.setStatus(v, (await a.fx.vehicles.get(v))!.status);
      final rev = await a.store.revOf('vehicles', v);
      // A late acknowledgement for an older revision must not clear the flag.
      await a.store.markPushed('vehicles', v, rev! - 1);
      expect(await a.dirty('vehicles'), 1);
      await a.store.markPushed('vehicles', v, rev);
      expect(await a.dirty('vehicles'), 0);
    });

    test(
      'a lost acknowledgement is harmless: the retry does not duplicate',
      () async {
        final v = await a.fx.vehicle();
        server.loseNextPushResponse = true;
        await a.sync();
        expect(a.engine.status.phase, SyncPhase.offline);
        expect(server.count('vehicles'), 1);
        expect(await a.dirty('vehicles'), 1);

        await a.sync();
        expect(a.engine.status.phase, SyncPhase.idle);
        expect(server.count('vehicles'), 1);
        expect(await a.dirty('vehicles'), 0);
        expect(server.row('vehicles', v), isNotNull);
      },
    );

    test('a rejected row does not block the others and is set aside', () async {
      final v1 = await a.fx.vehicle(name: 'Bad');
      final v2 = await a.fx.vehicle(name: 'Good');
      server.rejectIds.add(v1);

      await a.sync();
      expect(server.row('vehicles', v2), isNotNull);
      expect(server.row('vehicles', v1), isNull);
      expect(a.engine.status.issues, 1);
      expect(await a.dirty('vehicles'), 1);

      // Tried again on later syncs until it is parked.
      for (var i = 0; i < 6; i++) {
        await a.sync();
      }
      final issue = (await a.store.issues()).single;
      expect(issue.attempts, SyncStore.maxAttempts);
      final calls = server.pushCalls;
      await a.sync();
      expect(server.pushCalls, calls, reason: 'parked rows are not resent');
      expect(a.engine.status.pending, 0);

      // The person taps "retry"; once the server accepts it the row clears.
      server.rejectIds.clear();
      await a.engine.retryStuck();
      expect(server.row('vehicles', v1), isNotNull);
      expect(await a.store.issues(), isEmpty);
    });

    test('a phone clock far in the future is pulled back', () async {
      final nowMs = DateTime.utc(2026, 4).millisecondsSinceEpoch;
      final fast = Phone(server, now: () => nowMs);
      addTearDown(fast.close);
      final v = await fast.fx.vehicle();
      await fast.fx.db.customStatement(
        'UPDATE vehicles SET updated_at = ? WHERE id = ?',
        [nowMs + 90 * 24 * 3600 * 1000, v],
      );
      await fast.sync();
      expect(
        server.row('vehicles', v)!['updated_at'],
        nowMs + 24 * 3600 * 1000,
      );
    });
  });

  group('pull and convergence', () {
    test('a second phone receives everything', () async {
      final v = await a.fx.vehicle();
      final t = await addTrip(a, v);
      await a.fx.categories.ensureDefaults();
      await a.fx.expenses.create(
        v,
        ExpenseDraftFor.fuel(300, DateTime.utc(2026, 4, 1, 9)),
      );
      await a.sync();

      await b.sync();

      expect(await b.ids('vehicles'), [v]);
      expect(await b.ids('trips'), [t]);
      expect(await b.dirty('trips'), 0);
      expect(await b.dirty('vehicles'), 0);
      expect(await b.ids('expenses'), await a.ids('expenses'));
    });

    test('rollups on the new phone match the old one after restore', () async {
      final v = await a.fx.vehicle();
      await addTrip(a, v, fare: 2800);
      await a.fx.categories.ensureDefaults();
      await a.fx.expenses.create(
        v,
        ExpenseDraftFor.fuel(600, DateTime.utc(2026, 4, 1, 9)),
      );
      await a.sync();
      await b.sync();
      expect(await b.fx.rollups.verify(), isEmpty);
      final fromA = await a.fx.db
          .customSelect('SELECT * FROM daily_rollups')
          .get();
      final fromB = await b.fx.db
          .customSelect('SELECT * FROM daily_rollups')
          .get();
      expect(fromB.map((r) => r.data), fromA.map((r) => r.data));
    });

    test(
      'both phones edit offline: the later edit wins, both converge',
      () async {
        final v = await a.fx.vehicle(name: 'Original');
        await a.sync();
        await b.sync();

        await a.fx.db.customStatement(
          "UPDATE vehicles SET nickname = 'From A', updated_at = 2000000000000, rev = rev + 1, dirty = 1 WHERE id = ?",
          [v],
        );
        await b.fx.db.customStatement(
          "UPDATE vehicles SET nickname = 'From B', updated_at = 2000000005000, rev = rev + 1, dirty = 1 WHERE id = ?",
          [v],
        );
        await a.sync();
        await b.sync();
        await a.sync();

        Future<String> name(Phone p) async =>
            (await p.fx.vehicles.get(v))!.nickname;
        expect(await name(a), 'From B');
        expect(await name(b), 'From B');
        expect(await a.dirty('vehicles'), 0);
        expect(await b.dirty('vehicles'), 0);
      },
    );

    test('a newer unsent local edit survives a pull', () async {
      final v = await a.fx.vehicle(name: 'Original');
      await a.sync();
      server.put('vehicles', {
        ...server.row('vehicles', v)!,
        'nickname': 'Remote',
        'updated_at': 1000,
      });
      await a.fx.db.customStatement(
        "UPDATE vehicles SET nickname = 'Local', updated_at = 5000, rev = rev + 1, dirty = 1 WHERE id = ?",
        [v],
      );
      await a.sync();
      expect((await a.fx.vehicles.get(v))!.nickname, 'Local');
      expect(server.row('vehicles', v)!['nickname'], 'Local');
    });

    test('deletions travel as tombstones', () async {
      final v = await a.fx.vehicle();
      final t = await addTrip(a, v);
      await a.sync();
      await b.sync();
      await a.fx.trips.delete(t);
      await a.sync();
      await b.sync();
      final rows = await b.fx.db
          .customSelect("SELECT deleted_at FROM trips WHERE id = '$t'")
          .get();
      expect(rows.single.read<int?>('deleted_at'), isNotNull);
    });

    test('pages through a long history', () async {
      final v = await a.fx.vehicle();
      for (var i = 0; i < 30; i++) {
        await addTrip(a, v, fare: 100 + i);
      }
      await a.sync();
      final small = Phone(server);
      addTearDown(small.close);
      final paged = SyncEngine(
        db: small.fx.db,
        store: small.store,
        server: server,
        userId: () => 'user-1',
        pageSize: 7,
        debounce: Duration.zero,
      );
      addTearDown(paged.dispose);
      await paged.syncNow();
      expect(await small.ids('trips'), await a.ids('trips'));
      expect(await small.store.cursor, greaterThan(0));
    });

    test(
      'a row that cannot be stored is set aside; the rest still land',
      () async {
        final v = await a.fx.vehicle();
        await a.sync();
        server.put('trips', {'id': 'bad', 'updated_at': 5}); // missing columns
        await a.fx.vehicle(name: 'Another');
        await b.sync();
        expect(await b.ids('vehicles'), contains(v));
        expect(
          (await b.store.issues()).where((i) => i.direction == 'pull'),
          isNotEmpty,
        );
      },
    );

    test('restoring on an empty phone brings everything back', () async {
      final v = await a.fx.vehicle();
      final t = await addTrip(a, v);
      await a.fx.driver();
      await a.sync();

      final fresh = Phone(server);
      addTearDown(fresh.close);
      await fresh.engine.restoreFromServer();
      expect(await fresh.ids('trips'), [t]);
      expect(await fresh.ids('drivers'), await a.ids('drivers'));
    });
  });

  group('failures and gating', () {
    test('a network failure backs off and retries later', () async {
      await a.fx.vehicle();
      server.failNext.add(const SyncNetworkException('down'));
      await a.sync();
      expect(a.engine.status.phase, SyncPhase.offline);
      expect(a.engine.retryIn, isNotNull);
      expect(a.engine.status.pending, 1);

      await a.sync();
      expect(a.engine.status.phase, SyncPhase.idle);
      expect(server.count('vehicles'), 1);
    });

    test('an expired session asks to sign in again, not to retry', () async {
      await a.fx.vehicle();
      server.failNext.add(const SyncAuthException('expired'));
      await a.sync();
      expect(a.engine.status.phase, SyncPhase.signedOut);
      expect(a.engine.retryIn, isNull);
    });

    test('signed out: nothing is sent', () async {
      final off = Phone(server, user: null);
      addTearDown(off.close);
      await off.fx.vehicle();
      await off.sync();
      expect(off.engine.status.phase, SyncPhase.disabled);
      expect(server.pushCalls, 0);
    });

    test('another account on the same phone does not mix data', () async {
      await a.fx.vehicle();
      await a.sync();
      final other = SyncEngine(
        db: a.fx.db,
        store: a.store,
        server: MemorySyncServer(userId: 'user-2'),
        userId: () => 'user-2',
      );
      addTearDown(other.dispose);
      await other.syncNow();
      expect(other.status.phase, SyncPhase.wrongAccount);
    });

    test('concurrent syncNow calls share one run', () async {
      await a.fx.vehicle();
      await Future.wait([a.sync(), a.sync(), a.sync()]);
      expect(server.pushCalls, 1);
    });
  });

  group('upgrade from before sync', () {
    test('existing rows are all waiting to be sent', () async {
      final v = await a.fx.vehicle();
      await a.sync();
      expect(await a.dirty('vehicles'), 0);
      // The migration marks everything dirty; mirror it and push again.
      await a.fx.db.customStatement('UPDATE vehicles SET dirty = 1');
      await a.sync();
      expect(server.count('vehicles'), 1);
      expect(server.row('vehicles', v), isNotNull);
    });
  });

  group('backoff', () {
    const policy = BackoffPolicy(jitter: 0);
    test('doubles up to the cap', () {
      expect(policy.delay(1), const Duration(seconds: 5));
      expect(policy.delay(2), const Duration(seconds: 10));
      expect(policy.delay(3), const Duration(seconds: 20));
      expect(policy.delay(20), const Duration(minutes: 15));
    });

    test('jitter stays within bounds', () {
      const j = BackoffPolicy();
      final r = Random(3);
      for (var i = 0; i < 100; i++) {
        final ms = j.delay(3, r).inMilliseconds;
        expect(ms, inInclusiveRange(16000, 24000));
      }
    });

    test('future stamps are clamped to a day ahead', () {
      const day = 86400000;
      expect(clampUpdatedAt(1000, 5000), 1000);
      expect(clampUpdatedAt(5000 + day + 1, 5000), 5000 + day);
      expect(clampUpdatedAt(5000 + day, 5000), 5000 + day);
    });
  });
}
