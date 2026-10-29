import 'package:flutter/material.dart';

import 'demo_banner.dart';
import 'remote_status_banner.dart';

/// Stacks demo honesty + remote maintenance/min-version banners.
class AppStatusBanners extends StatelessWidget {
  const AppStatusBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [DemoBanner(), RemoteStatusBanner()],
    );
  }
}
