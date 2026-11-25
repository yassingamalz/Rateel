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

/// Tajweed colours for the **Quran's ayat** (owner, 2026-11-25: not for the
/// lessons' own sentences, which keep the text colour): the owner's colour wheel «قواعد ألوان
/// التجويد» (2026-11-25, `docs/design-assets/reading-lesson/
/// tajweed-colours-wheel.jpg`), sampled from it, the same in both themes.
/// Black (izhar, natural madd) is the normal text colour, so those words take
/// the theme's ink (cream on dark). Marks that are not tajweed rules (adab-*,
/// intention, a generic shadda…) keep the text colour.
class TajweedColors {
  TajweedColors._();
  static const ghunna = Color(0xFF43B76E); // green
  static const silent = Color(0xFFAAA4A5); // grey
  static const qalqala = Color(0xFF07D3DA); // cyan
  static const tafkhim = Color(0xFF0B71BB); // blue
  static const tafkhimRa = Color(0xFF013ED7); // dark blue
  static const maddLazim = Color(0xFF8E4590); // purple
  static const maddWajib = Color(0xFFCD1518); // red
  static const maddArid = Color(0xFFF08237); // orange
  static const maddSila = Color(0xFFFFD231); // yellow
}

const _tajweedByRule = {
  // Green: الإدغام بغنة، إدغام المتماثلين بغنة، الإقلاب، النون والميم
  // المشددتين، إخفاء شفوي، إخفاء حقيقي. The data's generic «idgham» is read as
  // الإدغام بغنة (to confirm with the owner).
  'idgham': TajweedColors.ghunna,
  'idgham-ghunnah': TajweedColors.ghunna,
  'idgham-mutamathilain': TajweedColors.ghunna,
  'iqlab': TajweedColors.ghunna,
  'ghunnah': TajweedColors.ghunna,
  'noon-meem-mushaddad': TajweedColors.ghunna,
  'ikhfa': TajweedColors.ghunna,
  'ikhfa-shafawi': TajweedColors.ghunna,
  // Grey: الإدغام بدون غنة، المتجانسين، المتقاربين، المرسوم خلاف اللفظ، همزة
  // الوصل، ألف التفريق، اللام الشمسية.
  'idgham-no-ghunnah': TajweedColors.silent,
  'idgham-mutajanisain': TajweedColors.silent,
  'idgham-mutaqaribain': TajweedColors.silent,
  'silent': TajweedColors.silent,
  'hamzat-wasl': TajweedColors.silent,
  'lam-shamsiyyah': TajweedColors.silent,
  // Blues: قلقلة، تفخيم، تفخيم الراء.
  'qalqalah': TajweedColors.qalqala,
  'tafkhim': TajweedColors.tafkhim,
  'tafkhim-ra': TajweedColors.tafkhimRa,
  // Madd: لازم/فرق، واجب/صلة كبرى، لين/عارض، صلة صغرى/ألف خنجرية.
  'madd-lazim': TajweedColors.maddLazim,
  'madd-farq': TajweedColors.maddLazim,
  'madd-wajib': TajweedColors.maddWajib,
  'madd-munfasil': TajweedColors.maddWajib,
  'madd-muttasil': TajweedColors.maddWajib,
  'madd-sila-kubra': TajweedColors.maddWajib,
  'madd-arid': TajweedColors.maddArid,
  'madd-leen': TajweedColors.maddArid,
  'madd-sila-sughra': TajweedColors.maddSila,
  'alif-khanjariyyah': TajweedColors.maddSila,
};

/// Colour of a tajweed rule (the same in both themes; [light] kept for a
/// future per-theme shade);
/// null for marks that are not tajweed rules.
Color? tajweedColor(String rule, double light) => _tajweedByRule[rule];

/// A tajweed rule of the «قواعد التجويد» panel. Names and descriptions are
/// the Angular service's (`reading-lesson.service.ts`, the only rules with a
/// definition). Dot colours: the tajweed colours of [tajweedColor] for the
/// tajweed rules (owner's wheel: green ghunna, cyan qalqala), the app gold for the others
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
    TajweedColors.ghunna,
  ),
  TajweedRule(
    'ikhfa',
    'إخفاء',
    'النطق بالحرف بصفة بين الإظهار والإدغام',
    TajweedColors.ghunna,
  ),
  TajweedRule(
    'qalqalah',
    'قلقلة',
    'اضطراب الصوت عند النطق بالحرف الساكن حتى يسمع له نبرة قوية',
    TajweedColors.qalqala,
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
