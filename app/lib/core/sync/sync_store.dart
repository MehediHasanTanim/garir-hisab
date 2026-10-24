import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/sync/backoff.dart';
import 'package:vehicle_khata/core/sync/sync_server.dart';

/// Tables that sync, in the order rows must be pushed (parents first).
/// Must match `public.sync_tables()` on the server.
const syncTableOrder = [
  'vehicles',
  'drivers',
  'assignments',
  'attendance_records',
  'advances',
  'payouts',
  'payout_advance_allocations',
  'expense_categories',
  'trips',
  'expenses',
  'day_logs',
];

/// Tables whose changes affect the derived daily rollups.
const _rollupSources = {'trips', 'expenses', 'day_logs'};

class _SyncTable {
  new(this.info) : name = info.actualTableName, columns = info.$columns;

  final TableInfo<Table, Object?> info;
  final String name;
  final List<GeneratedColumn<Object>> columns;
}

/// Local sync state: which rows are waiting, what the server last sent, and
/// the rows that could not be synced. Knows nothing about the network.
class SyncStore {
  new(this._db, {int Function()? now})
    : _now = now ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch) {
    final byName = {for (final t in _db.allTables) t.actualTableName: t};
    _tables = [for (final n in syncTableOrder) _SyncTable(byName[n]!)];
  }

  final AppDatabase _db;
  final int Function() _now;
  late final List<_SyncTable> _tables;

  /// Rows that were pushed this many times and failed are set aside until
  /// the person asks to retry.
  static const maxAttempts = 5;

  // --- meta -------------------------------------------------------------

  Future<String?> meta(String key) async {
    final row = await (_db.select(
      _db.syncMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setMeta(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.syncMeta)..where((t) => t.key.equals(key))).go();
      return;
    }
    await _db
        .into(_db.syncMeta)
        .insertOnConflictUpdate(
          SyncMetaCompanion.insert(key: key, value: value),
        );
  }

  Future<int> get cursor async => int.tryParse(await meta('cursor') ?? '') ?? 0;
  Future<void> setCursor(int v) => setMeta('cursor', '$v');

  // --- push side --------------------------------------------------------

  Future<Set<String>> _parked() async {
    final rows =
        await (_db.select(_db.syncIssues)..where(
              (t) =>
                  t.direction.equals('push') &
                  t.attempts.isBiggerOrEqualValue(maxAttempts),
            ))
            .get();
    return {for (final r in rows) '${r.entity}/${r.rowId}'};
  }

  /// Number of rows still waiting to be sent (not counting parked ones).
  Future<int> pendingCount() async {
    final parked = await _parked();
    var n = 0;
    for (final t in _tables) {
      final rows = await _db
          .customSelect('SELECT id FROM ${t.name} WHERE dirty = 1')
          .get();
      n += rows
          .where((r) => !parked.contains('${t.name}/${r.read<String>('id')}'))
          .length;
    }
    return n;
  }

  Future<int> issueCount() async {
    final c = _db.syncIssues.rowId.count();
    final q = _db.selectOnly(_db.syncIssues)..addColumns([c]);
    final row = await q.getSingle();
    final n = row.read<int>(c);
    return n ?? 0;
  }

  /// Up to [limit] waiting rows, parents before children.
  Future<List<PushItem>> dirtyRows({
    int limit = 200,
    Set<String> skip = const {},
  }) async {
    final parked = await _parked();
    final out = <PushItem>[];
    final now = _now();
    for (final t in _tables) {
      if (out.length >= limit) break;
      final rows = await _db
          .customSelect(
            'SELECT * FROM ${t.name} WHERE dirty = 1 ORDER BY updated_at, id',
          )
          .get();
      for (final r in rows) {
        if (out.length >= limit) break;
        final key = '${t.name}/${r.read<String>('id')}';
        if (parked.contains(key) || skip.contains(key)) continue;
        out.add(PushItem(t.name, _toJson(t, r.data, now)));
      }
    }
    return out;
  }

  Map<String, Object?> _toJson(
    _SyncTable t,
    Map<String, Object?> data,
    int now,
  ) {
    final json = <String, Object?>{};
    for (final c in t.columns) {
      if (c.name == 'dirty') continue;
      final v = data[c.name];
      if (v == null) {
        json[c.name] = null;
      } else if (c.type == DriftSqlType.bool) {
        json[c.name] = v == 1 || v == true;
      } else {
        json[c.name] = v;
      }
    }
    json['updated_at'] = clampUpdatedAt(json['updated_at']! as int, now);
    return json;
  }

  /// Clears the waiting flag, but only if the row was not edited again while
  /// it was on its way (same `rev`).
  Future<void> markPushed(String table, String id, int rev) async {
    await _db.customUpdate(
      'UPDATE $table SET dirty = 0 WHERE id = ? AND rev = ?',
      variables: [Variable<String>(id), Variable<int>(rev)],
      updates: const {},
    );
    await clearIssue(table, id, 'push');
  }

  Future<int?> revOf(String table, String id) async {
    final r = await _db
        .customSelect(
          'SELECT rev FROM $table WHERE id = ?',
          variables: [Variable<String>(id)],
        )
        .getSingleOrNull();
    return r?.read<int>('rev');
  }

  // --- issues -----------------------------------------------------------

  Future<void> recordIssue(
    String table,
    String id,
    String direction,
    String reason,
  ) async {
    final existing =
        await (_db.select(_db.syncIssues)..where(
              (t) =>
                  t.entity.equals(table) &
                  t.rowId.equals(id) &
                  t.direction.equals(direction),
            ))
            .getSingleOrNull();
    await _db
        .into(_db.syncIssues)
        .insertOnConflictUpdate(
          SyncIssuesCompanion.insert(
            entity: table,
            rowId: id,
            direction: direction,
            reason: reason,
            attempts: Value((existing?.attempts ?? 0) + 1),
            at: _now(),
          ),
        );
  }

  Future<void> clearIssue(String table, String id, String direction) =>
      (_db.delete(_db.syncIssues)..where(
            (t) =>
                t.entity.equals(table) &
                t.rowId.equals(id) &
                t.direction.equals(direction),
          ))
          .go();

  Future<List<SyncIssueRow>> issues() => (_db.select(
    _db.syncIssues,
  )..orderBy([(t) => OrderingTerm.desc(t.at)])).get();

  /// Gives every set-aside row another chance.
  Future<void> clearIssues() => _db.delete(_db.syncIssues).go();

  // --- pull side --------------------------------------------------------

  /// Applies rows from the server with last-write-wins on `updated_at`.
  /// Returns what happened; a row that cannot be stored is recorded as an
  /// issue and skipped so the rest still land.
  Future<ApplyResult> applyRemote(
    List<RemoteRow> rows, {
    bool force = false,
  }) async {
    var applied = 0;
    var skipped = 0;
    var failed = 0;
    var touchesRollups = false;
    // Parents may arrive after children within one page.
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      for (final remote in rows) {
        final t = _tables.where((x) => x.name == remote.table).firstOrNull;
        if (t == null) {
          skipped++;
          continue;
        }
        try {
          final done = await _db.transaction(
            () => _applyOne(t, remote.row, force: force),
          );
          if (done) {
            applied++;
            if (_rollupSources.contains(t.name)) touchesRollups = true;
            await clearIssue(t.name, remote.row['id']! as String, 'pull');
          } else {
            skipped++;
          }
        } on Object catch (e) {
          failed++;
          await recordIssue(
            t.name,
            (remote.row['id'] ?? '?').toString(),
            'pull',
            e.toString(),
          );
        }
      }
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
    return ApplyResult(
      applied: applied,
      skipped: skipped,
      failed: failed,
      touchesRollups: touchesRollups,
    );
  }

  Future<bool> _applyOne(
    _SyncTable t,
    Map<String, Object?> remote, {
    required bool force,
  }) async {
    final id = remote['id']! as String;
    final local = await _db
        .customSelect(
          'SELECT updated_at, dirty FROM ${t.name} WHERE id = ?',
          variables: [Variable<String>(id)],
        )
        .getSingleOrNull();
    if (local != null && !force) {
      final dirty = local.read<int>('dirty') == 1;
      final localAt = local.read<int>('updated_at');
      final remoteAt = remote['updated_at']! as int;
      // An edit made here and not sent yet wins if it is newer; it will go
      // up with the next push.
      if (dirty && localAt > remoteAt) return false;
    }
    final cols = [
      for (final c in t.columns)
        if (c.name != 'dirty') c,
    ];
    final values = <Object?>[for (final c in cols) _toSql(c, remote[c.name])];
    final names = cols.map((c) => c.name).join(', ');
    final marks = List.filled(cols.length, '?').join(', ');
    final updates = cols
        .where((c) => c.name != 'id')
        .map((c) => '${c.name} = excluded.${c.name}')
        .join(', ');
    await _db.customStatement(
      'INSERT INTO ${t.name} ($names, dirty) VALUES ($marks, 0) '
      'ON CONFLICT(id) DO UPDATE SET $updates, dirty = 0',
      values,
    );
    return true;
  }

  Object? _toSql(GeneratedColumn<Object> c, Object? v) {
    if (v == null) {
      if (c.$nullable) return null;
      // The server always sends every column, so a hole means a bad row.
      throw FormatException('missing value for ${c.name}');
    }
    if (c.type == DriftSqlType.bool) return (v == true || v == 1) ? 1 : 0;
    if (c.type == DriftSqlType.int && v is num) return v.toInt();
    return v;
  }
}

class ApplyResult {
  const new({
    required this.applied,
    required this.skipped,
    required this.failed,
    required this.touchesRollups,
  });

  final int applied;
  final int skipped;
  final int failed;
  final bool touchesRollups;
}
