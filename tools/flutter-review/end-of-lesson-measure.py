#!/usr/bin/env python3
"""Screen 24: element boxes of reference vs app (dark, 1844x853).
usage: end-of-lesson-measure.py <reference.webp> <capture.png>"""
import sys
import numpy as np
from PIL import Image


def load(p):
    return np.asarray(Image.open(p).convert('RGB').resize((1844, 853))).astype(int)


def card(im):
    y = 450
    lum = im[y].sum(1)
    l = next(x for x in range(380, 600) if lum[x] > 350)
    r = next(x for x in range(1480, 1300, -1) if lum[x] > 350)
    col = im[:, 700].sum(1)
    t = next(yy for yy in range(150, 300) if col[yy] > 350)
    b = next(yy for yy in range(800, 650, -1) if col[yy] > 350)
    return l, r, t, b


def bbox(mask, ox, oy):
    ys, xs = np.where(mask)
    if len(xs) == 0:
        return None
    return (int(xs.min() + ox), int(xs.max() + ox), int(ys.min() + oy), int(ys.max() + oy))


def elements(im):
    l, r, t, b = card(im)
    l, r, t, b = l + 10, r - 10, t + 10, b - 10
    c = im[t:b, l:r]
    out = {'card': (l, r, t, b)}
    gold = (c[..., 0] > 200) & (c[..., 1] > 150) & (c[..., 2] < 100)
    out['stars'] = bbox(gold[:int(0.25 * c.shape[0])], l, t)
    cream = (c.sum(2) > 600) & (c[..., 2] > 150)
    band = cream[int(0.22 * c.shape[0]):int(0.40 * c.shape[0])]
    out['title'] = bbox(band, l, t + int(0.22 * c.shape[0]))
    # divider: gold row band between title and tiles
    div = gold[int(0.38 * c.shape[0]):int(0.47 * c.shape[0])]
    out['divider'] = bbox(div, l, t + int(0.38 * c.shape[0]))
    # tiles: rows/cols with bright rim inside 0.45..0.75 height
    sub = c[int(0.45 * c.shape[0]):int(0.75 * c.shape[0])]
    rim = (sub[..., 0] > 150) & (sub[..., 1] > 140) & (sub[..., 2] < 140)
    cols = rim.sum(0) > sub.shape[0] * 0.35
    xs = np.where(cols)[0]
    runs = []
    for x in xs:
        if runs and x - runs[-1][-1] <= 3:
            runs[-1].append(x)
        else:
            runs.append([x])
    out['tile_vertical_rims_x'] = [int(rr[0] + l) for rr in runs]
    rows = rim.sum(1) > 120
    ys = np.where(rows)[0]
    out['tile_rims_y'] = [int(ys.min() + t + int(0.45 * c.shape[0])), int(ys.max() + t + int(0.45 * c.shape[0]))] if len(ys) else None
    # buttons: bright rim rows in 0.75..0.98
    sub = c[int(0.74 * c.shape[0]):int(0.985 * c.shape[0])]
    br = sub.sum(2) > 330
    rows = br.sum(1) > 150
    ys = np.where(rows)[0]
    out['buttons_y'] = [int(ys.min() + t + int(0.74 * c.shape[0])), int(ys.max() + t + int(0.74 * c.shape[0]))] if len(ys) else None
    cols = br.sum(0) > 8
    xs = np.where(cols)[0]
    runs = []
    for x in xs:
        if runs and x - runs[-1][-1] <= 12:
            runs[-1].append(x)
        else:
            runs.append([x])
    out['buttons_x'] = [(int(rr[0] + l), int(rr[-1] + l)) for rr in runs if len(rr) > 40]
    return out


ref, app = load(sys.argv[1]), load(sys.argv[2])
er, ea = elements(ref), elements(app)
for k in er:
    print(f'{k:22s} ref {er[k]}\n{"":22s} app {ea[k]}')
