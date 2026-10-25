enum CacheFreshness { fresh, staleButUsable, expired }

class CachePolicy {
  const CachePolicy({
    this.freshFor = const Duration(minutes: 15),
    this.usableFor = const Duration(hours: 6),
  });

  final Duration freshFor;
  final Duration usableFor;

  CacheFreshness evaluate(DateTime fetchedAt, {DateTime? now}) {
    final age = (now ?? DateTime.now()).difference(fetchedAt);
    if (age <= freshFor) return CacheFreshness.fresh;
    if (age <= usableFor) return CacheFreshness.staleButUsable;
    return CacheFreshness.expired;
  }

  String label(DateTime fetchedAt, {DateTime? now}) {
    final when = now ?? DateTime.now();
    final age = when.difference(fetchedAt);
    final freshness = evaluate(fetchedAt, now: when);
    final ageText = _formatAge(age);
    return switch (freshness) {
      CacheFreshness.fresh => 'Updated $ageText ago',
      CacheFreshness.staleButUsable =>
        'Last updated $ageText ago (cached, still usable)',
      CacheFreshness.expired =>
        'Cached snapshot from $ageText ago — may be out of date',
    };
  }

  String _formatAge(Duration age) {
    if (age.inMinutes < 1) {
      return 'moments';
    }
    if (age.inHours < 1) {
      return '${age.inMinutes} minute${age.inMinutes == 1 ? '' : 's'}';
    }
    if (age.inDays < 1) {
      return '${age.inHours} hour${age.inHours == 1 ? '' : 's'}';
    }
    return '${age.inDays} day${age.inDays == 1 ? '' : 's'}';
  }
}
