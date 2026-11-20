#!/usr/bin/env python3
"""Turn generated assets on a flat magenta (#FF00FF) background into trimmed,
transparent PNGs, removing the magenta spill on anti-aliased edges.

usage: key-magenta.py <mapping.csv> <src-dir> <out-dir>
mapping.csv columns: source,target,mode   (mode: key | copy)
  key  -> magenta removed, trimmed, longest side capped at 1024 px, PNG
  copy -> full-bleed image (backgrounds), re-encoded as high-quality JPG
"""
import csv, os, sys
import numpy as np
from PIL import Image

KEY = np.array([255, 0, 255], dtype=np.float32)


def key_magenta(img: Image.Image) -> Image.Image:
    """Un-mix the magenta key from every pixel.

    Model: pixel = a*F + (1-a)*K with K = magenta. Our palette (gold, cream, emerald)
    never has more blue than green, so we assume F_blue = k*F_green (k = 0.85, cream-like),
    which gives a = 1 - (P_blue - k*P_green)/255. Soft glows that the generator blended
    with magenta become semi-transparent warm light instead of pink.
    """
    rgb = np.asarray(img.convert('RGB'), dtype=np.float32)
    g, b = rgb[..., 1], rgb[..., 2]
    k = 0.85
    alpha = np.clip(1 - (b - k * g) / 255.0, 0, 1)
    # anything close to the key colour is background (generated magenta is not perfectly flat)
    dist = np.linalg.norm(rgb - KEY, axis=-1)
    alpha = np.minimum(alpha, np.clip((dist - 55) / 70.0, 0, 1))
    a = alpha[..., None]
    col = (rgb - (1 - a) * KEY) / np.maximum(a, 1e-3)
    col = np.clip(np.where(a > 0.995, rgb, col), 0, 255)
    out = np.dstack([col, alpha * 255]).astype(np.uint8)
    im = Image.fromarray(out, 'RGBA')
    bbox = im.getchannel('A').point(lambda v: 255 if v > 8 else 0).getbbox()
    if bbox:
        pad = 12
        bbox = (max(0, bbox[0] - pad), max(0, bbox[1] - pad), min(im.width, bbox[2] + pad), min(im.height, bbox[3] + pad))
        im = im.crop(bbox)
    im.thumbnail((1024, 1024), Image.LANCZOS)
    return im


def main(mapping, src, out):
    os.makedirs(out, exist_ok=True)
    for row in csv.DictReader(open(mapping)):
        s = os.path.join(src, row['source'])
        t = os.path.join(out, row['target'])
        os.makedirs(os.path.dirname(t), exist_ok=True)
        img = Image.open(s)
        if row['mode'] == 'key':
            key_magenta(img).save(t, optimize=True)
        else:
            img.convert('RGB').save(t, quality=90, optimize=True)
        print(row['target'], Image.open(t).size)


if __name__ == '__main__':
    main(*sys.argv[1:4])
