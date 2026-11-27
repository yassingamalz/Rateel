"""Screen 22: element-by-element check, reference vs capture at 1844x853 (boxes in px, ±4 px target).

Usage: python3 tools/flutter-review/listening-verify.py <reference.webp> <capture.png> [out.md]
Boxes: ink of each element found with a colour rule inside a search window (same rule on both images).
"""
import sys
import numpy as np
from PIL import Image

ref, cap = (np.asarray(Image.open(p).convert('RGB')).astype(int) for p in sys.argv[1:3])
out = sys.argv[3] if len(sys.argv) > 3 else None


def gold(a): return (a[..., 0] > 170) & (a[..., 1] > 120) & (a[..., 2] < 120) & (a[..., 0] - a[..., 2] > 90)
def bright(a): return a.sum(-1) > 450
def light(a): return a.sum(-1) > 330
def green(a): return (a[..., 1] > 85) & (a[..., 1] < 150) & (a[..., 0] < 100) & (a[..., 1] - a[..., 0] > 30)
def wgreen(a): return (abs(a[..., 0] - 0x3B) < 14) & (abs(a[..., 1] - 0x6C) < 14) & (abs(a[..., 2] - 0x39) < 14)


EL = [  # name, rule, window x0, y0, x1, y1
    ('capsule', light, 15, 50, 430, 135), ('pause ring', light, 1670, 15, 1835, 175),
    ('title', bright, 700, 110, 1150, 195), ('crescent+star', gold, 1320, 60, 1440, 180),
    ('card', light, 20, 210, 1825, 590), ('badge', light, 1660, 250, 1765, 350),
    ('surah · reciter', bright, 60, 255, 600, 315), ('verse', bright, 450, 315, 1400, 450),
    ('asked word (gold)', gold, 1100, 300, 1400, 450), ('wave played (gold)', gold, 330, 474, 1500, 532),
    ('wave rest (green)', wgreen, 330, 466, 1500, 528), ('play ring', light, 850, 570, 995, 690),
    ('question', bright, 1270, 725, 1800, 800), ('pill 1 (gold)', gold, 975, 710, 1245, 820),
    ('pill 2', light, 712, 712, 975, 818), ('pill 3', light, 448, 712, 712, 818), ('confirm', light, 45, 698, 350, 822),
]


def box(img, rule, x0, y0, x1, y1):
    m = rule(img[y0:y1, x0:x1])
    ys, xs = np.nonzero(m)
    if len(xs) < 20:
        return None
    return (xs.min() + x0, ys.min() + y0, xs.max() + x0, ys.max() + y0)


rows = ['| Element | Reference x0,y0–x1,y1 | Flutter | Δ max (px) |', '|---|---|---|---|']
for name, rule, *w in EL:
    a, b = box(ref, rule, *w), box(cap, rule, *w)
    d = max(abs(i - j) for i, j in zip(a, b)) if a and b else '—'
    flag = '' if d == '—' or d <= 4 else (' ⚠' if d <= 12 else ' ✗')
    rows.append(f'| {name} | {a} | {b} | {d}{flag} |')
txt = '\n'.join(rows)
print(txt)
if out:
    open(out, 'w').write(txt + '\n')
