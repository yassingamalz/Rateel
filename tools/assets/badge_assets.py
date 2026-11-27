"""Screen 27 assets from the owner (docs/design-assets/badges/) → app_flutter/assets/ui/badges/.
Medals are on flat magenta: same key as leaderboard_assets.py (un-mix only near the key colour).
Two engraving variants: `std` (docs/design-assets/badges/, brown engraving, as the reference) and
`green` (docs/design-assets/badges/dark-green/). The locked medal L1 exists only once.
Every medal is trimmed with the SAME box (union of all) so that medals line up when swapped.
Progress-fill kit (owner, 2026-11-27, 1254 px): `blank_olive` (empty locked medal), `blank_gold` (empty gold medal),
`l1_locked_v2` (locked medal with padlock), `padlock` (cream padlock alone; its keyhole is filled dark, as on the medal).
The three medals share one trim box and the same output size so they line up with each other and with the M01–M12 medals.
Usage: python3 -I tools/assets/badge_assets.py <repo-root>"""
import os
import sys
import numpy as np
from PIL import Image

root = sys.argv[1]
src = root + '/docs/design-assets/badges/'
out = root + '/app_flutter/assets/ui/badges/'
os.makedirs(out + 'green', exist_ok=True)
K = np.array([255, 0, 255], np.float32)
NAMES = ['m01_bidayat_alrihla', 'm02_khatim_alwahda', 'm03_itqan_altilawa', 'm04_khabir_almakharij',
         'm05_qari_mutaqaddim', 'm06_almuwazib', 'm07_mutqin_alghunna', 'm08_muhtarif_alahkam',
         'm09_sawt_jamil', 'm10_mutamayyiz_almuraja', 'm11_almutafawwiq', 'm12_sayyid_altajweed']


def keyed(path):
    rgb = np.asarray(Image.open(path).convert('RGB'), np.float32)
    dist = np.linalg.norm(rgb - K, axis=-1)
    g, b = rgb[..., 1], rgb[..., 2]
    unmix = np.clip(1 - (b - 0.85 * g) / 255.0, 0, 1)
    alpha = np.where(dist < 180, np.minimum(unmix, np.clip((dist - 55) / 70.0, 0, 1)), 1.0)
    a = alpha[..., None]
    col = np.clip(np.where(a > 0.995, rgb, (rgb - (1 - a) * K) / np.maximum(a, 1e-3)), 0, 255)
    return Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA')


jobs = [(src + n + '.png', out + n[:3] + '.webp') for n in NAMES]
jobs += [(src + 'dark-green/' + n + '.png', out + 'green/' + n[:3] + '.webp') for n in NAMES]
# (the old l1_locked.png is superseded by l1_locked_v2, built with the kit below)
ims = [(keyed(s), t) for s, t in jobs]
box = None
for im, _ in ims:
    b = im.getchannel('A').point(lambda v: 255 if v > 8 else 0).getbbox()
    box = b if box is None else (min(box[0], b[0]), min(box[1], b[1]), max(box[2], b[2]), max(box[3], b[3]))
print('common box', box)
for im, t in ims:
    im = im.crop(box)
    im.thumbnail((512, 512), Image.LANCZOS)
    im.save(t, quality=90)
    print(os.path.relpath(t, root), im.size, os.path.getsize(t) // 1024, 'KB')


# ---- progress-fill kit -------------------------------------------------------------------------
kit = {n: keyed(src + n + '.png') for n in ['blank_olive', 'blank_gold', 'l1_locked_v2', 'padlock']}
boxes = [kit[n].getchannel('A').point(lambda v: 255 if v > 8 else 0).getbbox()
         for n in ['blank_olive', 'blank_gold', 'l1_locked_v2']]
kb = (min(b[0] for b in boxes), min(b[1] for b in boxes), max(b[2] for b in boxes), max(b[3] for b in boxes))
print('kit box', kb, 'per image', boxes)
size = (487, 512)  # same size as the M01–M12 outputs: Image.asset(height) lines them up
for n, t in [('blank_olive', 'blank_olive'), ('blank_gold', 'blank_gold'), ('l1_locked_v2', 'l1')]:
    im = kit[n].crop(kb).resize(size, Image.LANCZOS)
    im.save(out + t + '.webp', quality=90)
    print(t, im.size, os.path.getsize(out + t + '.webp') // 1024, 'KB')
# Padlock rectangle on the medal, as fractions of the trimmed medal (from the cream pixels of l1_locked_v2).
a = np.asarray(Image.open(src + 'l1_locked_v2.png').convert('RGB'), np.int32)
cream = (a[..., 0] > 235) & (a[..., 1] > 228) & (a[..., 2] > 190)
cream[:, :400] = False; cream[:, 860:] = False; cream[:300] = False; cream[800:] = False
ys, xs = np.where(cream)
x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
W, H = kb[2] - kb[0], kb[3] - kb[1]
print('padlock rect on the medal: left %.4f top %.4f width %.4f height %.4f' % (
    (x0 - kb[0]) / W, (y0 - kb[1]) / H, (x1 - x0) / W, (y1 - y0) / H))
# Padlocks (closed + open): keyhole (transparent) filled with the medal's dark olive; both trimmed with the SAME box so the
# open one overlays the closed one exactly (the body does not move). Rect on the medal printed for the union box.
locks = {n: np.asarray(keyed(src + n + '.png')).copy() for n in ['padlock', 'padlock_open']}
for n, pl in locks.items():
    h, w = pl.shape[:2]
    win = np.zeros((h, w), bool)
    win[int(h * 0.50):int(h * 0.80), int(w * 0.38):int(w * 0.62)] = True
    pl[win & (pl[..., 3] < 40)] = [58, 77, 36, 255]
lb = [Image.fromarray(v, 'RGBA').getchannel('A').point(lambda t: 255 if t > 8 else 0).getbbox() for v in locks.values()]
ub = (min(b[0] for b in lb), min(b[1] for b in lb), max(b[2] for b in lb), max(b[3] for b in lb))
cb = lb[0]  # closed padlock's own box
r = (x1 - x0) / (cb[2] - cb[0])  # padlock px on the L1 medal per padlock px
ux0 = x0 - (cb[0] - ub[0]) * r; uy0 = y0 - (cb[1] - ub[1]) * r
ux1 = x1 + (ub[2] - cb[2]) * r; uy1 = y1 + (ub[3] - cb[3]) * r
print('lock rect on the medal (union box): left %.4f top %.4f width %.4f height %.4f' % (
    (ux0 - kb[0]) / W, (uy0 - kb[1]) / H, (ux1 - ux0) / W, (uy1 - uy0) / H))
for n, pl in locks.items():
    pim = Image.fromarray(pl, 'RGBA').crop(ub)
    pim.thumbnail((256, 256), Image.LANCZOS)
    pim.save(out + n + '.webp', quality=92)
    print(n, pim.size, 'aspect %.4f' % (pim.size[0] / pim.size[1]))
