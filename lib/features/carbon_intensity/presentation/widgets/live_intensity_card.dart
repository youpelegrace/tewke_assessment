import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/intensity_band_theme.dart';
import '../../domain/carbon_intensity.dart';

class LiveIntensityCard extends StatelessWidget {
  const LiveIntensityCard({required this.intensity, super.key});

  final CarbonIntensity intensity;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final IntensityBand band = intensity.index.band;

    return Card(
      child: Padding(
        padding: const .fromLTRB(22, 22, 22, 20),
        child: Column(
          crossAxisAlignment: .start,
          children: <Widget>[
            _IndexPill(
              label: intensity.index.label,
              tint: band.tint,
              foreground: band.foreground,
              dot: band.dot,
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: .baseline,
              textBaseline: .alphabetic,
              children: <Widget>[
                Text('${intensity.value}', style: theme.textTheme.displayLarge),
                const SizedBox(width: 8),
                Padding(
                  padding: const .only(bottom: 6),
                  child: Text('gCO₂/kWh', style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(intensity.index.userMessage, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 3),
            Text(_subtitleFor(intensity), style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  String _subtitleFor(CarbonIntensity c) => c.hasActual
      ? 'Measured from the live grid'
      : 'Forecast for this half-hour';
}

class _IndexPill extends StatelessWidget {
  const _IndexPill({
    required this.label,
    required this.tint,
    required this.foreground,
    required this.dot,
  });

  final String label;
  final Color tint;
  final Color foreground;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .fromLTRB(9, 5, 11, 5),
      decoration: BoxDecoration(color: tint, borderRadius: .circular(999)),
      child: Row(
        mainAxisSize: .min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: .circle, color: dot),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: .w500,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
