import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/app_remote_config.dart';
import '../providers/app_providers.dart';

/// Surfaces maintenance and minimum-version messages from `/v1/app/config`.
/// Hidden in mock mode and when config cannot be fetched.
class RemoteStatusBanner extends ConsumerWidget {
  const RemoteStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (AppConstants.isMockApi) {
      return const SizedBox.shrink();
    }

    final configAsync = ref.watch(remoteAppConfigProvider);
    return configAsync.when(
      data: (config) {
        if (config == null) {
          return const SizedBox.shrink();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (config.maintenanceMode)
              _Banner(
                message:
                    config.maintenanceMessage ??
                    'VeriMundi is temporarily unavailable for maintenance.',
                tone: _BannerTone.warning,
              ),
            if (AppRemoteConfig.isBelowMinimum(
              current: AppConstants.appVersion,
              minimum: config.minimumAppVersion,
            ))
              _Banner(
                message:
                    'This app version (${AppConstants.appVersion}) is below the '
                    'minimum required (${config.minimumAppVersion}). Please update.',
                tone: _BannerTone.error,
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

enum _BannerTone { warning, error }

class _Banner extends StatelessWidget {
  const _Banner({required this.message, required this.tone});

  final String message;
  final _BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = tone == _BannerTone.error
        ? scheme.errorContainer
        : scheme.secondaryContainer;
    final foreground = tone == _BannerTone.error
        ? scheme.onErrorContainer
        : scheme.onSecondaryContainer;

    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: background,
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
