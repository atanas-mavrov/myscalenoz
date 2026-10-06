import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/metrics.dart';
import '../data/models.dart';
import '../l10n/strings.dart';
import '../state/providers.dart';
import 'charts.dart';
import 'common.dart';

enum _Period {
  week(7),
  month(30),
  quarter(90),
  year(365),
  all(null),
  custom(null);

  const _Period(this.days);
  final int? days;

  String get label => switch (this) {
    week => S.period7d,
    month => S.period30d,
    quarter => S.period90d,
    year => S.period1y,
    all => S.periodAll,
    custom => S.periodCustom,
  };
}

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  _Period _period = _Period.month;
  DateTimeRange? _customRange;
  ChartKind _kind = ChartKind.line;
  final _selected = {Metrics.weight.key, Metrics.fat.key};

  /// Local [from, to) bounds of the selected period; null = unbounded.
  (DateTime?, DateTime?) get _bounds {
    if (_period == _Period.custom) {
      final r = _customRange!;
      return (r.start, r.end.add(const Duration(days: 1)));
    }
    final days = _period.days;
    return (
      days == null ? null : DateTime.now().subtract(Duration(days: days)),
      null,
    );
  }

  Future<void> _selectPeriod(_Period p) async {
    if (p == _Period.custom) {
      final now = DateTime.now();
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2015),
        lastDate: now,
        initialDateRange: _customRange,
      );
      if (range == null) return;
      _customRange = range;
    }
    setState(() => _period = p);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = ref.watch(activeProfileProvider);
    final all = active == null
        ? null
        : ref.watch(measurementsProvider(active.id!)).value;
    final (from, to) = _bounds;
    final inPeriod = [
      for (final m in all?.reversed ?? const <Measurement>[])
        if ((from == null || !m.timestampUtc.toLocal().isBefore(from)) &&
            (to == null || m.timestampUtc.toLocal().isBefore(to)))
          m,
    ];
    final range = _customRange;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          active == null ? S.statistics : '${S.statistics} · ${active.name}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final p in _Period.values)
                ChoiceChip(
                  label: Text(
                    p == _Period.custom && _period == p && range != null
                        ? '${formatDate(range.start)} – ${formatDate(range.end)}'
                        : p.label,
                  ),
                  selected: _period == p,
                  onSelected: (_) => _selectPeriod(p),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<ChartKind>(
            segments: [
              ButtonSegment(
                value: ChartKind.line,
                icon: Icon(Icons.show_chart),
                label: Text(S.chartLine),
              ),
              ButtonSegment(
                value: ChartKind.bar,
                icon: Icon(Icons.bar_chart),
                label: Text(S.chartBar),
              ),
              ButtonSegment(
                value: ChartKind.scatter,
                icon: Icon(Icons.scatter_plot),
                label: Text(S.chartScatter),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.single),
          ),
          const SizedBox(height: 12),
          Text(S.metricsFilter, style: theme.textTheme.titleSmall),
          Wrap(
            spacing: 8,
            children: [
              for (final metric in Metrics.all)
                FilterChip(
                  label: Text(metric.label),
                  selected: _selected.contains(metric.key),
                  onSelected: (on) => setState(
                    () => on
                        ? _selected.add(metric.key)
                        : _selected.remove(metric.key),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (inPeriod.isEmpty)
            Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text(S.noDataInPeriod)),
            )
          else
            for (final metric in Metrics.all)
              if (_selected.contains(metric.key) &&
                  inPeriod.any((m) => metric.value(m) != null))
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metric.unit.isEmpty
                            ? metric.label
                            : '${metric.label} (${metric.unit})',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: MetricChart(
                          metric: metric,
                          measurements: inPeriod,
                          kind: _kind,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
