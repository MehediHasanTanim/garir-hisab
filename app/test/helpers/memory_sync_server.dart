import 'package:vehicle_khata/core/sync/backoff.dart';
import 'package:vehicle_khata/core/sync/sync_server.dart';

/// A stand-in for the Supabase functions with the same rules as
/// `sync_push` / `sync_pull`, plus switches to break it on purpose.
class MemorySyncServer implements SyncServer {
  new({this.userId = 'user-1', int Function()? now})
    : _now = now ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);

  final String userId;
  final int Function() _now;

  final Map<String, Map<String, Map<String, Object?>>> _tables = {};
  int _seq = 0;

  // --- fault injection --------------------------------------------------

  /// Errors thrown by the next calls, one per call, before anything happens.
  final List<Exception> failNext = [];

  /// The next push is stored but the answer is lost on the way back.
  bool loseNextPushResponse = false;

  /// Rows with these ids are rejected.
  final Set<String> rejectIds = {};

  /// Calls made, for assertions.
  int pushCalls = 0;
  int pullCalls = 0;
  final List<int> pushBatchSizes = [];

  Map<String, Object?>? row(String table, String id) => _tables[table]?[id];

  int count(String table) => _tables[table]?.length ?? 0;

  /// Changes a stored row as if another device had pushed it.
  void put(String table, Map<String, Object?> row) {
    final copy = Map<String, Object?>.of(row)
      ..['owner_id'] = userId
      ..['server_seq'] = ++_seq;
    (_tables[table] ??= {})[row['id']! as String] = copy;
  }

  void _maybeFail() {
    if (failNext.isNotEmpty) throw failNext.removeAt(0);
  }

  @override
  Future<List<PushResult>> push(List<PushItem> items) async {
    pushCalls++;
    pushBatchSizes.add(items.length);
    _maybeFail();
    final out = <PushResult>[];
    for (final item in items) {
      final id = item.id;
      if (rejectIds.contains(id)) {
        out.add(
          PushResult(
            table: item.table,
            id: id,
            status: PushStatus.rejected,
            reason: 'rejected for test',
          ),
        );
        continue;
      }
      final existing = _tables[item.table]?[id];
      final at = clampUpdatedAt(item.row['updated_at']! as int, _now());
      if (existing != null && (existing['updated_at']! as int) > at) {
        out.add(
          PushResult(
            table: item.table,
            id: id,
            status: PushStatus.conflict,
            serverRow: Map.of(existing),
          ),
        );
        continue;
      }
      final stored = Map<String, Object?>.of(item.row)
        ..['updated_at'] = at
        ..['owner_id'] = userId
        ..['server_seq'] = ++_seq;
      (_tables[item.table] ??= {})[id] = stored;
      out.add(
        PushResult(table: item.table, id: id, status: PushStatus.accepted),
      );
    }
    if (loseNextPushResponse) {
      loseNextPushResponse = false;
      throw const SyncNetworkException('connection dropped');
    }
    return out;
  }

  @override
  Future<PullPage> pull({required int since, int limit = 500}) async {
    pullCalls++;
    _maybeFail();
    final all = <RemoteRow>[
      for (final e in _tables.entries)
        for (final r in e.value.values)
          if ((r['server_seq']! as int) > since)
            RemoteRow(e.key, r['server_seq']! as int, Map.of(r)),
    ]..sort((a, b) => a.seq.compareTo(b.seq));
    final page = all.take(limit).toList();
    return PullPage(
      rows: page,
      cursor: page.isEmpty ? since : page.last.seq,
      hasMore: all.length > page.length,
    );
  }
}
