import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: AppConstants.demoBanner,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: scheme.tertiaryContainer,
        child: Text(
          AppConstants.demoBanner,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onTertiaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
