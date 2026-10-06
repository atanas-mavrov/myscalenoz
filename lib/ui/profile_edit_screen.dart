import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../l10n/strings.dart';
import '../state/providers.dart';
import 'common.dart';
import 'help_screen.dart';

/// Creates a profile, or edits [profile] when given. With [onboarding] it is
/// the first-start screen: it is not a pushed route and the new profile
/// replaces it.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, this.profile, this.onboarding = false});

  final Profile? profile;
  final bool onboarding;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile?.name);
  late final _height = TextEditingController(
    text: widget.profile?.heightCm.toString(),
  );
  late final _refWeight = TextEditingController(
    text: widget.profile?.refWeightKg?.toString(),
  );
  late Gender _gender = widget.profile?.gender ?? Gender.male;
  late DateTime? _birthday = widget.profile?.birthday;
  bool _birthdayMissing = false;

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _refWeight.dispose();
    super.dispose();
  }

  static double? _parseDecimal(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
        _birthdayMissing = false;
      });
    }
  }

  Future<void> _save() async {
    final valid = _form.currentState!.validate();
    setState(() => _birthdayMissing = _birthday == null);
    if (!valid || _birthday == null) return;
    final old = widget.profile;
    final id = await ref
        .read(repoProvider)
        .saveProfile(
          Profile(
            id: old?.id,
            name: _name.text.trim(),
            gender: _gender,
            heightCm: int.parse(_height.text.trim()),
            birthday: _birthday!,
            refWeightKg: _parseDecimal(_refWeight.text),
            createdAt: old?.createdAt ?? DateTime.now().toUtc(),
          ),
        );
    if (old == null) {
      await ref.read(settingsProvider.notifier).setActiveProfile(id);
    }
    if (mounted && !widget.onboarding) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final birthday = _birthday;
    final onboarding = widget.onboarding;
    void showWhy() =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => const WhyScreen()));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !onboarding,
        title: Text(
          onboarding
              ? S.obTitle
              : widget.profile == null
              ? S.newProfile
              : S.editProfile,
        ),
        actions: [
          IconButton(
            tooltip: S.whyTitle,
            icon: const Icon(Icons.help_outline),
            onPressed: showWhy,
          ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (onboarding) ...[
              Text(S.obBody, style: theme.textTheme.bodyLarge),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: showWhy,
                  icon: const Icon(Icons.info_outline),
                  label: Text(S.whyTitle),
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: S.name),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v ?? '').trim().isEmpty ? S.errName : null,
            ),
            const SizedBox(height: 16),
            SegmentedButton<Gender>(
              segments: [
                ButtonSegment(value: Gender.male, label: Text(S.male)),
                ButtonSegment(value: Gender.female, label: Text(S.female)),
              ],
              selected: {_gender},
              onSelectionChanged: (s) => setState(() => _gender = s.single),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _height,
              decoration: InputDecoration(labelText: S.heightCm),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final cm = int.tryParse((v ?? '').trim());
                return cm == null || cm < 100 || cm > 250 ? S.errHeight : null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(S.birthday),
              subtitle: Text(
                _birthdayMissing
                    ? S.errBirthday
                    : birthday == null
                    ? S.pickDate
                    : formatDate(birthday),
                style: _birthdayMissing
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickBirthday,
            ),
            TextFormField(
              controller: _refWeight,
              decoration: InputDecoration(labelText: S.refWeight),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty || _parseDecimal(v!) != null
                  ? null
                  : S.errNumber,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(onboarding ? S.obStart : S.save),
            ),
          ],
        ),
      ),
    );
  }
}
