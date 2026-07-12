import 'package:flutter/material.dart';

import '../../shared/models/news_models.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _theme(
    ColorScheme.fromSeed(seedColor: const Color(0xff276678)),
  );

  static ThemeData dark() => _theme(
    ColorScheme.fromSeed(
      seedColor: const Color(0xff5fb3c6),
      brightness: Brightness.dark,
    ),
  );

  static ThemeData _theme(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class AppSemanticColors {
  const AppSemanticColors._();

  static Color severity(Severity severity, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (severity) {
      Severity.critical => dark ? const Color(0xffff8a80) : const Color(0xffb3261e),
      Severity.serious => dark ? const Color(0xffffb074) : const Color(0xffb85c00),
      Severity.developing => dark ? const Color(0xffffd166) : const Color(0xff9a6b00),
      Severity.general => dark ? const Color(0xff9ccaff) : const Color(0xff276678),
    };
  }

  static Color tone(Tone tone, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (tone) {
      Tone.positive => dark ? const Color(0xff80cbc4) : const Color(0xff00796b),
      Tone.neutral => dark ? const Color(0xffb0bec5) : const Color(0xff546e7a),
      Tone.concerning => dark ? const Color(0xffffab91) : const Color(0xffbf360c),
      Tone.mixed => dark ? const Color(0xffce93d8) : const Color(0xff7b1fa2),
    };
  }
}
