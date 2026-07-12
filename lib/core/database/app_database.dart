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

@DriftDatabase(tables: [SavedStoryEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Stream<List<SavedStoryEntry>> watchSavedStories() =>
      (select(savedStoryEntries)..orderBy([(t) => OrderingTerm.desc(t.savedAt)]))
          .watch();

  Future<Set<String>> savedStoryIds() async {
    final rows = await select(savedStoryEntries).get();
    return rows.map((row) => row.storyId).toSet();
  }

  Future<SavedStoryEntry?> savedStory(String storyId) {
    return (select(savedStoryEntries)..where((row) => row.storyId.equals(storyId)))
        .getSingleOrNull();
  }

  Future<void> upsertSavedStory(SavedStoryEntriesCompanion entry) {
    return into(savedStoryEntries).insertOnConflictUpdate(entry);
  }

  Future<void> deleteSavedStory(String storyId) {
    return (delete(savedStoryEntries)..where((row) => row.storyId.equals(storyId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'verimundi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
