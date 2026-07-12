import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('Data mode'),
            subtitle: Text(
              'Mock data mode. NEWS_API_BASE_URL is not configured for a live backend.',
            ),
          ),
          ListTile(
            leading: Icon(Icons.smart_toy_outlined),
            title: Text('AI transparency'),
            subtitle: Text(
              'Summaries and answers are mock generated from listed source material. The app never stores provider secrets.',
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(AppConstants.tagline),
            subtitle: Text('Version 0.1 MVP'),
          ),
        ],
      ),
    );
  }
}
