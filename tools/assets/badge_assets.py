"""Screen 27 assets from the owner (docs/design-assets/badges/) → app_flutter/assets/ui/badges/.
Medals are on flat magenta: same key as leaderboard_assets.py (un-mix only near the key colour).
Two engraving variants: `std` (docs/design-assets/badges/, brown engraving, as the reference) and
`green` (docs/design-assets/badges/dark-green/). The locked medal L1 exists only once.
Every medal is trimmed with the SAME box (union of all) so that medals line up when swapped.
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
jobs += [(src + 'l1_locked.png', out + 'l1.webp')]
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
