"""Generate app_flutter/lib/units/unit_data_gen.dart from the Angular units JSON.

Usage (repo root): python3 tools/flutter-review/gen_unit_data.py
File NN-<course>.json holds the units of course NN (1-based) in courses.json order.
"""
import glob
import json
import os

files = {int(os.path.basename(f)[:2]): f for f in glob.glob('src/assets/data/units/*.json')}
out = [
    '// Generated from src/assets/data/units/*.json (Angular app). Do not edit by hand:',
    '// python3 tools/flutter-review/gen_unit_data.py',
    '',
    "part of 'unit_data.dart';",
    '',
    'const _unitsByCourse = <int, List<Unit>>{',
]
for n in sorted(files):
    out.append(f'  {n - 1}: [')
    for u in json.load(open(files[n], encoding='utf-8'))['units']:
        out.append(f"    Unit(id: '{u['id']}', title: '{u['title']}', type: UnitType.{u['type']}),")
    out.append('  ],')
out.append('};')
with open('app_flutter/lib/units/unit_data_gen.dart', 'w', encoding='utf-8') as f:
    f.write('\n'.join(out) + '\n')
