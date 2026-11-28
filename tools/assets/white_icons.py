#!/usr/bin/env python3
"""Owner's white (cream) line icons, 2026-11-28 (zip rateel_white_icons): sources + app copies.

usage: white_icons.py <unzipped-dir>   (the dir has transparent/, magenta/, preview.png)
Sources: docs/design-assets/icons-white/{transparent,magenta}/<name>.webp (lossless) + preview.webp.
App copies: app_flutter/assets/ui/icons_white/<name>.webp, from transparent/ (clean alpha, cream edge),
trimmed (alpha > 8, pad 8 px), longest side 512 px, webp q92. Numbered files (01_stopwatch…) and unnumbered
ones (stopwatch…) are two framings of the same drawings: both are kept.
"""
import os, sys
from PIL import Image

src = sys.argv[1]
dst_src = 'docs/design-assets/icons-white'
dst_app = 'app_flutter/assets/ui/icons_white'
for sub in ('transparent', 'magenta'):
    os.makedirs(f'{dst_src}/{sub}', exist_ok=True)
os.makedirs(dst_app, exist_ok=True)
Image.open(f'{src}/preview.png').save(f'{dst_src}/preview.webp', quality=90)
for sub in ('transparent', 'magenta'):
    for f in sorted(os.listdir(f'{src}/{sub}')):
        if f.endswith('.png'):
            Image.open(f'{src}/{sub}/{f}').save(f'{dst_src}/{sub}/{f[:-4]}.webp', lossless=True, method=6)
for f in sorted(os.listdir(f'{src}/transparent')):
    if not f.endswith('.png'):
        continue
    im = Image.open(f'{src}/transparent/{f}').convert('RGBA')
    b = im.getchannel('A').point(lambda v: 255 if v > 8 else 0).getbbox()
    pad = 8
    im = im.crop((max(0, b[0] - pad), max(0, b[1] - pad), min(im.width, b[2] + pad), min(im.height, b[3] + pad)))
    im.thumbnail((512, 512), Image.LANCZOS)
    im.save(f'{dst_app}/{f[:-4]}.webp', quality=92, method=6)
    print(f, im.size)
