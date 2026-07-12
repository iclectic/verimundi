import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../models/news_models.dart';

class SeverityPill extends StatelessWidget {
  const SeverityPill({required this.severity, required this.reason, super.key});

  final Severity severity;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final color = AppSemanticColors.severity(
      severity,
      Theme.of(context).brightness,
    );
    return Semantics(
      label: 'Severity ${severity.name}. $reason',
      child: Chip(
        avatar: Icon(_icon, size: 18, color: color),
        label: Text(severity.name),
        side: BorderSide(color: color),
      ),
    );
  }

  IconData get _icon => switch (severity) {
    Severity.critical => Icons.warning_amber,
    Severity.serious => Icons.priority_high,
    Severity.developing => Icons.update,
    Severity.general => Icons.info_outline,
  };
}

class TonePill extends StatelessWidget {
  const TonePill({required this.tone, super.key});

  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final color = AppSemanticColors.tone(tone, Theme.of(context).brightness);
    return Chip(
      avatar: Icon(
        tone == Tone.positive ? Icons.volunteer_activism : Icons.tonality,
        size: 18,
      ),
      label: Text(tone.name),
      side: BorderSide(color: color),
    );
  }
}
