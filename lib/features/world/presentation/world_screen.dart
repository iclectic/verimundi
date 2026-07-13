import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/news_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../../shared/widgets/filter_bar.dart';
import '../../../shared/widgets/story_card.dart';
import 'world_map_view.dart';

class WorldScreen extends ConsumerWidget {
  const WorldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesValue = ref.watch(storiesProvider);
    final countriesValue = ref.watch(countriesProvider);
    final mode = ref.watch(feedModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(storiesProvider);
          ref.invalidate(countriesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const DemoBanner(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.tagline,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<FeedMode>(
                      segments: const [
                        ButtonSegment(
                          value: FeedMode.worldPulse,
                          label: Text('World Pulse'),
                          icon: Icon(Icons.public),
                        ),
                        ButtonSegment(
                          value: FeedMode.underreported,
                          label: Text('Underreported'),
                          icon: Icon(Icons.travel_explore),
                        ),
                        ButtonSegment(
                          value: FeedMode.positiveWorld,
                          label: Text('Positive World'),
                          icon: Icon(Icons.volunteer_activism),
                        ),
                      ],
                      selected: {mode},
                      onSelectionChanged: (selected) =>
                          ref.read(feedModeProvider.notifier).state =
                              selected.single,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FilterBar(),
                  const SizedBox(height: 16),
                  AsyncValueView<List<StoryCluster>>(
                    value: storiesValue,
                    builder: (stories) => AsyncValueView(
                      value: countriesValue,
                      builder: (countries) => _WorldContent(
                        stories: _modeStories(stories, mode),
                        countries: countries,
                        mode: mode,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<StoryCluster> _modeStories(List<StoryCluster> stories, FeedMode mode) {
    return switch (mode) {
      FeedMode.worldPulse => stories,
      FeedMode.underreported => [
        ...stories,
      ]..sort((a, b) => b.underreportedScore.compareTo(a.underreportedScore)),
      FeedMode.positiveWorld =>
        stories.where((story) => story.tone == Tone.positive).toList(),
    };
  }
}

class _WorldContent extends StatelessWidget {
  const _WorldContent({
    required this.stories,
    required this.countries,
    required this.mode,
  });

  final List<StoryCluster> stories;
  final List<CountryNewsStatus> countries;
  final FeedMode mode;

  @override
  Widget build(BuildContext context) {
    final summary = [
      (
        'Critical developments',
        stories.where((s) => s.severity == Severity.critical).length,
      ),
      (
        'Countries with active stories',
        countries.where((c) => c.activeStoryCount > 0).length,
      ),
      (
        'Underreported stories',
        stories.where((s) => s.underreportedScore > 65).length,
      ),
      (
        'Positive developments',
        stories.where((s) => s.tone == Tone.positive).length,
      ),
    ];
    final wide = MediaQuery.sizeOf(context).width > 900;
    final map = WorldMapView(countries: countries, stories: stories);
    final leading = Column(
      children: stories
          .take(4)
          .map((story) => StoryCard(story: story))
          .toList(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: map),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: leading),
            ],
          )
        else ...[
          map,
          const SizedBox(height: 16),
          leading,
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in summary)
              SizedBox(
                width: 210,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$1),
                        Text(
                          '${item.$2}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Regional sections',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        for (final region in {for (final story in stories) story.region})
          _RegionSection(
            region: region,
            stories: stories.where((s) => s.region == region).take(2),
          ),
      ],
    );
  }
}

class _RegionSection extends StatelessWidget {
  const _RegionSection({required this.region, required this.stories});

  final String region;
  final Iterable<StoryCluster> stories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  region,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('View region')),
            ],
          ),
          for (final story in stories)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StoryCard(story: story),
            ),
        ],
      ),
    );
  }
}
