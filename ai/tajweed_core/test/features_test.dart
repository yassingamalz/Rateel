// The Dart feature extractor must match transformers' SeamlessM4TFeatureExtractor on a real recording.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_core/features.dart';

Float32List _f32(String p) => File(p).readAsBytesSync().buffer.asFloat32List();

void main() {
  test('features match Python (al-Husary 1:2)', () {
    final wav = parseWav(File('test/data/husary_001002.wav').readAsBytesSync());
    expect(wav.rate, 16000);
    final f = extractFeatures(wav.samples, _f32('assets/window.f32'), _f32('assets/mel.f32'));
    final meta = jsonDecode(File('test/data/husary_001002_features.json').readAsStringSync()) as Map;
    final want = _f32('test/data/husary_001002_features.f32');
    expect([f.frames, 160], meta['shape']);
    expect(f.mask.toList(), (meta['mask'] as List).cast<int>());
    var maxDiff = 0.0;
    for (var i = 0; i < want.length; i++) {
      final d = (f.values[i] - want[i]).abs();
      if (d > maxDiff) maxDiff = d;
    }
    // ignore: avoid_print
    print('features: ${f.frames} x 160, max abs difference $maxDiff');
    expect(maxDiff, lessThan(1e-3));
  });
}
