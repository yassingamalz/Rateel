#!/usr/bin/env python3
"""Word timings for narration clips that come without them (e.g. Gemini TTS), via local Whisper.

usage: align-words-whisper.py <lessonId>
Reads src/assets/data/content/guided/<lessonId>.json and, for every step with a narration, writes
src/<audioBase>/<stepId>.words.json  {"d": durationMs, "t": [startMs per whitespace token]}
(the same format as scripts/generate-free-audio.py). Whisper words are matched to the narration
tokens in order (diacritics and punctuation ignored); unmatched tokens are interpolated.
Also prints a verification line per clip (rule 2.2): the transcript and any Latin-script speech.
"""
import json, os, re, subprocess, sys
import numpy as np
from difflib import SequenceMatcher
from faster_whisper import WhisperModel

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
lesson = json.load(open(f'{ROOT}/src/assets/data/content/guided/{sys.argv[1]}.json'))
base = f"{ROOT}/src/{lesson['audioBase']}"
HARAKAT = re.compile(r'[ً-ٰٟـ]')
norm = lambda w: re.sub(r'[^ء-ي]', '', HARAKAT.sub('', w)).replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا').replace('ة', 'ه').replace('ى', 'ي')

def load(f):
    raw = subprocess.run(['ffmpeg', '-loglevel', 'error', '-i', f, '-f', 's16le', '-ac', '1', '-ar', '16000', '-'], capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.int16).astype(np.float32) / 32768

model = WhisperModel('small', device='cpu', compute_type='int8')
for s in lesson['steps']:
    if not s.get('narration'):
        continue
    f = f"{base}/{s['id']}.mp3"
    audio = load(f)
    d = round(len(audio) / 16)
    segs, _ = model.transcribe(audio, language='ar', word_timestamps=True, vad_filter=False)
    words = [w for seg in segs for w in (seg.words or [])]
    latin = [w.word for w in words if re.search(r'[A-Za-z]{2,}', w.word)]
    tokens = s['narration'].split()
    starts = [None] * len(tokens)
    j = 0
    for i, tok in enumerate(tokens):
        n = norm(tok)
        best, bk = 0.0, None
        for k in range(j, min(j + 4, len(words))):
            r = SequenceMatcher(None, n, norm(words[k].word)).ratio()
            if r > best:
                best, bk = r, k
        if bk is not None and best >= 0.5:
            starts[i] = round(words[bk].start * 1000)
            j = bk + 1
    # interpolate the gaps
    known = [(i, t) for i, t in enumerate(starts) if t is not None]
    if not known:
        known = [(0, 0)]
    for i in range(len(tokens)):
        if starts[i] is None:
            prev = max([k for k in known if k[0] < i], default=(0 - 1, 0))
            nxt = min([k for k in known if k[0] > i], default=(len(tokens), d))
            starts[i] = round(prev[1] + (nxt[1] - prev[1]) * (i - prev[0]) / max(1, nxt[0] - prev[0]))
    starts = [max(a, b) for a, b in zip(starts, [0] + starts[:-1])]  # monotonic
    json.dump({'d': d, 't': starts}, open(f[:-4] + '.words.json', 'w'))
    matched = sum(1 for k in known if k is not None)
    status = 'ENG' if latin else 'OK '
    print(f"{status} {s['id']} {d/1000:.1f}s matched {len(known)}/{len(tokens)} :: {''.join(w.word for w in words)[:80]}")
