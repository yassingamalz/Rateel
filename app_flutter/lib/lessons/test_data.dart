import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Question types of the Angular assessment (`assessment-lesson.types.ts`).
enum QuestionType { single, multiple, trueFalse, text }

class TestOption {
  const TestOption(this.id, this.text);

  final String id;
  final String text;
}

class TestQuestion {
  const TestQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.correct,
    this.explanation,
    this.hint,
  });

  final String id;
  final String text;
  final QuestionType type;

  /// Options of single / multiple choice; true/false gets «صحيح» / «خطأ».
  final List<TestOption> options;

  /// Correct option ids (single: one; multiple: several; true/false: «true»
  /// or «false»; text: the accepted answers).
  final List<String> correct;
  final String? explanation;
  final String? hint;
}

/// A test lesson (screen 10), from the Angular data
/// `src/assets/data/content/assessments/<lessonId>.json`, bundled as
/// `assets/data/test/<lessonId>.json`.
class TestContent {
  const TestContent({
    required this.title,
    required this.description,
    required this.passingScore,
    required this.questions,
  });

  final String title;
  final String description;

  /// Percentage needed to pass (Angular default 70).
  final int passingScore;
  final List<TestQuestion> questions;

  /// Null when the lesson has no test file (Angular: «عذراً، لا يمكن تحميل
  /// محتوى الاختبار»).
  static Future<TestContent?> load(String lessonId) async {
    try {
      final raw = await rootBundle.loadString(
        'assets/data/test/$lessonId.json',
      );
      return parse(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static TestContent? parse(Map<String, dynamic> j) {
    final qs = <TestQuestion>[];
    for (final q in (j['questions'] as List? ?? const [])) {
      final m = q as Map<String, dynamic>;
      final type = switch (m['type']) {
        'singleChoice' => QuestionType.single,
        'multipleChoice' => QuestionType.multiple,
        'trueFalse' => QuestionType.trueFalse,
        'textInput' => QuestionType.text,
        _ => null,
      };
      if (type == null) continue; // matching: not in the data
      final ca = m['correctAnswer'];
      qs.add(
        TestQuestion(
          id: m['id'] as String,
          text: (m['text'] as String).trim(),
          type: type,
          options: type == QuestionType.trueFalse
              ? const [TestOption('true', 'صحيح'), TestOption('false', 'خطأ')]
              : [
                  for (final o in (m['options'] as List? ?? const []))
                    TestOption(
                      (o as Map<String, dynamic>)['id'] as String,
                      o['text'] as String,
                    ),
                ],
          correct: ca is List
              ? [for (final c in ca) '$c']
              : [if (ca != null) '$ca'],
          explanation: m['explanation'] as String?,
          hint: m['hint'] as String?,
        ),
      );
    }
    if (qs.isEmpty) return null;
    return TestContent(
      title: j['title'] as String? ?? '',
      description: j['description'] as String? ?? '',
      passingScore: (j['passingScore'] as num?)?.toInt() ?? 70,
      questions: qs,
    );
  }
}

/// State of one run of the test, with the Angular rules
/// (`assessment-service.service.ts`): 10 points per correct answer plus a
/// streak bonus (+2 per answer in the streak from the second, at most +10),
/// score = correct / questions in %, pass at [TestContent.passingScore].
class TestRun {
  TestRun(this.content);

  final TestContent content;

  /// Selected option ids (or the typed text) per question, before and after
  /// the answer is confirmed.
  final selected = <String, List<String>>{};

  /// Confirmed answers: question id → fully correct? A partly correct
  /// answer is `false` here and listed in [partial].
  final results = <String, bool>{};

  /// Multiple-choice answers partly correct (owner, 2026-11-26): some of the
  /// right options chosen, but not exactly the right set. Half the points and
  /// half a question in the score; the streak restarts.
  final partial = <String>{};
  int points = 0;
  int streak = 0;

  /// Points won by each answered question, and the points it was worth
  /// when answered (shown faded after a wrong answer).
  final earned = <String, int>{};
  final stakes = <String, int>{};

  /// Correct answers in a row when each question was answered.
  final streaks = <String, int>{};

  static const pointsPerQuestion = 10;

  int get total => content.questions.length;
  int get answered => results.length;
  int get correctCount => results.values.where((r) => r).length;
  int get partialCount => partial.length;
  int get wrongCount => results.values.where((r) => !r).length - partial.length;
  int get score => total == 0
      ? 0
      : ((correctCount + partialCount / 2) * 100 / total).round();

  bool isPartial(TestQuestion q) => partial.contains(q.id);
  bool get passed => score >= content.passingScore;
  bool get finished => answered == total;

  /// Points the next correct answer gives (shown in the «+n نقطة» pill).
  int get nextPoints =>
      pointsPerQuestion + (streak >= 1 ? ((streak + 1) * 2).clamp(0, 10) : 0);

  bool isAnswered(TestQuestion q) => results.containsKey(q.id);

  /// Angular: a question opens once the previous one is answered.
  bool isUnlocked(int i) =>
      i == 0 ||
      isAnswered(content.questions[i - 1]) ||
      isAnswered(content.questions[i]);

  bool canSubmit(TestQuestion q) {
    final s = selected[q.id] ?? const [];
    if (q.type == QuestionType.text) {
      return s.isNotEmpty && s.first.trim().isNotEmpty;
    }
    return s.isNotEmpty;
  }

  void toggle(TestQuestion q, String optionId) {
    if (isAnswered(q)) return;
    final s = [...?selected[q.id]];
    if (q.type == QuestionType.multiple) {
      s.contains(optionId) ? s.remove(optionId) : s.add(optionId);
    } else {
      s
        ..clear()
        ..add(optionId);
    }
    selected[q.id] = s;
  }

  void setText(TestQuestion q, String text) {
    if (isAnswered(q)) return;
    selected[q.id] = [text];
  }

  static String _norm(String s) => s.trim().toLowerCase();

  bool _isCorrect(TestQuestion q) {
    final s = selected[q.id] ?? const [];
    if (q.type == QuestionType.text) {
      return s.isNotEmpty && q.correct.any((c) => _norm(c) == _norm(s.first));
    }
    if (q.type == QuestionType.multiple) {
      return s.length == q.correct.length && q.correct.every(s.contains);
    }
    return s.length == 1 && q.correct.contains(s.first);
  }

  bool _isPartial(TestQuestion q) {
    if (q.type != QuestionType.multiple) return false;
    final s = selected[q.id] ?? const [];
    return s.any(q.correct.contains);
  }

  /// Confirms the answer; returns whether it is fully correct.
  bool submit(TestQuestion q) {
    final ok = _isCorrect(q);
    results[q.id] = ok;
    stakes[q.id] = nextPoints;
    if (ok) {
      final p = nextPoints;
      streak++;
      points += p;
      earned[q.id] = p;
      streaks[q.id] = streak;
    } else if (_isPartial(q)) {
      partial.add(q.id);
      final p = (pointsPerQuestion / 2).round();
      streak = 0;
      points += p;
      earned[q.id] = p;
    } else {
      streak = 0;
      earned[q.id] = 0;
    }
    return ok;
  }

  void reset() {
    selected.clear();
    results.clear();
    partial.clear();
    earned.clear();
    stakes.clear();
    streaks.clear();
    points = 0;
    streak = 0;
  }

  bool isCorrectOption(TestQuestion q, String id) => q.correct.contains(id);

  /// Text of the correct answer (feedback, details).
  String correctText(TestQuestion q) => q.type == QuestionType.text
      ? q.correct.first
      : [
          for (final o in q.options)
            if (q.correct.contains(o.id)) o.text,
        ].join('، ');

  String userText(TestQuestion q) {
    final s = selected[q.id] ?? const [];
    if (q.type == QuestionType.text) return s.isEmpty ? '' : s.first;
    return [
      for (final o in q.options)
        if (s.contains(o.id)) o.text,
    ].join('، ');
  }

  /// Angular `getRecommendations()`.
  List<String> recommendations() {
    final wrong = [
      for (final q in content.questions)
        if (results[q.id] == false) q,
    ];
    if (wrong.isEmpty) {
      return const ['أحسنت، لقد أجبت على جميع الأسئلة بشكل صحيح.'];
    }
    return [
      'مراجعة المواضيع المتعلقة بالأسئلة التي أخطأت فيها.',
      if (wrong.any((q) => q.type == QuestionType.trueFalse)) 'التركيز على فهم المفاهيم الأساسية لتحسين أدائك في أسئلة الصواب والخطأ.',
      if (wrong.any((q) => q.type == QuestionType.multiple)) 'تدرب على تحليل أسئلة الاختيار من متعدد بتمعن للتمييز بين الإجابات الصحيحة والخاطئة.',
    ];
  }
}
