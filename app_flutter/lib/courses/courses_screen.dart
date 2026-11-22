import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind, lerpDouble;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../theme/rateel_theme.dart';
import '../units/unit_data.dart';
import '../units/units_screen.dart';
import 'course_card.dart';
import 'course_data.dart';

/// Screen 03, courses / learning paths (docs/flutter/screens/03-courses.md).
///
/// Geometry is in units of 1% of the screen height (u), measured on the
/// ChatGPT reference (1847×851, u = 8.51 px). Horizontal positions are taken
/// from the right edge of the content (the left edge of the side rail), the
/// start of the RTL path.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with TickerProviderStateMixin {
  /// Entry choreography: header settles, cards slide in one after the other,
  /// the path line draws itself, the progress bar fills.
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  /// Shake of a locked card's lock (index in [_shaking]).
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  int _shaking = -1;

  late final AnimationController _toast = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  String _toastText = '';

  // Course completion (owner, 2026-11-20): when the last lesson of a course
  // ends, the lesson, unit and course screens close by themselves and land
  // here. The line between two courses has a node in the middle: the first
  // half lights up when the course reaches 50%, the second half when it is
  // completed and the light reaches the next course, whose lock pops; the
  // path glides to it. Haptics mark every step (core/haptics.dart).
  late final AnimationController _fill = AnimationController(vsync: this)
    ..addListener(_fillTicks);
  late final AnimationController _half = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..addListener(_flowTicks);
  late final AnimationController _unlock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  /// Index of the course in progress; the ones before it are completed, the
  /// ones after it locked.
  late int _current = math.max(0, courses.indexWhere((c) => c.locked) - 1);
  late final List<double> _progress = [for (final c in courses) c.progress];
  int? _completing;
  double _fillFrom = 0;
  double _fillTo = 0;
  int _lastTick = 0;

  PageController? _pages;
  double _pageFraction = 0;

  @override
  void initState() {
    super.initState();
    courseCompleted.addListener(_onCourseCompleted);
    // A completion that arrived before this screen was built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onCourseCompleted());
  }

  @override
  void dispose() {
    courseCompleted.removeListener(_onCourseCompleted);
    _entry.dispose();
    _shake.dispose();
    _toast.dispose();
    _fill.dispose();
    _half.dispose();
    _flow.dispose();
    _unlock.dispose();
    _pages?.dispose();
    super.dispose();
  }

  PageController _controllerFor(double fraction) {
    if (_pages == null || (fraction - _pageFraction).abs() > 0.001) {
      final page = _pages?.hasClients == true
          ? _pages!.page ?? 0
          : _current.toDouble();
      _pages?.dispose();
      _pageFraction = fraction;
      _pages = PageController(
        viewportFraction: fraction,
        initialPage: page.round(),
      );
    }
    return _pages!;
  }

  void _onCourseCompleted() {
    final i = courseCompleted.value;
    // A completion that arrives during a running sequence waits for it.
    if (i == null || !mounted || _completing != null) return;
    courseCompleted.value = null;
    _complete(i).then((_) {
      if (mounted) _onCourseCompleted();
    });
  }

  /// One tick every 10% while the bar fills.
  void _fillTicks() {
    final p = lerpDouble(_fillFrom, _fillTo, _fill.value)!;
    final step = (p * 10).floor();
    if (step != _lastTick) {
      _lastTick = step;
      Haptics.tick();
    }
  }

  /// Ticks as the light passes a third and two thirds of the second half.
  void _flowTicks() {
    final step = (_flow.value * 3).floor();
    if (step != _lastTick && step < 3) {
      _lastTick = step;
      if (step > 0) Haptics.tick();
    }
  }

  /// Fills course [i]'s bar from its stored progress to [to].
  Future<void> _fillBar(int i, double to) async {
    final from = _progress[i];
    if (to <= from) return;
    setState(() {
      _fillFrom = from;
      _fillTo = to;
      _lastTick = (from * 10).floor();
    });
    _fill.duration = Duration(milliseconds: (1400 * (to - from)).round());
    await _fill.forward(from: 0);
    _progress[i] = to;
  }

  /// Completion sequence for course [i]: bar to 50%, first half of the line
  /// and its node light up; bar to 100%; the second half lights up to the
  /// next course, its lock pops, the path glides to it.
  Future<void> _complete(int i) async {
    if (i != _current) return;
    final pages = _pages;
    setState(() => _completing = i);
    if (_entry.isAnimating) await _entry.forward();
    if (pages != null && pages.hasClients && (pages.page ?? 0).round() != i) {
      await pages.animateToPage(
        i,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
    if (_progress[i] < 0.5) {
      await _fillBar(i, 0.5);
      Haptics.milestone();
      await _half.forward(from: 0);
    }
    await _fillBar(i, 1);
    Haptics.milestone();
    if (i == courses.length - 1) {
      setState(() => _completing = null);
      Haptics.success();
      _showToast('أتممت جميع المسارات');
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _lastTick = 0;
    await _flow.forward(from: 0);
    Haptics.unlock();
    await _unlock.forward(from: 0);
    setState(() {
      _current = i + 1;
      _completing = null;
    });
    _fill.value = 0;
    _half.value = 0;
    _flow.value = 0;
    _unlock.value = 0;
    if (pages != null && pages.hasClients) {
      await pages.animateToPage(
        i + 1,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeInOutCubic,
      );
    }
    Haptics.success();
  }

  /// Back from the units screen: the course bar catches up with its units
  /// (shared progress, owner 2026-11-22), with the same light and haptics as
  /// the completion (first half of the line at 50%). 100% is played by the
  /// course completion itself.
  Future<void> _syncProgress(int i) async {
    if (!mounted || _completing != null || i != _current) return;
    final target = math.min(courseProgressFromUnits(i), 0.999);
    if (target <= _progress[i] + 0.001) return;
    setState(() => _completing = i);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (_progress[i] < 0.5 && target >= 0.5) {
      await _fillBar(i, 0.5);
      Haptics.milestone();
      await _half.forward(from: 0);
    }
    await _fillBar(i, target);
    if (!mounted) return;
    setState(() => _completing = null);
    _fill.value = 0;
    _half.value = 0;
  }

  Future<void> _showToast(String text) async {
    setState(() => _toastText = text);
    await _toast.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (mounted && _toastText == text) await _toast.reverse();
  }

  void _tapCourse(int i) {
    if (_completing != null) return;
    if (i > _current) {
      Haptics.denied();
      setState(() => _shaking = i);
      _shake.forward(from: 0);
      final previous = courses[i - 1].title;
      _showToast('أكمل «$previous» أولًا لفتح هذه الدورة');
    } else {
      Haptics.tap();
      Navigator.of(context).push(unitsRoute(i)).then((_) => _syncProgress(i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final g = _Geo(box.maxWidth, box.maxHeight);
        final pages = _controllerFor(g.pitch / (g.w - g.trackRightInset));
        return Stack(
          fit: StackFit.expand,
          // The top-right ornament runs on under the side rail.
          clipBehavior: Clip.none,
          children: [
            const _Background(),
            ..._header(g),
            Positioned(
              left: 0,
              right: g.trackRightInset,
              top: g.cardCenterY - g.trackHalfHeight,
              height: g.trackHalfHeight * 2,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _entry,
                  _shake,
                  _fill,
                  _half,
                  _flow,
                  _unlock,
                  pages,
                ]),
                // Mouse drag too (web review captures, desktop).
                builder: (context, _) => ScrollConfiguration(
                  behavior: const _DragEverywhere(),
                  child: PageView.builder(
                    controller: pages,
                    padEnds: false,
                    clipBehavior: Clip.none,
                    physics: _completing != null
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    itemCount: courses.length,
                    itemBuilder: (context, i) => _page(g, pages, i),
                  ),
                ),
              ),
            ),
            _toastLayer(g),
          ],
        );
      },
    );
  }

  Widget _page(_Geo g, PageController pages, int i) {
    final page = pages.hasClients && pages.position.haveDimensions
        ? pages.page ?? 0
        : _current.toDouble();
    final focus = (1 - (page - i).abs()).clamp(0.0, 1.0);
    final e = _entry.value;
    // Cards slide in from the right, starting at the focused one.
    final order = (i - page.round()).clamp(0, 4);
    final appear = Curves.easeOutCubic.transform(
      _interval(e, 0.15 + 0.08 * order, 0.55 + 0.08 * order),
    );
    final draw = Curves.easeInOutCubic.transform(_interval(e, 0.55, 0.9));
    final shake = _shaking == i
        ? math.sin(_shake.value * math.pi * 5) * (1 - _shake.value)
        : 0.0;
    final entryFill = Curves.easeOutCubic.transform(_interval(e, 0.6, 1));
    double progress = _progress[i] * entryFill;
    if (i < _current) progress = 1;
    if (i == _completing && _fill.isAnimating) {
      progress = lerpDouble(
        _fillFrom,
        _fillTo,
        Curves.easeInOutCubic.transform(_fill.value),
      )!;
    } else if (i == _completing) {
      progress = _progress[i];
    }
    // The line after course i: first half lit from 50%, second half when the
    // course is completed.
    double half1 = i < _current || _progress[i] >= 0.5 ? 1 : 0;
    if (i == _completing && _half.isAnimating) half1 = _half.value;
    double half2 = i < _current ? 1 : 0;
    if (i == _completing) half2 = _flow.value;
    double unlock = i <= _current ? 1 : 0;
    if (_completing != null && i == _completing! + 1) unlock = _unlock.value;
    return Opacity(
      opacity: appear,
      child: Transform.translate(
        offset: Offset(-g.u * 10 * (1 - appear), 0),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (i < courses.length - 1)
              _connector(
                g,
                draw,
                half1,
                half2,
                nodePop: i == _completing && _half.isAnimating
                    ? _half.value
                    : 0,
              ),
            Transform(
              // Focused card: 626×430 vs 616×426 px (x and y scale differ).
              transform: Matrix4.diagonal3Values(
                lerpDouble(1.0, g.focusScale, focus)!,
                lerpDouble(1.0, 1.009, focus)!,
                1,
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: g.cardW,
                height: g.cardH,
                child: CourseCard(
                  course: courses[i],
                  u: g.u,
                  unlock: unlock,
                  // The reference is static: no breathing glow (owner to decide).
                  breath: 0,
                  progress: progress,
                  lockShake: shake,
                  onTap: () => _tapCourse(i),
                  artSet: cardArtSet,
                  number: i + 1,
                  widthU: g.cardW / g.u,
                  onLongPress: () {
                    // Demo until screens 05–07 exist: long press on the
                    // course in progress plays the completion sequence.
                    if (i == _current) courseCompleted.value = i;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Line from this card's left edge to the next card (reference: y = card
  /// centre + 2.7u), with a node in the middle. Dim track; gold light on the
  /// first half from 50% of the course, on the second half when completed.
  Widget _connector(
    _Geo g,
    double draw,
    double half1,
    double half2, {
    required double nodePop,
  }) {
    final gap = g.pitch - g.cardW;
    final y = g.trackHalfHeight + g.u * 2.7;
    final left = g.pitch / 2 - g.cardW / 2 - gap;
    return Positioned(
      left: left,
      top: y - g.u * 2,
      width: gap,
      height: g.u * 4,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ConnectorPainter(
            u: g.u,
            draw: draw,
            half1: half1,
            half2: half2,
            nodePop: nodePop,
          ),
        ),
      ),
    );
  }

  List<Widget> _header(_Geo g) {
    Widget settle(Widget child) => AnimatedBuilder(
      animation: _entry,
      builder: (context, c) {
        final t = Curves.easeOutCubic.transform(
          _interval(_entry.value, 0, 0.35),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, -g.u * 2 * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
    );
    final cx = g.headerCenterX;
    return [
      // Corner ornaments from the owner (2026-11-21, glowing geometric
      // lattice with a frame): the right one runs on under the side rail.
      Positioned(
        // The frame lines sit on the screen edges (the reference has none).
        // The frame corner sits on the screen corner (the glow around it
        // spills off-screen).
        left: -g.u * 2.6,
        top: -g.u * 2.8,
        width: g.u * 30,
        height: g.u * 30 * 703 / 800,
        child: IgnorePointer(
          child: Opacity(
            opacity: 0.75,
            child: ShaderMask(
              // Soft fade from the corner outwards (owner, 2026-11-21: a
              // professional touch): the tails along the edges and the
              // diagonal dissolve into the background.
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const RadialGradient(
                center: Alignment.topLeft,
                radius: 1.25,
                stops: [0.0, 0.45, 1.0],
                colors: [
                  Color(0xFF000000),
                  Color(0xCC000000),
                  Color(0x00000000),
                ],
              ).createShader(r),
              child: Image.asset('assets/ui/decor/corner_glow_left.webp'),
            ),
          ),
        ),
      ),
      Positioned(
        right: -g.u * 5.75,
        top: -g.u * 2.6,
        width: g.u * 32,
        height: g.u * 32 * 674 / 800,
        child: IgnorePointer(
          child: Opacity(
            opacity: 0.75,
            child: ShaderMask(
              // Soft fade from the corner outwards (owner, 2026-11-21: a
              // professional touch): the tails along the edges and the
              // diagonal dissolve into the background.
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const RadialGradient(
                center: Alignment.topRight,
                radius: 1.25,
                stops: [0.0, 0.45, 1.0],
                colors: [
                  Color(0xFF000000),
                  Color(0xCC000000),
                  Color(0x00000000),
                ],
              ).createShader(r),
              child: Image.asset('assets/ui/decor/corner_glow_right.webp'),
            ),
          ),
        ),
      ),
      // Mosque silhouette (CR-03), faint, left of the title.
      Positioned(
        // Larger and higher than the reference (owner, 2026-11-21).
        left: g.u * 10.5,
        top: g.u * 8.0,
        width: g.u * 49,
        height: g.u * 49 * 542 / 900,
        child: settle(
          IgnorePointer(
            // Faint, fading out at the ground as in the reference.
            child: Opacity(
              opacity: 0.83,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.66, 0.80],
                  colors: [Color(0xFF000000), Color(0x00000000)],
                ).createShader(r),
                child: Image.asset(
                  'assets/ui/decor/mosque.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
      // Crescent and star (CR-04), top right.
      Positioned(
        right: g.u * 25.5,
        top: g.u * 7.5,
        width: g.u * 10.65,
        height: g.u * 9.75,
        child: settle(
          IgnorePointer(
            child: SvgPicture.asset(
              'assets/ui/decor/crescent_star.svg',
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
      // Header mihrab arch (CR-01).
      Positioned(
        left: cx - g.u * 51.4,
        top: g.u * 0.6,
        width: g.u * 102.8,
        height: g.u * 26.4,
        child: settle(
          IgnorePointer(
            // The flanks fade out towards the title, as in the reference.
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.55, 1.0],
                colors: [Color(0xFF000000), Color(0x00000000)],
              ).createShader(r),
              child: SvgPicture.asset(
                'assets/ui/decor/header_arch.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
      // Open Quran emblem on the arch apex (CR-02).
      Positioned(
        left: cx - g.u * 7.22,
        top: g.u * 7.45,
        width: g.u * 14.45,
        height: g.u * 7.8,
        child: settle(
          IgnorePointer(
            // Outline book (CR-02): the reference's pages are dark with a gold
            // rim; the filled variant (header_book_filled.webp) is a spare.
            child: SvgPicture.asset(
              'assets/ui/decor/header_book.svg',
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: g.w - 2 * cx,
        top: g.u * 22.4 - g.u * 7,
        height: g.u * 14,
        child: settle(
          Center(
            child: Stack(
              children: [
                // Shadow layer, then the cream gradient on top.
                Text(
                  'المسارات التعليمية',
                  textDirection: TextDirection.rtl,
                  style: readex(
                    g.u * 9.3,
                    weight: 530,
                    color: Colors.transparent,
                  ).copyWith(height: 1, shadows: titleShadows(g.u)),
                ),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (r) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [titleTop, titleBottom],
                  ).createShader(r),
                  child: Text(
                    'المسارات التعليمية',
                    textDirection: TextDirection.rtl,
                    style: readex(
                      g.u * 9.3,
                      weight: 530,
                      color: Colors.white,
                    ).copyWith(height: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        // Title divider (CR-06).
        left: cx - g.u * 25.3,
        top: g.u * 31.4 - g.u * 2.2,
        width: g.u * 50.6,
        height: g.u * 4.4,
        child: settle(
          IgnorePointer(
            // Brightest next to the diamond, fading outward.
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (r) => const LinearGradient(
                stops: [0, .12, .33, .5, .67, .88, 1],
                colors: [
                  Color(0x00B2983A),
                  Color(0xFFB2983A),
                  Color(0xFFEFC246),
                  Color(0xFFF8D053),
                  Color(0xFFEFC246),
                  Color(0xFFB2983A),
                  Color(0x00B2983A),
                ],
              ).createShader(r),
              child: SvgPicture.asset(
                'assets/ui/decor/title_divider.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _toastLayer(_Geo g) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: g.u * 2.5,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _toast,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_toast.value);
            if (t == 0) return const SizedBox.shrink();
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, g.u * 2 * (1 - t)),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: g.u * 3,
                      vertical: g.u * 1.4,
                    ),
                    decoration: BoxDecoration(
                      color: RateelColors.cardMid.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(g.u * 3),
                      border: Border.all(
                        color: RateelColors.cardRim,
                        width: g.u * 0.23,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: g.u * 2,
                          offset: Offset(0, g.u * 0.5),
                        ),
                      ],
                    ),
                    child: Text(
                      _toastText,
                      textDirection: TextDirection.rtl,
                      style: readex(
                        g.u * 3,
                        weight: 400,
                        color: RateelColors.label,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DragEverywhere extends MaterialScrollBehavior {
  const _DragEverywhere();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}

double _interval(double t, double a, double b) =>
    ((t - a) / (b - a)).clamp(0.0, 1.0);

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      // Slight lift at the bottom edge (reference #002D23).
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.85, 1],
          colors: [Color(0x00002D23), RateelColors.contentLift],
        ),
      ),
      child: _BaseGradient(),
    );
  }
}

class _BaseGradient extends StatelessWidget {
  const _BaseGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.0),
          radius: 1.2,
          colors: [RateelColors.contentTop, RateelColors.contentBottom],
        ),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.u,
    required this.draw,
    required this.half1,
    required this.half2,
    required this.nodePop,
  });

  final double u;

  /// Entry: the line draws itself right to left.
  final double draw;

  /// 0..1: light on the half from this course to the middle node.
  final double half1;

  /// 0..1: light on the half from the node to the next course.
  final double half2;

  /// 0..1 while the node lights up (pop).
  final double nodePop;

  void _light(Canvas canvas, double from, double to, double y, bool spark) {
    canvas.drawLine(
      Offset(to, y),
      Offset(from, y),
      Paint()
        ..color = RateelColors.gold.withValues(alpha: 0.45)
        ..strokeWidth = u * 0.9
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.6),
    );
    canvas.drawLine(
      Offset(to, y),
      Offset(from, y),
      Paint()
        ..color = RateelColors.pathLine
        ..strokeWidth = u * 0.35,
    );
    if (spark) {
      canvas.drawCircle(
        Offset(to, y),
        u * 1.6,
        Paint()
          ..color = RateelColors.goldHighlight.withValues(alpha: 0.7)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.0),
      );
      canvas.drawCircle(
        Offset(to, y),
        u * 0.5,
        Paint()..color = RateelColors.label,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (draw == 0) return;
    final y = size.height / 2;
    final right = size.width;
    final mid = size.width / 2;
    final left = right - size.width * draw;
    canvas.drawLine(
      Offset(left, y),
      Offset(right, y),
      Paint()
        ..color = RateelColors.progressTrack
        ..strokeWidth = u * 0.35,
    );
    if (half1 > 0) {
      _light(canvas, right, right - mid * half1, y, half1 < 1);
    }
    if (half2 > 0) {
      _light(canvas, mid, mid - mid * half2, y, half2 < 1);
    }
    final on = ((draw - 0.1) / 0.3).clamp(0.0, 1.0);
    if (on == 0) return;
    final node = Offset(mid, y);
    final lit = half1 >= 1;
    // The glow grows with the pop instead of appearing in one frame.
    final glow = lit
        ? 1.0
        : (nodePop > 0 ? math.sin(math.pi / 2 * nodePop) : 0.0);
    if (glow > 0) {
      canvas.drawCircle(
        node,
        u * 2.2,
        Paint()
          ..color = RateelColors.gold.withValues(alpha: 0.30 * on * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.2),
      );
    }
    final pop = 1 + 0.45 * math.sin(math.pi * nodePop);
    canvas.drawCircle(
      node,
      u * 1.3 * on * pop,
      Paint()
        ..color = lit || nodePop > 0.5
            ? RateelColors.pathNode
            : RateelColors.progressTrack,
    );
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.draw != draw ||
      old.half1 != half1 ||
      old.half2 != half2 ||
      old.nodePop != nodePop ||
      old.u != u;
}

/// Reference geometry (u = 1% of the height). Ref px / 8.51.
class _Geo {
  _Geo(this.w, this.h) : u = h / 100;

  final double w;
  final double h;
  final double u;

  bool get illustrated => cardArtSet != null;

  /// Illustrated cards (owner's mockup) are narrower: three fit on screen.
  double get cardW => illustrated ? u * 62 : u * 72.4;
  double get cardH => u * 50.0;

  /// The focused (first) card is 626 px wide against 616 px for the others.
  double get focusScale => illustrated ? 1.0 : 1.016;

  /// Card centre to card centre: 704 px.
  double get pitch => illustrated ? u * 66 : u * 82.7;

  /// First card centre: 373 px from the content's right edge.
  double get firstCenterFromRight => illustrated ? u * 34.5 : u * 43.8;

  /// PageView pages are [pitch] wide and start at the right edge; this inset
  /// moves the first card centre to [firstCenterFromRight].
  double get trackRightInset => firstCenterFromRight - pitch / 2;
  double get cardCenterY => u * 63.8;
  double get trackHalfHeight => u * 30;

  /// Arch apex / title centre: 810 px from the content's right edge.
  double get headerCenterX => w - u * 94.8;
}
