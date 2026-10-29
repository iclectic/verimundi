import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/network/api_client.dart';
import '../../features/stories/data/feed_cache_repository.dart';
import '../../features/stories/data/mock_news_repository.dart';
import '../../features/stories/data/remote_news_repository.dart';
import '../../features/stories/domain/news_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final inMemoryDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  ref.onDispose(database.close);
  return database;
});

final feedCacheRepositoryProvider = Provider<FeedCacheRepository>((ref) {
  return FeedCacheRepository(ref.watch(databaseProvider));
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  if (client.isMockMode) {
    return MockNewsRepository();
  }
  return RemoteNewsRepository(client: client);
});
