#!/usr/bin/env python3
"""Free narration voice (Microsoft Edge neural TTS via edge-tts, no API key) for guided lessons.

Usage: python3 scripts/generate-free-audio.py <lessonId> [--voice ar-SA-HamedNeural] [--force]

Writes, for every step with a narration:
  src/<audioBase>/<stepId>.mp3
  src/<audioBase>/<stepId>.words.json   {"d": durationMs, "t": [startMs per whitespace token]}
and the lesson's "common" lines into src/<commonBase>/<key>.mp3.
The word timings come from the TTS word boundaries, so captions and reveals follow the voice exactly.
Verify afterwards with scripts/video/check-audio-whisper.py (rule 2.2).
"""
import asyncio, json, os, re, subprocess, sys, hashlib
import edge_tts

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
args = sys.argv[1:]
voice = 'ar-SA-HamedNeural'
if '--voice' in args:
    i = args.index('--voice'); voice = args[i + 1]; del args[i:i + 2]
force = '--force' in args
args = [a for a in args if a != '--force']
lesson_id = args[0]
lesson = json.load(open(f'{ROOT}/src/assets/data/content/guided/{lesson_id}.json'))
manifest_path = f'{ROOT}/src/assets/audio/guided/manifest-free.json'
manifest = json.load(open(manifest_path)) if os.path.exists(manifest_path) else {}

HARAKAT = re.compile(r'[ً-ٰٟـ]')
def norm(w):
    return re.sub(r'[^ء-ي]', '', HARAKAT.sub('', w))

def duration_ms(f):
    return round(1000 * float(subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', f],
                                             capture_output=True, text=True, check=True).stdout))

async def synth(text, out, timings=False):
    c = edge_tts.Communicate(text, voice, boundary='WordBoundary')
    bounds = []
    with open(out, 'wb') as f:
        async for ch in c.stream():
            if ch['type'] == 'audio':
                f.write(ch['data'])
            elif ch['type'] == 'WordBoundary':
                bounds.append((ch['text'], ch['offset'] / 10_000))
    if not timings:
        return None
    tokens = text.split()
    starts, j = [], 0
    for tok in tokens:
        n = norm(tok)
        k = j
        while k < len(bounds) and norm(bounds[k][0]) != n and not (n and norm(bounds[k][0]) and (n.startswith(norm(bounds[k][0])) or norm(bounds[k][0]).startswith(n))):
            k += 1
        if k < len(bounds):
            starts.append(round(bounds[k][1])); j = k + 1
        else:
            starts.append(starts[-1] if starts else 0)
            print(f'    ! no boundary for «{tok}»')
    return {'d': duration_ms(out), 't': starts}

async def main():
    jobs = []
    base = f"{ROOT}/src/{lesson['audioBase']}"
    os.makedirs(base, exist_ok=True)
    for s in lesson['steps']:
        if s.get('narration'):
            jobs.append((s['narration'], f"{base}/{s['id']}.mp3", True))
    if lesson.get('commonBase'):
        cb = f"{ROOT}/src/{lesson['commonBase']}"
        os.makedirs(cb, exist_ok=True)
        for k, t in lesson.get('common', {}).items():
            jobs.append((t, f'{cb}/{k}.mp3', False))
    for text, out, timed in jobs:
        key = os.path.relpath(out, f'{ROOT}/src/assets/audio/guided')
        h = hashlib.sha1(f'{voice}|{text}'.encode()).hexdigest()[:12]
        if not force and manifest.get(key) == h and os.path.exists(out):
            continue
        print('  →', key)
        w = await synth(text, out, timed)
        if w:
            json.dump(w, open(out[:-4] + '.words.json', 'w'))
        manifest[key] = h
        json.dump(manifest, open(manifest_path, 'w'), indent=1, sort_keys=True)

asyncio.run(main())
print('done')
