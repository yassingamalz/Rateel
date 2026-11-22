import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../theme/rateel_theme.dart';
import '../units/unit_data.dart';
import 'lesson_card.dart';
import 'lesson_data.dart';
import 'lesson_page.dart';

/// Opens screen 06 for unit [unit] (index into [unitsOf]) of course
/// [course]. The route returns `true` when the last lesson of the unit was
/// just finished: screen 05 then plays the unit completion.
Route<bool> lessonsRoute(int course, int unit) => PageRouteBuilder<bool>(
  transitionDuration: const Duration(milliseconds: 520),
  reverseTransitionDuration: const Duration(milliseconds: 420),
  pageBuilder: (context, a, b) => LessonsScreen(course: course, unit: unit),
  transitionsBuilder: (context, a, b, child) {
    final t = Curves.easeOutCubic.transform(a.value);
    return Opacity(
      opacity: t,
      child: Transform.scale(scale: lerpDouble(0.94, 1, t), child: child),
    );
  },
);

/// Screen 06, lessons of the unit (docs/flutter/screens/06-lessons.md).
///
/// Two looks under review (owner, 2026-11-22): `ref` (ChatGPT reference 06,
/// 1844×853, u = 8.53 px) and `orig` (the Angular lessons screen, improved).
/// Horizontal positions are taken from the right edge of the content (the
/// left edge of the side rail), the start of the RTL path.
class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key, required this.course, required this.unit});

  final int course;
  final int unit;

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen>
    with TickerProviderStateMixin {
  late final Unit _unit = unitsOf(widget.course)[widget.unit];
  late final List<Lesson> _lessons = lessonsOf(_unit.id);

  /// Lessons done. A unit already completed on screen 05 (also by the demo)
  /// shows all its lessons done.
  int get _done => widget.unit < unitsProgressOf(widget.course).current
      ? _lessons.length
      : lessonsDone(_unit.id).clamp(0, _lessons.length);

  /// The lesson in progress (none when all are done).
  int get _current => _done;

  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();
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

  // Lesson completion (Angular border fill + owner: vibration and light).
  late final AnimationController _border = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..addListener(_borderTicks);
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  late final AnimationController _unlock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  int? _completing;
  int _lastTick = 0;

  late final AnimationController _scroll = AnimationController.unbounded(
    vsync: this,
    value: _pageFor(_current.clamp(0, math.max(0, _lessons.length - 1))),
  );
  double _dragPitch = 1;

  /// Cards that fit between the rail and the left edge (look B only; set on
  /// layout).
  int _fit = 1;
  bool _laidOut = false;

  /// Path position that shows lesson [i]. Look A centres it (reference);
  /// look B keeps the first lesson at the start as long as [i] is on screen
  /// (Angular: the small cards all fit), so done lessons stay visible.
  double _pageFor(int i) =>
      _style == 'orig' ? math.max(0, i - _fit + 1).toDouble() : i.toDouble();

  @override
  void initState() {
    super.initState();
    lessonsStyle.addListener(_restyle);
    final k = startCompleteLesson;
    if (k != null) {
      startCompleteLesson = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _complete(k));
    }
  }

  void _restyle() => setState(() {
    _scroll.value = _pageFor(
      _current.clamp(0, math.max(0, _lessons.length - 1)),
    );
  });

  @override
  void dispose() {
    lessonsStyle.removeListener(_restyle);
    for (final c in [
      _entry,
      _ambient,
      _shake,
      _toast,
      _border,
      _flash,
      _flow,
      _unlock,
      _scroll,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _style => lessonsStyle.value;

  void _borderTicks() {
    final q = (_border.value * 4).floor();
    if (q != _lastTick && q < 4) {
      _lastTick = q;
      Haptics.tick();
    }
  }

  Future<void> _glideTo(int i, int ms) => _scroll.animateTo(
    _pageFor(i),
    duration: Duration(milliseconds: ms),
    curve: Curves.easeInOutCubic,
  );

  void _onDrag(DragUpdateDetails d) {
    if (_completing != null) return;
    _scroll.stop();
    final max = (_lessons.length - 1).toDouble();
    var v = _scroll.value + d.delta.dx / _dragPitch;
    if (v < 0 || v > max) v = _scroll.value + d.delta.dx / _dragPitch * 0.35;
    _scroll.value = v;
  }

  void _onDragEnd(DragEndDetails d) {
    if (_completing != null) return;
    final v = (d.primaryVelocity ?? 0) / _dragPitch;
    final target = (_scroll.value + v * 0.25).round().clamp(
      0,
      _lessons.length - 1,
    );
    _glideTo(target, 420);
  }

  /// Completion of lesson [k], automatic when the lesson screen closes:
  /// 1) the path centres the card; 2) a gold light runs around the rim (a
  ///    haptic tick on every side); 3) gold flash and sparkles, the step pill
  ///    turns into ✓ (milestone); 4) the light runs along the line to the
  ///    next card (unlock); 5) its padlock flies off and the veil lifts, the
  ///    rim turns gold; 6) glide (success) and the next lesson opens.
  /// Last lesson of the unit: back to screen 05, which plays the unit
  /// completion.
  Future<void> _complete(int k) async {
    if (k != _current || k >= _lessons.length || _completing != null) return;
    setState(() => _completing = k);
    if (_entry.isAnimating) await _entry.forward();
    if ((_scroll.value - _pageFor(k)).abs() > 0.01) await _glideTo(k, 500);
    _lastTick = 0;
    Haptics.tick();
    await _border.forward(from: 0);
    Haptics.milestone();
    await _flash.forward(from: 0);
    final last = k == _lessons.length - 1;
    // The unit share moves on screen 05 when we go back. The last lesson
    // leaves the ring to the unit completion (it fills it to 100%).
    setLessonsDone(_unit.id, k + 1);
    if (last) {
      Haptics.success();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      // Back to screen 05, which plays the unit completion (also when this
      // screen was opened by a review link, with nobody awaiting the route).
      Navigator.of(context).pop(true);
      unitCompleted.value = widget.unit;
      return;
    }
    await _flow.forward(from: 0);
    Haptics.unlock();
    await _unlock.forward(from: 0);
    setState(() => _completing = null);
    _reset();
    await _glideTo(k + 1, 750);
    Haptics.success();
    // Angular: the next lesson opens by itself after 0.8 s.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) _openLesson(k + 1);
  }

  void _reset() {
    _border.value = 0;
    _flash.value = 0;
    _flow.value = 0;
    _unlock.value = 0;
  }

  Future<void> _openLesson(int k) async {
    final finished = await Navigator.of(context)
        .push<bool>(lessonPageRoute(_lessons[k], k + 1, _lessons.length));
    if (!mounted) return;
    if (finished == true && k == _current) await _complete(k);
  }

  Future<void> _showToast(String text) async {
    setState(() => _toastText = text);
    await _toast.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (mounted && _toastText == text) await _toast.reverse();
  }

  void _tapLesson(int k) {
    if (_completing != null) return;
    if (k > _current) {
      Haptics.denied();
      setState(() => _shaking = k);
      _shake.forward(from: 0);
      _showToast('أكمل «${_lessons[k - 1].title}» أولًا');
    } else {
      _openLesson(k);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final g = _Geo(_style, box.maxWidth, box.maxHeight);
        final b = _Geo('orig', box.maxWidth, box.maxHeight);
        _fit = math.max(
          1,
          ((b.w - b.firstCenterFromRight + b.card.width / 2 - b.u * 2) /
                  b.pitch)
              .floor(),
        );
        if (!_laidOut) {
          _laidOut = true;
          _scroll.value = _pageFor(
            _current.clamp(0, math.max(0, _lessons.length - 1)),
          );
        }
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            const ScreenBackground(),
            ..._decor(g),
            ..._header(g),
            if (_lessons.isEmpty) _empty(g) else _path(g),
            _styleSwitch(g),
            _toastLayer(g),
          ],
        );
      },
    );
  }

  Widget _path(_Geo g) {
    _dragPitch = g.pitch;
    final half = g.card.height / 2 + g.u * 9;
    return Positioned(
      left: 0,
      right: 0,
      top: g.cardCenterY - half,
      height: half * 2,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: _onDrag,
        onHorizontalDragEnd: _onDragEnd,
        // The path fades out at the left edge (reference: the line runs off,
        // no card sliver) and just before the rail, so a card gliding under
        // the rail leaves no sliver (critic v1 A8, A10).
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => LinearGradient(
            stops: [
              (g.u * 8 / r.width).clamp(0.0, 1.0),
              (g.u * 18 / r.width).clamp(0.0, 1.0),
              ((r.width - g.u * 3) / r.width).clamp(0.0, 1.0),
              1,
            ],
            colors: const [
              Color(0x00000000),
              Color(0xFF000000),
              Color(0xFF000000),
              Color(0x00000000),
            ],
          ).createShader(r),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _entry,
              _ambient,
              _shake,
              _border,
              _flash,
              _flow,
              _unlock,
              _scroll,
            ]),
            builder: (context, _) {
              final page = _scroll.value;
              final draw = Curves.easeInOutCubic.transform(
                _interval(_entry.value, 0.45, 0.85),
              );
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Lines first, under the cards.
                  for (var i = 0; i < _lessons.length; i++)
                    if ((i - page).abs() < 3.2)
                      _connector(g, page, i, half, draw),
                  for (var i = 0; i < _lessons.length; i++)
                    if ((i - page).abs() < 3.2) _cardAt(g, page, i, half),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _centerX(_Geo g, double page, int i) =>
      g.w - g.firstCenterFromRight - (i - page) * g.pitch;

  Widget _connector(_Geo g, double page, int i, double half, double draw) {
    final cx = _centerX(g, page, i);
    final last = i == _lessons.length - 1;
    // From this card's left edge to the next card's right edge; after the
    // last card the line runs off as in the reference (ref look only).
    if (last && _style == 'orig') return const SizedBox.shrink();
    final gap = g.pitch - g.card.width;
    final right = cx - g.card.width / 2;
    final width = last ? g.u * 14 : gap;
    double lit = i < _done ? 1 : 0;
    if (i == _completing) lit = _flow.value;
    return Positioned(
      left: right - width,
      width: width,
      top: half - g.u * 2.5,
      height: g.u * 5,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _LinePainter(
            u: g.u,
            draw: draw,
            lit: last ? 0 : lit,
            node: !last,
            fadeOut: last,
            style: _style,
          ),
        ),
      ),
    );
  }

  Widget _cardAt(_Geo g, double page, int i, double half) {
    final e = _entry.value;
    final order = (i - page.round()).clamp(0, 4);
    final appear = _interval(e, 0.08 + 0.09 * order, 0.45 + 0.09 * order);
    final pop = Curves.easeOutBack.transform(appear);
    final shake = _shaking == i
        ? math.sin(_shake.value * math.pi * 5) * (1 - _shake.value)
        : 0.0;
    double unlock = i <= _current ? 1 : 0;
    if (_completing != null && i == _completing! + 1) unlock = _unlock.value;
    double done = i < _done ? 1 : 0;
    if (i == _completing) done = _flash.value;
    final cx = _centerX(g, page, i);
    return Positioned(
      left: cx - g.card.width / 2,
      top: half - g.card.height / 2,
      width: g.card.width,
      height: g.card.height,
      child: Opacity(
        opacity: appear,
        child: Transform.scale(
          scale: lerpDouble(0.95, 1, pop)!,
          child: LessonCard(
            key: ValueKey('lesson-$i'),
            lesson: _lessons[i],
            style: _style,
            u: g.u,
            step: i + 1,
            total: _lessons.length,
            unlock: unlock,
            done: done,
            active:
                i == _current || (_completing != null && i == _completing! + 1),
            border: i == _completing ? _border.value : 0,
            flash: i == _completing ? _flash.value : 0,
            ambient: _ambient.value,
            lockShake: shake,
            onTap: () => _tapLesson(i),
            // Demo until the lesson screens exist: long press on the lesson
            // in progress plays its completion.
            onLongPress: () {
              if (i == _current) _complete(i);
            },
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

  List<Widget> _decor(_Geo g) {
    if (g.orig) {
      // Original Angular decoration: islamic-pattern-2 (gold), 700 px tiles,
      // turned 50°, very faint.
      return [
        Positioned.fill(
          child: IgnorePointer(child: _AngularPattern(tile: g.u * 82)),
        ),
      ];
    }
    return [
      const Positioned.fill(child: IgnorePointer(child: ScreenGirih())),
      Positioned(
        left: 0,
        top: 0,
        width: g.u * 27,
        height: g.u * 27 * 606 / 800,
        child: IgnorePointer(
          child: GoldCorner(
            'assets/ui/decor/corner_units_top_left.webp',
            u: g.u,
          ),
        ),
      ),
    ];
  }

  Widget _title(_Geo g, double size) {
    final text = _unit.title;
    final style = readex(
      size,
      weight: 560,
      color: Colors.white,
    ).copyWith(height: 1.35);
    return Stack(
      children: [
        Text(
          text,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          style: style.copyWith(
            color: Colors.transparent,
            shadows: titleShadows(g.u),
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [titleTop, titleBottom],
          ).createShader(r),
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            style: style,
          ),
        ),
      ],
    );
  }

  Widget _divider(double w, double h) => IgnorePointer(
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
        width: w,
        height: h,
        fit: BoxFit.fill,
      ),
    ),
  );

  List<Widget> _header(_Geo g) {
    final u = g.u;
    if (g.orig) {
      // Angular: small title at the top right with the back arrow; improved
      // with the cream title, a glass back button and a short divider.
      return [
        Positioned(
          right: u * 4.5,
          top: u * 6.2,
          width: u * 7,
          height: u * 7,
          child: _settle(g, _BackButton(u: u)),
        ),
        Positioned(
          right: u * 14,
          top: u * 5.2,
          height: u * 9,
          width: g.w * 0.6,
          child: _settle(
            g,
            Align(alignment: Alignment.centerRight, child: _title(g, u * 4.8)),
          ),
        ),
        Positioned(
          right: u * 14,
          top: u * 14.2,
          child: _settle(g, _divider(u * 26, u * 2.6)),
        ),
      ];
    }
    final cx = g.titleCenterX;
    return [
      Positioned(
        left: u * 30.5,
        top: u * 11.7,
        width: u * 33.4,
        height: u * 23,
        child: _settle(
          g,
          IgnorePointer(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.72, 1.0],
                colors: [Color(0xFF000000), Color(0x00000000)],
              ).createShader(r),
              child: Image.asset(
                'assets/ui/decor/mosque.webp',
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                color: RateelColors.lessonMosqueTint,
                colorBlendMode: BlendMode.srcATop,
              ),
            ),
          ),
        ),
      ),
      // Arch centred on the title (reference 06), book emblem on the apex.
      Positioned(
        left: cx - g.archW / 2,
        top: u * 0.9,
        width: g.archW,
        height: u * 21,
        child: _settle(
          g,
          IgnorePointer(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.55, 1.0],
                colors: [Color(0xFF000000), Color(0x00000000)],
              ).createShader(r),
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
      Positioned(
        left: cx - u * 9.5,
        top: u * 13.3 - u * 4.35,
        width: u * 19,
        height: u * 8.7,
        child: _settle(
          g,
          IgnorePointer(
            child: SvgPicture.asset(
              'assets/ui/decor/header_book.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      Positioned(
        left: cx - u * 45,
        width: u * 90,
        top: u * 23.4 - u * 6,
        height: u * 12,
        child: _settle(
          g,
          Center(
            child: FittedBox(fit: BoxFit.scaleDown, child: _title(g, u * 7.5)),
          ),
        ),
      ),
      // Title divider drawn in code (critic v1 A1): two fading lines and an
      // open diamond on the title axis, 62.7u long.
      Positioned(
        left: cx - u * 31.35,
        top: u * 32.1 - u * 1.8,
        width: u * 62.7,
        height: u * 3.6,
        child: _settle(
          g,
          IgnorePointer(child: CustomPaint(painter: _DividerPainter(u))),
        ),
      ),
      Positioned(
        left: g.w - u * 33.5 - u * 4.55,
        top: u * 24.4 - u * 4.55,
        width: u * 9.1,
        height: u * 9.1,
        child: _settle(g, _BackButton(u: u)),
      ),
    ];
  }

  Widget _empty(_Geo g) {
    return Positioned(
      left: 0,
      right: 0,
      top: g.cardCenterY - g.u * 6,
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
            'دروس هذه الوحدة: قريبًا',
            textDirection: TextDirection.rtl,
            style: readex(g.u * 4, weight: 450, color: titleCream),
          ),
        ),
      ),
    );
  }

  /// Review only (owner's two trials): switch between the ChatGPT look (A)
  /// and the original look, improved (B). Removed once the owner chooses.
  Widget _styleSwitch(_Geo g) {
    final u = g.u;
    Widget seg(String id, String label) {
      final on = _style == id;
      return GestureDetector(
        onTap: () {
          Haptics.tap();
          lessonsStyle.value = id;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: u * 2.2, vertical: u * 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(u * 3),
            color: on ? RateelColors.gold : Colors.transparent,
          ),
          child: Text(
            label,
            textDirection: TextDirection.rtl,
            style: readex(
              u * 2.4,
              weight: 500,
              color: on ? RateelColors.badgeText : RateelColors.cream,
            ).copyWith(height: 1.1),
          ),
        ),
      );
    }

    // Under the mosque in look A (the cards fill the bottom), bottom left in B.
    return Positioned(
      left: u * 3,
      top: g.orig ? null : u * 33,
      bottom: g.orig ? u * 3 : null,
      child: Container(
        padding: EdgeInsets.all(u * 0.6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(u * 3.6),
          color: RateelColors.pillFill.withValues(alpha: 0.85),
          border: Border.all(color: RateelColors.rowRim, width: u * 0.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [seg('ref', 'A  ChatGPT'), seg('orig', 'B  الأصلي')],
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

double _interval(double t, double a, double b) =>
    ((t - a) / (b - a)).clamp(0.0, 1.0);

/// Glass circle with → (back to the units): the same light glass as the
/// close button of the side menu (design token).
class _BackButton extends StatefulWidget {
  const _BackButton({required this.u});

  final double u;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
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
        scale: _down ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                RateelColors.gold.withValues(alpha: 0.08),
                RateelColors.gold.withValues(alpha: 0.24),
              ],
            ),
            border: Border.all(color: RateelColors.ringLine, width: u * 0.2),
            boxShadow: [
              BoxShadow(
                color: RateelColors.gold.withValues(alpha: 0.22),
                blurRadius: u * 2,
              ),
            ],
          ),
          child: CustomPaint(painter: _ArrowPainter(u)),
        ),
      ),
    );
  }
}

/// → arrow (RTL back), drawn like the ☰ / ✕ of the side nav.
class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.u);

  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // Reference: 3.2×2.8u arrow, 0.35u stroke (critic v1 A7).
    final s = u * 1.6;
    final p = Paint()
      ..color = RateelColors.closeWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = u * 0.35
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawLine(c + Offset(-s, 0), c + Offset(s, 0), p);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx + s * 0.15, c.dy - s * 0.85)
        ..lineTo(c.dx + s, c.dy)
        ..lineTo(c.dx + s * 0.15, c.dy + s * 0.85),
      p,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter o) => o.u != u;
}

/// Title divider of look A: lines fading out to the ends, brightest next to
/// an open diamond (3.5u tall, 1.2u gap on each side).
class _DividerPainter extends CustomPainter {
  _DividerPainter(this.u);

  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final d = u * 1.75;
    final gap = u * 1.2;
    final y = c.dy.roundToDouble() + 0.5;
    for (final side in [-1.0, 1.0]) {
      final from = c.dx + side * (d + gap);
      final to = side < 0 ? 0.0 : size.width;
      canvas.drawLine(
        Offset(from, y),
        Offset(to, y),
        Paint()
          ..strokeWidth = u * 0.35
          ..shader = LinearGradient(
            begin: side < 0 ? Alignment.centerRight : Alignment.centerLeft,
            end: side < 0 ? Alignment.centerLeft : Alignment.centerRight,
            stops: const [0, 0.35, 0.8, 1],
            colors: const [
              RateelColors.dividerPeak,
              RateelColors.dividerMid,
              RateelColors.dividerEnd,
              RateelColors.dividerEndClear,
            ],
          ).createShader(Rect.fromPoints(Offset(from, 0), Offset(to, 1))),
      );
    }
    final diamond = Path()
      ..moveTo(c.dx, c.dy - d)
      ..lineTo(c.dx + d * 0.85, c.dy)
      ..lineTo(c.dx, c.dy + d)
      ..lineTo(c.dx - d * 0.85, c.dy)
      ..close();
    canvas.drawPath(
      diamond,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.35
        ..strokeJoin = StrokeJoin.miter
        ..color = RateelColors.dividerPeak,
    );
  }

  @override
  bool shouldRepaint(_DividerPainter o) => o.u != u;
}

/// The Angular decoration of the lessons page: islamic-pattern-2 (gold),
/// tiled, turned 50°, faint.
class _AngularPattern extends StatelessWidget {
  const _AngularPattern({required this.tile});

  final double tile;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, box) {
          final d = math.sqrt(
            box.maxWidth * box.maxWidth + box.maxHeight * box.maxHeight,
          );
          final n = (d / tile).ceil() + 1;
          return OverflowBox(
            maxWidth: n * tile,
            maxHeight: n * tile,
            child: Transform.rotate(
              angle: 50 * math.pi / 180,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  'assets/ui/decor/angular_pattern_2.webp',
                  repeat: ImageRepeat.repeat,
                  width: n * tile,
                  height: n * tile,
                  scale: 700 / tile,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Line between two cards: dim track, lit gold once the lesson on its right
/// is done, with a diamond in the middle (as the unit path).
class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.u,
    required this.draw,
    required this.lit,
    required this.node,
    required this.fadeOut,
    required this.style,
  });

  final double u;
  final double draw;
  final double lit;
  final bool node;
  final bool fadeOut;
  final String style;

  @override
  void paint(Canvas canvas, Size size) {
    if (draw == 0) return;
    final y = (size.height / 2).roundToDouble() + 0.5;
    final right = size.width;
    final left = right - size.width * draw;
    final track = Paint()
      ..strokeWidth = u * 0.28
      ..shader = LinearGradient(
        colors: fadeOut
            ? [
                RateelColors.unitLine.withValues(alpha: 0),
                RateelColors.unitLine.withValues(alpha: 0.55),
              ]
            : [
                RateelColors.unitLine.withValues(alpha: 0.55),
                RateelColors.unitLine.withValues(alpha: 0.55),
              ],
      ).createShader(Offset(left, 0) & Size(right - left, 1));
    canvas.drawLine(Offset(left, y), Offset(right, y), track);
    if (lit > 0) {
      final to = right - size.width * lit;
      canvas.drawLine(
        Offset(to, y),
        Offset(right, y),
        Paint()
          ..color = RateelColors.gold.withValues(alpha: 0.45)
          ..strokeWidth = u * 0.9
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.6),
      );
      canvas.drawLine(
        Offset(to, y),
        Offset(right, y),
        Paint()
          ..color = RateelColors.goldHighlight
          ..strokeWidth = u * 0.3,
      );
      if (lit < 1) {
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
    if (!node) return;
    final on = ((draw - 0.3) / 0.4).clamp(0.0, 1.0);
    if (on == 0) return;
    final c = Offset(size.width / 2, y);
    final pass = lit >= 0.5 ? 1.0 : 0.0;
    final popT = lit > 0.45 && lit < 0.75
        ? math.sin(math.pi * (lit - 0.45) / 0.3)
        : 0.0;
    final s = u * 1.3 * on * (1 + 0.5 * popT);
    canvas.drawCircle(
      c,
      u * 1.6,
      Paint()
        ..color = RateelColors.gold.withValues(alpha: (0.12 + 0.3 * pass) * on)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.1),
    );
    final d = Path()
      ..moveTo(c.dx, c.dy - s)
      ..lineTo(c.dx + s, c.dy)
      ..lineTo(c.dx, c.dy + s)
      ..lineTo(c.dx - s, c.dy)
      ..close();
    canvas.drawPath(
      d,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.2, 1],
          colors: pass > 0
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
        ).createShader(d.getBounds()),
    );
  }

  @override
  bool shouldRepaint(_LinePainter o) =>
      o.draw != draw || o.lit != lit || o.u != u || o.style != style;
}

/// Geometry per look (u = 1% of the height).
class _Geo {
  _Geo(this.style, this.w, this.h) : u = h / 100;

  final String style;
  final double w;
  final double h;
  final double u;

  bool get orig => style == 'orig';

  Size get card => LessonCard.sizeFor(style, u);

  /// Reference 06: card centres 751 px apart; orig: cards 8u apart.
  double get pitch => orig ? u * 52 : u * 88;

  /// Reference 06: first card centre 447 px from the rail.
  double get firstCenterFromRight => orig ? u * 30 : u * 52.4;

  double get cardCenterY => orig ? u * 52 : u * 65.7;

  /// Reference 06: title centre 745 px from the rail.
  double get titleCenterX => w - u * 87.3;

  /// Reference 06: arch 820 px wide.
  double get archW => u * 96;
}
