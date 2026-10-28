import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/saved/data/drift_saved_stories_repository.dart';
import '../../features/saved/data/saved_stories_repository.dart';
import '../models/news_models.dart';
import 'core_providers.dart';

final savedStoriesRepositoryProvider = Provider<SavedStoriesRepository>((ref) {
  return DriftSavedStoriesRepository(ref.watch(databaseProvider));
});

final savedSnapshotsProvider = StreamProvider<List<SavedStorySnapshot>>((ref) {
  return ref.watch(savedStoriesRepositoryProvider).watchSavedStories();
});
