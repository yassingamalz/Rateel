"""Guided narration of the listening lessons (screen 22): Gemini TTS, voice 08 Orus, calm style (owner's choice F).

Usage (repo root): GEMINI_API_KEY=... python3 tools/flutter-review/gen_listening_narration.py [--force]
Writes app_flutter/assets/audio/narration/orus/<key>.mp3 and a manifest (text hash) so unchanged lines are kept.
Rules (lesson-production): full tashkīl; never a Quran word (a real reciter recites); every take transcribed and
rejected if it holds Latin words (the style note read aloud), misses part of the line or is much too long.
"""
import base64
import difflib
import hashlib
import json
import os
import re
import subprocess
import sys
import urllib.request

KEY = os.environ['GEMINI_API_KEY']
MODEL, CHECK, VOICE = 'gemini-3.1-flash-tts-preview', 'gemini-3.8-flash', 'Orus'
STYLE = 'Say slowly, softly and with calm reverence: '
OUT = 'app_flutter/assets/audio/narration/orus'
LINES = {
    # Rule lesson «الاستماع: الغنة».
    'ghunna-intro': 'اِسْتَمِعْ جَيِّدًا إِلَى الْغُنَّةِ فِي النُّونِ الْمُشَدَّدَةِ، وَانْتَبِهْ إِلَى الْحَرْفِ الْمُلَوَّنِ.',
    'ghunna-find': 'اِسْتَمِعْ، ثُمَّ اخْتَرِ الْكَلِمَةَ الَّتِي سَمِعْتَ فِيهَا الْغُنَّةَ.',
    'ghunna-letter': 'وَالْآنَ، اخْتَرِ الْحَرْفَ الَّذِي فِيهِ الْغُنَّةُ.',
    # Listening quiz.
    'quiz-intro': 'اِسْتَمِعْ إِلَى الْآيَةِ، ثُمَّ أَجِبْ عَنِ السُّؤَالِ.',
    # Shared feedback.
    'correct-1': 'أَحْسَنْتَ، بَارَكَ اللَّهُ فِيكَ.',
    'correct-2': 'أَحْسَنْتَ، إِجَابَةٌ صَحِيحَةٌ.',
    'wrong-1': 'لَا بَأْسَ، اسْتَمِعْ مَرَّةً أُخْرَى.',
    'done': 'أَحْسَنْتَ، أَتْمَمْتَ الدَّرْسَ، بَارَكَ اللَّهُ فِيكَ.',
}


def post(model, body):
    req = urllib.request.Request(
        f'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent',
        data=json.dumps(body).encode(), headers={'Content-Type': 'application/json', 'x-goog-api-key': KEY})
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.load(r)


def synth(text, out):
    j = post(MODEL, {'contents': [{'parts': [{'text': STYLE + text}]}], 'generationConfig': {
        'responseModalities': ['AUDIO'],
        'speechConfig': {'voiceConfig': {'prebuiltVoiceConfig': {'voiceName': VOICE}}}}})
    part = next(p for p in j['candidates'][0]['content']['parts'] if 'inlineData' in p)
    mime = part['inlineData']['mimeType']
    rate = mime.split('rate=')[-1].split(';')[0] if 'rate=' in mime else '24000'
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-f', 's16le', '-ar', rate, '-ac', '1', '-i', '-', '-af',
                    'silenceremove=start_periods=1:start_threshold=-50dB,areverse,silenceremove=start_periods=1:'
                    'start_threshold=-50dB,areverse,loudnorm=I=-16:TP=-1.5:LRA=11,apad=pad_dur=0.25',
                    '-ar', '24000', '-b:a', '64k', out], input=base64.b64decode(part['inlineData']['data']), check=True)


def transcribe(path):
    data = base64.b64encode(open(path, 'rb').read()).decode()
    j = post(CHECK, {'contents': [{'parts': [
        {'inlineData': {'mimeType': 'audio/mpeg', 'data': data}},
        {'text': 'Transcribe this audio exactly, in the language spoken. Output only the transcription.'}]}]})
    return j['candidates'][0]['content']['parts'][0]['text'].strip()


def letters(t):
    return re.sub(r'[^ء-ي]', '', t.replace('ٱ', 'ا').replace('ة', 'ه'))


def duration(f):
    return float(subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', f],
                                capture_output=True, text=True).stdout)


os.makedirs(OUT, exist_ok=True)
man_path = f'{OUT}/manifest.json'
manifest = json.load(open(man_path)) if os.path.exists(man_path) else {}
force = '--force' in sys.argv
for key, line in LINES.items():
    h = hashlib.sha1(f'{MODEL}|{VOICE}|{STYLE}|{line}'.encode()).hexdigest()[:12]
    f = f'{OUT}/{key}.mp3'
    if not force and manifest.get(key, {}).get('hash') == h and os.path.exists(f):
        print(f'{key}: kept')
        continue
    n = len(letters(line))
    for take in range(1, 9):
        synth(line, f)
        t, dur = transcribe(f), duration(f)
        ok = (not any(c.isascii() and c.isalpha() for c in t)
              and difflib.SequenceMatcher(None, letters(t), letters(line)).ratio() >= 0.85
              and dur <= 0.32 * n + 2.5)  # calm pace ≈ 0.2 s per letter; much longer = extra speech
        if ok:
            break
        print(f'  {key} take {take}: rejected ({dur:.1f}s «{t[:50]}»)')
    else:
        sys.exit(f'{key}: no clean take')
    manifest[key] = {'hash': h, 'text': line, 'transcript': t, 'seconds': round(dur, 2)}
    print(f'{key}: {dur:.1f}s «{t}»')
json.dump(manifest, open(man_path, 'w'), ensure_ascii=False, indent=1)
