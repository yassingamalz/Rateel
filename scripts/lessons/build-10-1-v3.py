# Lesson 10.1 v3 (theme glassy3, voice 08 Orus): same content as lesson-10-1.json + gold key words and two-tone titles.
import json, os, re
clean = lambda x: re.sub(r'[^\u0621-\u0652\u0670]', '', x)
root = os.path.join(os.path.dirname(__file__), '..', '..')
src = os.path.join(root, 'src/assets/data/content/guided/lesson-10-1.json')
d = json.load(open(src))
d.update({'lessonId': 'lesson-10-1-v3', 'theme': 'glassy3', 'titleAccent': 'الْمُشَدَّدَتَانِ',
          'audioBase': 'assets/audio/guided/lesson-10-1-orus', 'commonBase': 'assets/audio/guided/common-orus'})
gold = {
  's01-intro': ['الْمُشَدَّدَتَانِ'],
  's02-ghunna': ['الْغُنَّةُ؟', 'الْخَيْشُومِ،'],
  's03-split': ['حَرْفَانِ:', 'سَاكِنٌ،', 'مُتَحَرِّكٌ.'],
  's04-hukm': ['الْغُنَّةِ', 'أَكْمَلَ'],
  's05-listen-nas': ['النُّونِ', 'الْمُشَدَّدَةِ'],
  's06-listen-anfal': ['الْغُنَّةُ.'],
  's07-quiz-hukm': [],
  's08-listen-masad': ['الْمِيمِ', 'الْمُشَدَّدَةِ،'],
  's09-listen-qasas': ['مِيمٌ', 'مُشَدَّدَةٌ'],
  's10-compare': ['حُكْمُهُمَا', 'وَاحِدٌ:'],
  's11-quiz-meem': [],
  's12-levels': ['أَرْبَعُ', 'مَرَاتِبَ:', 'الأُولَى.'],
  's13-tanbih': ['التَّنَاسُبُ'],
  's14-quiz-level': [],
  's15-repeat': ['الآنَ!'],
  's16-summary': ['أَوَّلًا،', 'ثَانِيًا،', 'ثَالِثًا،', 'رَابِعًا،'],
}
for s in d['steps']:
    toks = s.get('narration', '').split()
    for w in gold.get(s['id'], []):
        assert clean(w) in [clean(t) for t in toks], (s['id'], w)
    s['goldWords'] = gold.get(s['id'], [])
    if s['id'] == 's01-intro': s['titleAccent'] = 'الْمُشَدَّدَتَانِ'
    if s['id'] == 's16-summary': s['titleAccent'] = 'أَتْمَمْتَ الدَّرْسَ'
json.dump(d, open(os.path.join(root, 'src/assets/data/content/guided/lesson-10-1-v3.json'), 'w'), ensure_ascii=False, indent=1)
print('ok v3')
