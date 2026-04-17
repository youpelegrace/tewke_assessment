import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(.light);
  static ThemeData dark() => _build(.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isLight = brightness == .light;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.brand,
      onPrimary: Colors.white,
      secondary: AppColors.brandLight,
      onSecondary: Colors.white,
      error: IntensityBandColors.veryHigh.foreground,
      onError: Colors.white,
      surface: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      onSurface: isLight
          ? AppColors.textPrimaryLight
          : AppColors.textPrimaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight
          ? AppColors.pageLight
          : AppColors.pageDark,
      textTheme: _textTheme(isLight),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: .circular(22),
          side: BorderSide(
            color: isLight ? AppColors.borderLight : AppColors.borderDark,
            width: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(
            color: isLight ? AppColors.borderLight : AppColors.borderDark,
            width: 0.5,
          ),
          shape: const StadiumBorder(),
          padding: const .symmetric(horizontal: 20, vertical: 10),
        ),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }

  static TextTheme _textTheme(bool isLight) {
    final Color primary = isLight
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;
    final Color secondary = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 64,
        height: 1,
        fontWeight: .w500,
        letterSpacing: -2.5,
        color: primary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: .w500,
        letterSpacing: -0.2,
        color: primary,
      ),
      titleSmall: TextStyle(fontSize: 15, fontWeight: .w500, color: primary),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: .w400, color: primary),
      bodyMedium: TextStyle(fontSize: 13, fontWeight: .w400, color: secondary),
      bodySmall: TextStyle(fontSize: 11, fontWeight: .w400, color: secondary),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: .w500,
        letterSpacing: 0.2,
        color: primary,
      ),
    );
  }
}
