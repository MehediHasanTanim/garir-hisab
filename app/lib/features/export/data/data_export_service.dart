import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/sync/sync_store.dart';

/// Builds a zip with every record the app holds: one JSON file with
/// everything, plus one CSV per table that opens in a spreadsheet.
///
/// Left out on purpose: the national ID (stored encrypted, and it should not
/// leave the phone in a shareable file), the audit log, and derived totals.
class DataExportService {
  new(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  static const _hidden = {'nid_encrypted', 'dirty', 'owner_id'};

  /// Exported tables, in the order they appear in the zip.
  static const tables = syncTableOrder;

  Future<Uint8List> build() async {
    final all = <String, List<Map<String, Object?>>>{};
    for (final t in tables) {
      final rows = await _db
          .customSelect('SELECT * FROM $t ORDER BY created_at, id')
          .get();
      all[t] = [
        for (final r in rows)
          {
            for (final e in r.data.entries)
              if (!_hidden.contains(e.key)) e.key: e.value,
          },
      ];
    }
    final archive = Archive();
    void add(String name, String text) {
      final bytes = utf8.encode(text);
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    add(
      'khata-export.json',
      const JsonEncoder.withIndent('  ').convert({
        'app': 'vehicle_khata',
        'exportedAt': _clock().toUtc().toIso8601String(),
        'note':
            'Amounts are in poisha (100 poisha = 1 taka). Times are epoch '
            'milliseconds (UTC); days are days since 1970-01-01.',
        'tables': all,
      }),
    );
    for (final e in all.entries) {
      if (e.value.isEmpty) continue;
      add('csv/${e.key}.csv', toCsv(e.value));
    }
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  /// RFC 4180 CSV with a UTF-8 byte-order mark so Excel reads Bangla text.
  static String toCsv(List<Map<String, Object?>> rows) {
    final cols = rows.first.keys.toList();
    final b = StringBuffer('﻿')..writeln(cols.map(_cell).join(','));
    for (final r in rows) {
      b.writeln(cols.map((c) => _cell(r[c])).join(','));
    }
    return b.toString();
  }

  static String _cell(Object? v) {
    if (v == null) return '';
    final s = v.toString();
    if (s.contains(',') ||
        s.contains('"') ||
        s.contains('\n') ||
        s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}
