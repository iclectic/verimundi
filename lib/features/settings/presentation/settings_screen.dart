import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/app_remote_config.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_status_banners.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteConfig = ref.watch(remoteAppConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const AppStatusBanners(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.verified_outlined),
                  title: Text('Release status'),
                  subtitle: Text(AppConstants.releaseStatus),
                ),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Data mode'),
                  subtitle: Text(_dataModeCopy()),
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: const Text('Remote API readiness'),
                  subtitle: Text(_remoteReadinessCopy(remoteConfig)),
                ),
                ListTile(
                  leading: const Icon(Icons.smart_toy_outlined),
                  title: const Text('AI transparency'),
                  subtitle: Text(_aiTransparencyCopy(remoteConfig)),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy'),
                  subtitle: Text(_privacyCopy()),
                  isThreeLine: true,
                ),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(AppConstants.tagline),
                  subtitle: Text(
                    'Version ${AppConstants.appVersion} • APP_ENV=${AppConstants.appEnv}\n'
                    '${AppConstants.productHonesty}',
                  ),
                  isThreeLine: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dataModeCopy() {
    final client = ApiClient();
    return switch (client.dataMode) {
      AppDataMode.mock =>
        'Mock data mode. NEWS_API_BASE_URL is not configured for a live backend.',
      AppDataMode.remote =>
        'Remote API mode. Base URL: ${AppConstants.apiBaseUrl}. Environment: ${AppConstants.appEnv}.',
      AppDataMode.misconfigured =>
        'Misconfigured: production cannot use mock news.',
    };
  }

  String _privacyCopy() {
    final local =
        'Saved stories and feed metadata cache stay on this device. No accounts or push notifications in this build.';
    if (AppConstants.isMockApi) {
      return '$local Mock mode does not send Ask questions or problem reports to a server. Privacy policy text remains an engineering draft pending legal review.';
    }
    return '$local Remote mode may send Ask questions and optional problem reports to the configured VeriMundi API (rate-limited). Do not include personal data you do not wish to share. Privacy / Play Data Safety answers are drafts — legal review is still required before store submission.';
  }

  String _aiTransparencyCopy(AsyncValue<AppRemoteConfig?> remoteConfig) {
    if (AppConstants.isMockApi) {
      return 'Summaries and answers in mock mode are generated locally from listed fictional source material. The app never stores commercial GenAI provider secrets or calls a provider directly.';
    }
    final provider = remoteConfig.asData?.value?.aiProvider;
    final path = switch (provider) {
      'openaiCompatible' =>
        'Backend path: OpenAI-compatible GenAI (host secret). ',
      'heuristic' =>
        'Backend path: heuristic grounded synthesis (no GenAI key). ',
      null => 'Backend AI path unknown until /v1/app/config loads. ',
      _ => 'Backend path: $provider. ',
    };
    return '${path}Summaries and Ask VeriMundi answers are produced by the VeriMundi API from linked source evidence only. The Flutter client never stores GenAI secrets.';
  }

  String _remoteReadinessCopy(AsyncValue<AppRemoteConfig?> remoteConfig) {
    if (AppConstants.isMockApi) {
      return 'Mock mode — remote /v1/app/config is not consulted.';
    }

    return remoteConfig.when(
      data: (config) {
        if (config == null) {
          return 'Could not load /v1/app/config. Check NEWS_API_BASE_URL and that the API is reachable (/health, /ready).';
        }
        final updateNeeded = AppRemoteConfig.isBelowMinimum(
          current: AppConstants.appVersion,
          minimum: config.minimumAppVersion,
        );
        final ingestion =
            'RSS=${config.enableRss ? 'flagged' : 'off'}; '
            'GDELT=${config.enableGdelt ? 'flagged' : 'off'}; '
            'AI=${config.aiProvider} '
            '(flags only — restricted/unapproved sources stay disabled; no GenAI secrets on device).';
        if (config.maintenanceMode) {
          return 'Maintenance mode is on. ${config.maintenanceMessage ?? ''} $ingestion';
        }
        if (updateNeeded) {
          return 'Update required: minimum ${config.minimumAppVersion}, this build is ${AppConstants.appVersion}. $ingestion';
        }
        return 'API env=${config.environment}; min version=${config.minimumAppVersion}; $ingestion';
      },
      loading: () => 'Checking remote config…',
      error: (error, _) => 'Remote config error: $error',
    );
  }
}
