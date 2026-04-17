import 'package:equatable/equatable.dart';

import 'intensity_index.dart';

class CarbonIntensity extends Equatable {
  const CarbonIntensity({
    required this.from,
    required this.to,
    required this.forecast,
    required this.actual,
    required this.index,
  });

  final DateTime from;
  final DateTime to;
  final int forecast;
  final int? actual;
  final IntensityIndex index;

  int get value => actual ?? forecast;
  bool get hasActual => actual != null;

  @override
  List<Object?> get props => <Object?>[from, to, forecast, actual, index];
}
