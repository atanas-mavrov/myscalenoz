import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app_config.dart';
import '../ble/scale_service.dart';
import '../data/export.dart';
import '../data/models.dart';
import '../l10n/strings.dart';
import '../state/providers.dart';
import 'backup_format_screen.dart';
import 'common.dart';
import 'help_screen.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref, String ext) async {
    final db = ref.read(dbProvider);
    final measurements = await db.allMeasurements();
    final profiles = await db.profiles();
    // A backup is worth making even before the first measurement.
    if (ext == 'csv' ? measurements.isEmpty : profiles.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(S.exportEmpty)));
      }
      return;
    }
    final text = ext == 'csv'
        ? exportCsv(profiles, measurements)
        : exportJson(profiles, measurements);
    final day = DateTime.now().toIso8601String().substring(0, 10);
    final dir = await getTemporaryDirectory();
    final file = File(
      p.join(dir.path, '${AppConfig.appName.toLowerCase()}-$day.$ext'),
    );
    await file.writeAsString(text);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  void _snack(BuildContext context, String text) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  void _showFormat(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const BackupFormatScreen()));

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final file = await FilePicker.pickFile();
    if (file == null) return;
    final (int, int) result;
    try {
      final text = utf8.decode(await file.readAsBytes());
      result = await ref.read(repoProvider).importBackup(jsonDecode(text));
    } on FormatException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.importInvalid),
            action: SnackBarAction(
              label: S.fmtTitle,
              onPressed: () => _showFormat(context),
            ),
          ),
        );
      }
      return;
    }
    if (context.mounted) _snack(context, S.importDone(result.$1, result.$2));
  }

  /// Step 1: pick the user and whether to remove the user too. Step 2:
  /// confirm with the exact consequences.
  Future<void> _deleteUserData(
    BuildContext context,
    WidgetRef ref,
    List<Profile> profiles,
  ) async {
    final choice = await showDialog<(Profile, bool)>(
      context: context,
      builder: (_) => _DeleteUserDialog(profiles: profiles),
    );
    if (choice == null || !context.mounted) return;
    final (profile, alsoProfile) = choice;
    final n = await ref.read(dbProvider).countMeasurements(profile.id!);
    if (!context.mounted) return;
    final ok = await _confirmDelete(
      context,
      S.deleteUserDataQ(profile.name, n, alsoProfile),
    );
    if (!ok) return;
    await ref
        .read(repoProvider)
        .deleteUserData(profile.id!, alsoProfile: alsoProfile);
    if (context.mounted) _snack(context, S.deletedUserData(profile.name));
  }

  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    final ok = await _confirmDelete(
      context,
      S.deleteAllDataQ,
      requireAcknowledge: true,
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    // Back to the root, which turns into the first-start screen.
    Navigator.of(context).popUntil((r) => r.isFirst);
    await ref.read(repoProvider).deleteAllData();
    messenger.showSnackBar(SnackBar(content: Text(S.deletedAllData)));
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    // '' stands for "follow the phone" (null would mean "cancelled").
    final phone =
        languages[resolveLanguage(
          WidgetsBinding.instance.platformDispatcher.locales,
        )]!;
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(S.languageSection),
        children: [
          RadioGroup<String>(
            groupValue: current ?? '',
            onChanged: (v) => Navigator.pop(context, v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: '',
                  title: Text(S.languageFollowsPhone),
                  subtitle: Text(phone.languageName),
                ),
                for (final MapEntry(key: code, value: s) in languages.entries)
                  RadioListTile<String>(
                    value: code,
                    title: Text(s.languageName),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    await ref
        .read(settingsProvider.notifier)
        .setLanguage(picked.isEmpty ? null : picked);
  }

  Future<void> _findScale(BuildContext context, WidgetRef ref) async {
    final saved = ref.read(settingsProvider).scales;
    final id = await showDialog<String>(
      context: context,
      builder: (_) =>
          _ScaleSearchDialog(savedIds: {for (final s in saved) s.id}),
    );
    if (id == null || !context.mounted) return;
    await _nameScale(
      context,
      ref,
      SavedScale(id: id, name: '${S.scaleDefaultName} ${saved.length + 1}'),
    );
  }

  /// Asks for a name and saves [scale] under it (also used to rename).
  Future<void> _nameScale(
    BuildContext context,
    WidgetRef ref,
    SavedScale scale,
  ) async {
    final controller = TextEditingController(text: scale.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.scaleName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(helperText: scale.id),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(S.save),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    await ref
        .read(settingsProvider.notifier)
        .saveScale(SavedScale(id: scale.id, name: name.trim()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    void edit([Profile? profile]) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileEditScreen(profile: profile),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(S.settings)),
      body: ListView(
        children: [
          _Header(S.scaleSection),
          if (settings.scales.isEmpty)
            ListTile(leading: Icon(Icons.bluetooth), title: Text(S.scaleNone)),
          for (final scale in settings.scales)
            ListTile(
              leading: const Icon(Icons.monitor_weight_outlined),
              title: Text(scale.name),
              subtitle: Text(scale.id),
              onTap: () => _nameScale(context, ref, scale),
              trailing: IconButton(
                tooltip: S.delete,
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await confirm(context, S.scaleForgetQ(scale.name))) {
                    await ref
                        .read(settingsProvider.notifier)
                        .removeScale(scale.id);
                  }
                },
              ),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(S.scaleFind),
            onTap: () => _findScale(context, ref),
          ),
          _Header(S.usersSection),
          for (final profile in profiles)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(profile.name),
              subtitle: Text(
                '${profile.gender == Gender.male ? S.male : S.female} · '
                '${profile.heightCm} cm · '
                '${ageAt(profile.birthday, DateTime.now())} ${S.years}',
              ),
              onTap: () => edit(profile),
              trailing: IconButton(
                tooltip: S.delete,
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await confirm(context, S.deleteProfileQ(profile.name))) {
                    await ref.read(repoProvider).deleteProfile(profile.id!);
                  }
                },
              ),
            ),
          ListTile(
            leading: const Icon(Icons.person_add_alt),
            title: Text(S.addProfile),
            onTap: edit,
          ),
          _Header(S.measuringSection),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: Text(S.doneSound),
            subtitle: Text(S.doneSoundHint),
            value: settings.soundOn,
            onChanged: ref.read(settingsProvider.notifier).setSoundOn,
          ),
          _Header(S.dataSection),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: Text(S.exportJson),
            subtitle: Text(S.exportJsonHint),
            onTap: () => _export(context, ref, 'json'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(S.importJson),
            subtitle: Text(S.importJsonHint),
            onTap: () => _import(context, ref),
            trailing: IconButton(
              tooltip: S.fmtTitle,
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showFormat(context),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: Text(S.exportCsv),
            subtitle: Text(S.exportCsvHint),
            onTap: () => _export(context, ref, 'csv'),
          ),
          _Header(S.deleteSection),
          ListTile(
            leading: const Icon(Icons.person_remove_outlined),
            title: Text(S.deleteUserData),
            subtitle: Text(S.deleteUserDataHint),
            onTap: () => _deleteUserData(context, ref, profiles),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              S.deleteAllData,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: Text(S.deleteAllDataHint),
            onTap: () => _deleteAllData(context, ref),
          ),
          _Header(S.appearanceSection),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_outlined),
                  label: Text(S.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: Text(S.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: Text(S.themeDark),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) =>
                  ref.read(settingsProvider.notifier).setThemeMode(s.single),
            ),
          ),
          _Header(S.languageSection),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S.languageName),
            subtitle: settings.language == null
                ? Text(S.languageFollowsPhone)
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickLanguage(context, ref, settings.language),
          ),
          _Header(S.aboutSection),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(AppConfig.appName),
            subtitle: Text('${S.version} ${AppConfig.appVersion}'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(S.helpTitle),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const HelpScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.person_search_outlined),
            title: Text(S.whyTitle),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const WhyScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(S.privacy),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(S.privacy),
                content: Text(S.privacyBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(S.ok),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Scans for scales and pops with the chosen device id.
class _ScaleSearchDialog extends StatefulWidget {
  const _ScaleSearchDialog({required this.savedIds});

  final Set<String> savedIds;

  @override
  State<_ScaleSearchDialog> createState() => _ScaleSearchDialogState();
}

class _ScaleSearchDialogState extends State<_ScaleSearchDialog> {
  final _found = <DiscoveredDevice>[];
  StreamSubscription<DiscoveredDevice>? _sub;
  bool _scanning = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (!await ensureBlePermissions()) {
      return _fail(S.scaleError(ScaleError.permissionDenied));
    }
    if (!await ensureBluetoothOn()) {
      return _fail(S.scaleError(ScaleError.bluetoothOff));
    }
    if (!mounted) return;
    _sub = scanForScales().listen(
      (r) => setState(() => _found.add(r)),
      onError: (Object e) => _fail('$e'),
      onDone: () {
        if (mounted) setState(() => _scanning = false);
      },
    );
  }

  void _fail(String message) {
    if (mounted) {
      setState(() {
        _error = message;
        _scanning = false;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.scaleFind),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Text(_error!)
          else if (_scanning) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Text(S.scaleSearching),
          ] else if (_found.isEmpty)
            Text(S.scaleNoneFound),
          for (final r in _found)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.monitor_weight_outlined),
              title: Text(AppConfig.scaleName),
              subtitle: Text(
                widget.savedIds.contains(r.id)
                    ? '${r.id} · ${S.scaleAlreadySaved}'
                    : '${r.id} · ${r.rssi} dBm',
              ),
              onTap: () => Navigator.pop(context, r.id),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.cancel),
        ),
      ],
    );
  }
}

/// Asks to confirm a destructive action. With [requireAcknowledge] the delete
/// button stays disabled until the user ticks "I understand".
Future<bool> _confirmDelete(
  BuildContext context,
  String question, {
  bool requireAcknowledge = false,
}) async {
  var acknowledged = !requireAcknowledge;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final error = Theme.of(context).colorScheme.error;
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: error),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question),
              const SizedBox(height: 12),
              Text(S.deleteIrreversible),
              if (requireAcknowledge)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: acknowledged,
                  onChanged: (v) => setState(() => acknowledged = v ?? false),
                  title: Text(S.deleteUnderstand),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(S.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: error),
              onPressed: acknowledged
                  ? () => Navigator.pop(context, true)
                  : null,
              child: Text(S.delete),
            ),
          ],
        );
      },
    ),
  );
  return ok ?? false;
}

/// Picks the user whose data to delete; pops with (user, alsoDeleteUser).
class _DeleteUserDialog extends StatefulWidget {
  const _DeleteUserDialog({required this.profiles});

  final List<Profile> profiles;

  @override
  State<_DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<_DeleteUserDialog> {
  late Profile _profile = widget.profiles.first;
  bool _alsoProfile = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.deleteUserData),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioGroup<int>(
            groupValue: _profile.id,
            onChanged: (id) => setState(
              () => _profile = widget.profiles.firstWhere((p) => p.id == id),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final p in widget.profiles)
                  RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    value: p.id!,
                    title: Text(p.name),
                  ),
              ],
            ),
          ),
          const Divider(),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _alsoProfile,
            onChanged: (v) => setState(() => _alsoProfile = v ?? false),
            title: Text(S.deleteAlsoProfile),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, (_profile, _alsoProfile)),
          child: Text(S.deleteContinue),
        ),
      ],
    );
  }
}
