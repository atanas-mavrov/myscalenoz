import 'package:flutter_test/flutter_test.dart';
import 'package:myscalenoz/ble/scale_parser.dart';

void main() {
  group('parseWeight', () {
    test('live reading: weight only, not final', () {
      // 1572 * 0.05 = 78.6 kg
      final w = parseWeight([0x00, 0x24, 0x06])!;
      expect(w.kg, 78.6);
      expect(w.isFinal, isFalse);
      expect(w.scaleTime, isNull);
    });

    test('final reading carries the scale timestamp', () {
      final w = parseWeight([
        0x2E, 0x24, 0x06, // flags (0x20 set), weight
        0xEA, 0x07, 10, 1, 19, 53, 7, // 2026-10-01 19:53:07
        0x01, // user index
      ])!;
      expect(w.kg, 78.6);
      expect(w.isFinal, isTrue);
      expect(w.scaleTime, DateTime.utc(2026, 10, 1, 19, 53, 7));
    });

    test('unset scale clock yields no timestamp', () {
      final w = parseWeight([0x2E, 0x24, 0x06, 0, 0, 0, 0, 0, 0, 0, 0xFF])!;
      expect(w.isFinal, isTrue);
      expect(w.scaleTime, isNull);
    });

    test('too short', () => expect(parseWeight([0x00, 0x24]), isNull));
  });

  group('BodyFrameAssembler', () {
    List<int> frame(int r50, int r500) {
      final f = List<int>.filled(39, 0);
      f[22] = r50 & 0xFF;
      f[23] = r50 >> 8;
      f[24] = r500 & 0xFF;
      f[25] = r500 >> 8;
      return f;
    }

    test('reassembles a fragmented frame', () {
      final a = BodyFrameAssembler();
      final f = frame(467, 427);
      expect(a.add(f.sublist(0, 20)), isEmpty);
      final out = a.add(f.sublist(20));
      expect(out, hasLength(1));
      expect(out.single.r50, 467);
      expect(out.single.r500, 427);
    });

    test('handles back-to-back frames split at arbitrary points', () {
      final a = BodyFrameAssembler();
      final bytes = [...frame(500, 450), ...frame(610, 580)];
      final out = [...a.add(bytes.sublist(0, 45)), ...a.add(bytes.sublist(45))];
      expect(out.map((f) => (f.r50, f.r500)), [(500, 450), (610, 580)]);
    });
  });
}
