import 'package:carbon_intensity_dashboard/features/carbon_intensity/data/carbon_intensity_dto.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/domain/intensity_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarbonIntensityDto.fromJson', () {
    test('parses a complete entry', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'from': '2024-03-15T12:00Z',
        'to': '2024-03-15T12:30Z',
        'intensity': <String, dynamic>{
          'forecast': 200,
          'actual': 195,
          'index': 'moderate',
        },
      };

      final CarbonIntensityDto dto = CarbonIntensityDto.fromJson(json);

      expect(dto.from, '2024-03-15T12:00Z');
      expect(dto.to, '2024-03-15T12:30Z');
      expect(dto.forecast, 200);
      expect(dto.actual, 195);
      expect(dto.index, 'moderate');
    });

    test('accepts null actual for future slots', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'from': '2024-03-15T23:30Z',
        'to': '2024-03-16T00:00Z',
        'intensity': <String, dynamic>{
          'forecast': 180,
          'actual': null,
          'index': 'moderate',
        },
      };

      final CarbonIntensityDto dto = CarbonIntensityDto.fromJson(json);

      expect(dto.actual, isNull);
      expect(dto.forecast, 180);
    });
  });

  group('CarbonIntensityDto.toDomain', () {
    test('produces a domain model with UTC timestamps', () {
      const CarbonIntensityDto dto = CarbonIntensityDto(
        from: '2024-03-15T12:00Z',
        to: '2024-03-15T12:30Z',
        forecast: 142,
        actual: 138,
        index: 'low',
      );

      final domain = dto.toDomain();

      expect(domain.from, DateTime.utc(2024, 3, 15, 12));
      expect(domain.to, DateTime.utc(2024, 3, 15, 12, 30));
      expect(domain.forecast, 142);
      expect(domain.actual, 138);
      expect(domain.index, IntensityIndex.low);
      expect(domain.value, 138, reason: 'prefers actual over forecast');
      expect(domain.hasActual, isTrue);
    });

    test('value falls back to forecast when actual is null', () {
      const CarbonIntensityDto dto = CarbonIntensityDto(
        from: '2024-03-15T23:30Z',
        to: '2024-03-16T00:00Z',
        forecast: 180,
        actual: null,
        index: 'moderate',
      );

      final domain = dto.toDomain();

      expect(domain.value, 180);
      expect(domain.hasActual, isFalse);
    });
  });
}
