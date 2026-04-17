import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color pageLight = Color(0xFFF6F4EE);
  static const Color pageDark = Color(0xFF141312);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1B1A);

  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textPrimaryDark = Color(0xFFF2F0EA);
  static const Color textSecondaryLight = Color(0xFF7A7871);
  static const Color textSecondaryDark = Color(0xFF9A9892);
  static const Color textTertiaryLight = Color(0xFF9A9892);
  static const Color textTertiaryDark = Color(0xFF6A6862);

  static const Color borderLight = Color(0x0F000000);
  static const Color borderDark = Color(0x1FFFFFFF);

  static const Color brand = Color(0xFF2F5A3E);
  static const Color brandLight = Color(0xFF4D9A62);
  static const Color brandTint = Color(0xFFE8F1E9);
}

class IntensityBand {
  const IntensityBand({
    required this.foreground,
    required this.tint,
    required this.dot,
  });

  final Color foreground;
  final Color tint;
  final Color dot;
}

class IntensityBandColors {
  IntensityBandColors._();

  static const IntensityBand veryLow = IntensityBand(
    foreground: Color(0xFF2F5A3E),
    tint: Color(0xFFE8F1E9),
    dot: Color(0xFF4D9A62),
  );
  static const IntensityBand low = IntensityBand(
    foreground: Color(0xFF3E7A4A),
    tint: Color(0xFFEBF2E5),
    dot: Color(0xFF6AAE70),
  );
  static const IntensityBand moderate = IntensityBand(
    foreground: Color(0xFF8A6114),
    tint: Color(0xFFF7EBD2),
    dot: Color(0xFFD9A24A),
  );
  static const IntensityBand high = IntensityBand(
    foreground: Color(0xFF994422),
    tint: Color(0xFFF5E4D8),
    dot: Color(0xFFD4743A),
  );
  static const IntensityBand veryHigh = IntensityBand(
    foreground: Color(0xFF8A2A2A),
    tint: Color(0xFFF4DBD8),
    dot: Color(0xFFC4564A),
  );
}
