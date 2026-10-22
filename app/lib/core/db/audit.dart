import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';

/// Changed fields between two snapshots, as `{field: {from, to}}`.
/// Keys in [redact] are recorded as changed without their values.
Map<String, Object?> diffFields(
  Map<String, Object?> before,
  Map<String, Object?> after, {
  Set<String> redact = const {},
}) {
  final out = <String, Object?>{};
  for (final key in {...before.keys, ...after.keys}) {
    if (before[key] == after[key]) continue;
    out[key] = redact.contains(key)
        ? {'changed': true}
        : {'from': before[key], 'to': after[key]};
  }
  return out;
}

extension AuditLogging on AppDatabase {
  /// Writes one audit row. Call inside the same transaction as the change it
  /// describes so the two succeed or fail together.
  Future<void> logAudit({
    required String entity,
    required String entityId,
    required String action,
    Map<String, Object?> diff = const {},
  }) async {
    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        entity: entity,
        entityId: entityId,
        action: action,
        diffJson: Value(jsonEncode(diff)),
      ),
    );
  }
}
