class AppConstants {
  const AppConstants._();

  static const appName = 'VeriMundi';
  static const tagline = 'The world beyond the usual headlines';
  static const demoBanner =
      'Demo MVP: Stories, sources, and AI answers in this build are fictional demo content for product evaluation.';
  static const releaseStatus =
      'Production-ready demo MVP. No live news feed, user accounts, push notifications, or commercial GenAI provider calls are enabled.';
  static const apiBaseUrl = String.fromEnvironment(
    'NEWS_API_BASE_URL',
    defaultValue: 'mock',
  );
}

class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppRadius {
  const AppRadius._();

  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
}
