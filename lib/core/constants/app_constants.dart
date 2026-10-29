class AppConstants {
  const AppConstants._();

  static const appName = 'VeriMundi';
  static const tagline = 'The world beyond the usual headlines';
  static const appVersion = '1.0.0';
  static const demoBanner =
      'Demo MVP: Stories, sources, and AI answers in this build are fictional demo content for product evaluation.';
  static const productHonesty =
      'VeriMundi summaries remain imperfect and should be read alongside original reporting. Live feeds require approved sources.';
  static const releaseStatus =
      'Mock or remote modes available. Production builds must set APP_ENV=production with a live NEWS_API_BASE_URL — silent mock fallback is forbidden.';
  static const apiBaseUrl = String.fromEnvironment(
    'NEWS_API_BASE_URL',
    defaultValue: 'mock',
  );
  static const appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isMockApi {
    final base = apiBaseUrl.trim().toLowerCase();
    return base.isEmpty || base == 'mock';
  }

  static bool get isProductionEnv {
    final env = appEnv.trim().toLowerCase();
    return env == 'production' || env == 'prod';
  }
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
