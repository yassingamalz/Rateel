#!/usr/bin/env python3
"""Rateel corner ornament: a Moroccan trellis of lobed four-point cells filling the
top-left triangle of the canvas (drawn by Claude on the owner's request, 2026-11-21,
to match the corners of reference 03).

Each cell: four pointed tips on the axes, four rounded lobes on the diagonals, tips
touching their neighbours. Gold line with a dark offset line under it (carved look);
cells get brighter towards the diagonal edge of the triangle, as in the reference.

Usage: python3 -I corner_trellis.py OUT.svg [cell_half_size] [canvas] [mirror]
  mirror = "right" draws the top-right corner (mirrored horizontally).
"""
import math, sys

out = sys.argv[1]
h = float(sys.argv[2]) if len(sys.argv) > 2 else 120.0   # cell half size
N = float(sys.argv[3]) if len(sys.argv) > 3 else 1000.0  # canvas size
mirror = len(sys.argv) > 4 and sys.argv[4] == "right"


def cell(cx, cy):
    # one quarter (top tip -> right tip), rotated 4 times
    q = [((0.06, -0.86), (0.16, -0.80), (0.28, -0.80)),   # concave flank to the lobe
         ((0.64, -0.92), (0.92, -0.64), (0.80, -0.28)),   # rounded diagonal lobe
         ((0.80, -0.16), (0.86, -0.06), (1.00, 0.00))]    # concave flank to the next tip
    d = f"M {cx:.1f} {cy - h:.1f}"
    for k in range(4):
        c, s = math.cos(k * math.pi / 2), math.sin(k * math.pi / 2)
        for seg in q:
            pts = []
            for x, y in seg:
                rx, ry = x * c - y * s, x * s + y * c
                pts.append(f"{cx + rx * h:.1f} {cy + ry * h:.1f}")
            d += " C " + ", ".join(pts)
    return d + " Z"


paths_dark, paths_gold, fills = [], [], []
step = 2 * h  # tips touch
i = 0
y = 0.0
while y < N + h:
    x = 0.0  # orthogonal grid, tips touching left/right and up/down
    while x < N + h:
        # keep whole cells whose centre lies inside the triangle x + y < N
        edge = (x + y) / N
        if edge < 0.98:
            a = 0.15 + 0.85 * max(0.0, (edge - 0.2) / 0.78) ** 1.8  # brighter near the diagonal
            d = cell(x, y)
            fills.append(f'<path d="{d}" fill-opacity="{0.10 + 0.12 * a:.2f}"/>')
            paths_dark.append(f'<path d="{d}" stroke-opacity="{0.55 * a:.2f}"/>')
            paths_gold.append(f'<path d="{d}" stroke-opacity="{a:.2f}"/>')
        x += step
    y += step
    i += 1

svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {N:.0f} {N:.0f}">
<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
<stop offset="0" stop-color="#C9A44A"/><stop offset="1" stop-color="#E8C25A"/></linearGradient></defs>
<g transform="{'translate(%.0f 0) scale(-1 1)' % N if mirror else ''}">
<g fill="#00150E" stroke="none">
{chr(10).join(fills)}
</g>
<g fill="none" stroke="#00150E" stroke-width="{h * 0.11:.1f}" stroke-linejoin="round" transform="translate({h * 0.05:.1f} {h * 0.07:.1f})">
{chr(10).join(paths_dark)}
</g>
<g fill="none" stroke="url(#g)" stroke-width="{h * 0.06:.1f}" stroke-linejoin="round">
{chr(10).join(paths_gold)}
</g>
</g>
</svg>
'''
open(out, "w").write(svg)
print(out, len(paths_gold), "cells")
