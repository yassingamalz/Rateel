"""Mock data of screen 22 (listening lesson): app_flutter/assets/data/listening/<id>.json.

Usage (repo root): python3 tools/flutter-review/gen_listening_data.py
Audio: Husary murattal 128 kbps from everyayah.com (owner 2026-11-26, Q1 A), in
app_flutter/assets/audio/quran/husary/. Word times measured by hand on the 50 ms energy envelope
(dips = hamza / stop closures / pauses), owner OK for the mock (Q2). Waveform: 51 RMS bars (reference: 51 bars, step 2.6u) per ayah.
"""
import json
import subprocess

import numpy as np

BARS = 51
AYAT = {
    '108001': ('إِنَّآ أَعْطَيْنَٰكَ ٱلْكَوْثَرَ', [(150, 3650), (3750, 6100), (6100, 7700)]),
    '108002': ('فَصَلِّ لِرَبِّكَ وَٱنْحَرْ', [(50, 1050), (1050, 2850), (2900, 4700)]),
    '108003': ('إِنَّ شَانِئَكَ هُوَ ٱلْأَبْتَرُ', [(50, 1500), (1500, 2950), (2950, 3700), (3700, 6000)]),
}
QUESTIONS = [  # ayah, word index, word as asked, options (RTL order), correct, explanation
    ('108001', 0, 'إنَّا', ['غنة', 'قلقلة', 'مد'], 'غنة', 'النون المشددة تُقرأ بغنة مقدارها حركتان.'),
    ('108002', 2, 'وانْحَر', ['غنة', 'إظهار', 'إخفاء'], 'إظهار', 'النون ساكنة وبعدها حاء، وهي من حروف الحلق، فتُظهر النون.'),
    ('108003', 0, 'إنَّ', ['مد', 'غنة', 'قلقلة'], 'غنة', 'في «إنَّ» نون مشددة، فتظهر الغنة بمقدار حركتين.'),
    ('108003', 1, 'شانِئَك', ['قلقلة', 'مد', 'غنة'], 'مد', 'بعد الألف همزة في الكلمة نفسها: مد واجب متصل.'),
    ('108003', 3, 'الأبْتَر', ['غنة', 'مد', 'قلقلة'], 'قلقلة', 'الباء ساكنة وهي من حروف القلقلة (قطب جد)، فتُقلقل.'),
]


def peaks(path):
    raw = subprocess.run(['ffmpeg', '-v', 'error', '-i', path, '-ac', '1', '-ar', '8000', '-f', 's16le', '-'],
                         capture_output=True, check=True).stdout
    x = np.frombuffer(raw, dtype=np.int16).astype(float) / 32768
    voiced = np.nonzero(np.abs(x) > 0.02)[0]
    x = x[voiced[0]:voiced[-1]]
    n = len(x) // BARS
    rms = np.sqrt((x[:n * BARS].reshape(BARS, n) ** 2).mean(1))
    v = rms / rms.max()
    return [round(float(0.02 + 0.98 * a ** 1.7), 2) for a in v], len(raw) // 2 * 1000 // 8000, voiced[0] * 1000 // 8000


ayat = []
for key, (text, times) in AYAT.items():
    p, dur, start = peaks(f'app_flutter/assets/audio/quran/husary/{key}.mp3')
    words = text.split(' ')
    assert len(words) == len(times)
    ayat.append({'id': key, 'surah': 'سورة الكوثر', 'ayah': int(key[3:]),
                 'audio': f'audio/quran/husary/{key}.mp3', 'durationMs': dur, 'waveStartMs': int(start),
                 'words': [{'text': w, 'startMs': a, 'endMs': b} for w, (a, b) in zip(words, times)],
                 'peaks': p})
data = {
    'id': 'listen-kawthar-ghunna', 'title': 'الاستماع: الغنة', 'reciter': 'الحصري', 'pointsPerQuestion': 10,
    'ayat': ayat,
    'questions': [{'ayah': a, 'word': w, 'prompt': f'ماذا سمعت في كلمة «{asked}»؟', 'options': o, 'correct': c,
                   'explanation': e} for a, w, asked, o, c, e in QUESTIONS],
}
with open('app_flutter/assets/data/listening/listen-kawthar-ghunna.json', 'w', encoding='utf-8') as fh:
    json.dump(data, fh, ensure_ascii=False, indent=1)
print('ok', [len(a['peaks']) for a in ayat])
