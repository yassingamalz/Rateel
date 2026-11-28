#!/usr/bin/env python3
"""Screen 31 assets from the owner (2026-11-28): magenta-keyed flat icons -> common library.

usage: practice_assets.py <calendar.webp> <headphones_pair.webp>
Sources (lossless) -> docs/design-assets/daily-practice/assets/, app copies (512 px webp):
  icons/calendar_cream.webp (A2, tinted gold in code), icons_white/headphones_{cream,brown}.webp (pair split in halves).
Same key as icon_collection.py (alpha from the distance to magenta, colour un-mixed on the edge only).
"""
import sys
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


SRC = 'docs/design-assets/daily-practice/assets/'
cal = Image.open(sys.argv[1]).convert('RGB')
cal.save(SRC + 'a2_calendar_magenta.webp', lossless=True, method=6)
key(cal).save('app_flutter/assets/ui/icons/calendar_cream.webp', quality=92, method=6)
pair = Image.open(sys.argv[2]).convert('RGB')
pair.save(SRC + 'headphones_cream_brown_magenta.webp', lossless=True, method=6)
w = pair.width // 2
key(pair.crop((0, 0, w, pair.height))).save('app_flutter/assets/ui/icons_white/headphones_cream.webp', quality=92, method=6)
key(pair.crop((w, 0, pair.width, pair.height))).save('app_flutter/assets/ui/icons_white/headphones_brown.webp', quality=92, method=6)
print('ok')
