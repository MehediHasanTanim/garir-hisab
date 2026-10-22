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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [auditLogs, vehicles];
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
          (
            VehicleRow,
            BaseReferences<_$AppDatabase, $VehiclesTable, VehicleRow>,
          ),
          VehicleRow,
          PrefetchHooks Function()
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
                  BaseReferences<_$AppDatabase, $VehiclesTable, VehicleRow>(
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
      (VehicleRow, BaseReferences<_$AppDatabase, $VehiclesTable, VehicleRow>),
      VehicleRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
}
