import '../domain/carbon_intensity.dart';

class CarbonIntensityDto {
  const CarbonIntensityDto({
    required this.from,
    required this.to,
    required this.forecast,
    required this.actual,
    required this.index,
  });

  final String from;
  final String to;
  final int forecast;
  final int? actual;
  final String index;

  factory CarbonIntensityDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> intensity =
        json['intensity'] as Map<String, dynamic>;
    return CarbonIntensityDto(
      from: json['from'] as String,
      to: json['to'] as String,
      forecast: intensity['forecast'] as int,
      actual: intensity['actual'] as int?,
      index: intensity['index'] as String,
    );
  }

  CarbonIntensity toDomain() => CarbonIntensity(
    from: .parse(from).toUtc(),
    to: .parse(to).toUtc(),
    forecast: forecast,
    actual: actual,
    index: .fromApi(index),
  );
}
