import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/sync/backoff.dart';
import 'package:vehicle_khata/core/sync/sync_server.dart';
import 'package:vehicle_khata/core/sync/sync_store.dart';
import 'package:vehicle_khata/features/reports/data/rollup_service.dart';

enum SyncPhase {
  /// Not signed in, or no server configured: the app works on this phone only.
  disabled,
  idle,
  syncing,

  /// The last attempt failed on the network; a retry is scheduled.
  offline,

  /// The session expired; sign in again.
  signedOut,

  /// This phone holds another account's data.
  wrongAccount,

  /// An unexpected failure; a retry is scheduled.
  error,
}

@immutable
class SyncStatus {
  const new({
    this.phase = SyncPhase.disabled,
    this.pending = 0,
    this.issues = 0,
    this.lastSyncedAt,
    this.lastError,
  });

  final SyncPhase phase;

  /// Rows waiting to be sent.
  final int pending;

  /// Rows that could not be synced and were set aside.
  final int issues;

  /// Epoch milliseconds of the last complete sync.
  final int? lastSyncedAt;
  final String? lastError;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pending,
    int? issues,
    int? lastSyncedAt,
    String? lastError,
    bool clearError = false,
  }) => SyncStatus(
    phase: phase ?? this.phase,
    pending: pending ?? this.pending,
    issues: issues ?? this.issues,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    lastError: clearError ? null : (lastError ?? this.lastError),
  );
}

/// Sends local changes, then fetches the server's, and repeats whenever
/// something changes. Safe to call [syncNow] at any time: calls made while a
/// sync runs share it.
class SyncEngine {
  new({
    required AppDatabase db,
    required this._store,
    required this._server,
    required this._userId,
    int Function()? now,
    this._backoff = const BackoffPolicy(),
    this._random,
    this.debounce = const Duration(seconds: 2),
    this.interval = const Duration(minutes: 5),
    this.batchSize = 200,
    this.pageSize = 500,
    Future<void> Function()? afterPull,
  }) : _db = db,
       _now = now ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch),
       _afterPull = afterPull ?? RollupService(db).rebuildAll;

  final AppDatabase _db;
  final SyncStore _store;
  final SyncServer _server;
  final String? Function() _userId;
  final int Function() _now;
  final BackoffPolicy _backoff;
  final Random? _random;
  final Future<void> Function() _afterPull;
  final Duration debounce;
  final Duration interval;
  final int batchSize;
  final int pageSize;

  final _changes = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = const SyncStatus();
  Future<void>? _inflight;
  StreamSubscription<Object?>? _watch;
  Timer? _debounceTimer;
  Timer? _retryTimer;
  Timer? _periodic;
  int _failures = 0;
  bool _disposed = false;

  SyncStatus get status => _status;
  Stream<SyncStatus> get changes => _changes.stream;

  /// Time until the next automatic retry, if one is scheduled.
  Duration? get retryIn => _retryAt == null
      ? null
      : Duration(milliseconds: max(0, _retryAt! - _now()));
  int? _retryAt;

  /// Starts watching for local changes and syncing on a timer.
  void start() {
    _watch ??= _db
        .tableUpdates()
        .where((u) => u.any((x) => syncTableOrder.contains(x.table)))
        .listen((_) => _scheduleSync());
    _periodic ??= Timer.periodic(interval, (_) => unawaited(syncNow()));
    unawaited(syncNow());
  }

  void _scheduleSync() {
    if (_disposed) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () async {
      if (_disposed) return;
      if (_status.phase == SyncPhase.syncing) return;
      // Writes by the sync itself touch these tables too; only react when
      // there is something to send.
      if (await _store.pendingCount() > 0) await syncNow();
    });
  }

  Future<void> syncNow() {
    if (_disposed) return Future.value();
    return _inflight ??= _run().whenComplete(() => _inflight = null);
  }

  /// Fetches everything from the server again (new phone, or a repair).
  /// Local waiting changes are kept and win if they are newer.
  Future<void> restoreFromServer() async {
    await _store.setCursor(0);
    await _store.clearIssues();
    await syncNow();
  }

  /// Gives set-aside rows another try.
  Future<void> retryStuck() async {
    await _store.clearIssues();
    await syncNow();
  }

  Future<void> _run() async {
    final user = _userId();
    if (user == null) {
      await _emit(phase: SyncPhase.disabled);
      return;
    }
    final owner = await _store.meta('owner');
    if (owner == null) {
      await _store.setMeta('owner', user);
    } else if (owner != user) {
      await _emit(phase: SyncPhase.wrongAccount);
      return;
    }
    _retryTimer?.cancel();
    _retryAt = null;
    await _emit(phase: SyncPhase.syncing, clearError: true);
    try {
      await _pushAll();
      await _pullAll();
      _failures = 0;
      final at = _now();
      await _store.setMeta('last_synced_at', '$at');
      await _emit(phase: SyncPhase.idle, lastSyncedAt: at, clearError: true);
    } on SyncAuthException catch (e) {
      await _emit(phase: SyncPhase.signedOut, lastError: e.toString());
    } on SyncNetworkException catch (e) {
      await _failed(SyncPhase.offline, e.toString());
    } on Object catch (e) {
      await _failed(SyncPhase.error, e.toString());
    }
  }

  Future<void> _failed(SyncPhase phase, String error) async {
    _failures++;
    final wait = _backoff.delay(_failures, _random);
    _retryAt = _now() + wait.inMilliseconds;
    _retryTimer?.cancel();
    if (!_disposed) {
      _retryTimer = Timer(wait, () => unawaited(syncNow()));
    }
    await _emit(phase: phase, lastError: error);
  }

  Future<void> _pushAll() async {
    final tried = <String>{};
    while (true) {
      final items = await _store.dirtyRows(limit: batchSize, skip: tried);
      if (items.isEmpty) return;
      final revs = <String, int>{
        for (final i in items) '${i.table}/${i.id}': i.row['rev']! as int,
      };
      tried.addAll(revs.keys);
      final results = await _server.push(items);
      final byKey = {for (final r in results) '${r.table}/${r.id}': r};
      if (!revs.keys.every(byKey.containsKey)) {
        throw const SyncNetworkException('incomplete response');
      }
      for (final key in revs.keys) {
        final r = byKey[key]!;
        switch (r.status) {
          case PushStatus.accepted:
            await _store.markPushed(r.table, r.id, revs[key]!);
          case PushStatus.conflict:
            // The server has a newer version: it wins, ours is dropped.
            final server = r.serverRow;
            if (server == null) {
              await _store.recordIssue(r.table, r.id, 'push', 'conflict');
            } else {
              await _store.applyRemote([
                RemoteRow(r.table, 0, server),
              ], force: true);
            }
          case PushStatus.rejected:
            await _store.recordIssue(
              r.table,
              r.id,
              'push',
              r.reason ?? 'rejected',
            );
        }
      }
      await _emit();
    }
  }

  Future<void> _pullAll() async {
    var touchesRollups = false;
    while (true) {
      final since = await _store.cursor;
      final page = await _server.pull(since: since, limit: pageSize);
      final result = await _store.applyRemote(page.rows);
      touchesRollups |= result.touchesRollups;
      if (page.cursor > since) await _store.setCursor(page.cursor);
      if (!page.hasMore) break;
      if (page.cursor <= since) {
        throw StateError('server did not advance the cursor');
      }
    }
    if (touchesRollups) await _afterPull();
  }

  Future<void> _emit({
    SyncPhase? phase,
    int? lastSyncedAt,
    String? lastError,
    bool clearError = false,
  }) async {
    if (_disposed) return;
    final last =
        lastSyncedAt ??
        _status.lastSyncedAt ??
        int.tryParse(await _store.meta('last_synced_at') ?? '');
    _status = _status.copyWith(
      phase: phase,
      pending: await _store.pendingCount(),
      issues: await _store.issueCount(),
      lastSyncedAt: last,
      lastError: lastError,
      clearError: clearError,
    );
    if (!_changes.isClosed) _changes.add(_status);
  }

  /// Refreshes the counts shown to the person without syncing.
  Future<void> refreshStatus() =>
      _emit(phase: _userId() == null ? SyncPhase.disabled : null);

  Future<void> dispose() async {
    _disposed = true;
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    _periodic?.cancel();
    await _watch?.cancel();
    await _changes.close();
  }
}
