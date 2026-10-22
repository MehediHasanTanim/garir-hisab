// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diffJsonMeta = const VerificationMeta(
    'diffJson',
  );
  @override
  late final GeneratedColumn<String> diffJson = GeneratedColumn<String>(
    'diff_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    entity,
    entityId,
    action,
    diffJson,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('diff_json')) {
      context.handle(
        _diffJsonMeta,
        diffJson.isAcceptableOrUnknown(data['diff_json']!, _diffJsonMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      diffJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diff_json'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;

  /// Tenant key. `local` until the user signs in and the data is claimed.
  final String ownerId;

  /// Epoch milliseconds, UTC.
  final int createdAt;
  final int updatedAt;

  /// Tombstone; non-null means soft-deleted.
  final int? deletedAt;

  /// Local monotonic revision, bumped on every write.
  final int rev;

  /// True while the row has changes not yet pushed.
  final bool dirty;
  final String entity;
  final String entityId;
  final String action;
  final String diffJson;
  final int at;
  const AuditLog({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.dirty,
    required this.entity,
    required this.entityId,
    required this.action,
    required this.diffJson,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['dirty'] = Variable<bool>(dirty);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['diff_json'] = Variable<String>(diffJson);
    map['at'] = Variable<int>(at);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      dirty: Value(dirty),
      entity: Value(entity),
      entityId: Value(entityId),
      action: Value(action),
      diffJson: Value(diffJson),
      at: Value(at),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      diffJson: serializer.fromJson<String>(json['diffJson']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'dirty': serializer.toJson<bool>(dirty),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'diffJson': serializer.toJson<String>(diffJson),
      'at': serializer.toJson<int>(at),
    };
  }

  AuditLog copyWith({
    String? id,
    String? ownerId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    bool? dirty,
    String? entity,
    String? entityId,
    String? action,
    String? diffJson,
    int? at,
  }) => AuditLog(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    dirty: dirty ?? this.dirty,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    diffJson: diffJson ?? this.diffJson,
    at: at ?? this.at,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      diffJson: data.diffJson.present ? data.diffJson.value : this.diffJson,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('diffJson: $diffJson, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    entity,
    entityId,
    action,
    diffJson,
    at,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.dirty == this.dirty &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.diffJson == this.diffJson &&
          other.at == this.at);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<bool> dirty;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> diffJson;
  final Value<int> at;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.diffJson = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    required String entity,
    required String entityId,
    required String action,
    this.diffJson = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       entityId = Value(entityId),
       action = Value(action);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<bool>? dirty,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? diffJson,
    Expression<int>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (dirty != null) 'dirty': dirty,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (diffJson != null) 'diff_json': diffJson,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<bool>? dirty,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? action,
    Value<String>? diffJson,
    Value<int>? at,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      dirty: dirty ?? this.dirty,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      diffJson: diffJson ?? this.diffJson,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (diffJson.present) {
      map['diff_json'] = Variable<String>(diffJson.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('diffJson: $diffJson, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles
    with TableInfo<$VehiclesTable, VehicleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<VehicleType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<VehicleType>($VehiclesTable.$convertertype);
  static const VerificationMeta _regNoMeta = const VerificationMeta('regNo');
  @override
  late final GeneratedColumn<String> regNo = GeneratedColumn<String>(
    'reg_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regNoKeyMeta = const VerificationMeta(
    'regNoKey',
  );
  @override
  late final GeneratedColumn<String> regNoKey = GeneratedColumn<String>(
    'reg_no_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FuelType, String> fuelType =
      GeneratedColumn<String>(
        'fuel_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FuelType>($VehiclesTable.$converterfuelType);
  @override
  late final GeneratedColumnWithTypeConverter<BusinessModel, String>
  businessModel = GeneratedColumn<String>(
    'business_model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<BusinessModel>($VehiclesTable.$converterbusinessModel);
  @override
  late final GeneratedColumnWithTypeConverter<VehicleStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('active'),
      ).withConverter<VehicleStatus>($VehiclesTable.$converterstatus);
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _photoFileMeta = const VerificationMeta(
    'photoFile',
  );
  @override
  late final GeneratedColumn<String> photoFile = GeneratedColumn<String>(
    'photo_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<int> purchaseDate = GeneratedColumn<int>(
    'purchase_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasePriceMinorMeta =
      const VerificationMeta('purchasePriceMinor');
  @override
  late final GeneratedColumn<int> purchasePriceMinor = GeneratedColumn<int>(
    'purchase_price_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    nickname,
    type,
    regNo,
    regNoKey,
    model,
    year,
    fuelType,
    businessModel,
    status,
    archived,
    photoFile,
    purchaseDate,
    purchasePriceMinor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('reg_no')) {
      context.handle(
        _regNoMeta,
        regNo.isAcceptableOrUnknown(data['reg_no']!, _regNoMeta),
      );
    }
    if (data.containsKey('reg_no_key')) {
      context.handle(
        _regNoKeyMeta,
        regNoKey.isAcceptableOrUnknown(data['reg_no_key']!, _regNoKeyMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('photo_file')) {
      context.handle(
        _photoFileMeta,
        photoFile.isAcceptableOrUnknown(data['photo_file']!, _photoFileMeta),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('purchase_price_minor')) {
      context.handle(
        _purchasePriceMinorMeta,
        purchasePriceMinor.isAcceptableOrUnknown(
          data['purchase_price_minor']!,
          _purchasePriceMinorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      type: $VehiclesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      regNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reg_no'],
      ),
      regNoKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reg_no_key'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      fuelType: $VehiclesTable.$converterfuelType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fuel_type'],
        )!,
      ),
      businessModel: $VehiclesTable.$converterbusinessModel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}business_model'],
        )!,
      ),
      status: $VehiclesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      photoFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_file'],
      ),
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_date'],
      ),
      purchasePriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_price_minor'],
      ),
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<VehicleType, String, String> $convertertype =
      const EnumNameConverter<VehicleType>(VehicleType.values);
  static JsonTypeConverter2<FuelType, String, String> $converterfuelType =
      const EnumNameConverter<FuelType>(FuelType.values);
  static JsonTypeConverter2<BusinessModel, String, String>
  $converterbusinessModel = const EnumNameConverter<BusinessModel>(
    BusinessModel.values,
  );
  static JsonTypeConverter2<VehicleStatus, String, String> $converterstatus =
      const EnumNameConverter<VehicleStatus>(VehicleStatus.values);
}

class VehicleRow extends DataClass implements Insertable<VehicleRow> {
  final String id;

  /// Tenant key. `local` until the user signs in and the data is claimed.
  final String ownerId;

  /// Epoch milliseconds, UTC.
  final int createdAt;
  final int updatedAt;

  /// Tombstone; non-null means soft-deleted.
  final int? deletedAt;

  /// Local monotonic revision, bumped on every write.
  final int rev;

  /// True while the row has changes not yet pushed.
  final bool dirty;
  final String nickname;
  final VehicleType type;
  final String? regNo;

  /// Normalised registration number used for duplicate detection.
  final String? regNoKey;
  final String? model;
  final int? year;
  final FuelType fuelType;
  final BusinessModel businessModel;
  final VehicleStatus status;
  final bool archived;
  final String? photoFile;
  final int? purchaseDate;
  final int? purchasePriceMinor;
  const VehicleRow({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.dirty,
    required this.nickname,
    required this.type,
    this.regNo,
    this.regNoKey,
    this.model,
    this.year,
    required this.fuelType,
    required this.businessModel,
    required this.status,
    required this.archived,
    this.photoFile,
    this.purchaseDate,
    this.purchasePriceMinor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['dirty'] = Variable<bool>(dirty);
    map['nickname'] = Variable<String>(nickname);
    {
      map['type'] = Variable<String>($VehiclesTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || regNo != null) {
      map['reg_no'] = Variable<String>(regNo);
    }
    if (!nullToAbsent || regNoKey != null) {
      map['reg_no_key'] = Variable<String>(regNoKey);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    {
      map['fuel_type'] = Variable<String>(
        $VehiclesTable.$converterfuelType.toSql(fuelType),
      );
    }
    {
      map['business_model'] = Variable<String>(
        $VehiclesTable.$converterbusinessModel.toSql(businessModel),
      );
    }
    {
      map['status'] = Variable<String>(
        $VehiclesTable.$converterstatus.toSql(status),
      );
    }
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || photoFile != null) {
      map['photo_file'] = Variable<String>(photoFile);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<int>(purchaseDate);
    }
    if (!nullToAbsent || purchasePriceMinor != null) {
      map['purchase_price_minor'] = Variable<int>(purchasePriceMinor);
    }
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      dirty: Value(dirty),
      nickname: Value(nickname),
      type: Value(type),
      regNo: regNo == null && nullToAbsent
          ? const Value.absent()
          : Value(regNo),
      regNoKey: regNoKey == null && nullToAbsent
          ? const Value.absent()
          : Value(regNoKey),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      fuelType: Value(fuelType),
      businessModel: Value(businessModel),
      status: Value(status),
      archived: Value(archived),
      photoFile: photoFile == null && nullToAbsent
          ? const Value.absent()
          : Value(photoFile),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      purchasePriceMinor: purchasePriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePriceMinor),
    );
  }

  factory VehicleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      nickname: serializer.fromJson<String>(json['nickname']),
      type: $VehiclesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      regNo: serializer.fromJson<String?>(json['regNo']),
      regNoKey: serializer.fromJson<String?>(json['regNoKey']),
      model: serializer.fromJson<String?>(json['model']),
      year: serializer.fromJson<int?>(json['year']),
      fuelType: $VehiclesTable.$converterfuelType.fromJson(
        serializer.fromJson<String>(json['fuelType']),
      ),
      businessModel: $VehiclesTable.$converterbusinessModel.fromJson(
        serializer.fromJson<String>(json['businessModel']),
      ),
      status: $VehiclesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      archived: serializer.fromJson<bool>(json['archived']),
      photoFile: serializer.fromJson<String?>(json['photoFile']),
      purchaseDate: serializer.fromJson<int?>(json['purchaseDate']),
      purchasePriceMinor: serializer.fromJson<int?>(json['purchasePriceMinor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'dirty': serializer.toJson<bool>(dirty),
      'nickname': serializer.toJson<String>(nickname),
      'type': serializer.toJson<String>(
        $VehiclesTable.$convertertype.toJson(type),
      ),
      'regNo': serializer.toJson<String?>(regNo),
      'regNoKey': serializer.toJson<String?>(regNoKey),
      'model': serializer.toJson<String?>(model),
      'year': serializer.toJson<int?>(year),
      'fuelType': serializer.toJson<String>(
        $VehiclesTable.$converterfuelType.toJson(fuelType),
      ),
      'businessModel': serializer.toJson<String>(
        $VehiclesTable.$converterbusinessModel.toJson(businessModel),
      ),
      'status': serializer.toJson<String>(
        $VehiclesTable.$converterstatus.toJson(status),
      ),
      'archived': serializer.toJson<bool>(archived),
      'photoFile': serializer.toJson<String?>(photoFile),
      'purchaseDate': serializer.toJson<int?>(purchaseDate),
      'purchasePriceMinor': serializer.toJson<int?>(purchasePriceMinor),
    };
  }

  VehicleRow copyWith({
    String? id,
    String? ownerId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    bool? dirty,
    String? nickname,
    VehicleType? type,
    Value<String?> regNo = const Value.absent(),
    Value<String?> regNoKey = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<int?> year = const Value.absent(),
    FuelType? fuelType,
    BusinessModel? businessModel,
    VehicleStatus? status,
    bool? archived,
    Value<String?> photoFile = const Value.absent(),
    Value<int?> purchaseDate = const Value.absent(),
    Value<int?> purchasePriceMinor = const Value.absent(),
  }) => VehicleRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    dirty: dirty ?? this.dirty,
    nickname: nickname ?? this.nickname,
    type: type ?? this.type,
    regNo: regNo.present ? regNo.value : this.regNo,
    regNoKey: regNoKey.present ? regNoKey.value : this.regNoKey,
    model: model.present ? model.value : this.model,
    year: year.present ? year.value : this.year,
    fuelType: fuelType ?? this.fuelType,
    businessModel: businessModel ?? this.businessModel,
    status: status ?? this.status,
    archived: archived ?? this.archived,
    photoFile: photoFile.present ? photoFile.value : this.photoFile,
    purchaseDate: purchaseDate.present ? purchaseDate.value : this.purchaseDate,
    purchasePriceMinor: purchasePriceMinor.present
        ? purchasePriceMinor.value
        : this.purchasePriceMinor,
  );
  VehicleRow copyWithCompanion(VehiclesCompanion data) {
    return VehicleRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      type: data.type.present ? data.type.value : this.type,
      regNo: data.regNo.present ? data.regNo.value : this.regNo,
      regNoKey: data.regNoKey.present ? data.regNoKey.value : this.regNoKey,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      businessModel: data.businessModel.present
          ? data.businessModel.value
          : this.businessModel,
      status: data.status.present ? data.status.value : this.status,
      archived: data.archived.present ? data.archived.value : this.archived,
      photoFile: data.photoFile.present ? data.photoFile.value : this.photoFile,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      purchasePriceMinor: data.purchasePriceMinor.present
          ? data.purchasePriceMinor.value
          : this.purchasePriceMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('nickname: $nickname, ')
          ..write('type: $type, ')
          ..write('regNo: $regNo, ')
          ..write('regNoKey: $regNoKey, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('fuelType: $fuelType, ')
          ..write('businessModel: $businessModel, ')
          ..write('status: $status, ')
          ..write('archived: $archived, ')
          ..write('photoFile: $photoFile, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchasePriceMinor: $purchasePriceMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    nickname,
    type,
    regNo,
    regNoKey,
    model,
    year,
    fuelType,
    businessModel,
    status,
    archived,
    photoFile,
    purchaseDate,
    purchasePriceMinor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.dirty == this.dirty &&
          other.nickname == this.nickname &&
          other.type == this.type &&
          other.regNo == this.regNo &&
          other.regNoKey == this.regNoKey &&
          other.model == this.model &&
          other.year == this.year &&
          other.fuelType == this.fuelType &&
          other.businessModel == this.businessModel &&
          other.status == this.status &&
          other.archived == this.archived &&
          other.photoFile == this.photoFile &&
          other.purchaseDate == this.purchaseDate &&
          other.purchasePriceMinor == this.purchasePriceMinor);
}

class VehiclesCompanion extends UpdateCompanion<VehicleRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<bool> dirty;
  final Value<String> nickname;
  final Value<VehicleType> type;
  final Value<String?> regNo;
  final Value<String?> regNoKey;
  final Value<String?> model;
  final Value<int?> year;
  final Value<FuelType> fuelType;
  final Value<BusinessModel> businessModel;
  final Value<VehicleStatus> status;
  final Value<bool> archived;
  final Value<String?> photoFile;
  final Value<int?> purchaseDate;
  final Value<int?> purchasePriceMinor;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    this.nickname = const Value.absent(),
    this.type = const Value.absent(),
    this.regNo = const Value.absent(),
    this.regNoKey = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.businessModel = const Value.absent(),
    this.status = const Value.absent(),
    this.archived = const Value.absent(),
    this.photoFile = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchasePriceMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    required String nickname,
    required VehicleType type,
    this.regNo = const Value.absent(),
    this.regNoKey = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    required FuelType fuelType,
    required BusinessModel businessModel,
    this.status = const Value.absent(),
    this.archived = const Value.absent(),
    this.photoFile = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchasePriceMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nickname = Value(nickname),
       type = Value(type),
       fuelType = Value(fuelType),
       businessModel = Value(businessModel);
  static Insertable<VehicleRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<bool>? dirty,
    Expression<String>? nickname,
    Expression<String>? type,
    Expression<String>? regNo,
    Expression<String>? regNoKey,
    Expression<String>? model,
    Expression<int>? year,
    Expression<String>? fuelType,
    Expression<String>? businessModel,
    Expression<String>? status,
    Expression<bool>? archived,
    Expression<String>? photoFile,
    Expression<int>? purchaseDate,
    Expression<int>? purchasePriceMinor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (dirty != null) 'dirty': dirty,
      if (nickname != null) 'nickname': nickname,
      if (type != null) 'type': type,
      if (regNo != null) 'reg_no': regNo,
      if (regNoKey != null) 'reg_no_key': regNoKey,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (fuelType != null) 'fuel_type': fuelType,
      if (businessModel != null) 'business_model': businessModel,
      if (status != null) 'status': status,
      if (archived != null) 'archived': archived,
      if (photoFile != null) 'photo_file': photoFile,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchasePriceMinor != null)
        'purchase_price_minor': purchasePriceMinor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<bool>? dirty,
    Value<String>? nickname,
    Value<VehicleType>? type,
    Value<String?>? regNo,
    Value<String?>? regNoKey,
    Value<String?>? model,
    Value<int?>? year,
    Value<FuelType>? fuelType,
    Value<BusinessModel>? businessModel,
    Value<VehicleStatus>? status,
    Value<bool>? archived,
    Value<String?>? photoFile,
    Value<int?>? purchaseDate,
    Value<int?>? purchasePriceMinor,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      dirty: dirty ?? this.dirty,
      nickname: nickname ?? this.nickname,
      type: type ?? this.type,
      regNo: regNo ?? this.regNo,
      regNoKey: regNoKey ?? this.regNoKey,
      model: model ?? this.model,
      year: year ?? this.year,
      fuelType: fuelType ?? this.fuelType,
      businessModel: businessModel ?? this.businessModel,
      status: status ?? this.status,
      archived: archived ?? this.archived,
      photoFile: photoFile ?? this.photoFile,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePriceMinor: purchasePriceMinor ?? this.purchasePriceMinor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $VehiclesTable.$convertertype.toSql(type.value),
      );
    }
    if (regNo.present) {
      map['reg_no'] = Variable<String>(regNo.value);
    }
    if (regNoKey.present) {
      map['reg_no_key'] = Variable<String>(regNoKey.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(
        $VehiclesTable.$converterfuelType.toSql(fuelType.value),
      );
    }
    if (businessModel.present) {
      map['business_model'] = Variable<String>(
        $VehiclesTable.$converterbusinessModel.toSql(businessModel.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $VehiclesTable.$converterstatus.toSql(status.value),
      );
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (photoFile.present) {
      map['photo_file'] = Variable<String>(photoFile.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<int>(purchaseDate.value);
    }
    if (purchasePriceMinor.present) {
      map['purchase_price_minor'] = Variable<int>(purchasePriceMinor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('nickname: $nickname, ')
          ..write('type: $type, ')
          ..write('regNo: $regNo, ')
          ..write('regNoKey: $regNoKey, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('fuelType: $fuelType, ')
          ..write('businessModel: $businessModel, ')
          ..write('status: $status, ')
          ..write('archived: $archived, ')
          ..write('photoFile: $photoFile, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchasePriceMinor: $purchasePriceMinor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DriversTable extends Drivers with TableInfo<$DriversTable, DriverRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DriversTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseNoMeta = const VerificationMeta(
    'licenseNo',
  );
  @override
  late final GeneratedColumn<String> licenseNo = GeneratedColumn<String>(
    'license_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseExpiryMeta = const VerificationMeta(
    'licenseExpiry',
  );
  @override
  late final GeneratedColumn<int> licenseExpiry = GeneratedColumn<int>(
    'license_expiry',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nidEncryptedMeta = const VerificationMeta(
    'nidEncrypted',
  );
  @override
  late final GeneratedColumn<String> nidEncrypted = GeneratedColumn<String>(
    'nid_encrypted',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emergencyContactMeta = const VerificationMeta(
    'emergencyContact',
  );
  @override
  late final GeneratedColumn<String> emergencyContact = GeneratedColumn<String>(
    'emergency_contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinDayMeta = const VerificationMeta(
    'joinDay',
  );
  @override
  late final GeneratedColumn<int> joinDay = GeneratedColumn<int>(
    'join_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoFileMeta = const VerificationMeta(
    'photoFile',
  );
  @override
  late final GeneratedColumn<String> photoFile = GeneratedColumn<String>(
    'photo_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DriverStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('active'),
      ).withConverter<DriverStatus>($DriversTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    name,
    phone,
    licenseNo,
    licenseExpiry,
    nidEncrypted,
    address,
    emergencyContact,
    joinDay,
    photoFile,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drivers';
  @override
  VerificationContext validateIntegrity(
    Insertable<DriverRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('license_no')) {
      context.handle(
        _licenseNoMeta,
        licenseNo.isAcceptableOrUnknown(data['license_no']!, _licenseNoMeta),
      );
    }
    if (data.containsKey('license_expiry')) {
      context.handle(
        _licenseExpiryMeta,
        licenseExpiry.isAcceptableOrUnknown(
          data['license_expiry']!,
          _licenseExpiryMeta,
        ),
      );
    }
    if (data.containsKey('nid_encrypted')) {
      context.handle(
        _nidEncryptedMeta,
        nidEncrypted.isAcceptableOrUnknown(
          data['nid_encrypted']!,
          _nidEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('emergency_contact')) {
      context.handle(
        _emergencyContactMeta,
        emergencyContact.isAcceptableOrUnknown(
          data['emergency_contact']!,
          _emergencyContactMeta,
        ),
      );
    }
    if (data.containsKey('join_day')) {
      context.handle(
        _joinDayMeta,
        joinDay.isAcceptableOrUnknown(data['join_day']!, _joinDayMeta),
      );
    }
    if (data.containsKey('photo_file')) {
      context.handle(
        _photoFileMeta,
        photoFile.isAcceptableOrUnknown(data['photo_file']!, _photoFileMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DriverRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriverRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      licenseNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_no'],
      ),
      licenseExpiry: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}license_expiry'],
      ),
      nidEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nid_encrypted'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      emergencyContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emergency_contact'],
      ),
      joinDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}join_day'],
      ),
      photoFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_file'],
      ),
      status: $DriversTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $DriversTable createAlias(String alias) {
    return $DriversTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DriverStatus, String, String> $converterstatus =
      const EnumNameConverter<DriverStatus>(DriverStatus.values);
}

class DriverRow extends DataClass implements Insertable<DriverRow> {
  final String id;

  /// Tenant key. `local` until the user signs in and the data is claimed.
  final String ownerId;

  /// Epoch milliseconds, UTC.
  final int createdAt;
  final int updatedAt;

  /// Tombstone; non-null means soft-deleted.
  final int? deletedAt;

  /// Local monotonic revision, bumped on every write.
  final int rev;

  /// True while the row has changes not yet pushed.
  final bool dirty;
  final String name;
  final String? phone;
  final String? licenseNo;

  /// Calendar day (days since 1970-01-01).
  final int? licenseExpiry;

  /// National ID, AES-GCM encrypted (`v1:...`); never plaintext.
  final String? nidEncrypted;
  final String? address;
  final String? emergencyContact;
  final int? joinDay;
  final String? photoFile;
  final DriverStatus status;
  const DriverRow({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.dirty,
    required this.name,
    this.phone,
    this.licenseNo,
    this.licenseExpiry,
    this.nidEncrypted,
    this.address,
    this.emergencyContact,
    this.joinDay,
    this.photoFile,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['dirty'] = Variable<bool>(dirty);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || licenseNo != null) {
      map['license_no'] = Variable<String>(licenseNo);
    }
    if (!nullToAbsent || licenseExpiry != null) {
      map['license_expiry'] = Variable<int>(licenseExpiry);
    }
    if (!nullToAbsent || nidEncrypted != null) {
      map['nid_encrypted'] = Variable<String>(nidEncrypted);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || emergencyContact != null) {
      map['emergency_contact'] = Variable<String>(emergencyContact);
    }
    if (!nullToAbsent || joinDay != null) {
      map['join_day'] = Variable<int>(joinDay);
    }
    if (!nullToAbsent || photoFile != null) {
      map['photo_file'] = Variable<String>(photoFile);
    }
    {
      map['status'] = Variable<String>(
        $DriversTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  DriversCompanion toCompanion(bool nullToAbsent) {
    return DriversCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      dirty: Value(dirty),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      licenseNo: licenseNo == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseNo),
      licenseExpiry: licenseExpiry == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseExpiry),
      nidEncrypted: nidEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(nidEncrypted),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      emergencyContact: emergencyContact == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContact),
      joinDay: joinDay == null && nullToAbsent
          ? const Value.absent()
          : Value(joinDay),
      photoFile: photoFile == null && nullToAbsent
          ? const Value.absent()
          : Value(photoFile),
      status: Value(status),
    );
  }

  factory DriverRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriverRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      licenseNo: serializer.fromJson<String?>(json['licenseNo']),
      licenseExpiry: serializer.fromJson<int?>(json['licenseExpiry']),
      nidEncrypted: serializer.fromJson<String?>(json['nidEncrypted']),
      address: serializer.fromJson<String?>(json['address']),
      emergencyContact: serializer.fromJson<String?>(json['emergencyContact']),
      joinDay: serializer.fromJson<int?>(json['joinDay']),
      photoFile: serializer.fromJson<String?>(json['photoFile']),
      status: $DriversTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'dirty': serializer.toJson<bool>(dirty),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'licenseNo': serializer.toJson<String?>(licenseNo),
      'licenseExpiry': serializer.toJson<int?>(licenseExpiry),
      'nidEncrypted': serializer.toJson<String?>(nidEncrypted),
      'address': serializer.toJson<String?>(address),
      'emergencyContact': serializer.toJson<String?>(emergencyContact),
      'joinDay': serializer.toJson<int?>(joinDay),
      'photoFile': serializer.toJson<String?>(photoFile),
      'status': serializer.toJson<String>(
        $DriversTable.$converterstatus.toJson(status),
      ),
    };
  }

  DriverRow copyWith({
    String? id,
    String? ownerId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    bool? dirty,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> licenseNo = const Value.absent(),
    Value<int?> licenseExpiry = const Value.absent(),
    Value<String?> nidEncrypted = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> emergencyContact = const Value.absent(),
    Value<int?> joinDay = const Value.absent(),
    Value<String?> photoFile = const Value.absent(),
    DriverStatus? status,
  }) => DriverRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    dirty: dirty ?? this.dirty,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    licenseNo: licenseNo.present ? licenseNo.value : this.licenseNo,
    licenseExpiry: licenseExpiry.present
        ? licenseExpiry.value
        : this.licenseExpiry,
    nidEncrypted: nidEncrypted.present ? nidEncrypted.value : this.nidEncrypted,
    address: address.present ? address.value : this.address,
    emergencyContact: emergencyContact.present
        ? emergencyContact.value
        : this.emergencyContact,
    joinDay: joinDay.present ? joinDay.value : this.joinDay,
    photoFile: photoFile.present ? photoFile.value : this.photoFile,
    status: status ?? this.status,
  );
  DriverRow copyWithCompanion(DriversCompanion data) {
    return DriverRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      licenseNo: data.licenseNo.present ? data.licenseNo.value : this.licenseNo,
      licenseExpiry: data.licenseExpiry.present
          ? data.licenseExpiry.value
          : this.licenseExpiry,
      nidEncrypted: data.nidEncrypted.present
          ? data.nidEncrypted.value
          : this.nidEncrypted,
      address: data.address.present ? data.address.value : this.address,
      emergencyContact: data.emergencyContact.present
          ? data.emergencyContact.value
          : this.emergencyContact,
      joinDay: data.joinDay.present ? data.joinDay.value : this.joinDay,
      photoFile: data.photoFile.present ? data.photoFile.value : this.photoFile,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DriverRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('licenseNo: $licenseNo, ')
          ..write('licenseExpiry: $licenseExpiry, ')
          ..write('nidEncrypted: $nidEncrypted, ')
          ..write('address: $address, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('joinDay: $joinDay, ')
          ..write('photoFile: $photoFile, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    name,
    phone,
    licenseNo,
    licenseExpiry,
    nidEncrypted,
    address,
    emergencyContact,
    joinDay,
    photoFile,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriverRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.dirty == this.dirty &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.licenseNo == this.licenseNo &&
          other.licenseExpiry == this.licenseExpiry &&
          other.nidEncrypted == this.nidEncrypted &&
          other.address == this.address &&
          other.emergencyContact == this.emergencyContact &&
          other.joinDay == this.joinDay &&
          other.photoFile == this.photoFile &&
          other.status == this.status);
}

class DriversCompanion extends UpdateCompanion<DriverRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<bool> dirty;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> licenseNo;
  final Value<int?> licenseExpiry;
  final Value<String?> nidEncrypted;
  final Value<String?> address;
  final Value<String?> emergencyContact;
  final Value<int?> joinDay;
  final Value<String?> photoFile;
  final Value<DriverStatus> status;
  final Value<int> rowid;
  const DriversCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.licenseNo = const Value.absent(),
    this.licenseExpiry = const Value.absent(),
    this.nidEncrypted = const Value.absent(),
    this.address = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.joinDay = const Value.absent(),
    this.photoFile = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DriversCompanion.insert({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.licenseNo = const Value.absent(),
    this.licenseExpiry = const Value.absent(),
    this.nidEncrypted = const Value.absent(),
    this.address = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.joinDay = const Value.absent(),
    this.photoFile = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<DriverRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<bool>? dirty,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? licenseNo,
    Expression<int>? licenseExpiry,
    Expression<String>? nidEncrypted,
    Expression<String>? address,
    Expression<String>? emergencyContact,
    Expression<int>? joinDay,
    Expression<String>? photoFile,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (dirty != null) 'dirty': dirty,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (licenseNo != null) 'license_no': licenseNo,
      if (licenseExpiry != null) 'license_expiry': licenseExpiry,
      if (nidEncrypted != null) 'nid_encrypted': nidEncrypted,
      if (address != null) 'address': address,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (joinDay != null) 'join_day': joinDay,
      if (photoFile != null) 'photo_file': photoFile,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DriversCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<bool>? dirty,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? licenseNo,
    Value<int?>? licenseExpiry,
    Value<String?>? nidEncrypted,
    Value<String?>? address,
    Value<String?>? emergencyContact,
    Value<int?>? joinDay,
    Value<String?>? photoFile,
    Value<DriverStatus>? status,
    Value<int>? rowid,
  }) {
    return DriversCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      dirty: dirty ?? this.dirty,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      licenseNo: licenseNo ?? this.licenseNo,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      nidEncrypted: nidEncrypted ?? this.nidEncrypted,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      joinDay: joinDay ?? this.joinDay,
      photoFile: photoFile ?? this.photoFile,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (licenseNo.present) {
      map['license_no'] = Variable<String>(licenseNo.value);
    }
    if (licenseExpiry.present) {
      map['license_expiry'] = Variable<int>(licenseExpiry.value);
    }
    if (nidEncrypted.present) {
      map['nid_encrypted'] = Variable<String>(nidEncrypted.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (emergencyContact.present) {
      map['emergency_contact'] = Variable<String>(emergencyContact.value);
    }
    if (joinDay.present) {
      map['join_day'] = Variable<int>(joinDay.value);
    }
    if (photoFile.present) {
      map['photo_file'] = Variable<String>(photoFile.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $DriversTable.$converterstatus.toSql(status.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DriversCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('licenseNo: $licenseNo, ')
          ..write('licenseExpiry: $licenseExpiry, ')
          ..write('nidEncrypted: $nidEncrypted, ')
          ..write('address: $address, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('joinDay: $joinDay, ')
          ..write('photoFile: $photoFile, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssignmentsTable extends Assignments
    with TableInfo<$AssignmentsTable, AssignmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drivers (id)',
    ),
  );
  static const VerificationMeta _payModelJsonMeta = const VerificationMeta(
    'payModelJson',
  );
  @override
  late final GeneratedColumn<String> payModelJson = GeneratedColumn<String>(
    'pay_model_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDayMeta = const VerificationMeta(
    'startDay',
  );
  @override
  late final GeneratedColumn<int> startDay = GeneratedColumn<int>(
    'start_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDayMeta = const VerificationMeta('endDay');
  @override
  late final GeneratedColumn<int> endDay = GeneratedColumn<int>(
    'end_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeVehicleKeyMeta = const VerificationMeta(
    'activeVehicleKey',
  );
  @override
  late final GeneratedColumn<String> activeVehicleKey = GeneratedColumn<String>(
    'active_vehicle_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    vehicleId,
    driverId,
    payModelJson,
    startDay,
    endDay,
    activeVehicleKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssignmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('pay_model_json')) {
      context.handle(
        _payModelJsonMeta,
        payModelJson.isAcceptableOrUnknown(
          data['pay_model_json']!,
          _payModelJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payModelJsonMeta);
    }
    if (data.containsKey('start_day')) {
      context.handle(
        _startDayMeta,
        startDay.isAcceptableOrUnknown(data['start_day']!, _startDayMeta),
      );
    } else if (isInserting) {
      context.missing(_startDayMeta);
    }
    if (data.containsKey('end_day')) {
      context.handle(
        _endDayMeta,
        endDay.isAcceptableOrUnknown(data['end_day']!, _endDayMeta),
      );
    }
    if (data.containsKey('active_vehicle_key')) {
      context.handle(
        _activeVehicleKeyMeta,
        activeVehicleKey.isAcceptableOrUnknown(
          data['active_vehicle_key']!,
          _activeVehicleKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {activeVehicleKey},
  ];
  @override
  AssignmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssignmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_id'],
      )!,
      payModelJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pay_model_json'],
      )!,
      startDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_day'],
      )!,
      endDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_day'],
      ),
      activeVehicleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_vehicle_key'],
      ),
    );
  }

  @override
  $AssignmentsTable createAlias(String alias) {
    return $AssignmentsTable(attachedDatabase, alias);
  }
}

class AssignmentRow extends DataClass implements Insertable<AssignmentRow> {
  final String id;

  /// Tenant key. `local` until the user signs in and the data is claimed.
  final String ownerId;

  /// Epoch milliseconds, UTC.
  final int createdAt;
  final int updatedAt;

  /// Tombstone; non-null means soft-deleted.
  final int? deletedAt;

  /// Local monotonic revision, bumped on every write.
  final int rev;

  /// True while the row has changes not yet pushed.
  final bool dirty;
  final String vehicleId;
  final String driverId;

  /// Versioned [PayModel] JSON.
  final String payModelJson;
  final int startDay;
  final int? endDay;

  /// Equals [vehicleId] while the assignment is active, NULL once ended.
  /// The unique constraint below therefore allows at most one active
  /// assignment per vehicle (NULLs are distinct in SQLite).
  final String? activeVehicleKey;
  const AssignmentRow({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.dirty,
    required this.vehicleId,
    required this.driverId,
    required this.payModelJson,
    required this.startDay,
    this.endDay,
    this.activeVehicleKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['dirty'] = Variable<bool>(dirty);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['driver_id'] = Variable<String>(driverId);
    map['pay_model_json'] = Variable<String>(payModelJson);
    map['start_day'] = Variable<int>(startDay);
    if (!nullToAbsent || endDay != null) {
      map['end_day'] = Variable<int>(endDay);
    }
    if (!nullToAbsent || activeVehicleKey != null) {
      map['active_vehicle_key'] = Variable<String>(activeVehicleKey);
    }
    return map;
  }

  AssignmentsCompanion toCompanion(bool nullToAbsent) {
    return AssignmentsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      dirty: Value(dirty),
      vehicleId: Value(vehicleId),
      driverId: Value(driverId),
      payModelJson: Value(payModelJson),
      startDay: Value(startDay),
      endDay: endDay == null && nullToAbsent
          ? const Value.absent()
          : Value(endDay),
      activeVehicleKey: activeVehicleKey == null && nullToAbsent
          ? const Value.absent()
          : Value(activeVehicleKey),
    );
  }

  factory AssignmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssignmentRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      driverId: serializer.fromJson<String>(json['driverId']),
      payModelJson: serializer.fromJson<String>(json['payModelJson']),
      startDay: serializer.fromJson<int>(json['startDay']),
      endDay: serializer.fromJson<int?>(json['endDay']),
      activeVehicleKey: serializer.fromJson<String?>(json['activeVehicleKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'dirty': serializer.toJson<bool>(dirty),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'driverId': serializer.toJson<String>(driverId),
      'payModelJson': serializer.toJson<String>(payModelJson),
      'startDay': serializer.toJson<int>(startDay),
      'endDay': serializer.toJson<int?>(endDay),
      'activeVehicleKey': serializer.toJson<String?>(activeVehicleKey),
    };
  }

  AssignmentRow copyWith({
    String? id,
    String? ownerId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    bool? dirty,
    String? vehicleId,
    String? driverId,
    String? payModelJson,
    int? startDay,
    Value<int?> endDay = const Value.absent(),
    Value<String?> activeVehicleKey = const Value.absent(),
  }) => AssignmentRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    dirty: dirty ?? this.dirty,
    vehicleId: vehicleId ?? this.vehicleId,
    driverId: driverId ?? this.driverId,
    payModelJson: payModelJson ?? this.payModelJson,
    startDay: startDay ?? this.startDay,
    endDay: endDay.present ? endDay.value : this.endDay,
    activeVehicleKey: activeVehicleKey.present
        ? activeVehicleKey.value
        : this.activeVehicleKey,
  );
  AssignmentRow copyWithCompanion(AssignmentsCompanion data) {
    return AssignmentRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      payModelJson: data.payModelJson.present
          ? data.payModelJson.value
          : this.payModelJson,
      startDay: data.startDay.present ? data.startDay.value : this.startDay,
      endDay: data.endDay.present ? data.endDay.value : this.endDay,
      activeVehicleKey: data.activeVehicleKey.present
          ? data.activeVehicleKey.value
          : this.activeVehicleKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('driverId: $driverId, ')
          ..write('payModelJson: $payModelJson, ')
          ..write('startDay: $startDay, ')
          ..write('endDay: $endDay, ')
          ..write('activeVehicleKey: $activeVehicleKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    vehicleId,
    driverId,
    payModelJson,
    startDay,
    endDay,
    activeVehicleKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssignmentRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.dirty == this.dirty &&
          other.vehicleId == this.vehicleId &&
          other.driverId == this.driverId &&
          other.payModelJson == this.payModelJson &&
          other.startDay == this.startDay &&
          other.endDay == this.endDay &&
          other.activeVehicleKey == this.activeVehicleKey);
}

class AssignmentsCompanion extends UpdateCompanion<AssignmentRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<bool> dirty;
  final Value<String> vehicleId;
  final Value<String> driverId;
  final Value<String> payModelJson;
  final Value<int> startDay;
  final Value<int?> endDay;
  final Value<String?> activeVehicleKey;
  final Value<int> rowid;
  const AssignmentsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.driverId = const Value.absent(),
    this.payModelJson = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endDay = const Value.absent(),
    this.activeVehicleKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssignmentsCompanion.insert({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    required String vehicleId,
    required String driverId,
    required String payModelJson,
    required int startDay,
    this.endDay = const Value.absent(),
    this.activeVehicleKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       driverId = Value(driverId),
       payModelJson = Value(payModelJson),
       startDay = Value(startDay);
  static Insertable<AssignmentRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<bool>? dirty,
    Expression<String>? vehicleId,
    Expression<String>? driverId,
    Expression<String>? payModelJson,
    Expression<int>? startDay,
    Expression<int>? endDay,
    Expression<String>? activeVehicleKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (dirty != null) 'dirty': dirty,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (driverId != null) 'driver_id': driverId,
      if (payModelJson != null) 'pay_model_json': payModelJson,
      if (startDay != null) 'start_day': startDay,
      if (endDay != null) 'end_day': endDay,
      if (activeVehicleKey != null) 'active_vehicle_key': activeVehicleKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssignmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<bool>? dirty,
    Value<String>? vehicleId,
    Value<String>? driverId,
    Value<String>? payModelJson,
    Value<int>? startDay,
    Value<int?>? endDay,
    Value<String?>? activeVehicleKey,
    Value<int>? rowid,
  }) {
    return AssignmentsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      dirty: dirty ?? this.dirty,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      payModelJson: payModelJson ?? this.payModelJson,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
      activeVehicleKey: activeVehicleKey ?? this.activeVehicleKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (payModelJson.present) {
      map['pay_model_json'] = Variable<String>(payModelJson.value);
    }
    if (startDay.present) {
      map['start_day'] = Variable<int>(startDay.value);
    }
    if (endDay.present) {
      map['end_day'] = Variable<int>(endDay.value);
    }
    if (activeVehicleKey.present) {
      map['active_vehicle_key'] = Variable<String>(activeVehicleKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('driverId: $driverId, ')
          ..write('payModelJson: $payModelJson, ')
          ..write('startDay: $startDay, ')
          ..write('endDay: $endDay, ')
          ..write('activeVehicleKey: $activeVehicleKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceRecordsTable extends AttendanceRecords
    with TableInfo<$AttendanceRecordsTable, AttendanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drivers (id)',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AttendanceStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AttendanceStatus>(
        $AttendanceRecordsTable.$converterstatus,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    driverId,
    day,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {driverId, day},
  ];
  @override
  AttendanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      )!,
      status: $AttendanceRecordsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $AttendanceRecordsTable createAlias(String alias) {
    return $AttendanceRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AttendanceStatus, String, String> $converterstatus =
      const EnumNameConverter<AttendanceStatus>(AttendanceStatus.values);
}

class AttendanceRow extends DataClass implements Insertable<AttendanceRow> {
  final String id;

  /// Tenant key. `local` until the user signs in and the data is claimed.
  final String ownerId;

  /// Epoch milliseconds, UTC.
  final int createdAt;
  final int updatedAt;

  /// Tombstone; non-null means soft-deleted.
  final int? deletedAt;

  /// Local monotonic revision, bumped on every write.
  final int rev;

  /// True while the row has changes not yet pushed.
  final bool dirty;
  final String driverId;
  final int day;
  final AttendanceStatus status;
  const AttendanceRow({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.dirty,
    required this.driverId,
    required this.day,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['dirty'] = Variable<bool>(dirty);
    map['driver_id'] = Variable<String>(driverId);
    map['day'] = Variable<int>(day);
    {
      map['status'] = Variable<String>(
        $AttendanceRecordsTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  AttendanceRecordsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceRecordsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      dirty: Value(dirty),
      driverId: Value(driverId),
      day: Value(day),
      status: Value(status),
    );
  }

  factory AttendanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      driverId: serializer.fromJson<String>(json['driverId']),
      day: serializer.fromJson<int>(json['day']),
      status: $AttendanceRecordsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'dirty': serializer.toJson<bool>(dirty),
      'driverId': serializer.toJson<String>(driverId),
      'day': serializer.toJson<int>(day),
      'status': serializer.toJson<String>(
        $AttendanceRecordsTable.$converterstatus.toJson(status),
      ),
    };
  }

  AttendanceRow copyWith({
    String? id,
    String? ownerId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    bool? dirty,
    String? driverId,
    int? day,
    AttendanceStatus? status,
  }) => AttendanceRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    dirty: dirty ?? this.dirty,
    driverId: driverId ?? this.driverId,
    day: day ?? this.day,
    status: status ?? this.status,
  );
  AttendanceRow copyWithCompanion(AttendanceRecordsCompanion data) {
    return AttendanceRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      day: data.day.present ? data.day.value : this.day,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('driverId: $driverId, ')
          ..write('day: $day, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    driverId,
    day,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.dirty == this.dirty &&
          other.driverId == this.driverId &&
          other.day == this.day &&
          other.status == this.status);
}

class AttendanceRecordsCompanion extends UpdateCompanion<AttendanceRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<bool> dirty;
  final Value<String> driverId;
  final Value<int> day;
  final Value<AttendanceStatus> status;
  final Value<int> rowid;
  const AttendanceRecordsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    this.driverId = const Value.absent(),
    this.day = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceRecordsCompanion.insert({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    required String driverId,
    required int day,
    required AttendanceStatus status,
    this.rowid = const Value.absent(),
  }) : driverId = Value(driverId),
       day = Value(day),
       status = Value(status);
  static Insertable<AttendanceRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<bool>? dirty,
    Expression<String>? driverId,
    Expression<int>? day,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (dirty != null) 'dirty': dirty,
      if (driverId != null) 'driver_id': driverId,
      if (day != null) 'day': day,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<bool>? dirty,
    Value<String>? driverId,
    Value<int>? day,
    Value<AttendanceStatus>? status,
    Value<int>? rowid,
  }) {
    return AttendanceRecordsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      dirty: dirty ?? this.dirty,
      driverId: driverId ?? this.driverId,
      day: day ?? this.day,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $AttendanceRecordsTable.$converterstatus.toSql(status.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('driverId: $driverId, ')
          ..write('day: $day, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdvancesTable extends Advances
    with TableInfo<$AdvancesTable, AdvanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdvancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drivers (id)',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _givenDayMeta = const VerificationMeta(
    'givenDay',
  );
  @override
  late final GeneratedColumn<int> givenDay = GeneratedColumn<int>(
    'given_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    driverId,
    amountMinor,
    givenDay,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'advances';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdvanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('given_day')) {
      context.handle(
        _givenDayMeta,
        givenDay.isAcceptableOrUnknown(data['given_day']!, _givenDayMeta),
      );
    } else if (isInserting) {
      context.missing(_givenDayMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdvanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdvanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      givenDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}given_day'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $AdvancesTable createAlias(String alias) {
    return $AdvancesTable(attachedDatabase, alias);
  }
}

class AdvanceRow extends DataClass implements Insertable<AdvanceRow> {
  final String id;

  /// Tenant key. `local` until the user signs in and the data is claimed.
  final String ownerId;

  /// Epoch milliseconds, UTC.
  final int createdAt;
  final int updatedAt;

  /// Tombstone; non-null means soft-deleted.
  final int? deletedAt;

  /// Local monotonic revision, bumped on every write.
  final int rev;

  /// True while the row has changes not yet pushed.
  final bool dirty;
  final String driverId;
  final int amountMinor;
  final int givenDay;
  final String? note;
  const AdvanceRow({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.dirty,
    required this.driverId,
    required this.amountMinor,
    required this.givenDay,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['dirty'] = Variable<bool>(dirty);
    map['driver_id'] = Variable<String>(driverId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['given_day'] = Variable<int>(givenDay);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  AdvancesCompanion toCompanion(bool nullToAbsent) {
    return AdvancesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      dirty: Value(dirty),
      driverId: Value(driverId),
      amountMinor: Value(amountMinor),
      givenDay: Value(givenDay),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory AdvanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdvanceRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      driverId: serializer.fromJson<String>(json['driverId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      givenDay: serializer.fromJson<int>(json['givenDay']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'dirty': serializer.toJson<bool>(dirty),
      'driverId': serializer.toJson<String>(driverId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'givenDay': serializer.toJson<int>(givenDay),
      'note': serializer.toJson<String?>(note),
    };
  }

  AdvanceRow copyWith({
    String? id,
    String? ownerId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    bool? dirty,
    String? driverId,
    int? amountMinor,
    int? givenDay,
    Value<String?> note = const Value.absent(),
  }) => AdvanceRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    dirty: dirty ?? this.dirty,
    driverId: driverId ?? this.driverId,
    amountMinor: amountMinor ?? this.amountMinor,
    givenDay: givenDay ?? this.givenDay,
    note: note.present ? note.value : this.note,
  );
  AdvanceRow copyWithCompanion(AdvancesCompanion data) {
    return AdvanceRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      givenDay: data.givenDay.present ? data.givenDay.value : this.givenDay,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdvanceRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('driverId: $driverId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('givenDay: $givenDay, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    driverId,
    amountMinor,
    givenDay,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdvanceRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.dirty == this.dirty &&
          other.driverId == this.driverId &&
          other.amountMinor == this.amountMinor &&
          other.givenDay == this.givenDay &&
          other.note == this.note);
}

class AdvancesCompanion extends UpdateCompanion<AdvanceRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<bool> dirty;
  final Value<String> driverId;
  final Value<int> amountMinor;
  final Value<int> givenDay;
  final Value<String?> note;
  final Value<int> rowid;
  const AdvancesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    this.driverId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.givenDay = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdvancesCompanion.insert({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    required String driverId,
    required int amountMinor,
    required int givenDay,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : driverId = Value(driverId),
       amountMinor = Value(amountMinor),
       givenDay = Value(givenDay);
  static Insertable<AdvanceRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<bool>? dirty,
    Expression<String>? driverId,
    Expression<int>? amountMinor,
    Expression<int>? givenDay,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (dirty != null) 'dirty': dirty,
      if (driverId != null) 'driver_id': driverId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (givenDay != null) 'given_day': givenDay,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdvancesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<bool>? dirty,
    Value<String>? driverId,
    Value<int>? amountMinor,
    Value<int>? givenDay,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return AdvancesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      dirty: dirty ?? this.dirty,
      driverId: driverId ?? this.driverId,
      amountMinor: amountMinor ?? this.amountMinor,
      givenDay: givenDay ?? this.givenDay,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (givenDay.present) {
      map['given_day'] = Variable<int>(givenDay.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdvancesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('driverId: $driverId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('givenDay: $givenDay, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayoutsTable extends Payouts with TableInfo<$PayoutsTable, PayoutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drivers (id)',
    ),
  );
  static const VerificationMeta _assignmentIdMeta = const VerificationMeta(
    'assignmentId',
  );
  @override
  late final GeneratedColumn<String> assignmentId = GeneratedColumn<String>(
    'assignment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assignments (id)',
    ),
  );
  static const VerificationMeta _periodStartDayMeta = const VerificationMeta(
    'periodStartDay',
  );
  @override
  late final GeneratedColumn<int> periodStartDay = GeneratedColumn<int>(
    'period_start_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodEndDayMeta = const VerificationMeta(
    'periodEndDay',
  );
  @override
  late final GeneratedColumn<int> periodEndDay = GeneratedColumn<int>(
    'period_end_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedMinorMeta = const VerificationMeta(
    'earnedMinor',
  );
  @override
  late final GeneratedColumn<int> earnedMinor = GeneratedColumn<int>(
    'earned_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adjustmentMinorMeta = const VerificationMeta(
    'adjustmentMinor',
  );
  @override
  late final GeneratedColumn<int> adjustmentMinor = GeneratedColumn<int>(
    'adjustment_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _adjustmentNoteMeta = const VerificationMeta(
    'adjustmentNote',
  );
  @override
  late final GeneratedColumn<String> adjustmentNote = GeneratedColumn<String>(
    'adjustment_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deductedMinorMeta = const VerificationMeta(
    'deductedMinor',
  );
  @override
  late final GeneratedColumn<int> deductedMinor = GeneratedColumn<int>(
    'deducted_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _netMinorMeta = const VerificationMeta(
    'netMinor',
  );
  @override
  late final GeneratedColumn<int> netMinor = GeneratedColumn<int>(
    'net_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<int> paidAt = GeneratedColumn<int>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    driverId,
    assignmentId,
    periodStartDay,
    periodEndDay,
    earnedMinor,
    adjustmentMinor,
    adjustmentNote,
    deductedMinor,
    netMinor,
    paidAt,
    note,
    periodKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayoutRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('assignment_id')) {
      context.handle(
        _assignmentIdMeta,
        assignmentId.isAcceptableOrUnknown(
          data['assignment_id']!,
          _assignmentIdMeta,
        ),
      );
    }
    if (data.containsKey('period_start_day')) {
      context.handle(
        _periodStartDayMeta,
        periodStartDay.isAcceptableOrUnknown(
          data['period_start_day']!,
          _periodStartDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartDayMeta);
    }
    if (data.containsKey('period_end_day')) {
      context.handle(
        _periodEndDayMeta,
        periodEndDay.isAcceptableOrUnknown(
          data['period_end_day']!,
          _periodEndDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodEndDayMeta);
    }
    if (data.containsKey('earned_minor')) {
      context.handle(
        _earnedMinorMeta,
        earnedMinor.isAcceptableOrUnknown(
          data['earned_minor']!,
          _earnedMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_earnedMinorMeta);
    }
    if (data.containsKey('adjustment_minor')) {
      context.handle(
        _adjustmentMinorMeta,
        adjustmentMinor.isAcceptableOrUnknown(
          data['adjustment_minor']!,
          _adjustmentMinorMeta,
        ),
      );
    }
    if (data.containsKey('adjustment_note')) {
      context.handle(
        _adjustmentNoteMeta,
        adjustmentNote.isAcceptableOrUnknown(
          data['adjustment_note']!,
          _adjustmentNoteMeta,
        ),
      );
    }
    if (data.containsKey('deducted_minor')) {
      context.handle(
        _deductedMinorMeta,
        deductedMinor.isAcceptableOrUnknown(
          data['deducted_minor']!,
          _deductedMinorMeta,
        ),
      );
    }
    if (data.containsKey('net_minor')) {
      context.handle(
        _netMinorMeta,
        netMinor.isAcceptableOrUnknown(data['net_minor']!, _netMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_netMinorMeta);
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {periodKey},
  ];
  @override
  PayoutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayoutRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_id'],
      )!,
      assignmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignment_id'],
      ),
      periodStartDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_start_day'],
      )!,
      periodEndDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_end_day'],
      )!,
      earnedMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}earned_minor'],
      )!,
      adjustmentMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}adjustment_minor'],
      )!,
      adjustmentNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjustment_note'],
      ),
      deductedMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deducted_minor'],
      )!,
      netMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_minor'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      ),
    );
  }

  @override
  $PayoutsTable createAlias(String alias) {
    return $PayoutsTable(attachedDatabase, alias);
  }
}

class PayoutRow extends DataClass implements Insertable<PayoutRow> {
  final String id;

  /// Tenant key. `local` until the user signs in and the data is claimed.
  final String ownerId;

  /// Epoch milliseconds, UTC.
  final int createdAt;
  final int updatedAt;

  /// Tombstone; non-null means soft-deleted.
  final int? deletedAt;

  /// Local monotonic revision, bumped on every write.
  final int rev;

  /// True while the row has changes not yet pushed.
  final bool dirty;
  final String driverId;
  final String? assignmentId;
  final int periodStartDay;
  final int periodEndDay;
  final int earnedMinor;
  final int adjustmentMinor;
  final String? adjustmentNote;
  final int deductedMinor;
  final int netMinor;
  final int paidAt;
  final String? note;

  /// `driver|assignment|start|end` while the payout stands; NULL once voided.
  /// Unique, so recording the same period twice cannot create a duplicate.
  final String? periodKey;
  const PayoutRow({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.dirty,
    required this.driverId,
    this.assignmentId,
    required this.periodStartDay,
    required this.periodEndDay,
    required this.earnedMinor,
    required this.adjustmentMinor,
    this.adjustmentNote,
    required this.deductedMinor,
    required this.netMinor,
    required this.paidAt,
    this.note,
    this.periodKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['dirty'] = Variable<bool>(dirty);
    map['driver_id'] = Variable<String>(driverId);
    if (!nullToAbsent || assignmentId != null) {
      map['assignment_id'] = Variable<String>(assignmentId);
    }
    map['period_start_day'] = Variable<int>(periodStartDay);
    map['period_end_day'] = Variable<int>(periodEndDay);
    map['earned_minor'] = Variable<int>(earnedMinor);
    map['adjustment_minor'] = Variable<int>(adjustmentMinor);
    if (!nullToAbsent || adjustmentNote != null) {
      map['adjustment_note'] = Variable<String>(adjustmentNote);
    }
    map['deducted_minor'] = Variable<int>(deductedMinor);
    map['net_minor'] = Variable<int>(netMinor);
    map['paid_at'] = Variable<int>(paidAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || periodKey != null) {
      map['period_key'] = Variable<String>(periodKey);
    }
    return map;
  }

  PayoutsCompanion toCompanion(bool nullToAbsent) {
    return PayoutsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      dirty: Value(dirty),
      driverId: Value(driverId),
      assignmentId: assignmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignmentId),
      periodStartDay: Value(periodStartDay),
      periodEndDay: Value(periodEndDay),
      earnedMinor: Value(earnedMinor),
      adjustmentMinor: Value(adjustmentMinor),
      adjustmentNote: adjustmentNote == null && nullToAbsent
          ? const Value.absent()
          : Value(adjustmentNote),
      deductedMinor: Value(deductedMinor),
      netMinor: Value(netMinor),
      paidAt: Value(paidAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      periodKey: periodKey == null && nullToAbsent
          ? const Value.absent()
          : Value(periodKey),
    );
  }

  factory PayoutRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayoutRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      driverId: serializer.fromJson<String>(json['driverId']),
      assignmentId: serializer.fromJson<String?>(json['assignmentId']),
      periodStartDay: serializer.fromJson<int>(json['periodStartDay']),
      periodEndDay: serializer.fromJson<int>(json['periodEndDay']),
      earnedMinor: serializer.fromJson<int>(json['earnedMinor']),
      adjustmentMinor: serializer.fromJson<int>(json['adjustmentMinor']),
      adjustmentNote: serializer.fromJson<String?>(json['adjustmentNote']),
      deductedMinor: serializer.fromJson<int>(json['deductedMinor']),
      netMinor: serializer.fromJson<int>(json['netMinor']),
      paidAt: serializer.fromJson<int>(json['paidAt']),
      note: serializer.fromJson<String?>(json['note']),
      periodKey: serializer.fromJson<String?>(json['periodKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'dirty': serializer.toJson<bool>(dirty),
      'driverId': serializer.toJson<String>(driverId),
      'assignmentId': serializer.toJson<String?>(assignmentId),
      'periodStartDay': serializer.toJson<int>(periodStartDay),
      'periodEndDay': serializer.toJson<int>(periodEndDay),
      'earnedMinor': serializer.toJson<int>(earnedMinor),
      'adjustmentMinor': serializer.toJson<int>(adjustmentMinor),
      'adjustmentNote': serializer.toJson<String?>(adjustmentNote),
      'deductedMinor': serializer.toJson<int>(deductedMinor),
      'netMinor': serializer.toJson<int>(netMinor),
      'paidAt': serializer.toJson<int>(paidAt),
      'note': serializer.toJson<String?>(note),
      'periodKey': serializer.toJson<String?>(periodKey),
    };
  }

  PayoutRow copyWith({
    String? id,
    String? ownerId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    bool? dirty,
    String? driverId,
    Value<String?> assignmentId = const Value.absent(),
    int? periodStartDay,
    int? periodEndDay,
    int? earnedMinor,
    int? adjustmentMinor,
    Value<String?> adjustmentNote = const Value.absent(),
    int? deductedMinor,
    int? netMinor,
    int? paidAt,
    Value<String?> note = const Value.absent(),
    Value<String?> periodKey = const Value.absent(),
  }) => PayoutRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    dirty: dirty ?? this.dirty,
    driverId: driverId ?? this.driverId,
    assignmentId: assignmentId.present ? assignmentId.value : this.assignmentId,
    periodStartDay: periodStartDay ?? this.periodStartDay,
    periodEndDay: periodEndDay ?? this.periodEndDay,
    earnedMinor: earnedMinor ?? this.earnedMinor,
    adjustmentMinor: adjustmentMinor ?? this.adjustmentMinor,
    adjustmentNote: adjustmentNote.present
        ? adjustmentNote.value
        : this.adjustmentNote,
    deductedMinor: deductedMinor ?? this.deductedMinor,
    netMinor: netMinor ?? this.netMinor,
    paidAt: paidAt ?? this.paidAt,
    note: note.present ? note.value : this.note,
    periodKey: periodKey.present ? periodKey.value : this.periodKey,
  );
  PayoutRow copyWithCompanion(PayoutsCompanion data) {
    return PayoutRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      periodStartDay: data.periodStartDay.present
          ? data.periodStartDay.value
          : this.periodStartDay,
      periodEndDay: data.periodEndDay.present
          ? data.periodEndDay.value
          : this.periodEndDay,
      earnedMinor: data.earnedMinor.present
          ? data.earnedMinor.value
          : this.earnedMinor,
      adjustmentMinor: data.adjustmentMinor.present
          ? data.adjustmentMinor.value
          : this.adjustmentMinor,
      adjustmentNote: data.adjustmentNote.present
          ? data.adjustmentNote.value
          : this.adjustmentNote,
      deductedMinor: data.deductedMinor.present
          ? data.deductedMinor.value
          : this.deductedMinor,
      netMinor: data.netMinor.present ? data.netMinor.value : this.netMinor,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      note: data.note.present ? data.note.value : this.note,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayoutRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('driverId: $driverId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('periodStartDay: $periodStartDay, ')
          ..write('periodEndDay: $periodEndDay, ')
          ..write('earnedMinor: $earnedMinor, ')
          ..write('adjustmentMinor: $adjustmentMinor, ')
          ..write('adjustmentNote: $adjustmentNote, ')
          ..write('deductedMinor: $deductedMinor, ')
          ..write('netMinor: $netMinor, ')
          ..write('paidAt: $paidAt, ')
          ..write('note: $note, ')
          ..write('periodKey: $periodKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    driverId,
    assignmentId,
    periodStartDay,
    periodEndDay,
    earnedMinor,
    adjustmentMinor,
    adjustmentNote,
    deductedMinor,
    netMinor,
    paidAt,
    note,
    periodKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayoutRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.dirty == this.dirty &&
          other.driverId == this.driverId &&
          other.assignmentId == this.assignmentId &&
          other.periodStartDay == this.periodStartDay &&
          other.periodEndDay == this.periodEndDay &&
          other.earnedMinor == this.earnedMinor &&
          other.adjustmentMinor == this.adjustmentMinor &&
          other.adjustmentNote == this.adjustmentNote &&
          other.deductedMinor == this.deductedMinor &&
          other.netMinor == this.netMinor &&
          other.paidAt == this.paidAt &&
          other.note == this.note &&
          other.periodKey == this.periodKey);
}

class PayoutsCompanion extends UpdateCompanion<PayoutRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<bool> dirty;
  final Value<String> driverId;
  final Value<String?> assignmentId;
  final Value<int> periodStartDay;
  final Value<int> periodEndDay;
  final Value<int> earnedMinor;
  final Value<int> adjustmentMinor;
  final Value<String?> adjustmentNote;
  final Value<int> deductedMinor;
  final Value<int> netMinor;
  final Value<int> paidAt;
  final Value<String?> note;
  final Value<String?> periodKey;
  final Value<int> rowid;
  const PayoutsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    this.driverId = const Value.absent(),
    this.assignmentId = const Value.absent(),
    this.periodStartDay = const Value.absent(),
    this.periodEndDay = const Value.absent(),
    this.earnedMinor = const Value.absent(),
    this.adjustmentMinor = const Value.absent(),
    this.adjustmentNote = const Value.absent(),
    this.deductedMinor = const Value.absent(),
    this.netMinor = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.note = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayoutsCompanion.insert({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    required String driverId,
    this.assignmentId = const Value.absent(),
    required int periodStartDay,
    required int periodEndDay,
    required int earnedMinor,
    this.adjustmentMinor = const Value.absent(),
    this.adjustmentNote = const Value.absent(),
    this.deductedMinor = const Value.absent(),
    required int netMinor,
    required int paidAt,
    this.note = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : driverId = Value(driverId),
       periodStartDay = Value(periodStartDay),
       periodEndDay = Value(periodEndDay),
       earnedMinor = Value(earnedMinor),
       netMinor = Value(netMinor),
       paidAt = Value(paidAt);
  static Insertable<PayoutRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<bool>? dirty,
    Expression<String>? driverId,
    Expression<String>? assignmentId,
    Expression<int>? periodStartDay,
    Expression<int>? periodEndDay,
    Expression<int>? earnedMinor,
    Expression<int>? adjustmentMinor,
    Expression<String>? adjustmentNote,
    Expression<int>? deductedMinor,
    Expression<int>? netMinor,
    Expression<int>? paidAt,
    Expression<String>? note,
    Expression<String>? periodKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (dirty != null) 'dirty': dirty,
      if (driverId != null) 'driver_id': driverId,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (periodStartDay != null) 'period_start_day': periodStartDay,
      if (periodEndDay != null) 'period_end_day': periodEndDay,
      if (earnedMinor != null) 'earned_minor': earnedMinor,
      if (adjustmentMinor != null) 'adjustment_minor': adjustmentMinor,
      if (adjustmentNote != null) 'adjustment_note': adjustmentNote,
      if (deductedMinor != null) 'deducted_minor': deductedMinor,
      if (netMinor != null) 'net_minor': netMinor,
      if (paidAt != null) 'paid_at': paidAt,
      if (note != null) 'note': note,
      if (periodKey != null) 'period_key': periodKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayoutsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<bool>? dirty,
    Value<String>? driverId,
    Value<String?>? assignmentId,
    Value<int>? periodStartDay,
    Value<int>? periodEndDay,
    Value<int>? earnedMinor,
    Value<int>? adjustmentMinor,
    Value<String?>? adjustmentNote,
    Value<int>? deductedMinor,
    Value<int>? netMinor,
    Value<int>? paidAt,
    Value<String?>? note,
    Value<String?>? periodKey,
    Value<int>? rowid,
  }) {
    return PayoutsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      dirty: dirty ?? this.dirty,
      driverId: driverId ?? this.driverId,
      assignmentId: assignmentId ?? this.assignmentId,
      periodStartDay: periodStartDay ?? this.periodStartDay,
      periodEndDay: periodEndDay ?? this.periodEndDay,
      earnedMinor: earnedMinor ?? this.earnedMinor,
      adjustmentMinor: adjustmentMinor ?? this.adjustmentMinor,
      adjustmentNote: adjustmentNote ?? this.adjustmentNote,
      deductedMinor: deductedMinor ?? this.deductedMinor,
      netMinor: netMinor ?? this.netMinor,
      paidAt: paidAt ?? this.paidAt,
      note: note ?? this.note,
      periodKey: periodKey ?? this.periodKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (assignmentId.present) {
      map['assignment_id'] = Variable<String>(assignmentId.value);
    }
    if (periodStartDay.present) {
      map['period_start_day'] = Variable<int>(periodStartDay.value);
    }
    if (periodEndDay.present) {
      map['period_end_day'] = Variable<int>(periodEndDay.value);
    }
    if (earnedMinor.present) {
      map['earned_minor'] = Variable<int>(earnedMinor.value);
    }
    if (adjustmentMinor.present) {
      map['adjustment_minor'] = Variable<int>(adjustmentMinor.value);
    }
    if (adjustmentNote.present) {
      map['adjustment_note'] = Variable<String>(adjustmentNote.value);
    }
    if (deductedMinor.present) {
      map['deducted_minor'] = Variable<int>(deductedMinor.value);
    }
    if (netMinor.present) {
      map['net_minor'] = Variable<int>(netMinor.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<int>(paidAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayoutsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('driverId: $driverId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('periodStartDay: $periodStartDay, ')
          ..write('periodEndDay: $periodEndDay, ')
          ..write('earnedMinor: $earnedMinor, ')
          ..write('adjustmentMinor: $adjustmentMinor, ')
          ..write('adjustmentNote: $adjustmentNote, ')
          ..write('deductedMinor: $deductedMinor, ')
          ..write('netMinor: $netMinor, ')
          ..write('paidAt: $paidAt, ')
          ..write('note: $note, ')
          ..write('periodKey: $periodKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayoutAdvanceAllocationsTable extends PayoutAdvanceAllocations
    with TableInfo<$PayoutAdvanceAllocationsTable, PayoutAllocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayoutAdvanceAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: utcNowMs,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _payoutIdMeta = const VerificationMeta(
    'payoutId',
  );
  @override
  late final GeneratedColumn<String> payoutId = GeneratedColumn<String>(
    'payout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payouts (id)',
    ),
  );
  static const VerificationMeta _advanceIdMeta = const VerificationMeta(
    'advanceId',
  );
  @override
  late final GeneratedColumn<String> advanceId = GeneratedColumn<String>(
    'advance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES advances (id)',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    payoutId,
    advanceId,
    amountMinor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payout_advance_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayoutAllocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('payout_id')) {
      context.handle(
        _payoutIdMeta,
        payoutId.isAcceptableOrUnknown(data['payout_id']!, _payoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_payoutIdMeta);
    }
    if (data.containsKey('advance_id')) {
      context.handle(
        _advanceIdMeta,
        advanceId.isAcceptableOrUnknown(data['advance_id']!, _advanceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_advanceIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayoutAllocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayoutAllocationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      payoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payout_id'],
      )!,
      advanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}advance_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
    );
  }

  @override
  $PayoutAdvanceAllocationsTable createAlias(String alias) {
    return $PayoutAdvanceAllocationsTable(attachedDatabase, alias);
  }
}

class PayoutAllocationRow extends DataClass
    implements Insertable<PayoutAllocationRow> {
  final String id;

  /// Tenant key. `local` until the user signs in and the data is claimed.
  final String ownerId;

  /// Epoch milliseconds, UTC.
  final int createdAt;
  final int updatedAt;

  /// Tombstone; non-null means soft-deleted.
  final int? deletedAt;

  /// Local monotonic revision, bumped on every write.
  final int rev;

  /// True while the row has changes not yet pushed.
  final bool dirty;
  final String payoutId;
  final String advanceId;
  final int amountMinor;
  const PayoutAllocationRow({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.dirty,
    required this.payoutId,
    required this.advanceId,
    required this.amountMinor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['dirty'] = Variable<bool>(dirty);
    map['payout_id'] = Variable<String>(payoutId);
    map['advance_id'] = Variable<String>(advanceId);
    map['amount_minor'] = Variable<int>(amountMinor);
    return map;
  }

  PayoutAdvanceAllocationsCompanion toCompanion(bool nullToAbsent) {
    return PayoutAdvanceAllocationsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      dirty: Value(dirty),
      payoutId: Value(payoutId),
      advanceId: Value(advanceId),
      amountMinor: Value(amountMinor),
    );
  }

  factory PayoutAllocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayoutAllocationRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      payoutId: serializer.fromJson<String>(json['payoutId']),
      advanceId: serializer.fromJson<String>(json['advanceId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'dirty': serializer.toJson<bool>(dirty),
      'payoutId': serializer.toJson<String>(payoutId),
      'advanceId': serializer.toJson<String>(advanceId),
      'amountMinor': serializer.toJson<int>(amountMinor),
    };
  }

  PayoutAllocationRow copyWith({
    String? id,
    String? ownerId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    bool? dirty,
    String? payoutId,
    String? advanceId,
    int? amountMinor,
  }) => PayoutAllocationRow(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    dirty: dirty ?? this.dirty,
    payoutId: payoutId ?? this.payoutId,
    advanceId: advanceId ?? this.advanceId,
    amountMinor: amountMinor ?? this.amountMinor,
  );
  PayoutAllocationRow copyWithCompanion(
    PayoutAdvanceAllocationsCompanion data,
  ) {
    return PayoutAllocationRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      payoutId: data.payoutId.present ? data.payoutId.value : this.payoutId,
      advanceId: data.advanceId.present ? data.advanceId.value : this.advanceId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayoutAllocationRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('payoutId: $payoutId, ')
          ..write('advanceId: $advanceId, ')
          ..write('amountMinor: $amountMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    dirty,
    payoutId,
    advanceId,
    amountMinor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayoutAllocationRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.dirty == this.dirty &&
          other.payoutId == this.payoutId &&
          other.advanceId == this.advanceId &&
          other.amountMinor == this.amountMinor);
}

class PayoutAdvanceAllocationsCompanion
    extends UpdateCompanion<PayoutAllocationRow> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<bool> dirty;
  final Value<String> payoutId;
  final Value<String> advanceId;
  final Value<int> amountMinor;
  final Value<int> rowid;
  const PayoutAdvanceAllocationsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    this.payoutId = const Value.absent(),
    this.advanceId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayoutAdvanceAllocationsCompanion.insert({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.dirty = const Value.absent(),
    required String payoutId,
    required String advanceId,
    required int amountMinor,
    this.rowid = const Value.absent(),
  }) : payoutId = Value(payoutId),
       advanceId = Value(advanceId),
       amountMinor = Value(amountMinor);
  static Insertable<PayoutAllocationRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<bool>? dirty,
    Expression<String>? payoutId,
    Expression<String>? advanceId,
    Expression<int>? amountMinor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (dirty != null) 'dirty': dirty,
      if (payoutId != null) 'payout_id': payoutId,
      if (advanceId != null) 'advance_id': advanceId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayoutAdvanceAllocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<bool>? dirty,
    Value<String>? payoutId,
    Value<String>? advanceId,
    Value<int>? amountMinor,
    Value<int>? rowid,
  }) {
    return PayoutAdvanceAllocationsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      dirty: dirty ?? this.dirty,
      payoutId: payoutId ?? this.payoutId,
      advanceId: advanceId ?? this.advanceId,
      amountMinor: amountMinor ?? this.amountMinor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (payoutId.present) {
      map['payout_id'] = Variable<String>(payoutId.value);
    }
    if (advanceId.present) {
      map['advance_id'] = Variable<String>(advanceId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayoutAdvanceAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('dirty: $dirty, ')
          ..write('payoutId: $payoutId, ')
          ..write('advanceId: $advanceId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $DriversTable drivers = $DriversTable(this);
  late final $AssignmentsTable assignments = $AssignmentsTable(this);
  late final $AttendanceRecordsTable attendanceRecords =
      $AttendanceRecordsTable(this);
  late final $AdvancesTable advances = $AdvancesTable(this);
  late final $PayoutsTable payouts = $PayoutsTable(this);
  late final $PayoutAdvanceAllocationsTable payoutAdvanceAllocations =
      $PayoutAdvanceAllocationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    auditLogs,
    vehicles,
    drivers,
    assignments,
    attendanceRecords,
    advances,
    payouts,
    payoutAdvanceAllocations,
  ];
}

typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<bool> dirty,
  required String entity,
  required String entityId,
  required String action,
  Value<String> diffJson,
  Value<int> at,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<bool> dirty,
  Value<String> entity,
  Value<String> entityId,
  Value<String> action,
  Value<String> diffJson,
  Value<int> at,
  Value<int> rowid,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diffJson => $composableBuilder(
    column: $table.diffJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diffJson => $composableBuilder(
    column: $table.diffJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get diffJson =>
      $composableBuilder(column: $table.diffJson, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> diffJson = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                entity: entity,
                entityId: entityId,
                action: action,
                diffJson: diffJson,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String entity,
                required String entityId,
                required String action,
                Value<String> diffJson = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                entity: entity,
                entityId: entityId,
                action: action,
                diffJson: diffJson,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditLogsTable, AuditLog>(table),
                  BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$VehiclesTableCreateCompanionBuilder = VehiclesCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<bool> dirty,
  required String nickname,
  required VehicleType type,
  Value<String?> regNo,
  Value<String?> regNoKey,
  Value<String?> model,
  Value<int?> year,
  required FuelType fuelType,
  required BusinessModel businessModel,
  Value<VehicleStatus> status,
  Value<bool> archived,
  Value<String?> photoFile,
  Value<int?> purchaseDate,
  Value<int?> purchasePriceMinor,
  Value<int> rowid,
});
typedef $$VehiclesTableUpdateCompanionBuilder = VehiclesCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<bool> dirty,
  Value<String> nickname,
  Value<VehicleType> type,
  Value<String?> regNo,
  Value<String?> regNoKey,
  Value<String?> model,
  Value<int?> year,
  Value<FuelType> fuelType,
  Value<BusinessModel> businessModel,
  Value<VehicleStatus> status,
  Value<bool> archived,
  Value<String?> photoFile,
  Value<int?> purchaseDate,
  Value<int?> purchasePriceMinor,
  Value<int> rowid,
});

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, VehicleRow> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssignmentsTable, List<AssignmentRow>>
  _assignmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assignments,
    aliasName: 'vehicles__id__assignments__vehicle_id',
  );

  $$AssignmentsTableProcessedTableManager get assignmentsRefs {
    final manager = $$AssignmentsTableTableManager(
      $_db,
      $_db.assignments,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_assignmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<VehicleType, VehicleType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get regNo => $composableBuilder(
    column: $table.regNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regNoKey => $composableBuilder(
    column: $table.regNoKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FuelType, FuelType, String> get fuelType =>
      $composableBuilder(
        column: $table.fuelType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<BusinessModel, BusinessModel, String>
  get businessModel => $composableBuilder(
    column: $table.businessModel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<VehicleStatus, VehicleStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoFile => $composableBuilder(
    column: $table.photoFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchasePriceMinor => $composableBuilder(
    column: $table.purchasePriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assignmentsRefs(
    Expression<bool> Function($$AssignmentsTableFilterComposer f) f,
  ) {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assignments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssignmentsTableFilterComposer(
            $db: $db,
            $table: $db.assignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regNo => $composableBuilder(
    column: $table.regNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regNoKey => $composableBuilder(
    column: $table.regNoKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessModel => $composableBuilder(
    column: $table.businessModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoFile => $composableBuilder(
    column: $table.photoFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchasePriceMinor => $composableBuilder(
    column: $table.purchasePriceMinor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumnWithTypeConverter<VehicleType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get regNo =>
      $composableBuilder(column: $table.regNo, builder: (column) => column);

  GeneratedColumn<String> get regNoKey =>
      $composableBuilder(column: $table.regNoKey, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FuelType, String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BusinessModel, String> get businessModel =>
      $composableBuilder(
        column: $table.businessModel,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<VehicleStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get photoFile =>
      $composableBuilder(column: $table.photoFile, builder: (column) => column);

  GeneratedColumn<int> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get purchasePriceMinor => $composableBuilder(
    column: $table.purchasePriceMinor,
    builder: (column) => column,
  );

  Expression<T> assignmentsRefs<T extends Object>(
    Expression<T> Function($$AssignmentsTableAnnotationComposer a) f,
  ) {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assignments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssignmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.assignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          VehicleRow,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (VehicleRow, $$VehiclesTableReferences),
          VehicleRow,
          PrefetchHooks Function({bool assignmentsRefs})
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<VehicleType> type = const Value.absent(),
                Value<String?> regNo = const Value.absent(),
                Value<String?> regNoKey = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<FuelType> fuelType = const Value.absent(),
                Value<BusinessModel> businessModel = const Value.absent(),
                Value<VehicleStatus> status = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> photoFile = const Value.absent(),
                Value<int?> purchaseDate = const Value.absent(),
                Value<int?> purchasePriceMinor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                nickname: nickname,
                type: type,
                regNo: regNo,
                regNoKey: regNoKey,
                model: model,
                year: year,
                fuelType: fuelType,
                businessModel: businessModel,
                status: status,
                archived: archived,
                photoFile: photoFile,
                purchaseDate: purchaseDate,
                purchasePriceMinor: purchasePriceMinor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String nickname,
                required VehicleType type,
                Value<String?> regNo = const Value.absent(),
                Value<String?> regNoKey = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int?> year = const Value.absent(),
                required FuelType fuelType,
                required BusinessModel businessModel,
                Value<VehicleStatus> status = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> photoFile = const Value.absent(),
                Value<int?> purchaseDate = const Value.absent(),
                Value<int?> purchasePriceMinor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                nickname: nickname,
                type: type,
                regNo: regNo,
                regNoKey: regNoKey,
                model: model,
                year: year,
                fuelType: fuelType,
                businessModel: businessModel,
                status: status,
                archived: archived,
                photoFile: photoFile,
                purchaseDate: purchaseDate,
                purchasePriceMinor: purchasePriceMinor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VehiclesTable, VehicleRow>(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assignmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (assignmentsRefs) db.assignments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assignmentsRefs)
                    await $_getPrefetchedData<
                      VehicleRow,
                      $VehiclesTable,
                      AssignmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$VehiclesTableReferences
                          ._assignmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$VehiclesTableReferences(
                        db,
                        table,
                        p0,
                      ).assignmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vehicleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      VehicleRow,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (VehicleRow, $$VehiclesTableReferences),
      VehicleRow,
      PrefetchHooks Function({bool assignmentsRefs})
    >;
typedef $$DriversTableCreateCompanionBuilder = DriversCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<bool> dirty,
  required String name,
  Value<String?> phone,
  Value<String?> licenseNo,
  Value<int?> licenseExpiry,
  Value<String?> nidEncrypted,
  Value<String?> address,
  Value<String?> emergencyContact,
  Value<int?> joinDay,
  Value<String?> photoFile,
  Value<DriverStatus> status,
  Value<int> rowid,
});
typedef $$DriversTableUpdateCompanionBuilder = DriversCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<bool> dirty,
  Value<String> name,
  Value<String?> phone,
  Value<String?> licenseNo,
  Value<int?> licenseExpiry,
  Value<String?> nidEncrypted,
  Value<String?> address,
  Value<String?> emergencyContact,
  Value<int?> joinDay,
  Value<String?> photoFile,
  Value<DriverStatus> status,
  Value<int> rowid,
});

final class $$DriversTableReferences
    extends BaseReferences<_$AppDatabase, $DriversTable, DriverRow> {
  $$DriversTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssignmentsTable, List<AssignmentRow>>
  _assignmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assignments,
    aliasName: 'drivers__id__assignments__driver_id',
  );

  $$AssignmentsTableProcessedTableManager get assignmentsRefs {
    final manager = $$AssignmentsTableTableManager(
      $_db,
      $_db.assignments,
    ).filter((f) => f.driverId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_assignmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttendanceRecordsTable, List<AttendanceRow>>
  _attendanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attendanceRecords,
        aliasName: 'drivers__id__attendance_records__driver_id',
      );

  $$AttendanceRecordsTableProcessedTableManager get attendanceRecordsRefs {
    final manager = $$AttendanceRecordsTableTableManager(
      $_db,
      $_db.attendanceRecords,
    ).filter((f) => f.driverId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attendanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AdvancesTable, List<AdvanceRow>>
  _advancesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.advances,
    aliasName: 'drivers__id__advances__driver_id',
  );

  $$AdvancesTableProcessedTableManager get advancesRefs {
    final manager = $$AdvancesTableTableManager(
      $_db,
      $_db.advances,
    ).filter((f) => f.driverId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_advancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PayoutsTable, List<PayoutRow>> _payoutsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payouts,
    aliasName: 'drivers__id__payouts__driver_id',
  );

  $$PayoutsTableProcessedTableManager get payoutsRefs {
    final manager = $$PayoutsTableTableManager(
      $_db,
      $_db.payouts,
    ).filter((f) => f.driverId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_payoutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DriversTableFilterComposer
    extends Composer<_$AppDatabase, $DriversTable> {
  $$DriversTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseNo => $composableBuilder(
    column: $table.licenseNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get licenseExpiry => $composableBuilder(
    column: $table.licenseExpiry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nidEncrypted => $composableBuilder(
    column: $table.nidEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get joinDay => $composableBuilder(
    column: $table.joinDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoFile => $composableBuilder(
    column: $table.photoFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DriverStatus, DriverStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> assignmentsRefs(
    Expression<bool> Function($$AssignmentsTableFilterComposer f) f,
  ) {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assignments,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssignmentsTableFilterComposer(
            $db: $db,
            $table: $db.assignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attendanceRecordsRefs(
    Expression<bool> Function($$AttendanceRecordsTableFilterComposer f) f,
  ) {
    final $$AttendanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceRecords,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> advancesRefs(
    Expression<bool> Function($$AdvancesTableFilterComposer f) f,
  ) {
    final $$AdvancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.advances,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdvancesTableFilterComposer(
            $db: $db,
            $table: $db.advances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> payoutsRefs(
    Expression<bool> Function($$PayoutsTableFilterComposer f) f,
  ) {
    final $$PayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableFilterComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DriversTableOrderingComposer
    extends Composer<_$AppDatabase, $DriversTable> {
  $$DriversTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseNo => $composableBuilder(
    column: $table.licenseNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get licenseExpiry => $composableBuilder(
    column: $table.licenseExpiry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nidEncrypted => $composableBuilder(
    column: $table.nidEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get joinDay => $composableBuilder(
    column: $table.joinDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoFile => $composableBuilder(
    column: $table.photoFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DriversTableAnnotationComposer
    extends Composer<_$AppDatabase, $DriversTable> {
  $$DriversTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get licenseNo =>
      $composableBuilder(column: $table.licenseNo, builder: (column) => column);

  GeneratedColumn<int> get licenseExpiry => $composableBuilder(
    column: $table.licenseExpiry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nidEncrypted => $composableBuilder(
    column: $table.nidEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => column,
  );

  GeneratedColumn<int> get joinDay =>
      $composableBuilder(column: $table.joinDay, builder: (column) => column);

  GeneratedColumn<String> get photoFile =>
      $composableBuilder(column: $table.photoFile, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DriverStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> assignmentsRefs<T extends Object>(
    Expression<T> Function($$AssignmentsTableAnnotationComposer a) f,
  ) {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assignments,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssignmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.assignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attendanceRecordsRefs<T extends Object>(
    Expression<T> Function($$AttendanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attendanceRecords,
          getReferencedColumn: (t) => t.driverId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttendanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.attendanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> advancesRefs<T extends Object>(
    Expression<T> Function($$AdvancesTableAnnotationComposer a) f,
  ) {
    final $$AdvancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.advances,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdvancesTableAnnotationComposer(
            $db: $db,
            $table: $db.advances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> payoutsRefs<T extends Object>(
    Expression<T> Function($$PayoutsTableAnnotationComposer a) f,
  ) {
    final $$PayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.driverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DriversTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DriversTable,
          DriverRow,
          $$DriversTableFilterComposer,
          $$DriversTableOrderingComposer,
          $$DriversTableAnnotationComposer,
          $$DriversTableCreateCompanionBuilder,
          $$DriversTableUpdateCompanionBuilder,
          (DriverRow, $$DriversTableReferences),
          DriverRow,
          PrefetchHooks Function({
            bool assignmentsRefs,
            bool attendanceRecordsRefs,
            bool advancesRefs,
            bool payoutsRefs,
          })
        > {
  $$DriversTableTableManager(_$AppDatabase db, $DriversTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DriversTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DriversTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DriversTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> licenseNo = const Value.absent(),
                Value<int?> licenseExpiry = const Value.absent(),
                Value<String?> nidEncrypted = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> emergencyContact = const Value.absent(),
                Value<int?> joinDay = const Value.absent(),
                Value<String?> photoFile = const Value.absent(),
                Value<DriverStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DriversCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                name: name,
                phone: phone,
                licenseNo: licenseNo,
                licenseExpiry: licenseExpiry,
                nidEncrypted: nidEncrypted,
                address: address,
                emergencyContact: emergencyContact,
                joinDay: joinDay,
                photoFile: photoFile,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> licenseNo = const Value.absent(),
                Value<int?> licenseExpiry = const Value.absent(),
                Value<String?> nidEncrypted = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> emergencyContact = const Value.absent(),
                Value<int?> joinDay = const Value.absent(),
                Value<String?> photoFile = const Value.absent(),
                Value<DriverStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DriversCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                name: name,
                phone: phone,
                licenseNo: licenseNo,
                licenseExpiry: licenseExpiry,
                nidEncrypted: nidEncrypted,
                address: address,
                emergencyContact: emergencyContact,
                joinDay: joinDay,
                photoFile: photoFile,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DriversTable, DriverRow>(table),
                  $$DriversTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                assignmentsRefs = false,
                attendanceRecordsRefs = false,
                advancesRefs = false,
                payoutsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (assignmentsRefs) db.assignments,
                    if (attendanceRecordsRefs) db.attendanceRecords,
                    if (advancesRefs) db.advances,
                    if (payoutsRefs) db.payouts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (assignmentsRefs)
                        await $_getPrefetchedData<
                          DriverRow,
                          $DriversTable,
                          AssignmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$DriversTableReferences
                              ._assignmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DriversTableReferences(
                                db,
                                table,
                                p0,
                              ).assignmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.driverId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attendanceRecordsRefs)
                        await $_getPrefetchedData<
                          DriverRow,
                          $DriversTable,
                          AttendanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$DriversTableReferences
                              ._attendanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DriversTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.driverId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (advancesRefs)
                        await $_getPrefetchedData<
                          DriverRow,
                          $DriversTable,
                          AdvanceRow
                        >(
                          currentTable: table,
                          referencedTable: $$DriversTableReferences
                              ._advancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DriversTableReferences(
                                db,
                                table,
                                p0,
                              ).advancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.driverId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (payoutsRefs)
                        await $_getPrefetchedData<
                          DriverRow,
                          $DriversTable,
                          PayoutRow
                        >(
                          currentTable: table,
                          referencedTable: $$DriversTableReferences
                              ._payoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DriversTableReferences(
                                db,
                                table,
                                p0,
                              ).payoutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.driverId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DriversTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DriversTable,
      DriverRow,
      $$DriversTableFilterComposer,
      $$DriversTableOrderingComposer,
      $$DriversTableAnnotationComposer,
      $$DriversTableCreateCompanionBuilder,
      $$DriversTableUpdateCompanionBuilder,
      (DriverRow, $$DriversTableReferences),
      DriverRow,
      PrefetchHooks Function({
        bool assignmentsRefs,
        bool attendanceRecordsRefs,
        bool advancesRefs,
        bool payoutsRefs,
      })
    >;
typedef $$AssignmentsTableCreateCompanionBuilder =
    AssignmentsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rev,
      Value<bool> dirty,
      required String vehicleId,
      required String driverId,
      required String payModelJson,
      required int startDay,
      Value<int?> endDay,
      Value<String?> activeVehicleKey,
      Value<int> rowid,
    });
typedef $$AssignmentsTableUpdateCompanionBuilder =
    AssignmentsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rev,
      Value<bool> dirty,
      Value<String> vehicleId,
      Value<String> driverId,
      Value<String> payModelJson,
      Value<int> startDay,
      Value<int?> endDay,
      Value<String?> activeVehicleKey,
      Value<int> rowid,
    });

final class $$AssignmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AssignmentsTable, AssignmentRow> {
  $$AssignmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('assignments__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DriversTable _driverIdTable(_$AppDatabase db) =>
      db.drivers.createAlias('assignments__driver_id__drivers__id');

  $$DriversTableProcessedTableManager get driverId {
    final $_column = $_itemColumn<String>('driver_id')!;

    final manager = $$DriversTableTableManager(
      $_db,
      $_db.drivers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_driverIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PayoutsTable, List<PayoutRow>> _payoutsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payouts,
    aliasName: 'assignments__id__payouts__assignment_id',
  );

  $$PayoutsTableProcessedTableManager get payoutsRefs {
    final manager = $$PayoutsTableTableManager(
      $_db,
      $_db.payouts,
    ).filter((f) => f.assignmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_payoutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payModelJson => $composableBuilder(
    column: $table.payModelJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeVehicleKey => $composableBuilder(
    column: $table.activeVehicleKey,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DriversTableFilterComposer get driverId {
    final $$DriversTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableFilterComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> payoutsRefs(
    Expression<bool> Function($$PayoutsTableFilterComposer f) f,
  ) {
    final $$PayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.assignmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableFilterComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payModelJson => $composableBuilder(
    column: $table.payModelJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeVehicleKey => $composableBuilder(
    column: $table.activeVehicleKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DriversTableOrderingComposer get driverId {
    final $$DriversTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableOrderingComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get payModelJson => $composableBuilder(
    column: $table.payModelJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => column);

  GeneratedColumn<int> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => column);

  GeneratedColumn<String> get activeVehicleKey => $composableBuilder(
    column: $table.activeVehicleKey,
    builder: (column) => column,
  );

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DriversTableAnnotationComposer get driverId {
    final $$DriversTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableAnnotationComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> payoutsRefs<T extends Object>(
    Expression<T> Function($$PayoutsTableAnnotationComposer a) f,
  ) {
    final $$PayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.assignmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssignmentsTable,
          AssignmentRow,
          $$AssignmentsTableFilterComposer,
          $$AssignmentsTableOrderingComposer,
          $$AssignmentsTableAnnotationComposer,
          $$AssignmentsTableCreateCompanionBuilder,
          $$AssignmentsTableUpdateCompanionBuilder,
          (AssignmentRow, $$AssignmentsTableReferences),
          AssignmentRow,
          PrefetchHooks Function({
            bool vehicleId,
            bool driverId,
            bool payoutsRefs,
          })
        > {
  $$AssignmentsTableTableManager(_$AppDatabase db, $AssignmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> driverId = const Value.absent(),
                Value<String> payModelJson = const Value.absent(),
                Value<int> startDay = const Value.absent(),
                Value<int?> endDay = const Value.absent(),
                Value<String?> activeVehicleKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssignmentsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                vehicleId: vehicleId,
                driverId: driverId,
                payModelJson: payModelJson,
                startDay: startDay,
                endDay: endDay,
                activeVehicleKey: activeVehicleKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String vehicleId,
                required String driverId,
                required String payModelJson,
                required int startDay,
                Value<int?> endDay = const Value.absent(),
                Value<String?> activeVehicleKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssignmentsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                vehicleId: vehicleId,
                driverId: driverId,
                payModelJson: payModelJson,
                startDay: startDay,
                endDay: endDay,
                activeVehicleKey: activeVehicleKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssignmentsTable, AssignmentRow>(table),
                  $$AssignmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vehicleId = false, driverId = false, payoutsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (payoutsRefs) db.payouts],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vehicleId,
                            referencedTable: $$AssignmentsTableReferences
                                ._vehicleIdTable(db),
                            referencedColumn: $$AssignmentsTableReferences
                                ._vehicleIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (driverId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.driverId,
                            referencedTable: $$AssignmentsTableReferences
                                ._driverIdTable(db),
                            referencedColumn: $$AssignmentsTableReferences
                                ._driverIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (payoutsRefs)
                        await $_getPrefetchedData<
                          AssignmentRow,
                          $AssignmentsTable,
                          PayoutRow
                        >(
                          currentTable: table,
                          referencedTable: $$AssignmentsTableReferences
                              ._payoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssignmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).payoutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assignmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssignmentsTable,
      AssignmentRow,
      $$AssignmentsTableFilterComposer,
      $$AssignmentsTableOrderingComposer,
      $$AssignmentsTableAnnotationComposer,
      $$AssignmentsTableCreateCompanionBuilder,
      $$AssignmentsTableUpdateCompanionBuilder,
      (AssignmentRow, $$AssignmentsTableReferences),
      AssignmentRow,
      PrefetchHooks Function({bool vehicleId, bool driverId, bool payoutsRefs})
    >;
typedef $$AttendanceRecordsTableCreateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rev,
      Value<bool> dirty,
      required String driverId,
      required int day,
      required AttendanceStatus status,
      Value<int> rowid,
    });
typedef $$AttendanceRecordsTableUpdateCompanionBuilder =
    AttendanceRecordsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rev,
      Value<bool> dirty,
      Value<String> driverId,
      Value<int> day,
      Value<AttendanceStatus> status,
      Value<int> rowid,
    });

final class $$AttendanceRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AttendanceRecordsTable, AttendanceRow> {
  $$AttendanceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DriversTable _driverIdTable(_$AppDatabase db) =>
      db.drivers.createAlias('attendance_records__driver_id__drivers__id');

  $$DriversTableProcessedTableManager get driverId {
    final $_column = $_itemColumn<String>('driver_id')!;

    final manager = $$DriversTableTableManager(
      $_db,
      $_db.drivers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_driverIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AttendanceStatus, AttendanceStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$DriversTableFilterComposer get driverId {
    final $$DriversTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableFilterComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$DriversTableOrderingComposer get driverId {
    final $$DriversTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableOrderingComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceRecordsTable> {
  $$AttendanceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AttendanceStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$DriversTableAnnotationComposer get driverId {
    final $$DriversTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableAnnotationComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceRecordsTable,
          AttendanceRow,
          $$AttendanceRecordsTableFilterComposer,
          $$AttendanceRecordsTableOrderingComposer,
          $$AttendanceRecordsTableAnnotationComposer,
          $$AttendanceRecordsTableCreateCompanionBuilder,
          $$AttendanceRecordsTableUpdateCompanionBuilder,
          (AttendanceRow, $$AttendanceRecordsTableReferences),
          AttendanceRow,
          PrefetchHooks Function({bool driverId})
        > {
  $$AttendanceRecordsTableTableManager(
    _$AppDatabase db,
    $AttendanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> driverId = const Value.absent(),
                Value<int> day = const Value.absent(),
                Value<AttendanceStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceRecordsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                driverId: driverId,
                day: day,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String driverId,
                required int day,
                required AttendanceStatus status,
                Value<int> rowid = const Value.absent(),
              }) => AttendanceRecordsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                driverId: driverId,
                day: day,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttendanceRecordsTable, AttendanceRow>(table),
                  $$AttendanceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({driverId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (driverId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.driverId,
                        referencedTable: $$AttendanceRecordsTableReferences
                            ._driverIdTable(db),
                        referencedColumn: $$AttendanceRecordsTableReferences
                            ._driverIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttendanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceRecordsTable,
      AttendanceRow,
      $$AttendanceRecordsTableFilterComposer,
      $$AttendanceRecordsTableOrderingComposer,
      $$AttendanceRecordsTableAnnotationComposer,
      $$AttendanceRecordsTableCreateCompanionBuilder,
      $$AttendanceRecordsTableUpdateCompanionBuilder,
      (AttendanceRow, $$AttendanceRecordsTableReferences),
      AttendanceRow,
      PrefetchHooks Function({bool driverId})
    >;
typedef $$AdvancesTableCreateCompanionBuilder = AdvancesCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<bool> dirty,
  required String driverId,
  required int amountMinor,
  required int givenDay,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$AdvancesTableUpdateCompanionBuilder = AdvancesCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<bool> dirty,
  Value<String> driverId,
  Value<int> amountMinor,
  Value<int> givenDay,
  Value<String?> note,
  Value<int> rowid,
});

final class $$AdvancesTableReferences
    extends BaseReferences<_$AppDatabase, $AdvancesTable, AdvanceRow> {
  $$AdvancesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DriversTable _driverIdTable(_$AppDatabase db) =>
      db.drivers.createAlias('advances__driver_id__drivers__id');

  $$DriversTableProcessedTableManager get driverId {
    final $_column = $_itemColumn<String>('driver_id')!;

    final manager = $$DriversTableTableManager(
      $_db,
      $_db.drivers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_driverIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PayoutAdvanceAllocationsTable,
    List<PayoutAllocationRow>
  >
  _payoutAdvanceAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.payoutAdvanceAllocations,
        aliasName: 'advances__id__payout_advance_allocations__advance_id',
      );

  $$PayoutAdvanceAllocationsTableProcessedTableManager
  get payoutAdvanceAllocationsRefs {
    final manager = $$PayoutAdvanceAllocationsTableTableManager(
      $_db,
      $_db.payoutAdvanceAllocations,
    ).filter((f) => f.advanceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _payoutAdvanceAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AdvancesTableFilterComposer
    extends Composer<_$AppDatabase, $AdvancesTable> {
  $$AdvancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get givenDay => $composableBuilder(
    column: $table.givenDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$DriversTableFilterComposer get driverId {
    final $$DriversTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableFilterComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> payoutAdvanceAllocationsRefs(
    Expression<bool> Function($$PayoutAdvanceAllocationsTableFilterComposer f)
    f,
  ) {
    final $$PayoutAdvanceAllocationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.payoutAdvanceAllocations,
          getReferencedColumn: (t) => t.advanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PayoutAdvanceAllocationsTableFilterComposer(
                $db: $db,
                $table: $db.payoutAdvanceAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AdvancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AdvancesTable> {
  $$AdvancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get givenDay => $composableBuilder(
    column: $table.givenDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$DriversTableOrderingComposer get driverId {
    final $$DriversTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableOrderingComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdvancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdvancesTable> {
  $$AdvancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get givenDay =>
      $composableBuilder(column: $table.givenDay, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$DriversTableAnnotationComposer get driverId {
    final $$DriversTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableAnnotationComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> payoutAdvanceAllocationsRefs<T extends Object>(
    Expression<T> Function($$PayoutAdvanceAllocationsTableAnnotationComposer a)
    f,
  ) {
    final $$PayoutAdvanceAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.payoutAdvanceAllocations,
          getReferencedColumn: (t) => t.advanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PayoutAdvanceAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.payoutAdvanceAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AdvancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdvancesTable,
          AdvanceRow,
          $$AdvancesTableFilterComposer,
          $$AdvancesTableOrderingComposer,
          $$AdvancesTableAnnotationComposer,
          $$AdvancesTableCreateCompanionBuilder,
          $$AdvancesTableUpdateCompanionBuilder,
          (AdvanceRow, $$AdvancesTableReferences),
          AdvanceRow,
          PrefetchHooks Function({
            bool driverId,
            bool payoutAdvanceAllocationsRefs,
          })
        > {
  $$AdvancesTableTableManager(_$AppDatabase db, $AdvancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdvancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdvancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdvancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> driverId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int> givenDay = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdvancesCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                driverId: driverId,
                amountMinor: amountMinor,
                givenDay: givenDay,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String driverId,
                required int amountMinor,
                required int givenDay,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdvancesCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                driverId: driverId,
                amountMinor: amountMinor,
                givenDay: givenDay,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AdvancesTable, AdvanceRow>(table),
                  $$AdvancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({driverId = false, payoutAdvanceAllocationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (payoutAdvanceAllocationsRefs)
                      db.payoutAdvanceAllocations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (driverId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.driverId,
                            referencedTable: $$AdvancesTableReferences
                                ._driverIdTable(db),
                            referencedColumn: $$AdvancesTableReferences
                                ._driverIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (payoutAdvanceAllocationsRefs)
                        await $_getPrefetchedData<
                          AdvanceRow,
                          $AdvancesTable,
                          PayoutAllocationRow
                        >(
                          currentTable: table,
                          referencedTable: $$AdvancesTableReferences
                              ._payoutAdvanceAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AdvancesTableReferences(
                                db,
                                table,
                                p0,
                              ).payoutAdvanceAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.advanceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AdvancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdvancesTable,
      AdvanceRow,
      $$AdvancesTableFilterComposer,
      $$AdvancesTableOrderingComposer,
      $$AdvancesTableAnnotationComposer,
      $$AdvancesTableCreateCompanionBuilder,
      $$AdvancesTableUpdateCompanionBuilder,
      (AdvanceRow, $$AdvancesTableReferences),
      AdvanceRow,
      PrefetchHooks Function({bool driverId, bool payoutAdvanceAllocationsRefs})
    >;
typedef $$PayoutsTableCreateCompanionBuilder = PayoutsCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<bool> dirty,
  required String driverId,
  Value<String?> assignmentId,
  required int periodStartDay,
  required int periodEndDay,
  required int earnedMinor,
  Value<int> adjustmentMinor,
  Value<String?> adjustmentNote,
  Value<int> deductedMinor,
  required int netMinor,
  required int paidAt,
  Value<String?> note,
  Value<String?> periodKey,
  Value<int> rowid,
});
typedef $$PayoutsTableUpdateCompanionBuilder = PayoutsCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<bool> dirty,
  Value<String> driverId,
  Value<String?> assignmentId,
  Value<int> periodStartDay,
  Value<int> periodEndDay,
  Value<int> earnedMinor,
  Value<int> adjustmentMinor,
  Value<String?> adjustmentNote,
  Value<int> deductedMinor,
  Value<int> netMinor,
  Value<int> paidAt,
  Value<String?> note,
  Value<String?> periodKey,
  Value<int> rowid,
});

final class $$PayoutsTableReferences
    extends BaseReferences<_$AppDatabase, $PayoutsTable, PayoutRow> {
  $$PayoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DriversTable _driverIdTable(_$AppDatabase db) =>
      db.drivers.createAlias('payouts__driver_id__drivers__id');

  $$DriversTableProcessedTableManager get driverId {
    final $_column = $_itemColumn<String>('driver_id')!;

    final manager = $$DriversTableTableManager(
      $_db,
      $_db.drivers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_driverIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssignmentsTable _assignmentIdTable(_$AppDatabase db) =>
      db.assignments.createAlias('payouts__assignment_id__assignments__id');

  $$AssignmentsTableProcessedTableManager? get assignmentId {
    final $_column = $_itemColumn<String>('assignment_id');
    if ($_column == null) return null;
    final manager = $$AssignmentsTableTableManager(
      $_db,
      $_db.assignments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assignmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PayoutAdvanceAllocationsTable,
    List<PayoutAllocationRow>
  >
  _payoutAdvanceAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.payoutAdvanceAllocations,
        aliasName: 'payouts__id__payout_advance_allocations__payout_id',
      );

  $$PayoutAdvanceAllocationsTableProcessedTableManager
  get payoutAdvanceAllocationsRefs {
    final manager = $$PayoutAdvanceAllocationsTableTableManager(
      $_db,
      $_db.payoutAdvanceAllocations,
    ).filter((f) => f.payoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _payoutAdvanceAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PayoutsTableFilterComposer
    extends Composer<_$AppDatabase, $PayoutsTable> {
  $$PayoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodStartDay => $composableBuilder(
    column: $table.periodStartDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodEndDay => $composableBuilder(
    column: $table.periodEndDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get earnedMinor => $composableBuilder(
    column: $table.earnedMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get adjustmentMinor => $composableBuilder(
    column: $table.adjustmentMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adjustmentNote => $composableBuilder(
    column: $table.adjustmentNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deductedMinor => $composableBuilder(
    column: $table.deductedMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netMinor => $composableBuilder(
    column: $table.netMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  $$DriversTableFilterComposer get driverId {
    final $$DriversTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableFilterComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssignmentsTableFilterComposer get assignmentId {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assignmentId,
      referencedTable: $db.assignments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssignmentsTableFilterComposer(
            $db: $db,
            $table: $db.assignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> payoutAdvanceAllocationsRefs(
    Expression<bool> Function($$PayoutAdvanceAllocationsTableFilterComposer f)
    f,
  ) {
    final $$PayoutAdvanceAllocationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.payoutAdvanceAllocations,
          getReferencedColumn: (t) => t.payoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PayoutAdvanceAllocationsTableFilterComposer(
                $db: $db,
                $table: $db.payoutAdvanceAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PayoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $PayoutsTable> {
  $$PayoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodStartDay => $composableBuilder(
    column: $table.periodStartDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodEndDay => $composableBuilder(
    column: $table.periodEndDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earnedMinor => $composableBuilder(
    column: $table.earnedMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get adjustmentMinor => $composableBuilder(
    column: $table.adjustmentMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjustmentNote => $composableBuilder(
    column: $table.adjustmentNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deductedMinor => $composableBuilder(
    column: $table.deductedMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netMinor => $composableBuilder(
    column: $table.netMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$DriversTableOrderingComposer get driverId {
    final $$DriversTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableOrderingComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssignmentsTableOrderingComposer get assignmentId {
    final $$AssignmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assignmentId,
      referencedTable: $db.assignments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssignmentsTableOrderingComposer(
            $db: $db,
            $table: $db.assignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayoutsTable> {
  $$PayoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get periodStartDay => $composableBuilder(
    column: $table.periodStartDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodEndDay => $composableBuilder(
    column: $table.periodEndDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get earnedMinor => $composableBuilder(
    column: $table.earnedMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get adjustmentMinor => $composableBuilder(
    column: $table.adjustmentMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adjustmentNote => $composableBuilder(
    column: $table.adjustmentNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deductedMinor => $composableBuilder(
    column: $table.deductedMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get netMinor =>
      $composableBuilder(column: $table.netMinor, builder: (column) => column);

  GeneratedColumn<int> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  $$DriversTableAnnotationComposer get driverId {
    final $$DriversTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.driverId,
      referencedTable: $db.drivers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DriversTableAnnotationComposer(
            $db: $db,
            $table: $db.drivers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssignmentsTableAnnotationComposer get assignmentId {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assignmentId,
      referencedTable: $db.assignments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssignmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.assignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> payoutAdvanceAllocationsRefs<T extends Object>(
    Expression<T> Function($$PayoutAdvanceAllocationsTableAnnotationComposer a)
    f,
  ) {
    final $$PayoutAdvanceAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.payoutAdvanceAllocations,
          getReferencedColumn: (t) => t.payoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PayoutAdvanceAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.payoutAdvanceAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PayoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayoutsTable,
          PayoutRow,
          $$PayoutsTableFilterComposer,
          $$PayoutsTableOrderingComposer,
          $$PayoutsTableAnnotationComposer,
          $$PayoutsTableCreateCompanionBuilder,
          $$PayoutsTableUpdateCompanionBuilder,
          (PayoutRow, $$PayoutsTableReferences),
          PayoutRow,
          PrefetchHooks Function({
            bool driverId,
            bool assignmentId,
            bool payoutAdvanceAllocationsRefs,
          })
        > {
  $$PayoutsTableTableManager(_$AppDatabase db, $PayoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> driverId = const Value.absent(),
                Value<String?> assignmentId = const Value.absent(),
                Value<int> periodStartDay = const Value.absent(),
                Value<int> periodEndDay = const Value.absent(),
                Value<int> earnedMinor = const Value.absent(),
                Value<int> adjustmentMinor = const Value.absent(),
                Value<String?> adjustmentNote = const Value.absent(),
                Value<int> deductedMinor = const Value.absent(),
                Value<int> netMinor = const Value.absent(),
                Value<int> paidAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> periodKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayoutsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                driverId: driverId,
                assignmentId: assignmentId,
                periodStartDay: periodStartDay,
                periodEndDay: periodEndDay,
                earnedMinor: earnedMinor,
                adjustmentMinor: adjustmentMinor,
                adjustmentNote: adjustmentNote,
                deductedMinor: deductedMinor,
                netMinor: netMinor,
                paidAt: paidAt,
                note: note,
                periodKey: periodKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String driverId,
                Value<String?> assignmentId = const Value.absent(),
                required int periodStartDay,
                required int periodEndDay,
                required int earnedMinor,
                Value<int> adjustmentMinor = const Value.absent(),
                Value<String?> adjustmentNote = const Value.absent(),
                Value<int> deductedMinor = const Value.absent(),
                required int netMinor,
                required int paidAt,
                Value<String?> note = const Value.absent(),
                Value<String?> periodKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayoutsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                driverId: driverId,
                assignmentId: assignmentId,
                periodStartDay: periodStartDay,
                periodEndDay: periodEndDay,
                earnedMinor: earnedMinor,
                adjustmentMinor: adjustmentMinor,
                adjustmentNote: adjustmentNote,
                deductedMinor: deductedMinor,
                netMinor: netMinor,
                paidAt: paidAt,
                note: note,
                periodKey: periodKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PayoutsTable, PayoutRow>(table),
                  $$PayoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                driverId = false,
                assignmentId = false,
                payoutAdvanceAllocationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (payoutAdvanceAllocationsRefs)
                      db.payoutAdvanceAllocations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (driverId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.driverId,
                            referencedTable: $$PayoutsTableReferences
                                ._driverIdTable(db),
                            referencedColumn: $$PayoutsTableReferences
                                ._driverIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (assignmentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.assignmentId,
                            referencedTable: $$PayoutsTableReferences
                                ._assignmentIdTable(db),
                            referencedColumn: $$PayoutsTableReferences
                                ._assignmentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (payoutAdvanceAllocationsRefs)
                        await $_getPrefetchedData<
                          PayoutRow,
                          $PayoutsTable,
                          PayoutAllocationRow
                        >(
                          currentTable: table,
                          referencedTable: $$PayoutsTableReferences
                              ._payoutAdvanceAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PayoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).payoutAdvanceAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.payoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PayoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayoutsTable,
      PayoutRow,
      $$PayoutsTableFilterComposer,
      $$PayoutsTableOrderingComposer,
      $$PayoutsTableAnnotationComposer,
      $$PayoutsTableCreateCompanionBuilder,
      $$PayoutsTableUpdateCompanionBuilder,
      (PayoutRow, $$PayoutsTableReferences),
      PayoutRow,
      PrefetchHooks Function({
        bool driverId,
        bool assignmentId,
        bool payoutAdvanceAllocationsRefs,
      })
    >;
typedef $$PayoutAdvanceAllocationsTableCreateCompanionBuilder =
    PayoutAdvanceAllocationsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rev,
      Value<bool> dirty,
      required String payoutId,
      required String advanceId,
      required int amountMinor,
      Value<int> rowid,
    });
typedef $$PayoutAdvanceAllocationsTableUpdateCompanionBuilder =
    PayoutAdvanceAllocationsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rev,
      Value<bool> dirty,
      Value<String> payoutId,
      Value<String> advanceId,
      Value<int> amountMinor,
      Value<int> rowid,
    });

final class $$PayoutAdvanceAllocationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PayoutAdvanceAllocationsTable,
          PayoutAllocationRow
        > {
  $$PayoutAdvanceAllocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PayoutsTable _payoutIdTable(_$AppDatabase db) => db.payouts
      .createAlias('payout_advance_allocations__payout_id__payouts__id');

  $$PayoutsTableProcessedTableManager get payoutId {
    final $_column = $_itemColumn<String>('payout_id')!;

    final manager = $$PayoutsTableTableManager(
      $_db,
      $_db.payouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_payoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AdvancesTable _advanceIdTable(_$AppDatabase db) => db.advances
      .createAlias('payout_advance_allocations__advance_id__advances__id');

  $$AdvancesTableProcessedTableManager get advanceId {
    final $_column = $_itemColumn<String>('advance_id')!;

    final manager = $$AdvancesTableTableManager(
      $_db,
      $_db.advances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_advanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PayoutAdvanceAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $PayoutAdvanceAllocationsTable> {
  $$PayoutAdvanceAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  $$PayoutsTableFilterComposer get payoutId {
    final $$PayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payoutId,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableFilterComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AdvancesTableFilterComposer get advanceId {
    final $$AdvancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.advanceId,
      referencedTable: $db.advances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdvancesTableFilterComposer(
            $db: $db,
            $table: $db.advances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayoutAdvanceAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PayoutAdvanceAllocationsTable> {
  $$PayoutAdvanceAllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  $$PayoutsTableOrderingComposer get payoutId {
    final $$PayoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payoutId,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableOrderingComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AdvancesTableOrderingComposer get advanceId {
    final $$AdvancesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.advanceId,
      referencedTable: $db.advances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdvancesTableOrderingComposer(
            $db: $db,
            $table: $db.advances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayoutAdvanceAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayoutAdvanceAllocationsTable> {
  $$PayoutAdvanceAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  $$PayoutsTableAnnotationComposer get payoutId {
    final $$PayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.payoutId,
      referencedTable: $db.payouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.payouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AdvancesTableAnnotationComposer get advanceId {
    final $$AdvancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.advanceId,
      referencedTable: $db.advances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdvancesTableAnnotationComposer(
            $db: $db,
            $table: $db.advances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayoutAdvanceAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayoutAdvanceAllocationsTable,
          PayoutAllocationRow,
          $$PayoutAdvanceAllocationsTableFilterComposer,
          $$PayoutAdvanceAllocationsTableOrderingComposer,
          $$PayoutAdvanceAllocationsTableAnnotationComposer,
          $$PayoutAdvanceAllocationsTableCreateCompanionBuilder,
          $$PayoutAdvanceAllocationsTableUpdateCompanionBuilder,
          (PayoutAllocationRow, $$PayoutAdvanceAllocationsTableReferences),
          PayoutAllocationRow,
          PrefetchHooks Function({bool payoutId, bool advanceId})
        > {
  $$PayoutAdvanceAllocationsTableTableManager(
    _$AppDatabase db,
    $PayoutAdvanceAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayoutAdvanceAllocationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PayoutAdvanceAllocationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PayoutAdvanceAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<String> payoutId = const Value.absent(),
                Value<String> advanceId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayoutAdvanceAllocationsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                payoutId: payoutId,
                advanceId: advanceId,
                amountMinor: amountMinor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                required String payoutId,
                required String advanceId,
                required int amountMinor,
                Value<int> rowid = const Value.absent(),
              }) => PayoutAdvanceAllocationsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                dirty: dirty,
                payoutId: payoutId,
                advanceId: advanceId,
                amountMinor: amountMinor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PayoutAdvanceAllocationsTable,
                    PayoutAllocationRow
                  >(table),
                  $$PayoutAdvanceAllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({payoutId = false, advanceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (payoutId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.payoutId,
                        referencedTable:
                            $$PayoutAdvanceAllocationsTableReferences
                                ._payoutIdTable(db),
                        referencedColumn:
                            $$PayoutAdvanceAllocationsTableReferences
                                ._payoutIdTable(db)
                                .id,
                      ) as T;
                    }
                    if (advanceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.advanceId,
                        referencedTable:
                            $$PayoutAdvanceAllocationsTableReferences
                                ._advanceIdTable(db),
                        referencedColumn:
                            $$PayoutAdvanceAllocationsTableReferences
                                ._advanceIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PayoutAdvanceAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayoutAdvanceAllocationsTable,
      PayoutAllocationRow,
      $$PayoutAdvanceAllocationsTableFilterComposer,
      $$PayoutAdvanceAllocationsTableOrderingComposer,
      $$PayoutAdvanceAllocationsTableAnnotationComposer,
      $$PayoutAdvanceAllocationsTableCreateCompanionBuilder,
      $$PayoutAdvanceAllocationsTableUpdateCompanionBuilder,
      (PayoutAllocationRow, $$PayoutAdvanceAllocationsTableReferences),
      PayoutAllocationRow,
      PrefetchHooks Function({bool payoutId, bool advanceId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$DriversTableTableManager get drivers =>
      $$DriversTableTableManager(_db, _db.drivers);
  $$AssignmentsTableTableManager get assignments =>
      $$AssignmentsTableTableManager(_db, _db.assignments);
  $$AttendanceRecordsTableTableManager get attendanceRecords =>
      $$AttendanceRecordsTableTableManager(_db, _db.attendanceRecords);
  $$AdvancesTableTableManager get advances =>
      $$AdvancesTableTableManager(_db, _db.advances);
  $$PayoutsTableTableManager get payouts =>
      $$PayoutsTableTableManager(_db, _db.payouts);
  $$PayoutAdvanceAllocationsTableTableManager get payoutAdvanceAllocations =>
      $$PayoutAdvanceAllocationsTableTableManager(
        _db,
        _db.payoutAdvanceAllocations,
      );
}
