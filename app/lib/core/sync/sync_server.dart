import 'package:meta/meta.dart';

/// One row on its way to the server.
@immutable
class PushItem {
  const new(this.table, this.row);

  final String table;

  /// Column name -> JSON value, already in the server's shape.
  final Map<String, Object?> row;

  String get id => row['id']! as String;
}

enum PushStatus { accepted, conflict, rejected }

@immutable
class PushResult {
  const new({
    required this.table,
    required this.id,
    required this.status,
    this.serverRow,
    this.reason,
  });

  final String table;
  final String id;
  final PushStatus status;

  /// The server's copy, when [status] is [PushStatus.conflict].
  final Map<String, Object?>? serverRow;
  final String? reason;
}

@immutable
class RemoteRow {
  const new(this.table, this.seq, this.row);

  final String table;
  final int seq;
  final Map<String, Object?> row;
}

@immutable
class PullPage {
  const new({required this.rows, required this.cursor, required this.hasMore});

  final List<RemoteRow> rows;

  /// Pass this as `since` for the next page.
  final int cursor;
  final bool hasMore;
}

/// The network is unreachable or the server failed; try again later.
class SyncNetworkException implements Exception {
  const new([this.message]);

  final String? message;

  @override
  String toString() => 'SyncNetworkException($message)';
}

/// The session is missing or expired; the person has to sign in again.
class SyncAuthException implements Exception {
  const new([this.message]);

  final String? message;

  @override
  String toString() => 'SyncAuthException($message)';
}

abstract interface class SyncServer {
  /// Results come back in the order of [items].
  Future<List<PushResult>> push(List<PushItem> items);

  Future<PullPage> pull({required int since, int limit = 500});
}
