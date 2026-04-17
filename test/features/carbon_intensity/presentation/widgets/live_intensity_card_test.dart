import 'package:carbon_intensity_dashboard/core/theme/app_theme.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/domain/carbon_intensity.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/domain/intensity_index.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/presentation/widgets/live_intensity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );

  testWidgets('shows actual value when available with live-grid subtitle', (
    WidgetTester tester,
  ) async {
    final CarbonIntensity intensity = CarbonIntensity(
      from: .utc(2024, 3, 15, 12),
      to: .utc(2024, 3, 15, 12, 30),
      forecast: 142,
      actual: 138,
      index: .low,
    );

    await tester.pumpWidget(wrap(LiveIntensityCard(intensity: intensity)));

    expect(find.text('138'), findsOneWidget);
    expect(find.text('gCO₂/kWh'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('Good time to use energy'), findsOneWidget);
    expect(find.text('Measured from the live grid'), findsOneWidget);
  });

  testWidgets('falls back to forecast with forecast subtitle', (
    WidgetTester tester,
  ) async {
    final CarbonIntensity intensity = CarbonIntensity(
      from: .utc(2024, 3, 15, 12),
      to: .utc(2024, 3, 15, 12, 30),
      forecast: 142,
      actual: null,
      index: .moderate,
    );

    await tester.pumpWidget(wrap(LiveIntensityCard(intensity: intensity)));

    expect(find.text('142'), findsOneWidget);
    expect(find.text('Moderate'), findsOneWidget);
    expect(find.text('Use energy mindfully'), findsOneWidget);
    expect(find.text('Forecast for this half-hour'), findsOneWidget);
    expect(find.text('Measured from the live grid'), findsNothing);
  });

  testWidgets('renders the correct copy for every band', (
    WidgetTester tester,
  ) async {
    for (final IntensityIndex index in IntensityIndex.values) {
      final CarbonIntensity intensity = CarbonIntensity(
        from: .utc(2024, 3, 15, 12),
        to: .utc(2024, 3, 15, 12, 30),
        forecast: 200,
        actual: 195,
        index: index,
      );

      await tester.pumpWidget(wrap(LiveIntensityCard(intensity: intensity)));
      await tester.pumpAndSettle();

      expect(
        find.text(index.label),
        findsOneWidget,
        reason: 'Label for $index not found',
      );
      expect(
        find.text(index.userMessage),
        findsOneWidget,
        reason: 'Message for $index not found',
      );
    }
  });
}
