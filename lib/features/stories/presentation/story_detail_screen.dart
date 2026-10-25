import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_formatters.dart';
import '../../../shared/models/news_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../../shared/widgets/status_pill.dart';
import '../data/remote_news_repository.dart';

class StoryDetailScreen extends ConsumerStatefulWidget {
  const StoryDetailScreen({required this.storyId, super.key});

  final String storyId;

  @override
  ConsumerState<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends ConsumerState<StoryDetailScreen> {
  final _questionController = TextEditingController();
  AsyncValue<AiStoryAnswer>? _answer;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = ref.watch(storyByIdProvider(widget.storyId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story details'),
        actions: [
          story.when(
            data: (value) {
              if (value == null) return const SizedBox.shrink();
              return IconButton(
                tooltip: value.isSaved ? 'Remove saved story' : 'Save story',
                icon: Icon(
                  value.isSaved ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () async {
                  final repo = ref.read(savedStoriesRepositoryProvider);
                  if (value.isSaved) {
                    await repo.remove(value.id);
                  } else {
                    await repo.save(value);
                  }
                  ref.invalidate(storyByIdProvider(widget.storyId));
                  ref.invalidate(storiesFeedProvider);
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Report a problem',
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => _showReportDialog(context),
          ),
        ],
      ),
      body: AsyncValueView(
        value: story,
        builder: (story) {
          if (story == null) {
            return const Center(child: Text('Story not found.'));
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const DemoBanner(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.headline,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          SeverityPill(
                            severity: story.severity,
                            reason: story.severityReason,
                          ),
                          TonePill(tone: story.tone),
                          Chip(label: Text(story.verificationStatus.name)),
                          Chip(label: Text(story.category.name)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${story.primaryCountryCode} • ${story.region} • first published ${DateFormatters.compact(story.firstPublishedAt)} • updated ${DateFormatters.compact(story.lastUpdatedAt)}',
                      ),
                      const SizedBox(height: 24),
                      _Section(
                        title: 'Timeline',
                        icon: Icons.timeline,
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.fiber_new),
                              title: const Text('First published'),
                              subtitle: Text(
                                DateFormatters.compact(story.firstPublishedAt),
                              ),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.auto_awesome),
                              title: const Text('Summary generated / updated'),
                              subtitle: Text(
                                DateFormatters.compact(story.lastUpdatedAt),
                              ),
                            ),
                            if (story.correctedAt != null)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.edit_note),
                                title: const Text('Correction recorded'),
                                subtitle: Text(
                                  DateFormatters.compact(story.correctedAt!),
                                ),
                              ),
                          ],
                        ),
                      ),
                      _Section(
                        title: 'AI-generated summary',
                        icon: Icons.auto_awesome,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(story.shortSummary),
                            const SizedBox(height: 12),
                            Text(
                              'Why this matters',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(story.whyItMatters),
                            const SizedBox(height: 12),
                            Text(
                              story.isDemoContent
                                  ? 'Mock generated from the listed fictional sources. Confidence ${(story.confidenceScore * 100).toStringAsFixed(0)}%. Last generated ${DateFormatters.compact(story.lastUpdatedAt)}.'
                                  : 'AI-assisted summary grounded in listed sources. Confidence ${(story.confidenceScore * 100).toStringAsFixed(0)}%. Last generated ${DateFormatters.compact(story.lastUpdatedAt)}.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (story.correctionNotice != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Correction: ${story.correctionNotice}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            if (story.verificationStatus ==
                                VerificationStatus.insufficientEvidence)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'VeriMundi does not currently have enough reliable source material to summarise this story.',
                                ),
                              ),
                          ],
                        ),
                      ),
                      _Section(
                        title: 'Confirmed facts',
                        icon: Icons.fact_check,
                        child: Column(
                          children: [
                            for (final fact in story.confirmedFacts)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.check_circle_outline),
                                title: Text(fact.text),
                                subtitle: Text(
                                  'Sources: ${fact.sourceIds.join(', ')}',
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (story.disputedClaims.isNotEmpty)
                        _Section(
                          title: 'Disputed or conflicting claims',
                          icon: Icons.compare,
                          child: Column(
                            children: [
                              for (final claim in story.disputedClaims)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.report_gmailerrorred_outlined,
                                  ),
                                  title: Text(claim.text),
                                  subtitle: Text(
                                    'Supports: ${claim.supportingSourceIds.join(', ')} • Disputes: ${claim.disputingSourceIds.join(', ')}',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      _Section(
                        title: 'What remains uncertain',
                        icon: Icons.help_outline,
                        child: Column(
                          children: [
                            for (final uncertainty in story.uncertainties)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.question_mark),
                                title: Text(uncertainty),
                              ),
                          ],
                        ),
                      ),
                      _Section(
                        title: 'Coverage comparison',
                        icon: Icons.compare_arrows,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _Metric(
                              label: 'Local',
                              value: story.localSourceCount.toString(),
                            ),
                            _Metric(
                              label: 'Regional',
                              value: story.regionalSourceCount.toString(),
                            ),
                            _Metric(
                              label: 'International',
                              value: story.internationalSourceCount.toString(),
                            ),
                            _Metric(
                              label: 'Independent',
                              value: story.independentSourceCount.toString(),
                            ),
                            _Metric(
                              label: 'Underreported score',
                              value: story.underreportedScore.toStringAsFixed(
                                0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (story.underreportedReason.isNotEmpty)
                        _Section(
                          title: 'Why this may be underreported',
                          icon: Icons.travel_explore,
                          child: Text(story.underreportedReason),
                        ),
                      if (story.rankingReason.isNotEmpty)
                        _Section(
                          title: 'Why VeriMundi ranked this story',
                          icon: Icons.insights,
                          child: Text(story.rankingReason),
                        ),
                      _Section(
                        title: 'Sources',
                        icon: Icons.link,
                        child: Column(
                          children: [
                            for (final source in story.sourceArticles)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(source.name),
                                subtitle: Text(
                                  '${source.headline}\n${source.countryCode} • ${source.coverageLevel} • ${source.credibilityStatus.name} metadata • ${DateFormatters.compact(source.publishedAt)}',
                                ),
                                trailing: const Icon(Icons.open_in_new),
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'External source: ${source.articleUrl}',
                                        ),
                                      ),
                                    ),
                              ),
                          ],
                        ),
                      ),
                      _QuestionBox(
                        controller: _questionController,
                        answer: _answer,
                        isDemoContent: story.isDemoContent,
                        onAsk: () async {
                          final question = _questionController.text.trim();
                          if (question.isEmpty) return;
                          setState(() => _answer = const AsyncLoading());
                          final service = ref.read(
                            storyQuestionServiceProvider,
                          );
                          final result = await AsyncValue.guard(
                            () => service.askQuestion(story, question),
                          );
                          setState(() => _answer = result);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showReportDialog(BuildContext context) async {
    const reasons = [
      'Incorrect summary',
      'Unsupported claim',
      'Outdated information',
      'Misleading classification',
      'Broken source',
      'Other',
    ];
    var selected = reasons.first;
    final notes = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Report a problem'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownMenu<String>(
                  initialSelection: selected,
                  label: const Text('Reason'),
                  onSelected: (value) {
                    if (value != null) {
                      setDialogState(() => selected = value);
                    }
                  },
                  dropdownMenuEntries: [
                    for (final reason in reasons)
                      DropdownMenuEntry(value: reason, label: reason),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notes,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Optional details',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit report'),
            ),
          ],
        ),
      ),
    );
    final detailText = notes.text.trim();
    notes.dispose();
    if (submitted == true && context.mounted) {
      final repository = ref.read(newsRepositoryProvider);
      if (repository is RemoteNewsRepository) {
        try {
          await repository.reportStory(
            widget.storyId,
            reason: selected,
            details: detailText,
          );
        } catch (_) {
          // Local acknowledgement still shown; backend may be offline.
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Thank you. Reports help VeriMundi correct summaries and classifications.',
            ),
          ),
        );
      }
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionBox extends StatelessWidget {
  const _QuestionBox({
    required this.controller,
    required this.answer,
    required this.onAsk,
    required this.isDemoContent,
  });

  final TextEditingController controller;
  final AsyncValue<AiStoryAnswer>? answer;
  final VoidCallback onAsk;
  final bool isDemoContent;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Ask about this story',
      icon: Icons.question_answer_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Question',
              hintText: 'What is still uncertain?',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onAsk(),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onAsk,
            icon: const Icon(Icons.auto_awesome),
            label: Text(isDemoContent ? 'Ask mock AI' : 'Ask VeriMundi'),
          ),
          if (answer != null) ...[
            const SizedBox(height: 12),
            answer!.when(
              data: (data) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI-generated response',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(data.answer),
                      const SizedBox(height: 8),
                      Text(
                        'Confidence ${(data.confidenceScore * 100).toStringAsFixed(0)}% • Sources: ${data.sourceIds.isEmpty ? 'insufficient evidence' : data.sourceIds.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) => Text(error.toString()),
            ),
          ],
        ],
      ),
    );
  }
}
