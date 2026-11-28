#!/usr/bin/env python3
"""Screen 24 (end of lesson) stars: key the owner's magenta sources into app_flutter/assets/ui/end_of_lesson/.

The earned row has a warm glow that the generator blended with the magenta key; the generic un-mix of
key-magenta.py leaves it pink/red. Here a pixel that still carries magenta (blue > 55) is read as
gold G=(255,192,48) over magenta: alpha = green / 192, colour = gold. Opaque gold (blue low) is kept.
"""
import importlib.util, os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, 'docs/design-assets/end-of-lesson')
OUT = os.path.join(ROOT, 'app_flutter/assets/ui/end_of_lesson')
spec = importlib.util.spec_from_file_location('km', os.path.join(ROOT, 'tools/assets/key-magenta.py'))
km = importlib.util.module_from_spec(spec); spec.loader.exec_module(km)
GOLD = np.array([255, 192, 48], np.float32)


def trim(im):
    bbox = im.getchannel('A').point(lambda v: 255 if v > 8 else 0).getbbox()
    pad = 12
    im = im.crop((max(0, bbox[0] - pad), max(0, bbox[1] - pad), min(im.width, bbox[2] + pad), min(im.height, bbox[3] + pad)))
    im.thumbnail((1024, 1024), Image.LANCZOS)
    return im


def key_gold_glow(img):
    rgb = np.asarray(img.convert('RGB'), np.float32)
    g, b = rgb[..., 1], rgb[..., 2]
    glow = b > 55
    alpha = np.where(glow, np.clip((g - 8) / 192, 0, 1), 1.0)
    dist = np.linalg.norm(rgb - km.KEY, axis=-1)
    alpha = np.minimum(alpha, np.clip((dist - 55) / 70.0, 0, 1))
    col = np.where(glow[..., None], GOLD, rgb)
    # cream highlights inside the stars (white-ish, blue high but green high too) stay as they are
    cream = (g > 215) & (rgb[..., 0] > 235)
    col = np.where(cream[..., None], rgb, col)
    alpha = np.where(cream, 1.0, alpha)
    return trim(Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA'))


def main():
    os.makedirs(OUT, exist_ok=True)
    key_gold_glow(Image.open(f'{SRC}/s1_stars_row_earned.webp')).save(f'{OUT}/stars_row_earned.webp', quality=92, method=6)
    km.key_magenta(Image.open(f'{SRC}/s3_stars_row_empty.webp')).save(f'{OUT}/stars_row_empty.webp', quality=92, method=6)
    pair = Image.open(f'{SRC}/s2_star_earned_and_empty.webp')
    w, h = pair.size
    km.key_magenta(pair.crop((0, 0, w // 2, h))).save(f'{OUT}/star_earned.webp', quality=92, method=6)
    km.key_magenta(pair.crop((w // 2, 0, w, h))).save(f'{OUT}/star_empty.webp', quality=92, method=6)
    for f in sorted(os.listdir(OUT)):
        print(f, Image.open(os.path.join(OUT, f)).size)


if __name__ == '__main__':
    main()
