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
          const ListTile(
            leading: Icon(Icons.smart_toy_outlined),
            title: Text('AI transparency'),
            subtitle: Text(
              'Summaries and answers are mock generated from listed fictional source material. The app never stores commercial GenAI provider secrets or calls a provider directly.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy'),
            subtitle: Text(
              'Saved stories are stored locally on this device. This demo build does not create accounts, send notifications, or upload saved-story data.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(AppConstants.tagline),
            subtitle: Text('Version 1.0.0 demo MVP'),
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
      AppDataMode.remoteUnavailable =>
        'Remote backend URL is configured, but this release does not include a live backend client. Use mock mode for the Play Store demo MVP.',
    };
  }
}
