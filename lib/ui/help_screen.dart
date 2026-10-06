import 'package:flutter/material.dart';

import '../core/metrics.dart';
import '../l10n/strings.dart';

/// Shows the explanation of one value in a bottom sheet.
void showHelpSheet(BuildContext context, String title, String text) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(text),
          ],
        ),
      ),
    ),
  );
}

/// An intro paragraph followed by titled explanations.
class _ExplanationPage extends StatelessWidget {
  const _ExplanationPage({
    required this.title,
    required this.intro,
    required this.entries,
  });

  final String title;
  final String intro;
  final List<(String, String)> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(intro, style: theme.textTheme.bodyMedium),
          for (final (heading, text) in entries) ...[
            const SizedBox(height: 20),
            Text(heading, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(text),
          ],
        ],
      ),
    );
  }
}

/// What every measured value means.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) => _ExplanationPage(
    title: S.helpTitle,
    intro: S.helpIntro,
    entries: [
      for (final m in Metrics.all) (m.label, m.help),
      (S.mBodyShape, S.hBodyShape),
      (S.impedance, S.hImpedance),
    ],
  );
}

/// Why the app asks for each piece of profile data.
class WhyScreen extends StatelessWidget {
  const WhyScreen({super.key});

  @override
  Widget build(BuildContext context) => _ExplanationPage(
    title: S.whyTitle,
    intro: S.whyIntro,
    entries: [
      (S.name, S.whyName),
      (S.gender, S.whyGender),
      (S.birthday, S.whyBirthday),
      (S.heightCm, S.whyHeight),
      (S.refWeight, S.whyRefWeight),
      (S.privacy, S.whyStorage),
    ],
  );
}
