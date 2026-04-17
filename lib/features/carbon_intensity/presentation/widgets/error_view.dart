import 'package:flutter/material.dart';

import '../../../../../../core/failure.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({required this.failure, required this.onRetry, super.key});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String title = switch (failure) {
      NetworkFailure() => "You're offline",
      ServerFailure() => 'The grid is napping',
      ParseFailure() => 'Bad data from the grid',
      UnknownFailure() => 'Something went wrong',
    };

    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const .symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: .min,
            children: <Widget>[
              Icon(
                Icons.cloud_off_outlined,
                size: 36,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: .center,
              ),
              const SizedBox(height: 6),
              Text(
                failure.message,
                style: theme.textTheme.bodyMedium,
                textAlign: .center,
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
