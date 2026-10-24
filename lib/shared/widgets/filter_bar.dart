import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/news_models.dart';
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

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final current = ref.read(storyFilterProvider);
      ref.read(storyFilterProvider.notifier).state = current.copyWith(
        query: value.trim().isEmpty ? null : value.trim(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(storyFilterProvider);
    final active = _activeLabels(filter);

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
                hintText: 'Search headlines, countries, summaries',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _onQueryChanged('');
                        setState(() {});
                      },
                    ),
                ],
                onChanged: (value) {
                  setState(() {});
                  _onQueryChanged(value);
                },
              ),
            ),
            DropdownMenu<String?>(
              label: const Text('Region'),
              initialSelection: filter.region,
              onSelected: (value) =>
                  ref.read(storyFilterProvider.notifier).state = filter
                      .copyWith(region: value),
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
              label: const Text('Category'),
              initialSelection: filter.category,
              onSelected: (value) =>
                  ref.read(storyFilterProvider.notifier).state = filter
                      .copyWith(category: value),
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any category'),
                ...StoryCategory.values.map(
                  (item) => DropdownMenuEntry(value: item, label: item.name),
                ),
              ],
            ),
            DropdownMenu<Severity?>(
              label: const Text('Severity'),
              initialSelection: filter.severity,
              onSelected: (value) =>
                  ref.read(storyFilterProvider.notifier).state = filter
                      .copyWith(severity: value),
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any severity'),
                ...Severity.values.map(
                  (item) => DropdownMenuEntry(value: item, label: item.name),
                ),
              ],
            ),
            DropdownMenu<Tone?>(
              label: const Text('Tone'),
              initialSelection: filter.tone,
              onSelected: (value) =>
                  ref.read(storyFilterProvider.notifier).state = filter
                      .copyWith(tone: value),
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any tone'),
                ...Tone.values.map(
                  (item) => DropdownMenuEntry(value: item, label: item.name),
                ),
              ],
            ),
            DropdownMenu<VerificationStatus?>(
              label: const Text('Verification'),
              initialSelection: filter.verificationStatus,
              onSelected: (value) =>
                  ref.read(storyFilterProvider.notifier).state = filter
                      .copyWith(verificationStatus: value),
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Any verification'),
                ...VerificationStatus.values.map(
                  (item) => DropdownMenuEntry(value: item, label: item.name),
                ),
              ],
            ),
            FilterChip(
              label: const Text('Local coverage'),
              selected: filter.hasLocalCoverage == true,
              onSelected: (selected) =>
                  ref.read(storyFilterProvider.notifier).state = filter
                      .copyWith(hasLocalCoverage: selected ? true : null),
            ),
            TextButton.icon(
              onPressed: () {
                _controller.clear();
                ref.read(storyFilterProvider.notifier).state =
                    const StoryFilter();
                setState(() {});
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset filters'),
            ),
          ],
        ),
        if (active.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Text(
                'Active filters:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              for (final label in active) Chip(label: Text(label)),
            ],
          ),
        ],
      ],
    );
  }

  List<String> _activeLabels(StoryFilter filter) {
    return [
      if (filter.query != null && filter.query!.isNotEmpty)
        'Search: ${filter.query}',
      if (filter.region != null) 'Region: ${filter.region}',
      if (filter.countryCode != null) 'Country: ${filter.countryCode}',
      if (filter.category != null) 'Category: ${filter.category!.name}',
      if (filter.severity != null) 'Severity: ${filter.severity!.name}',
      if (filter.tone != null) 'Tone: ${filter.tone!.name}',
      if (filter.verificationStatus != null)
        'Verification: ${filter.verificationStatus!.name}',
      if (filter.hasLocalCoverage == true) 'Local coverage',
    ];
  }
}
