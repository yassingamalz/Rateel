#!/usr/bin/env python3
"""Owner's icon collection (2026-11-25): magenta-keyed flat icons -> app copies.

usage: icon_collection.py <src-dir-with-pngs>
Sources (lossless) -> docs/design-assets/icon-collection/, app copies (512 px, webp) -> app_flutter/assets/ui/icons/.
Flat icons with hard edges: alpha from the distance to magenta only (key-magenta.py's blue/green model tints cream
towards green), colour un-mixed from the key only on the anti-aliased edge.
"""
import os, sys
import numpy as np
from PIL import Image

KEY = np.array([255, 0, 255], np.float32)


def key(img):
    rgb = np.asarray(img.convert('RGB'), np.float32)
    dist = np.linalg.norm(rgb - KEY, axis=-1)
    a = np.clip((dist - 60) / 150.0, 0, 1)[..., None]
    col = (rgb - (1 - a) * KEY) / np.maximum(a, 1e-3)
    col = np.clip(np.where(a > 0.98, rgb, col), 0, 255)
    im = Image.fromarray(np.dstack([col, a[..., 0] * 255]).astype(np.uint8), 'RGBA')
    bbox = im.getchannel('A').point(lambda v: 255 if v > 8 else 0).getbbox()
    pad = 8
    im = im.crop((max(0, bbox[0] - pad), max(0, bbox[1] - pad), min(im.width, bbox[2] + pad), min(im.height, bbox[3] + pad)))
    im.thumbnail((512, 512), Image.LANCZOS)
    return im


src = sys.argv[1]
for f in sorted(os.listdir(src)):
    if not f.endswith('.png'):
        continue
    im = Image.open(os.path.join(src, f))
    im.save(f'docs/design-assets/icon-collection/{f[:-4]}.webp', lossless=True, method=6)
    key(im).save(f'app_flutter/assets/ui/icons/{f[:-4]}.webp', quality=92, method=6)
    print(f)
