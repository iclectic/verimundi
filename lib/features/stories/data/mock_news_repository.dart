import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../shared/models/news_models.dart';
import '../domain/news_repository.dart';
import 'story_filtering.dart';
import 'underreported_scoring_service.dart';

class MockNewsRepository implements NewsRepository {
  MockNewsRepository({
    AssetBundle? bundle,
    StoryFiltering filtering = const StoryFiltering(),
    UnderreportedScoringService scoring = const UnderreportedScoringService(),
  }) : _bundle = bundle ?? rootBundle,
       _filtering = filtering,
       _scoring = scoring;

  final AssetBundle _bundle;
  final StoryFiltering _filtering;
  final UnderreportedScoringService _scoring;
  List<StoryCluster>? _stories;
  List<CountryNewsStatus>? _countries;

  @override
  Future<List<StoryCluster>> getStories(StoryFilter filter) async {
    final stories = await _loadStories();
    return _filtering.apply(stories, filter);
  }

  @override
  Future<StoryCluster?> getStoryById(String id) async {
    final stories = await _loadStories();
    return stories.where((story) => story.id == id).firstOrNull;
  }

  @override
  Future<List<CountryNewsStatus>> getCountryStatuses() async =>
      _loadCountries();

  @override
  Future<List<StoryCluster>> getUnderreportedStories() async {
    final stories = await _loadStories();
    return [...stories]
      ..sort((a, b) => b.underreportedScore.compareTo(a.underreportedScore));
  }

  @override
  Future<List<StoryCluster>> getPositiveStories() async {
    final stories = await _loadStories();
    return stories.where((story) => story.tone == Tone.positive).toList()
      ..sort((a, b) => b.positiveImpactScore.compareTo(a.positiveImpactScore));
  }

  Future<List<CountryNewsStatus>> _loadCountries() async {
    if (_countries != null) return _countries!;
    final json = await _loadCatalog();
    final countries = (json['countries'] as List<dynamic>)
        .map((item) => CountryNewsStatus.fromJson(item as Map<String, dynamic>))
        .toList();
    _countries = countries;
    return countries;
  }

  Future<List<StoryCluster>> _loadStories() async {
    if (_stories != null) return _stories!;
    final json = await _loadCatalog();
    final seeds = json['storySeeds'] as List<dynamic>;
    final now = DateTime.parse(json['generatedAt'] as String);
    final stories = <StoryCluster>[];
    for (var index = 0; index < seeds.length; index++) {
      final seed = seeds[index] as Map<String, dynamic>;
      final severity = Severity.values.byName(seed['severity'] as String);
      final tone = Tone.values.byName(seed['tone'] as String);
      final category = StoryCategory.values.byName(seed['category'] as String);
      final verification = VerificationStatus.values.byName(
        seed['verificationStatus'] as String,
      );
      final local = seed['localSourceCount'] as int;
      final regional = seed['regionalSourceCount'] as int;
      final international = seed['internationalSourceCount'] as int;
      final sourceCount = local + regional + international;
      final sources = List.generate(sourceCount, (sourceIndex) {
        final level = sourceIndex < local
            ? 'local'
            : sourceIndex < local + regional
            ? 'regional'
            : 'international';
        return NewsSource(
          id: '${seed['id']}-src-${sourceIndex + 1}',
          name: '${_publisherPrefix(level)} Dispatch ${sourceIndex + 1}',
          articleUrl: 'https://example.test/${seed['id']}/${sourceIndex + 1}',
          publisherUrl: 'https://example.test/$level-dispatch',
          countryCode: seed['primaryCountryCode'] as String,
          languageCode: sourceIndex.isEven ? 'en' : 'local',
          publicationType: level == 'international' ? 'wire' : 'local newsroom',
          isLocalSource: level == 'local',
          publishedAt: now.subtract(Duration(hours: index * 3 + sourceIndex)),
          author: sourceIndex.isEven ? 'VeriMundi demo desk' : null,
          credibilityStatus: sourceIndex == sourceCount - 1
              ? CredibilityStatus.unknown
              : CredibilityStatus.established,
          headline: seed['headline'] as String,
          coverageLevel: level,
        );
      });
      final score = _scoring.calculate(
        severity: severity,
        localSourceCount: local,
        regionalSourceCount: regional,
        internationalSourceCount: international,
      );
      stories.add(
        StoryCluster(
          id: seed['id'] as String,
          headline: seed['headline'] as String,
          shortSummary: seed['shortSummary'] as String,
          fullSummary: seed['fullSummary'] as String,
          whyItMatters: seed['whyItMatters'] as String,
          countryCodes: [seed['primaryCountryCode'] as String],
          primaryCountryCode: seed['primaryCountryCode'] as String,
          region: seed['region'] as String,
          category: category,
          latitude: (seed['latitude'] as num).toDouble(),
          longitude: (seed['longitude'] as num).toDouble(),
          firstPublishedAt: now.subtract(
            Duration(days: index % 9 + 1, hours: index),
          ),
          lastUpdatedAt: now.subtract(Duration(hours: index + 1)),
          severity: severity,
          severityReason: seed['severityReason'] as String,
          tone: tone,
          verificationStatus: verification,
          confidenceScore: (seed['confidenceScore'] as num).toDouble(),
          localSourceCount: local,
          regionalSourceCount: regional,
          internationalSourceCount: international,
          underreportedScore: score,
          positiveImpactScore: (seed['positiveImpactScore'] as num).toDouble(),
          sourceArticles: sources,
          confirmedFacts: [
            ConfirmedFact(
              text: seed['confirmedFact'] as String,
              sourceIds: sources.take(2).map((source) => source.id).toList(),
            ),
          ],
          uncertainties: List<String>.from(
            seed['uncertainties'] as List<dynamic>,
          ),
          isDemoContent: true,
        ),
      );
    }
    _stories = stories;
    return stories;
  }

  Future<Map<String, dynamic>> _loadCatalog() async {
    final content = await _bundle.loadString(
      'assets/mock/verimundi_mock_catalog.json',
    );
    return jsonDecode(content) as Map<String, dynamic>;
  }

  String _publisherPrefix(String level) => switch (level) {
    'local' => 'Local',
    'regional' => 'Regional',
    _ => 'Global',
  };
}

class RemoteNewsRepository implements NewsRepository {
  RemoteNewsRepository({required String baseUrl}) : _baseUrl = baseUrl;

  final String _baseUrl;

  @override
  Future<List<CountryNewsStatus>> getCountryStatuses() => _unavailable();

  @override
  Future<List<StoryCluster>> getPositiveStories() => _unavailable();

  @override
  Future<StoryCluster?> getStoryById(String id) => _unavailable();

  @override
  Future<List<StoryCluster>> getStories(StoryFilter filter) => _unavailable();

  @override
  Future<List<StoryCluster>> getUnderreportedStories() => _unavailable();

  Future<T> _unavailable<T>() {
    return Future<T>.error(
      StateError(
        'NEWS_API_BASE_URL is set to "$_baseUrl", but this release does not include a live VeriMundi backend client. Use NEWS_API_BASE_URL=mock for the Play Store demo MVP.',
      ),
    );
  }
}

class MockGenAiSummaryService implements GenAiSummaryService {
  @override
  Future<StoryCluster> refreshSummary(StoryCluster story) async {
    if (story.verificationStatus == VerificationStatus.insufficientEvidence) {
      return story.copyWith(
        shortSummary:
            'VeriMundi does not currently have enough reliable source material to summarise this story.',
        confidenceScore: 0,
      );
    }
    return story;
  }
}
