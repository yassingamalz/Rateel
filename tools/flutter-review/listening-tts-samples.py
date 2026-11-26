"""Audition samples of the guided narration of the listening lessons (screen 22): Gemini TTS, voice 08 Orus.

Usage: GEMINI_API_KEY=... python3 tools/flutter-review/listening-tts-samples.py <outdir>
Each line is generated bare and with a short director's note (calm, reverent teaching tone); the note can be read
aloud by the model (lesson-production rule 2.1), so every take is transcribed by Gemini and flagged if it holds more
than the Arabic line. Narration never reads Quran text (rule 1.2: a real reciter recites).
"""
import base64
import json
import os
import subprocess
import sys
import urllib.request

KEY = os.environ['GEMINI_API_KEY']
OUT = sys.argv[1]
MODEL = os.environ.get('TTS_MODEL', 'gemini-3.8-flash-tts')
CHECK = 'gemini-3.8-flash'
VOICE = 'Orus'
LINES = {
    'intro': 'اِسْتَمِعْ جَيِّدًا إِلَى الْغُنَّةِ فِي النُّونِ الْمُشَدَّدَةِ، وَانْتَبِهْ إِلَى الْحَرْفِ الْمُلَوَّنِ.',
    'find': 'اِسْتَمِعْ، ثُمَّ اخْتَرِ الْكَلِمَةَ الَّتِي سَمِعْتَ فِيهَا الْغُنَّةَ.',
    'good': 'أَحْسَنْتَ، بَارَكَ اللَّهُ فِيكَ.',
}
# The note goes before the text, the format Gemini TTS expects; it is sometimes read aloud (lesson-production rule 2.1;
# a system instruction is refused by the TTS model, HTTP 400). Every take is checked: no Latin words in the
# transcription and a length close to the bare take; otherwise it is generated again (up to 6 takes).
STYLES = {
    'bare': '',
    'calm': 'Say slowly, softly and with calm reverence: ',
}


def post(model, body):
    req = urllib.request.Request(
        f'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent',
        data=json.dumps(body).encode(), headers={'Content-Type': 'application/json', 'x-goog-api-key': KEY})
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.load(r)


def synth(text, out, system=None):
    body = {'contents': [{'parts': [{'text': text}]}], 'generationConfig': {
        'responseModalities': ['AUDIO'],
        'speechConfig': {'voiceConfig': {'prebuiltVoiceConfig': {'voiceName': VOICE}}}}}
    if system:
        body['systemInstruction'] = {'parts': [{'text': system}]}
    j = post(MODEL, body)
    part = next(p for p in j['candidates'][0]['content']['parts'] if 'inlineData' in p)
    raw = base64.b64decode(part['inlineData']['data'])
    rate = part['inlineData']['mimeType'].split('rate=')[-1].split(';')[0] if 'rate=' in part['inlineData']['mimeType'] else '24000'
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-f', 's16le', '-ar', rate, '-ac', '1', '-i', '-', '-af',
                    'silenceremove=start_periods=1:start_threshold=-50dB,areverse,silenceremove=start_periods=1:'
                    'start_threshold=-50dB,areverse,loudnorm=I=-16:TP=-1.5:LRA=11,apad=pad_dur=0.25',
                    '-ar', '24000', '-b:a', '64k', out], input=raw, check=True)


def transcribe(path):
    data = base64.b64encode(open(path, 'rb').read()).decode()
    j = post(CHECK, {'contents': [{'parts': [
        {'inlineData': {'mimeType': 'audio/mpeg', 'data': data}},
        {'text': 'Transcribe this audio exactly, in the language spoken. Output only the transcription.'}]}]})
    return j['candidates'][0]['content']['parts'][0]['text'].strip()


def duration(f):
    return float(subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', f],
                                capture_output=True, text=True).stdout)


os.makedirs(OUT, exist_ok=True)
for key, line in LINES.items():
    bare = None
    for style, note in STYLES.items():
        f = f'{OUT}/{key}-{style}.mp3'
        for take in range(1, int(os.environ.get('TAKES', '6')) + 1):
            synth(note + line, f)
            t, dur = transcribe(f), duration(f)
            latin = any(c.isascii() and c.isalpha() for c in t)
            long = bare is not None and dur > bare * 1.9
            if not latin and not long:
                break
            print(f'  {key}-{style} take {take}: rejected ({dur:.1f}s «{t[:60]}»)')
        if style == 'bare':
            bare = dur
        print(f'{key}-{style}: {dur:.1f}s  «{t}»' + (' ⚠ NOT CLEAN' if latin or long else ''))
