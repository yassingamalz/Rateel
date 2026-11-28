// The errors of a take, grouped per letter of the ayah and said in plain words (Italian + the Arabic rule),
// for the «Cosa rivedere» cards of the result screen.
import 'package:tajweed_core/explain.dart';
import 'package:tajweed_core/timeline.dart';

enum IssueKind { tajweed, letter }

class Issue {
  final int ref; // reference group
  final List<ReciterError> errors;
  final IssueKind kind;
  final String title, detail, arabic;
  final int? expectedCount, myCount; // harakat, for madd / ghunna
  Issue(this.ref, this.errors, this.kind, this.title, this.detail, this.arabic, {this.expectedCount, this.myCount});
}

const _harakaName = {'َ': 'fatha', 'ُ': 'damma', 'ِ': 'kasra'};
const _maddLetter = {'ا': 'ا', 'ۥ': 'و', 'ۦ': 'ي'};
const _typeAr = {'tajweed': 'خطأ تجويد', 'normal': 'خطأ في الحرف', 'tashkeel': 'خطأ في الحركة'};

/// Letters of a phoneme group as a reader would write them (madd marks as their letter).
String readable(String g) {
  final b = StringBuffer();
  for (final c in g.split('')) {
    b.write(switch (c) { 'ۥ' => 'و', 'ۦ' => 'ي', 'ں' => 'ن', '۾' => 'م', 'ڇ' => '', _ => c });
  }
  return b.toString();
}

String _haraka(String g) => g.isEmpty ? 'sukun' : (_harakaName[g[g.length - 1]] ?? 'sukun');

int _runOf(String g) {
  if (g.isEmpty) return 0;
  var n = 0;
  for (final c in g.split('')) {
    if (c == g[0]) n++;
  }
  return n;
}

List<Issue> issuesOf(TakeAnalysis a) {
  final byRef = <int, List<ReciterError>>{};
  for (var r = 0; r < a.refGroups.length; r++) {
    if (a.errorsOfRef[r].isNotEmpty) byRef[r] = [...a.errorsOfRef[r]];
  }
  // extra sounds (zero-width errors) go to the letter they come before
  for (final e in a.correction.errors) {
    if (e.phPos[0] != e.phPos[1]) continue;
    var r = a.refStartPh.lastIndexWhere((s) => s <= e.phPos[0]);
    if (r < 0) r = 0;
    byRef.putIfAbsent(r, () => []).add(e);
  }
  final out = <Issue>[];
  for (final r in byRef.keys.toList()..sort()) {
    out.add(_issue(a, r, byRef[r]!));
  }
  return out;
}

Issue _issue(TakeAnalysis a, int r, List<ReciterError> es) {
  final rules = a.correction.variant.groupRules[r];
  final arRule = rules.isEmpty ? '' : rules.map((x) => x.ar).join('، ');
  final ref = a.refGroups[r];

  // 1. a length (madd, ghunna)
  final counted = es.where((e) => e.errorType == 'tajweed' && e.expectedLen != null && e.predictedLen != null);
  if (counted.isNotEmpty) {
    final e = counted.first;
    final rule = e.refRules.isNotEmpty ? e.refRules.first : null;
    final isGhunna = rule?.kind == 'Ghonnah';
    final what = isGhunna ? 'Ghunna' : 'Mad';
    final short = e.predictedLen! < e.expectedLen!;
    return Issue(
      r, es, IssueKind.tajweed,
      '$what troppo ${short ? (isGhunna ? 'corta' : 'corto') : (isGhunna ? 'lunga' : 'lungo')}',
      'Hai tenuto ${isGhunna ? 'la ghunna' : 'il mad'} ${e.predictedLen} tempi; nella lettura scelta ne servono ${e.expectedLen}.',
      rule?.ar ?? arRule,
      expectedCount: e.expectedLen, myCount: e.predictedLen,
    );
  }
  // 2. a rule that must match (qalqala…)
  final missing = es.where((e) => e.errorType == 'tajweed' && e.refRules.any((x) => x.kind == 'Qalqalah'));
  if (missing.isNotEmpty) {
    return Issue(r, es, IssueKind.tajweed, 'Qalqala mancante',
        'La lettera ${readable(ref)} va pronunciata con il rimbalzo (qalqala).', 'قلقلة');
  }
  final e = es.first;
  // 3. something missing
  if (e.speechErrorType == 'delete' && e.predictedPh.isEmpty) {
    final isMadd = _maddLetter.containsKey(ref.isEmpty ? '' : ref[0]);
    return Issue(r, es, e.errorType == 'tajweed' ? IssueKind.tajweed : IssueKind.letter,
        isMadd ? 'Mad mancante' : 'Lettera mancante',
        'Non si sente «${readable(ref)}».', arRule.isNotEmpty ? arRule : (_typeAr[e.errorType] ?? ''));
  }
  // 4. a sound too many
  if (e.expectedPh.isEmpty) {
    return Issue(r, es, IssueKind.letter, 'Suono in più', 'Si sente in più «${readable(e.predictedPh)}».', 'زيادة');
  }
  // 5. shadda / haraka
  if (e.errorType == 'tashkeel' || (e.errorType == 'normal' && e.speechErrorType == 'insert')) {
    final exp = e.expectedPh, got = e.predictedPh;
    if (exp.isNotEmpty && got.isNotEmpty && exp[0] == got[0] && _runOf(exp) != _runOf(got)) {
      final less = _runOf(got) < _runOf(exp);
      return Issue(r, es, IssueKind.letter, less ? 'Shadda mancante' : 'Shadda in più',
          less
              ? 'La ${exp[0]} è uscita semplice: va raddoppiata (${exp[0]}ّ).'
              : 'La ${exp[0]} è uscita raddoppiata: va detta una volta sola.',
          'الشدة');
    }
    return Issue(r, es, IssueKind.letter, 'Haraka sbagliata',
        'Sulla ${exp.isEmpty ? '' : exp[0]} serve ${_haraka(exp)}, si sente ${_haraka(got)}.', 'الحركة');
  }
  // 6. another letter
  if (e.errorType == 'normal') {
    return Issue(r, es, IssueKind.letter, 'Lettera diversa',
        'Atteso «${readable(e.expectedPh)}», si sente «${readable(e.predictedPh)}».', 'خطأ في الحرف');
  }
  return Issue(r, es, IssueKind.tajweed, 'Regola non rispettata',
      'Atteso «${readable(e.expectedPh)}», si sente «${readable(e.predictedPh)}».', arRule);
}

/// How many harakat a heard group lasts, counted like the reference rule of group [r] does.
int? countFor(TakeAnalysis ref, int r, String heard) {
  final rule = ref.correction.variant.groupRules[r].where((x) => x.correctness == 'count').firstOrNull;
  if (rule == null || heard.isEmpty || ref.refGroups[r].isEmpty || heard[0] != ref.refGroups[r][0]) return null;
  return rule.count(ref.refGroups[r], heard);
}
