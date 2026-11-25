"""Screen 08 assets from the owner (docs/design-assets/reading-lesson/, on magenta) → app_flutter/assets/ui/reading/.
R1 lattice: seamless 2×2-cell tile cut at one period (313.5 px, measured by autocorrelation), gold line alpha from the
green channel (magenta has none) and the dark carved offset from the darkness of red/blue, as the 07 corners.
R2 badge: split into the gold line and the emerald fill (two layers, tinted per theme in code).
Usage: python3 -I tools/assets/reading_lesson_assets.py <repo-root>"""
import sys
import numpy as np
from scipy import ndimage
from PIL import Image

root = sys.argv[1]
src = root + '/docs/design-assets/reading-lesson/'
out = root + '/app_flutter/assets/ui/reading/'


def lattice():
    rgb = np.asarray(Image.open(src + '01_moroccan_gold_lattice.png').convert('RGB'), np.float32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    a_gold = np.clip(g / 170.0, 0, 1)
    gc = np.where(a_gold > 0.995, g, 170.0)
    gold = np.dstack([np.clip(gc * 1.18, 0, 255), gc, gc * 0.36])
    a_dark = np.clip((235 - np.maximum(r, b)) / 200.0, 0, 1) * (g < 60)
    use_gold = (a_gold >= a_dark)[..., None]
    col = np.where(use_gold, gold, np.zeros_like(rgb) + np.array([6, 18, 10], np.float32))
    alpha = np.where(use_gold[..., 0], a_gold, a_dark)
    alpha = np.where(alpha < 0.07, 0, alpha)
    im = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA')
    p = 1254 / 4
    x0 = round(p)
    tile = im.crop((x0, x0, x0 + round(2 * p), x0 + round(2 * p))).resize((512, 512), Image.LANCZOS)
    tile.save(out + 'lattice_tile.webp', quality=92)
    a = np.asarray(tile, np.float32)[..., 3]
    print('lattice_tile.webp', tile.size, 'seam x', float(np.abs(a[:, 0] - a[:, -1]).mean()),
          'seam y', float(np.abs(a[0] - a[-1]).mean()))


def badge():
    rgb = np.asarray(Image.open(src + '02_emerald_gold_badge.png').convert('RGB'), np.float32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    magenta = (r > 200) & (b > 200) & (g < 80)
    goldish = (~magenta) & (r > 120) & (r > b + 40)
    fill = (~magenta) & (~goldish)
    # Soft edges: the line's alpha from the green channel against magenta (0) at the outer border.
    a_line = np.where(goldish, 1.0, 0.0)
    a_line = np.maximum(a_line, np.where(~fill & ~magenta, np.clip(g / 180.0, 0, 1), 0))
    line = Image.fromarray(np.dstack([rgb, a_line * 255]).astype(np.uint8), 'RGBA')
    # Fill = the inside of the line (holes of the line mask), one flat emerald from the image (no shadow ring, no
    # magenta fringe); a 2 px overlap under the line avoids a seam.
    inside = ndimage.binary_fill_holes(goldish) & ~goldish
    emerald = np.median(rgb[inside & fill], axis=0)
    inside = ndimage.binary_dilation(inside, iterations=2) & ndimage.binary_fill_holes(goldish)
    fill_rgb = np.zeros_like(rgb) + emerald
    fill_im = Image.fromarray(np.dstack([fill_rgb, inside * 255.0]).astype(np.uint8), 'RGBA')
    print('emerald', emerald)
    bb = line.getchannel('A').point(lambda v: 255 if v > 60 else 0).getbbox()
    for im, name in [(line, 'badge_line.webp'), (fill_im, 'badge_fill.webp')]:
        im = im.crop(bb)
        im.thumbnail((256, 256), Image.LANCZOS)
        im.save(out + name, quality=92)
        print(name, im.size)


lattice()
badge()
