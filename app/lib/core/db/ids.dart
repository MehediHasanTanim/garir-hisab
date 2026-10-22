import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Client-generated, time-ordered primary key (UUIDv7) — safe to create
/// offline and index-friendly.
String newId() => _uuid.v7();

/// Current UTC time as epoch milliseconds.
int utcNowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;
