import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';

/// Content of a reading lesson (screen 08), from the Angular data
/// `src/assets/data/content/reading/<lessonId>.json`, bundled as
/// `assets/data/reading/<lessonId>.json`.
class ReadingContent {
  const ReadingContent({required this.title, required this.verses});

  final String title;
  final List<String> verses;

  /// Null when the lesson has no reading file (the page shows the Angular
  /// «عذراً، لا يمكن تحميل المحتوى»).
  static Future<ReadingContent?> load(String lessonId) async {
    try {
      final raw = await rootBundle.loadString(
        'assets/data/reading/$lessonId.json',
      );
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final verses = [
        for (final v in j['verses'] as List) (v as Map)['text'] as String,
      ];
      if (verses.isEmpty) return null;
      return ReadingContent(title: j['title'] as String, verses: verses);
    } catch (_) {
      return null;
    }
  }
}

/// A tajweed rule of the «قواعد التجويد» panel. Names and descriptions are
/// the Angular service's (`reading-lesson.service.ts`, the only rules with a
/// definition); the dot colours follow the panel reference
/// (`reference-panel.png`: orange, green, blue, violet), readable on both
/// themes (owner 2026-11-25: the verse text stays cream, no colour marks).
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
    Color(0xFFF2A93B),
  ),
  TajweedRule(
    'ikhfa',
    'إخفاء',
    'النطق بالحرف بصفة بين الإظهار والإدغام',
    Color(0xFF5FC35A),
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
    Color(0xFFA98BE8),
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
    Color(0xFFD08A4E),
  ),
];

/// Reading preferences, kept for the session (Angular: theme service and the
/// reading service's state). Light/dark of the reading (moon button, owner
/// 2026-11-25), text size 18–36 px step 2 (default 24 = the reference's
/// size), line spacing 1.0–3.0× step 0.1 (default 2.0).
final readingLight = ValueNotifier<bool>(false);
int readingFontSize = 24;
double readingLineHeight = 2.0;
