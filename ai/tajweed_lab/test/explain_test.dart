// The Dart comparison must give the same errors as quran_transcript 0.6.4 explain_error
// on 728 cases (references of the 28 ayat + random mutations), made by tool/build_assets.py --tests.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_lab/explain.dart';

void main() {
  final ayat = parseAyat(File('assets/ayat.json').readAsStringSync());
  final cases = jsonDecode(File('test/data/explain_cases.json').readAsStringSync()) as List;

  test('explainError matches Python on every case', () {
    var ok = 0;
    final failures = <String>[];
    for (final c in cases.cast<Map<String, dynamic>>()) {
      if (c.containsKey('exception')) continue;
      final ayah = ayat.firstWhere((a) => a.sura == c['sura'] && a.aya == c['aya']);
      final v = ayah.variants.firstWhere((v) => v.ph == c['ref']);
      final got = jsonEncode([for (final e in explainError(v, c['pred'] as String)) e.toJson()]);
      final want = jsonEncode(c['errors']);
      if (got == want) {
        ok++;
      } else if (failures.length < 5) {
        failures.add('${c['sura']}:${c['aya']} pred=${c['pred']}\n want $want\n got  $got');
      }
    }
    // ignore: avoid_print
    print('explain: $ok / ${cases.length} identical');
    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}
