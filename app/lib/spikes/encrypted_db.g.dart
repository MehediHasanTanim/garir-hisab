// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encrypted_db.dart';

// ignore_for_file: type=lint
class $SpikeRowsTable extends SpikeRows
    with TableInfo<$SpikeRowsTable, SpikeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpikeRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [id, label, amountMinor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spike_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpikeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
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
  SpikeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpikeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
    );
  }

  @override
  $SpikeRowsTable createAlias(String alias) {
    return $SpikeRowsTable(attachedDatabase, alias);
  }
}

class SpikeRow extends DataClass implements Insertable<SpikeRow> {
  final int id;
  final String label;
  final int amountMinor;
  const SpikeRow({
    required this.id,
    required this.label,
    required this.amountMinor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['amount_minor'] = Variable<int>(amountMinor);
    return map;
  }

  SpikeRowsCompanion toCompanion(bool nullToAbsent) {
    return SpikeRowsCompanion(
      id: Value(id),
      label: Value(label),
      amountMinor: Value(amountMinor),
    );
  }

  factory SpikeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpikeRow(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'amountMinor': serializer.toJson<int>(amountMinor),
    };
  }

  SpikeRow copyWith({int? id, String? label, int? amountMinor}) => SpikeRow(
    id: id ?? this.id,
    label: label ?? this.label,
    amountMinor: amountMinor ?? this.amountMinor,
  );
  SpikeRow copyWithCompanion(SpikeRowsCompanion data) {
    return SpikeRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpikeRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('amountMinor: $amountMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, amountMinor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpikeRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.amountMinor == this.amountMinor);
}

class SpikeRowsCompanion extends UpdateCompanion<SpikeRow> {
  final Value<int> id;
  final Value<String> label;
  final Value<int> amountMinor;
  const SpikeRowsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.amountMinor = const Value.absent(),
  });
  SpikeRowsCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required int amountMinor,
  }) : label = Value(label),
       amountMinor = Value(amountMinor);
  static Insertable<SpikeRow> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<int>? amountMinor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (amountMinor != null) 'amount_minor': amountMinor,
    });
  }

  SpikeRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<int>? amountMinor,
  }) {
    return SpikeRowsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      amountMinor: amountMinor ?? this.amountMinor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpikeRowsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('amountMinor: $amountMinor')
          ..write(')'))
        .toString();
  }
}

abstract class _$SpikeDatabase extends GeneratedDatabase {
  _$SpikeDatabase(QueryExecutor e) : super(e);
  $SpikeDatabaseManager get managers => $SpikeDatabaseManager(this);
  late final $SpikeRowsTable spikeRows = $SpikeRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [spikeRows];
}

typedef $$SpikeRowsTableCreateCompanionBuilder = SpikeRowsCompanion Function({
  Value<int> id,
  required String label,
  required int amountMinor,
});
typedef $$SpikeRowsTableUpdateCompanionBuilder = SpikeRowsCompanion Function({
  Value<int> id,
  Value<String> label,
  Value<int> amountMinor,
});

class $$SpikeRowsTableFilterComposer
    extends Composer<_$SpikeDatabase, $SpikeRowsTable> {
  $$SpikeRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpikeRowsTableOrderingComposer
    extends Composer<_$SpikeDatabase, $SpikeRowsTable> {
  $$SpikeRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpikeRowsTableAnnotationComposer
    extends Composer<_$SpikeDatabase, $SpikeRowsTable> {
  $$SpikeRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );
}

class $$SpikeRowsTableTableManager
    extends
        RootTableManager<
          _$SpikeDatabase,
          $SpikeRowsTable,
          SpikeRow,
          $$SpikeRowsTableFilterComposer,
          $$SpikeRowsTableOrderingComposer,
          $$SpikeRowsTableAnnotationComposer,
          $$SpikeRowsTableCreateCompanionBuilder,
          $$SpikeRowsTableUpdateCompanionBuilder,
          (
            SpikeRow,
            BaseReferences<_$SpikeDatabase, $SpikeRowsTable, SpikeRow>,
          ),
          SpikeRow,
          PrefetchHooks Function()
        > {
  $$SpikeRowsTableTableManager(_$SpikeDatabase db, $SpikeRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpikeRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpikeRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpikeRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
              }) => SpikeRowsCompanion(
                id: id,
                label: label,
                amountMinor: amountMinor,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required int amountMinor,
              }) => SpikeRowsCompanion.insert(
                id: id,
                label: label,
                amountMinor: amountMinor,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpikeRowsTable, SpikeRow>(table),
                  BaseReferences<_$SpikeDatabase, $SpikeRowsTable, SpikeRow>(
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

typedef $$SpikeRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$SpikeDatabase,
      $SpikeRowsTable,
      SpikeRow,
      $$SpikeRowsTableFilterComposer,
      $$SpikeRowsTableOrderingComposer,
      $$SpikeRowsTableAnnotationComposer,
      $$SpikeRowsTableCreateCompanionBuilder,
      $$SpikeRowsTableUpdateCompanionBuilder,
      (SpikeRow, BaseReferences<_$SpikeDatabase, $SpikeRowsTable, SpikeRow>),
      SpikeRow,
      PrefetchHooks Function()
    >;

class $SpikeDatabaseManager {
  final _$SpikeDatabase _db;
  $SpikeDatabaseManager(this._db);
  $$SpikeRowsTableTableManager get spikeRows =>
      $$SpikeRowsTableTableManager(_db, _db.spikeRows);
}
