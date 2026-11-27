"""Mock data of screen 22 (listening lessons): app_flutter/assets/data/listening/<id>.json.

listen-ghunna: rule lesson (several ayat, rule letters coloured, then 3 «find the word, then the letter» questions);
listen-kawthar-ghunna: the quiz (later: practice after several rules, daily practice).

Usage (repo root): python3 tools/flutter-review/gen_listening_data.py
Audio: Husary murattal 128 kbps from everyayah.com (owner 2026-11-26, Q1 A), in
app_flutter/assets/audio/quran/husary/. Word times measured by hand on the 50 ms energy envelope
(dips = hamza / stop closures / pauses), owner OK for the mock (Q2). Waveform: 51 RMS bars (reference: 51 bars, step 2.6u) per ayah.
"""
import json
import subprocess

import numpy as np

BARS = 51
KAWTHAR, NAS = 'سورة الكوثر', 'سورة الناس'
AYAT = {  # id: (surah, Uthmani text, word times ms)
    '108001': (KAWTHAR, 'إِنَّآ أَعْطَيْنَٰكَ ٱلْكَوْثَرَ', [(150, 3650), (3750, 6100), (6100, 7700)]),
    '108002': (KAWTHAR, 'فَصَلِّ لِرَبِّكَ وَٱنْحَرْ', [(50, 1050), (1050, 2850), (2900, 4700)]),
    '108003': (KAWTHAR, 'إِنَّ شَانِئَكَ هُوَ ٱلْأَبْتَرُ', [(50, 1500), (1500, 2950), (2950, 3700), (3700, 6000)]),
    '114001': (NAS, 'قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ', [(450, 1000), (1000, 2500), (2500, 4000), (4000, 6700)]),
    '114002': (NAS, 'مَلِكِ ٱلنَّاسِ', [(200, 1200), (1200, 3700)]),
    '114003': (NAS, 'إِلَٰهِ ٱلنَّاسِ', [(250, 1650), (1650, 4050)]),
    '114004': (NAS, 'مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ', [(350, 1400), (1400, 2600), (2600, 5200), (5200, 8600)]),
    '114005': (NAS, 'ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ',
               [(550, 1550), (1550, 4300), (4300, 5150), (5150, 6750), (6750, 9300)]),
    '114006': (NAS, 'مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ', [(600, 1600), (1600, 3450), (3450, 6800)]),
}
QUIZ = [  # ayah, word index, word as asked, options (RTL order), correct, explanation
    ('108001', 0, 'إنَّا', ['غنة', 'قلقلة', 'مد'], 'غنة', 'النون المشددة تُقرأ بغنة مقدارها حركتان.'),
    ('108002', 2, 'وانْحَر', ['غنة', 'إظهار', 'إخفاء'], 'إظهار', 'النون ساكنة وبعدها حاء، وهي من حروف الحلق، فتُظهر النون.'),
    ('108003', 0, 'إنَّ', ['مد', 'غنة', 'قلقلة'], 'غنة', 'في «إنَّ» نون مشددة، فتظهر الغنة بمقدار حركتين.'),
    ('108003', 1, 'شانِئَك', ['قلقلة', 'مد', 'غنة'], 'مد', 'بعد الألف همزة في الكلمة نفسها: مد واجب متصل.'),
    ('108003', 3, 'الأبْتَر', ['غنة', 'مد', 'قلقلة'], 'قلقلة', 'الباء ساكنة وهي من حروف القلقلة (قطب جد)، فتُقلقل.'),
]
# Rule lesson (owner, 2026-11-26): one rule, several ayat, the rule's words in the tajweed wheel colour.
NOTE = 'نون مشددة: غنة بمقدار حركتين.'
STEPS = [  # ayah, rule word indexes, note; the rule is on the letter(s) found by rule_letters()
    ('114001', [3], f'«النَّاس»: {NOTE}'), ('114002', [1], f'«النَّاس»: {NOTE}'), ('114003', [1], f'«النَّاس»: {NOTE}'),
    ('114004', [3], f'«الخَنَّاس»: {NOTE}'), ('114005', [4], f'«النَّاس»: {NOTE}'),
    ('114006', [1, 2], 'في «الجِنَّة» و«النَّاس» نون مشددة: غنة بمقدار حركتين.'),
    ('108001', [0], f'«إِنَّا»: {NOTE}'),
]
# Ghunna «hold» of each rule letter (ms in the ayah audio): the nasal stretch measured on the 50 ms energy envelope
# (steady low level after the vowel). The lesson lights one dot per haraka over it (owner, 2026-11-27: 2 harakat).
HOLDS = {
    ('114001', 3): (4000, 4900), ('114002', 1): (1250, 2300), ('114003', 1): (1750, 2550),
    ('114004', 3): (5600, 6250), ('114005', 4): (6800, 7500), ('114006', 1): (1900, 2900),
    ('114006', 2): (4250, 5250), ('108001', 0): (400, 1350), ('108003', 0): (300, 1400),
}
HARAKAT = 2  # ghunna of a doubled nun / meem
MARKS = set(range(0x064B, 0x0660)) | {0x0670} | set(range(0x06D6, 0x06EE))


def rule_letters(word):
    """Ghunna of a doubled nun / meem (owner, 2026-11-26: colour the letter, not the word): the letter carrying the
    shadda, with its marks, as [from, to) in UTF-16 code units (= Dart string indexes; Arabic is in the BMP)."""
    for i, ch in enumerate(word):
        if ch in 'نم':
            j = i + 1
            while j < len(word) and ord(word[j]) in MARKS:
                j += 1
            if '\u0651' in word[i + 1:j]:
                return [i, j]
    raise ValueError(word)
RULE_QUIZ = [QUIZ[0], QUIZ[4], QUIZ[1]]
# End of the rule lesson (owner, 2026-11-26): the ayah plays, the student taps the word where the rule was heard, then
# chooses its letter. Ayat with one rule word only (114:4 is left out: its «مِن شَرّ» has an ikhfa with ghunna too).
FINDS = [('114002', 1), ('108003', 0), ('108001', 0)]


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


def ayah(key):
    surah, text, times = AYAT[key]
    p, dur, _ = peaks(f'app_flutter/assets/audio/quran/husary/{key}.mp3')
    words = text.split(' ')
    assert len(words) == len(times), key
    return {'id': key, 'surah': surah, 'ayah': int(key[3:]), 'audio': f'audio/quran/husary/{key}.mp3',
            'durationMs': dur, 'words': [{'text': w, 'startMs': a, 'endMs': b} for w, (a, b) in zip(words, times)],
            'peaks': p}


def quiz(rows):
    return [{'ayah': a, 'word': w, 'prompt': f'ماذا سمعت في كلمة «{asked}»؟', 'options': o, 'correct': c,
             'explanation': e} for a, w, asked, o, c, e in rows]


def write(lesson, steps, questions, title, finds=(), narration=None):
    keys = sorted({a for a, *_ in steps} | {q[0] for q in questions} | {a for a, _ in finds})
    data = {'id': lesson, 'title': title, 'reciter': 'الحصري', 'pointsPerQuestion': 10,
            'rule': {'name': 'الغنة', 'short': 'غنة', 'colour': 'green'} if steps else None,
            'ayat': [ayah(k) for k in keys],
            'steps': [{'ayah': a, 'marks': [{'word': i, 'letters': rule_letters(AYAT[a][1].split(' ')[i]),
                                              'hold': list(HOLDS[(a, i)]), 'harakat': HARAKAT} for i in w],
                       'note': n} for a, w, n in steps],
            'finds': [{'ayah': a, 'marks': [{'word': w, 'letters': rule_letters(AYAT[a][1].split(' ')[w])}]}
                      for a, w in finds],
            'questions': quiz(questions),
            # Guided voice (Gemini TTS Orus, gen_listening_narration.py): keys of audio/narration/orus/<key>.mp3.
            'narration': narration or {}}
    with open(f'app_flutter/assets/data/listening/{lesson}.json', 'w', encoding='utf-8') as fh:
        json.dump(data, fh, ensure_ascii=False, indent=1)
    print('ok', lesson, len(steps), len(questions))


write('listen-ghunna', STEPS, [], 'الاستماع: الغنة', FINDS,
      {'intro': 'ghunna-intro', 'find': 'ghunna-find', 'letter': 'ghunna-letter'})
write('listen-kawthar-ghunna', [], QUIZ, 'اختبار الاستماع: الغنة', narration={'intro': 'quiz-intro'})
