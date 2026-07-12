import '../../../shared/models/news_models.dart';

Severity parseSeverity(String value) => Severity.values.firstWhere(
  (item) => item.name == value,
  orElse: () => Severity.general,
);

Tone parseTone(String value) => Tone.values.firstWhere(
  (item) => item.name == value,
  orElse: () => Tone.neutral,
);
