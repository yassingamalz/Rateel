import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind, lerpDouble;

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/rateel_theme.dart';
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

  /// Slow breathing glow on the active card's gold rim.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

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

  PageController? _pages;
  double _pageFraction = 0;

  @override
  void dispose() {
    _entry.dispose();
    _breath.dispose();
    _shake.dispose();
    _toast.dispose();
    _pages?.dispose();
    super.dispose();
  }

  PageController _controllerFor(double fraction) {
    if (_pages == null || (fraction - _pageFraction).abs() > 0.001) {
      final page = _pages?.hasClients == true ? _pages!.page ?? 0 : 0.0;
      _pages?.dispose();
      _pageFraction = fraction;
      _pages = PageController(
        viewportFraction: fraction,
        initialPage: page.round(),
      );
    }
    return _pages!;
  }

  Future<void> _showToast(String text) async {
    setState(() => _toastText = text);
    await _toast.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (mounted && _toastText == text) await _toast.reverse();
  }

  void _tapCourse(int i) {
    final course = courses[i];
    if (course.locked) {
      HapticFeedback.lightImpact();
      setState(() => _shaking = i);
      _shake.forward(from: 0);
      final previous = courses[i - 1].title;
      _showToast('أكمل «$previous» أولًا لفتح هذه الدورة');
    } else {
      HapticFeedback.selectionClick();
      // The units screen (05) is not built yet.
      _showToast('الوحدات: قريبًا');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final g = _Geo(box.maxWidth, box.maxHeight);
        final pages = _controllerFor(g.pitch / g.w);
        return Stack(
          fit: StackFit.expand,
          children: [
            const _Background(),
            ..._header(g),
            Positioned(
              left: 0,
              right: g.trackRightInset,
              top: g.cardCenterY - g.trackHalfHeight,
              height: g.trackHalfHeight * 2,
              child: AnimatedBuilder(
                animation: Listenable.merge([_entry, _breath, _shake, pages]),
                // Mouse drag too (web review captures, desktop).
                builder: (context, _) => ScrollConfiguration(
                  behavior: const _DragEverywhere(),
                  child: PageView.builder(
                    controller: pages,
                    padEnds: false,
                    clipBehavior: Clip.none,
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
        : 0.0;
    final focus = (1 - (page - i).abs()).clamp(0.0, 1.0);
    final e = _entry.value;
    final appear = Curves.easeOutCubic.transform(
      _interval(e, 0.15 + 0.08 * i.clamp(0, 4), 0.55 + 0.08 * i.clamp(0, 4)),
    );
    final line = Curves.easeInOutCubic.transform(_interval(e, 0.55, 0.9));
    final shake = _shaking == i
        ? math.sin(_shake.value * math.pi * 5) * (1 - _shake.value)
        : 0.0;
    return Opacity(
      opacity: appear,
      child: Transform.translate(
        offset: Offset(-g.u * 10 * (1 - appear), 0),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (i < courses.length - 1) _connector(g, line),
            Transform.scale(
              scale: lerpDouble(1.0, g.focusScale, focus)!,
              child: SizedBox(
                width: g.cardW,
                height: g.cardH,
                child: CourseCard(
                  course: courses[i],
                  u: g.u,
                  breath: Curves.easeInOutSine.transform(_breath.value),
                  progress:
                      courses[i].progress *
                      Curves.easeOutCubic.transform(_interval(e, 0.6, 1)),
                  lockShake: shake,
                  onTap: () => _tapCourse(i),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gold line from this card's left edge to the next card, with a glowing
  /// node just outside the card (reference: y = card centre + 2.7u).
  Widget _connector(_Geo g, double draw) {
    final gap = g.pitch - g.cardW;
    final y = g.trackHalfHeight + g.u * 2.7;
    final left = g.pitch / 2 - g.cardW / 2 - gap;
    final full = gap;
    final nodeX = g.u * 2.4;
    return Positioned(
      left: left,
      top: y - g.u * 2,
      width: full,
      height: g.u * 4,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ConnectorPainter(u: g.u, draw: draw, nodeFromRight: nodeX),
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
      // Lattice corners (shared library), faint as in the reference.
      Positioned(
        left: -g.u * 1,
        top: -g.u * 1,
        width: g.u * 26,
        child: IgnorePointer(
          child: Opacity(
            opacity: 0.32,
            child: Image.asset('assets/images/lattice-corner-left.webp'),
          ),
        ),
      ),
      Positioned(
        right: g.u * 1,
        top: -g.u * 2,
        width: g.u * 19,
        child: IgnorePointer(
          child: Opacity(
            opacity: 0.32,
            child: Image.asset('assets/images/lattice-corner-right.webp'),
          ),
        ),
      ),
      // Header arch. PLACEHOLDER: the side-nav arch (shared library) until
      // the owner delivers the wide header arch (prompt P1).
      Positioned(
        left: cx - g.u * 51.4,
        top: g.u * 0.2,
        width: g.u * 102.8,
        height: g.u * 102.8 * 222 / 720,
        child: settle(
          IgnorePointer(
            child: Opacity(
              opacity: 0.85,
              child: SvgPicture.asset(
                'assets/ui/decor/arch.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
      // Open-book emblem on the arch apex: the outline Quran icon of the nav.
      Positioned(
        left: cx - g.u * 7.85,
        top: g.u * 11.0 - g.u * 7.85,
        width: g.u * 15.7,
        height: g.u * 15.7,
        child: settle(
          IgnorePointer(
            child: SvgPicture.asset(
              'assets/ui/nav/quran.svg',
              theme: const SvgTheme(currentColor: RateelColors.gold),
            ),
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: g.w - 2 * cx,
        top: g.u * 23.4 - g.u * 7,
        height: g.u * 14,
        child: settle(
          Center(
            child: Text(
              'المسارات التعليمية',
              textDirection: TextDirection.rtl,
              style: readex(
                g.u * 9.15,
                weight: 600,
                color: RateelColors.label,
              ).copyWith(height: 1),
            ),
          ),
        ),
      ),
      Positioned(
        left: cx - g.u * 28,
        top: g.u * 31.4 - g.u * 1.2,
        width: g.u * 56,
        height: g.u * 2.4,
        child: settle(
          IgnorePointer(
            child: CustomPaint(painter: _DividerPainter(u: g.u)),
          ),
        ),
      ),
    ];
  }

  Widget _toastLayer(_Geo g) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: g.u * 4,
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
                      border: Border.all(color: RateelColors.cardRim, width: 2),
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
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.5),
          radius: 1.1,
          colors: [RateelColors.contentTop, RateelColors.contentBottom],
        ),
      ),
    );
  }
}

/// Thin gold divider under the title: two lines fading outward, a small bar
/// next to each, and an outlined diamond in the middle.
class _DividerPainter extends CustomPainter {
  _DividerPainter({required this.u});

  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final diamond = u * 1.0;
    final gap = u * 2.6;
    final line = Paint()..strokeWidth = 2;
    for (final s in [-1.0, 1.0]) {
      final inner = c.dx + s * gap;
      final outer = s < 0 ? 0.0 : size.width;
      line.shader = LinearGradient(
        colors: [RateelColors.gold, RateelColors.gold.withValues(alpha: 0)],
      ).createShader(Rect.fromPoints(Offset(inner, 0), Offset(outer, 1)));
      canvas.drawLine(Offset(inner, c.dy), Offset(outer, c.dy), line);
      // Short bar between the line and the diamond.
      canvas.drawCircle(
        Offset(c.dx + s * (gap - u * 0.2), c.dy),
        u * 0.28,
        Paint()..color = RateelColors.gold,
      );
    }
    final path = Path()
      ..moveTo(c.dx, c.dy - diamond)
      ..lineTo(c.dx + diamond, c.dy)
      ..lineTo(c.dx, c.dy + diamond)
      ..lineTo(c.dx - diamond, c.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = RateelColors.gold,
    );
  }

  @override
  bool shouldRepaint(_DividerPainter old) => old.u != u;
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.u,
    required this.draw,
    required this.nodeFromRight,
  });

  final double u;
  final double draw;
  final double nodeFromRight;

  @override
  void paint(Canvas canvas, Size size) {
    if (draw == 0) return;
    final y = size.height / 2;
    final right = size.width;
    final left = right - size.width * draw;
    canvas.drawLine(
      Offset(left, y),
      Offset(right, y),
      Paint()
        ..color = RateelColors.pathLine
        ..strokeWidth = 3,
    );
    final node = Offset(right - nodeFromRight, y);
    final lit = ((draw - 0.1) / 0.3).clamp(0.0, 1.0);
    if (lit == 0) return;
    canvas.drawCircle(
      node,
      u * 2.2,
      Paint()
        ..color = RateelColors.gold.withValues(alpha: 0.30 * lit)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.2),
    );
    canvas.drawCircle(
      node,
      u * 1.3 * lit,
      Paint()..color = RateelColors.progressFill,
    );
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) => old.draw != draw || old.u != u;
}

/// Reference geometry (u = 1% of the height). Ref px / 8.51.
class _Geo {
  _Geo(this.w, this.h) : u = h / 100;

  final double w;
  final double h;
  final double u;

  double get cardW => u * 72.4;
  double get cardH => u * 50.0;

  /// The focused (first) card is 626 px wide against 616 px for the others.
  double get focusScale => 1.016;

  /// Card centre to card centre: 704 px.
  double get pitch => u * 82.7;

  /// First card centre: 373 px from the content's right edge.
  double get firstCenterFromRight => u * 43.8;

  /// PageView pages are [pitch] wide and start at the right edge; this inset
  /// moves the first card centre to [firstCenterFromRight].
  double get trackRightInset => firstCenterFromRight - pitch / 2;
  double get cardCenterY => u * 63.8;
  double get trackHalfHeight => u * 30;

  /// Arch apex / title centre: 810 px from the content's right edge.
  double get headerCenterX => w - u * 95.2;
}
