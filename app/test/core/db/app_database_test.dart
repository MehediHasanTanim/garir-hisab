import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/database_key_store.dart';

class _MemorySecretStore implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

Future<String> _insert(AppDatabase db) async {
  final row = await db
      .into(db.auditLogs)
      .insertReturning(
        AuditLogsCompanion.insert(
          entity: 'trip',
          entityId: 'x',
          action: 'create',
        ),
      );
  return row.id;
}

void main() {
  group('synced columns defaults', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase.inMemory());
    tearDown(() => db.close());

    test('id is a UUIDv7, timestamps set, dirty, rev 0, local owner', () async {
      final id = await _insert(db);
      final row = await (db.select(
        db.auditLogs,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(id, matches(RegExp('^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-')));
      expect(row.createdAt, greaterThan(0));
      expect(row.updatedAt - row.createdAt, inInclusiveRange(0, 50));
      expect(row.deletedAt, isNull);
      expect(row.rev, 0);
      expect(row.dirty, isTrue);
      expect(row.ownerId, 'local');
    });

    test('ids are time-ordered', () async {
      final a = await _insert(db);
      await Future<void>.delayed(const Duration(milliseconds: 2));
      final b = await _insert(db);
      expect(a.compareTo(b), lessThan(0));
    });

    test(
      'softDelete sets tombstone, bumps rev and dirty; restore clears',
      () async {
        final id = await _insert(db);
        await (db.update(db.auditLogs)..where((t) => t.id.equals(id))).write(
          const AuditLogsCompanion(dirty: Value(false)),
        );

        expect(await db.softDelete(db.auditLogs, id), 1);
        var row = await (db.select(
          db.auditLogs,
        )..where((t) => t.id.equals(id))).getSingle();
        expect(row.deletedAt, isNotNull);
        expect(row.rev, 1);
        expect(row.dirty, isTrue);

        await db.restore(db.auditLogs, id);
        row = await (db.select(
          db.auditLogs,
        )..where((t) => t.id.equals(id))).getSingle();
        expect(row.deletedAt, isNull);
        expect(row.rev, 2);
      },
    );

    test('softDelete of unknown id affects nothing', () async {
      expect(await db.softDelete(db.auditLogs, 'nope'), 0);
    });
  });

  group('encryption at rest', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('khata_db'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('file is unreadable without the key', () async {
      final file = File('${dir.path}/k.db');
      var db = AppDatabase.file(file, key: 'right');
      await _insert(db);
      await db.close();

      expect(
        String.fromCharCodes(file.readAsBytesSync().take(15)),
        isNot(contains('SQLite format')),
      );

      db = AppDatabase.file(file, key: 'wrong');
      await expectLater(db.select(db.auditLogs).get(), throwsA(anything));
      await db.close().catchError((_) {});

      db = AppDatabase.file(file, key: 'right');
      expect(await db.select(db.auditLogs).get(), hasLength(1));
      await db.close();
    });
  });

  group('DatabaseKeyStore', () {
    test('generates a 256-bit hex key once and reuses it', () async {
      final store = _MemorySecretStore();
      final keys = DatabaseKeyStore(store);
      final first = await keys.getOrCreateKey();
      expect(first, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(await DatabaseKeyStore(store).getOrCreateKey(), first);
    });

    test('different installs get different keys', () async {
      final a = await DatabaseKeyStore(_MemorySecretStore()).getOrCreateKey();
      final b = await DatabaseKeyStore(_MemorySecretStore()).getOrCreateKey();
      expect(a, isNot(b));
    });
  });
}
