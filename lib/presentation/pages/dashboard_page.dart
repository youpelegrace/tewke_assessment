import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/carbon_intensity_cubit.dart';
import '../cubit/carbon_intensity_state.dart';
import '../widgets/app_header.dart';
import '../widgets/daily_intensity_chart.dart';
import '../widgets/error_view.dart';
import '../widgets/live_intensity_card.dart';
import '../widgets/loading_view.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CarbonIntensityCubit, CarbonIntensityState>(
          builder: (BuildContext context, CarbonIntensityState state) {
            return RefreshIndicator(
              onRefresh: () => context.read<CarbonIntensityCubit>().load(),
              color: Theme.of(context).colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const .symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: <Widget>[
                    const SizedBox(height: 12),
                    AppHeader(
                      isRefreshing:
                          state is CarbonIntensityLoaded && state.isRefreshing,
                      onRefresh: () => unawaited(
                        context.read<CarbonIntensityCubit>().load(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ContentFor(state: state),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ContentFor extends StatelessWidget {
  const _ContentFor({required this.state});
  final CarbonIntensityState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      CarbonIntensityInitial() ||
      CarbonIntensityLoading() => const LoadingView(),
      CarbonIntensityError(failure: final f) => ErrorView(
        failure: f,
        onRetry: () => unawaited(context.read<CarbonIntensityCubit>().load()),
      ),
      CarbonIntensityLoaded(
        live: final live,
        daily: final daily,
        lastUpdated: final lastUpdated,
        refreshError: final refreshError,
      ) =>
        Column(
          crossAxisAlignment: .stretch,
          children: <Widget>[
            if (refreshError case final refreshError?)
              _RefreshErrorBanner(
                message: refreshError.message,
                onDismiss: () =>
                    context.read<CarbonIntensityCubit>().dismissError(),
              ),
            LiveIntensityCard(intensity: live),
            const SizedBox(height: 16),
            DailyIntensityChart(data: daily, lastUpdated: lastUpdated),
          ],
        ),
    };
  }
}

class _RefreshErrorBanner extends StatelessWidget {
  const _RefreshErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const .only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.08),
          borderRadius: .circular(12),
        ),
        child: Padding(
          padding: const .fromLTRB(14, 10, 6, 10),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.cloud_off_outlined,
                size: 16,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: .zero,
                  iconSize: 16,
                  icon: Icon(Icons.close, color: theme.colorScheme.error),
                  onPressed: onDismiss,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
