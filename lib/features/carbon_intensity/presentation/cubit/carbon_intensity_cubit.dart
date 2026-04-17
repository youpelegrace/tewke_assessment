import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/failure.dart';
import '../../../../../../core/result.dart';
import '../../data/carbon_intensity_repository.dart';
import '../../domain/carbon_intensity.dart';
import 'carbon_intensity_state.dart';

class CarbonIntensityCubit extends Cubit<CarbonIntensityState> {
  CarbonIntensityCubit(
    this._repository, {
    Duration refreshInterval = const Duration(minutes: 5),
  }) : _refreshInterval = refreshInterval,
       super(const CarbonIntensityInitial());

  final CarbonIntensityRepository _repository;
  final Duration _refreshInterval;
  Timer? _refreshTimer;

  Future<void> load() async {
    final CarbonIntensityState current = state;
    if (current is CarbonIntensityLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const CarbonIntensityLoading());
    }

    final (
      Result<CarbonIntensity, Failure> liveResult,
      Result<List<CarbonIntensity>, Failure> dailyResult,
    ) = await (
      _repository.getLiveIntensity(),
      _repository.getTodayIntensity(),
    ).wait;

    switch ((liveResult, dailyResult)) {
      case (
        Success<CarbonIntensity, Failure>(value: final CarbonIntensity live),
        Success<List<CarbonIntensity>, Failure>(
          value: final List<CarbonIntensity> daily,
        ),
      ):
        emit(
          CarbonIntensityLoaded(
            live: live,
            daily: _mergeLiveIntoDaily(live, daily),
            lastUpdated: .now(),
          ),
        );
      case (
        FailureResult<CarbonIntensity, Failure>(failure: final Failure f),
        _,
      ):
        _handleFailure(current, f);
      case (
        Success<CarbonIntensity, Failure>(),
        FailureResult<List<CarbonIntensity>, Failure>(failure: final Failure f),
      ):
        _handleFailure(current, f);
    }
  }

  void _handleFailure(CarbonIntensityState previous, Failure failure) {
    if (previous is CarbonIntensityLoaded) {
      emit(previous.copyWith(isRefreshing: false, refreshError: () => failure));
    } else {
      emit(CarbonIntensityError(failure));
    }
  }

  List<CarbonIntensity> _mergeLiveIntoDaily(
    CarbonIntensity live,
    List<CarbonIntensity> daily,
  ) {
    if (live.actual == null) return daily;
    return daily.map((CarbonIntensity slot) {
      if (slot.from == live.from && slot.actual == null) {
        return CarbonIntensity(
          from: slot.from,
          to: slot.to,
          forecast: slot.forecast,
          actual: live.actual,
          index: live.index,
        );
      }
      return slot;
    }).toList();
  }

  void dismissError() {
    final CarbonIntensityState current = state;
    if (current is CarbonIntensityLoaded && current.refreshError != null) {
      emit(current.copyWith(refreshError: () => null));
    }
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => load());
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
