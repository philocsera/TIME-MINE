// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _taskNameMeta = const VerificationMeta(
    'taskName',
  );
  @override
  late final GeneratedColumn<String> taskName = GeneratedColumn<String>(
    'task_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<bool> mode = GeneratedColumn<bool>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskName,
    startAt,
    endAt,
    mode,
    durationSec,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_name')) {
      context.handle(
        _taskNameMeta,
        taskName.isAcceptableOrUnknown(data['task_name']!, _taskNameMeta),
      );
    } else if (isInserting) {
      context.missing(_taskNameMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_name'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mode'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String taskName;
  final DateTime startAt;
  final DateTime endAt;
  final bool mode;
  final int durationSec;
  const Session({
    required this.id,
    required this.taskName,
    required this.startAt,
    required this.endAt,
    required this.mode,
    required this.durationSec,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_name'] = Variable<String>(taskName);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    map['mode'] = Variable<bool>(mode);
    map['duration_sec'] = Variable<int>(durationSec);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      taskName: Value(taskName),
      startAt: Value(startAt),
      endAt: Value(endAt),
      mode: Value(mode),
      durationSec: Value(durationSec),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      taskName: serializer.fromJson<String>(json['taskName']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      mode: serializer.fromJson<bool>(json['mode']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskName': serializer.toJson<String>(taskName),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'mode': serializer.toJson<bool>(mode),
      'durationSec': serializer.toJson<int>(durationSec),
    };
  }

  Session copyWith({
    int? id,
    String? taskName,
    DateTime? startAt,
    DateTime? endAt,
    bool? mode,
    int? durationSec,
  }) => Session(
    id: id ?? this.id,
    taskName: taskName ?? this.taskName,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    mode: mode ?? this.mode,
    durationSec: durationSec ?? this.durationSec,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      taskName: data.taskName.present ? data.taskName.value : this.taskName,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      mode: data.mode.present ? data.mode.value : this.mode,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('taskName: $taskName, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('mode: $mode, ')
          ..write('durationSec: $durationSec')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, taskName, startAt, endAt, mode, durationSec);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.taskName == this.taskName &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.mode == this.mode &&
          other.durationSec == this.durationSec);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> taskName;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<bool> mode;
  final Value<int> durationSec;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.taskName = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.mode = const Value.absent(),
    this.durationSec = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String taskName,
    required DateTime startAt,
    required DateTime endAt,
    this.mode = const Value.absent(),
    this.durationSec = const Value.absent(),
  }) : taskName = Value(taskName),
       startAt = Value(startAt),
       endAt = Value(endAt);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? taskName,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<bool>? mode,
    Expression<int>? durationSec,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskName != null) 'task_name': taskName,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (mode != null) 'mode': mode,
      if (durationSec != null) 'duration_sec': durationSec,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? taskName,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<bool>? mode,
    Value<int>? durationSec,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      mode: mode ?? this.mode,
      durationSec: durationSec ?? this.durationSec,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskName.present) {
      map['task_name'] = Variable<String>(taskName.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (mode.present) {
      map['mode'] = Variable<bool>(mode.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('taskName: $taskName, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('mode: $mode, ')
          ..write('durationSec: $durationSec')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDB extends GeneratedDatabase {
  _$AppDB(QueryExecutor e) : super(e);
  $AppDBManager get managers => $AppDBManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sessions];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required String taskName,
      required DateTime startAt,
      required DateTime endAt,
      Value<bool> mode,
      Value<int> durationSec,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String> taskName,
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<bool> mode,
      Value<int> durationSec,
    });

class $$SessionsTableFilterComposer extends Composer<_$AppDB, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get taskName => $composableBuilder(
    column: $table.taskName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDB, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get taskName => $composableBuilder(
    column: $table.taskName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDB, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskName =>
      $composableBuilder(column: $table.taskName, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<bool> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDB,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDB, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDB db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> taskName = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<bool> mode = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                taskName: taskName,
                startAt: startAt,
                endAt: endAt,
                mode: mode,
                durationSec: durationSec,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String taskName,
                required DateTime startAt,
                required DateTime endAt,
                Value<bool> mode = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                taskName: taskName,
                startAt: startAt,
                endAt: endAt,
                mode: mode,
                durationSec: durationSec,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDB,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDB, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;

class $AppDBManager {
  final _$AppDB _db;
  $AppDBManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
}
