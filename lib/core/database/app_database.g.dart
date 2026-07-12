// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SavedStoryEntriesTable extends SavedStoryEntries
    with TableInfo<$SavedStoryEntriesTable, SavedStoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedStoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _storyIdMeta = const VerificationMeta(
    'storyId',
  );
  @override
  late final GeneratedColumn<String> storyId = GeneratedColumn<String>(
    'story_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headlineSnapshotMeta = const VerificationMeta(
    'headlineSnapshot',
  );
  @override
  late final GeneratedColumn<String> headlineSnapshot = GeneratedColumn<String>(
    'headline_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summarySnapshotMeta = const VerificationMeta(
    'summarySnapshot',
  );
  @override
  late final GeneratedColumn<String> summarySnapshot = GeneratedColumn<String>(
    'summary_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verificationStatusMeta =
      const VerificationMeta('verificationStatus');
  @override
  late final GeneratedColumn<String> verificationStatus =
      GeneratedColumn<String>(
        'verification_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastKnownSourceCountMeta =
      const VerificationMeta('lastKnownSourceCount');
  @override
  late final GeneratedColumn<int> lastKnownSourceCount = GeneratedColumn<int>(
    'last_known_source_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    storyId,
    savedAt,
    headlineSnapshot,
    country,
    summarySnapshot,
    verificationStatus,
    lastKnownSourceCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_story_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedStoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('story_id')) {
      context.handle(
        _storyIdMeta,
        storyId.isAcceptableOrUnknown(data['story_id']!, _storyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storyIdMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('headline_snapshot')) {
      context.handle(
        _headlineSnapshotMeta,
        headlineSnapshot.isAcceptableOrUnknown(
          data['headline_snapshot']!,
          _headlineSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_headlineSnapshotMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('summary_snapshot')) {
      context.handle(
        _summarySnapshotMeta,
        summarySnapshot.isAcceptableOrUnknown(
          data['summary_snapshot']!,
          _summarySnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_summarySnapshotMeta);
    }
    if (data.containsKey('verification_status')) {
      context.handle(
        _verificationStatusMeta,
        verificationStatus.isAcceptableOrUnknown(
          data['verification_status']!,
          _verificationStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verificationStatusMeta);
    }
    if (data.containsKey('last_known_source_count')) {
      context.handle(
        _lastKnownSourceCountMeta,
        lastKnownSourceCount.isAcceptableOrUnknown(
          data['last_known_source_count']!,
          _lastKnownSourceCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastKnownSourceCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {storyId};
  @override
  SavedStoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedStoryEntry(
      storyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story_id'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
      headlineSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headline_snapshot'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      summarySnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_snapshot'],
      )!,
      verificationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verification_status'],
      )!,
      lastKnownSourceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_known_source_count'],
      )!,
    );
  }

  @override
  $SavedStoryEntriesTable createAlias(String alias) {
    return $SavedStoryEntriesTable(attachedDatabase, alias);
  }
}

class SavedStoryEntry extends DataClass implements Insertable<SavedStoryEntry> {
  final String storyId;
  final DateTime savedAt;
  final String headlineSnapshot;
  final String country;
  final String summarySnapshot;
  final String verificationStatus;
  final int lastKnownSourceCount;
  const SavedStoryEntry({
    required this.storyId,
    required this.savedAt,
    required this.headlineSnapshot,
    required this.country,
    required this.summarySnapshot,
    required this.verificationStatus,
    required this.lastKnownSourceCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['story_id'] = Variable<String>(storyId);
    map['saved_at'] = Variable<DateTime>(savedAt);
    map['headline_snapshot'] = Variable<String>(headlineSnapshot);
    map['country'] = Variable<String>(country);
    map['summary_snapshot'] = Variable<String>(summarySnapshot);
    map['verification_status'] = Variable<String>(verificationStatus);
    map['last_known_source_count'] = Variable<int>(lastKnownSourceCount);
    return map;
  }

  SavedStoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return SavedStoryEntriesCompanion(
      storyId: Value(storyId),
      savedAt: Value(savedAt),
      headlineSnapshot: Value(headlineSnapshot),
      country: Value(country),
      summarySnapshot: Value(summarySnapshot),
      verificationStatus: Value(verificationStatus),
      lastKnownSourceCount: Value(lastKnownSourceCount),
    );
  }

  factory SavedStoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedStoryEntry(
      storyId: serializer.fromJson<String>(json['storyId']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      headlineSnapshot: serializer.fromJson<String>(json['headlineSnapshot']),
      country: serializer.fromJson<String>(json['country']),
      summarySnapshot: serializer.fromJson<String>(json['summarySnapshot']),
      verificationStatus: serializer.fromJson<String>(
        json['verificationStatus'],
      ),
      lastKnownSourceCount: serializer.fromJson<int>(
        json['lastKnownSourceCount'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'storyId': serializer.toJson<String>(storyId),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'headlineSnapshot': serializer.toJson<String>(headlineSnapshot),
      'country': serializer.toJson<String>(country),
      'summarySnapshot': serializer.toJson<String>(summarySnapshot),
      'verificationStatus': serializer.toJson<String>(verificationStatus),
      'lastKnownSourceCount': serializer.toJson<int>(lastKnownSourceCount),
    };
  }

  SavedStoryEntry copyWith({
    String? storyId,
    DateTime? savedAt,
    String? headlineSnapshot,
    String? country,
    String? summarySnapshot,
    String? verificationStatus,
    int? lastKnownSourceCount,
  }) => SavedStoryEntry(
    storyId: storyId ?? this.storyId,
    savedAt: savedAt ?? this.savedAt,
    headlineSnapshot: headlineSnapshot ?? this.headlineSnapshot,
    country: country ?? this.country,
    summarySnapshot: summarySnapshot ?? this.summarySnapshot,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    lastKnownSourceCount: lastKnownSourceCount ?? this.lastKnownSourceCount,
  );
  SavedStoryEntry copyWithCompanion(SavedStoryEntriesCompanion data) {
    return SavedStoryEntry(
      storyId: data.storyId.present ? data.storyId.value : this.storyId,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      headlineSnapshot: data.headlineSnapshot.present
          ? data.headlineSnapshot.value
          : this.headlineSnapshot,
      country: data.country.present ? data.country.value : this.country,
      summarySnapshot: data.summarySnapshot.present
          ? data.summarySnapshot.value
          : this.summarySnapshot,
      verificationStatus: data.verificationStatus.present
          ? data.verificationStatus.value
          : this.verificationStatus,
      lastKnownSourceCount: data.lastKnownSourceCount.present
          ? data.lastKnownSourceCount.value
          : this.lastKnownSourceCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedStoryEntry(')
          ..write('storyId: $storyId, ')
          ..write('savedAt: $savedAt, ')
          ..write('headlineSnapshot: $headlineSnapshot, ')
          ..write('country: $country, ')
          ..write('summarySnapshot: $summarySnapshot, ')
          ..write('verificationStatus: $verificationStatus, ')
          ..write('lastKnownSourceCount: $lastKnownSourceCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    storyId,
    savedAt,
    headlineSnapshot,
    country,
    summarySnapshot,
    verificationStatus,
    lastKnownSourceCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedStoryEntry &&
          other.storyId == this.storyId &&
          other.savedAt == this.savedAt &&
          other.headlineSnapshot == this.headlineSnapshot &&
          other.country == this.country &&
          other.summarySnapshot == this.summarySnapshot &&
          other.verificationStatus == this.verificationStatus &&
          other.lastKnownSourceCount == this.lastKnownSourceCount);
}

class SavedStoryEntriesCompanion extends UpdateCompanion<SavedStoryEntry> {
  final Value<String> storyId;
  final Value<DateTime> savedAt;
  final Value<String> headlineSnapshot;
  final Value<String> country;
  final Value<String> summarySnapshot;
  final Value<String> verificationStatus;
  final Value<int> lastKnownSourceCount;
  final Value<int> rowid;
  const SavedStoryEntriesCompanion({
    this.storyId = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.headlineSnapshot = const Value.absent(),
    this.country = const Value.absent(),
    this.summarySnapshot = const Value.absent(),
    this.verificationStatus = const Value.absent(),
    this.lastKnownSourceCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedStoryEntriesCompanion.insert({
    required String storyId,
    required DateTime savedAt,
    required String headlineSnapshot,
    required String country,
    required String summarySnapshot,
    required String verificationStatus,
    required int lastKnownSourceCount,
    this.rowid = const Value.absent(),
  }) : storyId = Value(storyId),
       savedAt = Value(savedAt),
       headlineSnapshot = Value(headlineSnapshot),
       country = Value(country),
       summarySnapshot = Value(summarySnapshot),
       verificationStatus = Value(verificationStatus),
       lastKnownSourceCount = Value(lastKnownSourceCount);
  static Insertable<SavedStoryEntry> custom({
    Expression<String>? storyId,
    Expression<DateTime>? savedAt,
    Expression<String>? headlineSnapshot,
    Expression<String>? country,
    Expression<String>? summarySnapshot,
    Expression<String>? verificationStatus,
    Expression<int>? lastKnownSourceCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (storyId != null) 'story_id': storyId,
      if (savedAt != null) 'saved_at': savedAt,
      if (headlineSnapshot != null) 'headline_snapshot': headlineSnapshot,
      if (country != null) 'country': country,
      if (summarySnapshot != null) 'summary_snapshot': summarySnapshot,
      if (verificationStatus != null) 'verification_status': verificationStatus,
      if (lastKnownSourceCount != null)
        'last_known_source_count': lastKnownSourceCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedStoryEntriesCompanion copyWith({
    Value<String>? storyId,
    Value<DateTime>? savedAt,
    Value<String>? headlineSnapshot,
    Value<String>? country,
    Value<String>? summarySnapshot,
    Value<String>? verificationStatus,
    Value<int>? lastKnownSourceCount,
    Value<int>? rowid,
  }) {
    return SavedStoryEntriesCompanion(
      storyId: storyId ?? this.storyId,
      savedAt: savedAt ?? this.savedAt,
      headlineSnapshot: headlineSnapshot ?? this.headlineSnapshot,
      country: country ?? this.country,
      summarySnapshot: summarySnapshot ?? this.summarySnapshot,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      lastKnownSourceCount: lastKnownSourceCount ?? this.lastKnownSourceCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (storyId.present) {
      map['story_id'] = Variable<String>(storyId.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (headlineSnapshot.present) {
      map['headline_snapshot'] = Variable<String>(headlineSnapshot.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (summarySnapshot.present) {
      map['summary_snapshot'] = Variable<String>(summarySnapshot.value);
    }
    if (verificationStatus.present) {
      map['verification_status'] = Variable<String>(verificationStatus.value);
    }
    if (lastKnownSourceCount.present) {
      map['last_known_source_count'] = Variable<int>(
        lastKnownSourceCount.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedStoryEntriesCompanion(')
          ..write('storyId: $storyId, ')
          ..write('savedAt: $savedAt, ')
          ..write('headlineSnapshot: $headlineSnapshot, ')
          ..write('country: $country, ')
          ..write('summarySnapshot: $summarySnapshot, ')
          ..write('verificationStatus: $verificationStatus, ')
          ..write('lastKnownSourceCount: $lastKnownSourceCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SavedStoryEntriesTable savedStoryEntries =
      $SavedStoryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [savedStoryEntries];
}

typedef $$SavedStoryEntriesTableCreateCompanionBuilder =
    SavedStoryEntriesCompanion Function({
      required String storyId,
      required DateTime savedAt,
      required String headlineSnapshot,
      required String country,
      required String summarySnapshot,
      required String verificationStatus,
      required int lastKnownSourceCount,
      Value<int> rowid,
    });
typedef $$SavedStoryEntriesTableUpdateCompanionBuilder =
    SavedStoryEntriesCompanion Function({
      Value<String> storyId,
      Value<DateTime> savedAt,
      Value<String> headlineSnapshot,
      Value<String> country,
      Value<String> summarySnapshot,
      Value<String> verificationStatus,
      Value<int> lastKnownSourceCount,
      Value<int> rowid,
    });

class $$SavedStoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedStoryEntriesTable> {
  $$SavedStoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headlineSnapshot => $composableBuilder(
    column: $table.headlineSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summarySnapshot => $composableBuilder(
    column: $table.summarySnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verificationStatus => $composableBuilder(
    column: $table.verificationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastKnownSourceCount => $composableBuilder(
    column: $table.lastKnownSourceCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedStoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedStoryEntriesTable> {
  $$SavedStoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headlineSnapshot => $composableBuilder(
    column: $table.headlineSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summarySnapshot => $composableBuilder(
    column: $table.summarySnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verificationStatus => $composableBuilder(
    column: $table.verificationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastKnownSourceCount => $composableBuilder(
    column: $table.lastKnownSourceCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedStoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedStoryEntriesTable> {
  $$SavedStoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get storyId =>
      $composableBuilder(column: $table.storyId, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<String> get headlineSnapshot => $composableBuilder(
    column: $table.headlineSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get summarySnapshot => $composableBuilder(
    column: $table.summarySnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verificationStatus => $composableBuilder(
    column: $table.verificationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastKnownSourceCount => $composableBuilder(
    column: $table.lastKnownSourceCount,
    builder: (column) => column,
  );
}

class $$SavedStoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedStoryEntriesTable,
          SavedStoryEntry,
          $$SavedStoryEntriesTableFilterComposer,
          $$SavedStoryEntriesTableOrderingComposer,
          $$SavedStoryEntriesTableAnnotationComposer,
          $$SavedStoryEntriesTableCreateCompanionBuilder,
          $$SavedStoryEntriesTableUpdateCompanionBuilder,
          (
            SavedStoryEntry,
            BaseReferences<
              _$AppDatabase,
              $SavedStoryEntriesTable,
              SavedStoryEntry
            >,
          ),
          SavedStoryEntry,
          PrefetchHooks Function()
        > {
  $$SavedStoryEntriesTableTableManager(
    _$AppDatabase db,
    $SavedStoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedStoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedStoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedStoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> storyId = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<String> headlineSnapshot = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> summarySnapshot = const Value.absent(),
                Value<String> verificationStatus = const Value.absent(),
                Value<int> lastKnownSourceCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedStoryEntriesCompanion(
                storyId: storyId,
                savedAt: savedAt,
                headlineSnapshot: headlineSnapshot,
                country: country,
                summarySnapshot: summarySnapshot,
                verificationStatus: verificationStatus,
                lastKnownSourceCount: lastKnownSourceCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String storyId,
                required DateTime savedAt,
                required String headlineSnapshot,
                required String country,
                required String summarySnapshot,
                required String verificationStatus,
                required int lastKnownSourceCount,
                Value<int> rowid = const Value.absent(),
              }) => SavedStoryEntriesCompanion.insert(
                storyId: storyId,
                savedAt: savedAt,
                headlineSnapshot: headlineSnapshot,
                country: country,
                summarySnapshot: summarySnapshot,
                verificationStatus: verificationStatus,
                lastKnownSourceCount: lastKnownSourceCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedStoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedStoryEntriesTable,
      SavedStoryEntry,
      $$SavedStoryEntriesTableFilterComposer,
      $$SavedStoryEntriesTableOrderingComposer,
      $$SavedStoryEntriesTableAnnotationComposer,
      $$SavedStoryEntriesTableCreateCompanionBuilder,
      $$SavedStoryEntriesTableUpdateCompanionBuilder,
      (
        SavedStoryEntry,
        BaseReferences<_$AppDatabase, $SavedStoryEntriesTable, SavedStoryEntry>,
      ),
      SavedStoryEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SavedStoryEntriesTableTableManager get savedStoryEntries =>
      $$SavedStoryEntriesTableTableManager(_db, _db.savedStoryEntries);
}
