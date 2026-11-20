#!/usr/bin/env python3
"""Frame sheets for the video critic (rule 5.6): one sheet per step, with timestamps.

usage: critic-frames.py <video.mp4> <media.json> <out-dir> [narration-folder-name]

Step boundaries come from the narration clips in media.json (one per step). For each step the sheet
shows 8 frames: the transition in (+0.1, +0.3, +0.6 s), 25/50/75 % of the step, and the last second.
Also writes overview.png (one frame per step). The critic reads the sheets next to the design screens
docs/design/glassy-gamified/screens/15–21 and the rulebook, and lists what to fix.
"""
import json, os, subprocess, sys
from PIL import Image, ImageDraw

video, media_path, out = sys.argv[1:4]
folder = sys.argv[4] if len(sys.argv) > 4 else None
os.makedirs(out, exist_ok=True)
d = json.load(open(media_path))
t0 = d['t0']
dur = float(subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', video],
                           capture_output=True, text=True).stdout)
narr = [m for m in d['media'] if '/guided/' in m['src'] and '/common' not in m['src']
        and (folder is None or f'/{folder}/' in m['src'])]
starts = [(m['at'] - t0) / 1000 - 0.6 for m in narr] + [dur]
names = [os.path.basename(m['src'])[:-4] for m in narr]
W, H = 560, 259

def frame(t):
    raw = subprocess.run(['ffmpeg', '-loglevel', 'error', '-ss', f'{max(0, t):.2f}', '-i', video, '-frames:v', '1',
                          '-vf', f'scale={W}:{H}', '-f', 'image2pipe', '-vcodec', 'png', '-'], capture_output=True).stdout
    from io import BytesIO
    return Image.open(BytesIO(raw)).convert('RGB')

over = Image.new('RGB', (W * 4, (H + 22) * ((len(names) + 3) // 4)), (20, 20, 20))
for k, name in enumerate(names):
    a, b = starts[k], starts[k + 1]
    ts = [a + 0.1, a + 0.3, a + 0.6, a + (b - a) * 0.25, a + (b - a) * 0.5, a + (b - a) * 0.75, b - 1.0, b - 0.2]
    sheet = Image.new('RGB', (W * 4, (H + 22) * 2), (20, 20, 20))
    for i, t in enumerate(ts):
        im = frame(t)
        x, y = (i % 4) * W, (i // 4) * (H + 22)
        sheet.paste(im, (x, y + 22))
        ImageDraw.Draw(sheet).text((x + 6, y + 4), f'{name}  t={t:.1f}s', fill=(255, 220, 90))
    sheet.save(f'{out}/{k + 1:02d}-{name}.png')
    im = frame(a + (b - a) * 0.8)
    x, y = (k % 4) * W, (k // 4) * (H + 22)
    over.paste(im, (x, y + 22))
    ImageDraw.Draw(over).text((x + 6, y + 4), f'{k + 1}. {name}', fill=(255, 220, 90))
over.save(f'{out}/overview.png')
print('sheets:', len(names), '->', out)
