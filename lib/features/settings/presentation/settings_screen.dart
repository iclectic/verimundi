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
                  subtitle: Text(
                    AppConstants.isMockApi
                        ? 'Summaries and answers in mock mode are generated locally from listed fictional source material. The app never stores commercial GenAI provider secrets or calls a provider directly.'
                        : 'Summaries and answers are produced by the VeriMundi backend from linked source evidence. The Flutter client never stores GenAI secrets.',
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text('Privacy'),
                  subtitle: Text(
                    'Saved stories are stored locally on this device. This build does not create accounts or send push notifications.',
                  ),
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
            'GDELT=${config.enableGdelt ? 'flagged' : 'off'} '
            '(flags only — unapproved sources stay disabled).';
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
