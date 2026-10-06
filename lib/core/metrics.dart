import '../data/models.dart';
import '../l10n/strings.dart';

/// A displayable / chartable value of a [Measurement].
class Metric {
  const Metric(
    this.key,
    this.label,
    this.unit,
    this.decimals,
    this.value, {
    required this.help,
  });

  /// Stable id; also the CSV column name.
  final String key;
  final String label;
  final String unit;
  final int decimals;
  final num? Function(Measurement m) value;

  /// Plain-language explanation shown to the user.
  final String help;

  /// e.g. "78.6 kg", or "—" when the measurement lacks this value.
  String format(Measurement m, {bool withUnit = true}) {
    final v = value(m);
    if (v == null) return '—';
    final s = v.toStringAsFixed(decimals);
    return withUnit && unit.isNotEmpty ? '$s $unit' : s;
  }
}

/// Built on each access so that labels follow the current language.
abstract final class Metrics {
  static Metric get weight => Metric(
    'weightKg',
    S.mWeight,
    'kg',
    2,
    (m) => m.weightKg,
    help: S.hWeight,
  );
  static Metric get fat =>
      Metric('fatPct', S.mFat, '%', 1, (m) => m.fatPct, help: S.hFat);
  static Metric get skelMuscle => Metric(
    'skelMusclePct',
    S.mSkelMuscle,
    '%',
    1,
    (m) => m.skelMusclePct,
    help: S.hSkelMuscle,
  );

  /// In display order.
  static List<Metric> get all => <Metric>[
    weight,
    Metric('bmi', S.mBmi, '', 1, (m) => m.bmi, help: S.hBmi),
    fat,
    skelMuscle,
    Metric(
      'muscleMassKg',
      S.mMuscleMass,
      'kg',
      1,
      (m) => m.muscleMassKg,
      help: S.hMuscleMass,
    ),
    Metric('waterPct', S.mWater, '%', 1, (m) => m.waterPct, help: S.hWater),
    Metric(
      'proteinPct',
      S.mProtein,
      '%',
      1,
      (m) => m.proteinPct,
      help: S.hProtein,
    ),
    Metric('boneMassKg', S.mBone, 'kg', 2, (m) => m.boneMassKg, help: S.hBone),
    Metric(
      'leanMassKg',
      S.mLeanMass,
      'kg',
      1,
      (m) => m.leanMassKg,
      help: S.hLeanMass,
    ),
    Metric(
      'subcutFatPct',
      S.mSubcutFat,
      '%',
      1,
      (m) => m.subcutFatPct,
      help: S.hSubcutFat,
    ),
    Metric(
      'visceral',
      S.mVisceral,
      '',
      1,
      (m) => m.visceral,
      help: S.hVisceral,
    ),
    Metric('bmr', S.mBmr, 'kcal', 0, (m) => m.bmr, help: S.hBmr),
    Metric(
      'bodyScore',
      S.mBodyScore,
      '/ 100',
      1,
      (m) => m.bodyScore,
      help: S.hBodyScore,
    ),
    Metric(
      'bodyAge',
      S.mBodyAge,
      S.years,
      0,
      (m) => m.bodyAge,
      help: S.hBodyAge,
    ),
  ];
}
