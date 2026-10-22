// S0-T4 spike: Drift + SQLite3 Multiple Ciphers (encrypted at rest).
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'encrypted_db.g.dart';

class SpikeRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();
  IntColumn get amountMinor => integer()();
}

@DriftDatabase(tables: [SpikeRows])
class SpikeDatabase extends _$SpikeDatabase {
  SpikeDatabase(File file, {required String key})
    : super(
        NativeDatabase(
          file,
          setup: (db) {
            // Must be the first statement on the connection.
            db.execute("PRAGMA key = '$key';");
          },
        ),
      );

  @override
  int get schemaVersion => 1;

  Future<void> insertMany(int count) => batch((b) {
    b.insertAll(spikeRows, [
      for (var i = 0; i < count; i++)
        SpikeRowsCompanion.insert(label: 'row $i', amountMinor: i * 100),
    ]);
  });
}

class SpikeResult {
  const SpikeResult(this.openMs, this.insertMs, this.countMs, this.rows);
  final int openMs;
  final int insertMs;
  final int countMs;
  final int rows;

  @override
  String toString() =>
      'open=${openMs}ms insert($rows)=${insertMs}ms count=${countMs}ms';
}

Future<SpikeResult> runEncryptedDbSpike(
  File file, {
  required String key,
  int rows = 50000,
}) async {
  final sw = Stopwatch()..start();
  final db = SpikeDatabase(file, key: key);
  await db.customSelect('SELECT 1').get(); // forces open
  final openMs = sw.elapsedMilliseconds;

  sw
    ..reset()
    ..start();
  await db.insertMany(rows);
  final insertMs = sw.elapsedMilliseconds;

  sw
    ..reset()
    ..start();
  final count = await db.spikeRows.count().getSingle();
  final countMs = sw.elapsedMilliseconds;
  await db.close();
  if (count != rows) throw StateError('expected $rows rows, got $count');
  return SpikeResult(openMs, insertMs, countMs, rows);
}
