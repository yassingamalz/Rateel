import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../courses/course_data.dart';
import '../lessons/lesson_data.dart';
import '../lessons/lesson_decor.dart';
import '../lessons/lesson_end.dart';
import '../lessons/lesson_shell.dart';
import '../lessons/listening_data.dart';
import '../lessons/listening_lesson_page.dart';
import '../lessons/practice_part.dart';
import '../lessons/reading_data.dart' show readingLight;
import '../lessons/test_data.dart';
import '../lessons/test_lesson_page.dart';
import '../units/unit_data.dart';
import 'practice_store.dart';

/// Size of one session (owner, 2026-11-28, Q4: fixed for v1; variable with the
/// user's progress later, BACKLOG).
const practiceListenQuestions = 3;
const practiceRuleQuestions = 4;
const practiceAyat = 2;
const practiceTotal =
    practiceListenQuestions + practiceRuleQuestions + practiceAyat;

/// The daily practice session (screen 31, plan §4): in one lesson frame (02
/// bar over the 9 steps) the listening quiz of 22 (3 questions), the rule
/// questions of 10 (4) and 2 ayat of the listening data read and heard in the
/// 22 rule view, then the end card of 24. Items come from the completed
/// lessons; with none completed yet, from the first lessons of the course
/// (owner, Q5). Returns `true` when the session is finished.
/// Review aid: `?practicePart=1|2` starts the session at its second / third
/// part; `?practiceSession=1` opens the session on start.
int practiceStartPart = 0;

Route<bool> practiceSessionRoute() =>
    lessonRoute<bool>((context) => const _SessionHost());

/// A lesson of the data with its unit, in path order.
typedef _Found = (Lesson lesson, bool done);

List<_Found> _lessons(LessonType type) {
  final out = <_Found>[];
  for (var c = 0; c < courses.length; c++) {
    for (final unit in unitsOf(c)) {
      final list = lessonsOf(unit.id);
      final done = lessonsDone(unit.id);
      for (var i = 0; i < list.length; i++) {
        if (list[i].type == type) out.add((list[i], i < done));
      }
    }
  }
  return out;
}

/// Completed lessons of [type] whose content loads; none → all of them (the
/// first lessons, owner Q5).
Future<List<T>> _pool<T>(
  LessonType type,
  Future<T?> Function(String id) load,
) async {
  final all = _lessons(type);
  Future<List<T>> loadAll(Iterable<_Found> ls) async => [
    for (final l in ls) ?(await load(l.$1.id)),
  ];
  final done = await loadAll(all.where((l) => l.$2));
  if (done.isNotEmpty) return done;
  return loadAll(all);
}

List<E> _pick<E>(List<E> from, int n, math.Random r) =>
    (List.of(from)..shuffle(r)).take(n).toList();

class _Plan {
  _Plan(this.listen, this.test, this.read);

  final ListenContent? listen;
  final TestContent? test;
  final ListenContent? read;
}

Future<_Plan> _plan() async {
  final r = math.Random(PracticeStore.key(PracticeStore.today).hashCode);
  final listening = await _pool(LessonType.listen, ListenContent.load);
  final tests = await _pool(LessonType.test, TestContent.load);
  ListenContent? listen;
  final qs = [for (final c in listening) ...c.questions];
  if (qs.isNotEmpty) {
    final c = listening.first;
    listen = ListenContent(
      title: 'تدريب اليوم',
      reciter: c.reciter,
      points: c.points,
      questions: _pick(qs, practiceListenQuestions, r),
    );
  }
  TestContent? test;
  final tq = [for (final c in tests) ...c.questions];
  if (tq.isNotEmpty) {
    test = TestContent(
      title: 'تدريب اليوم',
      description: 'أحكام',
      passingScore: 0,
      questions: _pick(tq, practiceRuleQuestions, r),
    );
  }
  // Reading: 2 ayat of a rule lesson of the listening data, with the rule's
  // colour and the recitation (owner, Q6 a).
  ListenContent? read;
  final withRule = listening.where((c) => c.rule != null && c.steps.isNotEmpty);
  if (withRule.isNotEmpty) {
    final c = withRule.first;
    read = ListenContent(
      title: 'تدريب اليوم',
      reciter: c.reciter,
      points: c.points,
      questions: const [],
      rule: c.rule,
      steps: _pick(c.steps, practiceAyat, r),
    );
  }
  return _Plan(listen, test, read);
}

class _SessionHost extends StatefulWidget {
  const _SessionHost();

  @override
  State<_SessionHost> createState() => _SessionHostState();
}

class _SessionHostState extends State<_SessionHost> {
  final _shell = GlobalKey<LessonShellState>();
  int _step = 0;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Route<bool> _partRoute(Widget page) => PageRouteBuilder<bool>(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, a, b) =>
        Material(color: Colors.transparent, child: page),
    transitionsBuilder: (context, a, b, child) =>
        FadeTransition(opacity: a, child: child),
  );

  void _leave(bool done) {
    if (_left || !mounted) return;
    _left = true;
    Navigator.of(context).pop(done);
  }

  Future<void> _run() async {
    final plan = await _plan();
    if (!mounted) return;
    const placeholder = Lesson(
      id: 'daily-practice',
      title: 'تدريب اليوم',
      description: '',
      type: LessonType.listen,
      minutes: 5,
    );
    final parts = <(PracticePart, Widget Function(PracticePart))>[];
    var offset = 0;
    void add(int n, ListenContent? l, TestContent? t, bool test) {
      if (l == null && t == null) return;
      final part = PracticePart(
        offset: offset,
        total: practiceTotal,
        title: 'تدريب اليوم',
        listen: l,
        test: t,
      );
      offset += n;
      parts.add((
        part,
        (p) => test
            ? TestLessonPage(
                lesson: placeholder,
                index: 1,
                count: 1,
                practice: p,
              )
            : ListeningLessonPage(lesson: placeholder, practice: p),
      ));
    }

    add(plan.listen?.questions.length ?? 0, plan.listen, null, false);
    add(plan.test?.questions.length ?? 0, null, plan.test, true);
    add(plan.read?.steps.length ?? 0, plan.read, null, false);
    if (parts.isEmpty) {
      _leave(false);
      return;
    }
    while (mounted) {
      for (final (part, page) in parts.skip(
        practiceStartPart.clamp(0, parts.length - 1),
      )) {
        setState(() => _step = part.offset);
        final ok = await Navigator.of(context).push(_partRoute(page(part)));
        if (!mounted) return;
        if (ok != true) {
          _leave(false);
          return;
        }
      }
      setState(() => _step = practiceTotal);
      await _shell.currentState?.celebrate();
      // Questions only (the ayat are read, not scored).
      var right = 0, total = 0, points = 0;
      for (final (p, _) in parts) {
        right += p.right;
        total += p.count;
        points += p.points;
      }
      PracticeStore.markDoneToday();
      final choice =
          await _shell.currentState?.finish(
            LessonEndResult.answers(
              right: right,
              total: math.max(1, total),
              points: points,
            ),
          ) ??
          LessonEndChoice.next;
      if (!mounted) return;
      practiceStartPart = 0;
      if (choice != LessonEndChoice.again) {
        _leave(true);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: readingLight,
    builder: (context, light, _) {
      final p = LessonPal(light ? 1 : 0);
      return LessonShell(
        key: _shell,
        step: _step,
        total: practiceTotal,
        light: p.t,
        onBack: () => _leave(false),
        onRestart: () {},
        child: LayoutBuilder(
          builder: (context, box) =>
              LessonBackground(p: p, u: box.maxHeight / 100),
        ),
      );
    },
  );
}
