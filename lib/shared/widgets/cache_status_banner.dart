import 'package:flutter/material.dart';

import '../../core/cache/cache_freshness.dart';

class CacheStatusBanner extends StatelessWidget {
  const CacheStatusBanner({
    required this.label,
    required this.freshness,
    super.key,
  });

  final String label;
  final CacheFreshness freshness;

  @override
  Widget build(BuildContext context) {
    if (freshness == CacheFreshness.fresh) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label: label,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        color: freshness == CacheFreshness.expired
            ? scheme.errorContainer
            : scheme.secondaryContainer,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: freshness == CacheFreshness.expired
                ? scheme.onErrorContainer
                : scheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
