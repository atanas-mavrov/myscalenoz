import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/metrics.dart';
import '../data/models.dart';
import '../l10n/strings.dart';

enum ChartKind { line, bar, scatter }

/// Compact, axis-less trend line.
class Sparkline extends StatelessWidget {
  const Sparkline(this.values, {super.key, required this.color});

  /// Oldest first.
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return const SizedBox.expand();
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            color: color,
            barWidth: 2,
            isCurved: true,
            preventCurveOverShooting: true,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

/// One metric over time, with date and value axes.
class MetricChart extends StatelessWidget {
  const MetricChart({
    super.key,
    required this.metric,
    required this.measurements,
    required this.kind,
  });

  final Metric metric;

  /// Oldest first; entries lacking the metric are skipped.
  final List<Measurement> measurements;
  final ChartKind kind;

  static const _msPerDay = 86400000.0;

  static String _dayLabel(double days) => DateFormat.Md(currentLanguage)
      .format(DateTime.fromMillisecondsSinceEpoch((days * _msPerDay).round()));

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final points = [
      for (final m in measurements)
        if (metric.value(m) case final v?)
          (
            m.timestampUtc.toLocal().millisecondsSinceEpoch / _msPerDay,
            v.toDouble(),
          ),
    ];
    if (points.isEmpty) return const SizedBox.shrink();

    final ys = points.map((p) => p.$2);
    final lo = ys.reduce(math.min), hi = ys.reduce(math.max);
    final pad = math.max((hi - lo) * 0.15, hi.abs() * 0.01 + 0.1);
    final minY = lo - pad, maxY = hi + pad;

    Widget axisText(String s, TitleMeta meta) => SideTitleWidget(
      meta: meta,
      child: Text(s, style: labelStyle),
    );

    final leftTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 44,
        interval: (maxY - minY) / 4,
        minIncluded: false,
        maxIncluded: false,
        getTitlesWidget: (v, meta) =>
            axisText(v.toStringAsFixed(metric.decimals.clamp(0, 1)), meta),
      ),
    );
    const none = AxisTitles(sideTitles: SideTitles(showTitles: false));
    final grid = FlGridData(
      drawVerticalLine: false,
      horizontalInterval: (maxY - minY) / 4,
    );
    final border = FlBorderData(show: false);

    if (kind == ChartKind.bar) {
      final step = math.max(1, (points.length / 4).ceil());
      return BarChart(
        BarChartData(
          minY: minY,
          maxY: maxY,
          gridData: grid,
          borderData: border,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: none,
            rightTitles: none,
            leftTitles: leftTitles,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.round();
                  if (i % step != 0 || i < 0 || i >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return axisText(_dayLabel(points[i].$1), meta);
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    fromY: minY,
                    toY: points[i].$2,
                    color: color,
                    width: math.min(14, 220 / points.length),
                  ),
                ],
              ),
          ],
        ),
      );
    }

    // A single point (or several on one day) still needs a non-empty x range.
    final x0 = points.first.$1, x1 = points.last.$1;
    final xPad = math.max((x1 - x0) * 0.04, 0.5);
    final minX = x0 - xPad, maxX = x1 + xPad;
    final titles = FlTitlesData(
      topTitles: none,
      rightTitles: none,
      leftTitles: leftTitles,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: (maxX - minX) / 4,
          minIncluded: false,
          maxIncluded: false,
          getTitlesWidget: (v, meta) => axisText(_dayLabel(v), meta),
        ),
      ),
    );

    if (kind == ChartKind.scatter) {
      return ScatterChart(
        ScatterChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          gridData: grid,
          borderData: border,
          titlesData: titles,
          scatterTouchData: ScatterTouchData(enabled: false),
          scatterSpots: [
            for (final (x, y) in points)
              ScatterSpot(
                x,
                y,
                dotPainter: FlDotCirclePainter(radius: 3.5, color: color),
              ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        gridData: grid,
        borderData: border,
        titlesData: titles,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  '${s.y.toStringAsFixed(metric.decimals)} ${metric.unit}\n'
                  '${_dayLabel(s.x)}',
                  labelStyle!.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (final (x, y) in points) FlSpot(x, y)],
            color: color,
            barWidth: 2,
            dotData: FlDotData(show: points.length <= 40),
          ),
        ],
      ),
    );
  }
}
