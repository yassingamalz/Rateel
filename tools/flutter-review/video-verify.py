"""Screen 07 element-by-element check: boxes (same masks and search regions on reference and capture) and colour
samples. Usage: python3 -I tools/flutter-review/video-verify.py <ref.webp> <capture.png> <unavailable|playing>"""
import sys
import numpy as np
from PIL import Image

ref, cap, state = sys.argv[1], sys.argv[2], sys.argv[3]
R = np.asarray(Image.open(ref).convert('RGB'), np.int32)
C = np.asarray(Image.open(cap).convert('RGB').resize((R.shape[1], R.shape[0]), Image.LANCZOS), np.int32)
U = R.shape[0] / 100


def gold(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    return (r > 150) & (g > 100) & (r - b > 70)


def cream(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    return (r > 190) & (g > 180) & (b > 140)


def green(a):
    return (a[..., 1] > a[..., 0] + 25) & (a[..., 1] > 70)


def box(a, reg, f):
    x0, y0, x1, y1 = reg
    m = f(a[y0:y1, x0:x1])
    ys, xs = np.nonzero(m)
    if len(xs) < 5:
        return None
    return (xs.min() + x0, ys.min() + y0, xs.max() + x0, ys.max() + y0)


common = {
    'skip rim': ((1470, 620, 1800, 780), gold),
    'skip text+glyph': ((1520, 660, 1760, 750), cream),
    'corner L gold': ((0, 560, 330, 854), gold),
    'corner R gold': ((1480, 560, 1842, 854), gold),
}
if state == 'unavailable':
    items = {
        'arch top (gold)': ((250, 25, 1600, 200), gold),
        'mosque': ((450, 150, 850, 450), green),
        'icon gold': ((780, 180, 1090, 400), gold),
        'icon play cream': ((860, 250, 960, 350), cream),
        'title': ((600, 400, 1250, 505), cream),
        'divider': ((450, 505, 1400, 555), gold),
        'sentence': ((550, 560, 1300, 630), cream),
    }
else:
    items = {
        'arch top (gold)': ((250, 25, 1600, 160), gold),
        'title': ((600, 150, 1250, 235), cream),
        'player rim': ((480, 236, 1360, 700), gold),
        'line gold': ((560, 700, 1290, 742), gold),
        'knob': ((700, 700, 900, 745), cream),
        'time L': ((470, 700, 570, 742), cream),
        'time R': ((1270, 700, 1370, 742), cream),
    }
items.update(common)
print(f'{"element":18s} {"REF box":24s} {"APP box":24s} dx dy dw dh (px @854)')
for k, (reg, f) in items.items():
    a, b = box(R, reg, f), box(C, reg, f)
    if a is None or b is None:
        print(f'{k:18s} {a} {b}')
        continue
    d = (b[0] - a[0], b[1] - a[1], (b[2] - b[0]) - (a[2] - a[0]), (b[3] - b[1]) - (a[3] - a[1]))
    flag = ' <<' if max(abs(v) for v in d) > 4 else ''
    print(f'{k:18s} {str(a):24s} {str(b):24s} {d[0]:3d} {d[1]:3d} {d[2]:3d} {d[3]:3d}{flag}')


def hx(p):
    return '#%02X%02X%02X' % tuple(int(v) for v in p)


def med(a, x, y, r=12):
    return hx(np.median(a[y - r:y + r, x - r:x + r].reshape(-1, 3), 0))


print('\nbackground medians (ref | app)')
for (x, y) in [(150, 300), (150, 500), (1700, 300), (921, 640), (921, 800), (400, 800), (300, 150), (921, 30)]:
    print(f'  ({x},{y}) {med(R, x, y)} | {med(C, x, y)}')
# Girih contrast: p95 - median luminance in empty bands.
for (x0, y0, x1, y1) in [(60, 200, 260, 520), (1600, 200, 1800, 520)]:
    for n, a in (('ref', R), ('app', C)):
        l = a[y0:y1, x0:x1].mean(2)
        print(f'  girih {n} ({x0},{y0}) p95-med {np.percentile(l, 95) - np.median(l):.1f}', end='')
    print()


def brightest(a, reg, q=98):
    x0, y0, x1, y1 = reg
    r = a[y0:y1, x0:x1].reshape(-1, 3)
    l = r.sum(1)
    return hx(r[l >= np.percentile(l, q)].mean(0))


print('\nbrightest colours (ref | app)')
for k, (reg, f) in items.items():
    print(f'  {k:18s} {brightest(R, reg)} | {brightest(C, reg)}')
