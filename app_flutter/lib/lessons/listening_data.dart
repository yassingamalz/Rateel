import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Data of a listening lesson (screen 22), `assets/data/listening/<id>.json`
/// (mock until real data: `tools/flutter-review/gen_listening_data.py`).
class ListenWord {
  const ListenWord(this.text, this.startMs, this.endMs);

  final String text;
  final int startMs;
  final int endMs;
}

class ListenAyah {
  const ListenAyah({
    required this.id,
    required this.surah,
    required this.ayah,
    required this.audio,
    required this.durationMs,
    required this.words,
    required this.peaks,
  });

  final String id;
  final String surah;
  final int ayah;

  /// Asset path under `assets/` (audioplayers `AssetSource`).
  final String audio;
  final int durationMs;
  final List<ListenWord> words;

  /// Waveform bars 0–1 (51, as the reference).
  final List<double> peaks;

  /// Index of the word recited at [ms], or -1.
  int wordAt(int ms) {
    for (var i = 0; i < words.length; i++) {
      if (ms >= words[i].startMs && ms < words[i].endMs) return i;
    }
    return -1;
  }
}

class ListenQuestion {
  const ListenQuestion({
    required this.ayah,
    required this.word,
    required this.prompt,
    required this.options,
    required this.correct,
    required this.explanation,
  });

  final ListenAyah ayah;

  /// Index of the asked word in the ayah.
  final int word;
  final String prompt;

  /// Options in RTL order (the first one on the right).
  final List<String> options;
  final String correct;
  final String explanation;
}

/// The tajweed rule a listening lesson teaches (owner, 2026-11-26): its
/// words are coloured with the wheel colour ([colour], key of
/// `TajweedColors`).
class ListenRule {
  const ListenRule(this.name, this.short, this.colour);

  final String name;
  final String short;
  final String colour;
}

/// Letters [from, to) of word [word] that carry the rule (owner, 2026-11-26:
/// the letter is coloured, not the whole word: a word can hold several rules).
class ListenMark {
  const ListenMark(
    this.word,
    this.from,
    this.to, {
    this.holdStart,
    this.holdEnd,
    this.harakat = 0,
  });

  final int word;
  final int from;
  final int to;

  /// Where the rule is held in the audio (ms) and for how many harakat
  /// (owner, 2026-11-27: dots over the letter light up one per haraka).
  final int? holdStart;
  final int? holdEnd;
  final int harakat;
}

/// One ayah of a rule lesson: [marks] hold the rule (coloured letters),
/// [note] says where it is.
class ListenStep {
  const ListenStep({
    required this.ayah,
    required this.marks,
    required this.note,
  });

  final ListenAyah ayah;
  final List<ListenMark> marks;
  final String note;

  ListenMark? markOf(int word) {
    for (final m in marks) {
      if (m.word == word) return m;
    }
    return null;
  }
}

class ListenContent {
  const ListenContent({
    required this.title,
    required this.reciter,
    required this.points,
    required this.questions,
    this.rule,
    this.steps = const [],
    this.finds = const [],
    this.narration = const {},
  });

  /// Guided voice (owner, 2026-11-26: Gemini TTS «Orus», calm style): moment
  /// (`intro`, `find`, `letter`) → key of `audio/narration/orus/<key>.mp3`.
  final Map<String, String> narration;

  /// End of a rule lesson (owner, 2026-11-26): an ayah plays without colours,
  /// the student taps the word where the rule was heard, then its letter.
  final List<ListenStep> finds;

  /// Rule lesson: the ayat with the rule first ([steps]), then [questions] as a
  /// short check. Without a rule: a listening quiz (questions only).
  final ListenRule? rule;
  final List<ListenStep> steps;

  final String title;
  final String reciter;

  /// Points of a right answer (owner, 2026-11-26: +10 as tests, no pass/fail).
  final int points;
  final List<ListenQuestion> questions;

  static Future<ListenContent?> load(String lessonId) async {
    try {
      final raw = await rootBundle.loadString(
        'assets/data/listening/$lessonId.json',
      );
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final ayat = <String, ListenAyah>{
        for (final a in (j['ayat'] as List).cast<Map<String, dynamic>>())
          a['id'] as String: ListenAyah(
            id: a['id'] as String,
            surah: a['surah'] as String,
            ayah: a['ayah'] as int,
            audio: a['audio'] as String,
            durationMs: a['durationMs'] as int,
            words: [
              for (final w in (a['words'] as List).cast<Map<String, dynamic>>())
                ListenWord(
                  w['text'] as String,
                  w['startMs'] as int,
                  w['endMs'] as int,
                ),
            ],
            peaks: [for (final p in a['peaks'] as List) (p as num).toDouble()],
          ),
      };
      final r = j['rule'] as Map<String, dynamic>?;
      return ListenContent(
        rule: r == null
            ? null
            : ListenRule(
                r['name'] as String,
                r['short'] as String,
                r['colour'] as String,
              ),
        steps: [
          for (final s
              in (j['steps'] as List? ?? const []).cast<Map<String, dynamic>>())
            ListenStep(
              ayah: ayat[s['ayah'] as String]!,
              marks: [
                for (final m
                    in (s['marks'] as List).cast<Map<String, dynamic>>())
                  ListenMark(
                    m['word'] as int,
                    (m['letters'] as List)[0] as int,
                    (m['letters'] as List)[1] as int,
                    holdStart: (m['hold'] as List?)?[0] as int?,
                    holdEnd: (m['hold'] as List?)?[1] as int?,
                    harakat: m['harakat'] as int? ?? 0,
                  ),
              ],
              note: s['note'] as String,
            ),
        ],
        finds: [
          for (final f
              in (j['finds'] as List? ?? const []).cast<Map<String, dynamic>>())
            ListenStep(
              ayah: ayat[f['ayah'] as String]!,
              marks: [
                for (final m
                    in (f['marks'] as List).cast<Map<String, dynamic>>())
                  ListenMark(
                    m['word'] as int,
                    (m['letters'] as List)[0] as int,
                    (m['letters'] as List)[1] as int,
                  ),
              ],
              note: '',
            ),
        ],
        narration: (j['narration'] as Map<String, dynamic>? ?? const {}).map(
          (k, v) => MapEntry(k, v as String),
        ),
        title: j['title'] as String,
        reciter: j['reciter'] as String,
        points: j['pointsPerQuestion'] as int? ?? 10,
        questions: [
          for (final q in (j['questions'] as List).cast<Map<String, dynamic>>())
            ListenQuestion(
              ayah: ayat[q['ayah'] as String]!,
              word: q['word'] as int,
              prompt: q['prompt'] as String,
              options: (q['options'] as List).cast<String>(),
              correct: q['correct'] as String,
              explanation: q['explanation'] as String,
            ),
        ],
      );
    } catch (_) {
      return null;
    }
  }
}

/// Letters of an Arabic word as clusters [from, to) (a letter with its marks),
/// for the letter question of a rule lesson.
List<(int, int)> letterClusters(String word) {
  bool mark(int c) =>
      (c >= 0x064B && c <= 0x065F) ||
      c == 0x0670 ||
      (c >= 0x06D6 && c <= 0x06ED);
  final out = <(int, int)>[];
  var i = 0;
  while (i < word.length) {
    var j = i + 1;
    while (j < word.length && mark(word.codeUnitAt(j))) {
      j++;
    }
    out.add((i, j));
    i = j;
  }
  return out;
}
