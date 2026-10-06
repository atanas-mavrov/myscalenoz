import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:myscalenoz/core/body_comp.dart';

const _fields = [
  'BMI', 'fatPct', 'leanMassKg', 'subcutFatPct', 'visceral', 'waterPct', //
  'BMR', 'skelMusclePct', 'muscleMassKg', 'boneMassKg', 'proteinPct',
  'bodyScore', 'bodyAge', 'bodyShape',
];

Map<String, num> _outputs(BodyCompResult r) => {
  'weight': r.weightKg,
  'BMI': r.bmi,
  'fatPct': r.fatPct,
  'leanMassKg': r.leanMassKg,
  'subcutFatPct': r.subcutFatPct,
  'visceral': r.visceral,
  'waterPct': r.waterPct,
  'BMR': r.bmr,
  'skelMusclePct': r.skelMusclePct,
  'muscleMassKg': r.muscleMassKg,
  'boneMassKg': r.boneMassKg,
  'proteinPct': r.proteinPct,
  'bodyScore': r.bodyScore,
  'bodyAge': r.bodyAge,
  'bodyShape': r.bodyShape,
};

/// Runs [check] for every field of every row of [path]; returns the row count.
int _forEachRow(
  String path,
  void Function(String field, num got, String ref, String line) check,
) {
  final lines = File(path)
      .readAsLinesSync()
      .where((l) => l.trim().isNotEmpty)
      .toList();
  final cols = lines.first.split(',');
  final ci = {for (var i = 0; i < cols.length; i++) cols[i]: i};
  for (final line in lines.skip(1)) {
    final v = line.split(',');
    final r = BodyComp.calc(
      genderMale1Female0: int.parse(v[ci['gender']!]),
      heightCm: double.parse(v[ci['heightCm']!]),
      ageYears: int.parse(v[ci['ageYears']!]),
      weightKg: double.parse(v[ci['weightKg']!]),
      r50: int.parse(v[ci['r50']!]),
      r500: int.parse(v[ci['r500']!]),
    )!;
    final got = _outputs(r);
    for (final f in ['weight', ..._fields]) {
      check(f, got[f]!, v[ci[f]!], line);
    }
  }
  return lines.length - 1;
}

void main() {
  // Output of the original native library. Printed with 4 decimals, so the
  // (unrounded) visceral value can only be checked to half a unit of the 4th
  // decimal here; every other field is exact.
  test('matches native reference.csv on all 14 fields', () {
    final n = _forEachRow('reference/reference.csv', (f, got, ref, line) {
      final want = double.parse(ref);
      if (f == 'visceral') {
        expect(
          (got - want).abs(),
          lessThanOrEqualTo(5e-5),
          reason: '$f in row: $line',
        );
      } else {
        expect(got.toDouble(), want, reason: '$f in row: $line');
      }
    });
    expect(n, 40);
  });

  // Full-precision output of the validated reference/BodyComp.java over the
  // reference rows plus a grid that includes out-of-range inputs (clamps) and
  // r500 == 0. Every field, visceral included, must be the identical double.
  test('bit-for-bit identical to the Java port (java_golden.csv)', () {
    final n = _forEachRow('reference/java_golden.csv', (f, got, ref, line) {
      final want = double.parse(ref);
      if (got.toDouble() != want) {
        fail('$f: got $got, want $ref in row: $line');
      }
    });
    expect(n, greaterThan(30000));
  });

  test('returns null on invalid input', () {
    BodyCompResult? calc({double h = 180, double w = 78.6, int r50 = 467}) =>
        BodyComp.calc(
          heightCm: h,
          ageYears: 48,
          genderMale1Female0: 1,
          weightKg: w,
          r50: r50,
          r500: 427,
        );
    expect(calc(h: 0), isNull);
    expect(calc(w: 0), isNull);
    expect(calc(r50: 0), isNull);
    expect(calc(), isNotNull);
  });
}
