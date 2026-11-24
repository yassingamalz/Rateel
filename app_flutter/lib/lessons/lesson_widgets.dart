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
enum PillGlyph { forward, check, replay, play, previous }

/// «تخطي ⏩» (skip) glass pill of the lesson screens, as Angular's skip
/// button: completes the lesson. On a lesson already completed it reads
/// «إكمال ✓» (Angular).
class SkipButton extends StatelessWidget {
  const SkipButton({
    super.key,
    required this.u,
    required this.onTap,
    this.completed = false,
  });

  final double u;
  final VoidCallback onTap;
  final bool completed;

  @override
  Widget build(BuildContext context) => LessonPill(
    u: u,
    label: completed ? 'إكمال' : 'تخطي',
    glyph: completed ? PillGlyph.check : PillGlyph.forward,
    onTap: onTap,
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
  });

  final double u;
  final String label;
  final PillGlyph? glyph;
  final VoidCallback onTap;
  final bool gold;

  @override
  State<LessonPill> createState() => _LessonPillState();
}

class _LessonPillState extends State<LessonPill> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final ink = widget.gold ? RateelColors.countText : titleCream;
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
              borderRadius: BorderRadius.circular(u * SkipMetrics.height / 2),
              gradient: widget.gold
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [RateelColors.badgeTop, RateelColors.amber],
                    )
                  : const RadialGradient(
                      radius: 1.4,
                      colors: [
                        RateelColors.videoSkipFill,
                        RateelColors.videoSkipFillEdge,
                      ],
                    ),
              border: Border.all(
                color: widget.gold
                    ? RateelColors.goldHighlight
                    : RateelColors.videoSkipRim,
                width: u * 0.28,
              ),
              boxShadow: [
                BoxShadow(
                  color: RateelColors.videoSkipRim.withValues(
                    alpha: _down ? 0.6 : 0.42,
                  ),
                  blurRadius: u * 2.2,
                ),
              ],
            ),
            child: CustomPaint(
              foregroundPainter: widget.gold
                  ? null
                  : _InnerGlowPainter(u: u, radius: u * SkipMetrics.height / 2),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      widget.label,
                      textDirection: TextDirection.rtl,
                      style: readex(
                        u * 4.6,
                        weight: widget.gold ? 520 : 340,
                        color: ink,
                      ).copyWith(height: 1.0),
                    ),
                    if (widget.glyph != null) ...[
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
  });

  final double u;
  final String label;
  final PillGlyph glyph;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<LessonRoundButton> createState() => _LessonRoundButtonState();
}

class _LessonRoundButtonState extends State<LessonRoundButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
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
                gradient: const RadialGradient(
                  radius: 0.8,
                  colors: [
                    RateelColors.videoSkipFill,
                    RateelColors.videoSkipFillEdge,
                  ],
                ),
                border: Border.all(
                  color: RateelColors.videoSkipRim,
                  width: u * 0.28,
                ),
                boxShadow: [
                  BoxShadow(
                    color: RateelColors.videoSkipRim.withValues(
                      alpha: _down ? 0.6 : 0.42,
                    ),
                    blurRadius: u * 2.2,
                  ),
                ],
              ),
              child: CustomPaint(
                foregroundPainter: _InnerGlowPainter(
                  u: u,
                  radius: u * SkipMetrics.height / 2,
                ),
                child: Center(
                  child: SizedBox(
                    width: u * 4.1,
                    height: u * 4.1,
                    child: CustomPaint(
                      painter: PillGlyphPainter(widget.glyph, titleCream),
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
  _InnerGlowPainter({required this.u, required this.radius});

  final double u;
  final double radius;

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
        ..color = RateelColors.videoSkipRim.withValues(alpha: 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.6),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InnerGlowPainter o) => o.u != u || o.radius != radius;
}
