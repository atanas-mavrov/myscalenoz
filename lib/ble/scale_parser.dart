/// Pure parsing of the scale's BLE payloads (no plugin dependencies).
library;

int _u16(List<int> b, int i) => (b[i] & 0xFF) | ((b[i + 1] & 0xFF) << 8);

/// `year(u16 LE) month day hour minute second`, as the scale's clock (UTC).
/// Returns null for an unset / nonsensical clock.
DateTime? _timestamp(List<int> b, int i) {
  if (b.length < i + 7) return null;
  final year = _u16(b, i), month = b[i + 2], day = b[i + 3];
  final h = b[i + 4], m = b[i + 5], s = b[i + 6];
  if (year < 2020 || month < 1 || month > 12 || day < 1 || day > 31) {
    return null;
  }
  if (h > 23 || m > 59 || s > 59) return null;
  return DateTime.utc(year, month, day, h, m, s);
}

/// One 0x2A9D (Weight Measurement) notification.
class WeightReading {
  const WeightReading({
    required this.kg,
    required this.isFinal,
    this.scaleTime,
  });

  final double kg;

  /// False for the real-time stream while the weight is still settling.
  final bool isFinal;
  final DateTime? scaleTime;
}

/// `flags(1) weight(u16 LE, ×0.05 kg) [timestamp(7) userIndex(1)]`.
///
/// A stabilised record has flag 0x20 set and carries the timestamp + user
/// index (11+ bytes); anything else is the live, still-settling weight.
WeightReading? parseWeight(List<int> data) {
  if (data.length < 3) return null;
  final flags = data[0] & 0xFF;
  // ×0.05 kg, written so the result is the nearest double to the 2-decimal
  // value (78.6, not 78.60000000000001).
  final kg = _u16(data, 1) * 5 / 100;
  final isFinal = (flags & 0x20) != 0 && data.length >= 11;
  return WeightReading(
    kg: kg,
    isFinal: isFinal,
    scaleTime: isFinal ? _timestamp(data, 3) : null,
  );
}

/// A complete 39-byte 0x2A9C (Body Composition) frame. In Guest mode the
/// scale's own composition fields are zero; only the impedances matter.
class BodyFrame {
  const BodyFrame({required this.r50, required this.r500, this.scaleTime});

  final int r50;
  final int r500;
  final DateTime? scaleTime;
}

/// Reassembles 0x2A9C indications, which arrive fragmented, into frames.
class BodyFrameAssembler {
  static const frameLength = 39;

  final List<int> _buf = [];

  List<BodyFrame> add(List<int> chunk) {
    _buf.addAll(chunk);
    final out = <BodyFrame>[];
    while (_buf.length >= frameLength) {
      final f = _buf.sublist(0, frameLength);
      _buf.removeRange(0, frameLength);
      out.add(
        BodyFrame(
          r50: _u16(f, 22),
          r500: _u16(f, 24),
          scaleTime: _timestamp(f, 4),
        ),
      );
    }
    return out;
  }

  void reset() => _buf.clear();
}
