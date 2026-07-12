import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/database/app_database.dart';
import 'package:verimundi/features/saved/data/drift_saved_stories_repository.dart';

import '../test_helpers.dart';

void main() {
  test('saved story persistence stores snapshots and supports removal', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftSavedStoriesRepository(database);
    final story = storyFixture(id: 'save-me');

    await repository.save(story);
    expect(await repository.isSaved(story.id), isTrue);

    final snapshots = await repository.watchSavedStories().first;
    expect(snapshots.single.storyId, story.id);
    expect(snapshots.single.lastKnownSourceCount, story.sourceCount);

    await repository.remove(story.id);
    expect(await repository.isSaved(story.id), isFalse);
  });
}
