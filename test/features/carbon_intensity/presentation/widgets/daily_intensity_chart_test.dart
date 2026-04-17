import 'package:carbon_intensity_dashboard/core/theme/app_theme.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/domain/carbon_intensity.dart';
import 'package:carbon_intensity_dashboard/features/carbon_intensity/presentation/widgets/daily_intensity_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<CarbonIntensity> buildDay({int withActualCount = 10}) {
    final DateTime start = .utc(2024, 3, 15);
    return .generate(48, (int i) {
      return CarbonIntensity(
        from: start.add(Duration(minutes: 30 * i)),
        to: start.add(Duration(minutes: 30 * (i + 1))),
        forecast: 150 + (i % 5) * 10,
        actual: i < withActualCount ? 145 + (i % 5) * 8 : null,
        index: .moderate,
      );
    });
  }

  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );

  testWidgets('renders title, legend, and time axis', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(DailyIntensityChart(data: buildDay(), lastUpdated: .now())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Half-hourly'), findsOneWidget);
    expect(find.text('Actual'), findsOneWidget);
    expect(find.text('Forecast'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('06:00'), findsOneWidget);
    expect(find.text('12:00'), findsOneWidget);
    expect(find.text('18:00'), findsOneWidget);
    expect(find.text('24:00'), findsOneWidget);
  });

  testWidgets('renders without actual data (start of day)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        DailyIntensityChart(
          data: buildDay(withActualCount: 0),
          lastUpdated: .now(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Forecast'), findsOneWidget);
  });

  testWidgets('empty data list renders nothing rather than crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        DailyIntensityChart(
          data: const <CarbonIntensity>[],
          lastUpdated: .now(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Today'), findsNothing);
  });
}
