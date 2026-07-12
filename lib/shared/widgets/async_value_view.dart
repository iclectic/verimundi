import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.builder,
    this.empty,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) {
        if (data is Iterable && data.isEmpty) {
          return empty ??
              const _StateMessage(
                icon: Icons.inbox,
                message: 'Nothing to show yet.',
              );
        }
        return builder(data);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _StateMessage(
        icon: Icons.error_outline,
        message: 'Something went wrong. Pull to refresh or try again.',
        detail: error.toString(),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.message, this.detail});

  final IconData icon;
  final String message;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(
                detail!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
