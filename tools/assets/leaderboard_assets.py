"""Screen 11 assets from the owner (docs/design-assets/leaderboard/) → app_flutter/assets/ui/leaderboard/.
Magenta key: un-mix only near the key colour (dist < 180), so silver keeps full opacity
(the lesson-production key-magenta.py makes bluish-grey semi-transparent). Lattice: gold lines on
black → alpha from brightness. Usage: python3 -I tools/assets/leaderboard_assets.py <repo-root>"""
import sys
import numpy as np
from PIL import Image

root = sys.argv[1]
src = root + '/docs/design-assets/leaderboard/'
out = root + '/app_flutter/assets/ui/leaderboard/'
K = np.array([255, 0, 255], np.float32)


def key(name, target, longest, darken_green=0.0):
    rgb = np.asarray(Image.open(src + name).convert('RGB'), np.float32)
    if darken_green:
        # Darken the emerald band only (green-dominant pixels), keep the gold rims
        # (critic v1 A9: band #055120 vs reference #012418).
        r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
        green = np.clip((g - r - 20) / 30.0, 0, 1) * (np.linalg.norm(rgb - K, axis=-1) > 180)
        rgb = rgb * (1 - darken_green * green)[..., None]
    dist = np.linalg.norm(rgb - K, axis=-1)
    g, b = rgb[..., 1], rgb[..., 2]
    unmix = np.clip(1 - (b - 0.85 * g) / 255.0, 0, 1)
    alpha = np.where(dist < 180, np.minimum(unmix, np.clip((dist - 55) / 70.0, 0, 1)), 1.0)
    a = alpha[..., None]
    col = np.clip(np.where(a > 0.995, rgb, (rgb - (1 - a) * K) / np.maximum(a, 1e-3)), 0, 255)
    im = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA')
    im = im.crop(im.getchannel('A').point(lambda v: 255 if v > 8 else 0).getbbox())
    im.thumbnail((longest, longest), Image.LANCZOS)
    im.save(out + target, quality=92)
    print(target, im.size)


def lattice(name, target, size):
    rgb = np.asarray(Image.open(src + name).convert('RGB'), np.float32)
    alpha = np.clip(rgb.max(axis=-1) / 255.0 * 1.25, 0, 1)
    col = np.clip(rgb / np.maximum(alpha[..., None], 1e-3), 0, 255)
    im = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA')
    im = im.resize((size, size), Image.LANCZOS)
    im.save(out + target, quality=92)
    print(target, im.size)


key('ribbon_emerald_gold_02.png', 'ribbon.webp', 1400, darken_green=0.5)
key('coins_gold.png', 'coins_gold.webp', 256)
key('coins_silver.png', 'coins_silver.webp', 256)
key('coins_bronze.png', 'coins_bronze.webp', 256)
key('book_gold.png', 'book.webp', 160)
lattice('moroccan_ogee_lattice.png', 'lattice.webp', 512)
