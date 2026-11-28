// Comparison of the heard phonemes with the reference: a Dart port of
// quran_transcript 0.6.4 `explain_error` (the version tested in docs/ai/TAJWEED-MODEL.md),
// checked against the Python output by test/explain_test.dart.
import 'dart:convert';

const _core = 'ءبتثجحخدذرزسشصضطظعغفقكلمنهوياۥۦ۾ںـٲ';
const _residuals = 'َُِڇؙ۪ۜ';
const _harakat = 'َُِ';
const _qlqla = 'ڇ';
const _maddMap = {'ا': 'alif', 'ۥ': 'waw', 'ۦ': 'yaa'};
const _leenMap = {'و': 'waw', 'ي': 'yaa'};
const _ghonnaOffset = {'ن': 0, 'ي': 1, 'و': 1, 'ں': 1, 'م': 0, '۾': 0};
const _maddKinds = {
  'NormalMaddRule', 'MonfaselMaddRule', 'MottaselMaddPauseRule', 'MottaselMaddRule',
  'LazemMaddRule', 'AaredMaddRule', 'MoshaddadOrModghamNoonRule',
};

/// Groups of phonemes: a run of the same core letter plus an optional residual (haraka, qalqala…).
List<String> chunkPhonemes(String s) {
  final out = <String>[];
  var i = 0;
  while (i < s.length) {
    final c = s[i];
    if (!_core.contains(c)) {
      i++;
      continue;
    }
    var j = i + 1;
    while (j < s.length && s[j] == c) {
      j++;
    }
    if (j < s.length && _residuals.contains(s[j])) j++;
    out.add(s.substring(i, j));
    i = j;
  }
  return out;
}

class TajweedRule {
  final String kind, ar, en, correctness;
  final int goldenLen, offset;
  final String? tag;
  const TajweedRule(this.kind, this.ar, this.en, this.correctness, this.goldenLen, this.tag, this.offset);

  factory TajweedRule.fromJson(Map<String, dynamic> j) => TajweedRule(
        j['kind'] as String, j['ar'] as String, j['en'] as String, j['correctness'] as String,
        (j['golden_len'] as num).toInt(), j['tag'] as String?, (j['offset'] as num? ?? 0).toInt());

  TajweedRule withTag(String t, {int? offset}) =>
      TajweedRule(kind, ar, en, correctness, goldenLen, t, offset ?? this.offset);

  static int _countOf(String s, String c) => c.allMatches(s).length;

  int count(String ref, String pred) {
    if (_maddKinds.contains(kind) || kind == 'LeenMaddRule') {
      final body = pred[pred.length - 1] != pred[0] ? pred.substring(0, pred.length - 1) : pred;
      return _countOf(body, ref[0]) + (kind == 'LeenMaddRule' ? 1 : 0);
    }
    if (kind == 'Ghonnah') return _countOf(pred, ref[0]) + offset;
    return 0;
  }

  bool match(String ref, String pred) {
    if (kind == 'Qalqalah' || kind == 'IdghamKamel') return ref == pred;
    return true;
  }

  /// `get_relvant_rule`: the rule this phoneme group would carry in the prediction.
  TajweedRule? relevant(String ph) {
    if (ph.isEmpty) return null;
    if (kind == 'Qalqalah') return ph[ph.length - 1] == _qlqla ? this : null;
    if (kind == 'IdghamKamel') return null;
    if (kind == 'LeenMaddRule') return _leenMap.containsKey(ph[0]) ? withTag(_leenMap[ph[0]]!) : null;
    if (_maddKinds.contains(kind)) return _maddMap.containsKey(ph[0]) ? withTag(_maddMap[ph[0]]!) : null;
    if (kind == 'Ghonnah') {
      return _ghonnaOffset.containsKey(ph[0]) ? withTag(ph[0], offset: _ghonnaOffset[ph[0]]) : null;
    }
    return this;
  }
}

class ReciterError {
  final List<int> uthmaniPos, phPos;
  final String errorType, speechErrorType, expectedPh, predictedPh;
  final int? expectedLen, predictedLen;
  final List<TajweedRule> refRules, replacedRules;
  ReciterError(this.uthmaniPos, this.phPos, this.errorType, this.speechErrorType, this.expectedPh, this.predictedPh,
      {this.expectedLen, this.predictedLen, this.refRules = const [], this.replacedRules = const []});

  Map<String, dynamic> toJson() => {
        'uthmani_pos': uthmaniPos,
        'ph_pos': phPos,
        'error_type': errorType,
        'speech_error_type': speechErrorType,
        'expected_ph': expectedPh,
        'predicted_ph': predictedPh,
        'expected_len': expectedLen,
        'predicted_len': predictedLen,
        'ref_rules': [for (final r in refRules) r.en],
        'replaced_rules': [
          for (final r in replacedRules) [r.en, r.tag]
        ],
      };
}

class Variant {
  final List<Map<String, int>> labels;
  final String ph;
  final List<int> phToUth;
  final Set<int> uthHasRules;
  final List<List<TajweedRule>> groupRules;
  Variant(this.labels, this.ph, this.phToUth, this.uthHasRules, this.groupRules);

  factory Variant.fromJson(Map<String, dynamic> j) => Variant(
        [for (final l in j['labels'] as List) (l as Map).map((k, v) => MapEntry(k as String, (v as num).toInt()))],
        j['ph'] as String,
        [for (final x in j['ph_to_uth'] as List) (x as num).toInt()],
        {for (final x in j['uth_has_rules'] as List) (x as num).toInt()},
        [
          for (final g in j['group_rules'] as List)
            [for (final r in g as List) TajweedRule.fromJson(r as Map<String, dynamic>)]
        ],
      );

  String get labelText {
    final l = labels.first;
    return 'عارض ${l['aared']} · منفصل ${l['monfasel']} · متصل ${l['mottasel']}';
  }
}

class Ayah {
  final int sura, aya;
  final String suraName, uthmani;
  final List<Variant> variants;
  Ayah(this.sura, this.aya, this.suraName, this.uthmani, this.variants);
  factory Ayah.fromJson(Map<String, dynamic> j) => Ayah(
        (j['sura'] as num).toInt(),
        (j['aya'] as num).toInt(),
        j['sura_name'] as String,
        j['uthmani'] as String,
        [for (final v in j['variants'] as List) Variant.fromJson(v as Map<String, dynamic>)],
      );
}

List<Ayah> parseAyat(String jsonText) =>
    [for (final a in (jsonDecode(jsonText) as Map)['ayat'] as List) Ayah.fromJson(a as Map<String, dynamic>)];

class Op {
  final String type; // equal, replace, insert, delete
  final int refIdx, predIdx;
  Op(this.type, this.refIdx, this.predIdx);
}

/// Levenshtein edit operations on two sequences, then split per index like `align_phonemes_groups`.
List<Op> alignGroups(List<String> refG, List<String> predG) {
  final a = [for (final g in refG) g[0]];
  final b = [for (final g in predG) g[0]];
  // common prefix and suffix are matched first (as rapidfuzz does)
  var pre = 0;
  while (pre < a.length && pre < b.length && a[pre] == b[pre]) {
    pre++;
  }
  var suf = 0;
  while (suf < a.length - pre && suf < b.length - pre && a[a.length - 1 - suf] == b[b.length - 1 - suf]) {
    suf++;
  }
  final n = a.length - pre - suf, m = b.length - pre - suf;
  final d = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
  for (var i = 0; i <= n; i++) {
    d[i][0] = i;
  }
  for (var j = 0; j <= m; j++) {
    d[0][j] = j;
  }
  for (var i = 1; i <= n; i++) {
    for (var j = 1; j <= m; j++) {
      final cost = a[pre + i - 1] == b[pre + j - 1] ? 0 : 1;
      var v = d[i - 1][j - 1] + cost;
      if (d[i - 1][j] + 1 < v) v = d[i - 1][j] + 1;
      if (d[i][j - 1] + 1 < v) v = d[i][j - 1] + 1;
      d[i][j] = v;
    }
  }
  // backtrace from the end: editops (type, i, j) in reverse
  final rev = <List<Object>>[];
  var i = n, j = m;
  // Priority delete > replace > insert > equal reproduces python-Levenshtein 0.27 opcodes
  // (3000/3000 random cases, docs/ai/tajweed-model-study/lev_order.py).
  while (i > 0 || j > 0) {
    if (i > 0 && d[i][j] == d[i - 1][j] + 1) {
      rev.add(['delete', i - 1, j]);
      i--;
    } else if (i > 0 && j > 0 && a[pre + i - 1] != b[pre + j - 1] && d[i][j] == d[i - 1][j - 1] + 1) {
      rev.add(['replace', i - 1, j - 1]);
      i--;
      j--;
    } else if (j > 0 && d[i][j] == d[i][j - 1] + 1) {
      rev.add(['insert', i, j - 1]);
      j--;
    } else {
      rev.add(['equal', i - 1, j - 1]);
      i--;
      j--;
    }
  }
  final ops = <Op>[];
  for (var k = 0; k < pre; k++) {
    ops.add(Op('equal', k, k));
  }
  for (final e in rev.reversed) {
    final t = e[0] as String;
    final ri = (e[1] as int) + pre, pj = (e[2] as int) + pre;
    ops.add(Op(t, ri, pj));
  }
  for (var k = 0; k < suf; k++) {
    ops.add(Op('equal', a.length - suf + k, b.length - suf + k));
  }
  return ops;
}

List<ReciterError> explainError(Variant ref, String predicted) {
  final refG = chunkPhonemes(ref.ph);
  final predG = chunkPhonemes(predicted);
  final p2u = ref.phToUth;
  final rules = ref.groupRules;
  final errors = <ReciterError>[];
  var refStart = 0, refEnd = 0;
  for (final al in alignGroups(refG, predG)) {
    final refPh = al.refIdx < refG.length ? refG[al.refIdx] : '';
    final predPh = al.predIdx < predG.length ? predG[al.predIdx] : '';
    List<int> uth, phPos;
    if (al.type != 'insert') {
      refEnd = refStart + refPh.length;
      uth = [p2u[refStart], p2u[refEnd - 1] + 1];
      phPos = [refStart, refEnd];
    } else {
      final k = refStart < p2u.length ? refStart : refStart - 1;
      uth = [p2u[k], p2u[k]];
      phPos = [refStart, refStart];
    }
    if (al.type == 'insert') {
      errors.add(ReciterError(uth, phPos, 'normal', 'insert', '', predPh));
    } else if (al.type == 'replace') {
      final rs = rules[al.refIdx];
      for (final r in rs) {
        final pr = r.relevant(predPh);
        if (pr != null) {
          final isCount = pr.correctness == 'count';
          errors.add(ReciterError(uth, phPos, 'tajweed', 'replace', refPh, predPh,
              expectedLen: isCount ? r.goldenLen : null,
              predictedLen: isCount ? pr.count(predPh, predPh) : null,
              refRules: [r],
              replacedRules: [pr]));
        } else {
          errors.add(ReciterError(uth, phPos, 'tajweed', 'replace', refPh, predPh, refRules: [r]));
        }
      }
      if (rs.isEmpty) errors.add(ReciterError(uth, phPos, 'normal', 'replace', refPh, predPh));
    } else if (al.type == 'delete') {
      errors.add(ReciterError(
          uth, phPos, ref.uthHasRules.contains(p2u[refStart]) ? 'tajweed' : 'normal', 'delete', refPh, ''));
    } else {
      // equal first letter
      if (refPh == predPh) {
        // nothing
      } else if (rules[al.refIdx].isNotEmpty) {
        for (final r in rules[al.refIdx]) {
          int? expLen, predLen;
          if (r.correctness == 'count') {
            predLen = r.count(refPh, predPh);
            expLen = r.goldenLen;
          }
          errors.add(ReciterError(uth, phPos, 'tajweed', 'replace', refPh, predPh,
              expectedLen: expLen, predictedLen: predLen, refRules: [r]));
          if (_harakat.contains(refPh[refPh.length - 1]) && predPh[predPh.length - 1] != refPh[refPh.length - 1]) {
            errors.add(_tashkeel(refPh, predPh, uth, phPos));
          }
        }
      } else if (_harakat.contains(refPh[refPh.length - 1])) {
        errors.add(_tashkeel(refPh, predPh, uth, phPos));
      } else if (_residuals.contains(refPh[refPh.length - 1])) {
        // imala, sakt…: not handled (as in Python)
      } else {
        final type = _harakat.contains(predPh[predPh.length - 1]) ? 'tashkeel' : 'normal';
        errors.add(ReciterError(uth, phPos, type, 'insert', refPh, predPh));
      }
    }
    refStart = refEnd;
  }
  return errors;
}

ReciterError _tashkeel(String ref, String pred, List<int> uth, List<int> phPos) {
  final t = pred.length > ref.length ? 'insert' : (pred.length < ref.length ? 'delete' : 'replace');
  return ReciterError(uth, phPos, 'tashkeel', t, ref, pred);
}

class Correction {
  final Variant variant;
  final List<ReciterError> errors;
  Correction(this.variant, this.errors);
}

/// Compares with every allowed reading of the ayah and keeps the one with the fewest errors
/// (owner 2026-11-28: every allowed madd length is correct).
/// With [fixed] only the reading ʿarid 4 · munfasil 4 · muttasil 4 is used (to test madd errors).
Correction correct(Ayah ayah, String predicted, {bool fixed = false}) {
  Correction? best;
  final candidates = fixed
      ? ayah.variants.where((v) => v.labels.any((l) => l['aared'] == 4 && l['monfasel'] == 4 && l['mottasel'] == 4))
      : ayah.variants;
  for (final v in candidates) {
    final e = explainError(v, predicted);
    if (best == null || e.length < best.errors.length) best = Correction(v, e);
  }
  return best!;
}

/// Greedy CTC decode of the phonemes head: argmax per frame, collapse repeats, drop blank (id 0).
String greedyDecode(List<double> logits, int frames, int classes, Map<int, String> vocab) {
  final sb = StringBuffer();
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
    if (best != prev && best != 0) sb.write(vocab[best] ?? '');
    prev = best;
  }
  return sb.toString();
}
