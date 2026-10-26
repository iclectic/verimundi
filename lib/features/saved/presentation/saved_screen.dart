import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_formatters.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/app_status_banners.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedSnapshotsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: ListView(
        children: [
          const AppStatusBanners(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AsyncValueView(
              value: saved,
              empty: const _EmptySavedStories(),
              builder: (items) => Column(
                children: [
                  for (final item in items)
                    Card(
                      child: ListTile(
                        title: Text(item.headlineSnapshot),
                        subtitle: Text(
                          '${item.country} • ${item.verificationStatus.name} • ${item.lastKnownSourceCount} sources • saved ${DateFormatters.relative(item.savedAt)}\n'
                          'Saved snapshot may be older than the current server version.',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: 'Remove saved story',
                          icon: const Icon(Icons.bookmark_remove),
                          onPressed: () async {
                            await ref
                                .read(savedStoriesRepositoryProvider)
                                .remove(item.storyId);
                            ref.invalidate(storiesProvider);
                            ref.invalidate(storiesFeedProvider);
                          },
                        ),
                        onTap: () => context.push('/stories/${item.storyId}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySavedStories extends StatelessWidget {
  const _EmptySavedStories();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'No saved stories yet',
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.bookmark_border, size: 48),
            SizedBox(height: 12),
            Text('No saved stories yet.', textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text(
              'Save a story from any feed to return to it here later.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
