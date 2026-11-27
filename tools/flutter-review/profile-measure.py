"""Screen 29: element boxes on the reference and on a capture (1844x853).
Usage: python3 tools/flutter-review/profile-measure.py <reference.webp> <capture.png> [light]"""
import sys
import numpy as np
from PIL import Image

def load(p):
    return np.asarray(Image.open(p).convert('RGB').resize((1844, 853))).astype(int)

def boxes(a, light):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    if light:
        text = (r < 140) & (g < 100) & (b < 70)
        bright = (r + g + b < 520) & (r - b > 60)
    else:
        text = (r > 215) & (g > 210) & (b > 170)
        bright = r + g > 330
    gold = (r > 170) & (g > 120) & (b < 110) & (r - b > 80) if not light else (r > 170) & (g > 110) & (b < 90)
    out = {}
    def bb(m, x0, y0, x1, y1, k):
        s = m[y0:y1, x0:x1]
        ys, xs = np.nonzero(s)
        out[k] = None if len(xs) < 4 else (x0 + xs.min(), y0 + ys.min(), x0 + xs.max(), y0 + ys.max())
    bb(text, 640, 105, 1100, 172, 'title')
    bb(gold if not light else bright, 780, 30, 960, 105, 'header book')
    bb(text, 690, 245, 1120, 325, 'name')
    bb(text, 930, 345, 1065, 392, 'city')
    bb(bright, 1050, 335, 1112, 395, 'pin')
    for i, (x0, x1) in enumerate([(157, 466), (517, 826), (875, 1184), (1237, 1546)]):
        bb(bright, x0 + 20, 490, x1 - 20, 548, f'icon{i}')
        bb(text, x0 + 20, 550, x1 - 20, 592, f'label{i}')
        bb(text, x0 + 20, 612, x1 - 20, 670, f'num{i}')
    bb(text, 1200, 722, 1395, 785, 'level label')
    bb(bright, 1395, 715, 1475, 790, 'layers')
    bb(bright if not light else (g > r) & (g < 110), 690, 735, 960, 778, 'pill content')
    return out

ref, cap = load(sys.argv[1]), load(sys.argv[2])
light = len(sys.argv) > 3
R, C = boxes(ref, light), boxes(cap, light)
for k in R:
    a, b = R[k], C[k]
    if a is None or b is None:
        print(f'{k:14s} ref {a} cap {b}')
        continue
    d = [b[i] - a[i] for i in range(4)]
    flag = '  <-- ' if max(map(abs, d)) > 4 else ''
    print(f'{k:14s} ref {a} cap {b} diff {d}{flag}')
