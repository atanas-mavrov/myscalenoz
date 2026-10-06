import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/metrics.dart';
import '../data/models.dart';
import '../l10n/strings.dart';
import 'help_screen.dart';
import 'measurement_detail_screen.dart';

String formatDateTime(DateTime utc) =>
    DateFormat.yMMMd(currentLanguage).add_Hm().format(utc.toLocal());

String formatDate(DateTime d) => DateFormat.yMMMd(currentLanguage).format(d);

/// One measurement as a list row; opens the detail screen on tap.
class MeasurementTile extends StatelessWidget {
  const MeasurementTile(this.m, {super.key});

  final Measurement m;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(Metrics.weight.format(m)),
      subtitle: Text(formatDateTime(m.timestampUtc)),
      trailing: m.hasComposition
          ? Text(
              '${S.mFat} ${Metrics.fat.format(m)}\n'
              '${S.mBmi} ${m.bmi?.toStringAsFixed(1) ?? '—'}',
              textAlign: TextAlign.end,
            )
          : null,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => MeasurementDetailScreen(m)),
      ),
    );
  }
}

/// Label/value grid of every metric of [m].
class MetricGrid extends StatelessWidget {
  const MetricGrid(this.m, {super.key});

  final Measurement m;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = S.bodyShapes[m.bodyShape];
    // (label, value, explanation)
    final cells = <(String, String, String)>[
      for (final metric in Metrics.all.skip(1))
        (metric.label, metric.format(m), metric.help),
      (S.mBodyShape, shape ?? '—', S.hBodyShape),
      (S.impedance, m.r50 > 0 ? '${m.r50} / ${m.r500} Ω' : '—', S.hImpedance),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final width = (c.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (label, value, help) in cells)
              SizedBox(
                width: width,
                child: InkWell(
                  onTap: () => showHelpSheet(context, label, help),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.bodySmall),
                      Text(value, style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            SizedBox(
              width: c.maxWidth,
              child: Text(
                S.helpHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<bool> confirm(BuildContext context, String question) async {
  final yes = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(question),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(S.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(S.delete),
        ),
      ],
    ),
  );
  return yes ?? false;
}
