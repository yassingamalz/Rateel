import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';

/// A marked part of a sentence: [start, end) in the text, and its rule.
class ReadingMark {
  const ReadingMark(this.start, this.end, this.rule);

  final int start;
  final int end;
  final String rule;
}

class ReadingVerse {
  const ReadingVerse(this.text, this.marks);

  final String text;
  final List<ReadingMark> marks;
}

/// Content of a reading lesson (screen 08), from the Angular data
/// `src/assets/data/content/reading/<lessonId>.json`, bundled as
/// `assets/data/reading/<lessonId>.json`.
class ReadingContent {
  const ReadingContent({required this.title, required this.verses});

  final String title;
  final List<ReadingVerse> verses;

  /// Null when the lesson has no reading file (the page shows the Angular
  /// «عذراً، لا يمكن تحميل المحتوى»).
  static Future<ReadingContent?> load(String lessonId) async {
    try {
      final raw = await rootBundle.loadString(
        'assets/data/reading/$lessonId.json',
      );
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final verses = [
        for (final v in j['verses'] as List) _verse(v as Map<String, dynamic>),
      ];
      if (verses.isEmpty) return null;
      return ReadingContent(title: j['title'] as String, verses: verses);
    } catch (_) {
      return null;
    }
  }

  /// The data's startIndex/endIndex are wrong for 38 of the 45 marks (they cut
  /// words, e.g. «لاوة الط» for «الطهارة»): the mark's own text is looked up in
  /// the sentence instead (from the end of the previous mark).
  static ReadingVerse _verse(Map<String, dynamic> v) {
    final text = v['text'] as String;
    final marks = <ReadingMark>[];
    var from = 0;
    for (final m in (v['marks'] as List? ?? const [])) {
      final mm = m as Map<String, dynamic>;
      final t = (mm['text'] as String?)?.trim() ?? '';
      final rule = mm['ruleId'] as String? ?? '';
      if (t.isEmpty) continue;
      var at = text.indexOf(t, from);
      if (at < 0) at = text.indexOf(t);
      if (at < 0) continue;
      marks.add(ReadingMark(at, at + t.length, rule));
      from = at + t.length;
    }
    marks.sort((a, b) => a.start.compareTo(b.start));
    return ReadingVerse(text, marks);
  }
}

/// Tajweed colours of the marked words (owner, 2026-11-25: «respect the
/// tajweed colours»), following the classic colour-coded mushaf: green =
/// ghunna (ikhfa, idgham with ghunna, iqlab, noon/meem mushaddad), blue =
/// qalqala, red = madd; izhar and the topic marks of the data (adab-*,
/// intention, …) stay in the text colour. Two shades: dark and light theme.
/// PROVISIONAL until the owner's list of colours.
const _tajweedGreen = (Color(0xFF5BD26B), Color(0xFF1E8C2E));
const _tajweedBlue = (Color(0xFF4FB3E8), Color(0xFF1F6FB5));
const _tajweedRed = (Color(0xFFFF6B5B), Color(0xFFC62828));
const _tajweedByRule = {
  'ikhfa': _tajweedGreen,
  'idgham': _tajweedGreen,
  'iqlab': _tajweedGreen,
  'ghunnah': _tajweedGreen,
  'shaddah': _tajweedGreen,
  'qalqalah': _tajweedBlue,
  'madd': _tajweedRed,
};

/// Colour of a tajweed rule for the theme mix [light] (0 dark … 1 light);
/// null for marks that are not tajweed rules.
Color? tajweedColor(String rule, double light) {
  final c = _tajweedByRule[rule];
  return c == null ? null : Color.lerp(c.$1, c.$2, light);
}

/// A tajweed rule of the «قواعد التجويد» panel. Names and descriptions are
/// the Angular service's (`reading-lesson.service.ts`, the only rules with a
/// definition). Dot colours: the tajweed colours of [tajweedColor] for the
/// tajweed rules (green ghunna, blue qalqala), the app gold for the others
/// (owner 2026-11-25: tajweed colours, app-standard colours).
class TajweedRule {
  const TajweedRule(this.id, this.name, this.description, this.color);

  final String id;
  final String name;
  final String description;
  final Color color;
}

const tajweedRules = [
  TajweedRule(
    'idgham',
    'إدغام',
    'دمج حرفين متماثلين أو متقاربين بحيث يصيران حرفاً واحداً مشدداً',
    Color(0xFF5BD26B),
  ),
  TajweedRule(
    'ikhfa',
    'إخفاء',
    'النطق بالحرف بصفة بين الإظهار والإدغام',
    Color(0xFF5BD26B),
  ),
  TajweedRule(
    'qalqalah',
    'قلقلة',
    'اضطراب الصوت عند النطق بالحرف الساكن حتى يسمع له نبرة قوية',
    Color(0xFF4FB3E8),
  ),
  TajweedRule(
    'adab-general',
    'آداب عامة',
    'الآداب العامة المتعلقة بتلاوة القرآن الكريم',
    Color(0xFFE9B83A),
  ),
  TajweedRule(
    'adab-title',
    'عنوان',
    'عناوين الآداب والأقسام',
    Color(0xFFE9B83A),
  ),
  TajweedRule(
    'quran-verse',
    'آية قرآنية',
    'آية من القرآن الكريم',
    Color(0xFFE9B83A),
  ),
];

/// Reading preferences, kept for the session (Angular: theme service and the
/// reading service's state). Light/dark of the reading (moon button, owner
/// 2026-11-25), text size 18–36 px step 2 (default 24 = the reference's
/// size), line spacing 1.0–3.0× step 0.1 (default 2.0).
final readingLight = ValueNotifier<bool>(false);
int readingFontSize = 24;
double readingLineHeight = 2.0;
