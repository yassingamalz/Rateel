import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../theme/rateel_theme.dart';
import 'lesson_data.dart';

/// One lesson card of screen 06: the original Angular card, improved (owner's
/// choice B, 2026-11-23). Geometry in u (the screen passes u × 1.4, owner's
/// scale).
///
/// States: locked (dark veil + green padlock, as approved on screen 05),
/// open (the lesson in progress: gold), done (✓ pill, dim gold rim).
/// [unlock] goes 0 → 1 while the card opens (padlock flies off, veil lifts),
/// [done] 0 → 1 when the lesson is finished, [border] 0 → 1 is the light
/// running around the rim (Angular border fill), [flash] the burst at the end.
class LessonCard extends StatefulWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    required this.u,
    required this.step,
    required this.total,
    required this.unlock,
    required this.done,
    required this.active,
    required this.border,
    required this.flash,
    required this.ambient,
    required this.lockShake,
    required this.onTap,
    this.onLongPress,
  });

  final Lesson lesson;
  final double u;
  final int step;
  final int total;
  final double unlock;
  final double done;
  final bool active;
  final double border;
  final double flash;

  /// 0..1 repeating (4 s): breathing glow of the lesson in progress. Passed
  /// as an animation so that only that glow follows it (PERFORMANCE.md).
  final Animation<double> ambient;
  final double lockShake;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  static Size sizeFor(double u) => Size(u * 44, u * 31);

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard>
    with SingleTickerProviderStateMixin {
  bool _down = false;
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  double get _locked => 1 - _seg(widget.unlock, 0.3, 0.8);

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final size = LessonCard.sizeFor(u);
    final radius = u * 3.2;
    final card = SizedBox.fromSize(
      size: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: _glow(radius)),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: _lockedLook(
                Stack(
                  fit: StackFit.expand,
                  children: [_body(), ..._content(size), _shineLayer(size)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _RimPainter(
                  u: u,
                  radius: radius,
                  open: widget.unlock,
                  active: widget.active ? 1 - widget.done : 0,
                  done: widget.done,
                  border: widget.border,
                ),
              ),
            ),
          ),
          if (widget.unlock < 1) _padlock(size),
          if (widget.flash > 0)
            Positioned(
              left: -u * 8,
              top: -u * 8,
              right: -u * 8,
              bottom: -u * 8,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SparklePainter(u: u, t: widget.flash),
                ),
              ),
            ),
        ],
      ),
    );
    return GestureDetector(
      onTapDown: (_) {
        if (_locked == 0) Haptics.tap();
        setState(() => _down = true);
      },
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        if (_locked == 0) _shine.forward(from: 0);
        widget.onTap();
      },
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: card,
      ),
    );
  }

  /// Outer gold glow: breathing on the lesson in progress (as the active
  /// course card), a burst on the completion flash.
  Widget _glow(double radius) {
    final open = widget.active
        ? (1 - widget.done) * _seg(widget.unlock, 0.45, 1)
        : 0.0;
    // Only the lesson in progress breathes: only its glow follows the 4 s
    // loop, in its own layer (PERFORMANCE.md).
    if (open <= 0) return _glowBox(radius, open, 0);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: widget.ambient,
        builder: (context, _) => _glowBox(
          radius,
          open,
          0.5 - 0.5 * math.cos(widget.ambient.value * math.pi * 2),
        ),
      ),
    );
  }

  Widget _glowBox(double radius, double open, double breath) {
    final u = widget.u;
    final glow =
        open * (0.22 + 0.12 * breath) + 0.6 * math.sin(math.pi * widget.flash);
    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: u * 2.2,
      offset: Offset(0, u * 0.6),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          shadow,
          if (glow > 0)
            BoxShadow(
              color: RateelColors.gold.withValues(alpha: glow.clamp(0.0, 1.0)),
              blurRadius: u * 2.4,
              spreadRadius: u * 0.1,
            ),
        ],
      ),
    );
  }

  Widget _body() {
    // Original look: glass card; the lesson in progress is filled gold
    // (Angular `--active`), a done lesson keeps a 15% gold tint.
    final gold = _goldFill;
    final tint = 0.15 * widget.done;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(RateelColors.origGlass, RateelColors.gold, tint)!,
                Color.lerp(RateelColors.cardMid, RateelColors.gold, tint)!,
              ],
            ),
          ),
        ),
        if (gold > 0)
          Opacity(
            opacity: gold,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    RateelColors.origGoldTop,
                    RateelColors.origGoldBottom,
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Gold fill of the original look's lesson in progress: it comes in while
  /// the card unlocks and leaves only once the ✓ is in (critic v1 B1, B2).
  double get _goldFill => widget.active
      ? (1 - _seg(widget.done, 0.7, 0.95)) * _seg(widget.unlock, 0.55, 0.85)
      : 0.0;

  /// Text colour: dark on the filled gold card of the original look. The
  /// ink snaps at the middle of the fill instead of lerping (critic v1 B1).
  Color _ink(Color normal) {
    if (!widget.active) return normal;
    return _goldFill > 0.5 ? RateelColors.origCardText : normal;
  }

  List<Widget> _content(Size size) {
    final u = widget.u;
    final l = widget.lesson;
    return [
      Positioned(right: u * 1.6, top: u * 1.5, child: _pill(u * 8, u * 4.2)),
      Positioned(
        right: u * 3,
        left: u * 3,
        top: u * 7.2,
        // Long titles shrink to fit instead of being cut (seen at ×1.4).
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            l.title,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            style: readex(u * 3.4, weight: 600, color: _ink(titleCream)),
          ),
        ),
      ),
      Positioned(
        right: u * 3,
        left: u * 3,
        top: u * 12.4,
        child: Text(
          l.description,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: readex(
            u * 2.3,
            weight: 380,
            color: _ink(RateelColors.cream),
          ).copyWith(height: 1.55),
        ),
      ),
      if (l.minutes > 0)
        Positioned(
          right: u * 3,
          bottom: u * 2.4,
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              CustomPaint(
                size: Size.square(u * 2.4),
                painter: _ClockPainter(
                  _ink(RateelColors.cream.withValues(alpha: 0.75)),
                ),
              ),
              SizedBox(width: u * 0.9),
              Text(
                '${l.minutes} دقيقة',
                textDirection: TextDirection.rtl,
                style: readex(
                  u * 2.2,
                  weight: 400,
                  color: _ink(RateelColors.cream.withValues(alpha: 0.75)),
                ).copyWith(height: 1),
              ),
            ],
          ),
        ),
      // Improvement on the Angular card: the lesson-type icon.
      Positioned(
        left: u * 2.6,
        bottom: u * 1.8,
        width: u * 9,
        height: u * 5,
        child: _icon(),
      ),
    ];
  }

  Widget _pill(double w, double h) {
    final u = widget.u;
    final d = widget.done;
    final onGold = widget.active && d < 1;
    final pop = d > 0 && d < 1 ? 1 + 0.35 * math.sin(math.pi * d) : 1.0;
    final text = Text(
      '${widget.step}/${widget.total}',
      textDirection: TextDirection.ltr,
      style: readex(
        h * 0.55,
        weight: 600,
        color: onGold ? RateelColors.gold : RateelColors.badgeText,
      ).copyWith(height: 1),
    );
    final check = SvgPicture.asset(
      'assets/ui/glyphs/check.svg',
      width: h * 0.6,
      height: h * 0.6,
      theme: SvgTheme(
        currentColor: onGold ? RateelColors.gold : RateelColors.badgeText,
      ),
    );
    return Transform.scale(
      scale: pop,
      child: Container(
        width: w,
        height: h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h / 2),
          gradient: onGold
              ? const LinearGradient(
                  colors: [RateelColors.pillFill, RateelColors.pillFill],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [RateelColors.badgeTop, RateelColors.badge],
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: u * 0.8,
              offset: Offset(0, u * 0.25),
            ),
          ],
        ),
        child: Padding(
          // Readex sets Arabic and digits low in the box (lesson learned).
          padding: EdgeInsets.only(bottom: h * 0.06),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: 1 - _seg(d, 0.3, 0.45), child: text),
              Opacity(opacity: _seg(d, 0.33, 0.48), child: check),
            ],
          ),
        ),
      ),
    );
  }

  /// Lesson-type icon (owner's L1–L5, 2026-11-23: gold line art), its own
  /// gold; muted green while locked, dark on the gold card.
  Widget _icon() {
    final asset = 'assets/ui/lessons/${widget.lesson.type.name}.webp';
    // Dark on the gold fill, switching with the text ink (critic v2 B7).
    final onGold = _goldFill > 0.5;
    final image = Image.asset(asset, fit: BoxFit.contain);
    if (!onGold && widget.unlock >= 1) return image;
    final lit = _seg(widget.unlock, 0.45, 1);
    final top = onGold
        ? RateelColors.origCardText
        : Color.lerp(
            RateelColors.lessonIconMuted,
            RateelColors.lessonIconTop,
            lit,
          )!;
    final bottom = onGold
        ? RateelColors.origCardText
        : Color.lerp(
            RateelColors.lessonIconMuted,
            RateelColors.lessonIconBottom,
            lit,
          )!;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      ).createShader(r),
      child: image,
    );
  }

  Widget _shineLayer(Size size) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _shine,
        builder: (context, _) {
          final t = _shine.value;
          if (t == 0 || t == 1) return const SizedBox.shrink();
          return Transform.translate(
            offset: Offset(size.width * (1.4 - 2.8 * t), 0),
            child: Transform.rotate(
              angle: 0.35,
              child: Center(
                child: Container(
                  width: widget.u * 8,
                  height: size.height * 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.16),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Dark veil on locked cards (owner's choice B on screen 05), lifting
  /// while the padlock flies off.
  Widget _lockedLook(Widget child) {
    final l = _locked;
    if (l == 0) return child;
    final k = 1 - 0.45 * l;
    return ColorFiltered(
      colorFilter: ColorFilter.matrix([
        k, 0, 0, 0, 0, //
        0, k, 0, 0, 0, //
        0, 0, k, 0, 0, //
        0, 0, 0, 1, 0, //
      ]),
      child: child,
    );
  }

  /// Green padlock (screen 05) in the centre of the card (owner,
  /// 2026-11-23); it shakes on a tap and flies off when the lesson opens.
  Widget _padlock(Size size) {
    final u = widget.u;
    final t = _seg(widget.unlock, 0, 0.45);
    final pop = 1 + 0.35 * math.sin(math.pi * (t * 1.3).clamp(0.0, 1.0));
    final onIcon = lessonLockPos == 'icon';
    final s = onIcon ? u * 6 : u * 6.4;
    // On the lesson-type icon (as on screen 05) or in the card centre on a
    // dark glass disc (owner's choice pending, 2026-11-23).
    final c = onIcon
        ? Offset(u * 2.6 + u * 4.5, size.height - u * 1.8 - u * 2.5)
        : size.center(Offset.zero);
    return Positioned(
      left: c.dx - s / 2 + widget.lockShake * u * 0.9,
      top: c.dy - s / 2 - u * 5 * t,
      width: s,
      height: s,
      child: IgnorePointer(
        child: Opacity(
          opacity: 1 - _seg(t, 0.5, 1),
          child: Transform.rotate(
            angle: widget.lockShake * 0.18 - t * 0.6,
            child: Transform.scale(
              scale: pop,
              child: onIcon
                  ? SvgPicture.asset(
                      'assets/ui/units/padlock_$lessonLockColor.svg',
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: RateelColors.pillFill.withValues(alpha: 0.92),
                        border: Border.all(
                          color: RateelColors.rowRim,
                          width: u * 0.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: u * 1.2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(s * 0.2),
                        child: SvgPicture.asset(
                          'assets/ui/units/padlock_$lessonLockColor.svg',
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

double _seg(double t, double a, double b) =>
    ((t - a) / (b - a)).clamp(0.0, 1.0);

/// Card rim: muted green while waiting, gold on the lesson in progress, dim
/// gold when done; [border] draws the light that runs around the rim on the
/// completion (Angular border fill: top, right, bottom, left).
class _RimPainter extends CustomPainter {
  _RimPainter({
    required this.u,
    required this.radius,
    required this.open,
    required this.active,
    required this.done,
    required this.border,
  });

  final double u;
  final double radius;
  final double open;
  final double active;
  final double done;
  final double border;

  @override
  void paint(Canvas canvas, Size size) {
    final w = u * 0.28;
    final rect = (Offset.zero & size).deflate(w / 2);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(radius - w / 2),
    );
    final lit = active * _seg(open, 0.45, 1);
    // Glass rim (Angular: white 10%), dim gold once done.
    final base = Color.lerp(
      Colors.white.withValues(alpha: 0.10),
      RateelColors.cardRimGold.withValues(alpha: 0.75),
      done,
    )!;
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..color = base,
    );
    if (lit > 0) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.55 * lit),
            Colors.white.withValues(alpha: 0.25 * lit),
          ],
        ).createShader(rect);
      canvas.drawRRect(rrect, paint);
    }
    if (border <= 0 || border >= 1.0 && done >= 1) return;
    // Light running around the rim, starting at the top centre, clockwise.
    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final len = metric.length;
    final start = len * _topCentreOffset(rrect, len);
    final run = len * border;
    final seg = Path();
    void add(double a, double b) =>
        seg.addPath(metric.extractPath(a, b), Offset.zero);
    if (start + run <= len) {
      add(start, start + run);
    } else {
      add(start, len);
      add(0, start + run - len);
    }
    canvas.drawPath(
      seg,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 3
        ..color = RateelColors.gold.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.8),
    );
    canvas.drawPath(
      seg,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 1.2
        ..strokeCap = StrokeCap.round
        ..color = RateelColors.goldHighlight,
    );
    if (border < 1) {
      final head = metric.getTangentForOffset((start + run) % len)!.position;
      canvas.drawCircle(
        head,
        u * 2,
        Paint()
          ..color = RateelColors.goldHighlight.withValues(alpha: 0.75)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.2),
      );
      canvas.drawCircle(head, u * 0.55, Paint()..color = RateelColors.label);
    }
  }

  /// Offset (0–1) of the top centre on the RRect path, which starts on the
  /// left edge below the top-left corner.
  double _topCentreOffset(RRect r, double len) {
    final arc = math.pi / 2 * r.tlRadiusX;
    final side = r.height - r.tlRadiusY * 2;
    final top = r.width / 2 - r.tlRadiusX;
    return ((side + arc + top) / len) % 1;
  }

  @override
  bool shouldRepaint(_RimPainter o) =>
      o.open != open ||
      o.active != active ||
      o.done != done ||
      o.border != border ||
      o.u != u;
}

/// Gold sparkles bursting out around the card on the completion flash.
class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.u, required this.t});

  final double u;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rx = size.width / 2 - u * 6;
    final ry = size.height / 2 - u * 6;
    final rnd = math.Random(7);
    final fade = 1 - _seg(t, 0.55, 1);
    for (var i = 0; i < 16; i++) {
      final a = i / 16 * math.pi * 2 + rnd.nextDouble() * 0.3;
      final d =
          1 + 0.18 * Curves.easeOutCubic.transform(t) + rnd.nextDouble() * 0.06;
      final p = c + Offset(math.cos(a) * rx * d, math.sin(a) * ry * d);
      final s =
          u *
          (0.5 + rnd.nextDouble() * 0.9) *
          math.sin(math.pi * t.clamp(0, 1));
      if (s <= 0) continue;
      final star = Path()
        ..moveTo(p.dx, p.dy - s * 2)
        ..quadraticBezierTo(p.dx, p.dy, p.dx + s * 2, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + s * 2)
        ..quadraticBezierTo(p.dx, p.dy, p.dx - s * 2, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - s * 2)
        ..close();
      canvas.drawPath(
        star,
        Paint()..color = RateelColors.goldHighlight.withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(_SparklePainter o) => o.t != t || o.u != u;
}

/// Small clock before the duration (Angular «⏱»).
class _ClockPainter extends CustomPainter {
  _ClockPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.18
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawCircle(c, r * 0.85, p);
    canvas.drawLine(c, c + Offset(0, -r * 0.5), p);
    canvas.drawLine(c, c + Offset(r * 0.38, 0), p);
  }

  @override
  bool shouldRepaint(_ClockPainter o) => o.color != color;
}
