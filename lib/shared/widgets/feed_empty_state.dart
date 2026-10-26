import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../models/news_models.dart';

/// Why a feed list has nothing to show — drives distinct British English copy.
enum FeedEmptyReason {
  /// Server/mock returned no clusters and no filters are active.
  noClusters,

  /// Active filters (or server-side filter query) excluded everything.
  filteredOut,

  /// Base feed has stories, but the selected mode (e.g. Positive) has none.
  modeEmpty,

  /// Pagination landed on an empty page.
  endOfPages,
}

FeedEmptyReason resolveFeedEmptyReason({
  required bool sourceEmpty,
  required bool displayedEmpty,
  required bool filtersActive,
  required FeedMode mode,
  required int page,
}) {
  if (!displayedEmpty) {
    return FeedEmptyReason.noClusters;
  }
  if (page > 1 && sourceEmpty) {
    return FeedEmptyReason.endOfPages;
  }
  if (sourceEmpty && filtersActive) {
    return FeedEmptyReason.filteredOut;
  }
  if (sourceEmpty && !filtersActive) {
    return FeedEmptyReason.noClusters;
  }
  // Source has stories but the current mode/view shows none.
  if (mode == FeedMode.positiveWorld) {
    return FeedEmptyReason.modeEmpty;
  }
  return filtersActive
      ? FeedEmptyReason.filteredOut
      : FeedEmptyReason.noClusters;
}

class FeedEmptyState extends StatelessWidget {
  const FeedEmptyState({
    required this.reason,
    this.mode = FeedMode.worldPulse,
    this.onResetFilters,
    this.onSwitchToWorldPulse,
    this.onGoToPreviousPage,
    super.key,
  });

  final FeedEmptyReason reason;
  final FeedMode mode;
  final VoidCallback? onResetFilters;
  final VoidCallback? onSwitchToWorldPulse;
  final VoidCallback? onGoToPreviousPage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final copy = _copyFor(reason, mode);

    return Semantics(
      liveRegion: true,
      label: '${copy.title}. ${copy.body}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(copy.icon, size: 40, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              copy.title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              copy.body,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (reason == FeedEmptyReason.filteredOut &&
                    onResetFilters != null)
                  FilledButton.tonalIcon(
                    onPressed: onResetFilters,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset filters'),
                  ),
                if (onSwitchToWorldPulse != null &&
                    (reason == FeedEmptyReason.modeEmpty ||
                        mode == FeedMode.positiveWorld))
                  FilledButton.tonalIcon(
                    onPressed: onSwitchToWorldPulse,
                    icon: const Icon(Icons.public),
                    label: const Text('Show World Pulse'),
                  ),
                if (reason == FeedEmptyReason.endOfPages &&
                    onGoToPreviousPage != null)
                  FilledButton.tonalIcon(
                    onPressed: onGoToPreviousPage,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous page'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static _EmptyCopy _copyFor(FeedEmptyReason reason, FeedMode mode) {
    return switch (reason) {
      FeedEmptyReason.noClusters => _EmptyCopy(
        icon: Icons.public_off_outlined,
        title: 'No stories available yet',
        body: AppConstants.isMockApi
            ? 'This demo catalogue has nothing to show for this view. Try another tab or reload the app.'
            : 'The server has no story clusters for this feed yet. Pull to refresh, or check back after the next ingestion cycle. VeriMundi never invents stories to fill an empty feed.',
      ),
      FeedEmptyReason.filteredOut => const _EmptyCopy(
        icon: Icons.filter_alt_off_outlined,
        title: 'No stories match these filters',
        body:
            'Try widening the region, clearing search, or resetting filters. An empty result with filters on does not mean the world is quiet.',
      ),
      FeedEmptyReason.modeEmpty => _EmptyCopy(
        icon: Icons.volunteer_activism_outlined,
        title: mode == FeedMode.positiveWorld
            ? 'No positive stories in this selection'
            : 'Nothing in this view',
        body: mode == FeedMode.positiveWorld
            ? 'There are stories in the feed, but none are marked positive for the current filters. Switch to World Pulse or adjust tone filters.'
            : 'Try another feed mode or reset filters.',
      ),
      FeedEmptyReason.endOfPages => const _EmptyCopy(
        icon: Icons.manage_search_outlined,
        title: 'No stories on this page',
        body:
            'You have moved past the available results. Go to the previous page or reset filters.',
      ),
    };
  }
}

class _EmptyCopy {
  const _EmptyCopy({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
