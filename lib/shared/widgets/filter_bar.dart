import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/news_models.dart';
import '../providers/app_providers.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(storyFilterProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: SearchBar(
            hintText: 'Search stories',
            leading: const Icon(Icons.search),
            onChanged: (value) => ref.read(storyFilterProvider.notifier).state =
                filter.copyWith(query: value),
          ),
        ),
        DropdownMenu<String>(
          label: const Text('Region'),
          initialSelection: filter.region,
          onSelected: (value) => ref.read(storyFilterProvider.notifier).state =
              filter.copyWith(region: value),
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'Africa', label: 'Africa'),
            DropdownMenuEntry(value: 'Asia', label: 'Asia'),
            DropdownMenuEntry(value: 'Europe', label: 'Europe'),
            DropdownMenuEntry(value: 'Middle East', label: 'Middle East'),
            DropdownMenuEntry(value: 'North America', label: 'North America'),
            DropdownMenuEntry(
              value: 'Latin America and the Caribbean',
              label: 'Latin America',
            ),
            DropdownMenuEntry(value: 'Oceania', label: 'Oceania'),
          ],
        ),
        DropdownMenu<Severity>(
          label: const Text('Severity'),
          initialSelection: filter.severity,
          onSelected: (value) => ref.read(storyFilterProvider.notifier).state =
              filter.copyWith(severity: value),
          dropdownMenuEntries: Severity.values
              .map((item) => DropdownMenuEntry(value: item, label: item.name))
              .toList(),
        ),
        DropdownMenu<Tone>(
          label: const Text('Tone'),
          initialSelection: filter.tone,
          onSelected: (value) => ref.read(storyFilterProvider.notifier).state =
              filter.copyWith(tone: value),
          dropdownMenuEntries: Tone.values
              .map((item) => DropdownMenuEntry(value: item, label: item.name))
              .toList(),
        ),
        FilterChip(
          label: const Text('Local coverage'),
          selected: filter.hasLocalCoverage == true,
          onSelected: (selected) =>
              ref.read(storyFilterProvider.notifier).state = filter.copyWith(
                hasLocalCoverage: selected ? true : null,
              ),
        ),
        TextButton.icon(
          onPressed: () => ref.read(storyFilterProvider.notifier).state =
              const StoryFilter(),
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset filters'),
        ),
      ],
    );
  }
}
