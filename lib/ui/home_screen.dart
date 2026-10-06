import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_config.dart';
import '../core/metrics.dart';
import '../data/models.dart';
import '../l10n/strings.dart';
import '../state/providers.dart';
import 'all_measurements_screen.dart';
import 'charts.dart';
import 'common.dart';
import 'measure_sheet.dart';
import 'profile_edit_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final active = ref.watch(activeProfileProvider);

    // First start (or after deleting all data): create the first profile.
    if (profiles.hasValue && active == null) {
      return const ProfileEditScreen(onboarding: true);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            tooltip: S.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _push(context, const SettingsScreen()),
          ),
        ],
      ),
      body: profiles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${S.loadError}: $e')),
        data: (list) => _Dashboard(profiles: list, active: active!),
      ),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.profiles, required this.active});

  final List<Profile> profiles;
  final Profile active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final measurements = ref.watch(measurementsProvider(active.id!));
    void push(Widget screen) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final p in profiles)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.name),
                    selected: p.id == active.id,
                    onSelected: (_) => ref
                        .read(settingsProvider.notifier)
                        .setActiveProfile(p.id),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: () => showMeasureSheet(context, sync: false),
            icon: const Icon(Icons.monitor_weight_outlined),
            label: Text(S.newMeasurement),
          ),
        ),
        ...measurements.when(
          loading: () => const [LinearProgressIndicator()],
          error: (e, _) => [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${S.loadError}: $e'),
            ),
          ],
          data: (list) => list.isEmpty
              ? [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text(S.noMeasurements)),
                  ),
                ]
              : [
                  _Trends(list),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      S.lastMeasurements,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  for (final m in list.take(10)) MeasurementTile(m),
                ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => push(const StatsScreen()),
                  icon: const Icon(Icons.show_chart),
                  label: Text(S.statistics),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => push(const AllMeasurementsScreen()),
                  icon: const Icon(Icons.list),
                  label: Text(S.allMeasurements),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Latest value + sparkline for the key metrics, over the last month (or the
/// most recent measurements when the last month is sparse).
class _Trends extends StatelessWidget {
  const _Trends(this.newestFirst);

  final List<Measurement> newestFirst;

  static List<Metric> get _metrics => [
    Metrics.weight,
    Metrics.fat,
    Metrics.skelMuscle,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthAgo = DateTime.now().toUtc().subtract(const Duration(days: 30));
    var recent = newestFirst
        .where((m) => m.timestampUtc.isAfter(monthAgo))
        .toList();
    if (recent.length < 5) recent = newestFirst.take(15).toList();
    final oldestFirst = recent.reversed.toList();
    final latest = newestFirst.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.trends, style: theme.textTheme.titleMedium),
              for (final metric in _metrics)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metric.label,
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              metric.format(latest),
                              style: metric.key == Metrics.weight.key
                                  ? theme.textTheme.headlineMedium
                                  : theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 44,
                          child: Sparkline([
                            for (final m in oldestFirst)
                              if (metric.value(m) case final v?) v.toDouble(),
                          ], color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
