#!/usr/bin/env python3
"""Pixel measurements for the side-nav critic (reference vs Flutter).

Usage:  python3 -I measure.py [REF_DIR] [FLUTTER_DIR]   e.g. measure.py . v2
DIR defaults to this script's folder. Files expected there:
  ref-04-open.png, flutter-open-1844x853.png        open menu (1844x853)
  ref-05-rail.png (scaled to h=853 by 853/941),      closed rail
  flutter-closed-1844x853.png
All x values are reported in the 1844x853 frame (rail images right-aligned).

Method: every element is located from an approximate ANCHOR (see CONFIG) and
then refined locally: rims = narrow luminance peaks (<= 6 px wide, prominence
>= 8), gold/amber = colour masks, text/icons = light-pixel masks. If the Flutter
layout moves a lot in v2, update the anchors in CONFIG (they are only search
seeds; sizes/colours are measured, not assumed).
"""
import sys, os, math
import numpy as np
from PIL import Image

D = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.abspath(__file__))
DF = sys.argv[2] if len(sys.argv) > 2 else D  # folder with the flutter-*.png captures (e.g. v2/)
H, FW = 853, 1844

CONFIG = {
    'ref-04-open.png': dict(edge=1175, rows=[187, 288, 383, 478, 572, 667]),
    'flutter-open-1844x853.png': dict(edge=1178, rows=[188, 282, 377, 471, 566, 661]),
    # rail anchors are in the 1844 frame
    'ref-05-rail.png': dict(edge=1685, menu=(1764, 56), active=(1769, 184),
                            tiles=[312, 433, 555, 676]),
    'flutter-closed-1844x853.png': dict(edge=1682, menu=(1765, 54), active=(1765, 175),
                                        tiles=[285, 396, 507, 618, 729]),
}

# Per-round anchor overrides for the Flutter captures (key = FLUTTER_DIR basename)
OVERRIDES = {
    'v4': {
        'flutter-open-1844x853.png': dict(edge=1176, rows=[189, 284, 379, 474, 569, 664]),
        'flutter-closed-1844x853.png': dict(edge=1688, menu=(1768, 55), active=(1769, 182),
                                            tiles=[300, 418, 537, 655, 774]),
    },
    'v3': {
        'flutter-open-1844x853.png': dict(edge=1176, rows=[189, 284, 379, 474, 569, 664]),
        'flutter-closed-1844x853.png': dict(edge=1688, menu=(1768, 55), active=(1769, 182),
                                            tiles=[300, 418, 537, 655, 774]),
    },
    'v2': {
        'flutter-open-1844x853.png': dict(edge=1176, rows=[189, 284, 379, 474, 569, 664]),
        'flutter-closed-1844x853.png': dict(edge=1688, menu=(1768, 55), active=(1769, 182),
                                            tiles=[300, 418, 537, 655, 774]),
    },
}
for _k, _v in OVERRIDES.get(os.path.basename(os.path.normpath(DF)), {}).items():
    CONFIG[_k] = _v


# ------------------------------------------------------------------ helpers
def load(name, scale=False):
    im = Image.open(os.path.join(DF if name.startswith('flutter') else D, name)).convert('RGB')
    if scale and im.size[1] != H:
        im = im.resize((round(im.size[0] * H / im.size[1]), H), Image.LANCZOS)
    return np.asarray(im).astype(float)


def hx(c):
    if c is None or np.any(np.isnan(np.asarray(c, float))):
        return '?'
    return '#%02X%02X%02X' % tuple(int(max(0, min(255, round(v)))) for v in c)


def L(c):
    c = np.asarray(c, float)
    return 0.2126 * c[..., 0] + 0.7152 * c[..., 1] + 0.0722 * c[..., 2]


def med(a, x0, y0, x1, y1):
    return np.median(a[int(y0):int(y1), int(x0):int(x1)].reshape(-1, 3), axis=0)


def amber(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    return (r > 190) & (g > 125) & (b < 130) & (r - b > 95)


def gold(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    return (r > 170) & (g > 120) & (b < 130) & (r - b > 80)


def light(a):
    return (a.min(axis=-1) > 160) & ~amber(a)


def bbox(m, x0=0, y0=0):
    ys, xs = np.nonzero(m)
    if not len(xs):
        return None
    return int(xs.min() + x0), int(ys.min() + y0), int(xs.max() + x0), int(ys.max() + y0)


def peaks(prof, start, prom=8, maxw=6):
    """Narrow luminance peaks: list of (pos, width, peakvalue)."""
    v = L(prof)
    out = []
    n = len(v)
    i = 1
    while i < n - 1:
        if v[i] >= v[i - 1] and v[i] >= v[i + 1]:
            lo = min(v[max(0, i - 7):i].min() if i else v[i], v[i + 1:i + 8].min())
            if v[i] - lo >= prom:
                half = lo + (v[i] - lo) / 2
                a_, b_ = i, i
                while a_ > 0 and v[a_ - 1] > half: a_ -= 1
                while b_ < n - 1 and v[b_ + 1] > half: b_ += 1
                w = b_ - a_ + 1
                if w <= maxw:
                    if not out or start + i - out[-1][0] > 3:
                        out.append((start + i, w, prof[i]))
                    i = b_ + 1
                    continue
        i += 1
    return out


def falloff(a, x, y, dx, dy, bg, n=45):
    prof = []
    for d in range(1, n):
        xx, yy = x + dx * d, y + dy * d
        if not (0 <= xx < a.shape[1] and 0 <= yy < a.shape[0]): break
        prof.append(a[yy, xx])
    ext = next((i + 1 for i, c in enumerate(prof) if np.abs(c - bg).sum() < 6), len(prof))
    return ext, (prof[2] if len(prof) > 2 else bg)


def alpha(c, bg, src):
    d = np.asarray(src) - bg
    m = np.abs(d) > 20
    return float(np.clip(np.mean((np.asarray(c) - bg)[m] / d[m]), 0, 1)) if m.any() else 0.0


def ink(a, m, x0, y0, what):
    bb = bbox(m, x0, y0)
    if bb is None:
        return f'{what}: none'
    w, h = bb[2] - bb[0] + 1, bb[3] - bb[1] + 1
    sub = a[bb[1]:bb[3] + 1, bb[0]:bb[2] + 1]
    mm = m[bb[1] - y0:bb[3] - y0 + 1, bb[0] - x0:bb[2] - x0 + 1]
    px = sub[mm]
    core = px[L(px) >= np.percentile(L(px), 70)]
    return (f'{what}: x{bb[0]}-{bb[2]} y{bb[1]}-{bb[3]} = {w}x{h}px, centre ({(bb[0] + bb[2]) / 2:.0f},{(bb[1] + bb[3]) / 2:.0f}), '
            f'colour {hx(np.median(core, axis=0))}, ink density {mm.sum() / (w * h):.2f} (weight proxy)')


def capsule(a, cy, vx, lwin, rwin, fillx, bg, X=lambda x: x):
    """Measure a rounded capsule/tile around centre row cy."""
    col = a[:, vx]
    up = [p for p in peaks(col[max(1, cy - 75):cy], max(1, cy - 75))]
    dn = [p for p in peaks(col[cy:cy + 75], cy)]
    if not up or not dn:
        return None
    t, b = up[-1], dn[0]
    top, bot = t[0] - t[1] // 2, b[0] + b[1] // 2
    cyy = (top + bot) // 2
    row = a[cyy]
    lp = peaks(row[lwin[0]:lwin[1]], lwin[0])
    rp = peaks(row[rwin[0]:rwin[1]], rwin[0], prom=5)
    lft = lp[0] if lp else None
    rgt = rp[0] if rp else None
    res = dict(top=top, bot=bot, h=bot - top + 1, cy=cyy, rim_t=t, rim_b=b, left=lft, right=rgt)
    # radius from bottom-left corner
    rad = None
    if lft:
        fillL = L(a[cyy, lft[0] + 8])
        thr = fillL + 0.5 * (L(lft[2]) - fillL)
        for yy in range(bot, cyy, -1):
            seg = L(a[yy, lwin[0]:lft[0] + 60])
            xs = np.nonzero(seg > thr)[0]
            if len(xs) and lwin[0] + xs[0] <= lft[0] + 1:
                rad = bot - yy; break
    if rad is not None:
        r_ = rad
        for _ in range(5): r_ = rad + math.sqrt(2 * max(r_, 1))
        rad = f'{rad} (corrected for 1px tolerance: r~{r_:.0f})'
    res['radius'] = rad
    th = max(t[1], 1)
    res['fill_top'] = med(a, fillx[0], top + th + 4, fillx[1], top + th + 10)
    res['fill_bot'] = med(a, fillx[0], bot - th - 10, fillx[1], bot - th - 4)
    ext, c3 = falloff(a, vx, top - 1, 0, -1, bg, n=min(45, max(3, top)))
    res['glow'] = (ext, c3, alpha(c3, bg, t[2]))
    w = (rgt[0] - lft[0] + 1) if (lft and rgt) else None
    res['txt'] = (f'y{top}-{bot} h={bot - top + 1}px, x{X(lft[0]) if lft else "?"}-{X(rgt[0]) if rgt else "?"} w={w}px, '
                  f'corner radius ~{rad}px; rim top {t[1]}px {hx(t[2])}, bottom {b[1]}px {hx(b[2])}, '
                  f'left {lft[1] if lft else "?"}px {hx(lft[2]) if lft else ""}, right {rgt[1] if rgt else "?"}px; '
                  f'fill top {hx(res["fill_top"])} bottom {hx(res["fill_bot"])}; '
                  f'outer glow above: extent {ext}px, colour@3px {hx(c3)} (bg {hx(bg)}), est. opacity {res["glow"][2]:.2f}')
    return res


def pill(a, x0, y0, x1, y1, ref_left=None, X=lambda x: x):
    m = amber(a[y0:y1, x0:x1])
    # keep the largest connected horizontal band: bbox of mask rows with >=6 px
    rows_ok = np.nonzero(m.sum(axis=1) >= 6)[0]
    if not len(rows_ok):
        return 'pill: none', None
    m2 = np.zeros_like(m); m2[rows_ok] = m[rows_ok]
    bb = bbox(m2, x0, y0)
    w, h = bb[2] - bb[0] + 1, bb[3] - bb[1] + 1
    cxp = (bb[0] + bb[2]) // 2
    sl = a[bb[1]:bb[3] + 1, bb[0]:bb[2] + 1]
    am = amber(sl)
    tcol = np.median(sl[am].reshape(-1, 3)[:0], axis=0) if False else None
    def rowc(yy):
        seg = a[yy, bb[0] + 4:bb[2] - 3]
        m_ = amber(seg)
        return np.median(seg[m_], axis=0) if m_.any() else None
    topc, botc = rowc(bb[1] + 3), rowc(bb[3] - 3)
    dm = sl.sum(axis=-1) < 330
    ins = max(3, h // 3)
    dm[:4] = dm[-4:] = False; dm[:, :ins] = dm[:, -ins:] = False
    tb = bbox(dm, bb[0], bb[1])
    tc = np.median(sl[dm], axis=0) if dm.any() else np.zeros(3)
    dens = dm.sum() / ((tb[2] - tb[0] + 1) * (tb[3] - tb[1] + 1)) if tb else 0
    sh2, sh5 = a[bb[3] + 2, cxp], a[bb[3] + 6, cxp]
    txt = (f'x{X(bb[0])}-{X(bb[2])} y{bb[1]}-{bb[3]} = {w}x{h}px'
           + (f', inset {bb[0] - ref_left}px from row/tile left rim' if ref_left is not None else '')
           + f'; gradient top {hx(topc)} bottom {hx(botc)}; text {"?" if tb is None else f"{tb[2] - tb[0] + 1}x{tb[3] - tb[1] + 1}px"} '
           f'{hx(tc)} density {dens:.2f}; under-edge +2px {hx(sh2)} +6px {hx(sh5)}')
    return txt, bb


# ------------------------------------------------------------------ open menu
def open_menu(name):
    a = load(name)
    cfg = CONFIG[name]
    W = a.shape[1]
    print(f'\n################ OPEN MENU  {name}')
    y = 740
    seg = a[y, cfg['edge'] - 15:cfg['edge'] + 16]
    pk = peaks(seg, cfg['edge'] - 15, prom=5)
    e = pk[0][0] if pk else cfg['edge']
    print(f'PANEL: edge line x={e} width {pk[0][1] if pk else "?"}px {hx(a[y, e])}; panel width {W - e}px; '
          f'profile x-6..x+6: {" ".join(hx(a[y, x]) for x in range(e - 6, e + 7))}')
    print(f'   panel bg top-right {hx(med(a, 1810, 4, 1836, 14))}, bottom-right(y~743) {hx(med(a, 1810, 736, 1836, 750))}, '
          f'top-left {hx(med(a, e + 10, 4, e + 30, 14))}, mid-left {hx(med(a, e + 10, 420, e + 30, 430))}')
    print(f'   content left of edge: x-40 {hx(a[y, e - 40])} x-20 {hx(a[y, e - 20])} x-8 {hx(a[y, e - 8])} x-3 {hx(a[y, e - 3])}; '
          f'far content (600,820) {hx(a[820, 600])}')
    gapbg = med(a, 1400, (cfg['rows'][2] + cfg['rows'][3]) // 2 - 1, 1500, (cfg['rows'][2] + cfg['rows'][3]) // 2 + 1)

    # close button
    gm = gold(a[0:125, e + 15:e + 150])
    cb = bbox(gm, e + 15, 0)
    cx, cy = (cb[0] + cb[2]) // 2, (cb[1] + cb[3]) // 2
    dia = cb[2] - cb[0] + 1
    lp = peaks(a[cy, cb[0] - 3:cx], cb[0] - 3, prom=20)
    sub = a[cb[1]:cb[3] + 1, cb[0]:cb[2] + 1]
    xm = sub.min(axis=-1) > 150
    yy, xx = np.mgrid[cb[1]:cb[3] + 1, cb[0]:cb[2] + 1]
    xm &= ((xx - cx) ** 2 + (yy - cy) ** 2) < (0.4 * dia) ** 2
    xb = bbox(xm, cb[0], cb[1])
    xw, xh = xb[2] - xb[0] + 1, xb[3] - xb[1] + 1
    stroke = xm.sum() / (2 * math.hypot(xw, xh))
    bgc = a[cy, cb[0] - 15]
    ext, c3 = falloff(a, cb[0], cy, -1, 0, a[cy, cb[0] - 30])
    print(f'CLOSE BTN: x{cb[0]}-{cb[2]} y{cb[1]}-{cb[3]} diameter {dia}px centre ({cx},{cy}); '
          f'rim {lp[0][1] if lp else "?"}px {hx(lp[0][2]) if lp else ""}; fill {hx(a[int(cy + 0.36 * dia), cx])} vs bg {hx(bgc)}; '
          f'X glyph {xw}x{xh}px colour {hx(np.median(sub[xm & (sub.min(axis=-1) > 200)], axis=0))} stroke ~{stroke:.1f}px; '
          f'outer glow {ext}px colour@3px {hx(c3)}')

    prev = None
    for k, rc in enumerate(cfg['rows']):
        r = capsule(a, rc, 1450, (e + 62, e + 140), (1780, 1815), (1400, 1500), gapbg)
        if r is None:
            print(f'ROW{k + 1}: not found'); continue
        sel = bool(gold(np.array([r['rim_t'][2]]))[0])
        print(f'ROW{k + 1}{" [SELECTED]" if sel else ""}: {r["txt"]}' + (f'; pitch {r["cy"] - prev}px' if prev else ''))
        prev = r['cy']
        top, bot, cyy = r['top'], r['bot'], r['cy']
        left = r['left'][0] if r['left'] else None
        if sel:
            # icon circle: horizontal run of bright gold at cy within 1670-1790
            g = gold(a[cyy, 1670:1792]) & (a[cyy, 1670:1792, 0] > 185)
            xs = np.nonzero(g)[0]
            gv = gold(a[top + 3:bot - 2, (1670 + 1790) // 2 + 0:(1670 + 1790) // 2 + 1])
            if len(xs):
                l_, r_ = 1670 + xs[0], 1670 + xs[-1]
                icx = (l_ + r_) // 2
                gcol = np.nonzero(gold(a[top + 3:bot - 2, icx]) & (a[top + 3:bot - 2, icx, 0] > 185))[0]
                t_, b_ = top + 3 + gcol[0], top + 3 + gcol[-1]
                icy = (t_ + b_) // 2
                d = r_ - l_ + 1
                ringw = peaks(a[icy, l_ - 3:l_ + 10], l_ - 3, prom=15)
                angs = [a[int(icy + 0.42 * d * math.sin(t)), int(icx + 0.42 * d * math.cos(t))] for t in np.linspace(0, 2 * math.pi, 64)]
                angs = np.array([c for c in angs if not gold(np.array([c]))[0]])
                inner = gold(a[icy - int(0.36 * d):icy + int(0.36 * d), icx - int(0.36 * d):icx + int(0.36 * d)])
                gb = bbox(inner, icx - int(0.36 * d), icy - int(0.36 * d))
                ext2, c32 = falloff(a, r_, icy, 1, 0, a[icy, r_ + 12])
                print(f'   icon circle: x{l_}-{r_} y{t_}-{b_} = {d}x{b_ - t_ + 1}px centre ({icx},{icy}), {r["right"][0] - r_ if r["right"] else "?"}px from row right rim; '
                      f'ring {ringw[0][1] if ringw else "?"}px {hx(ringw[0][2]) if ringw else ""}; disc fill {hx(np.median(angs, axis=0)) if len(angs) else "?"}; '
                      f'gold glyph {None if gb is None else f"{gb[2] - gb[0] + 1}x{gb[3] - gb[1] + 1}px"}')
        else:
            ia = a[top + 4:bot - 3, 1690:1790]
            print('   ' + ink(a, light(ia), 1690, top + 4, 'icon') + f'; gold-accent px in icon area {int(gold(ia).sum())}')
        print('   ' + ink(a, light(a[top + 4:bot - 3, 1390:1688]), 1390, top + 4, 'label'))
        ptxt, pb = pill(a, max(e + 70, (left or 0) + 5), top + 3, e + 205, bot - 2, left)
        print('   pill: ' + ptxt)
        if pb:
            dp = peaks(a[cyy, pb[2] + 3:pb[2] + 50], pb[2] + 3, prom=6)
            if dp:
                dx = dp[0][0]
                base = L(a[cyy, dx + 6])
                vr = [yy for yy in range(top + 3, bot - 3) if L(a[yy, dx]) > base + 6]
                print(f'   divider: x{dx}, {dx - pb[2]}px left-of-label side of pill, width {dp[0][1]}px, height {len(vr)}px, peak {hx(dp[0][2])}')


# ------------------------------------------------------------------ closed rail
def rail(name, scale):
    a = load(name, scale)
    cfg = CONFIG[name]
    W = a.shape[1]
    off = FW - W
    X = lambda x: None if x is None else int(x) + off
    lx = lambda x: int(x) - off
    print(f'\n################ CLOSED RAIL  {name}  (img width {W}; x shown in 1844 frame, +{off})')
    y = 450
    ex = lx(cfg['edge'])
    pk = peaks(a[y, ex - 15:ex + 16], ex - 15, prom=5)
    e = pk[0][0] if pk else ex
    print(f'RAIL: edge x={X(e)} line {pk[0][1] if pk else "?"}px {hx(a[y, e])}; rail width {W - e}px; '
          f'profile x-4..x+6: {" ".join(hx(a[y, x]) for x in range(e - 4, e + 7))}')
    railbg = med(a, e + 6, 415, e + 16, 425)
    print(f'   rail bg top {hx(med(a, W - 30, 2, W - 10, 10))}, mid {hx(railbg)}, bottom {hx(med(a, W - 30, 838, W - 10, 850))}')

    # menu button
    mx, my = lx(cfg['menu'][0]), cfg['menu'][1]
    r = capsule(a, my, mx + 30, (e + 5, mx - 10), (mx + 15, W), (mx + 26, mx + 30), railbg, X)
    if r:
        print(f'MENU BTN: {r["txt"]}')
        l_ = r['left'][0] if r['left'] else mx - 35
        rr = r['right'][0] if r['right'] else mx + 35
        sub = a[r['top'] + 4:r['bot'] - 3, l_ + 4:rr - 3]
        hm = sub.min(axis=-1) > 170
        hb = bbox(hm, l_ + 4, r['top'] + 4)
        if hb:
            bars = []
            colv = hm[:, (hb[0] + hb[2]) // 2 - (l_ + 4)]
            i = 0
            while i < len(colv):
                if colv[i]:
                    j = i
                    while j < len(colv) and colv[j]: j += 1
                    bars.append(j - i); i = j
                else:
                    i += 1
            print(f'   hamburger: {hb[2] - hb[0] + 1}x{hb[3] - hb[1] + 1}px, {len(bars)} bars, thickness {bars}px, colour {hx(np.median(sub[hm], axis=0))}')

    # active circle
    acx, acy = lx(cfg['active'][0]), cfg['active'][1]
    def span(vals, c0):
        m = gold(vals) & (vals[:, 0] > 185)
        rs, st = [], None
        for i, v in enumerate(m):
            if v and st is None: st = i
            if (not v) and st is not None: rs.append((st, i - 1)); st = None
        if st is not None: rs.append((st, len(m) - 1))
        thick = [r for r in rs if r[1] - r[0] >= 6]
        if not thick: return None
        return c0 + thick[0][0], c0 + thick[-1][1]
    for _ in range(3):
        sx = span(a[acy, acx - 48:acx + 48], acx - 48)
        sy = span(a[acy - 48:acy + 48, acx], acy - 48)
        if not sx or not sy: break
        L_, R_ = sx; T_, B_ = sy
        acx, acy = (L_ + R_) // 2, (T_ + B_) // 2
    disk = R_ - L_ + 1
    rp = peaks(a[acy, R_ + 3:min(W, R_ + 60)], R_ + 3, prom=15, maxw=4)
    bp = peaks(a[B_ + 3:B_ + 60, acx], B_ + 3, prom=15)
    print(f'ACTIVE: centre ({X(acx)},{acy}); gold disc {disk}x{B_ - T_ + 1}px (x{X(L_)}-{X(R_)}, y{T_}-{B_})')
    print(f'   disc colours: top {hx(a[T_ + 4, acx])} upper-left {hx(a[acy - int(disk * .3), acx - int(disk * .3)])} '
          f'left {hx(a[acy, L_ + 5])} right {hx(a[acy, R_ - 5])} bottom {hx(a[B_ - 4, acx])}')
    ring_x = rp[0][0] if rp else None
    if rp:
        ring = rp[0]
        ringd = 2 * (ring[0] - acx) + 1
        gapc = a[acy, (R_ + ring[0]) // 2]
        ext, c3 = falloff(a, acx, bp[0][0] + bp[0][1] if bp else B_ + 20, 0, 1, railbg)
        print(f'   ring: diameter ~{ringd}px (right x{X(ring[0])}{", bottom y" + str(bp[0][0]) if bp else ""}), width {ring[1]}px {hx(ring[2])}; '
              f'gap disc-ring {ring[0] - R_ - 1}px, gap colour {hx(gapc)}; disc-edge glow +2px {hx(a[acy, R_ + 2])} +6px {hx(a[acy, R_ + 6])}; '
              f'glow outside ring: extent {ext}px colour@3px {hx(c3)} (rail bg {hx(railbg)})')
    dk = a[T_ + 3:B_ - 2, L_ + 3:R_ - 2].sum(axis=-1) < 260
    gb = bbox(dk, L_ + 3, T_ + 3)
    if gb:
        print(f'   glyph: {gb[2] - gb[0] + 1}x{gb[3] - gb[1] + 1}px, centre offset ({(gb[0] + gb[2]) / 2 - acx:+.0f},{(gb[1] + gb[3]) / 2 - acy:+.0f}), '
              f'colour {hx(np.median(a[T_ + 3:B_ - 2, L_ + 3:R_ - 2][dk], axis=0))} (incl. bubble overlap if any)')
    btxt, bb = pill(a, e + 3, acy - 75, L_, acy + 5, None, X)
    if bb:
        print(f'   bubble "30": {btxt}; part left of disc only (bubble continues over the disc); bubble left edge vs disc left edge {bb[0] - L_:+d}px, vs ring left ~{bb[0] - (2 * acx - (ring_x if ring_x else acx)):+d}px, bubble bottom vs disc centre {bb[3] - acy:+d}px')

    prev = acy
    for k, ty in enumerate(cfg['tiles']):
        r = capsule(a, ty, W - 40, (e + 5, e + 70), (W - 36, W - 5), (W - 52, W - 44), railbg, X)
        if r is None:
            print(f'TILE{k + 2}: not found'); continue
        print(f'TILE{k + 2}: {r["txt"]}; pitch {r["cy"] - prev}px')
        prev = r['cy']
        tl = r['left'][0] if r['left'] else e + 30
        tr = r['right'][0] if r['right'] else W - 25
        btxt, bb = pill(a, tl - 35, r['top'] - 10, (tl + tr) // 2 + 15, r['cy'] + 5, None, X)
        if bb:
            print(f'   bubble: {btxt}; offset from tile top-left ({bb[0] - tl:+d},{bb[1] - r["top"]:+d})')
        sub = a[r['top'] + 4:r['bot'] - 3, tl + 4:tr - 3]
        im = light(sub)
        if bb:
            im[:max(0, bb[3] + 3 - (r['top'] + 4)), :max(0, bb[2] + 3 - (tl + 4))] = False
        ib = bbox(im, tl + 4, r['top'] + 4)
        if ib:
            print(f'   icon: {ib[2] - ib[0] + 1}x{ib[3] - ib[1] + 1}px, centre offset from tile centre '
                  f'({(ib[0] + ib[2]) / 2 - (tl + tr) / 2:+.0f},{(ib[1] + ib[3]) / 2 - r["cy"]:+.0f}), colour {hx(np.median(sub[im], axis=0))}')


if __name__ == '__main__':
    open_menu('ref-04-open.png')
    open_menu('flutter-open-1844x853.png')
    rail('ref-05-rail.png', True)
    rail('flutter-closed-1844x853.png', False)
