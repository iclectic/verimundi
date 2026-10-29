import '../../../shared/models/news_models.dart';

/// Paged story list from mock or remote discovery (`/v1/stories` or `/v1/search`).
class StoryPageResult {
  const StoryPageResult({
    required this.stories,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<StoryCluster> stories;
  final int page;
  final int pageSize;
  final int total;

  bool get isEmpty => stories.isEmpty;
  bool get hasMore => page * pageSize < total;
  int get totalPages => pageSize <= 0
      ? 1
      : ((total + pageSize - 1) ~/ pageSize).clamp(1, 1 << 30);
}
