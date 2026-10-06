import '../core/body_comp.dart';

enum Gender { male, female }

/// Full years between [birthday] and [at].
int ageAt(DateTime birthday, DateTime at) {
  var age = at.year - birthday.year;
  if (at.month < birthday.month ||
      (at.month == birthday.month && at.day < birthday.day)) {
    age--;
  }
  return age;
}

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

class Profile {
  const Profile({
    this.id,
    required this.name,
    required this.gender,
    required this.heightCm,
    required this.birthday,
    this.refWeightKg,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final Gender gender;
  final int heightCm;
  final DateTime birthday;
  final double? refWeightKg;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'gender': gender.name,
    'height_cm': heightCm,
    'birthday': _isoDate(birthday),
    'ref_weight_kg': refWeightKg,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  /// Also reads hand-made backups (see docs/BACKUP_FORMAT.md), so numbers
  /// may come as either int or double and `created_at` may be missing.
  factory Profile.fromMap(Map<String, Object?> m) => Profile(
    id: (m['id'] as num?)?.toInt(),
    name: m['name'] as String,
    gender: Gender.values.byName(m['gender'] as String),
    heightCm: (m['height_cm'] as num).toInt(),
    birthday: DateTime.parse(m['birthday'] as String),
    refWeightKg: (m['ref_weight_kg'] as num?)?.toDouble(),
    createdAt: m['created_at'] == null
        ? DateTime.now().toUtc()
        : DateTime.parse(m['created_at'] as String),
  );
}

class Measurement {
  const Measurement({
    this.id,
    required this.profileId,
    required this.timestampUtc,
    required this.weightKg,
    required this.r50,
    required this.r500,
    this.bmi,
    this.fatPct,
    this.leanMassKg,
    this.subcutFatPct,
    this.visceral,
    this.waterPct,
    this.bmr,
    this.skelMusclePct,
    this.muscleMassKg,
    this.boneMassKg,
    this.proteinPct,
    this.bodyScore,
    this.bodyAge,
    this.bodyShape,
    this.source = 'ble',
  });

  final int? id;
  final int profileId;
  final DateTime timestampUtc;
  final double weightKg;
  final int r50;
  final int r500;

  // Body composition; null when the scale reported no impedance (e.g. shoes).
  final double? bmi;
  final double? fatPct;
  final double? leanMassKg;
  final double? subcutFatPct;
  final double? visceral;
  final double? waterPct;
  final int? bmr;
  final double? skelMusclePct;
  final double? muscleMassKg;
  final double? boneMassKg;
  final double? proteinPct;
  final double? bodyScore;
  final int? bodyAge;
  final int? bodyShape;
  final String source;

  bool get hasComposition => fatPct != null;

  /// Computes body composition for [profile] from a raw scale reading.
  factory Measurement.compute({
    int? id,
    required Profile profile,
    required DateTime timestampUtc,
    required double weightKg,
    required int r50,
    required int r500,
    String source = 'ble',
  }) {
    final r = BodyComp.calc(
      heightCm: profile.heightCm.toDouble(),
      ageYears: ageAt(profile.birthday, timestampUtc.toLocal()),
      // The algorithm's convention: 1 = male, 0 = female.
      genderMale1Female0: profile.gender == Gender.male ? 1 : 0,
      weightKg: weightKg,
      r50: r50,
      r500: r500,
    );
    final hm = profile.heightCm / 100.0;
    return Measurement(
      id: id,
      profileId: profile.id!,
      timestampUtc: timestampUtc.toUtc(),
      weightKg: weightKg,
      r50: r50,
      r500: r500,
      // Weight-only readings still get a BMI.
      bmi: r?.bmi ?? (weightKg / (hm * hm) * 10).roundToDouble() / 10,
      fatPct: r?.fatPct,
      leanMassKg: r?.leanMassKg,
      subcutFatPct: r?.subcutFatPct,
      visceral: r?.visceral,
      waterPct: r?.waterPct,
      bmr: r?.bmr,
      skelMusclePct: r?.skelMusclePct,
      muscleMassKg: r?.muscleMassKg,
      boneMassKg: r?.boneMassKg,
      proteinPct: r?.proteinPct,
      bodyScore: r?.bodyScore,
      bodyAge: r?.bodyAge,
      bodyShape: r?.bodyShape,
      source: source,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'profile_id': profileId,
    'timestamp_utc': timestampUtc.toUtc().toIso8601String(),
    'weight_kg': weightKg,
    'r50': r50,
    'r500': r500,
    'bmi': bmi,
    'fat_pct': fatPct,
    'lean_mass_kg': leanMassKg,
    'subcut_fat_pct': subcutFatPct,
    'visceral': visceral,
    'water_pct': waterPct,
    'bmr': bmr,
    'skel_muscle_pct': skelMusclePct,
    'muscle_mass_kg': muscleMassKg,
    'bone_mass_kg': boneMassKg,
    'protein_pct': proteinPct,
    'body_score': bodyScore,
    'body_age': bodyAge,
    'body_shape': bodyShape,
    'source': source,
  };

  /// Also reads hand-made backups (see docs/BACKUP_FORMAT.md): numbers may
  /// come as int or double; impedance, composition and source may be missing.
  factory Measurement.fromMap(Map<String, Object?> m) {
    double? d(String k) => (m[k] as num?)?.toDouble();
    int? i(String k) => (m[k] as num?)?.toInt();
    return Measurement(
      id: i('id'),
      profileId: i('profile_id')!,
      timestampUtc: DateTime.parse(m['timestamp_utc'] as String),
      weightKg: d('weight_kg')!,
      r50: i('r50') ?? 0,
      r500: i('r500') ?? 0,
      bmi: d('bmi'),
      fatPct: d('fat_pct'),
      leanMassKg: d('lean_mass_kg'),
      subcutFatPct: d('subcut_fat_pct'),
      visceral: d('visceral'),
      waterPct: d('water_pct'),
      bmr: i('bmr'),
      skelMusclePct: d('skel_muscle_pct'),
      muscleMassKg: d('muscle_mass_kg'),
      boneMassKg: d('bone_mass_kg'),
      proteinPct: d('protein_pct'),
      bodyScore: d('body_score'),
      bodyAge: i('body_age'),
      bodyShape: i('body_shape'),
      source: m['source'] as String? ?? 'import',
    );
  }
}
