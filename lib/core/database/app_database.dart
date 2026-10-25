import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class SavedStoryEntries extends Table {
  TextColumn get storyId => text()();
  DateTimeColumn get savedAt => dateTime()();
  TextColumn get headlineSnapshot => text()();
  TextColumn get country => text()();
  TextColumn get summarySnapshot => text()();
  TextColumn get verificationStatus => text()();
  IntColumn get lastKnownSourceCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {storyId};
}

/// Local metadata cache for feeds/recent story opens. Never stores full
/// copyrighted external article bodies — only VeriMundi JSON snapshots.
class CachedFeedEntries extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  TextColumn get sourceMode => text().withDefault(const Constant('mock'))();

  @override
  Set<Column<Object>> get primaryKey => {cacheKey};
}

@DriftDatabase(tables: [SavedStoryEntries, CachedFeedEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(cachedFeedEntries);
      }
    },
  );

  Stream<List<SavedStoryEntry>> watchSavedStories() => (select(
    savedStoryEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.savedAt)])).watch();

  Future<Set<String>> savedStoryIds() async {
    final rows = await select(savedStoryEntries).get();
    return rows.map((row) => row.storyId).toSet();
  }

  Future<SavedStoryEntry?> savedStory(String storyId) {
    return (select(
      savedStoryEntries,
    )..where((row) => row.storyId.equals(storyId))).getSingleOrNull();
  }

  Future<void> upsertSavedStory(SavedStoryEntriesCompanion entry) {
    return into(savedStoryEntries).insertOnConflictUpdate(entry);
  }

  Future<void> deleteSavedStory(String storyId) {
    return (delete(
      savedStoryEntries,
    )..where((row) => row.storyId.equals(storyId))).go();
  }

  Future<void> upsertFeedCache(CachedFeedEntriesCompanion entry) {
    return into(cachedFeedEntries).insertOnConflictUpdate(entry);
  }

  Future<CachedFeedEntry?> feedCache(String cacheKey) {
    return (select(
      cachedFeedEntries,
    )..where((row) => row.cacheKey.equals(cacheKey))).getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'verimundi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
