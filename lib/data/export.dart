import 'dart:convert';

import '../core/metrics.dart';
import 'models.dart';

String _csvCell(Object? v) {
  final s = v?.toString() ?? '';
  return s.contains(RegExp('[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
}

/// One row per measurement, oldest first.
String exportCsv(List<Profile> profiles, List<Measurement> measurements) {
  final names = {for (final p in profiles) p.id: p.name};
  final rows = <List<Object?>>[
    [
      'profile', 'timestampUtc', 'r50', 'r500', //
      for (final m in Metrics.all) m.key,
      'bodyShape', 'source',
    ],
    for (final m in measurements)
      [
        names[m.profileId],
        m.timestampUtc.toUtc().toIso8601String(),
        m.r50,
        m.r500,
        for (final metric in Metrics.all) metric.value(m),
        m.bodyShape,
        m.source,
      ],
  ];
  return rows.map((r) => r.map(_csvCell).join(',')).join('\n');
}

/// Marks a JSON backup made by this app (read back by `AppDb.importBackup`).
const backupFormat = 'myscalenoz-backup';

/// Full backup of profiles and measurements; can be imported back.
String exportJson(List<Profile> profiles, List<Measurement> measurements) =>
    const JsonEncoder.withIndent('  ').convert({
      'format': backupFormat,
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'profiles': [for (final p in profiles) p.toMap()],
      'measurements': [for (final m in measurements) m.toMap()],
    });
