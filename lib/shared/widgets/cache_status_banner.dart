import 'package:flutter/material.dart';

import '../../core/cache/cache_freshness.dart';

/// Visible whenever a feed is served from local cache (including freshly
/// cached rows). Callers should only mount this when [fromCache] is true so
/// live network responses never show a cache banner.
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
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (freshness) {
      CacheFreshness.expired => (
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      CacheFreshness.staleButUsable => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      CacheFreshness.fresh => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
    };
    return Semantics(
      liveRegion: true,
      label: label,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        color: bg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              freshness == CacheFreshness.expired
                  ? Icons.wifi_off_outlined
                  : Icons.history_toggle_off_outlined,
              size: 18,
              color: fg,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
