#!/usr/bin/env python3
"""Renders the measurement chime into assets/sounds/.

done.wav  - bright bell: the measurement is complete, step off.

Struck-bell tones: a few inharmonic partials, the higher ones dying away
faster, so they ring out instead of beeping.
"""
import math
import struct
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parent.parent / "assets" / "sounds"

# (frequency ratio, level, decay time constant in seconds). Weighted towards
# the strike note and the partials above it, which is what makes a bell sound
# clear rather than muffled.
PARTIALS = [
    (0.5, 0.08, 0.50),   # hum
    (1.0, 1.00, 0.50),   # strike note
    (2.0, 0.70, 0.36),   # octave
    (2.76, 0.45, 0.22),
    (3.0, 0.30, 0.20),
    (4.07, 0.35, 0.14),
    (5.4, 0.25, 0.09),
    (6.8, 0.15, 0.06),
]


def bell(strike_hz, seconds, ring=1.0):
    n = int(RATE * seconds)
    attack, release = int(RATE * 0.001), int(RATE * 0.05)
    samples = []
    for i in range(n):
        t = i / RATE
        v = sum(level * math.exp(-t / (decay * ring)) * math.sin(2 * math.pi * strike_hz * ratio * t)
                for ratio, level, decay in PARTIALS)
        samples.append(v * min(1.0, i / attack, (n - i) / release))
    return samples


def save(name, samples):
    peak = max(abs(s) for s in samples)
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(s / peak * 0.97 * 32767)) for s in samples))


save("done.wav", bell(2093, 1.6))              # C7
