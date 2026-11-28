#!/usr/bin/env python3
"""Screen 31 comparison sheet: reference (left) | Flutter desktop 1844x853 (middle) | phone 915x412 (right).

usage: practice-compare.py <capdir> <tag> <out.jpg>
"""
import sys
from PIL import Image, ImageDraw, ImageFont

cap, tag, out = sys.argv[1:4]
R = 'docs/flutter/screens/31-daily-practice/'
F = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 26)
rows = []
for st, ref in [('a', 'a-practice'), ('b', 'b-reminder')]:
    for th in ['dark', 'light']:
        imgs = [Image.open(f'{R}reference-{ref}-{th}.webp').convert('RGB'),
                Image.open(f'{cap}/capture-{tag}-{st}-{th}.png').convert('RGB'),
                Image.open(f'{cap}/capture-{tag}-{st}-{th}-phone.png').convert('RGB')]
        h = 600
        imgs = [i.resize((int(i.width * h / i.height), h), Image.LANCZOS) for i in imgs]
        w = sum(i.width for i in imgs) + 40
        row = Image.new('RGB', (w, h + 44), (255, 255, 255))
        d = ImageDraw.Draw(row)
        x = 0
        for lab, i in zip([f'31-{st.upper()} {th}: reference', 'Flutter 1844x853', 'phone 915x412'], imgs):
            d.text((x + 6, 6), lab, fill=(150, 0, 0), font=F)
            row.paste(i, (x, 44))
            x += i.width + 20
        rows.append(row)
W = max(r.width for r in rows)
sheet = Image.new('RGB', (W, sum(r.height for r in rows)), (255, 255, 255))
y = 0
for r in rows:
    sheet.paste(r, (0, y))
    y += r.height
sheet.save(out, quality=82)
print(out, sheet.size)
