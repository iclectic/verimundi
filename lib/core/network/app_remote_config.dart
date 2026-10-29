import 'json_decoding.dart';

class AppRemoteConfig {
  const AppRemoteConfig({
    required this.environment,
    required this.maintenanceMode,
    required this.minimumAppVersion,
    required this.disclaimer,
    this.maintenanceMessage,
    this.enableRss = false,
    this.enableGdelt = false,
    this.aiProvider = 'heuristic',
  });

  final String environment;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final String minimumAppVersion;
  final String disclaimer;
  final bool enableRss;
  final bool enableGdelt;

  /// Backend synthesis path only (`heuristic` | `openaiCompatible`). Never a secret.
  final String aiProvider;

  factory AppRemoteConfig.fromJson(Map<String, dynamic> json) {
    final ingestion =
        JsonDecoding.asObjectOrNull(json['ingestion']) ??
        const <String, dynamic>{};
    final ai =
        JsonDecoding.asObjectOrNull(json['ai']) ?? const <String, dynamic>{};
    return AppRemoteConfig(
      environment: JsonDecoding.asString(
        json['environment'],
        fallback: 'unknown',
      ),
      maintenanceMode: JsonDecoding.asBool(json['maintenanceMode']),
      maintenanceMessage: JsonDecoding.asStringOrNull(
        json['maintenanceMessage'],
      ),
      minimumAppVersion: JsonDecoding.asString(
        json['minimumAppVersion'],
        fallback: '1.0.0',
      ),
      disclaimer: JsonDecoding.asString(
        json['disclaimer'],
        fallback:
            'VeriMundi summaries remain imperfect and should be read with original reporting.',
      ),
      enableRss: JsonDecoding.asBool(ingestion['enableRss']),
      enableGdelt: JsonDecoding.asBool(ingestion['enableGdelt']),
      aiProvider: JsonDecoding.asString(ai['provider'], fallback: 'heuristic'),
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
