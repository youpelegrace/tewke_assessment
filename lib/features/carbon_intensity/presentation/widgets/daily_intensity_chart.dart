import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../domain/carbon_intensity.dart';

class DailyIntensityChart extends StatelessWidget {
  const DailyIntensityChart({
    required this.data,
    required this.lastUpdated,
    super.key,
  });

  final List<CarbonIntensity> data;
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final _Series series = _buildSeries(data);

    return Card(
      child: Padding(
        padding: const .fromLTRB(22, 20, 22, 18),
        child: Column(
          crossAxisAlignment: .stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .baseline,
              textBaseline: .alphabetic,
              children: <Widget>[
                Text('Today', style: theme.textTheme.titleSmall),
                Text('Half-hourly', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 160,
              child: _Chart(series: series, theme: theme),
            ),
            const SizedBox(height: 14),
            Divider(
              height: 0.5,
              thickness: 0.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 12),
            _Legend(textStyle: theme.textTheme.bodySmall),
            const SizedBox(height: 10),
            Text(
              _lastUpdatedText(lastUpdated),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static _Series _buildSeries(List<CarbonIntensity> data) {
    final List<FlSpot> forecastSpots = <FlSpot>[];
    final List<FlSpot> actualSpots = <FlSpot>[];
    double? nowX;
    double? nowY;

    final DateTime dayStart = data.first.from;
    final DateTime now = DateTime.now().toUtc();

    for (final CarbonIntensity c in data) {
      final double x = c.to.difference(dayStart).inMinutes.toDouble();
      forecastSpots.add(FlSpot(x, c.forecast.toDouble()));
      if (c.actual case final actual?) {
        actualSpots.add(FlSpot(x, actual.toDouble()));
      }
      final bool isCurrentSlot = !c.from.isAfter(now) && c.to.isAfter(now);
      if (isCurrentSlot) {
        nowX = now.difference(dayStart).inMinutes.toDouble();
        nowY = (c.actual ?? c.forecast).toDouble();
      }
    }

    final double minY = forecastSpots
        .map((FlSpot s) => s.y)
        .reduce((a, b) => a < b ? a : b);
    final double maxY = forecastSpots
        .map((FlSpot s) => s.y)
        .reduce((a, b) => a > b ? a : b);

    return _Series(
      forecastSpots: forecastSpots,
      actualSpots: actualSpots,
      nowX: nowX,
      nowY: nowY,
      minY: minY,
      maxY: maxY,
    );
  }

  static String _lastUpdatedText(DateTime t) {
    final Duration diff = DateTime.now().difference(t);
    if (diff.inSeconds < 30) return 'Updated just now';
    if (diff.inMinutes < 1) return 'Updated ${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes} min ago';
    return 'Updated at ${DateFormat.jm().format(t)}';
  }
}

class _Series {
  const _Series({
    required this.forecastSpots,
    required this.actualSpots,
    required this.nowX,
    required this.nowY,
    required this.minY,
    required this.maxY,
  });

  final List<FlSpot> forecastSpots;
  final List<FlSpot> actualSpots;
  final double? nowX;
  final double? nowY;
  final double minY;
  final double maxY;
}

class _Chart extends StatelessWidget {
  const _Chart({required this.series, required this.theme});

  final _Series series;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final double padding = (series.maxY - series.minY) * 0.15;
    final double? nowX = series.nowX;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 24 * 60,
        minY: (series.minY - padding).floorToDouble(),
        maxY: (series.maxY + padding).ceilToDouble(),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: ((series.maxY - series.minY + padding * 2) / 3)
              .ceilToDouble(),
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 360,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value % 360 != 0) return const SizedBox.shrink();
                final int hour = (value ~/ 60) % 24;
                final String label = value == 1440
                    ? '24:00'
                    : '${hour.toString().padLeft(2, '0')}:00';
                return Padding(
                  padding: const .only(top: 6),
                  child: Text(label, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.surface,
            tooltipBorder: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
              width: 0.5,
            ),
            tooltipBorderRadius: .circular(8),
            tooltipPadding: const .symmetric(horizontal: 10, vertical: 8),
            tooltipMargin: 12,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              if (touchedSpots.isEmpty) return <LineTooltipItem?>[];

              LineBarSpot? forecastSpot;
              LineBarSpot? actualSpot;
              for (final LineBarSpot s in touchedSpots) {
                if (s.barIndex == 0) forecastSpot = s;
                if (s.barIndex == 1) actualSpot = s;
              }

              final double xAtTouch = touchedSpots.first.x;
              final int endMin = xAtTouch.round();
              final int startMin = endMin - 30;
              String fmt(int t) {
                final int h = (t ~/ 60) % 24;
                final int m = t % 60;
                return '${h.toString().padLeft(2, '0')}:'
                    '${m.toString().padLeft(2, '0')}';
              }

              final StringBuffer buf = StringBuffer(
                '${fmt(startMin)}–${fmt(endMin)}',
              );
              if (forecastSpot != null) {
                buf.write('\nForecast  ${forecastSpot.y.round()}');
              }
              if (actualSpot != null) {
                buf.write('\nActual    ${actualSpot.y.round()}');
              }

              return touchedSpots
                  .asMap()
                  .entries
                  .map<LineTooltipItem?>(
                    (MapEntry<int, LineBarSpot> e) => e.key == 0
                        ? LineTooltipItem(
                            buf.toString(),
                            TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: theme.colorScheme.onSurface,
                              fontWeight: .w400,
                            ),
                          )
                        : null,
                  )
                  .toList();
            },
          ),
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((int i) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: AppColors.brand.withValues(alpha: 0.5),
                      strokeWidth: 0.5,
                    ),
                    FlDotData(
                      getDotPainter:
                          (
                            FlSpot spot,
                            double percent,
                            LineChartBarData bar,
                            int index,
                          ) => FlDotCirclePainter(
                            radius: 3.5,
                            color: theme.colorScheme.surface,
                            strokeColor: bar.color ?? AppColors.brand,
                            strokeWidth: 2,
                          ),
                    ),
                  );
                }).toList();
              },
        ),
        extraLinesData: ExtraLinesData(
          verticalLines: <VerticalLine>[
            if (nowX != null)
              VerticalLine(
                x: nowX,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                strokeWidth: 0.5,
                dashArray: <int>[2, 3],
              ),
          ],
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: series.forecastSpots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
            dashArray: <int>[3, 3],
          ),
          if (series.actualSpots.isNotEmpty)
            LineChartBarData(
              spots: series.actualSpots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: AppColors.brand,
              dotData: FlDotData(
                checkToShowDot: (FlSpot spot, _) {
                  if (series.actualSpots.isEmpty) return false;
                  return spot == series.actualSpots.last;
                },
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.surface,
                  strokeColor: AppColors.brand,
                  strokeWidth: 2,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.brand.withValues(alpha: 0.06),
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.textStyle});
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        _LegendItem(
          color: AppColors.brand,
          label: 'Actual',
          textStyle: textStyle,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          label: 'Forecast',
          dashed: true,
          textStyle: textStyle,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.dashed = false,
    this.textStyle,
  });

  final Color color;
  final String label;
  final bool dashed;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: <Widget>[
        SizedBox(
          width: 14,
          height: 2,
          child: dashed
              ? CustomPaint(painter: _DashedLinePainter(color: color))
              : DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: .circular(1),
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(label, style: textStyle),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = .stroke;
    const double dashWidth = 3;
    const double dashSpace = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashWidth, size.height / 2),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => false;
}
