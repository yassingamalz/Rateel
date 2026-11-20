"""Transcribe each narration with Whisper (no language forced) and flag English speech.
With --fix, cut everything before the first Arabic segment."""
import sys, glob, re, subprocess, os
import numpy as np

def load(f):
    raw = subprocess.run(['ffmpeg', '-loglevel', 'error', '-i', f, '-f', 's16le', '-ac', '1', '-ar', '16000', '-'], capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.int16).astype(np.float32) / 32768
from faster_whisper import WhisperModel

m = WhisperModel('small', device='cpu', compute_type='int8')
fix = '--fix' in sys.argv
files = [f for f in sys.argv[1:] if f != '--fix']
for f in files:
    segs, info = m.transcribe(load(f), word_timestamps=True, language=None, vad_filter=False)
    words = [w for s in segs for w in (s.words or [])]
    latin = [w for w in words if re.search(r'[A-Za-z]{2,}', w.word)]
    first_ar = next((w for w in words if re.search(r'[؀-ۿ]', w.word)), None)
    text = ''.join(w.word for w in words)
    status = 'OK ' if not latin else 'ENG'
    print(f'{status} {os.path.basename(f)} lang={info.language} :: {text[:90]}')
    if latin and fix and first_ar:
        cut = max(0, first_ar.start - 0.15)
        tmp = f + '.tmp.mp3'
        subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-ss', f'{cut:.2f}', '-i', f,
                        '-af', 'afade=t=in:d=0.05', '-ac', '1', '-ar', '24000', '-b:a', '64k', tmp], check=True)
        os.replace(tmp, f)
        print(f'    trimmed first {cut:.2f}s')
