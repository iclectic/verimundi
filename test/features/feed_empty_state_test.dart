import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/shared/models/news_models.dart';
import 'package:verimundi/shared/models/story_filter_extensions.dart';
import 'package:verimundi/shared/widgets/feed_empty_state.dart';

void main() {
  group('StoryFilter.hasActiveConstraints', () {
    test('default filter is inactive', () {
      expect(const StoryFilter().hasActiveConstraints, isFalse);
    });

    test('query and structured chips count as active', () {
      expect(const StoryFilter(query: 'flood').hasActiveConstraints, isTrue);
      expect(const StoryFilter(region: 'Africa').hasActiveConstraints, isTrue);
      expect(
        const StoryFilter(hasLocalCoverage: true).hasActiveConstraints,
        isTrue,
      );
    });
  });

  group('resolveFeedEmptyReason', () {
    test('no clusters when source empty and filters off', () {
      expect(
        resolveFeedEmptyReason(
          sourceEmpty: true,
          displayedEmpty: true,
          filtersActive: false,
          mode: FeedMode.worldPulse,
          page: 1,
        ),
        FeedEmptyReason.noClusters,
      );
    });

    test('filtered out when source empty and filters on', () {
      expect(
        resolveFeedEmptyReason(
          sourceEmpty: true,
          displayedEmpty: true,
          filtersActive: true,
          mode: FeedMode.worldPulse,
          page: 1,
        ),
        FeedEmptyReason.filteredOut,
      );
    });

    test(
      'mode empty when positive view has no matches but source has stories',
      () {
        expect(
          resolveFeedEmptyReason(
            sourceEmpty: false,
            displayedEmpty: true,
            filtersActive: false,
            mode: FeedMode.positiveWorld,
            page: 1,
          ),
          FeedEmptyReason.modeEmpty,
        );
      },
    );

    test('end of pages when page > 1 and source empty', () {
      expect(
        resolveFeedEmptyReason(
          sourceEmpty: true,
          displayedEmpty: true,
          filtersActive: false,
          mode: FeedMode.worldPulse,
          page: 3,
        ),
        FeedEmptyReason.endOfPages,
      );
    });
  });

  testWidgets('FeedEmptyState shows filter reset action', (tester) async {
    var reset = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedEmptyState(
            reason: FeedEmptyReason.filteredOut,
            onResetFilters: () => reset = true,
          ),
        ),
      ),
    );

    expect(find.text('No stories match these filters'), findsOneWidget);
    await tester.tap(find.text('Reset filters'));
    expect(reset, isTrue);
  });

  testWidgets('FeedEmptyState shows no-clusters honesty copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeedEmptyState(reason: FeedEmptyReason.noClusters),
        ),
      ),
    );

    expect(find.text('No stories available yet'), findsOneWidget);
    expect(
      find.textContaining('never invents stories to fill an empty feed'),
      findsNothing, // mock mode default — demo catalogue copy instead
    );
    expect(find.textContaining('demo catalogue'), findsOneWidget);
  });
}
