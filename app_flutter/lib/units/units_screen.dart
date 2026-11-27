import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../core/sounds.dart';
import '../courses/course_data.dart';
import '../theme/rateel_theme.dart';
import '../core/screen_decor.dart';
import '../lessons/lesson_data.dart';
import '../lessons/lessons_screen.dart';
import 'unit_circle.dart';
import 'unit_data.dart';

/// Opens screen 05 for course [course]: the courses screen fades back and
/// the units screen grows in (Angular: the page slid in from the left).
Route<void> unitsRoute(int course) => PageRouteBuilder<void>(
  transitionDuration: const Duration(milliseconds: 520),
  reverseTransitionDuration: const Duration(milliseconds: 420),
  pageBuilder: (context, a, b) => UnitsScreen(course: course),
  transitionsBuilder: (context, a, b, child) {
    final t = Curves.easeOutCubic.transform(a.value);
    return Opacity(
      opacity: t,
      child: Transform.scale(scale: lerpDouble(1.06, 1, t), child: child),
    );
  },
);

/// Screen 05, course units (docs/flutter/screens/05-units.md).
///
/// Geometry in u = 1% of the screen height, measured on reference 05
/// (1672×941, u = 9.41 px). Horizontal positions are taken from the right
/// edge of the content (the left edge of the side rail), the start of the RTL
/// path.
class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key, required this.course});

  /// Index into [courses].
  final int course;

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen>
    with TickerProviderStateMixin {
  late final List<Unit> _units = unitsOf(widget.course);
  late final CourseUnitsProgress _state = unitsProgressOf(widget.course);

  /// Entry: header settles, circles pop in right to left, the line draws
  /// itself and the diamonds light up, the rings fill, the badge counts up.
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  /// Breathing glow of the open unit, badge shine, check pulse (4 s).
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
  )..repeat();

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

  // Unit completion (Angular border-fill + owner 2026-11-22: vibration and
  // light). See _complete.
  late final AnimationController _fill = AnimationController(vsync: this)
    ..addListener(_fillTicks);
  late final AnimationController _half = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..addListener(_flowTicks);
  late final AnimationController _unlock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  int? _completing;
  double _fillFrom = 0;
  double _fillTo = 0;
  int _lastTick = 0;

  /// Path position in pages (0 = first unit centred). A custom track rather
  /// than a PageView, so the units on both sides of the screen are always
  /// drawn, also the completed one next to the rail (critic v3, D15).
  late final AnimationController _scroll = AnimationController.unbounded(
    vsync: this,
    value: _current.clamp(0, math.max(0, _units.length - 1)).toDouble(),
  );
  double _dragPitch = 1;

  int get _current => _state.current;

  @override
  void initState() {
    super.initState();
    unitCompleted.addListener(_onUnitCompleted);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onUnitCompleted());
  }

  @override
  void dispose() {
    unitCompleted.removeListener(_onUnitCompleted);
    for (final c in [
      _entry,
      _ambient,
      _shake,
      _toast,
      _fill,
      _half,
      _flash,
      _flow,
      _unlock,
      _scroll,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _glideTo(int i, int ms) => _scroll.animateTo(
    i.toDouble(),
    duration: Duration(milliseconds: ms),
    curve: Curves.easeInOutCubic,
  );

  void _onDrag(DragUpdateDetails d) {
    if (_completing != null) return;
    _scroll.stop();
    // RTL path: dragging to the right brings the next units in.
    final max = (_units.length - 1).toDouble();
    var v = _scroll.value + d.delta.dx / _dragPitch;
    if (v < 0) v = _scroll.value + d.delta.dx / _dragPitch * 0.35;
    if (v > max) v = _scroll.value + d.delta.dx / _dragPitch * 0.35;
    _scroll.value = v;
  }

  void _onDragEnd(DragEndDetails d) {
    if (_completing != null) return;
    final v = (d.primaryVelocity ?? 0) / _dragPitch;
    var target = (_scroll.value + v * 0.25).round();
    target = target.clamp(0, _units.length - 1);
    _glideTo(target, 420);
  }

  void _onUnitCompleted() {
    final i = unitCompleted.value;
    if (i == null || !mounted || _completing != null) return;
    unitCompleted.value = null;
    _complete(i).then((_) {
      if (mounted) _onUnitCompleted();
    });
  }

  /// One haptic tick every 10% while the ring fills (Angular: 4 pulses).
  void _fillTicks() {
    final p = lerpDouble(_fillFrom, _fillTo, _fill.value)!;
    final step = (p * 10).floor();
    if (step != _lastTick) {
      _lastTick = step;
      Haptics.tick();
    }
  }

  void _flowTicks() {
    final step = (_flow.value * 3).floor();
    if (step != _lastTick && step < 3) {
      _lastTick = step;
      if (step > 0) Haptics.tick();
    }
  }

  Future<void> _fillRing(int i, double to) async {
    final from = _state.progress[i];
    if (to <= from) return;
    setState(() {
      _fillFrom = from;
      _fillTo = to;
      _lastTick = (from * 10).floor();
    });
    _fill.duration = Duration(milliseconds: (1500 * (to - from)).round());
    await _fill.forward(from: 0);
    _state.progress[i] = to;
  }

  /// Completion of unit [i], automatic when its last lesson ends:
  /// 1) the path centres the unit; 2) the ring fills with a light head (tick
  ///    every 10%, fill sound), at 50% the first half of the line and its
  ///    diamond light up; 3) at 100% gold flash and sparkles, the play disc
  ///    turns into the type icon with a check badge (milestone);
  /// 4) the light runs to the next unit (unlock); 5) its padlock pops, the
  ///    ring turns gold, the badge drops in; 6) the path glides to it
  ///    (success) and its lessons open. Last unit: back to the courses
  ///    screen, which plays the course completion.
  Future<void> _complete(int i) async {
    if (i != _current || i >= _units.length) return;
    setState(() => _completing = i);
    if (_entry.isAnimating) await _entry.forward();
    if ((_scroll.value - i).abs() > 0.01) await _glideTo(i, 500);
    Sounds.fill();
    if (_state.progress[i] < 0.5) {
      await _fillRing(i, 0.5);
      Haptics.milestone();
      await _half.forward(from: 0);
    }
    await _fillRing(i, 1);
    Haptics.milestone();
    await _flash.forward(from: 0);
    final last = i == _units.length - 1;
    if (last) {
      setState(() {
        _state.current = _units.length;
        _completing = null;
      });
      _resetSequence();
      Haptics.success();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      // Back to the courses screen, which plays the course completion.
      Navigator.of(context).pop();
      courseCompleted.value = widget.course;
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _lastTick = 0;
    await _flow.forward(from: 0);
    Haptics.unlock();
    await _unlock.forward(from: 0);
    setState(() {
      _state.current = i + 1;
      _completing = null;
    });
    _resetSequence();
    await _glideTo(i + 1, 750);
    Haptics.success();
    // Owner (2026-11-22): the next unit's lessons open by themselves.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) _openLessons(i + 1);
  }

  void _resetSequence() {
    _fill.value = 0;
    _half.value = 0;
    _flash.value = 0;
    _flow.value = 0;
    _unlock.value = 0;
  }

  /// Opens screen 06, the lessons of unit [i]. Back here: if its last lesson
  /// was just finished the unit completion plays; otherwise the ring catches
  /// up with the lessons done (one shared progress, owner 2026-11-22).
  Future<void> _openLessons(int i) async {
    final finished = await Navigator.of(context)
        .push<bool>(lessonsRoute(widget.course, i));
    if (!mounted) return;
    // Last lesson finished: screen 06 has set `unitCompleted`.
    if (finished == true) return;
    await _catchUp(i);
  }

  /// The ring of the unit in progress fills to the share of its lessons done,
  /// with the ticks; crossing 50% lights the first half of the line.
  Future<void> _catchUp(int i) async {
    if (i != _current || _completing != null) return;
    final target = unitShareFromLessons(_units[i].id);
    if (target <= _state.progress[i] + 0.001) return;
    setState(() => _completing = i);
    if ((_scroll.value - i).abs() > 0.01) await _glideTo(i, 450);
    if (_state.progress[i] < 0.5 && target >= 0.5) {
      await _fillRing(i, 0.5);
      Haptics.milestone();
      await _half.forward(from: 0);
    }
    await _fillRing(i, target);
    if (!mounted) return;
    setState(() => _completing = null);
    _resetSequence();
  }

  Future<void> _showToast(String text) async {
    setState(() => _toastText = text);
    await _toast.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (mounted && _toastText == text) await _toast.reverse();
  }

  void _tapUnit(int i) {
    if (_completing != null) return;
    if (i > _current) {
      Haptics.denied();
      setState(() => _shaking = i);
      _shake.forward(from: 0);
      _showToast('أكمل «${_units[i - 1].title}» أولًا');
    } else {
      _openLessons(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final g = _Geo(box.maxWidth, box.maxHeight);
        return Stack(
          fit: StackFit.expand,
          // The bottom-right ornament runs on under the side rail.
          clipBehavior: Clip.none,
          children: [
            const ScreenBackground(),
            ..._decor(g),
            ..._header(g),
            if (_units.isEmpty) _empty(g) else _path(g),
            _toastLayer(g),
          ],
        );
      },
    );
  }

  Widget _path(_Geo g) {
    _dragPitch = g.pitch;
    return Positioned(
      left: 0,
      right: 0,
      top: g.circleCenterY - g.trackHalfHeight,
      height: g.trackHalfHeight * 2,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: _onDrag,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          // No _ambient here: the 4 s loop drives only the parts of the
          // circles it animates (UnitCircle), not the whole path
          // (PERFORMANCE.md, cause 1).
          animation: Listenable.merge([
            _entry,
            _shake,
            _fill,
            _half,
            _flash,
            _flow,
            _unlock,
            _scroll,
          ]),
          builder: (context, _) {
            final page = _scroll.value;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < _units.length; i++)
                  if ((i - page).abs() < 3.2)
                    Positioned(
                      // Unit i centre: firstCenterFromRight + (i − page)·pitch
                      // from the content's right edge.
                      left:
                          g.w -
                          g.firstCenterFromRight -
                          (i - page) * g.pitch -
                          g.pitch / 2,
                      top: 0,
                      width: g.pitch,
                      height: g.trackHalfHeight * 2,
                      child: _page(g, page, i),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _page(_Geo g, double page, int i) {
    final e = _entry.value;
    // Circles pop in right to left, starting at the one in focus.
    final order = (i - page.round()).clamp(0, 4);
    final appear = _interval(e, 0.12 + 0.09 * order, 0.5 + 0.09 * order);
    final pop = Curves.easeOutBack.transform(appear);
    final draw = Curves.easeInOutCubic.transform(_interval(e, 0.5, 0.85));
    final entryFill = Curves.easeOutCubic.transform(_interval(e, 0.6, 1));
    final shake = _shaking == i
        ? math.sin(_shake.value * math.pi * 5) * (1 - _shake.value)
        : 0.0;

    double progress = i < _current ? 1 : _state.progress[i] * entryFill;
    if (i == _completing && _fill.isAnimating) {
      progress = lerpDouble(
        _fillFrom,
        _fillTo,
        Curves.easeInOutCubic.transform(_fill.value),
      )!;
    } else if (i == _completing) {
      progress = _state.progress[i];
    }
    double done = i < _current ? 1 : 0;
    if (i == _completing) done = _flash.value;
    double unlock = i <= _current ? 1 : 0;
    if (_completing != null && i == _completing! + 1) unlock = _unlock.value;

    // Line after unit i: first half lit from 50%, second half on completion.
    double half1 = i < _current || _state.progress[i] >= 0.5 ? 1 : 0;
    if (i == _completing && _half.isAnimating) half1 = _half.value;
    double half2 = i < _current ? 1 : 0;
    if (i == _completing) half2 = _flow.value;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (i < _units.length - 1)
          _connector(
            g,
            draw,
            half1,
            half2,
            nodePop: i == _completing && _half.isAnimating ? _half.value : 0,
          ),
        Opacity(
          opacity: appear,
          child: Transform.scale(
            scale: lerpDouble(0.85, 1, pop)!,
            // Each circle paints in its own layer: a drag of the path only
            // moves the layers (PERFORMANCE.md, cause 4).
            child: RepaintBoundary(
              child: UnitCircle(
                unit: _units[i],
                u: g.u,
                progress: progress,
                unlock: unlock,
                done: done,
                flash: i == _completing ? _flash.value : 0,
                ambient: _ambient,
                lockShake: shake,
                filling: i == _completing && _fill.isAnimating,
                onTap: () => _tapUnit(i),
                onLongPress: () {
                  // Demo until screens 06–07 exist: long press on the unit in
                  // progress plays its completion.
                  if (i == _current) unitCompleted.value = i;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Line from this circle's left edge to the next circle, with a gold
  /// diamond in the middle.
  Widget _connector(
    _Geo g,
    double draw,
    double half1,
    double half2, {
    required double nodePop,
  }) {
    final gap = g.pitch - g.ring;
    final left = g.pitch / 2 - g.ring / 2 - gap;
    return Positioned(
      left: left,
      top: g.trackHalfHeight - g.u * 2.5 - g.u * 0.2,
      width: gap,
      height: g.u * 5,
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

  Widget _settle(_Geo g, Widget child) => AnimatedBuilder(
    animation: _entry,
    builder: (context, c) {
      final t = Curves.easeOutCubic.transform(_interval(_entry.value, 0, 0.35));
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

  /// Corner ornaments top left and bottom right (owner, 2026-11-22), the
  /// owner's lattice corners drawn after reference 05; the faint girih
  /// pattern (U6) covers the background.
  List<Widget> _decor(_Geo g) {
    return [
      const Positioned.fill(child: IgnorePointer(child: ScreenGirih())),
      Positioned(
        left: 0,
        top: 0,
        width: g.u * 21.5,
        height: g.u * 21.5 * 606 / 800,
        child: IgnorePointer(
          child: GoldCorner(
            'assets/ui/decor/corner_units_top_left.webp',
            u: g.u,
          ),
        ),
      ),
      Positioned(
        right: 0,
        bottom: 0,
        width: g.u * 22,
        height: g.u * 22 * 628 / 800,
        child: IgnorePointer(
          child: GoldCorner(
            'assets/ui/decor/corner_units_bottom_right.webp',
            u: g.u,
          ),
        ),
      ),
    ];
  }

  List<Widget> _header(_Geo g) {
    final cx = g.titleCenterX;
    return [
      // Mosque silhouette (CR-03), faint, as in the reference.
      Positioned(
        left: g.u * 44.1,
        top: g.u * 6.9,
        width: g.u * 30.3,
        height: g.u * 30.3 * 542 / 900,
        child: _settle(
          g,
          IgnorePointer(
            child: Opacity(
              opacity: 1,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.62, 0.82],
                  colors: [Color(0xFF000000), Color(0x00000000)],
                ).createShader(r),
                child: Image.asset(
                  'assets/ui/decor/mosque.webp',
                  fit: BoxFit.contain,
                  // Olive tint, as in the reference (critic v1).
                  color: RateelColors.unitMosqueTint,
                  colorBlendMode: BlendMode.srcATop,
                ),
              ),
            ),
          ),
        ),
      ),
      // Crescent and star (CR-04), muted as in the reference.
      Positioned(
        left: g.u * 81.8 - g.u * 4.3,
        top: g.u * 17.3 - g.u * 3.95,
        width: g.u * 8.6,
        height: g.u * 7.9,
        child: _settle(
          g,
          IgnorePointer(
            child: Opacity(
              opacity: 0.18,
              child: SvgPicture.asset(
                'assets/ui/decor/crescent_star.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
      // Header arch (CR-01), centred on the title (owner, 2026-11-22).
      Positioned(
        left: cx - g.archW / 2,
        top: g.u * 2.0,
        width: g.archW,
        height: g.u * 13.2,
        child: _settle(
          g,
          IgnorePointer(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1.0],
                colors: [Color(0xFF000000), Color(0x00000000)],
              ).createShader(r),
              // Gold along the stroke: darker ends, bright apex (critic v3).
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (r) => const LinearGradient(
                  stops: [0, 0.15, 0.32, 0.5, 0.68, 0.85, 1],
                  colors: [
                    RateelColors.archEnd,
                    RateelColors.archTail,
                    RateelColors.archShoulder,
                    RateelColors.archApex,
                    RateelColors.archShoulder,
                    RateelColors.archTail,
                    RateelColors.archEnd,
                  ],
                ).createShader(r),
                child: SvgPicture.asset(
                  'assets/ui/decor/header_arch.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
      // Title «وحدات المقرر», on the right as in the reference.
      Positioned(
        left: cx - g.u * 30,
        width: g.u * 60,
        top: g.u * (17.5 - 0.65) - g.u * 6,
        height: g.u * 12,
        child: _settle(
          g,
          Center(
            child: Stack(
              children: [
                Text(
                  'وحدات المقرر',
                  textDirection: TextDirection.rtl,
                  style: readex(
                    g.u * 7.5,
                    weight: 560,
                    color: Colors.transparent,
                  ).copyWith(height: 1.35, shadows: titleShadows(g.u)),
                ),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (r) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [titleTop, titleBottom],
                  ).createShader(r),
                  child: Text(
                    'وحدات المقرر',
                    textDirection: TextDirection.rtl,
                    style: readex(
                      g.u * 7.5,
                      weight: 560,
                      color: Colors.white,
                    ).copyWith(height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Title divider (CR-06).
      Positioned(
        left: cx - g.u * 17.25,
        top: g.u * 24.2 - g.u * 1.8,
        width: g.u * 34.5,
        height: g.u * 3.6,
        child: _settle(
          g,
          IgnorePointer(
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (r) => const LinearGradient(
                stops: [0, .12, .33, .5, .67, .88, 1],
                colors: [
                  RateelColors.dividerEndClear,
                  RateelColors.dividerEnd,
                  RateelColors.dividerMid,
                  RateelColors.dividerPeak,
                  RateelColors.dividerMid,
                  RateelColors.dividerEnd,
                  RateelColors.dividerEndClear,
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
      // «تغيير المقرر»: back to the courses screen.
      Positioned(
        left: g.u * 7.5,
        top: g.u * 13.1,
        width: g.u * 30.5,
        height: g.u * 7.8,
        child: _settle(g, _ChangeCourseButton(u: g.u)),
      ),
    ];
  }

  Widget _empty(_Geo g) {
    return Positioned(
      left: 0,
      right: 0,
      top: g.circleCenterY - g.u * 6,
      height: g.u * 12,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: g.u * 5, vertical: g.u * 2),
          decoration: BoxDecoration(
            color: RateelColors.cardMid,
            borderRadius: BorderRadius.circular(g.u * 4),
            border: Border.all(color: RateelColors.cardRim, width: g.u * 0.23),
          ),
          child: Text(
            'وحدات هذا المسار: قريبًا',
            textDirection: TextDirection.rtl,
            style: readex(g.u * 4, weight: 450, color: titleCream),
          ),
        ),
      ),
    );
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

/// Glass pill «تغيير المقرر» with the swap icon (placeholder until U5).
class _ChangeCourseButton extends StatefulWidget {
  const _ChangeCourseButton({required this.u});

  final double u;

  @override
  State<_ChangeCourseButton> createState() => _ChangeCourseButtonState();
}

class _ChangeCourseButtonState extends State<_ChangeCourseButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        Haptics.tap();
        Navigator.of(context).maybePop();
      },
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(u * 3.9),
            color: RateelColors.pillFill.withValues(alpha: 0.6),
            border: Border.all(
              color: RateelColors.unitRingLocked.withValues(alpha: 0.8),
              width: u * 0.22,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: u * 3.3),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/ui/glyphs/swap.svg',
                  width: u * 3.5,
                  height: u * 3.4,
                  theme: const SvgTheme(currentColor: RateelColors.cream),
                ),
                SizedBox(width: u * 3.1),
                Padding(
                  padding: EdgeInsets.only(bottom: u * 0.45),
                  child: Text(
                    'تغيير المقرر',
                    textDirection: TextDirection.rtl,
                    style: readex(
                      u * 2.9,
                      weight: 420,
                      color: RateelColors.cream,
                    ).copyWith(height: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

double _interval(double t, double a, double b) =>
    ((t - a) / (b - a)).clamp(0.0, 1.0);

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.u,
    required this.draw,
    required this.half1,
    required this.half2,
    required this.nodePop,
  });

  final double u;
  final double draw;
  final double half1;
  final double half2;
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
        ..color = RateelColors.goldHighlight
        ..strokeWidth = u * 0.3,
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
    // Snapped to a pixel row so the thin line stays crisp.
    final y = (size.height / 2).roundToDouble() + 0.5;
    final right = size.width;
    final mid = size.width / 2;
    final left = right - size.width * draw;
    // Thin gold line with dark edges (reference). The brighter lit halves
    // keep the course-path rule (50% / 100%); the full-bright reference line
    // is an open owner decision.
    canvas.drawLine(
      Offset(left, y),
      Offset(right, y),
      Paint()
        ..color = RateelColors.unitLineEdge
        ..strokeWidth = u * 0.45,
    );
    canvas.drawLine(
      Offset(left, y),
      Offset(right, y),
      Paint()
        ..color = RateelColors.unitLine
        ..strokeWidth = u * 0.25,
    );
    if (half1 > 0) _light(canvas, right, right - mid * half1, y, half1 < 1);
    if (half2 > 0) _light(canvas, mid, mid - mid * half2, y, half2 < 1);

    final on = ((draw - 0.1) / 0.3).clamp(0.0, 1.0);
    if (on == 0) return;
    final lit = half1 >= 1;
    final glow = lit
        ? 1.0
        : (nodePop > 0 ? math.sin(math.pi / 2 * nodePop) : 0.0);
    final node = Offset(mid, y);
    if (glow > 0) {
      canvas.drawCircle(
        node,
        u * 2.4,
        Paint()
          ..color = RateelColors.gold.withValues(alpha: 0.35 * on * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.2),
      );
    }
    // Gold diamond (2.1u), pops when the first half lights up.
    final s = u * 1.3 * on * (1 + 0.5 * math.sin(math.pi * nodePop));
    // Permanent soft glow (reference), stronger when lit.
    canvas.drawCircle(
      node,
      u * 1.4,
      Paint()
        ..color = RateelColors.gold.withValues(alpha: 0.10 * on)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.0),
    );
    final diamond = Path()
      ..moveTo(node.dx, node.dy - s)
      ..lineTo(node.dx + s, node.dy)
      ..lineTo(node.dx, node.dy + s)
      ..lineTo(node.dx - s, node.dy)
      ..close();
    canvas.drawPath(
      diamond,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.2, 1],
          colors: lit || nodePop > 0.5
              ? const [
                  RateelColors.label,
                  RateelColors.goldHighlight,
                  RateelColors.goldHighlight,
                ]
              : const [
                  RateelColors.unitDiamondTop,
                  RateelColors.unitDiamondMid,
                  RateelColors.unitDiamond,
                ],
        ).createShader(diamond.getBounds()),
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

/// Reference geometry (u = 1% of the height). Ref px / 9.41.
class _Geo {
  _Geo(this.w, this.h) : u = h / 100;

  final double w;
  final double h;
  final double u;

  /// Outer ring diameter: 433 px.
  double get ring => u * 47.2;

  /// Circle centre to circle centre: 626 px.
  double get pitch => u * 66.5;

  /// First circle centre: 480 px from the content's right edge.
  double get firstCenterFromRight => u * 51;

  double get trackRightInset => firstCenterFromRight - pitch / 2;
  double get circleCenterY => u * 58.2;

  /// Room above and below the circle for the badge, check and sparkles.
  double get trackHalfHeight => u * 33;

  /// Title centre: 298 px from the content's right edge.
  double get titleCenterX => w - u * 31.7;

  /// Arch width: it frames the title without running under the rail.
  double get archW => u * 45.4;
}
