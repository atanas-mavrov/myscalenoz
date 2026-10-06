import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/strings.dart';
import '../state/providers.dart';
import 'common.dart';

class AllMeasurementsScreen extends ConsumerWidget {
  const AllMeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeProfileProvider);
    final measurements = active == null
        ? null
        : ref.watch(measurementsProvider(active.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          active == null
              ? S.allMeasurements
              : '${S.allMeasurements} · ${active.name}',
        ),
      ),
      body: measurements == null
          ? const SizedBox.shrink()
          : measurements.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${S.loadError}: $e')),
              data: (list) => list.isEmpty
                  ? Center(child: Text(S.noMeasurements))
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) => MeasurementTile(list[i]),
                    ),
            ),
    );
  }
}
