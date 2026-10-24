import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(AppConstants.tagline),
            subtitle: Text('Version 1.0.0 • APP_ENV=${AppConstants.appEnv}'),
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
}
