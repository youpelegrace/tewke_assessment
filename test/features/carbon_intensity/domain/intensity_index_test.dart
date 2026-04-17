import 'package:carbon_intensity_dashboard/features/carbon_intensity/domain/intensity_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntensityIndex.fromApi', () {
    test('parses each documented API value', () {
      expect(IntensityIndex.fromApi('very low'), IntensityIndex.veryLow);
      expect(IntensityIndex.fromApi('low'), IntensityIndex.low);
      expect(IntensityIndex.fromApi('moderate'), IntensityIndex.moderate);
      expect(IntensityIndex.fromApi('high'), IntensityIndex.high);
      expect(IntensityIndex.fromApi('very high'), IntensityIndex.veryHigh);
    });

    test('is case insensitive', () {
      expect(IntensityIndex.fromApi('LOW'), IntensityIndex.low);
      expect(IntensityIndex.fromApi('Very High'), IntensityIndex.veryHigh);
      expect(IntensityIndex.fromApi('MoDeRaTe'), IntensityIndex.moderate);
    });

    test('falls back to moderate on unknown values', () {
      expect(IntensityIndex.fromApi('unknown'), IntensityIndex.moderate);
      expect(IntensityIndex.fromApi(''), IntensityIndex.moderate);
      expect(IntensityIndex.fromApi('   '), IntensityIndex.moderate);
    });
  });

  group('display metadata', () {
    test('every variant has a distinct label', () {
      final Set<String> labels = IntensityIndex.values
          .map((IntensityIndex e) => e.label)
          .toSet();
      expect(labels.length, IntensityIndex.values.length);
    });

    test('every variant has a non-empty user message', () {
      for (final IntensityIndex v in IntensityIndex.values) {
        expect(v.userMessage, isNotEmpty, reason: '$v missing message');
      }
    });
  });
}
