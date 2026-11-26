"""Put the sound back into the screen 22 demo video (Playwright records no audio).

Usage: python3 tools/flutter-review/listening-demo-audio.py <outdir> <out.mp4>
Reads <outdir>/vid-22/*.webm and <outdir>/audio-events.json (from listening-demo.js, `?logAudio=1`): the position
samples of the verse player become played segments (file, from, to, at); the effect sounds are placed at their time.
"""
import glob
import json
import subprocess
import sys

d, out = sys.argv[1], sys.argv[2]
A = 'app_flutter/assets/'
ev = json.load(open(f'{d}/audio-events.json'))
segs, sfx, cur = [], [], None
for t, e in ev:
    k = e.split(' ')
    if k[0] == 'sfx':
        sfx.append((t, f'{A}sounds/{k[1]}.mp3'))
        continue
    f, ms = k[1], int(k[2])
    if cur and cur['f'] == f and 0 <= ms - cur['to'] <= (t - cur['tl']) + 400 and ms > cur['to'] - 50:
        if ms > cur['to']:
            cur['to'], cur['tl'] = ms, t
        continue
    if cur and cur['f'] == f and ms == cur['to']:
        continue
    cur = {'f': f, 'from': ms, 'to': ms, 'at': t, 'tl': t}
    segs.append(cur)
segs = [s for s in segs if s['to'] - s['from'] > 150]
for s in segs:
    print(f"{s['at']/1000:6.2f}s  {s['f'].split('/')[-1]}  {s['from']}→{s['to']} ms")
for t, f in sfx:
    print(f'{t/1000:6.2f}s  {f}')
video = glob.glob(f'{d}/vid-22/*.webm')[0]
inputs, filt, labels = ['-i', video], [], []
n = 1
for s in segs:
    inputs += ['-i', A + s['f']]
    dur = (s['to'] - s['from'] + 220) / 1000
    filt.append(f"[{n}:a]atrim=start={s['from']/1000}:duration={dur},asetpts=PTS-STARTPTS,"
                f"afade=t=out:st={max(0, dur-0.08)}:d=0.08,adelay={s['at']}|{s['at']}[a{n}]")
    labels.append(f'[a{n}]'); n += 1
for t, f in sfx:
    inputs += ['-i', f]
    filt.append(f'[{n}:a]volume=0.6,adelay={t}|{t}[a{n}]'); labels.append(f'[a{n}]'); n += 1
filt.append(''.join(labels) + f'amix=inputs={len(labels)}:normalize=0[aout]')
subprocess.run(['ffmpeg', '-v', 'error', '-y', *inputs, '-filter_complex', ';'.join(filt), '-map', '0:v', '-map', '[aout]',
                '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '24', '-profile:v', 'high', '-level', '4.1',
                '-c:a', 'aac', '-b:a', '128k', '-ac', '2', '-ar', '44100', '-movflags', '+faststart', '-shortest', out], check=True)
print('ok', out)
