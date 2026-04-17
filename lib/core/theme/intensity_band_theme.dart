import '../../features/carbon_intensity/domain/intensity_index.dart';
import 'app_colors.dart';

extension IntensityIndexTheme on IntensityIndex {
  IntensityBand get band => switch (this) {
    .veryLow => IntensityBandColors.veryLow,
    .low => IntensityBandColors.low,
    .moderate => IntensityBandColors.moderate,
    .high => IntensityBandColors.high,
    .veryHigh => IntensityBandColors.veryHigh,
  };
}
