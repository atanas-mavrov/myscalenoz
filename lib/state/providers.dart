import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ble/scale_service.dart';
import '../data/db.dart';
import '../data/models.dart';
import '../l10n/strings.dart';

/// Overridden in main() with the opened database.
final dbProvider = Provider<AppDb>((_) => throw UnimplementedError());

/// Overridden in main() with the settings loaded at startup.
final initialSettingsProvider = Provider<Map<String, String>>((_) => const {});

/// A scale the user saved, with a name of their choosing.
class SavedScale {
  const SavedScale({required this.id, required this.name});

  /// BLE address.
  final String id;
  final String name;

  Map<String, Object?> toJson() => {'id': id, 'name': name};

  factory SavedScale.fromJson(Map<String, Object?> j) =>
      SavedScale(id: j['id'] as String, name: j['name'] as String);
}

class AppSettings {
  const AppSettings({
    this.activeProfileId,
    this.scales = const [],
    this.soundOn = true,
    this.themeMode = ThemeMode.system,
    this.language,
  });
  final int? activeProfileId;

  /// When non-empty, only these scales are connected to.
  final List<SavedScale> scales;

  /// Chime when the measurement is complete and the user may step off.
  final bool soundOn;

  /// Follows the phone by default; light or dark on request.
  final ThemeMode themeMode;

  /// Language code chosen in the settings; null = follow the phone.
  final String? language;

  static const _keep = Object();

  AppSettings copyWith({
    int? activeProfileId,
    List<SavedScale>? scales,
    bool? soundOn,
    ThemeMode? themeMode,
    Object? language = _keep,
  }) => AppSettings(
    activeProfileId: activeProfileId ?? this.activeProfileId,
    scales: scales ?? this.scales,
    soundOn: soundOn ?? this.soundOn,
    themeMode: themeMode ?? this.themeMode,
    language: identical(language, _keep) ? this.language : language as String?,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _kActive = 'activeProfileId', _kScales = 'scales';
  static const _kSound = 'sound', _kTheme = 'theme', _kLanguage = 'language';

  @override
  AppSettings build() {
    final m = ref.watch(initialSettingsProvider);
    return AppSettings(
      activeProfileId: int.tryParse(m[_kActive] ?? ''),
      scales: [
        for (final j in jsonDecode(m[_kScales] ?? '[]') as List)
          SavedScale.fromJson(j as Map<String, Object?>),
      ],
      soundOn: m[_kSound] != 'off',
      themeMode: ThemeMode.values.asNameMap()[m[_kTheme]] ?? ThemeMode.system,
      language: languages.containsKey(m[_kLanguage]) ? m[_kLanguage] : null,
    );
  }

  Future<void> setActiveProfile(int? id) async {
    state = AppSettings(
      activeProfileId: id,
      scales: state.scales,
      soundOn: state.soundOn,
      themeMode: state.themeMode,
      language: state.language,
    );
    await ref.read(dbProvider).setSetting(_kActive, id?.toString());
  }

  /// Adds [scale], or renames the saved scale with the same id.
  Future<void> saveScale(SavedScale scale) => _setScales([
    for (final s in state.scales)
      if (s.id != scale.id) s,
    scale,
  ]);

  Future<void> removeScale(String id) =>
      _setScales(state.scales.where((s) => s.id != id).toList());

  /// Back to defaults after all data was deleted (the DB is already empty).
  void reset() => state = const AppSettings();

  /// [code] null = follow the phone's language.
  Future<void> setLanguage(String? code) async {
    state = state.copyWith(language: code);
    await ref.read(dbProvider).setSetting(_kLanguage, code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(dbProvider).setSetting(_kTheme, mode.name);
  }

  Future<void> setSoundOn(bool on) async {
    state = state.copyWith(soundOn: on);
    await ref.read(dbProvider).setSetting(_kSound, on ? 'on' : 'off');
  }

  Future<void> _setScales(List<SavedScale> scales) async {
    state = state.copyWith(scales: scales);
    await ref.read(dbProvider).setSetting(_kScales, jsonEncode(scales));
  }
}

/// Plays the "measurement complete, step off" chime. Overridable for tests.
final doneChimeProvider = Provider<void Function()>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  // A short notification-style cue: follows the notification volume and
  // silent mode, and lowers rather than stops other audio.
  player.setAudioContext(
    AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.notification,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
    ),
  );
  return () => player.play(AssetSource('sounds/done.wav')).ignore();
});

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

final profilesProvider = FutureProvider<List<Profile>>(
  (ref) => ref.watch(dbProvider).profiles(),
);

/// The profile the next measurement is attributed to (first one by default).
final activeProfileProvider = Provider<Profile?>((ref) {
  final profiles = ref.watch(profilesProvider).value ?? const [];
  if (profiles.isEmpty) return null;
  final id = ref.watch(settingsProvider).activeProfileId;
  return profiles.firstWhere((p) => p.id == id, orElse: () => profiles.first);
});

/// Measurements of one profile, newest first.
final measurementsProvider = FutureProvider.family<List<Measurement>, int>(
  (ref, profileId) => ref.watch(dbProvider).measurements(profileId),
);

/// Write operations; each refreshes the providers it affects.
class Repo {
  Repo(this._ref);
  final Ref _ref;

  AppDb get _db => _ref.read(dbProvider);

  Future<int> saveProfile(Profile p) async {
    final id = await _db.saveProfile(p);
    _ref.invalidate(profilesProvider);
    return id;
  }

  Future<void> deleteProfile(int id) async {
    await _db.deleteProfile(id);
    _ref.invalidate(profilesProvider);
    _ref.invalidate(measurementsProvider);
  }

  Future<void> deleteMeasurement(int id) async {
    await _db.deleteMeasurement(id);
    _ref.invalidate(measurementsProvider);
  }

  /// Deletes a profile's measurements and, if [alsoProfile], the profile.
  Future<void> deleteUserData(
    int profileId, {
    required bool alsoProfile,
  }) async {
    if (alsoProfile) {
      await _db.deleteProfile(profileId); // cascades to the measurements
      _ref.invalidate(profilesProvider);
    } else {
      await _db.deleteMeasurementsOf(profileId);
    }
    _ref.invalidate(measurementsProvider);
  }

  /// Deletes all profiles, measurements and settings.
  Future<void> deleteAllData() async {
    await _db.wipe();
    _ref.read(settingsProvider.notifier).reset();
    _ref.invalidate(profilesProvider);
    _ref.invalidate(measurementsProvider);
  }

  /// See [AppDb.importBackup].
  Future<(int, int)> importBackup(Object? backup) async {
    final result = await _db.importBackup(backup);
    _ref.invalidate(profilesProvider);
    _ref.invalidate(measurementsProvider);
    return result;
  }

  /// Moves [m] to [to], recomputing the composition for that person.
  Future<Measurement> reassign(Measurement m, Profile to) async {
    final moved = Measurement.compute(
      id: m.id,
      profile: to,
      timestampUtc: m.timestampUtc,
      weightKg: m.weightKg,
      r50: m.r50,
      r500: m.r500,
      source: m.source,
    );
    await _db.updateMeasurement(moved);
    _ref.invalidate(measurementsProvider);
    return moved;
  }

  /// Stores scale readings for [profile]. Live readings are stamped with the
  /// phone's clock; synced ones keep the scale's timestamp when it is sane and
  /// are skipped if already stored.
  Future<List<Measurement>> saveReadings(
    Profile profile,
    List<RawReading> readings, {
    required bool live,
  }) async {
    final now = DateTime.now().toUtc();
    final saved = <Measurement>[];
    for (final r in readings) {
      if (r.weightKg <= 0) continue;
      final st = r.scaleTime;
      final useScaleTime =
          !live && st != null && st.isBefore(now.add(const Duration(days: 1)));
      final ts = useScaleTime ? st : now;
      if (useScaleTime && await _db.hasReading(ts, r.weightKg, r.r50)) {
        continue;
      }
      final m = Measurement.compute(
        profile: profile,
        timestampUtc: ts,
        weightKg: r.weightKg,
        r50: r.r50,
        r500: r.r500,
      );
      final id = await _db.insertMeasurement(m);
      saved.add(Measurement.fromMap({...m.toMap(), 'id': id}));
    }
    if (saved.isNotEmpty) _ref.invalidate(measurementsProvider);
    return saved;
  }

  /// If [m]'s weight is far from what [owner] usually weighs but close to
  /// another profile's usual weight, returns that other profile.
  Future<Profile?> likelyOtherOwner(Measurement m, Profile owner) async {
    const far = 5.0, near = 2.5;
    Future<double?> usual(Profile p) async {
      final others = (await _db.measurements(p.id!)).where((x) => x.id != m.id);
      return others.isEmpty ? p.refWeightKg : others.first.weightKg;
    }

    final own = await usual(owner);
    if (own == null || (m.weightKg - own).abs() <= far) return null;
    for (final p in await _db.profiles()) {
      if (p.id == owner.id) continue;
      final w = await usual(p);
      if (w != null && (m.weightKg - w).abs() <= near) return p;
    }
    return null;
  }
}

final repoProvider = Provider<Repo>(Repo.new);

class MeasureState {
  const MeasureState({
    this.running = false,
    this.sync = false,
    this.status,
    this.saved,
    this.likelyOther,
  });

  final bool running;
  final bool sync;
  final ScaleStatus? status;

  /// Set when the session finished successfully.
  final List<Measurement>? saved;

  /// See [Repo.likelyOtherOwner].
  final Profile? likelyOther;
}

/// Drives one scale session at a time and stores its results.
class MeasureController extends Notifier<MeasureState> {
  ScaleSession? _session;

  @override
  MeasureState build() => const MeasureState();

  Future<void>? _current;

  /// Starts a new session, first stopping one that is still winding down.
  Future<void> start({required bool sync}) async {
    await _session?.cancel();
    await _current;
    await (_current = _run(sync));
  }

  Future<void> _run(bool sync) async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) return;
    final session = ScaleSession(
      sync: sync,
      deviceIds: [for (final s in ref.read(settingsProvider).scales) s.id],
      onReading: () {
        if (ref.read(settingsProvider).soundOn) ref.read(doneChimeProvider)();
      },
    );
    _session = session;
    state = MeasureState(
      running: true,
      sync: sync,
      status: const ScaleStatus(ScalePhase.preparing),
    );
    final sub = session.status.listen((s) {
      if (_session != session) return;
      state = MeasureState(running: true, sync: sync, status: s);
    });
    try {
      final readings = await session.run();
      final repo = ref.read(repoProvider);
      final saved = await repo.saveReadings(profile, readings, live: !sync);
      final other = !sync && saved.length == 1
          ? await repo.likelyOtherOwner(saved.single, profile)
          : null;
      state = MeasureState(
        sync: sync,
        status: const ScaleStatus(ScalePhase.done),
        saved: saved,
        likelyOther: other,
      );
    } on ScaleException catch (e) {
      state = MeasureState(
        sync: sync,
        status: ScaleStatus(ScalePhase.failed, error: e.error),
      );
    } finally {
      await sub.cancel();
      if (_session == session) _session = null;
    }
  }

  /// Replaces the just-saved measurement after it was reassigned.
  void resultReassigned(Measurement moved) {
    state = MeasureState(
      sync: state.sync,
      status: state.status,
      saved: [moved],
    );
  }

  Future<void> cancel() async => _session?.cancel();

  void reset() {
    if (!state.running) state = const MeasureState();
  }
}

final measureProvider = NotifierProvider<MeasureController, MeasureState>(
  MeasureController.new,
);
