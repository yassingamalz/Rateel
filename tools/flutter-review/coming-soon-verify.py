"""Screen 14: element boxes of a capture vs the reference (1844x853).
python3 tools/flutter-review/coming-soon-verify.py <capture.png>"""
import sys, numpy as np
from PIL import Image
REF = 'docs/flutter/screens/14-coming-soon/14-in-arrivo.webp'
REGIONS = {'card1': (90, 548, 222, 410), 'card2': (585, 1040, 222, 410), 'card3': (90, 548, 585, 772),
           'card4': (585, 1040, 585, 772), 'right': (1100, 1660, 330, 730), 'emblem': (1180, 1560, 40, 335),
           'badge1': (240, 400, 85, 225), 'badge2': (735, 890, 85, 225), 'badge3': (240, 400, 448, 585),
           'badge4': (735, 890, 448, 585)}
def blocks(L, x0, x1, y0, y1, thr=450):
    m = L[y0:y1, x0:x1] > thr
    rows = np.where(m.any(1))[0]
    out, start, prev = [], None, None
    for r in rows:
        if start is None: start = r
        elif r - prev > 3: out.append((start, prev)); start = r
        prev = r
    if start is not None: out.append((start, prev))
    res = []
    for a, b in out:
        cols = np.where(m[a:b + 1].any(0))[0]
        res.append((y0 + a, y0 + b, x0 + cols[0], x0 + cols[-1]))
    return res
imgs = {n: np.array(Image.open(f).convert('RGB').resize((1844, 853))).astype(int).sum(2) for n, f in [('ref', REF), ('cap', sys.argv[1])]}
for name, box in REGIONS.items():
    r, c = blocks(imgs['ref'], *box), blocks(imgs['cap'], *box)
    print(name)
    for i in range(max(len(r), len(c))):
        a = r[i] if i < len(r) else None; b = c[i] if i < len(c) else None
        fmt = lambda t: 'y %4d-%4d x %4d-%4d (w%4d h%3d)' % (t[0], t[1], t[2], t[3], t[3] - t[2] + 1, t[1] - t[0] + 1) if t else '-' * 40
        d = '' if not (a and b) else '  d top %+d bot %+d left %+d right %+d' % (b[0] - a[0], b[1] - a[1], b[2] - a[2], b[3] - a[3])
        print('  ref', fmt(a), '| cap', fmt(b), d)
