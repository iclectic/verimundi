class AppRemoteConfig {
  const AppRemoteConfig({
    required this.environment,
    required this.maintenanceMode,
    required this.minimumAppVersion,
    required this.disclaimer,
    this.maintenanceMessage,
    this.enableRss = false,
    this.enableGdelt = false,
  });

  final String environment;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final String minimumAppVersion;
  final String disclaimer;
  final bool enableRss;
  final bool enableGdelt;

  factory AppRemoteConfig.fromJson(Map<String, dynamic> json) {
    final ingestion = json['ingestion'] as Map<String, dynamic>? ?? const {};
    return AppRemoteConfig(
      environment: json['environment'] as String? ?? 'unknown',
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
      maintenanceMessage: json['maintenanceMessage'] as String?,
      minimumAppVersion: json['minimumAppVersion'] as String? ?? '1.0.0',
      disclaimer:
          json['disclaimer'] as String? ??
          'VeriMundi summaries remain imperfect and should be read with original reporting.',
      enableRss: ingestion['enableRss'] as bool? ?? false,
      enableGdelt: ingestion['enableGdelt'] as bool? ?? false,
    );
  }

  /// Returns true when [current] is strictly older than [minimum] (simple SemVer x.y.z).
  static bool isBelowMinimum({
    required String current,
    required String minimum,
  }) {
    List<int> parts(String value) {
      final cleaned = value.split('+').first.split('-').first;
      return cleaned.split('.').map((part) => int.tryParse(part) ?? 0).toList();
    }

    final a = parts(current);
    final b = parts(minimum);
    for (var i = 0; i < 3; i++) {
      final left = i < a.length ? a[i] : 0;
      final right = i < b.length ? b[i] : 0;
      if (left < right) return true;
      if (left > right) return false;
    }
    return false;
  }
}
