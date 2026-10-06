import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Local store: profiles, measurements and key/value settings.
class AppDb {
  AppDb._(this._db);

  final Database _db;

  static const _schema = [
    '''CREATE TABLE profiles(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      gender TEXT NOT NULL,
      height_cm INTEGER NOT NULL,
      birthday TEXT NOT NULL,
      ref_weight_kg REAL,
      created_at TEXT NOT NULL)''',
    '''CREATE TABLE measurements(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      profile_id INTEGER NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
      timestamp_utc TEXT NOT NULL,
      weight_kg REAL NOT NULL,
      r50 INTEGER NOT NULL,
      r500 INTEGER NOT NULL,
      bmi REAL, fat_pct REAL, lean_mass_kg REAL, subcut_fat_pct REAL,
      visceral REAL, water_pct REAL, bmr INTEGER, skel_muscle_pct REAL,
      muscle_mass_kg REAL, bone_mass_kg REAL, protein_pct REAL,
      body_score REAL, body_age INTEGER, body_shape INTEGER,
      source TEXT NOT NULL)''',
    'CREATE INDEX measurements_profile_time '
        'ON measurements(profile_id, timestamp_utc)',
    'CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT)',
  ];

  static Future<AppDb> open(String path, {DatabaseFactory? factory}) async {
    final db = await (factory ?? databaseFactory).openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) async {
          for (final sql in _schema) {
            await db.execute(sql);
          }
        },
      ),
    );
    return AppDb._(db);
  }

  Future<void> close() => _db.close();

  // ---- profiles ----

  Future<List<Profile>> profiles() async {
    final rows = await _db.query('profiles', orderBy: 'id');
    return rows.map(Profile.fromMap).toList();
  }

  /// Inserts or updates; returns the profile id.
  Future<int> saveProfile(Profile p) async {
    if (p.id == null) return _db.insert('profiles', p.toMap());
    await _db.update('profiles', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
    return p.id!;
  }

  /// Deletes the profile and (by cascade) all of its measurements.
  Future<void> deleteProfile(int id) =>
      _db.delete('profiles', where: 'id = ?', whereArgs: [id]);

  // ---- measurements ----

  /// Newest first.
  Future<List<Measurement>> measurements(int profileId) async {
    final rows = await _db.query(
      'measurements',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'timestamp_utc DESC, id DESC',
    );
    return rows.map(Measurement.fromMap).toList();
  }

  Future<List<Measurement>> allMeasurements() async {
    final rows = await _db.query('measurements', orderBy: 'timestamp_utc, id');
    return rows.map(Measurement.fromMap).toList();
  }

  Future<int> insertMeasurement(Measurement m) =>
      _db.insert('measurements', m.toMap());

  Future<void> updateMeasurement(Measurement m) =>
      _db.update('measurements', m.toMap(), where: 'id = ?', whereArgs: [m.id]);

  Future<void> deleteMeasurement(int id) =>
      _db.delete('measurements', where: 'id = ?', whereArgs: [id]);

  /// True if the same raw reading (any profile) is already stored.
  Future<bool> hasReading(
    DateTime timestampUtc,
    double weightKg,
    int r50,
  ) async {
    final rows = await _db.query(
      'measurements',
      columns: ['id'],
      where: 'timestamp_utc = ? AND weight_kg = ? AND r50 = ?',
      whereArgs: [timestampUtc.toUtc().toIso8601String(), weightKg, r50],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Deletes all measurements of one profile; returns how many.
  Future<int> deleteMeasurementsOf(int profileId) => _db.delete(
    'measurements',
    where: 'profile_id = ?',
    whereArgs: [profileId],
  );

  Future<int> countMeasurements(int profileId) async {
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) AS n FROM measurements WHERE profile_id = ?',
      [profileId],
    );
    return rows.first['n'] as int;
  }

  /// Deletes everything: profiles, measurements and settings.
  Future<void> wipe() => _db.transaction((t) async {
    await t.delete('measurements');
    await t.delete('profiles');
    await t.delete('settings');
  });

  /// Merges a backup made by `exportJson` or by hand (docs/BACKUP_FORMAT.md).
  /// A profile with the same name, sex, height and date of birth as an
  /// existing one is reused; measurements already present for that profile
  /// (same time, weight and impedance) are skipped. Body-composition values
  /// in the file are kept as they are, even without impedance (e.g. computed
  /// by another app); missing ones are computed for the profile like for a
  /// new measurement (just BMI when there is no impedance).
  /// Returns (new profiles, new measurements).
  ///
  /// Throws [FormatException] if [backup] is not such a backup; nothing is
  /// written in that case.
  Future<(int, int)> importBackup(Object? backup) async {
    final List<Profile> profiles;
    final List<Measurement> measurements;
    try {
      final json = backup! as Map<String, Object?>;
      profiles = [
        for (final p in json['profiles']! as List)
          Profile.fromMap(p as Map<String, Object?>),
      ];
      measurements = [
        for (final m in json['measurements'] as List? ?? const [])
          Measurement.fromMap(m as Map<String, Object?>),
      ];
    } catch (e) {
      throw FormatException('Not a backup: $e');
    }

    return _db.transaction((t) async {
      var newProfiles = 0, newMeasurements = 0;
      // Profile id in the file -> the stored profile.
      final byFileId = <int?, Profile>{};
      for (final p in profiles) {
        final m = p.toMap()..remove('id');
        final existing = await t.query(
          'profiles',
          columns: ['id'],
          where: 'name = ? AND gender = ? AND height_cm = ? AND birthday = ?',
          whereArgs: [m['name'], m['gender'], m['height_cm'], m['birthday']],
          limit: 1,
        );
        final int id;
        if (existing.isNotEmpty) {
          id = existing.first['id']! as int;
        } else {
          id = await t.insert('profiles', m);
          newProfiles++;
        }
        byFileId[p.id] = Profile.fromMap({...m, 'id': id});
      }
      for (final x in measurements) {
        final profile = byFileId[x.profileId];
        if (profile == null) continue;
        final profileId = profile.id!;
        // Values in the file win; whatever is missing is computed for the
        // profile, as for a new measurement.
        final given = x.toMap();
        final computed = Measurement.compute(
          profile: profile,
          timestampUtc: x.timestampUtc,
          weightKg: x.weightKg,
          r50: x.r50,
          r500: x.r500,
          source: x.source,
        ).toMap();
        final m = {for (final k in computed.keys) k: given[k] ?? computed[k]}
          ..remove('id')
          ..['profile_id'] = profileId;
        final dup = await t.query(
          'measurements',
          columns: ['id'],
          where:
              'profile_id = ? AND timestamp_utc = ? AND weight_kg = ? '
              'AND r50 = ? AND r500 = ?',
          whereArgs: [
            profileId,
            m['timestamp_utc'],
            m['weight_kg'],
            m['r50'],
            m['r500'],
          ],
          limit: 1,
        );
        if (dup.isNotEmpty) continue;
        await t.insert('measurements', m);
        newMeasurements++;
      }
      return (newProfiles, newMeasurements);
    });
  }

  // ---- settings ----

  Future<Map<String, String>> settings() async {
    final rows = await _db.query('settings');
    return {
      for (final r in rows)
        if (r['value'] != null) r['key'] as String: r['value'] as String,
    };
  }

  Future<void> setSetting(String key, String? value) async {
    if (value == null) {
      await _db.delete('settings', where: 'key = ?', whereArgs: [key]);
    } else {
      await _db.insert('settings', {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
