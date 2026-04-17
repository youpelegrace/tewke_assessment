import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.isRefreshing,
    required this.onRefresh,
    super.key,
  });

  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: <Widget>[
              Text('Carbon intensity', style: theme.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('Great Britain grid', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        _RefreshButton(onTap: onRefresh, isRefreshing: isRefreshing),
      ],
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.onTap, required this.isRefreshing});

  final VoidCallback onTap;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color borderColor = theme.brightness == .light
        ? AppColors.borderLight
        : AppColors.borderDark;

    return Semantics(
      button: true,
      label: 'Refresh',
      enabled: !isRefreshing,
      child: GestureDetector(
        onTap: isRefreshing ? null : onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: .circle,
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Center(
            child: isRefreshing
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
          ),
        ),
      ),
    );
  }
}
