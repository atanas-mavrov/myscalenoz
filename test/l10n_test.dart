import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:myscalenoz/ble/scale_service.dart';
import 'package:myscalenoz/core/metrics.dart';
import 'package:myscalenoz/l10n/strings.dart';

void main() {
  test('follows the phone language, English otherwise', () {
    expect(resolveLanguage(const [Locale('de', 'AT')]), 'de');
    expect(resolveLanguage(const [Locale('ja'), Locale('fr')]), 'fr');
    expect(resolveLanguage(const [Locale('ja')]), 'en');
    expect(resolveLanguage(const []), 'en');
  });

  test('every language is complete', () {
    expect(languages.keys, unorderedEquals(['en', 'bg', 'es', 'de', 'fr']));
    for (final MapEntry(key: code, value: s) in languages.entries) {
      expect(
        s.bodyShapes.keys,
        unorderedEquals([1, 2, 3, 4, 5, 6, 7, 8, 9]),
        reason: code,
      );
      for (final e in ScaleError.values) {
        expect(s.scaleError(e), isNotEmpty, reason: '$code $e');
      }
      setLanguage(code);
      for (final m in Metrics.all) {
        expect(m.label, isNotEmpty, reason: '$code ${m.key}');
        expect(m.help, isNotEmpty, reason: '$code ${m.key}');
      }
    }
  });

  test('switching the language switches the texts', () {
    setLanguage('de');
    expect(S.mWeight, 'Gewicht');
    expect(Metrics.weight.label, 'Gewicht');
    setLanguage('es');
    expect(S.mWeight, 'Peso');
  });
}
