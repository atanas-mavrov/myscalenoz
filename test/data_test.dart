import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myscalenoz/data/db.dart';
import 'package:myscalenoz/data/export.dart';
import 'package:myscalenoz/data/models.dart';
import 'package:myscalenoz/state/providers.dart';
import 'package:myscalenoz/ui/backup_format_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Profile _profile(String name, Gender gender, int heightCm) => Profile(
  name: name,
  gender: gender,
  heightCm: heightCm,
  birthday: DateTime(1978, 3, 15),
  createdAt: DateTime.utc(2026, 10, 1),
);

void main() {
  sqfliteFfiInit();
  late AppDb db;

  setUp(() async {
    db = await AppDb.open(inMemoryDatabasePath, factory: databaseFactoryFfi);
  });
  tearDown(() => db.close());

  Future<Profile> add(Profile p) async {
    final id = await db.saveProfile(p);
    return (await db.profiles()).firstWhere((x) => x.id == id);
  }

  test('ageAt counts full years', () {
    final b = DateTime(1978, 3, 15);
    expect(ageAt(b, DateTime(2026, 3, 14)), 47);
    expect(ageAt(b, DateTime(2026, 3, 15)), 48);
  });

  test(
    'compute maps the profile to the algorithm inputs (ground-truth row)',
    () async {
      // reference.csv row 1: male, 180 cm, 48 y, 78.6 kg, 467/427.
      final p = await add(_profile('A', Gender.male, 180));
      final m = Measurement.compute(
        profile: p,
        timestampUtc: DateTime.utc(2026, 10, 1, 12),
        weightKg: 78.6,
        r50: 467,
        r500: 427,
      );
      expect(m.fatPct, 21.1);
      expect(m.bmr, 1709);
      expect(m.bodyAge, 47);
      expect(m.bodyShape, 1);
    },
  );

  test('no impedance: weight and BMI only', () async {
    final p = await add(_profile('A', Gender.male, 180));
    final m = Measurement.compute(
      profile: p,
      timestampUtc: DateTime.utc(2026, 10, 1),
      weightKg: 78.6,
      r50: 0,
      r500: 0,
    );
    expect(m.hasComposition, isFalse);
    expect(m.bmi, 24.3);
  });

  test(
    'measurements round-trip, newest first; profile delete cascades',
    () async {
      final p = await add(_profile('A', Gender.female, 165));
      for (final day in [1, 3, 2]) {
        await db.insertMeasurement(
          Measurement.compute(
            profile: p,
            timestampUtc: DateTime.utc(2026, 9, day),
            weightKg: 60.0 + day,
            r50: 500,
            r500: 450,
          ),
        );
      }
      final list = await db.measurements(p.id!);
      expect(list.map((m) => m.weightKg), [63.0, 62.0, 61.0]);
      expect(list.first.visceral, isNotNull);
      expect(await db.hasReading(DateTime.utc(2026, 9, 3), 63.0, 500), isTrue);
      expect(await db.hasReading(DateTime.utc(2026, 9, 3), 63.5, 500), isFalse);

      await db.deleteProfile(p.id!);
      expect(await db.allMeasurements(), isEmpty);
    },
  );

  test('settings set / clear', () async {
    await db.setSetting('k', 'v');
    expect(await db.settings(), {'k': 'v'});
    await db.setSetting('k', null);
    expect(await db.settings(), isEmpty);
  });

  test('CSV export quotes names and has one row per measurement', () async {
    final p = await add(_profile('Иван, "Ванката"', Gender.male, 180));
    await db.insertMeasurement(
      Measurement.compute(
        profile: p,
        timestampUtc: DateTime.utc(2026, 10, 1, 12),
        weightKg: 78.6,
        r50: 467,
        r500: 427,
      ),
    );
    final lines = exportCsv(
      await db.profiles(),
      await db.allMeasurements(),
    ).split('\n');
    expect(lines, hasLength(2));
    expect(lines[0], startsWith('profile,timestampUtc,r50,r500,weightKg,bmi,'));
    expect(
      lines[1],
      startsWith(
        '"Иван, ""Ванката""",2026-10-01T12:00:00.000Z,467,427,78.6,24.3,21.1,',
      ),
    );
  });

  test('saved scales: add, rename, remove, and survive a restart', () async {
    ProviderContainer container(Map<String, String> initial) {
      final c = ProviderContainer(
        overrides: [
          dbProvider.overrideWithValue(db),
          initialSettingsProvider.overrideWithValue(initial),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    final settings = container(const {}).read(settingsProvider.notifier);
    await settings.saveScale(const SavedScale(id: 'AA:01', name: 'Баня'));
    await settings.saveScale(const SavedScale(id: 'AA:02', name: 'Вила'));
    await settings.saveScale(const SavedScale(id: 'AA:01', name: 'Спалня'));
    await settings.removeScale('AA:02');
    expect(container(const {}).read(settingsProvider).soundOn, isTrue);
    await settings.setSoundOn(false);
    expect(
      container(const {}).read(settingsProvider).themeMode,
      ThemeMode.system,
    );
    await settings.setThemeMode(ThemeMode.light);
    expect(container(const {}).read(settingsProvider).language, isNull);
    await settings.setLanguage('de');

    final reloaded = container(await db.settings()).read(settingsProvider);
    expect(reloaded.scales.map((s) => (s.id, s.name)), [('AA:01', 'Спалня')]);
    expect(reloaded.soundOn, isFalse);
    expect(reloaded.themeMode, ThemeMode.light);
    expect(reloaded.language, 'de');
  });

  Future<void> addMeasurements(Profile p, int n) async {
    for (var i = 0; i < n; i++) {
      await db.insertMeasurement(
        Measurement.compute(
          profile: p,
          timestampUtc: DateTime.utc(2026, 9, 1 + i),
          weightKg: 78.6,
          r50: 467,
          r500: 427,
        ),
      );
    }
  }

  test(
    'backup round trip: import into an empty app restores everything',
    () async {
      final a = await add(_profile('A', Gender.male, 180));
      final b = await add(_profile('B', Gender.female, 165));
      await addMeasurements(a, 3);
      await addMeasurements(b, 2);
      final backup = exportJson(
        await db.profiles(),
        await db.allMeasurements(),
      );

      await db.wipe();
      expect(await db.importBackup(jsonDecode(backup)), (2, 5));
      final profiles = await db.profiles();
      expect(profiles.map((p) => p.name), ['A', 'B']);
      final restoredB = profiles.firstWhere((p) => p.name == 'B');
      final measB = await db.measurements(restoredB.id!);
      expect(measB, hasLength(2));
      expect(measB.first.fatPct, isNotNull);

      // Importing the same backup again adds nothing.
      expect(await db.importBackup(jsonDecode(backup)), (0, 0));
    },
  );

  test('import rejects files that are not a backup, writing nothing', () async {
    for (final bad in [
      null,
      'x',
      <String, Object?>{},
      {'profiles': 'x'},
    ]) {
      await expectLater(db.importBackup(bad), throwsFormatException);
    }
    expect(await db.profiles(), isEmpty);
  });

  test('delete one user\'s measurements, or everything', () async {
    final a = await add(_profile('A', Gender.male, 180));
    final b = await add(_profile('B', Gender.female, 165));
    await addMeasurements(a, 3);
    await addMeasurements(b, 2);
    await db.setSetting('k', 'v');

    expect(await db.countMeasurements(a.id!), 3);
    expect(await db.deleteMeasurementsOf(a.id!), 3);
    expect(await db.countMeasurements(a.id!), 0);
    expect(await db.countMeasurements(b.id!), 2);
    expect(await db.profiles(), hasLength(2));

    await db.wipe();
    expect(await db.profiles(), isEmpty);
    expect(await db.allMeasurements(), isEmpty);
    expect(await db.settings(), isEmpty);
  });

  test(
    'the documented example imports; missing composition is computed',
    () async {
      expect(await db.importBackup(jsonDecode(backupExample)), (1, 2));
      final anna = (await db.profiles()).single;
      expect(anna.gender, Gender.female);
      final list = await db.measurements(anna.id!); // newest first
      expect(list.map((m) => m.weightKg), [63.8, 64.2]);
      expect(list.last.fatPct, isNotNull, reason: 'computed from impedance');
      expect(list.last.source, 'import');
      expect(list.first.hasComposition, isFalse, reason: 'weight only');
      expect(list.first.bmi, isNotNull);
    },
  );

  test(
    'values computed elsewhere, without impedance, are kept as they are',
    () async {
      final backup = {
        'profiles': [
          {
            'id': 7,
            'name': 'B',
            'gender': 'male',
            'height_cm': 180,
            'birthday': '1978-03-15',
          },
        ],
        'measurements': [
          {
            'profile_id': 7,
            'timestamp_utc': '2025-03-15T07:00:00Z',
            'weight_kg': 66.0,
            'fat_pct': 29.4,
            'water_pct': 51.2,
            'bmr': 1310,
          },
        ],
      };
      expect(await db.importBackup(backup), (1, 1));
      final m = (await db.allMeasurements()).single;
      expect((m.fatPct, m.waterPct, m.bmr), (29.4, 51.2, 1310));
      expect(m.r50, 0);
      expect(m.bmi, 20.4, reason: 'missing BMI is still computed');
      expect(m.muscleMassKg, isNull, reason: 'needs impedance');
    },
  );
}
