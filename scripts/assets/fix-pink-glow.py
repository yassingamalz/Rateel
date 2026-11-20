#!/usr/bin/env python3
"""Turn the pink/peach spill left in soft glows (generated on magenta) back into warm gold.
usage: fix-pink-glow.py <file.webp> [...]   (run after key-magenta.py; rule 6.3 is still the better fix)"""
import sys
import numpy as np
from PIL import Image
for f in sys.argv[1:]:
    im = np.asarray(Image.open(f).convert('RGBA')).astype(np.float32)
    rgb = im[..., :3]; r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    ratio = g / np.maximum(r, 1)                      # gold has g/r ≈ 0.76
    bad = (r > g + 25) & (ratio < 0.7) & (b > g * 0.5)
    w = np.clip((0.72 - ratio) / 0.25, 0, 1) * bad
    rgb[..., 1] = g * (1 - w) + r * 0.76 * w
    rgb[..., 2] = b * (1 - w) + r * 0.12 * w
    Image.fromarray(np.dstack([np.clip(rgb, 0, 255), im[..., 3]]).astype(np.uint8), 'RGBA').save(f, quality=92, method=6)
    print('fixed', f)
