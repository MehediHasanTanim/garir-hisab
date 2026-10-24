import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:vehicle_khata/core/sync/sync_server.dart';

/// Talks to the `sync_push` / `sync_pull` functions (see
/// `backend/supabase/migrations/*_sync_rpc.sql`).
class SupabaseSyncServer implements SyncServer {
  new(this._client, {this.timeout = const Duration(seconds: 30)});

  final sb.SupabaseClient _client;
  final Duration timeout;

  @override
  Future<List<PushResult>> push(List<PushItem> items) async {
    final data = await _call('sync_push', {
      'rows': [
        for (final i in items) {'t': i.table, 'row': i.row},
      ],
    });
    if (data is! List) throw const SyncNetworkException('bad push response');
    return [
      for (final r in data.cast<Map<String, dynamic>>())
        PushResult(
          table: r['t'] as String,
          id: r['id'] as String,
          status: switch (r['status']) {
            'accepted' => PushStatus.accepted,
            'conflict' => PushStatus.conflict,
            _ => PushStatus.rejected,
          },
          serverRow: (r['row'] as Map<String, dynamic>?)
              ?.cast<String, Object?>(),
          reason: r['reason'] as String?,
        ),
    ];
  }

  @override
  Future<PullPage> pull({required int since, int limit = 500}) async {
    final data = await _call('sync_pull', {'since': since, 'lim': limit});
    if (data is! Map<String, dynamic>) {
      throw const SyncNetworkException('bad pull response');
    }
    return PullPage(
      rows: [
        for (final r
            in (data['rows'] as List<dynamic>).cast<Map<String, dynamic>>())
          RemoteRow(
            r['t'] as String,
            (r['seq'] as num).toInt(),
            (r['row'] as Map<String, dynamic>).cast<String, Object?>(),
          ),
      ],
      cursor: (data['cursor'] as num).toInt(),
      hasMore: data['has_more'] as bool,
    );
  }

  Future<Object?> _call(String fn, Map<String, Object?> params) async {
    try {
      return await _client.rpc<Object?>(fn, params: params).timeout(timeout);
    } on sb.PostgrestException catch (e) {
      // 28000: our "not signed in"; PGRST301/303: the token is missing or bad.
      if (e.code == '28000' || e.code == 'PGRST301' || e.code == 'PGRST303') {
        throw SyncAuthException(e.message);
      }
      throw SyncNetworkException('${e.code}: ${e.message}');
    } on sb.AuthException catch (e) {
      throw SyncAuthException(e.message);
    } on SocketException catch (e) {
      throw SyncNetworkException(e.message);
    } on TimeoutException {
      throw const SyncNetworkException('timed out');
    } on HttpException catch (e) {
      throw SyncNetworkException(e.message);
    }
  }
}
