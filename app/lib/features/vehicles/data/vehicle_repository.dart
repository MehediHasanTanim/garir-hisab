import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_rules.dart';

/// Filter for the vehicle list.
@immutable
class VehicleFilter {
  const new({
    this.query = '',
    this.status,
    this.includeArchived = false,
    this.limit = 30,
  });

  final String query;

  /// Null means every status.
  final VehicleStatus? status;
  final bool includeArchived;
  final int limit;

  VehicleFilter copyWith({
    String? query,
    VehicleStatus? Function()? status,
    bool? includeArchived,
    int? limit,
  }) => VehicleFilter(
    query: query ?? this.query,
    status: status == null ? this.status : status(),
    includeArchived: includeArchived ?? this.includeArchived,
    limit: limit ?? this.limit,
  );

  @override
  bool operator ==(Object other) =>
      other is VehicleFilter &&
      other.query == query &&
      other.status == status &&
      other.includeArchived == includeArchived &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(query, status, includeArchived, limit);
}

class VehicleRepository {
  new(this._db);

  final AppDatabase _db;

  /// Live list, newest first, excluding deleted rows.
  Stream<List<Vehicle>> watch(VehicleFilter filter) {
    final q = _db.select(_db.vehicles)
      ..where((t) {
        var cond = t.deletedAt.isNull();
        if (!filter.includeArchived) {
          cond = cond & t.archived.equals(false);
        }
        if (filter.status != null) {
          cond = cond & t.status.equalsValue(filter.status);
        }
        final text = VehicleRules.cleanText(filter.query).toLowerCase();
        if (text.isNotEmpty) {
          final like = '%${_escapeLike(text)}%';
          final key = VehicleRules.regNoKey(text);
          cond =
              cond &
              (t.nickname.lower().like(like, escapeChar: r'\') |
                  t.regNo.lower().like(like, escapeChar: r'\') |
                  t.model.lower().like(like, escapeChar: r'\') |
                  (key == null
                      ? const Constant(false)
                      : t.regNoKey.like(
                          '%${_escapeLike(key)}%',
                          escapeChar: r'\',
                        )));
        }
        return cond;
      })
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(filter.limit);
    return q.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Stream<Vehicle?> watchOne(String id) {
    final q = _db.select(_db.vehicles)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return q.watchSingleOrNull().map((r) => r == null ? null : _toDomain(r));
  }

  Future<Vehicle?> get(String id) async {
    final row = await (_db.select(
      _db.vehicles,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<int> countActive() async {
    final count = _db.vehicles.id.count();
    final q = _db.selectOnly(_db.vehicles)
      ..addColumns([count])
      ..where(_db.vehicles.deletedAt.isNull());
    final row = await q.getSingle();
    final total = row.read(count);
    return total ?? 0;
  }

  Future<String> create(VehicleDraft draft) {
    return _db.transaction(() async {
      final id = newId();
      await _db.into(_db.vehicles).insert(_companion(draft, id: id));
      await _db.logAudit(
        entity: 'vehicle',
        entityId: id,
        action: 'create',
        diff: {'nickname': VehicleRules.cleanText(draft.nickname)},
      );
      return id;
    });
  }

  Future<void> update(String id, VehicleDraft draft) {
    return _db.transaction(() async {
      final before = await get(id);
      await (_db.update(
        _db.vehicles,
      )..where((t) => t.id.equals(id))).write(_companion(draft));
      await _db.touch(_db.vehicles, id);
      await _db.logAudit(
        entity: 'vehicle',
        entityId: id,
        action: 'update',
        diff: before == null
            ? const {}
            : diffFields(
                _snapshot(VehicleDraft.fromVehicle(before)),
                _snapshot(draft),
              ),
      );
    });
  }

  Future<void> setStatus(String id, VehicleStatus status) {
    return _db.transaction(() async {
      await (_db.update(_db.vehicles)..where((t) => t.id.equals(id))).write(
        VehiclesCompanion(status: Value(status)),
      );
      await _db.touch(_db.vehicles, id);
      await _db.logAudit(
        entity: 'vehicle',
        entityId: id,
        action: 'status',
        diff: {'status': status.name},
      );
    });
  }

  Future<void> setArchived(String id, {required bool archived}) {
    return _db.transaction(() async {
      await (_db.update(_db.vehicles)..where((t) => t.id.equals(id))).write(
        VehiclesCompanion(archived: Value(archived)),
      );
      await _db.touch(_db.vehicles, id);
      await _db.logAudit(
        entity: 'vehicle',
        entityId: id,
        action: archived ? 'archive' : 'restore',
      );
    });
  }

  Map<String, Object?> _snapshot(VehicleDraft d) => {
    'nickname': VehicleRules.cleanText(d.nickname),
    'type': d.type.name,
    'regNo': VehicleRules.cleanRegNo(d.regNo),
    'model': _nullIfBlank(d.model),
    'year': d.year,
    'fuelType': d.fuelType.name,
    'businessModel': d.businessModel.name,
    'status': d.status.name,
    'photoFile': d.photoFile,
    'purchaseDate': d.purchaseDate?.toUtc().toIso8601String(),
    'purchasePriceMinor': d.purchasePrice?.minor,
  };

  /// Another (non-deleted) vehicle with the same registration number, if any.
  Future<Vehicle?> findByRegNo(String? regNo, {String? excludingId}) async {
    final key = VehicleRules.regNoKey(regNo);
    if (key == null) return null;
    final q = _db.select(_db.vehicles)
      ..where((t) {
        var cond = t.regNoKey.equals(key) & t.deletedAt.isNull();
        if (excludingId != null) cond = cond & t.id.equals(excludingId).not();
        return cond;
      })
      ..limit(1);
    final row = await q.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  VehiclesCompanion _companion(VehicleDraft d, {String? id}) {
    final regNo = VehicleRules.cleanRegNo(d.regNo);
    return VehiclesCompanion(
      id: id == null ? const Value.absent() : Value(id),
      nickname: Value(VehicleRules.cleanText(d.nickname)),
      type: Value(d.type),
      regNo: Value(regNo),
      regNoKey: Value(VehicleRules.regNoKey(regNo)),
      model: Value(_nullIfBlank(d.model)),
      year: Value(d.year),
      fuelType: Value(d.fuelType),
      businessModel: Value(d.businessModel),
      status: Value(d.status),
      photoFile: Value(d.photoFile),
      purchaseDate: Value(d.purchaseDate?.toUtc().millisecondsSinceEpoch),
      purchasePriceMinor: Value(d.purchasePrice?.minor),
    );
  }

  Vehicle _toDomain(VehicleRow r) => Vehicle(
    id: r.id,
    nickname: r.nickname,
    type: r.type,
    fuelType: r.fuelType,
    businessModel: r.businessModel,
    status: r.status,
    archived: r.archived,
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true),
    regNo: r.regNo,
    model: r.model,
    year: r.year,
    photoFile: r.photoFile,
    purchaseDate: r.purchaseDate == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(r.purchaseDate!, isUtc: true),
    purchasePrice: r.purchasePriceMinor == null
        ? null
        : Money(r.purchasePriceMinor!),
  );

  static String? _nullIfBlank(String? s) {
    final cleaned = s == null ? '' : VehicleRules.cleanText(s);
    return cleaned.isEmpty ? null : cleaned;
  }

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
