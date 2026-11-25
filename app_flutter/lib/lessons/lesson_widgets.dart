import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../theme/rateel_theme.dart';

// Widgets shared by the lesson screens (07 video, 08 reading, …).

/// Geometry of the «تخطي» button in u, measured on reference 07
/// (1493–1780 × 649–759 px at 854 high). Placed **bottom left** (owner,
/// 2026-11-24: in Arabic «forward» is to the left), 7.3u from the edge.
class SkipMetrics {
  SkipMetrics._();
  static const width = 33.6;
  static const height = 12.9;
  static const side = 7.3; // screen edge → rim
  static const top = 76.0;
}

/// Glyphs of the lesson pills, drawn in code (cream, or dark on gold).
enum PillGlyph { forward, check, replay, play, previous, next }

/// «تخطي ⏩» (skip) glass pill of the lesson screens, as Angular's skip
/// button: completes the lesson. On a lesson already completed it reads
/// «إكمال ✓» (Angular).
class SkipButton extends StatelessWidget {
  const SkipButton({
    super.key,
    required this.u,
    required this.onTap,
    this.completed = false,
    this.light = 0,
  });

  final double u;
  final VoidCallback onTap;
  final bool completed;
  final double light;

  @override
  Widget build(BuildContext context) => LessonPill(
    u: u,
    label: completed ? 'إكمال' : 'تخطي',
    glyph: completed ? PillGlyph.check : PillGlyph.forward,
    onTap: onTap,
    light: light,
  );
}

/// Glass pill of the lesson screens (reference 07 «تخطي»): dark green
/// glass, thin gold rim with a soft glow (conflict V2); [gold] fills it with
/// the lesson gold and dark ink (the main action, e.g. «تابع»). Press: scale
/// 0.96 + stronger glow. Height 12.9u; the width comes from the parent.
class LessonPill extends StatefulWidget {
  const LessonPill({
    super.key,
    required this.u,
    required this.label,
    required this.glyph,
    required this.onTap,
    this.gold = false,
    this.light = 0,
    this.height = SkipMetrics.height,
    this.fontSize = 4.6,
    this.leading,
    this.dim = false,
  });

  final double u;
  final String label;
  final PillGlyph? glyph;
  final VoidCallback onTap;
  final bool gold;

  /// 0 dark, 1 light (screen 08's light reading).
  final double light;

  /// Height and text size in u (07 «تخطي»: 12.9u, 4.6u).
  final double height;
  final double fontSize;

  /// Drawn before the label in RTL (right of it), instead of [glyph], e.g.
  /// the ⓘ disc of «قواعد التجويد».
  final Widget? leading;

  /// Quieter rim (olive gold, no glow): the «8 / 1» counter of screen 08.
  final bool dim;

  @override
  State<LessonPill> createState() => _LessonPillState();
}

class _LessonPillState extends State<LessonPill> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final l = widget.light;
    final ink = widget.gold
        ? RateelColors.countText
        : Color.lerp(titleCream, RateelColors.readLInk, l)!;
    final rim = widget.dim
        ? Color.lerp(RateelColors.readCounterRim, RateelColors.readLPillRim, l)!
        : Color.lerp(RateelColors.videoSkipRim, RateelColors.readLPillRim, l)!;
    final h = widget.height;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {
          Haptics.tap();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(u * h / 2),
              gradient: widget.gold
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [RateelColors.badgeTop, RateelColors.amber],
                    )
                  : RadialGradient(
                      radius: 1.4,
                      colors: [
                        Color.lerp(
                          RateelColors.videoSkipFill,
                          RateelColors.readLPillFill,
                          l,
                        )!,
                        Color.lerp(
                          RateelColors.videoSkipFillEdge,
                          RateelColors.readLPillFill,
                          l,
                        )!,
                      ],
                    ),
              border: widget.dim
                  ? null
                  : Border.all(
                      color: widget.gold ? RateelColors.goldHighlight : rim,
                      width: u * 0.28,
                    ),
              boxShadow: [
                // Gold glow (dark), soft brown shadow (light).
                if (!widget.dim)
                  BoxShadow(
                    color: RateelColors.videoSkipRim.withValues(
                      alpha: (_down ? 0.6 : 0.42) * (1 - l),
                    ),
                    blurRadius: u * 2.2,
                  ),
                if (l > 0)
                  BoxShadow(
                    color: const Color(0xFF6B4A2A).withValues(alpha: 0.22 * l),
                    blurRadius: u * 1.4,
                    offset: Offset(0, u * 0.5),
                  ),
              ],
            ),
            child: CustomPaint(
              // The dim pill (08 counter): thin olive → cream-gold rim.
              painter: widget.dim
                  ? GradientRimPainter(
                      width: u * 0.24,
                      radius: u * h / 2,
                      top: Color.lerp(
                        RateelColors.readCounterRim,
                        RateelColors.readLPillRim,
                        l,
                      )!,
                      bottom: Color.lerp(
                        RateelColors.readCounterRimBottom,
                        RateelColors.readLPillRim,
                        l,
                      )!,
                    )
                  : null,
              foregroundPainter: widget.gold || widget.dim || l >= 1
                  ? null
                  : _InnerGlowPainter(u: u, radius: u * h / 2, strength: 1 - l),
              // Long labels shrink instead of overflowing the pill.
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: u * h * 0.3),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.rtl,
                      children: [
                        // ⓘ-like marks sit before the label (right of it in RTL).
                        if (widget.leading != null) ...[
                          widget.leading!,
                          SizedBox(width: u * 1.6),
                        ],
                        Text(
                          widget.label,
                          textDirection: TextDirection.rtl,
                          style: readex(
                            u * widget.fontSize,
                            // Small toolbar pills (08) read bolder, as their
                            // reference; «تخطي» keeps 340.
                            weight: widget.gold
                                ? 520
                                : (widget.height < SkipMetrics.height
                                      ? 460
                                      : 340),
                            color: ink,
                          ).copyWith(height: 1.0),
                        ),
                        if (widget.leading == null && widget.glyph != null) ...[
                          SizedBox(width: u * 2.9),
                          SizedBox(
                            width: u * 4.1,
                            height: u * 3.0,
                            child: CustomPaint(
                              painter: PillGlyphPainter(widget.glyph!, ink),
                            ),
                          ),
                        ],
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

/// Round glass button of the lesson screens (same glass and rim as
/// [LessonPill]), e.g. «previous section».
class LessonRoundButton extends StatefulWidget {
  const LessonRoundButton({
    super.key,
    required this.u,
    required this.label,
    required this.glyph,
    required this.onTap,
    this.enabled = true,
    this.light = 0,
    this.child,
    this.plain = false,
    this.glyphSize = 4.1,
    this.compact = false,
  });

  /// Screen 08 toolbar: thin ring lit at the bottom, faint glow.
  final bool compact;

  final double u;
  final String label;
  final PillGlyph glyph;
  final VoidCallback onTap;
  final bool enabled;

  /// 0 dark, 1 light (screen 08's light reading).
  final double light;

  /// Replaces the [glyph] (screen 08: moon, «A»).
  final Widget? child;

  /// Filled green disc without the gold rim and glow (screen 08 «A»).
  final bool plain;
  final double glyphSize;

  @override
  State<LessonRoundButton> createState() => _LessonRoundButtonState();
}

class _LessonRoundButtonState extends State<LessonRoundButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final l = widget.light;
    final plain = widget.plain;
    final compact = widget.compact;
    final fill = plain
        ? [
            Color.lerp(RateelColors.readADiscTop, RateelColors.readLADisc, l)!,
            Color.lerp(RateelColors.readDiscFill, RateelColors.readLADisc, l)!,
          ]
        : [
            Color.lerp(
              RateelColors.videoSkipFill,
              RateelColors.readLDiscFill,
              l,
            )!,
            Color.lerp(
              RateelColors.videoSkipFillEdge,
              RateelColors.readLDiscFill,
              l,
            )!,
          ];
    final rim = plain
        ? Color.lerp(RateelColors.readADiscRim, RateelColors.readLADisc, l)!
        : Color.lerp(RateelColors.videoSkipRim, RateelColors.readLDiscRim, l)!;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.enabled
            ? () {
                Haptics.tap();
                widget.onTap();
              }
            : Haptics.denied,
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: _down ? 0.94 : 1,
            duration: const Duration(milliseconds: 120),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(radius: 0.8, colors: fill),
                border: compact && l < 0.5
                    ? null
                    : Border.all(color: rim, width: u * (plain ? 0.2 : 0.28)),
                boxShadow: [
                  if (!plain)
                    BoxShadow(
                      color: RateelColors.videoSkipRim.withValues(
                        alpha:
                            (_down ? 0.6 : (compact ? 0.16 : 0.42)) * (1 - l),
                      ),
                      blurRadius: u * (compact ? 1.2 : 2.2),
                    ),
                  BoxShadow(
                    color: (l > 0.5 ? const Color(0xFF6B4A2A) : Colors.black)
                        .withValues(alpha: plain || l > 0 ? 0.25 : 0),
                    blurRadius: u * 1.0,
                    offset: Offset(0, u * 0.4),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: compact && l < 0.5
                    ? GradientRimPainter(
                        width: u * 0.24,
                        radius: 9999,
                        top: RateelColors.readRingTop,
                        bottom: RateelColors.readRingBottom,
                      )
                    : null,
                foregroundPainter: plain || compact || l >= 1
                    ? null
                    : _InnerGlowPainter(
                        u: u,
                        radius: u * SkipMetrics.height / 2,
                        strength: 1 - l,
                      ),
                child: Center(
                  child:
                      widget.child ??
                      SizedBox(
                        width: u * widget.glyphSize,
                        height: u * widget.glyphSize,
                        child: CustomPaint(
                          painter: PillGlyphPainter(
                            widget.glyph,
                            Color.lerp(titleCream, RateelColors.readLInk, l)!,
                          ),
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

/// ⏪ forward in RTL (two rounded triangles pointing left: the button sits
/// bottom left, owner 2026-11-24), ✓, ↻ replay, ▶ play, › back (RTL: right).
class PillGlyphPainter extends CustomPainter {
  PillGlyphPainter(this.glyph, this.color);

  final PillGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = color;
    final round = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.12
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    Path tri(double x0, double x1) => Path()
      ..moveTo(x0, h * 0.06)
      ..lineTo(x1, h * 0.5)
      ..lineTo(x0, h * 0.94)
      ..close();
    switch (glyph) {
      case PillGlyph.forward:
        for (final x0 in [0.0, w * 0.5]) {
          final p = tri(x0 + w * 0.48, x0 + w * 0.03);
          canvas.drawPath(p, fill);
          canvas.drawPath(p, round);
        }
      case PillGlyph.play:
        final p = tri(w * 0.22, w * 0.82);
        canvas.drawPath(p, fill);
        canvas.drawPath(p, round);
      case PillGlyph.check:
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.12, h * 0.52)
            ..lineTo(w * 0.40, h * 0.86)
            ..lineTo(w * 0.88, h * 0.14),
          stroke,
        );
      case PillGlyph.replay:
        final c = Offset(w / 2, h / 2);
        final r = math.min(w, h) * 0.4;
        // Open circle from the top, counter-clockwise, arrow head at the top.
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          -math.pi / 2 + 0.5,
          2 * math.pi - 1.0,
          false,
          stroke,
        );
        final tip = Offset(c.dx + r * math.sin(0.5), c.dy - r * math.cos(0.5));
        canvas.drawPath(
          Path()
            ..moveTo(tip.dx - r * 0.55, tip.dy - r * 0.45)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(tip.dx - r * 0.6, tip.dy + r * 0.4),
          stroke,
        );
      case PillGlyph.next:
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.65, h * 0.12)
            ..lineTo(w * 0.32, h * 0.5)
            ..lineTo(w * 0.65, h * 0.88),
          stroke,
        );
      case PillGlyph.previous:
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.35, h * 0.12)
            ..lineTo(w * 0.68, h * 0.5)
            ..lineTo(w * 0.35, h * 0.88),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(PillGlyphPainter o) =>
      o.glyph != glyph || o.color != color;
}

/// Soft gold light just inside the rim (reference 07 «تخطي»: #585E28 →
/// #203D23 over ≈ 1u inside the rim).
class _InnerGlowPainter extends CustomPainter {
  _InnerGlowPainter({required this.u, required this.radius, this.strength = 1});

  final double u;
  final double radius;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.save();
    canvas.clipRRect(r);
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 1.0
        ..color = RateelColors.videoSkipRim.withValues(alpha: 0.6 * strength)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.6),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InnerGlowPainter o) =>
      o.u != u || o.radius != radius || o.strength != strength;
}

/// Ring or rounded rim with a vertical colour change (screen 08 toolbar:
/// dark olive at the top, light gold at the bottom).
class GradientRimPainter extends CustomPainter {
  GradientRimPainter({
    required this.width,
    required this.radius,
    required this.top,
    required this.bottom,
  });

  final double width;
  final double radius;
  final Color top;
  final Color bottom;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(radius, size.shortestSide / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(width / 2),
        Radius.circular(r),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(GradientRimPainter o) =>
      o.width != width ||
      o.radius != radius ||
      o.top != top ||
      o.bottom != bottom;
}
