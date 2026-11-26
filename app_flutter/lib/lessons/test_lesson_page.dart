import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../core/sounds.dart';
import '../theme/rateel_theme.dart';
import 'lesson_data.dart';
import 'lesson_decor.dart';
import 'lesson_shell.dart';
import 'lesson_widgets.dart';
import 'reading_data.dart' show readingLight;
import 'reading_lesson_page.dart' show readingStartLight;
import 'test_data.dart';

/// Review aids (screen 10): `?testQ=4` opens question 4 (0-based; the earlier
/// ones answered right), `?testPick=1,2` selects those options,
/// `?testState=ok|ko|partial|streak|results|fail|details` shows that state, with
/// `?readTheme=light` for the light theme.
int testStartQuestion = 0;
List<int> testStartPick = const [];
String? testStartState;

/// Review aid: `?testRight=6` answers the first 6 questions right (results).
int? testStartRight;

/// Geometry of screen 10 in u (1% of the screen height), measured on
/// `screens/10-test-lesson/reference.webp` (1842×854, u = 8.54 px). x values
/// from the card edges or the screen centre.
class TestMetrics {
  TestMetrics._();
  static const side = 4.9;
  // Header: arch R4 fitted on reference 10 (overlay): 97.2 × 13.8u, flatter
  // than 08, top 1.4u; the shoulders match, the reference's lower right lobe
  // runs ≈ 4u longer (shape of the asset). No book emblem.
  static const header = HeaderSpec(
    archW: 97.2,
    archH: 13.8,
    archTop: 1.4,
    archClipDx: -37.6,
    mosqueDx: -58.6,
    mosqueTop: 3.5,
    mosqueW: 29.4,
    crescentDx: 43.44,
    crescentTop: 4.5,
    crescentH: 7.6,
    starDx: 48.0,
    starTop: 5.9,
    starH: 3.4,
    titleCentre: 10.5,
    titleSize: 5.9,
    dividerTop: 21.9,
    dividerW: 78.0,
    dividerDiamond: 1.3,
    book: false,
    goldTitle: true,
    subtitleCentre: 17.4,
    subtitleSize: 3.0,
    subtitleColor: RateelColors.testSubtitle,
  );
  // Moon button under the capsule.
  static const moonCx = 11.5;
  static const moonCy = 22.0;
  static const moonD = 8.8;
  // Question circles.
  static const navY = 28.2;
  static const navD = 7.4;
  static const navStep = 11.42;
  static const navText = 4.2;
  // Card.
  static const cardTop = 34.7;
  static const cardBottom = 94.6;
  static const cardRadius = 3.6;
  static const badgeCx = 9.25; // from the card's right edge
  static const badgeCy = 7.0; // from the card top
  static const badgeH = 9.8;
  static const qRight = 17.2; // card right → question text
  static const qCy = 6.6;
  static const qSize = 4.3;
  static const pillLeft = 4.5; // card left → «+10 نقطة»
  static const pillW = 27.4;
  static const pillH = 7.7;
  static const pillCy = 7.3;
  static const pillText = 3.7;
  // Option rows.
  static const rowInset = 4.9;
  static const rowTop = 14.8; // from the card top
  static const rowH = 9.5;
  static const rowGap = 2.9;
  static const rowRadius = 1.9;
  static const rowRim = 0.3;
  static const radioRight = 5.9; // row right → radio centre
  static const radioD = 6.2;
  static const optRight = 13.6; // row right → option text
  static const optSize = 3.7;
  static const listBottom = 76.7; // the band starts here (screen y)
  // «تأكيد الإجابة» and its diamond lines.
  static const btnW = 43.8;
  static const btnH = 10.5;
  static const btnTop = 81.0;
  static const btnText = 3.9;
  static const lineDx = 37.1;
  static const lineW = 34.0;
  static const lineY = 86.2;
  // Feedback bar (owner's choice A, mockup feedback-a-*.jpg).
  static const fbTop = 74.9;
  static const fbH = 17.6;
  static const fbRadius = 2.8;
  static const fbMedal = 10.3;
  static const fbPad = 4.0;
  static const fbTitle = 4.7;
  static const fbPoints = 3.75;
  static const fbText = 3.0;
  static const fbBtnW = 42.0;
  static const fbBtnH = 10.3;
}

Route<bool> testLessonRoute(
  Lesson lesson,
  int index,
  int count, {
  bool completed = false,
}) => lessonRoute<bool>(
  (context) => TestLessonPage(
    lesson: lesson,
    index: index,
    count: count,
    completed: completed,
  ),
);

enum _Phase { question, results }

/// Screens 10 / 10b, test lesson (owner, 2026-11-25; plan
/// `docs/flutter/screens/10-test-lesson.md`): the Angular assessment
/// (`assessment-lesson`, `assessment/`) in the reference's look. Question
/// circles (sequential, answered ones reviewable), one question at a time on
/// the gold card, options in one column scrolling under the lattice band,
/// «تأكيد الإجابة» → feedback bar inside the card (variant A) with
/// «السؤال التالي» / «إنهاء الاختبار», then the end popup (score, points,
/// pass at 70%, auto-close) and the results (score ring, stats, answers →
/// details, recommendations, «إعادة الاختبار», «إنهاء الدرس»). No «تخطي»
/// (owner). Returns `true` when the lesson is finished.
class TestLessonPage extends StatefulWidget {
  const TestLessonPage({
    super.key,
    required this.lesson,
    required this.index,
    required this.count,
    this.completed = false,
  });

  final Lesson lesson;
  final int index;
  final int count;
  final bool completed;

  @override
  State<TestLessonPage> createState() => _TestLessonPageState();
}

class _TestLessonPageState extends State<TestLessonPage>
    with TickerProviderStateMixin {
  final _shell = GlobalKey<LessonShellState>();
  late final _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _theme = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    value: readingLight.value ? 1 : 0,
  );
  // Question change: content slides out / in (RTL: next comes from the left).
  late final _swap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    value: 1,
  );
  // Feedback bar slides up from under the button.
  late final _fb = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  // Wrong answer: the chosen row shakes.
  late final _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  // Details popup of an answer.
  late final _details = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  // Results: score ring fill.
  late final _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  // Streak banner (Angular streak indicator, owner 2026-11-26: «we lost the
  // screen of the correct answers in a row»): pops over the card for 1.9 s.
  late final _streakAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  TestContent? _content;
  TestRun? _run;
  bool _loaded = false;
  int _index = 0;
  int _dir = 1;
  _Phase _phase = _Phase.question;
  int? _detailsIndex;
  bool _finishing = false;
  bool _left = false;
  final _text = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (readingStartLight) {
      readingLight.value = true;
      _theme.value = 1;
    }
    TestContent.load(widget.lesson.id).then((c) {
      if (!mounted) return;
      setState(() {
        _content = c;
        _loaded = true;
        if (c != null) {
          _run = TestRun(c);
          _applyReviewAids();
        }
      });
    });
  }

  void _applyReviewAids() {
    final run = _run!;
    final qs = run.content.questions;
    final q0 = testStartQuestion.clamp(0, qs.length - 1);
    final state = testStartState;
    final all =
        state == 'results' ||
        state == 'pass' ||
        state == 'fail' ||
        state == 'details';
    final upTo = all ? qs.length : q0;
    for (var i = 0; i < upTo; i++) {
      final q = qs[i];
      final right = testStartRight != null
          ? i < testStartRight!
          : state != 'fail' || (i.isEven && i < 6);
      if (q.type == QuestionType.text) {
        run.setText(q, right ? q.correct.first : '—');
      } else if (!right && q.type == QuestionType.multiple) {
        // Review: a wrong multiple-choice answer is a partial one.
        run.toggle(q, q.correct.first);
      } else {
        for (final o in q.options) {
          if (run.isCorrectOption(q, o.id) == right) {
            run.toggle(q, o.id);
            if (q.type != QuestionType.multiple) break;
          }
        }
      }
      run.submit(q);
    }
    _index = all ? qs.length - 1 : q0;
    final q = qs[_index];
    if (!all) {
      for (final k in testStartPick) {
        if (k < q.options.length) run.toggle(q, q.options[k].id);
      }
      if (state == 'partial' && q.type == QuestionType.multiple) {
        run.toggle(q, q.correct.first);
        run.submit(q);
        _fb.value = 1;
        _revealAnswer(q);
      }
      if (state == 'ok' || state == 'ko' || state == 'streak') {
        if (testStartPick.isEmpty) {
          for (final o in q.options) {
            final right = run.isCorrectOption(q, o.id);
            if (right == (state != 'ko')) {
              run.toggle(q, o.id);
              if (q.type != QuestionType.multiple) break;
            }
          }
          if (q.type == QuestionType.text) {
            run.setText(q, state != 'ko' ? q.correct.first : 'من');
          }
        }
        run.submit(q);
        _fb.value = 1;
        _revealAnswer(q);
        if (state == 'streak') _streakAnim.value = 0.45;
      }
    }
    if (all) {
      _phase = _Phase.results;
      _ring.value = 1;
      if (state == 'details') {
        _detailsIndex = 1;
        _details.value = 1;
      }
    }
    if (q.type == QuestionType.text) {
      _text.text = (run.selected[q.id] ?? const ['']).first;
    }
  }

  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    const assets = [
      'assets/ui/reading/lattice_tile.webp',
      'assets/ui/reading/badge_line.webp',
      'assets/ui/reading/badge_fill.webp',
      'assets/ui/reading/arch.webp',
      'assets/ui/test/trophy.webp',
      'assets/ui/test/flame_medallion.webp',
      'assets/ui/test/flame.webp',
      'assets/ui/test/star_coin_gold.webp',
      'assets/ui/decor/mosque.webp',
    ];
    Future.any([
      Future.wait([
        for (final a in assets) precacheImage(AssetImage(a), context),
      ]),
      Future<void>.delayed(const Duration(milliseconds: 400)),
    ]).whenComplete(() {
      if (mounted && !_entry.isAnimating && _entry.value == 0) {
        _entry.forward();
      }
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    _theme.dispose();
    _swap.dispose();
    _fb.dispose();
    _shake.dispose();
    _details.dispose();
    _ring.dispose();
    _streakAnim.dispose();
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  TestQuestion? get _q => _run?.content.questions[_index];

  void _leave(bool done) {
    if (_left || !mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    _left = true;
    Navigator.of(context).pop(done);
  }

  void _toggleTheme() {
    readingLight.value = !readingLight.value;
    readingLight.value ? _theme.forward() : _theme.reverse();
  }

  // ---- Question flow ----------------------------------------------------

  void _select(TestOption o) {
    final run = _run, q = _q;
    if (run == null || q == null || run.isAnswered(q) || _finishing) return;
    Haptics.tick();
    setState(() => run.toggle(q, o.id));
  }

  void _confirm() {
    final run = _run, q = _q;
    if (run == null || q == null || run.isAnswered(q)) return;
    if (!run.canSubmit(q)) {
      Haptics.denied();
      return;
    }
    FocusScope.of(context).unfocus();
    final ok = run.submit(q);
    setState(() {});
    if (ok) {
      Sounds.correct();
      Haptics.success();
      if (run.streak > 1) {
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          if (!mounted) return;
          Sounds.streak();
          _streakAnim.forward(from: 0);
        });
      }
    } else {
      Sounds.wrong();
      Haptics.denied();
      _shake.forward(from: 0);
    }
    _fb.forward(from: 0);
    _revealAnswer(q);
  }

  /// After the answer the list is shorter (the feedback bar): scroll so that
  /// the correct row (and the chosen one, when wrong) are in view.
  void _revealAnswer(TestQuestion q) {
    if (q.type == QuestionType.text) return;
    final run = _run!;
    final sel = run.selected[q.id] ?? const [];
    final idx = [
      for (final (i, o) in q.options.indexed)
        if (run.isCorrectOption(q, o.id) || sel.contains(o.id)) i,
    ];
    if (idx.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final pos = _scroll.position;
      final stride = pos.viewportDimension > 0
          ? (TestMetrics.rowH + TestMetrics.rowGap) *
                (MediaQuery.sizeOf(context).height / 100)
          : 0.0;
      final first = idx.reduce(math.min), last = idx.reduce(math.max);
      // Rows [first, last] fit: show from the first; otherwise the correct one.
      final fits = (last - first + 1) * stride <= pos.viewportDimension;
      final correct = q.options.indexWhere((o) => run.isCorrectOption(q, o.id));
      final target = (fits ? first : correct) * stride;
      final top = pos.pixels;
      final bottom = top + pos.viewportDimension;
      final endRow = (fits ? last : correct) * stride + stride;
      if (target >= top && endRow <= bottom) return;
      _scroll.animateTo(
        target.clamp(0.0, pos.maxScrollExtent),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _goTo(int i) {
    final run = _run;
    if (run == null || i == _index || _finishing) return;
    if (i < 0 || i >= run.total) return;
    if (!run.isUnlocked(i)) {
      Haptics.denied();
      return;
    }
    Haptics.tick();
    setState(() {
      _dir = i > _index ? 1 : -1;
      _index = i;
      final q = _q!;
      _text.text = q.type == QuestionType.text
          ? (run.selected[q.id] ?? const ['']).first
          : '';
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _fb.value = run.isAnswered(_q!) ? 1 : 0;
    if (run.isAnswered(_q!)) _revealAnswer(_q!);
    _swap.forward(from: 0);
  }

  /// «السؤال التالي»: the next question, or the first one not answered yet;
  /// when all are answered, «إنهاء الاختبار».
  void _next() {
    final run = _run;
    if (run == null) return;
    if (run.finished) {
      _finishTest();
      return;
    }
    var n = _index + 1;
    while (n < run.total && run.isAnswered(run.content.questions[n])) {
      n++;
    }
    if (n >= run.total) {
      n = run.content.questions.indexWhere((q) => !run.isAnswered(q));
    }
    _goTo(n);
  }

  void _finishTest() {
    final run = _run;
    if (run == null) return;
    Haptics.milestone();
    setState(() {
      _phase = _Phase.results;
      _fb.value = 0;
    });
    _ring.forward(from: 0);
    // No end popup any more (owner, 2026-11-26: the results show the same;
    // in the backlog): the ring fills, sound and haptic when passed.
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (run.passed) {
        Sounds.passed();
        Haptics.lessonDone();
      } else {
        Haptics.tap();
      }
    });
  }

  void _restart() {
    final run = _run;
    if (run == null) return;
    _details.value = 0;
    setState(() {
      run.reset();
      _phase = _Phase.question;
      _dir = -1;
      _index = 0;
      _text.clear();
    });
    _fb.value = 0;
    _swap.forward(from: 0);
  }

  Future<void> _completeLesson() async {
    if (_finishing || _left) return;
    // A test not passed does not complete the lesson: the next one stays
    // locked (owner, 2026-11-26).
    if (_run?.passed != true) {
      Haptics.tap();
      _leave(false);
      return;
    }
    _finishing = true;
    Haptics.success();
    await _shell.currentState?.celebrate();
    _leave(true);
  }

  void _openDetails(int i) {
    Haptics.tap();
    setState(() => _detailsIndex = i);
    _details.forward(from: 0);
  }

  // Entry: header first, then the circles, the card (70 ms steps), as 08.
  Widget _enter(int k, Widget child) => AnimatedBuilder(
    animation: _entry,
    child: child,
    builder: (context, child) {
      final t = Curves.easeOutCubic.transform(
        ((_entry.value - k * 0.07) / 0.6).clamp(0.0, 1.0),
      );
      return Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 12),
          child: child,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        final light = Curves.easeInOut.transform(_theme.value);
        final run = _run;
        return LessonShell(
          key: _shell,
          step: run?.answered ?? 0,
          total: run?.total ?? 1,
          light: light,
          onBack: () => _leave(false),
          onRestart: _restart,
          child: LayoutBuilder(
            builder: (context, box) =>
                _page(box, LessonPal(light), box.maxHeight / 100),
          ),
        );
      },
    );
  }

  Widget _page(BoxConstraints box, LessonPal p, double u) {
    final w = box.maxWidth;
    final cx = w / 2;
    final card = Rect.fromLTRB(
      u * TestMetrics.side,
      u * TestMetrics.cardTop,
      w - u * TestMetrics.side,
      u * TestMetrics.cardBottom,
    );
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        RepaintBoundary(
          key: const ValueKey('bg'),
          child: LessonBackground(p: p, u: u),
        ),
        RepaintBoundary(
          key: const ValueKey('header'),
          child: _enter(
            0,
            LessonHeader(
              p: p,
              u: u,
              cx: cx,
              s: TestMetrics.header,
              title: _content?.title ?? widget.lesson.title,
              subtitle: _content?.description ?? widget.lesson.description,
            ),
          ),
        ),
        Positioned(
          key: const ValueKey('moon'),
          left: u * (TestMetrics.moonCx - TestMetrics.moonD / 2),
          top: u * (TestMetrics.moonCy - TestMetrics.moonD / 2),
          width: u * TestMetrics.moonD,
          height: u * TestMetrics.moonD,
          child: _enter(
            0,
            LessonRoundButton(
              u: u,
              label: p.t > 0.5 ? 'الوضع المظلم' : 'الوضع الفاتح',
              compact: true,
              glyph: PillGlyph.play,
              light: p.t,
              onTap: _toggleTheme,
              child: SizedBox(
                width: u * 4.4,
                height: u * 4.4,
                child: CustomPaint(
                  painter: MoonPainter(
                    p.c(RateelColors.leaderText, RateelColors.readLInk),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_run != null)
          Positioned(
            key: const ValueKey('nav'),
            left: 0,
            right: 0,
            top: u * (TestMetrics.navY - TestMetrics.navD / 2 - 1),
            height: u * (TestMetrics.navD + 2),
            child: _enter(1, RepaintBoundary(child: _navigator(p, u, cx))),
          ),
        Positioned.fromRect(
          key: const ValueKey('card'),
          rect: card,
          child: _enter(2, _card(p, u, card)),
        ),
        AnimatedBuilder(
          key: const ValueKey('streak'),
          animation: _streakAnim,
          builder: (context, _) {
            final v = _streakAnim.value;
            final run = _run;
            if (v == 0 || v == 1 || run == null) return const SizedBox.shrink();
            final inT = Curves.easeOutBack.transform(
              (v / 0.22).clamp(0.0, 1.0),
            );
            final out = ((v - 0.8) / 0.2).clamp(0.0, 1.0);
            return Positioned(
              left: 0,
              right: 0,
              top: u * 30,
              height: u * 15,
              child: IgnorePointer(
                child: Opacity(
                  opacity: (inT.clamp(0.0, 1.0)) * (1 - out),
                  child: Transform.translate(
                    offset: Offset(0, -u * 3 * out),
                    child: Transform.scale(
                      scale: 0.7 + 0.3 * inT,
                      child: Center(
                        child: _StreakBanner(
                          u: u,
                          p: p,
                          streak: run.streak,
                          bonus: run.nextPoints - TestRun.pointsPerQuestion,
                          t: v,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Details popup above everything (veil, no blur: PERFORMANCE.md).
        AnimatedBuilder(
          key: const ValueKey('details'),
          animation: _details,
          builder: (context, _) => _details.value == 0 || _detailsIndex == null
              ? const SizedBox.shrink()
              : _detailsPopup(p, u, w, box.maxHeight),
        ),
      ],
    );
  }

  // ---- Question circles ---------------------------------------------------

  Widget _navigator(LessonPal p, double u, double cx) {
    final run = _run!;
    final n = run.total;
    final d = u * TestMetrics.navD;
    return Stack(
      children: [
        for (var i = 0; i < n; i++)
          Positioned(
            // RTL: question 1 on the right.
            left: cx + u * TestMetrics.navStep * ((n - 1) / 2 - i) - d / 2,
            top: u,
            width: d,
            height: d,
            child: _NavCircle(
              key: ValueKey('nav$i'),
              u: u,
              p: p,
              number: i + 1,
              current: i == _index && _phase == _Phase.question,
              result: run.results[run.content.questions[i].id],
              partial: run.isPartial(run.content.questions[i]),
              locked: !run.isUnlocked(i),
              onTap: () => _goTo(i),
            ),
          ),
      ],
    );
  }

  // ---- Card ----------------------------------------------------------------

  Widget _card(LessonPal p, double u, Rect card) {
    final r = u * TestMetrics.cardRadius;
    final bandTop = u * TestMetrics.listBottom - card.top;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: GoldCardPainter(
              p,
              u,
              r,
              fill: const [
                RateelColors.testCardTop,
                RateelColors.testCardMid,
                RateelColors.testCardBottom,
              ],
            ),
          ),
        ),
        // Lattice band along the bottom, under the button (reference).
        Positioned(
          left: 0,
          right: 0,
          top: bandTop,
          bottom: 0,
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(r)),
              child: LatticeField(
                p: p,
                u: u,
                cell: 9.2,
                opacity: p.d(0.2, 0.4),
                mask: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x55000000), Color(0xFF000000)],
                  stops: [0.0, 0.85],
                ),
              ),
            ),
          ),
        ),
        if (_run == null)
          Center(
            child: Text(
              _loaded ? 'عذراً، لا يمكن تحميل محتوى الاختبار' : '',
              textDirection: TextDirection.rtl,
              style: readex(
                u * 4.2,
                weight: 400,
                color: p.c(RateelColors.cream, RateelColors.readLInk),
              ),
            ),
          )
        else if (_phase == _Phase.question)
          ..._questionLayers(p, u, card, bandTop)
        else
          ..._resultsLayers(p, u, card, bandTop),
      ],
    );
  }

  List<Widget> _questionLayers(
    LessonPal p,
    double u,
    Rect card,
    double bandTop,
  ) {
    final run = _run!;
    return [
      // Question content (badge, text, pill, options), sliding on a change.
      AnimatedBuilder(
        key: const ValueKey('question'),
        animation: _swap,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_swap.value);
          final dx = card.width * 0.12 * (1 - t) * _dir;
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(-dx, 0),
              child: _questionBody(p, u, card, bandTop),
            ),
          );
        },
      ),
      // Band fill under the list edge (the rows scroll under it).
      Positioned(
        left: 0,
        right: 0,
        top: bandTop,
        height: u * 0.6,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  p.c(const Color(0x33000000), const Color(0x1A6B4A2A)),
                  const Color(0x00000000),
                ],
              ),
            ),
          ),
        ),
      ),
      // «تأكيد الإجابة» with the diamond lines.
      AnimatedBuilder(
        key: const ValueKey('confirm'),
        animation: _fb,
        builder: (context, _) {
          final q = _q!;
          final hide = Curves.easeIn.transform(_fb.value);
          if (hide >= 1) return const SizedBox.shrink();
          final cx = card.width / 2;
          final y = u * TestMetrics.lineY - card.top;
          return Opacity(
            opacity: 1 - hide,
            child: Stack(
              children: [
                for (final s in [-1.0, 1.0])
                  Positioned(
                    left:
                        cx +
                        s * u * TestMetrics.lineDx -
                        u * TestMetrics.lineW / 2,
                    top: y - u * 2,
                    width: u * TestMetrics.lineW,
                    height: u * 4,
                    child: _tinted(p, GoldDivider(u: u, diamond: 1.15)),
                  ),
                Positioned(
                  left: cx - u * TestMetrics.btnW / 2,
                  top: u * TestMetrics.btnTop - card.top,
                  width: u * TestMetrics.btnW,
                  height: u * TestMetrics.btnH,
                  child: _GoldButton(
                    u: u,
                    p: p,
                    label: 'تأكيد الإجابة',
                    enabled: run.canSubmit(q),
                    onTap: _confirm,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // Feedback bar (variant A).
      AnimatedBuilder(
        key: const ValueKey('feedback'),
        animation: _fb,
        builder: (context, _) {
          final q = _q!;
          if (_fb.value == 0 || !run.isAnswered(q)) {
            return const SizedBox.shrink();
          }
          final t = Curves.easeOutBack.transform(_fb.value);
          return Positioned(
            left: u * TestMetrics.rowInset,
            right: u * TestMetrics.rowInset,
            top: u * TestMetrics.fbTop - card.top + (1 - t) * u * 6,
            height: u * TestMetrics.fbH,
            child: Opacity(
              opacity: _fb.value.clamp(0.0, 1.0),
              child: _FeedbackBar(
                u: u,
                p: p,
                ok: run.results[q.id]!,
                partial: run.isPartial(q),
                points: run.earned[q.id] ?? 0,
                streak: run.streaks[q.id] ?? 0,
                correctText: run.correctText(q),
                explanation: q.explanation,
                last: run.finished,
                onNext: _next,
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _questionBody(LessonPal p, double u, Rect card, double bandTop) {
    final run = _run!;
    final q = _q!;
    final answered = run.isAnswered(q);
    final ok = run.results[q.id];
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    final badgeW = u * TestMetrics.badgeH * 250 / 256;
    final listBottom = answered
        ? u * (TestMetrics.fbTop - 0.8) - card.top
        : bandTop;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: u * TestMetrics.badgeCx - badgeW / 2,
          top: u * (TestMetrics.badgeCy - TestMetrics.badgeH / 2),
          width: badgeW,
          height: u * TestMetrics.badgeH,
          child: LessonBadge(p: p, u: u, number: _index + 1),
        ),
        Positioned(
          right: u * TestMetrics.qRight,
          left: u * (TestMetrics.pillLeft + TestMetrics.pillW + 3),
          top: u * (TestMetrics.qCy - 4),
          height: u * 8,
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: q.text),
                    if (q.type == QuestionType.multiple)
                      TextSpan(
                        text: ' (اختر أكثر من إجابة)',
                        style: readex(
                          u * TestMetrics.qSize * 0.92,
                          weight: 400,
                          color: ink.withValues(alpha: 0.85),
                        ),
                      ),
                  ],
                ),
                textDirection: TextDirection.rtl,
                maxLines: 1,
                style: readex(
                  u * TestMetrics.qSize,
                  weight: 600,
                  color: ink,
                ).copyWith(height: 1.3, shadows: p.t > 0.5 ? null : _shadow(u)),
              ),
            ),
          ),
        ),
        Positioned(
          left: u * TestMetrics.pillLeft,
          top: u * (TestMetrics.pillCy - TestMetrics.pillH / 2),
          width: u * TestMetrics.pillW,
          height: u * TestMetrics.pillH,
          child: _PointsPill(
            u: u,
            p: p,
            points: answered
                ? (ok == true || run.isPartial(q)
                      ? run.earned[q.id] ?? 0
                      : run.stakes[q.id] ?? 0)
                : run.nextPoints,
            state: run.isPartial(q) ? true : ok,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: u * TestMetrics.rowTop - u,
          height: math.max(0, listBottom - u * TestMetrics.rowTop + u),
          child: ClipRect(child: _options(p, u, q)),
        ),
      ],
    );
  }

  Widget _options(LessonPal p, double u, TestQuestion q) {
    final run = _run!;
    final answered = run.isAnswered(q);
    final sel = run.selected[q.id] ?? const [];
    final rows = <Widget>[];
    if (q.type == QuestionType.text) {
      final ok = run.results[q.id];
      rows.add(
        _OptionRow(
          u: u,
          p: p,
          state: ok == null
              ? (sel.isNotEmpty && sel.first.isNotEmpty
                    ? _RowState.selected
                    : _RowState.idle)
              : (ok ? _RowState.correct : _RowState.wrong),
          shake: ok == false ? _shake : null,
          onTap: null,
          child: TextField(
            controller: _text,
            enabled: !answered,
            onChanged: (v) => setState(() => run.setText(q, v)),
            onSubmitted: (_) => _confirm(),
            textDirection: TextDirection.rtl,
            cursorColor: RateelColors.testSelRim,
            style: readex(
              u * TestMetrics.optSize,
              weight: 500,
              color: p.c(RateelColors.leaderText, RateelColors.readLInk),
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'اكتب إجابتك هنا...',
              hintTextDirection: TextDirection.rtl,
              hintStyle: readex(
                u * TestMetrics.optSize,
                weight: 340,
                color: p
                    .c(RateelColors.leaderText, RateelColors.readLInk)
                    .withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      );
    } else {
      for (final o in q.options) {
        final chosen = sel.contains(o.id);
        final right = run.isCorrectOption(q, o.id);
        // Multiple choice not fully right: the right options not chosen are
        // «missed» (green rim, no fill), the chosen right ones correct.
        final missed =
            answered &&
            right &&
            !chosen &&
            q.type == QuestionType.multiple &&
            run.results[q.id] == false;
        final state = !answered
            ? (chosen ? _RowState.selected : _RowState.idle)
            : missed
            ? _RowState.missed
            : right
            ? _RowState.correct
            : chosen
            ? _RowState.wrong
            : _RowState.dim;
        rows.add(
          _OptionRow(
            key: ValueKey('${q.id}-${o.id}'),
            u: u,
            p: p,
            state: state,
            shake: state == _RowState.wrong ? _shake : null,
            onTap: answered ? null : () => _select(o),
            child: Text(
              o.text,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: readex(
                u * TestMetrics.optSize,
                weight: 500,
                color: p.c(RateelColors.leaderText, RateelColors.readLInk),
              ).copyWith(height: 1.3),
            ),
          ),
        );
      }
    }
    return ListView.separated(
      controller: _scroll,
      padding: EdgeInsets.fromLTRB(
        u * TestMetrics.rowInset,
        u,
        u * TestMetrics.rowInset,
        u * 3,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: rows.length,
      separatorBuilder: (_, _) => SizedBox(height: u * TestMetrics.rowGap),
      itemBuilder: (_, i) =>
          SizedBox(height: u * TestMetrics.rowH, child: rows[i]),
    );
  }

  // ---- Results -------------------------------------------------------------

  List<Widget> _resultsLayers(
    LessonPal p,
    double u,
    Rect card,
    double bandTop,
  ) {
    final run = _run!;
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    final soft = ink.withValues(alpha: 0.8);
    final rightW = card.width * 0.44;
    return [
      // Right column: one glass panel with the ring, the message and the
      // numbers (owner chose layout A, 2026-11-26).
      Positioned(
        right: u * 4.5,
        top: u * 3.2,
        width: rightW - u * 4.5,
        height: bandTop - u * 4.2,
        child: _summaryA(p, u, run),
      ),
      // Left column: answers, then recommendations.
      Positioned(
        left: u * 4.5,
        right: rightW + u * 2,
        top: u * 3.2,
        height: bandTop - u * 3.2,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF000000), Color(0x00000000)],
            stops: [0, 0.9, 1],
          ).createShader(r),
          child: ListView(
            padding: EdgeInsets.only(bottom: u * 4),
            physics: const BouncingScrollPhysics(),
            children: [
              _sectionTitle(u, p, 'تفاصيل الإجابات'),
              for (final (i, q) in run.content.questions.indexed)
                Padding(
                  padding: EdgeInsets.only(bottom: u * 1.4),
                  child: _ResultRow(
                    u: u,
                    p: p,
                    number: i + 1,
                    text: q.text,
                    ok: run.results[q.id] ?? false,
                    partial: run.isPartial(q),
                    onTap: () => _openDetails(i),
                  ),
                ),
              SizedBox(height: u * 1.6),
              _sectionTitle(u, p, 'توصيات للتحسين'),
              for (final rec in run.recommendations())
                Padding(
                  padding: EdgeInsets.only(bottom: u * 1.4),
                  child: _GlassBox(
                    u: u,
                    p: p,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        _GoldIcon(u: u, p: p, icon: Icons.lightbulb, size: 3.4),
                        SizedBox(width: u * 1.6),
                        Expanded(
                          child: Text(
                            rec,
                            textDirection: TextDirection.rtl,
                            style: readex(
                              u * 2.9,
                              weight: 400,
                              color: soft,
                            ).copyWith(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      // Buttons on the band.
      Positioned(
        left: 0,
        right: 0,
        top: u * TestMetrics.btnTop - card.top,
        height: u * TestMetrics.btnH,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            SizedBox(
              width: u * TestMetrics.lineW,
              height: u * 4,
              child: _tinted(p, GoldDivider(u: u, diamond: 1.15)),
            ),
            SizedBox(width: u * 2.4),
            SizedBox(
              width: u * 40,
              child: _GoldButton(
                u: u,
                p: p,
                label: _run!.passed ? 'إنهاء الدرس' : 'العودة إلى الدروس',
                glyph: _run!.passed ? _BtnGlyph.check : _BtnGlyph.arrow,
                onTap: _completeLesson,
              ),
            ),
            SizedBox(width: u * 3),
            SizedBox(
              width: u * 40,
              child: _GoldButton(
                u: u,
                p: p,
                label: 'إعادة الاختبار',
                glyph: _BtnGlyph.replay,
                tone: _run!.passed ? _Tone.green : _Tone.red,
                onTap: _restart,
              ),
            ),
            SizedBox(width: u * 2.4),
            SizedBox(
              width: u * TestMetrics.lineW,
              height: u * 4,
              child: _tinted(p, GoldDivider(u: u, diamond: 1.15)),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _scoreRing(LessonPal p, double u, TestRun run, double d) => SizedBox(
    width: u * d,
    height: u * d,
    child: AnimatedBuilder(
      animation: _ring,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_ring.value);
        return CustomPaint(
          painter: _ScoreRingPainter(
            p: p,
            u: u,
            value: run.score / 100 * t,
            passed: run.passed,
            pass: run.content.passingScore / 100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(run.score * t).round()}%',
                textDirection: TextDirection.ltr,
                style: readex(
                  u * d * (run.score == 100 ? 0.21 : 0.25),
                  weight: 700,
                  color: scoreColor(
                    p,
                    run.score / 100 * t,
                    run.content.passingScore / 100,
                  ),
                ).copyWith(height: 1),
              ),
              SizedBox(height: u * 0.6),
              Text(
                run.passed ? 'ناجح' : 'لم تنجح',
                textDirection: TextDirection.rtl,
                style: readex(
                  u * d * 0.12,
                  weight: 500,
                  color: run.passed
                      ? p.c(RateelColors.testOkText, RateelColors.testLOkRim)
                      : p.c(
                          RateelColors.testKoDiscTop,
                          RateelColors.testLKoRim,
                        ),
                ).copyWith(height: 1),
              ),
            ],
          ),
        );
      },
    ),
  );

  // No «!» (owner, 2026-11-26: rare in Arabic, it reads as machine-written).
  String _resultTitle(TestRun run) => run.passed ? 'أحسنت' : 'حاول مرة أخرى';
  String _resultText(TestRun run) => run.passed
      ? 'لقد اجتزت الاختبار بنجاح.'
      : 'لم تتمكن من اجتياز الاختبار، تحتاج إلى ${run.content.passingScore}%.';

  List<_Stat> _stats(TestRun run) => [
    _Stat('${run.correctCount}', 'إجابات صحيحة', _Mark.ok),
    if (run.partialCount > 0)
      _Stat('${run.partialCount}', 'إجابات جزئية', _Mark.part),
    _Stat('${run.wrongCount}', 'إجابات خاطئة', _Mark.ko),
    _Stat('${run.points}', 'نقطة', _Mark.star),
  ];

  /// A: one glass panel, everything centred: ring, title + message, then the
  /// three numbers in columns divided by thin lines.
  Widget _summaryA(LessonPal p, double u, TestRun run) {
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    final line = p.c(RateelColors.testRowRimBottom, RateelColors.testLRowRim);
    return _GlassBox(
      u: u,
      p: p,
      padding: EdgeInsets.symmetric(vertical: u * 2, horizontal: u * 2),
      child: Column(
        children: [
          Expanded(
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                _scoreRing(p, u, run, 18),
                SizedBox(width: u * 3),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          // Owner's trophy (T4); ↻ when not passed.
                          run.passed
                              ? Image.asset(
                                  'assets/ui/test/trophy.webp',
                                  height: u * 5.2,
                                )
                              : _GoldIcon(
                                  u: u,
                                  p: p,
                                  icon: Icons.refresh,
                                  size: 4.6,
                                ),
                          SizedBox(width: u * 1.2),
                          Text(
                            _resultTitle(run),
                            textDirection: TextDirection.rtl,
                            style: readex(
                              u * 4.6,
                              weight: 700,
                              color: p.c(
                                RateelColors.testTitleTop,
                                RateelColors.readLTitle,
                              ),
                            ).copyWith(height: 1.2),
                          ),
                        ],
                      ),
                      SizedBox(height: u * 0.8),
                      Text(
                        _resultText(run),
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        style: readex(
                          u * 3.1,
                          weight: 400,
                          color: ink,
                        ).copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: u * 1.4),
            child: SizedBox(
              height: math.max(1.0, u * 0.18),
              child: ColoredBox(color: line.withValues(alpha: 0.6)),
            ),
          ),
          SizedBox(
            height: u * 10.5,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                for (final (i, s) in _stats(run).indexed) ...[
                  if (i > 0)
                    SizedBox(
                      width: math.max(1.0, u * 0.18),
                      height: u * 8,
                      child: ColoredBox(color: line.withValues(alpha: 0.6)),
                    ),
                  Expanded(
                    child: _StatColumn(u: u, p: p, stat: s),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(double u, LessonPal p, String t) => Padding(
    padding: EdgeInsets.only(bottom: u * 1.4, right: u * 0.6),
    child: Text(
      t,
      textDirection: TextDirection.rtl,
      style: readex(
        u * 3.4,
        weight: 600,
        color: p.c(RateelColors.testTitleTop, RateelColors.readLTitle),
      ),
    ),
  );

  // ---- Popups --------------------------------------------------------------

  Widget _veil(LessonPal p, double t, VoidCallback onTap) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: ColoredBox(
      color: p
          .c(RateelColors.lessonVeil, const Color(0x993B2A18))
          .withValues(alpha: (p.d(0.72, 0.45)) * t),
    ),
  );

  Widget _detailsPopup(LessonPal p, double u, double w, double h) {
    final run = _run!;
    final i = _detailsIndex!;
    final q = run.content.questions[i];
    final ok = run.results[q.id] ?? false;
    final part = run.isPartial(q);
    final t = Curves.easeOutCubic.transform(_details.value);
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    final pw = u * 96, ph = u * 74;
    void close() => _details.reverse();
    Widget label(String s) => Padding(
      padding: EdgeInsets.only(bottom: u * 0.8, right: u * 0.4),
      child: Text(
        s,
        textDirection: TextDirection.rtl,
        style: readex(u * 2.8, weight: 500, color: ink.withValues(alpha: 0.75)),
      ),
    );
    return Stack(
      children: [
        Positioned.fill(child: _veil(p, t, close)),
        Positioned(
          left: (w - pw) / 2,
          top: (h - ph) / 2,
          width: pw,
          height: ph,
          child: Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * u * 4),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GoldCardPainter(p, u, u * 3.6, rimWidth: 0.4),
                    ),
                  ),
                  Positioned(
                    left: u * 2.4,
                    top: u * 2.4,
                    width: u * 7,
                    height: u * 7,
                    child: LessonRoundButton(
                      u: u,
                      label: 'إغلاق',
                      compact: true,
                      glyph: PillGlyph.play,
                      light: p.t,
                      onTap: close,
                      child: SizedBox(
                        width: u * 2.4,
                        height: u * 2.4,
                        child: CustomPaint(painter: _CrossPainter(ink, 0.16)),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(u * 5, u * 3, u * 5, 0),
                      child: Column(
                        children: [
                          Text(
                            'السؤال ${i + 1}',
                            textDirection: TextDirection.rtl,
                            style: readex(
                              u * 4.6,
                              weight: 700,
                              color: p.c(
                                RateelColors.testTitleTop,
                                RateelColors.readLTitle,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: u * 30,
                            height: u * 2.6,
                            child: _tinted(p, GoldDivider(u: u, diamond: 0.9)),
                          ),
                          Text(
                            q.text,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: readex(u * 3.4, weight: 500, color: ink),
                          ),
                          SizedBox(height: u * 2),
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.only(bottom: u * 2),
                              children: [
                                Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    _MarkDisc(
                                      u: u,
                                      ok: ok,
                                      partial: part,
                                      d: 4.6,
                                    ),
                                    SizedBox(width: u * 1.4),
                                    Text(
                                      ok
                                          ? 'إجابة صحيحة'
                                          : part
                                          ? 'إجابة صحيحة جزئيًا'
                                          : 'إجابة خاطئة',
                                      textDirection: TextDirection.rtl,
                                      style: readex(
                                        u * 3.6,
                                        weight: 700,
                                        color: ink,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: u * 1.6),
                                label('إجابتك:'),
                                _AnswerBox(
                                  u: u,
                                  p: p,
                                  ok: ok,
                                  partial: part,
                                  text: run.userText(q),
                                ),
                                if (!ok) ...[
                                  SizedBox(height: u * 1.4),
                                  label('الإجابة الصحيحة:'),
                                  _AnswerBox(
                                    u: u,
                                    p: p,
                                    ok: true,
                                    text: run.correctText(q),
                                  ),
                                ],
                                if (q.explanation != null) ...[
                                  SizedBox(height: u * 1.4),
                                  label('الشرح:'),
                                  _GlassBox(
                                    u: u,
                                    p: p,
                                    child: Text(
                                      q.explanation!,
                                      textDirection: TextDirection.rtl,
                                      style: readex(
                                        u * 3.0,
                                        weight: 400,
                                        color: ink,
                                      ).copyWith(height: 1.45),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: u * 3, top: u),
                            child: SizedBox(
                              width: u * 30,
                              child: _GoldButton(
                                u: u,
                                p: p,
                                label: 'إغلاق',
                                glyph: _BtnGlyph.check,
                                height: 8.6,
                                fontSize: 3.5,
                                onTap: close,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

List<Shadow> _shadow(double u) => [
  Shadow(
    color: Colors.black.withValues(alpha: 0.4),
    blurRadius: u * 0.5,
    offset: Offset(0, u * 0.15),
  ),
];

/// Gold ornaments (GoldDivider) take the light theme's copper (as 08).
Widget _tinted(LessonPal p, Widget child) => p.t > 0
    ? ColorFiltered(
        colorFilter: ColorFilter.mode(
          p.c(RateelColors.videoDivider, RateelColors.readLCopper),
          BlendMode.srcIn,
        ),
        child: child,
      )
    : child;

// ---- Widgets -----------------------------------------------------------------

enum _RowState { idle, selected, correct, wrong, missed, dim }

/// An option row (reference: flat dark green glass, light green rim, pale
/// radio on the right; 10b: olive fill, gold rim, gold radio dot; feedback:
/// jewel green / red with a check / ✕ disc). Colour changes are tweened.
class _OptionRow extends StatefulWidget {
  const _OptionRow({
    super.key,
    required this.u,
    required this.p,
    required this.state,
    required this.child,
    required this.onTap,
    this.shake,
  });

  final double u;
  final LessonPal p;
  final _RowState state;
  final Widget child;
  final VoidCallback? onTap;
  final Animation<double>? shake;

  @override
  State<_OptionRow> createState() => _OptionRowState();
}

class _OptionRowState extends State<_OptionRow> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final p = widget.p;
    final s = widget.state;
    final (top, bottom, rimTop, rimBottom, glow) = switch (s) {
      _RowState.missed => (
        p.c(RateelColors.testRowFill, RateelColors.testLRowFill),
        p.c(RateelColors.testRowFill, RateelColors.testLRowFill),
        p.c(RateelColors.testOkRim, RateelColors.testLOkRim),
        p.c(RateelColors.testOkRim, RateelColors.testLOkRim),
        const Color(0x00000000),
      ),
      _RowState.idle || _RowState.dim => (
        p.c(RateelColors.testRowFill, RateelColors.testLRowFill),
        p.c(RateelColors.testRowFill, RateelColors.testLRowFill),
        p.c(RateelColors.testRowRimTop, RateelColors.testLRowRim),
        p.c(RateelColors.testRowRimBottom, RateelColors.testLRowRim),
        const Color(0x00000000),
      ),
      _RowState.selected => (
        p.c(RateelColors.testSelTop, RateelColors.testLSelTop),
        p.c(RateelColors.testSelBottom, RateelColors.testLSelBottom),
        p.c(RateelColors.testSelRim, RateelColors.testLSelRim),
        p.c(RateelColors.testSelRim, RateelColors.testLSelRim),
        RateelColors.testSelRim.withValues(alpha: 0.28 * (1 - p.t)),
      ),
      _RowState.correct => (
        p.c(RateelColors.testOkTop, RateelColors.testLOkTop),
        p.c(RateelColors.testOkBottom, RateelColors.testLOkBottom),
        p.c(RateelColors.testOkRim, RateelColors.testLOkRim),
        p.c(RateelColors.testOkRim, RateelColors.testLOkRim),
        RateelColors.testOkRim.withValues(alpha: 0.35 * (1 - p.t)),
      ),
      _RowState.wrong => (
        p.c(RateelColors.testKoTop, RateelColors.testLKoTop),
        p.c(RateelColors.testKoBottom, RateelColors.testLKoBottom),
        p.c(RateelColors.testKoRim, RateelColors.testLKoRim),
        p.c(RateelColors.testKoRim, RateelColors.testLKoRim),
        RateelColors.testKoRim.withValues(alpha: 0.3 * (1 - p.t)),
      ),
    };
    final r = u * TestMetrics.rowRadius;
    Widget row = TweenAnimationBuilder<double>(
      tween: Tween(end: s == _RowState.dim ? 0.5 : 1),
      duration: const Duration(milliseconds: 220),
      builder: (context, o, child) => Opacity(opacity: o, child: child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [top, bottom],
          ),
          boxShadow: [
            BoxShadow(color: glow, blurRadius: u * 1.6),
            BoxShadow(
              color: p
                  .c(Colors.black, const Color(0xFF8A6A4A))
                  .withValues(alpha: p.d(0.3, 0.12)),
              blurRadius: u * 0.6,
              offset: Offset(0, u * 0.35),
            ),
          ],
        ),
        child: CustomPaint(
          foregroundPainter: GradientRimPainter(
            width: math.max(1.0, u * TestMetrics.rowRim),
            radius: r,
            top: rimTop,
            bottom: rimBottom,
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              SizedBox(
                width: u * (TestMetrics.radioRight - TestMetrics.radioD / 2),
              ),
              SizedBox(
                width: u * TestMetrics.radioD,
                height: u * TestMetrics.radioD,
                child: _Marker(u: u, p: p, state: s),
              ),
              SizedBox(
                width:
                    u *
                    (TestMetrics.optRight -
                        TestMetrics.radioRight -
                        TestMetrics.radioD / 2),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  // Readex sets Arabic low: lifted 0.9u (reference centre).
                  child: Transform.translate(
                    offset: Offset(0, -u * 0.9),
                    child: widget.child,
                  ),
                ),
              ),
              SizedBox(width: u * 3),
            ],
          ),
        ),
      ),
    );
    if (widget.shake != null) {
      final sh = widget.shake!;
      row = AnimatedBuilder(
        animation: sh,
        child: row,
        builder: (context, child) => Transform.translate(
          offset: Offset(
            math.sin(sh.value * math.pi * 5) * u * 0.9 * (1 - sh.value),
            0,
          ),
          child: child,
        ),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.985 : 1,
        duration: const Duration(milliseconds: 110),
        child: row,
      ),
    );
  }
}

/// Radio of a row: pale ring; selected = gold ring with a gold dot that pops
/// in; correct / wrong = enamel disc with ✓ / ✕.
class _Marker extends StatelessWidget {
  const _Marker({required this.u, required this.p, required this.state});

  final double u;
  final LessonPal p;
  final _RowState state;

  @override
  Widget build(BuildContext context) {
    if (state == _RowState.missed) {
      final g = p.c(RateelColors.testOkRim, RateelColors.testLOkRim);
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: g, width: u * 0.42),
        ),
        child: Padding(
          padding: EdgeInsets.all(u * TestMetrics.radioD * 0.22),
          child: CustomPaint(painter: _CheckPainter(g, 0.17)),
        ),
      );
    }
    if (state == _RowState.correct || state == _RowState.wrong) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.4, end: 1),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutBack,
        builder: (context, s, child) => Transform.scale(scale: s, child: child),
        child: _MarkDisc(
          u: u,
          ok: state == _RowState.correct,
          d: TestMetrics.radioD,
        ),
      );
    }
    final sel = state == _RowState.selected;
    final ring = sel
        ? p.c(RateelColors.testSelDot, RateelColors.testLSelRim)
        : p.c(RateelColors.testRadio, RateelColors.testLRadio);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: u * 0.42),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: RateelColors.testSelDot.withValues(
                        alpha: 0.4 * (1 - p.t),
                      ),
                      blurRadius: u * 1.2,
                    ),
                  ]
                : null,
          ),
        ),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: sel ? 1 : 0),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            builder: (context, s, _) => Container(
              width: u * TestMetrics.radioD * 0.66 * s.clamp(0, 1.2),
              height: u * TestMetrics.radioD * 0.66 * s.clamp(0, 1.2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.4),
                  colors: [
                    p.c(const Color(0xFFFFE27A), const Color(0xFFE9B85A)),
                    p.c(RateelColors.testSelDot, RateelColors.testLSelRim),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Enamel disc with a ✓ (green) or ✕ (red), with a thin light rim.
class _MarkDisc extends StatelessWidget {
  const _MarkDisc({
    required this.u,
    required this.ok,
    required this.d,
    this.partial = false,
  });

  /// Partly correct (amber, ✓).
  final bool partial;

  final double u;
  final bool ok;
  final double d;

  @override
  Widget build(BuildContext context) {
    final (top, bottom, rim, glow) = partial
        ? (
            RateelColors.testPartDiscTop,
            RateelColors.testPartDisc,
            const Color(0xFFFBE3A6),
            RateelColors.testPartRim,
          )
        : ok
        ? (
            RateelColors.testOkDiscTop,
            RateelColors.testOkDisc,
            const Color(0xFFC9F2D9),
            RateelColors.testOkRim,
          )
        : (
            RateelColors.testKoDiscTop,
            RateelColors.testKoDisc,
            const Color(0xFFF7C1B4),
            RateelColors.testKoRim,
          );
    return Container(
      width: u * d,
      height: u * d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.25, -0.35),
          radius: 0.9,
          colors: [top, bottom],
        ),
        border: Border.all(
          color: rim.withValues(alpha: 0.85),
          width: math.max(1.0, u * d * 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.55),
            blurRadius: u * d * 0.25,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(u * d * 0.24),
        child: CustomPaint(
          painter: ok || partial
              ? _CheckPainter(const Color(0xFFFFFBEA), 0.17)
              : _CrossPainter(const Color(0xFFFFFBEA), 0.17),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.color, this.stroke);

  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.1, w * 0.53)
        ..lineTo(w * 0.4, w * 0.8)
        ..lineTo(w * 0.92, w * 0.22),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter o) => o.color != color;
}

class _CrossPainter extends CustomPainter {
  _CrossPainter(this.color, this.stroke);

  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()
      ..color = color
      ..strokeWidth = w * stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.15, w * 0.15), Offset(w * 0.85, w * 0.85), p);
    canvas.drawLine(Offset(w * 0.85, w * 0.15), Offset(w * 0.15, w * 0.85), p);
  }

  @override
  bool shouldRepaint(_CrossPainter o) => o.color != color;
}

/// A question circle: number on dark green glass with a light green rim;
/// current = gold disc; answered = green ✓ / red ✕ enamel.
class _NavCircle extends StatelessWidget {
  const _NavCircle({
    super.key,
    required this.u,
    required this.p,
    required this.number,
    required this.current,
    required this.result,
    this.partial = false,
    required this.locked,
    required this.onTap,
  });

  final double u;
  final LessonPal p;
  final int number;
  final bool current;
  final bool? result;
  final bool partial;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget face;
    if (result != null) {
      face = _MarkDisc(
        u: u,
        ok: result!,
        partial: partial,
        d: TestMetrics.navD,
      );
    } else {
      face = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: current
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    p.c(RateelColors.testNavOnTop, RateelColors.testLSelRim),
                    p.c(RateelColors.testNavOnBottom, RateelColors.readLTitle),
                  ],
                )
              : RadialGradient(
                  center: const Alignment(0, -0.4),
                  colors: [
                    p.c(RateelColors.testNavFill, RateelColors.testLNavFill),
                    p.c(RateelColors.readBgEdge, RateelColors.testLNavFill),
                  ],
                ),
          border: current
              ? Border.all(
                  color: p.c(const Color(0xFFFFE89A), RateelColors.testLSelRim),
                  width: u * 0.25,
                )
              : Border.all(
                  color: p.c(RateelColors.testNavRim, RateelColors.testLRowRim),
                  width: u * 0.3,
                ),
          boxShadow: [
            if (current)
              BoxShadow(
                color: RateelColors.testNavOnTop.withValues(
                  alpha: 0.45 * (1 - p.t),
                ),
                blurRadius: u * 1.6,
              ),
            BoxShadow(
              color: p
                  .c(Colors.black, const Color(0xFF8A6A4A))
                  .withValues(alpha: p.d(0.35, 0.12)),
              blurRadius: u * 0.6,
              offset: Offset(0, u * 0.3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$number',
            textDirection: TextDirection.ltr,
            style: readex(
              u * TestMetrics.navText,
              weight: current ? 600 : 400,
              color: current
                  ? p.c(const Color(0xFFFFFBEF), Colors.white)
                  : p.c(RateelColors.testNavText, RateelColors.readLInk),
            ).copyWith(height: 1.0),
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      label: 'السؤال $number',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedScale(
          scale: current ? 1.06 : 1,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => ScaleTransition(
              scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
              child: c,
            ),
            child: KeyedSubtree(
              key: ValueKey('$current$result'),
              child: Opacity(opacity: locked ? 0.85 : 1, child: face),
            ),
          ),
        ),
      ),
    );
  }
}

/// «⭐ +10 نقطة» (reference): dark olive glass, gold rim, gold star; once
/// answered right it fills with gold «+n نقطة ✓» (mockup A); wrong: faded.
class _PointsPill extends StatelessWidget {
  const _PointsPill({
    required this.u,
    required this.p,
    required this.points,
    required this.state,
  });

  final double u;
  final LessonPal p;
  final int points;
  final bool? state;

  bool get total => false;

  @override
  Widget build(BuildContext context) {
    final h = u * TestMetrics.pillH;
    final filled = state == true;
    final text = filled
        ? p.c(RateelColors.countText, RateelColors.readLInk)
        : p.c(RateelColors.testPillText, RateelColors.readLInk);
    return AnimatedOpacity(
      opacity: state == false ? 0.4 : 1,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: filled
                ? [
                    p.c(const Color(0xFFFFD95A), const Color(0xFFF1D08A)),
                    p.c(RateelColors.amber, const Color(0xFFE0B163)),
                  ]
                : [
                    p.c(RateelColors.testPillTop, RateelColors.readLPillFill),
                    p.c(
                      RateelColors.testPillBottom,
                      RateelColors.readLToolFill,
                    ),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: RateelColors.testPillRimBottom.withValues(
                alpha: (filled ? 0.5 : 0.28) * (1 - p.t),
              ),
              blurRadius: u * 1.4,
            ),
          ],
        ),
        child: CustomPaint(
          foregroundPainter: GradientRimPainter(
            width: math.max(1.0, u * 0.32),
            radius: h,
            top: p.c(RateelColors.testPillRimTop, RateelColors.readLPillRim),
            bottom: p.c(
              RateelColors.testPillRimBottom,
              RateelColors.testLSelRim,
            ),
          ),
          // Shrinks the content rather than overflowing a long number.
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: u * 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                // Reference: the star on the right, then «+10 نقطة».
                textDirection: TextDirection.rtl,
                children: [
                  if (!filled || total)
                    SvgPicture.asset(
                      'assets/ui/glyphs/star.svg',
                      width: u * 4.6,
                      height: u * 4.6,
                      colorFilter: ColorFilter.mode(
                        filled
                            ? p.c(RateelColors.countText, RateelColors.readLInk)
                            : p.c(
                                RateelColors.testSelDot,
                                RateelColors.testLSelRim,
                              ),
                        BlendMode.srcIn,
                      ),
                    ),
                  if (!filled || total) SizedBox(width: u * 1.2),
                  Transform.translate(
                    offset: Offset(0, -u * 0.3),
                    child: Text(
                      total ? '$points نقطة' : '+$points نقطة',
                      textDirection: TextDirection.rtl,
                      style: readex(
                        u * TestMetrics.pillText,
                        weight: filled ? 700 : 500,
                        color: text,
                      ).copyWith(height: 1.0),
                    ),
                  ),
                  if (filled && !total) ...[
                    SizedBox(width: u * 1.0),
                    SizedBox(
                      width: u * 2.8,
                      height: u * 2.8,
                      child: CustomPaint(painter: _CheckPainter(text, 0.2)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _BtnGlyph { arrow, check, replay }

/// Colour of a filled lesson button.
enum _Tone { gold, green, red }

/// Filled lesson button (owner, 2026-11-26: filled with white text in both
/// themes; the reference's «تأكيد الإجابة» was dark glass with a gold rim):
/// gold for the main actions, green / red for «إعادة الاختبار» after a passed
/// / failed test. Glow around it in the dark theme, soft shadow in the light.
class _GoldButton extends StatefulWidget {
  const _GoldButton({
    required this.u,
    required this.p,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.glyph = _BtnGlyph.arrow,
    this.tone = _Tone.gold,
    this.height,
    this.fontSize,
  });

  final double u;
  final LessonPal p;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final _BtnGlyph glyph;
  final _Tone tone;
  final double? height;
  final double? fontSize;

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final p = widget.p;
    final h = u * (widget.height ?? TestMetrics.btnH);
    final (top, bottom, rimTop, rimBottom, glow) = switch (widget.tone) {
      _Tone.gold => (
        RateelColors.testLGoldTop,
        RateelColors.testLGoldBottom,
        RateelColors.testLGoldRimTop,
        RateelColors.testLGoldRimBottom,
        RateelColors.testPillRimBottom,
      ),
      _Tone.green => (
        RateelColors.testLGreenTop,
        RateelColors.testLGreenBottom,
        RateelColors.testLGreenRimTop,
        RateelColors.testLGreenBottom,
        RateelColors.testOkRim,
      ),
      _Tone.red => (
        RateelColors.testLRedTop,
        RateelColors.testLRedBottom,
        RateelColors.testLRedRimTop,
        RateelColors.testLRedBottom,
        RateelColors.testKoRim,
      ),
    };
    // Dark theme: outlined glass with a luminous rim; light theme: filled,
    // white text (owner, 2026-11-26, approved).
    final (oTop, oBottom, oRimTop, oRimBottom, oText) = switch (widget.tone) {
      _Tone.gold => (
        RateelColors.testPillTop,
        RateelColors.testPillBottom,
        RateelColors.testPillRimTop,
        RateelColors.testPillRimBottom,
        RateelColors.testPillText,
      ),
      _Tone.green => (
        RateelColors.testRowFill,
        RateelColors.testPillBottom,
        RateelColors.testRowRimTop,
        RateelColors.testOkRim,
        RateelColors.leaderText,
      ),
      _Tone.red => (
        const Color(0xFF3A2420),
        RateelColors.testPillBottom,
        const Color(0xFFEE9C8A),
        RateelColors.testKoRim,
        RateelColors.leaderText,
      ),
    };
    final f = p.t;
    Color mix(Color a, Color b) => Color.lerp(a, b, f)!;
    final text = mix(oText, Colors.white);
    final fill = [mix(oTop, top), mix(oBottom, bottom)];
    final rim = (mix(oRimTop, rimTop), mix(oRimBottom, rimBottom));
    final glyphW = u * 3.6;
    final textShadow = [
      Shadow(
        color: Colors.black.withValues(alpha: 0.28 * f),
        blurRadius: u * 0.4,
        offset: Offset(0, u * 0.12),
      ),
    ];
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        // Before a choice the button keeps its look; a tap gives the
        // «denied» haptic.
        onTap: widget.enabled
            ? () {
                Haptics.tap();
                widget.onTap();
              }
            : Haptics.denied,
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          child: SizedBox(
            height: h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(h),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: fill,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glow.withValues(
                      alpha: (_down ? 0.6 : 0.38) * (1 - p.t),
                    ),
                    blurRadius: u * 2.0,
                  ),
                  BoxShadow(
                    color: p
                        .c(Colors.black, const Color(0xFF8A6A4A))
                        .withValues(alpha: p.d(0.35, 0.18)),
                    blurRadius: u * 1.0,
                    offset: Offset(0, u * 0.4),
                  ),
                ],
              ),
              child: CustomPaint(
                foregroundPainter: GradientRimPainter(
                  width: math.max(1.0, u * 0.3),
                  radius: h,
                  top: rim.$1,
                  bottom: rim.$2,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: u * 2.5),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      children: [
                        SizedBox(
                          width: glyphW,
                          height: glyphW,
                          child: CustomPaint(
                            painter: switch (widget.glyph) {
                              _BtnGlyph.arrow => _ArrowPainter(text),
                              _BtnGlyph.check => _CheckPainter(text, 0.16),
                              _BtnGlyph.replay => _ReplayPainter(text),
                            },
                          ),
                        ),
                        SizedBox(width: u * 2.4),
                        Text(
                          widget.label,
                          textDirection: TextDirection.rtl,
                          style: readex(
                            u * (widget.fontSize ?? TestMetrics.btnText),
                            weight: 700,
                            color: text,
                          ).copyWith(height: 1.0, shadows: textShadow),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ← arrow (RTL «forward»).
class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(Offset(w * 0.1, w * 0.5), Offset(w * 0.92, w * 0.5), p);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.42, w * 0.18)
        ..lineTo(w * 0.1, w * 0.5)
        ..lineTo(w * 0.42, w * 0.82),
      p,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter o) => o.color != color;
}

/// ↻ restart: an open circle with an arrow head at its upper end.
class _ReplayPainter extends CustomPainter {
  _ReplayPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w / 2, w / 2);
    final r = w * 0.36;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.13
      ..strokeCap = StrokeCap.round;
    // From the top, clockwise round to the upper left (gap at the top left).
    const start = -math.pi / 2 + 0.55;
    const sweep = math.pi * 2 - 1.1;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start,
      sweep,
      false,
      p,
    );
    final end = start + sweep;
    final tip = c + Offset(math.cos(end), math.sin(end)) * r;
    // Arrow head pointing along the circle (clockwise), at its end.
    final dir = Offset(-math.sin(end), math.cos(end));
    final nrm = Offset(math.cos(end), math.sin(end));
    final h = w * 0.26;
    canvas.drawPath(
      Path()
        ..moveTo(
          tip.dx - dir.dx * h + nrm.dx * h * 0.7,
          tip.dy - dir.dy * h + nrm.dy * h * 0.7,
        )
        ..lineTo(tip.dx + dir.dx * h * 0.25, tip.dy + dir.dy * h * 0.25)
        ..lineTo(
          tip.dx - dir.dx * h - nrm.dx * h * 0.7,
          tip.dy - dir.dy * h - nrm.dy * h * 0.7,
        ),
      p..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ReplayPainter o) => o.color != color;
}

/// Feedback bar inside the card (owner's choice A, 2026-11-25; mockups
/// `feedback-a-{ok,ko}.jpg`): jewel green / red glass, medallion on the
/// right, «إجابة صحيحة» + points or «إجابة خاطئة» + the correct answer, one
/// line of explanation, «السؤال التالي ←» (last: «إنهاء الاختبار») on the left.
class _FeedbackBar extends StatelessWidget {
  const _FeedbackBar({
    required this.u,
    required this.p,
    required this.ok,
    this.partial = false,
    required this.points,
    required this.streak,
    required this.correctText,
    required this.explanation,
    required this.last,
    required this.onNext,
  });

  /// Correct answers in a row up to this one (Angular: shown from 2).
  final int streak;

  final double u;
  final LessonPal p;
  final bool ok;

  /// Partly correct (amber): half the points, the full answer shown.
  final bool partial;
  final int points;
  final String correctText;
  final String? explanation;
  final bool last;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    final rim = ok
        ? p.c(RateelColors.testOkRim, RateelColors.testLOkRim)
        : partial
        ? p.c(RateelColors.testPartRim, RateelColors.testLPartRim)
        : p.c(RateelColors.testKoRim, RateelColors.testLKoRim);
    final r = u * TestMetrics.fbRadius;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: ok
              ? [
                  p.c(const Color(0xFF0E4532), RateelColors.testLOkTop),
                  p.c(const Color(0xFF062F22), RateelColors.testLOkBottom),
                ]
              : partial
              ? [
                  p.c(RateelColors.testPartTop, RateelColors.testLPartTop),
                  p.c(const Color(0xFF1E2A16), RateelColors.testLPartBottom),
                ]
              : [
                  p.c(const Color(0xFF3A2420), RateelColors.testLKoTop),
                  p.c(const Color(0xFF1E2A1E), RateelColors.testLKoBottom),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: rim.withValues(alpha: 0.25 * (1 - p.t)),
            blurRadius: u * 2.4,
          ),
          BoxShadow(
            color: p
                .c(Colors.black, const Color(0xFF8A6A4A))
                .withValues(alpha: p.d(0.4, 0.15)),
            blurRadius: u * 1.2,
            offset: Offset(0, u * 0.5),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: GradientRimPainter(
          width: math.max(1.0, u * 0.24),
          radius: r,
          top: rim,
          bottom: rim.withValues(alpha: 0.7),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: u * TestMetrics.fbPad),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, s, child) =>
                    Transform.scale(scale: s, child: child),
                child: _MarkDisc(
                  u: u,
                  ok: ok,
                  partial: partial,
                  d: TestMetrics.fbMedal,
                ),
              ),
              SizedBox(width: u * 3.2),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          ok
                              ? 'إجابة صحيحة'
                              : partial
                              ? 'إجابة صحيحة جزئيًا'
                              : 'إجابة خاطئة',
                          textDirection: TextDirection.rtl,
                          style:
                              readex(
                                u * TestMetrics.fbTitle,
                                weight: 700,
                                color: ink,
                              ).copyWith(
                                height: 1.2,
                                shadows: p.t > 0.5 ? null : _shadow(u),
                              ),
                        ),
                        SizedBox(width: u * 3),
                        if (ok || partial) ...[
                          SvgPicture.asset(
                            'assets/ui/glyphs/star.svg',
                            width: u * 3.4,
                            height: u * 3.4,
                            colorFilter: ColorFilter.mode(
                              p.c(
                                RateelColors.testSelDot,
                                RateelColors.testLSelRim,
                              ),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: u * 1.0),
                          Text(
                            '+$points نقطة',
                            textDirection: TextDirection.rtl,
                            style: readex(
                              u * TestMetrics.fbPoints,
                              weight: 700,
                              color: p.c(
                                RateelColors.testTitleTop,
                                RateelColors.readLTitle,
                              ),
                            ),
                          ),
                          if (streak > 1) ...[
                            SizedBox(width: u * 2.4),
                            _StreakChip(u: u, p: p, streak: streak),
                          ],
                        ] else
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'الإجابة الصحيحة: '),
                                  TextSpan(
                                    text: correctText,
                                    style: readex(
                                      u * 3.3,
                                      weight: 700,
                                      color: p.c(
                                        RateelColors.testOkText,
                                        RateelColors.testLOkRim,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: readex(
                                u * 3.2,
                                weight: 400,
                                color: ink.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (partial) ...[
                      SizedBox(height: u * 0.6),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'الإجابة الكاملة: '),
                            TextSpan(
                              text: correctText,
                              style: readex(
                                u * 3.2,
                                weight: 700,
                                color: p.c(
                                  RateelColors.testOkText,
                                  RateelColors.testLOkRim,
                                ),
                              ),
                            ),
                          ],
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: readex(
                          u * 3.1,
                          weight: 400,
                          color: ink.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                    if (explanation != null) ...[
                      SizedBox(height: u * 0.8),
                      Text(
                        explanation!,
                        textDirection: TextDirection.rtl,
                        maxLines: partial ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: readex(
                          u * TestMetrics.fbText,
                          weight: 400,
                          color: ink.withValues(alpha: 0.88),
                        ).copyWith(height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: u * 3),
              SizedBox(
                width: u * TestMetrics.fbBtnW,
                child: _GoldButton(
                  u: u,
                  p: p,
                  label: last ? 'إنهاء الاختبار' : 'السؤال التالي',
                  height: TestMetrics.fbBtnH,
                  fontSize: 3.9,
                  onTap: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Mark { ok, part, ko, star }

class _Stat {
  const _Stat(this.value, this.label, this.mark);

  final String value;
  final String label;
  final _Mark mark;
}

/// A result number in a column: mark on top, the number, one-line label.
/// One diameter for the marks of the results numbers (✓, ✕, coin), in u
/// (owner, 2026-11-26).
const _statIcon = 4.0;

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.u, required this.p, required this.stat});

  final double u;
  final LessonPal p;
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            if (stat.mark == _Mark.star)
              // Owner's gold star coin (2026-11-26).
              Image.asset(
                'assets/ui/test/star_coin_gold.webp',
                width: u * _statIcon,
                height: u * _statIcon,
              )
            else
              _MarkDisc(
                u: u,
                ok: stat.mark == _Mark.ok,
                partial: stat.mark == _Mark.part,
                d: _statIcon,
              ),
            SizedBox(width: u * 1.2),
            Text(
              stat.value,
              textDirection: TextDirection.ltr,
              style: readex(u * 5, weight: 700, color: ink).copyWith(height: 1),
            ),
          ],
        ),
        SizedBox(height: u * 1.0),
        Text(
          stat.label,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          style: readex(
            u * 2.7,
            weight: 400,
            color: ink.withValues(alpha: 0.8),
          ).copyWith(height: 1.1),
        ),
      ],
    );
  }
}

/// Row of the answers list: number circle, question, ✓ / ✕, thin coloured
/// edge on the right (Angular results).
class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.u,
    required this.p,
    required this.number,
    required this.text,
    required this.ok,
    this.partial = false,
    required this.onTap,
  });

  final double u;
  final LessonPal p;
  final int number;
  final String text;
  final bool ok;
  final bool partial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    final edge = ok
        ? p.c(RateelColors.testOkRim, RateelColors.testLOkRim)
        : partial
        ? p.c(RateelColors.testPartRim, RateelColors.testLPartRim)
        : p.c(RateelColors.testKoRim, RateelColors.testLKoRim);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _GlassBox(
        u: u,
        p: p,
        edge: edge,
        padding: EdgeInsets.symmetric(vertical: u * 1.3, horizontal: u * 1.8),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: u * 4.6,
              height: u * 4.6,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.c(RateelColors.testNavFill, RateelColors.testLNavFill),
                border: Border.all(
                  color: p.c(RateelColors.testNavRim, RateelColors.testLRowRim),
                  width: u * 0.22,
                ),
              ),
              child: Text(
                '$number',
                textDirection: TextDirection.ltr,
                style: readex(
                  u * 2.6,
                  weight: 500,
                  color: ink,
                ).copyWith(height: 1),
              ),
            ),
            SizedBox(width: u * 1.6),
            Expanded(
              child: Text(
                text,
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: readex(u * 3.0, weight: 500, color: ink),
              ),
            ),
            SizedBox(width: u * 1.6),
            _MarkDisc(u: u, ok: ok, partial: partial, d: 4),
          ],
        ),
      ),
    );
  }
}

/// Small glass box (stats, recommendations, answers): row glass with the
/// rows' rim; optional coloured edge on the right.
class _GlassBox extends StatelessWidget {
  const _GlassBox({
    required this.u,
    required this.p,
    required this.child,
    this.padding,
    this.edge,
  });

  final double u;
  final LessonPal p;
  final Widget child;
  final EdgeInsets? padding;
  final Color? edge;

  @override
  Widget build(BuildContext context) {
    final r = u * TestMetrics.rowRadius;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        color: p.c(RateelColors.testRowFill, RateelColors.testLRowFill),
      ),
      child: CustomPaint(
        foregroundPainter: _GlassRimPainter(
          u: u,
          radius: r,
          top: p.c(RateelColors.testRowRimTop, RateelColors.testLRowRim),
          bottom: p.c(RateelColors.testRowRimBottom, RateelColors.testLRowRim),
          edge: edge,
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.all(u * 1.8),
          child: child,
        ),
      ),
    );
  }
}

class _GlassRimPainter extends CustomPainter {
  _GlassRimPainter({
    required this.u,
    required this.radius,
    required this.top,
    required this.bottom,
    this.edge,
  });

  final double u;
  final double radius;
  final Color top;
  final Color bottom;
  final Color? edge;

  @override
  void paint(Canvas canvas, Size size) {
    final w = math.max(1.0, u * 0.22);
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(w / 2),
      Radius.circular(radius),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top.withValues(alpha: 0.7), bottom.withValues(alpha: 0.6)],
        ).createShader(Offset.zero & size),
    );
    if (edge != null) {
      canvas.save();
      canvas.clipRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
      canvas.drawRect(
        Rect.fromLTWH(size.width - u * 0.6, 0, u * 0.6, size.height),
        Paint()..color = edge!,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_GlassRimPainter o) =>
      o.top != top || o.bottom != bottom || o.edge != edge || o.u != u;
}

/// Material glyph in the lesson gold (lightbulb, ↻); the trophy and the
/// flames are the owner's drawn icons (T4–T6, `assets/ui/test/`).
class _GoldIcon extends StatelessWidget {
  const _GoldIcon({
    required this.u,
    required this.p,
    required this.icon,
    required this.size,
  });

  final double u;
  final LessonPal p;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final i = Icon(icon, size: u * size, color: Colors.white);
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          p.c(const Color(0xFFFFE07A), RateelColors.readLCopper),
          p.c(RateelColors.amber, RateelColors.readLTitle),
        ],
      ).createShader(r),
      child: i,
    );
  }
}

class _AnswerBox extends StatelessWidget {
  const _AnswerBox({
    required this.u,
    required this.p,
    required this.ok,
    this.partial = false,
    required this.text,
  });

  final double u;
  final LessonPal p;
  final bool ok;
  final bool partial;
  final String text;

  @override
  Widget build(BuildContext context) {
    final rim = ok
        ? p.c(RateelColors.testOkRim, RateelColors.testLOkRim)
        : partial
        ? p.c(RateelColors.testPartRim, RateelColors.testLPartRim)
        : p.c(RateelColors.testKoRim, RateelColors.testLKoRim);
    final r = u * TestMetrics.rowRadius;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: u * 2.2, vertical: u * 1.6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: ok
              ? [
                  p.c(RateelColors.testOkTop, RateelColors.testLOkTop),
                  p.c(RateelColors.testOkBottom, RateelColors.testLOkBottom),
                ]
              : partial
              ? [
                  p.c(RateelColors.testPartTop, RateelColors.testLPartTop),
                  p.c(
                    RateelColors.testPartBottom,
                    RateelColors.testLPartBottom,
                  ),
                ]
              : [
                  p.c(RateelColors.testKoTop, RateelColors.testLKoTop),
                  p.c(RateelColors.testKoBottom, RateelColors.testLKoBottom),
                ],
        ),
        border: Border.all(color: rim, width: math.max(1.0, u * 0.25)),
      ),
      child: Text(
        text.isEmpty ? '—' : text,
        textDirection: TextDirection.rtl,
        style: readex(
          u * 3.3,
          weight: 600,
          color: p.c(RateelColors.leaderText, RateelColors.readLInk),
        ),
      ),
    );
  }
}

/// Colour of the score (owner, 2026-11-26: the ring says how well it went):
/// red up to 50%, a darker amber from 51% to the pass mark, gold from the
/// pass mark, the full bright gold at 100%. Follows the ring while it fills.
Color scoreColor(LessonPal p, double v, double pass) {
  final dark = [
    (0.0, RateelColors.testScoreRedLow),
    (0.5, RateelColors.testScoreRed),
    (0.51, RateelColors.testScoreAmber),
    (pass - 0.01, RateelColors.testScoreAmberHigh),
    (pass, RateelColors.testScoreGold),
    (1.0, RateelColors.testScoreFull),
  ];
  final light = [
    (0.0, RateelColors.testLScoreRed),
    (0.5, RateelColors.testLScoreRed),
    (0.51, RateelColors.testLScoreAmber),
    (pass - 0.01, RateelColors.testLScoreAmber),
    (pass, RateelColors.testLScoreGold),
    (1.0, RateelColors.testLScoreFull),
  ];
  Color at(List<(double, Color)> stops) {
    if (v <= stops.first.$1) return stops.first.$2;
    for (var i = 1; i < stops.length; i++) {
      if (v <= stops[i].$1) {
        final (a, ca) = stops[i - 1];
        final (b, cb) = stops[i];
        return Color.lerp(ca, cb, b == a ? 1 : (v - a) / (b - a))!;
      }
    }
    return stops.last.$2;
  }

  return p.c(at(dark), at(light));
}

/// Score ring of the results: dark green track, arc in the score colour
/// ([scoreColor]) with a light head.
class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({
    required this.p,
    required this.u,
    required this.value,
    required this.passed,
    required this.pass,
  });

  final LessonPal p;
  final double u;
  final double value;
  final bool passed;

  /// Pass mark (0–1).
  final double pass;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final sw = u * 1.8;
    final r = size.width / 2 - sw;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..color = p.c(RateelColors.testNavFill, RateelColors.testLNavFill),
    );
    canvas.drawCircle(
      c,
      r + sw / 2 + u * 0.2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, u * 0.18)
        ..color = p.c(RateelColors.testNavRim, RateelColors.testLRowRim),
    );
    if (value <= 0) return;
    final sweep = math.pi * 2 * value;
    final gold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + math.max(sweep, 0.01),
        colors: [
          Color.lerp(scoreColor(p, value, pass), Colors.black, 0.18)!,
          scoreColor(p, value, pass),
        ],
        transform: const GradientRotation(0),
      ).createShader(rect);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw * 1.8
        ..strokeCap = StrokeCap.round
        ..color = scoreColor(p, value, pass).withValues(alpha: 0.28 * (1 - p.t))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.9),
    );
    canvas.drawArc(rect, -math.pi / 2, sweep, false, gold);
  }

  @override
  bool shouldRepaint(_ScoreRingPainter o) =>
      o.value != value || o.p.t != p.t || o.u != u || o.pass != pass;
}

/// «🔥 3 إجابات متتالية» (Angular feedback modal: streak indicator with three
/// flames, from 2 correct answers in a row): a warm chip that pops in, its
/// flames lit one after the other.
class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.u, required this.p, required this.streak});

  final double u;
  final LessonPal p;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final h = u * 6.2;
    const flame = Color(0xFFFF9A3C);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, t, _) {
        final pop = Curves.easeOutBack.transform((t / 0.45).clamp(0.0, 1.0));
        return Transform.scale(
          scale: 0.6 + 0.4 * pop,
          child: Opacity(
            opacity: pop.clamp(0.0, 1.0),
            child: Container(
              height: h,
              padding: EdgeInsets.symmetric(horizontal: u * 1.8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(h),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    p.c(const Color(0xFF5A3A14), const Color(0xFFFBE3C4)),
                    p.c(const Color(0xFF3A2610), const Color(0xFFF6D3A8)),
                  ],
                ),
                border: Border.all(
                  color: flame.withValues(alpha: 0.85),
                  width: math.max(1.0, u * 0.22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: flame.withValues(alpha: 0.35 * (1 - p.t)),
                    blurRadius: u * 1.4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  if (streak > 3)
                    Padding(
                      padding: EdgeInsets.only(right: u * 0.3),
                      child: Text(
                        '+',
                        textDirection: TextDirection.ltr,
                        style: readex(
                          u * 3.4,
                          weight: 700,
                          color: flame,
                        ).copyWith(height: 1),
                      ),
                    ),
                  // One flame per answer in the row, at most three; from 4 a
                  // «+» on their left (owner, 2026-11-26).
                  for (var i = 0; i < math.min(streak, 3); i++)
                    Opacity(
                      opacity: ((t - 0.3 - i * 0.15) / 0.2).clamp(0.3, 1.0),
                      // Owner's flame glyph (T6).
                      child: Image.asset(
                        'assets/ui/test/flame.webp',
                        height: u * 3.2,
                      ),
                    ),
                  SizedBox(width: u * 0.8),
                  Text(
                    '$streak إجابات متتالية',
                    textDirection: TextDirection.rtl,
                    style: readex(
                      u * 3.2,
                      weight: 600,
                      color: p.c(
                        const Color(0xFFFFE3B8),
                        const Color(0xFF6A3A10),
                      ),
                    ).copyWith(height: 1),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Streak banner over the card: flame medallion, «3 إجابات متتالية!» and the
/// bonus the next answer is worth.
class _StreakBanner extends StatelessWidget {
  const _StreakBanner({
    required this.u,
    required this.p,
    required this.streak,
    required this.bonus,
    required this.t,
  });

  final double u;
  final LessonPal p;
  final int streak;
  final int bonus;
  final double t;

  @override
  Widget build(BuildContext context) {
    const flame = Color(0xFFFF9A3C);
    final r = u * 7.5;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.c(const Color(0xFF4A3213), const Color(0xFFFCE6C6)),
            p.c(const Color(0xFF1E2412), const Color(0xFFF5D2A2)),
          ],
        ),
        border: Border.all(color: flame, width: math.max(1.0, u * 0.32)),
        boxShadow: [
          BoxShadow(
            color: flame.withValues(alpha: 0.45 * (1 - p.t) + 0.15),
            blurRadius: u * 3,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: p.d(0.45, 0.15)),
            blurRadius: u * 1.6,
            offset: Offset(0, u * 0.6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(width: u * 2),
          // Owner's flame medallion (T5), with a soft orange glow and a
          // gentle pulse.
          Transform.scale(
            scale: 1 + 0.05 * math.sin(t * math.pi * 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: flame.withValues(alpha: 0.55),
                    blurRadius: u * 2,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/ui/test/flame_medallion.webp',
                width: u * 11.5,
                height: u * 11.5,
              ),
            ),
          ),
          SizedBox(width: u * 2.8),
          Padding(
            padding: EdgeInsets.only(left: u * 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak إجابات متتالية',
                  textDirection: TextDirection.rtl,
                  style: readex(
                    u * 4.6,
                    weight: 700,
                    color: p.c(
                      const Color(0xFFFFE3B8),
                      const Color(0xFF6A3A10),
                    ),
                  ).copyWith(height: 1.15),
                ),
                if (bonus > 0)
                  Text(
                    'مكافأة السلسلة: +$bonus نقطة للإجابة التالية',
                    textDirection: TextDirection.rtl,
                    style: readex(
                      u * 2.9,
                      weight: 400,
                      color: p.c(
                        const Color(0xFFF3D9B0),
                        const Color(0xFF7A4A1E),
                      ),
                    ).copyWith(height: 1.3),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
