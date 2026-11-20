import json, subprocess, sys
from urllib.parse import urlparse, unquote

ROOT = '/home/user/Rateel/dist/rateel/browser'
d = json.load(open(sys.argv[2] if len(sys.argv) > 2 else 'media.json'))
t0 = d['t0']
inputs, filters, labels = [], [], []
for i, m in enumerate(d['media']):
    path = ROOT + unquote(urlparse(m['src']).path)
    dur = max(0.05, (m['end'] - m['at']) / 1000)
    delay = max(0, m['at'] - t0)
    inputs += ['-i', path]
    filters.append(f"[{i+1}:a]atrim=start={m['from']:.3f}:duration={dur:.3f},asetpts=PTS-STARTPTS,"
                   f"aresample=48000,aformat=channel_layouts=stereo,adelay={delay}|{delay}[a{i}]")
    labels.append(f'[a{i}]')
filt = ';'.join(filters) + ';' + ''.join(labels) + f"amix=inputs={len(labels)}:normalize=0:dropout_transition=0,alimiter=limit=0.95,apad[aout]"
cmd = ['ffmpeg', '-y', '-loglevel', 'error', '-i', d['video'], *inputs, '-filter_complex', filt,
       '-map', '0:v', '-map', '[aout]', '-c:v', 'copy', '-c:a', 'aac', '-b:a', '160k', '-shortest', '-movflags', '+faststart', sys.argv[1]]
subprocess.run(cmd, check=True)
print('ok', len(labels), 'clips')
