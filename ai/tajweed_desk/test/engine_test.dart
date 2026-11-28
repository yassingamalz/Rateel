// End to end on the PC engine (ONNX Runtime 1.15.1 via FFI): needs the int8 model (LAB_MODEL) and
// LD_LIBRARY_PATH pointing at the onnxruntime plugin's linux/ folder. Skipped otherwise.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_core/explain.dart';
import 'package:tajweed_core/features.dart';
import 'package:tajweed_core/timeline.dart';
import 'package:tajweed_desk/engine.dart';

Float32List _f32(String p) => File(p).readAsBytesSync().buffer.asFloat32List();

void main() {
  final model = Platform.environment['LAB_MODEL'];
  test('al-Husary 1:2 -> same phonemes as PyTorch, no error', () async {
    const core = '../tajweed_core';
    final w = parseWav(File('$core/test/data/husary_001002.wav').readAsBytesSync());
    final f = extractFeatures(w.samples, _f32('$core/assets/window.f32'), _f32('$core/assets/mel.f32'));
    final e = Engine();
    final loadMs = await e.load(model!, threads: 4);
    final r = await e.run(f.values, f.mask);
    final v = jsonDecode(File('$core/assets/vocab.json').readAsStringSync()) as Map<String, dynamic>;
    final vocab = {for (final x in v.entries) int.parse(x.key): x.value as String};
    final ph = greedyDecode(r.logits, r.frames, r.classes, vocab);
    final ayah = parseAyat(File('$core/assets/ayat.json').readAsStringSync()).firstWhere((a) => a.sura == 1 && a.aya == 2);
    final c = correct(ayah, ph);
    // ignore: avoid_print
    print('load ${loadMs}ms, run ${r.ms}ms, frames ${r.frames}, $ph, errors ${c.errors.length}');
    expect(ph, 'ءَلحَمدُلِللَااهِرَببِلعَاالَمِۦۦۦۦن');
    expect(c.errors, isEmpty);
    // timings: groups in order, and the final madd ʿarid (4 harakat) lasts about a second
    final a = TakeAnalysis.of(decodeWithFrames(r.logits, r.frames, r.classes, vocab, w.seconds), ayah, w.seconds);
    for (var i = 1; i < a.groups.length; i++) {
      expect(a.groups[i].start, greaterThanOrEqualTo(a.groups[i - 1].start));
    }
    final madd = a.groups.firstWhere((g) => g.text == 'ۦۦۦۦ');
    // ignore: avoid_print
    print('madd ۦۦۦۦ ${madd.start.toStringAsFixed(2)}-${madd.end.toStringAsFixed(2)} s');
    expect(madd.duration, inInclusiveRange(0.8, 1.8));
    expect(a.status.every((s) => s == GroupStatus.ok), isTrue);
    await e.close();
  }, skip: model == null ? 'LAB_MODEL not set' : false, timeout: const Timeout(Duration(minutes: 5)));
}
