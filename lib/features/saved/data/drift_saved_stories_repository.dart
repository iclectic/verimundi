import '../../../core/database/app_database.dart';
import '../../../shared/models/news_models.dart';
import 'saved_stories_repository.dart';

class DriftSavedStoriesRepository implements SavedStoriesRepository {
  DriftSavedStoriesRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<SavedStorySnapshot>> watchSavedStories() {
    return _database.watchSavedStories().map(
      (rows) => rows.map(_fromRow).toList(),
    );
  }

  @override
  Future<Set<String>> getSavedStoryIds() => _database.savedStoryIds();

  @override
  Future<bool> isSaved(String storyId) async =>
      await _database.savedStory(storyId) != null;

  @override
  Future<void> save(StoryCluster story) {
    return _database.upsertSavedStory(
      SavedStoryEntriesCompanion.insert(
        storyId: story.id,
        savedAt: DateTime.now(),
        headlineSnapshot: story.headline,
        country: story.primaryCountryCode,
        summarySnapshot: story.shortSummary,
        verificationStatus: story.verificationStatus.name,
        lastKnownSourceCount: story.sourceCount,
      ),
    );
  }

  @override
  Future<void> remove(String storyId) => _database.deleteSavedStory(storyId);

  SavedStorySnapshot _fromRow(SavedStoryEntry row) {
    return SavedStorySnapshot(
      storyId: row.storyId,
      savedAt: row.savedAt,
      headlineSnapshot: row.headlineSnapshot,
      country: row.country,
      summarySnapshot: row.summarySnapshot,
      verificationStatus: VerificationStatus.values.firstWhere(
        (status) => status.name == row.verificationStatus,
        orElse: () => VerificationStatus.developing,
      ),
      lastKnownSourceCount: row.lastKnownSourceCount,
    );
  }
}
