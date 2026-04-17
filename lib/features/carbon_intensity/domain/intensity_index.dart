enum IntensityIndex {
  veryLow('very low'),
  low('low'),
  moderate('moderate'),
  high('high'),
  veryHigh('very high');

  const IntensityIndex(this.apiValue);

  final String apiValue;

  static IntensityIndex fromApi(String value) =>
      IntensityIndex.values.firstWhere(
        (IntensityIndex e) => e.apiValue == value.toLowerCase(),
        orElse: () => IntensityIndex.moderate,
      );

  String get label => switch (this) {
    .veryLow => 'Very low',
    .low => 'Low',
    .moderate => 'Moderate',
    .high => 'High',
    .veryHigh => 'Very high',
  };

  String get userMessage => switch (this) {
    .veryLow => 'Great time to use energy',
    .low => 'Good time to use energy',
    .moderate => 'Use energy mindfully',
    .high => 'Hold off if you can',
    .veryHigh => 'Avoid heavy use now',
  };
}
