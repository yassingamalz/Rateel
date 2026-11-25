"""Screen 08 element-by-element check: boxes (same masks and search regions on reference and capture), in px at
1842x854 and the difference. Usage: python3 -I tools/flutter-review/reading-verify.py <ref> <capture.png>"""
import sys
import numpy as np
from PIL import Image

ref, cap = sys.argv[1], sys.argv[2]
R = np.asarray(Image.open(ref).convert('RGB'), np.int32)
C = np.asarray(Image.open(cap).convert('RGB').resize((R.shape[1], R.shape[0]), Image.LANCZOS), np.int32)
light = 'light' in ref


def gold(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    if light:
        return (r < 225) & (r - b > 45) & (r > 120)
    return (r > 170) & (g > 120) & (b < 140) & (r - b > 70)


def cream(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    if light:
        return (r < 110) & (g < 90)
    return (r > 215) & (g > 205) & (b > 160)


def green(a):
    r, g = a[..., 0], a[..., 1]
    if light:
        return (r < 236) & (r > 200) & (g < 215)
    return (g > r + 30) & (g > 110)


def box(a, reg, f):
    x0, y0, x1, y1 = reg
    ys, xs = np.nonzero(f(a[y0:y1, x0:x1]))
    if len(xs) < 4:
        return None
    return (x0 + int(xs.min()), y0 + int(ys.min()), x0 + int(xs.max()) + 1, y0 + int(ys.max()) + 1)


checks = [
    ('title', (620, 100, 1240, 200), cream),
    ('verse', (300, 470, 1690, 600), cream),
    ('rules text+i', (95, 268, 360, 318), cream),
    ('rules pill', (55, 250, 400, 340), gold),
    ('moon btn', (800, 255, 895, 335), gold),
    ('A glyph', (955, 262, 1020, 322), cream),
    ('prev btn', (1425, 255, 1520, 335), gold),
    ('next btn', (1685, 255, 1785, 335), gold),
    ('counter txt', (1560, 270, 1650, 315), cream),
    ('card rim', (20, 355, 1825, 695), gold),
    ('badge', (1645, 390, 1770, 500), gold),
    ('badge num', (1690, 420, 1725, 468), cream),
    ('book', (840, 40, 1000, 115), gold),
    ('crescent', (1320, 60, 1450, 175), gold),
    ('divider', (700, 190, 1150, 230), gold),
    ('mosque', (330, 30, 640, 215), green),
    ('dot on', (1050, 745, 1120, 795), gold),
    ('skip (ref right / app left)', (40, 690, 1830, 815), gold),
]
print('%-28s %-26s %-26s %s' % ('element', 'reference', 'capture', 'dx0 dy0 dx1 dy1'))
for name, reg, f in checks:
    a, b = box(R, reg, f), box(C, reg, f)
    d = tuple(b[i] - a[i] for i in range(4)) if a and b else None
    print('%-28s %-26s %-26s %s' % (name, a, b, d))
