import 'package:equatable/equatable.dart';

import '../../../../core/failure.dart';
import '../../domain/carbon_intensity.dart';

sealed class CarbonIntensityState extends Equatable {
  const CarbonIntensityState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class CarbonIntensityInitial extends CarbonIntensityState {
  const CarbonIntensityInitial();
}

final class CarbonIntensityLoading extends CarbonIntensityState {
  const CarbonIntensityLoading();
}

final class CarbonIntensityLoaded extends CarbonIntensityState {
  const CarbonIntensityLoaded({
    required this.live,
    required this.daily,
    required this.lastUpdated,
    this.isRefreshing = false,
    this.refreshError,
  });

  final CarbonIntensity live;
  final List<CarbonIntensity> daily;
  final DateTime lastUpdated;
  final bool isRefreshing;
  final Failure? refreshError;

  CarbonIntensityLoaded copyWith({
    CarbonIntensity? live,
    List<CarbonIntensity>? daily,
    DateTime? lastUpdated,
    bool? isRefreshing,
    Failure? Function()? refreshError,
  }) => CarbonIntensityLoaded(
    live: live ?? this.live,
    daily: daily ?? this.daily,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    refreshError: refreshError != null ? refreshError() : this.refreshError,
  );

  @override
  List<Object?> get props => <Object?>[
    live,
    daily,
    lastUpdated,
    isRefreshing,
    refreshError,
  ];
}

final class CarbonIntensityError extends CarbonIntensityState {
  const CarbonIntensityError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
