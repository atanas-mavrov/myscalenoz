import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../core/metrics.dart';
import '../data/models.dart';
import '../l10n/strings.dart';
import '../state/providers.dart';
import 'common.dart';
import 'help_screen.dart';

String measurementAsText(Measurement m, String profileName) => [
  '$profileName — ${formatDateTime(m.timestampUtc)}',
  for (final metric in Metrics.all)
    if (metric.value(m) != null) '${metric.label}: ${metric.format(m)}',
  if (S.bodyShapes[m.bodyShape] case final shape?) '${S.mBodyShape}: $shape',
].join('\n');

/// Lets the user pick another profile and moves [m] to it. Returns the moved
/// measurement, or null if cancelled.
Future<Measurement?> pickAndReassign(
  BuildContext context,
  WidgetRef ref,
  Measurement m,
) async {
  final profiles = await ref.read(profilesProvider.future);
  if (!context.mounted) return null;
  final to = await showDialog<Profile>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(S.reassign),
      children: [
        for (final p in profiles)
          if (p.id != m.profileId)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, p),
              child: Text(p.name),
            ),
      ],
    ),
  );
  if (to == null) return null;
  return ref.read(repoProvider).reassign(m, to);
}

class MeasurementDetailScreen extends ConsumerWidget {
  const MeasurementDetailScreen(this.m, {super.key});

  final Measurement m;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final owner = profiles.where((p) => p.id == m.profileId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.measurement),
        actions: [
          IconButton(
            tooltip: S.helpTitle,
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const HelpScreen())),
          ),
          IconButton(
            tooltip: S.share,
            icon: const Icon(Icons.share),
            onPressed: () => SharePlus.instance.share(
              ShareParams(text: measurementAsText(m, owner?.name ?? '')),
            ),
          ),
          if (profiles.length > 1)
            IconButton(
              tooltip: S.reassign,
              icon: const Icon(Icons.switch_account),
              onPressed: () async {
                final moved = await pickAndReassign(context, ref, m);
                if (moved != null && context.mounted) Navigator.pop(context);
              },
            ),
          IconButton(
            tooltip: S.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (!await confirm(context, S.deleteMeasurementQ)) return;
              await ref.read(repoProvider).deleteMeasurement(m.id!);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${owner?.name ?? ''} · ${formatDateTime(m.timestampUtc)}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(Metrics.weight.format(m), style: theme.textTheme.displaySmall),
          const SizedBox(height: 16),
          if (!m.hasComposition) ...[
            Text(S.weightOnlyNote),
            const SizedBox(height: 16),
          ],
          MetricGrid(m),
        ],
      ),
    );
  }
}
