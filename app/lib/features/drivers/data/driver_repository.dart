import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/field_cipher.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/driver_rules.dart';

@immutable
class DriverFilter {
  const new({this.query = '', this.status, this.limit = 30});

  final String query;

  /// Null means every status.
  final DriverStatus? status;
  final int limit;

  DriverFilter copyWith({
    String? query,
    DriverStatus? Function()? status,
    int? limit,
  }) => DriverFilter(
    query: query ?? this.query,
    status: status == null ? this.status : status(),
    limit: limit ?? this.limit,
  );

  @override
  bool operator ==(Object other) =>
      other is DriverFilter &&
      other.query == query &&
      other.status == status &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(query, status, limit);
}

class DriverRepository {
  new(this._db, this._cipher);

  final AppDatabase _db;
  final FieldCipher _cipher;

  Stream<List<Driver>> watch(DriverFilter filter) {
    final q = _db.select(_db.drivers)
      ..where((t) {
        var cond = t.deletedAt.isNull();
        if (filter.status != null) {
          cond = cond & t.status.equalsValue(filter.status);
        }
        final text = DriverRules.clean(filter.query).toLowerCase();
        if (text.isNotEmpty) {
          final like = '%${_escapeLike(text)}%';
          var match = t.name.lower().like(like, escapeChar: r'\');
          match = match | t.licenseNo.lower().like(like, escapeChar: r'\');
          final digits = _phoneDigits(text);
          if (digits.length >= 3) {
            match =
                match |
                t.phone.like('%${_escapeLike(digits)}%', escapeChar: r'\');
          }
          cond = cond & match;
        }
        return cond;
      })
      ..orderBy([
        (t) => OrderingTerm.asc(t.name),
        (t) => OrderingTerm.asc(t.id),
      ])
      ..limit(filter.limit);
    return q.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Stream<Driver?> watchOne(String id) {
    final q = _db.select(_db.drivers)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return q.watchSingleOrNull().map((r) => r == null ? null : _toDomain(r));
  }

  /// A driver with the national ID decrypted (for editing).
  Future<Driver?> get(String id) async {
    final row = await _row(id);
    if (row == null) return null;
    final nid = row.nidEncrypted == null
        ? null
        : await _cipher.decrypt(row.nidEncrypted!);
    return _toDomain(row, nid: nid);
  }

  Future<String> create(DriverDraft draft) async {
    final id = newId();
    final nidEncrypted = await _encryptNid(draft.nid);
    await _db.transaction(() async {
      await _db
          .into(_db.drivers)
          .insert(_companion(draft, nidEncrypted, id: id));
      await _db.logAudit(
        entity: 'driver',
        entityId: id,
        action: 'create',
        diff: {'name': DriverRules.clean(draft.name)},
      );
    });
    return id;
  }

  Future<void> update(String id, DriverDraft draft) async {
    final nidEncrypted = await _encryptNid(draft.nid);
    final existing = await get(id);
    if (existing == null) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.drivers,
      )..where((t) => t.id.equals(id))).write(_companion(draft, nidEncrypted));
      await _db.touch(_db.drivers, id);
      await _db.logAudit(
        entity: 'driver',
        entityId: id,
        action: 'update',
        diff: diffFields(
          _snapshot(DriverDraft.fromDriver(existing)),
          _snapshot(draft),
          redact: {'nid'},
        ),
      );
    });
  }

  Future<void> setStatus(String id, DriverStatus status) async {
    await _db.transaction(() async {
      await (_db.update(_db.drivers)..where((t) => t.id.equals(id))).write(
        DriversCompanion(status: Value(status)),
      );
      await _db.touch(_db.drivers, id);
      await _db.logAudit(
        entity: 'driver',
        entityId: id,
        action: 'status',
        diff: {'status': status.name},
      );
    });
  }

  Future<DriverRow?> _row(String id) => (_db.select(
    _db.drivers,
  )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  Future<String?> _encryptNid(String? nid) async {
    final normalized = DriverRules.normalizeNid(nid);
    if (normalized == null) return null;
    return await _cipher.encrypt(normalized);
  }

  DriversCompanion _companion(
    DriverDraft d,
    String? nidEncrypted, {
    String? id,
  }) => DriversCompanion(
    id: id == null ? const Value.absent() : Value(id),
    name: Value(DriverRules.clean(d.name)),
    phone: Value(DriverRules.normalizePhone(d.phone)),
    licenseNo: Value(DriverRules.blankToNull(d.licenseNo)),
    licenseExpiry: Value(d.licenseExpiry?.epochDay),
    nidEncrypted: Value(nidEncrypted),
    address: Value(DriverRules.blankToNull(d.address)),
    emergencyContact: Value(DriverRules.blankToNull(d.emergencyContact)),
    joinDay: Value(d.joinDate?.epochDay),
    photoFile: Value(d.photoFile),
    status: Value(d.status),
  );

  Map<String, Object?> _snapshot(DriverDraft d) => {
    'name': DriverRules.clean(d.name),
    'phone': DriverRules.normalizePhone(d.phone),
    'licenseNo': DriverRules.blankToNull(d.licenseNo),
    'licenseExpiry': d.licenseExpiry?.toIso(),
    'nid': DriverRules.normalizeNid(d.nid),
    'address': DriverRules.blankToNull(d.address),
    'emergencyContact': DriverRules.blankToNull(d.emergencyContact),
    'joinDate': d.joinDate?.toIso(),
    'photoFile': d.photoFile,
    'status': d.status.name,
  };

  Driver _toDomain(DriverRow r, {String? nid}) => Driver(
    id: r.id,
    name: r.name,
    status: r.status,
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true),
    phone: r.phone,
    licenseNo: r.licenseNo,
    licenseExpiry: r.licenseExpiry == null
        ? null
        : CalendarDay(r.licenseExpiry!),
    hasNid: r.nidEncrypted != null,
    nid: nid,
    address: r.address,
    emergencyContact: r.emergencyContact,
    joinDate: r.joinDay == null ? null : CalendarDay(r.joinDay!),
    photoFile: r.photoFile,
  );

  static String _phoneDigits(String s) {
    const bangla = '০১২৩৪৫৬৭৮৯';
    final out = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      final i = bangla.indexOf(ch);
      if (i >= 0) {
        out.write(i);
      } else if (RegExp('[0-9]').hasMatch(ch)) {
        out.write(ch);
      }
    }
    return out.toString().replaceFirst(RegExp('^(880|0)'), '');
  }

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
