/// On-device body-composition calculator — a 1:1 Dart port of
/// `reference/BodyComp.java`, itself a port of the original Qingniu native
/// routine `algorithm()` from libyolanda_calc.so.
///
/// gender: 1 = male, 0 = female (native convention — the OPPOSITE of the BLE
/// wire convention).
///
/// CRITICAL ordering (verified): fat is computed raw, then STORED rounded; most
/// downstream fields re-read the rounded values (fatR, wr, lbmR). The two
/// exceptions — water and protein — use the UNROUNDED clamped water value.
///
/// Do not "simplify" any expression here: operation order affects the last bit
/// and `test/body_comp_test.dart` checks the output bit-for-bit.
library;

import 'dart:math' as math;

/// Parsed body-composition result (the 14 computed fields + rounded weight).
class BodyCompResult {
  const BodyCompResult({
    required this.weightKg,
    required this.bmi,
    required this.fatPct,
    required this.leanMassKg,
    required this.subcutFatPct,
    required this.visceral,
    required this.waterPct,
    required this.bmr,
    required this.skelMusclePct,
    required this.muscleMassKg,
    required this.boneMassKg,
    required this.proteinPct,
    required this.bodyScore,
    required this.bodyAge,
    required this.bodyShape,
  });

  final double weightKg;
  final double bmi;
  final double fatPct;
  final double leanMassKg;
  final double subcutFatPct;

  /// Stored RAW (not rounded), as the native lib does.
  final double visceral;
  final double waterPct;
  final int bmr;
  final double skelMusclePct;
  final double muscleMassKg;
  final double boneMassKg;
  final double proteinPct;
  final double bodyScore;
  final int bodyAge;

  /// 1..9
  final int bodyShape;
}

abstract final class BodyComp {
  /// round to 1 decimal, half-up (matches the lib's floor(x*10+0.5)/10).
  static double _r1(double x) => (x * 10 + 0.5).floorToDouble() / 10.0;

  /// round to 2 decimals, half-up.
  static double _r2(double x) => (x * 100 + 0.5).floorToDouble() / 100.0;

  static double _clamp(double x, double a, double b) =>
      math.max(a, math.min(b, x));

  /// Body fat % — dual-frequency, per gender; clamped to [5.1, 75].
  static double _fat(int g, double h, int age, double w, int rA, int rB) {
    double res;
    if (g != 0) {
      final fA = 37.088 - 0.528 * h + 0.067 * age + 0.05 * rA + 0.668 * w;
      final fB =
          64.22 - 0.58 * h - 0.01 * age - 0.12 * rA + 0.19 * rB + 0.51 * w;
      final d = (fA - fB > 5) ? fA - 5 : fB;
      res = (rB != 0) ? math.min(fA, d) : fA;
    } else {
      final fA = 55.478 - 0.623 * h + 0.058 * age + 0.042 * rA + 0.831 * w;
      final fB =
          36.23 - 0.37 * h + 0.19 * age + 0.05 * rA - 0.02 * rB + 0.53 * w;
      res = (rB != 0) ? math.min(fA, fB) : fA;
    }
    return _clamp(res, 5.1, 75.0);
  }

  static double _bmiScore(double b) {
    if (b == 22) return 100.0;
    if (b > 22) {
      return (b < 35) ? 100 + (22 - b).abs() * (-3.8461538461538463) : 50.0;
    }
    if (b > 15) return 100 + (22 - b).abs() * (-3.8461538461538463);
    if (b >= 10) return 40.0;
    if (b >= 5) return 30.0;
    if (b >= 0) return 20.0;
    return 0.0;
  }

  static double _fatScore(double fat, int g) {
    final std = (g != 0) ? 16.0 : 26.0;
    if (fat == std) return 100.0;
    if (fat > std) {
      return (fat <= 45)
          ? 100 + (std - fat).abs() * (-50.0 / (std - 45).abs())
          : 50.0;
    }
    if (fat <= 5) return (fat > 0) ? 10.0 : 0.0;
    return 100 + (std - fat).abs() * (-50.0 / (std - 5).abs());
  }

  static double _weightScore(double w, double h, int g) {
    final std = (g != 0) ? (h - 80) * 0.7 : (1.37 * h - 110) * 0.45;
    if (std == w) return 100.0;
    if (std < w) {
      return (1.3 * std >= w)
          ? 100 + (std - w).abs() * (-50.0 / (std - 1.3 * std).abs())
          : 50.0;
    }
    if (0.7 * std >= w) {
      if (0.6 * std >= w) {
        if (0.5 * std >= w) {
          if (0.4 * std >= w) {
            if (0.3 * std >= w) return (w == 0) ? 0.0 : 10.0;
            return 20.0;
          }
          return 30.0;
        }
        return 40.0;
      }
      return 50.0;
    }
    return 100 + (std - w).abs() * (-50.0 / (std - 0.7 * std).abs());
  }

  static const List<double> _ageTbl = [
    50, 60, 65, 67.5, 70, 72.5, 75, 80, 85, 87.5, 90, 92.5, 95, 96.5, 98, 99, //
    101,
  ];

  static int _bodyAge(int age, double raw) {
    var r = -8, cnt = 0;
    for (final t in _ageTbl) {
      if (t > raw) break;
      r++;
      cnt++;
    }
    final ba = (cnt == _ageTbl.length) ? age : age - r;
    return (ba <= 18) ? 18 : ba;
  }

  static int _bodyShape(double bmi, double fat, int g) {
    final std = (g != 0) ? 16.0 : 26.0;
    final bb = (bmi < 18.5) ? 0 : (bmi < 25 ? 1 : 2);
    if (bb == 0) {
      if (fat < std - 5) return 3;
      if (fat <= std + 5) return 2;
      return 1;
    }
    if (bb == 1) {
      if (fat < std - 5) return 5;
      if (fat <= std + 5) return 4;
      if (fat <= std + 20) return 1;
      return 6;
    }
    if (fat < std - 5) return 5;
    if (fat < std - 3) return 4;
    if (fat <= std + 5) return 8;
    if (fat <= std + 10) return 7;
    return 6;
  }

  /// Compute full body composition. Returns null on clearly invalid input.
  ///
  /// [genderMale1Female0]: 1 = male, 0 = female (native convention).
  static BodyCompResult? calc({
    required double heightCm,
    required int ageYears,
    required int genderMale1Female0,
    required double weightKg,
    required int r50,
    required int r500,
  }) {
    if (heightCm <= 0 || weightKg <= 0 || r50 <= 0) return null;

    // Input clamps applied by the native lib before anything else.
    final g = (genderMale1Female0 != 0) ? 1 : 0;
    final h = _clamp(heightCm, 40, 240);
    final age = math.max(3, math.min(80, ageYears));
    final w = _clamp(weightKg, 40, 240);
    final rA = math.min(r50, 1500);
    final rB = math.min(math.max(r500, 0), 1500);

    final fat = _fat(g, h, age, w, rA, rB);
    final fatR = _r1(fat);
    final lbmR = _r1(w * (1 - fat / 100.0)); // lean uses RAW fat
    final wr = _r1(w);
    final hm = h / 100.0;
    final bmiR = _r1(w / (hm * hm));
    final bmiIn = wr / (hm * hm); // inline BMI for visceral

    final boneRaw = (g != 0 ? 0.05 : 0.06) * lbmR;
    final bone = _r2(boneRaw);
    final kW = (g != 0) ? 0.76 : 0.73;
    // unrounded, reused
    final waterC = _clamp(kW * (lbmR - boneRaw) / wr * 100, 10, 80);
    final water = _r1(waterC);
    final sm = _r1((g != 0 ? 0.68 : 0.62) * (lbmR - boneRaw) / wr * 100);
    final musM = _r1(wr * (1 - fatR / 100.0) - boneRaw);
    final bmr = _clamp(370 + 0.216 * wr * (100 - fatR), 900, 2500).truncate();

    final double visc, subc;
    if (g != 0) {
      visc = _clamp(
        0.0082 * fatR + 0.8666 * bmiIn + 0.026 * (wr - lbmR) - 14.2692,
        1,
        30,
      );
      subc = _r1(-0.22 * visc + 0.965 * fatR);
    } else {
      visc = _clamp(
        0.0943 * fatR + 0.8895 * bmiIn - 0.0534 * (wr - lbmR) - 16.215,
        1,
        30,
      );
      subc = _r1(-0.303 * visc + 0.983 * fatR);
    }
    final kf = (g != 0) ? 1.0 : 1.05;
    final prot = _r1(
      math.max(100 - kf * fatR - 100 * boneRaw / wr - waterC, 5.0),
    );

    final raw =
        (_weightScore(wr, h, g) + _fatScore(fatR, g) + _bmiScore(bmiR)) / 3.0;

    return BodyCompResult(
      weightKg: wr,
      bmi: bmiR,
      fatPct: fatR,
      leanMassKg: lbmR,
      subcutFatPct: subc,
      visceral: visc,
      waterPct: water,
      bmr: bmr,
      skelMusclePct: sm,
      muscleMassKg: musM,
      boneMassKg: bone,
      proteinPct: prot,
      bodyScore: _r1(raw),
      bodyAge: _bodyAge(age, raw),
      bodyShape: _bodyShape(bmiR, fatR, g),
    );
  }
}
