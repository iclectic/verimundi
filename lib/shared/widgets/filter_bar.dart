import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/news_labels.dart';
import '../models/news_models.dart';
import '../models/story_filter_extensions.dart';
import '../providers/app_providers.dart';

/// Discovery filters with debounced query updates and active-filter chips.
class FilterBar extends ConsumerStatefulWidget {
  const FilterBar({super.key});

  @override
  ConsumerState<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<FilterBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  static const debounceDuration = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(storyFilterProvider).query ?? '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _resetPage() {
    ref.read(feedPageProvider.notifier).state = 1;
  }

  void _setFilter(StoryFilter next) {
    _resetPage();
    ref.read(storyFilterProvider.notifier).state = next;
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, () {
      if (!mounted) return;
      final current = ref.read(storyFilterProvider);
      final trimmed = value.trim();
      _setFilter(
        current.copyWith(query: trimmed.isEmpty ? null : trimmed),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(storyFilterProvider);
    // Keep the search field aligned when filters are cleared elsewhere.
    final queryText = filter.query ?? '';
    if (_controller.text != queryText && !_debounceActive) {
      _controller.value = TextEditingValue(
        text: queryText,
        selection: TextSelection.collapsed(offset: queryText.length),
      );
    }
    final active = _activeEntries(filter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: SearchBar(
                controller: _controller,
                hintText: 'Search headlines, sources, summaries',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _debounce?.cancel();
                        _controller.clear();
                        _setFilter(filter.copyWith(query: null));
                        setState(() {});
                      },
                    ),
                ],
                onChanged: (value) {
                  setState(() {});
                  _onQueryChanged(value);
                },
                onSubmitted: (value) {
                  _debounce?.cancel();
                  final trimmed = value.trim();
                  _setFilter(
                    filter.copyWith(query: trimmed.isEmpty ? null : trimmed),
                  );
                },
              ),
            ),
            DropdownMenu<String?>(
              key: ValueKey('region-${filter.region}'),
              label: const Text('Region'),
              initialSelection: filter.region,
              onSelected: (value) => _setFilter(filter.copyWith(region: value)),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: null, label: 'Any region'),
                DropdownMenuEntry(value: 'Africa', label: 'Africa'),
                DropdownMenuEntry(value: 'Asia', label: 'Asia'),
                DropdownMenuEntry(value: 'Europe', label: 'Europe'),
                DropdownMenuEntry(value: 'Middle East', label: 'Middle East'),
                DropdownMenuEntry(
                  value: 'North America',
                  label: 'North America',
                ),
                DropdownMenuEntry(
                  value: 'Latin America and the Caribbean',
                  label: 'Latin America',
                ),
                DropdownMenuEntry(value: 'Oceania', label: 'Oceania'),
              ],
            ),
            DropdownMenu<StoryCategory?>(
              key: ValueKey('category-${filter.category}'),
              label: const Text('Category'),
              initialSelection: filter.category,
              onSelected: (value) =>
                  _setFilter(filter.copyWith(category: value)),
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any category'),
                ...StoryCategory.values.map(
                  (item) => DropdownMenuEntry(value: item, label: item.label),
                ),
              ],
            ),
            DropdownMenu<Severity?>(
              key: ValueKey('severity-${filter.severity}'),
              label: const Text('Severity'),
              initialSelection: filter.severity,
              onSelected: (value) =>
                  _setFilter(filter.copyWith(severity: value)),
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any severity'),
                ...Severity.values.map(
                  (item) => DropdownMenuEntry(value: item, label: item.label),
                ),
              ],
            ),
            DropdownMenu<Tone?>(
              key: ValueKey('tone-${filter.tone}'),
              label: const Text('Tone'),
              initialSelection: filter.tone,
              onSelected: (value) => _setFilter(filter.copyWith(tone: value)),
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any tone'),
                ...Tone.values.map(
                  (item) => DropdownMenuEntry(value: item, label: item.label),
                ),
              ],
            ),
            DropdownMenu<VerificationStatus?>(
              key: ValueKey('verification-${filter.verificationStatus}'),
              label: const Text('Verification'),
              initialSelection: filter.verificationStatus,
              onSelected: (value) =>
                  _setFilter(filter.copyWith(verificationStatus: value)),
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any verification'),
                ...VerificationStatus.values.map(
                  (item) => DropdownMenuEntry(value: item, label: item.label),
                ),
              ],
            ),
            FilterChip(
              label: const Text('Local coverage'),
              selected: filter.hasLocalCoverage == true,
              onSelected: (selected) => _setFilter(
                filter.copyWith(hasLocalCoverage: selected ? true : null),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                _debounce?.cancel();
                _controller.clear();
                _setFilter(const StoryFilter());
                setState(() {});
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset filters'),
            ),
          ],
        ),
        if (active.isNotEmpty) ...[
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            label: '${active.length} active discovery filters',
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Active filters:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                for (final entry in active)
                  InputChip(
                    label: Text(entry.label),
                    onDeleted: () {
                      _debounce?.cancel();
                      if (entry.clearQuery) {
                        _controller.clear();
                      }
                      _setFilter(entry.clear(filter));
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),
        ] else if (filter.hasActiveConstraints == false) ...[
          const SizedBox(height: 8),
          Text(
            'Tip: search uses the live /v1/search API when a query is set.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  bool get _debounceActive => _debounce?.isActive ?? false;

  List<_ActiveFilter> _activeEntries(StoryFilter filter) {
    return [
      if (filter.query != null && filter.query!.isNotEmpty)
        _ActiveFilter(
          label: 'Search: ${filter.query}',
          clearQuery: true,
          clear: (current) => current.copyWith(query: null),
        ),
      if (filter.region != null)
        _ActiveFilter(
          label: 'Region: ${filter.region}',
          clear: (current) => current.copyWith(region: null),
        ),
      if (filter.countryCode != null)
        _ActiveFilter(
          label: 'Country: ${filter.countryCode}',
          clear: (current) => current.copyWith(countryCode: null),
        ),
      if (filter.category != null)
        _ActiveFilter(
          label: 'Category: ${filter.category!.label}',
          clear: (current) => current.copyWith(category: null),
        ),
      if (filter.severity != null)
        _ActiveFilter(
          label: 'Severity: ${filter.severity!.label}',
          clear: (current) => current.copyWith(severity: null),
        ),
      if (filter.tone != null)
        _ActiveFilter(
          label: 'Tone: ${filter.tone!.label}',
          clear: (current) => current.copyWith(tone: null),
        ),
      if (filter.verificationStatus != null)
        _ActiveFilter(
          label: 'Verification: ${filter.verificationStatus!.label}',
          clear: (current) => current.copyWith(verificationStatus: null),
        ),
      if (filter.hasLocalCoverage == true)
        _ActiveFilter(
          label: 'Local coverage',
          clear: (current) => current.copyWith(hasLocalCoverage: null),
        ),
    ];
  }
}

class _ActiveFilter {
  const _ActiveFilter({
    required this.label,
    required this.clear,
    this.clearQuery = false,
  });

  final String label;
  final StoryFilter Function(StoryFilter current) clear;
  final bool clearQuery;
}
