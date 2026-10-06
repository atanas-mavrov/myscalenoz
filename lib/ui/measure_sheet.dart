import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ble/scale_service.dart';
import '../core/metrics.dart';
import '../l10n/strings.dart';
import '../state/providers.dart';
import 'common.dart';

/// Starts a scale session and shows its progress and result.
Future<void> showMeasureSheet(BuildContext context, {required bool sync}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    showDragHandle: false,
    builder: (_) => _MeasureSheet(sync: sync),
  );
}

class _MeasureSheet extends ConsumerStatefulWidget {
  const _MeasureSheet({required this.sync});

  final bool sync;

  @override
  ConsumerState<_MeasureSheet> createState() => _MeasureSheetState();
}

class _MeasureSheetState extends ConsumerState<_MeasureSheet> {
  late final MeasureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(measureProvider.notifier);
    Future.microtask(() {
      _controller.reset();
      _controller.start(sync: widget.sync);
    });
  }

  @override
  void dispose() {
    _controller.cancel();
    super.dispose();
  }

  String _phaseText(ScalePhase phase) => switch (phase) {
    ScalePhase.preparing => S.phasePreparing,
    ScalePhase.scanning => S.phaseScanning,
    ScalePhase.connecting => S.phaseConnecting,
    ScalePhase.waiting => widget.sync ? S.phaseWaitingSync : S.phaseWaitingLive,
    ScalePhase.weighing => S.phaseWeighing,
    ScalePhase.done || ScalePhase.failed => '',
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(measureProvider);
    final theme = Theme.of(context);
    final status = state.status;
    final saved = state.saved;

    final List<Widget> body;
    if (status?.phase == ScalePhase.failed) {
      final error = status!.error!;
      body = [
        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 12),
        Text(S.scaleError(error), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        if (error == ScaleError.permissionDenied)
          TextButton(
            onPressed: openAppSettings,
            child: Text(S.openAppSettings),
          ),
        FilledButton(
          onPressed: () => _controller.start(sync: widget.sync),
          child: Text(S.retry),
        ),
      ];
    } else if (saved != null && !widget.sync && saved.isNotEmpty) {
      final m = saved.last;
      final other = state.likelyOther;
      body = [
        Text(Metrics.weight.format(m), style: theme.textTheme.displayMedium),
        const SizedBox(height: 4),
        Text(
          m.hasComposition ? S.measurementSaved : S.weightOnlyNote,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (m.hasComposition) MetricGrid(m),
        if (other != null) ...[
          const SizedBox(height: 16),
          Text(S.looksLike(other.name), textAlign: TextAlign.center),
          TextButton(
            onPressed: () async {
              final moved = await ref.read(repoProvider).reassign(m, other);
              _controller.resultReassigned(moved);
            },
            child: Text(S.reassignTo(other.name)),
          ),
        ],
      ];
    } else if (saved != null) {
      body = [
        Icon(
          Icons.check_circle_outline,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(saved.isEmpty ? S.syncNothing : S.syncSaved(saved.length)),
      ];
    } else {
      final kg = status?.liveKg;
      body = [
        if (kg != null)
          Text(
            '${kg.toStringAsFixed(2)} kg',
            style: theme.textTheme.displayMedium,
          )
        else
          const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        const SizedBox(height: 12),
        Text(
          _phaseText(status?.phase ?? ScalePhase.preparing),
          textAlign: TextAlign.center,
        ),
      ];
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...body,
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(state.running ? S.cancel : S.close),
            ),
          ],
        ),
      ),
    );
  }
}
