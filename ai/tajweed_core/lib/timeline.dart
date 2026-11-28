// When each phoneme group was pronounced: from the CTC frames of the phonemes head (one frame ≈ 40 ms),
// plus the link between the heard groups and the reference groups (used to colour and to compare takes).
import 'dart:math' as math;
import 'dart:typed_data';

import 'explain.dart';

class TimedGroup {
  final String text; // phonemes of the group, e.g. «ۦۦۦۦ»
  final double start, end; // seconds
  final double confidence; // lowest softmax probability of its phonemes (0..1)
  TimedGroup(this.text, this.start, this.end, this.confidence);
  double get duration => end - start;
}

/// Greedy CTC decode keeping, for every emitted phoneme, its first frame and its probability.
class Decoded {
  final String text;
  final List<int> frameOf; // per character of [text]
  final List<double> probOf;
  final int frames;
  final double secondsPerFrame;
  Decoded(this.text, this.frameOf, this.probOf, this.frames, this.secondsPerFrame);
}

Decoded decodeWithFrames(
    List<double> logits, int frames, int classes, Map<int, String> vocab, double audioSeconds) {
  final sb = StringBuffer();
  final frameOf = <int>[], probOf = <double>[];
  var prev = -1;
  for (var t = 0; t < frames; t++) {
    var best = 0;
    var bv = logits[t * classes];
    for (var c = 1; c < classes; c++) {
      final v = logits[t * classes + c];
      if (v > bv) {
        bv = v;
        best = c;
      }
    }
    if (best != prev && best != 0) {
      var sum = 0.0;
      for (var c = 0; c < classes; c++) {
        sum += math.exp(logits[t * classes + c] - bv);
      }
      final s = vocab[best] ?? '';
      for (var k = 0; k < s.length; k++) {
        sb.write(s[k]);
        frameOf.add(t);
        probOf.add(1 / sum);
      }
    }
    prev = best;
  }
  return Decoded(sb.toString(), frameOf, probOf, frames, frames == 0 ? 0 : audioSeconds / frames);
}

/// Phoneme groups (same split as [chunkPhonemes]) with their start offset in the string.
List<(String, int)> chunkWithOffsets(String s) {
  final groups = chunkPhonemes(s);
  final out = <(String, int)>[];
  var from = 0;
  for (final g in groups) {
    final at = s.indexOf(g, from);
    out.add((g, at));
    from = at + g.length;
  }
  return out;
}

/// Times of the heard groups: a group starts at its first phoneme and lasts until the next group starts.
List<TimedGroup> timeGroups(Decoded d) {
  final gs = chunkWithOffsets(d.text);
  final out = <TimedGroup>[];
  for (var i = 0; i < gs.length; i++) {
    final (g, at) = gs[i];
    final start = d.frameOf[at] * d.secondsPerFrame;
    final lastFrame = d.frameOf[at + g.length - 1];
    final end = i + 1 < gs.length
        ? d.frameOf[gs[i + 1].$2] * d.secondsPerFrame
        : math.min(d.frames, lastFrame + 3) * d.secondsPerFrame;
    var conf = 1.0;
    for (var k = at; k < at + g.length; k++) {
      conf = math.min(conf, d.probOf[k]);
    }
    out.add(TimedGroup(g, start, math.max(end, start + d.secondsPerFrame), conf));
  }
  return out;
}

enum GroupStatus { ok, tajweed, letter, haraka, extra }

/// A heard recitation compared with the reference of the ayah.
class TakeAnalysis {
  final Decoded decoded;
  final List<TimedGroup> groups; // heard groups, in time order
  final Correction correction;
  final List<String> refGroups; // reference groups of the chosen reading
  final List<int> refStartPh; // phoneme offset of each reference group
  final List<int> predToRef; // heard group -> reference group (-1: extra sound)
  final List<int> refToPred; // reference group -> heard group (-1: missing)
  final List<GroupStatus> status; // per heard group
  final List<List<ReciterError>> errorsOfRef; // per reference group
  final double seconds;

  TakeAnalysis._(this.decoded, this.groups, this.correction, this.refGroups, this.refStartPh, this.predToRef,
      this.refToPred, this.status, this.errorsOfRef, this.seconds);

  factory TakeAnalysis.of(Decoded d, Ayah ayah, double seconds, {bool fixed = false}) {
    final groups = timeGroups(d);
    final corr = correct(ayah, d.text, fixed: fixed);
    final refG = chunkPhonemes(corr.variant.ph);
    final refStart = <int>[];
    var o = 0;
    for (final g in refG) {
      refStart.add(o);
      o += g.length;
    }
    final predG = [for (final g in groups) g.text];
    final predToRef = List<int>.filled(predG.length, -1);
    final refToPred = List<int>.filled(refG.length, -1);
    for (final op in alignGroups(refG, predG)) {
      if (op.type == 'equal' || op.type == 'replace') {
        if (op.predIdx < predG.length && op.refIdx < refG.length) {
          predToRef[op.predIdx] = op.refIdx;
          refToPred[op.refIdx] = op.predIdx;
        }
      }
    }
    final errorsOfRef = List.generate(refG.length, (_) => <ReciterError>[]);
    final extraAt = <int>{};
    for (final e in corr.errors) {
      if (e.phPos[0] == e.phPos[1]) {
        extraAt.add(e.phPos[0]);
        continue;
      }
      for (var r = 0; r < refG.length; r++) {
        if (refStart[r] >= e.phPos[0] && refStart[r] < e.phPos[1]) errorsOfRef[r].add(e);
      }
    }
    final status = List<GroupStatus>.generate(predG.length, (i) {
      final r = predToRef[i];
      if (r < 0) return GroupStatus.extra;
      final es = errorsOfRef[r];
      if (es.isEmpty) return GroupStatus.ok;
      if (es.any((e) => e.errorType == 'tajweed')) return GroupStatus.tajweed;
      if (es.any((e) => e.errorType == 'normal')) return GroupStatus.letter;
      return GroupStatus.haraka;
    });
    return TakeAnalysis._(d, groups, corr, refG, refStart, predToRef, refToPred, status, errorsOfRef, seconds);
  }

  /// Uthmani character span of a reference group.
  (int, int) uthmaniOfRef(int r) {
    final p2u = correction.variant.phToUth;
    final s = refStartPh[r], e = s + refGroups[r].length - 1;
    return (p2u[s], p2u[e] + 1);
  }

  /// Reference groups whose letters fall inside the Uthmani span [a, b).
  List<int> refGroupsInUthmani(int a, int b) => [
        for (var r = 0; r < refGroups.length; r++)
          if (uthmaniOfRef(r).$1 < b && uthmaniOfRef(r).$2 > a) r
      ];
}

/// 16-bit PCM mono WAV bytes of [samples] (for playing a piece of a take).
Uint8List wavBytes(Float32List samples, int rate) {
  final n = samples.length;
  final b = ByteData(44 + n * 2);
  void s(int o, String t) {
    for (var i = 0; i < 4; i++) {
      b.setUint8(o + i, t.codeUnitAt(i));
    }
  }

  s(0, 'RIFF');
  b.setUint32(4, 36 + n * 2, Endian.little);
  s(8, 'WAVE');
  s(12, 'fmt ');
  b.setUint32(16, 16, Endian.little);
  b.setUint16(20, 1, Endian.little);
  b.setUint16(22, 1, Endian.little);
  b.setUint32(24, rate, Endian.little);
  b.setUint32(28, rate * 2, Endian.little);
  b.setUint16(32, 2, Endian.little);
  b.setUint16(34, 16, Endian.little);
  s(36, 'data');
  b.setUint32(40, n * 2, Endian.little);
  for (var i = 0; i < n; i++) {
    b.setInt16(44 + i * 2, (samples[i].clamp(-1.0, 1.0) * 32767).round(), Endian.little);
  }
  return b.buffer.asUint8List();
}
