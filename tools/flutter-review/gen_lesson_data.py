"""Generate app_flutter/lib/lessons/lesson_data_gen.dart from the Angular lessons JSON.

Usage (repo root): python3 tools/flutter-review/gen_lesson_data.py
Lessons are keyed by unit id (src/assets/data/units/*.json). Files whose unitId does not match a unit are
mapped by UNIT_ALIASES (owner plan 2026-11-22, question 7); the others are skipped and listed.
"""
import glob
import json

UNIT_ALIASES = {
    'intro-noon-meem-unit': 'intro-noon-meem',
    'practical-noon-meem-unit': 'noon-meem-practical',
}
TYPES = {'video': 'video', 'read': 'read', 'reading': 'read', 'practice': 'practice',
         'listen': 'listen', 'assessment': 'test', 'test': 'test'}

units = set()
for f in glob.glob('src/assets/data/units/*.json'):
    units.update(u['id'] for u in json.load(open(f, encoding='utf-8'))['units'])


def q(s):
    return "'" + str(s).replace('\\', '\\\\').replace("'", "\\'") + "'"


out = [
    '// Generated from src/assets/data/lessons/*/*.json (Angular app). Do not edit by hand:',
    '// python3 tools/flutter-review/gen_lesson_data.py',
    '',
    "part of 'lesson_data.dart';",
    '',
    'const _lessonsByUnit = <String, List<Lesson>>{',
]
for f in sorted(glob.glob('src/assets/data/lessons/*/*.json')):
    d = json.load(open(f, encoding='utf-8'))
    unit = UNIT_ALIASES.get(d['unitId'], d['unitId'])
    if unit not in units:
        print('skipped (no unit):', f)
        continue
    out.append(f'  {q(unit)}: [')
    for l in sorted(d['lessons'], key=lambda l: l['order']):
        out.append(
            f"    Lesson(id: {q(l['id'])}, title: {q(l['title'])}, description: {q(l.get('description', ''))}, "
            f"type: LessonType.{TYPES[l['type']]}, minutes: {int(l.get('duration') or 0)}),")
    out.append('  ],')
out.append('};')
with open('app_flutter/lib/lessons/lesson_data_gen.dart', 'w', encoding='utf-8') as fh:
    fh.write('\n'.join(out) + '\n')
