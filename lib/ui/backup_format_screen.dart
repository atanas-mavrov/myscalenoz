import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';

/// Minimal hand-made backup: one user, one measurement with impedance (its
/// body composition is computed on import) and one with weight only. Kept in
/// sync with docs/BACKUP_FORMAT.md; test/data_test.dart imports it.
const backupExample = '''{
  "profiles": [
    { "id": 1, "name": "Anna", "gender": "female",
      "height_cm": 168, "birthday": "1985-04-12" }
  ],
  "measurements": [
    { "profile_id": 1, "timestamp_utc": "2026-09-01T06:45:00Z",
      "weight_kg": 64.2, "r50": 512, "r500": 461 },
    { "profile_id": 1, "timestamp_utc": "2026-09-08T06:50:00Z",
      "weight_kg": 63.8 }
  ]
}''';

/// What a file must look like to be imported.
class BackupFormatScreen extends StatelessWidget {
  const BackupFormatScreen({super.key});

  // (field, required)
  static const _profileFields = [
    ('id', true),
    ('name', true),
    ('gender', true),
    ('height_cm', true),
    ('birthday', true),
    ('ref_weight_kg', false),
    ('created_at', false),
  ];
  static const _measurementFields = [
    ('profile_id', true),
    ('timestamp_utc', true),
    ('weight_kg', true),
    ('r50', false),
    ('r500', false),
    ('source', false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace');

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    Widget field(String name, bool required) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: name,
                  style: mono?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '  ${required ? S.fmtRequired : S.fmtOptional}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: required
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Text(S.fieldDocs[name]!),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(S.fmtTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(S.fmtIntro),
          heading(S.fmtStructure),
          Text(S.fmtStructureBody),
          heading(S.fmtProfiles),
          for (final (name, required) in _profileFields) field(name, required),
          heading(S.fmtMeasurements),
          for (final (name, required) in _measurementFields)
            field(name, required),
          Text(S.fieldDocs['composition']!),
          heading(S.fmtRules),
          Text(S.fmtRulesBody),
          heading(S.fmtExample),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(backupExample, style: mono),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              icon: const Icon(Icons.copy),
              label: Text(S.fmtCopy),
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(text: backupExample),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(S.fmtCopied)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
