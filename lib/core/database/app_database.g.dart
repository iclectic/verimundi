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

class $CachedFeedEntriesTable extends CachedFeedEntries
    with TableInfo<$CachedFeedEntriesTable, CachedFeedEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedFeedEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceModeMeta = const VerificationMeta(
    'sourceMode',
  );
  @override
  late final GeneratedColumn<String> sourceMode = GeneratedColumn<String>(
    'source_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mock'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    cacheKey,
    payloadJson,
    fetchedAt,
    sourceMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_feed_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedFeedEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('source_mode')) {
      context.handle(
        _sourceModeMeta,
        sourceMode.isAcceptableOrUnknown(data['source_mode']!, _sourceModeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  CachedFeedEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFeedEntry(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      sourceMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_mode'],
      )!,
    );
  }

  @override
  $CachedFeedEntriesTable createAlias(String alias) {
    return $CachedFeedEntriesTable(attachedDatabase, alias);
  }
}

class CachedFeedEntry extends DataClass implements Insertable<CachedFeedEntry> {
  final String cacheKey;
  final String payloadJson;
  final DateTime fetchedAt;
  final String sourceMode;
  const CachedFeedEntry({
    required this.cacheKey,
    required this.payloadJson,
    required this.fetchedAt,
    required this.sourceMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['payload_json'] = Variable<String>(payloadJson);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['source_mode'] = Variable<String>(sourceMode);
    return map;
  }

  CachedFeedEntriesCompanion toCompanion(bool nullToAbsent) {
    return CachedFeedEntriesCompanion(
      cacheKey: Value(cacheKey),
      payloadJson: Value(payloadJson),
      fetchedAt: Value(fetchedAt),
      sourceMode: Value(sourceMode),
    );
  }

  factory CachedFeedEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFeedEntry(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      sourceMode: serializer.fromJson<String>(json['sourceMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'sourceMode': serializer.toJson<String>(sourceMode),
    };
  }

  CachedFeedEntry copyWith({
    String? cacheKey,
    String? payloadJson,
    DateTime? fetchedAt,
    String? sourceMode,
  }) => CachedFeedEntry(
    cacheKey: cacheKey ?? this.cacheKey,
    payloadJson: payloadJson ?? this.payloadJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    sourceMode: sourceMode ?? this.sourceMode,
  );
  CachedFeedEntry copyWithCompanion(CachedFeedEntriesCompanion data) {
    return CachedFeedEntry(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      sourceMode: data.sourceMode.present
          ? data.sourceMode.value
          : this.sourceMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFeedEntry(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('sourceMode: $sourceMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, payloadJson, fetchedAt, sourceMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFeedEntry &&
          other.cacheKey == this.cacheKey &&
          other.payloadJson == this.payloadJson &&
          other.fetchedAt == this.fetchedAt &&
          other.sourceMode == this.sourceMode);
}

class CachedFeedEntriesCompanion extends UpdateCompanion<CachedFeedEntry> {
  final Value<String> cacheKey;
  final Value<String> payloadJson;
  final Value<DateTime> fetchedAt;
  final Value<String> sourceMode;
  final Value<int> rowid;
  const CachedFeedEntriesCompanion({
    this.cacheKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.sourceMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedFeedEntriesCompanion.insert({
    required String cacheKey,
    required String payloadJson,
    required DateTime fetchedAt,
    this.sourceMode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       payloadJson = Value(payloadJson),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedFeedEntry> custom({
    Expression<String>? cacheKey,
    Expression<String>? payloadJson,
    Expression<DateTime>? fetchedAt,
    Expression<String>? sourceMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (sourceMode != null) 'source_mode': sourceMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedFeedEntriesCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? payloadJson,
    Value<DateTime>? fetchedAt,
    Value<String>? sourceMode,
    Value<int>? rowid,
  }) {
    return CachedFeedEntriesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      payloadJson: payloadJson ?? this.payloadJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      sourceMode: sourceMode ?? this.sourceMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (sourceMode.present) {
      map['source_mode'] = Variable<String>(sourceMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedFeedEntriesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('sourceMode: $sourceMode, ')
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
  late final $CachedFeedEntriesTable cachedFeedEntries =
      $CachedFeedEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    savedStoryEntries,
    cachedFeedEntries,
  ];
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
typedef $$CachedFeedEntriesTableCreateCompanionBuilder =
    CachedFeedEntriesCompanion Function({
      required String cacheKey,
      required String payloadJson,
      required DateTime fetchedAt,
      Value<String> sourceMode,
      Value<int> rowid,
    });
typedef $$CachedFeedEntriesTableUpdateCompanionBuilder =
    CachedFeedEntriesCompanion Function({
      Value<String> cacheKey,
      Value<String> payloadJson,
      Value<DateTime> fetchedAt,
      Value<String> sourceMode,
      Value<int> rowid,
    });

class $$CachedFeedEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedFeedEntriesTable> {
  $$CachedFeedEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceMode => $composableBuilder(
    column: $table.sourceMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedFeedEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedFeedEntriesTable> {
  $$CachedFeedEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceMode => $composableBuilder(
    column: $table.sourceMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedFeedEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedFeedEntriesTable> {
  $$CachedFeedEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get sourceMode => $composableBuilder(
    column: $table.sourceMode,
    builder: (column) => column,
  );
}

class $$CachedFeedEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedFeedEntriesTable,
          CachedFeedEntry,
          $$CachedFeedEntriesTableFilterComposer,
          $$CachedFeedEntriesTableOrderingComposer,
          $$CachedFeedEntriesTableAnnotationComposer,
          $$CachedFeedEntriesTableCreateCompanionBuilder,
          $$CachedFeedEntriesTableUpdateCompanionBuilder,
          (
            CachedFeedEntry,
            BaseReferences<
              _$AppDatabase,
              $CachedFeedEntriesTable,
              CachedFeedEntry
            >,
          ),
          CachedFeedEntry,
          PrefetchHooks Function()
        > {
  $$CachedFeedEntriesTableTableManager(
    _$AppDatabase db,
    $CachedFeedEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedFeedEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedFeedEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedFeedEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<String> sourceMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedFeedEntriesCompanion(
                cacheKey: cacheKey,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
                sourceMode: sourceMode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String payloadJson,
                required DateTime fetchedAt,
                Value<String> sourceMode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedFeedEntriesCompanion.insert(
                cacheKey: cacheKey,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
                sourceMode: sourceMode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedFeedEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedFeedEntriesTable,
      CachedFeedEntry,
      $$CachedFeedEntriesTableFilterComposer,
      $$CachedFeedEntriesTableOrderingComposer,
      $$CachedFeedEntriesTableAnnotationComposer,
      $$CachedFeedEntriesTableCreateCompanionBuilder,
      $$CachedFeedEntriesTableUpdateCompanionBuilder,
      (
        CachedFeedEntry,
        BaseReferences<_$AppDatabase, $CachedFeedEntriesTable, CachedFeedEntry>,
      ),
      CachedFeedEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SavedStoryEntriesTableTableManager get savedStoryEntries =>
      $$SavedStoryEntriesTableTableManager(_db, _db.savedStoryEntries);
  $$CachedFeedEntriesTableTableManager get cachedFeedEntries =>
      $$CachedFeedEntriesTableTableManager(_db, _db.cachedFeedEntries);
}
