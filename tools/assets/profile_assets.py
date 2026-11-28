"""Screen 29 assets from the owner (Rateel_Assets_Complete.zip, 2026-11-28; sources in docs/design-assets/profile/)
→ the common library in app_flutter/assets/ui/ (owner: «metti anche tutto nella libreria comune»).
Magenta key: same un-mix as badge_assets.py. Full-bleed art (Quran in the mihrab, dark / light) is copied as is.
Also darkens the yellow background of the leaderboard avatars app-wide (owner, 2026-11-28: critic v1, reference
#E7AF03 vs #FCC300). Usage: python3 -I tools/assets/profile_assets.py <repo-root>"""
import os
import sys
import numpy as np
from PIL import Image

root = sys.argv[1]
src = root + '/docs/design-assets/profile/'
ui = root + '/app_flutter/assets/ui/'
K = np.array([255, 0, 255], np.float32)


def keyed(path, trim=True):
    rgb = np.asarray(Image.open(path).convert('RGB'), np.float32)
    dist = np.linalg.norm(rgb - K, axis=-1)
    g, b = rgb[..., 1], rgb[..., 2]
    unmix = np.clip(1 - (b - 0.85 * g) / 255.0, 0, 1)
    alpha = np.where(dist < 180, np.minimum(unmix, np.clip((dist - 55) / 70.0, 0, 1)), 1.0)
    a = alpha[..., None]
    col = np.clip(np.where(a > 0.995, rgb, (rgb - (1 - a) * K) / np.maximum(a, 1e-3)), 0, 255)
    im = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA')
    if trim:
        box = im.getchannel('A').point(lambda v: 255 if v > 8 else 0).getbbox()
        im = im.crop(box)
    return im


def save(im, target, longest=1024):
    im = im.copy()
    im.thumbnail((longest, longest), Image.LANCZOS)
    os.makedirs(os.path.dirname(target), exist_ok=True)
    im.save(target, quality=92, method=6)
    print(os.path.relpath(target, root), im.size)


# Keyed objects (transparent, trimmed).
for name, target, longest in [
    ('01_quran_rehal.png', 'icons/quran_rehal_gold.webp', 1024),
    ('02_quran_rehal_glow.png', 'icons/quran_rehal_gold_glow.webp', 1024),
    ('05_award_rosette.png', 'glyphs/rank_rosette.webp', 512),
    ('06_open_book_white.png', 'glyphs/open_book.webp', 512),
    ('07_stacked_layers_gold.png', 'glyphs/layers.webp', 512),
    ('10_streak_flame.png', 'icons/flame_gold_04.webp', 512),
    ('09_mosque_skyline_light.png', 'decor/mosque_light.webp', 900),
    ('12_mosque_dark_magenta.png', 'decor/mosque_v2_dark.webp', 900),
    ('13_mosque_light_magenta.png', 'decor/mosque_v2_light.webp', 900),
]:
    save(keyed(src + name), ui + target, longest)

# Seamless lattice tile: keyed but NOT trimmed (the tile must keep its period).
save(keyed(src + '08_islamic_lattice.png', trim=False), ui + 'decor/lattice_star_tile.webp', 512)

# Full-bleed art: the Quran in the glowing mihrab, on the card colour (dark) / cream (light).
for name, target in [('04_quran_mihrab_dark.png', 'decor/quran_mihrab_dark.webp'),
                     ('03_quran_mihrab_light.png', 'decor/quran_mihrab_light.webp')]:
    save(Image.open(src + name).convert('RGB'), ui + target, 1024)

# Avatar ring (owner, 2026-11-28, 16_avatar_ring_magenta.png): yellow light over magenta; the green channel comes
# only from the ring and its glow, so it gives the opacity; the glow takes one warm yellow (no magenta spill).
rgb = np.asarray(Image.open(src + '16_avatar_ring_magenta.png').convert('RGB'), np.float32)
alpha = np.clip((rgb[..., 1] - 12) / 205.0, 0, 1)
col = np.where(alpha[..., None] > 0.9, rgb, np.array([255, 222, 70], np.float32))
ring = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA').crop((280, 37, 1228, 977))
save(ring, ui + 'decor/avatar_ring_gold.webp', 768)
# 14/15 (Quran in the mihrab) and 17 (ring) came with a checkerboard painted in the image (no alpha): not usable,
# kept as sources only; 03/04 (full-bleed) are used for the Quran art.

# Avatars: yellow background #FCC300 → #E7AF03, anti-aliased edges follow by colour distance.
Y = np.array([252, 195, 0], np.float32)
T = np.array([231, 175, 3], np.float32)
for n in range(1, 11):
    p = ui + f'leaderboard/avatar_{n}.webp'  # run once: it darkens again on every run
    a = np.asarray(Image.open(p).convert('RGBA'), np.float32)
    rgb = a[..., :3]
    w = np.clip(1 - np.linalg.norm(rgb - Y, axis=-1) / 90.0, 0, 1)[..., None]
    a[..., :3] = np.clip(rgb + w * (T - Y), 0, 255)
    Image.fromarray(a.astype(np.uint8), 'RGBA').save(p, quality=92, method=6)
    print(os.path.relpath(p, root), 'yellow darkened')
