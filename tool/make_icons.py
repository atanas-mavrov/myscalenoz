#!/usr/bin/env python3
"""Renders the launcher icon into assets/icon/.

b_dial.png    — full icon (as shown on a launcher), used for legacy icons
b_dial_fg.png — transparent adaptive-icon foreground (background #2EAD8F)

Then apply it with `dart run flutter_launcher_icons`.
"""
import math
from pathlib import Path
from PIL import Image, ImageDraw

DARK, TEAL, WHITE = "#12352F", "#2EAD8F", "#FFFFFF"
S = 2048          # supersampled canvas
OUT = 1024
C = S // 2


def disc(d, r, fill, cy=C):
    d.ellipse([C - r, cy - r, C + r, cy + r], fill=fill)


def dial(d):
    """Scale platform with a dial: tick arc and a needle."""
    disc(d, 560, WHITE)
    for i in range(-4, 5):
        a = math.radians(-90 + i * 14)
        r0, r1 = (400, 480) if i % 2 == 0 else (430, 480)
        d.line([(C + r0 * math.cos(a), C + 120 + r0 * math.sin(a)),
                (C + r1 * math.cos(a), C + 120 + r1 * math.sin(a))],
               fill=DARK, width=26)
    a = math.radians(-90 + 24)
    d.line([(C, C + 120), (C + 360 * math.cos(a), C + 120 + 360 * math.sin(a))],
           fill=TEAL, width=44)
    disc(d, 62, TEAL, cy=C + 120)


def main():
    out = Path(__file__).resolve().parent.parent / "assets" / "icon"
    out.mkdir(parents=True, exist_ok=True)
    fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    dial(ImageDraw.Draw(fg))
    fg.resize((OUT, OUT), Image.LANCZOS).save(out / "b_dial_fg.png")

    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, S, S], radius=S // 4.5, fill=255)
    full = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    full.paste(Image.new("RGBA", (S, S), TEAL), (0, 0), mask)
    full.alpha_composite(fg)
    full.resize((OUT, OUT), Image.LANCZOS).save(out / "b_dial.png")


if __name__ == "__main__":
    main()
