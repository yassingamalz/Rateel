import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../theme/rateel_theme.dart';

// Widgets shared by the lesson screens (07 video, 08 reading, …).

/// Geometry of the «تخطي» button in u, measured on reference 07
/// (1493–1780 × 649–759 px at 854 high): bottom right of every lesson.
class SkipMetrics {
  SkipMetrics._();
  static const width = 33.6;
  static const height = 12.9;
  static const right = 7.3; // screen edge → rim
  static const top = 76.0;
}

/// «تخطي ⏩» (skip) glass pill of the lesson screens, as Angular's skip
/// button: completes the lesson. On a lesson already completed it reads
/// «إكمال ✓» (Angular). Dark green glass, thin gold rim with a soft glow
/// (reference 07, conflict V2), press: scale 0.96 + light.
class SkipButton extends StatefulWidget {
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
  State<SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<SkipButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    return Semantics(
      button: true,
      label: widget.completed ? 'إكمال' : 'تخطي',
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
              gradient: const RadialGradient(
                radius: 1.4,
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
                    alpha: _down ? 0.35 : 0.16,
                  ),
                  blurRadius: u * 1.8,
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    widget.completed ? 'إكمال' : 'تخطي',
                    textDirection: TextDirection.rtl,
                    style: readex(
                      u * 4.6,
                      weight: 340,
                      color: titleCream,
                    ).copyWith(height: 1.0),
                  ),
                  SizedBox(width: u * 2.9),
                  SizedBox(
                    width: u * 4.1,
                    height: u * 3.0,
                    child: CustomPaint(
                      painter: _SkipGlyphPainter(check: widget.completed),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ⏩ (two rounded triangles pointing right, as the reference and Angular's
/// fa-forward) or ✓.
class _SkipGlyphPainter extends CustomPainter {
  _SkipGlyphPainter({required this.check});

  final bool check;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (check) {
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.12, h * 0.52)
          ..lineTo(w * 0.40, h * 0.86)
          ..lineTo(w * 0.88, h * 0.14),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = h * 0.18
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = titleCream,
      );
      return;
    }
    final fill = Paint()..color = titleCream;
    final round = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.12
      ..strokeJoin = StrokeJoin.round
      ..color = titleCream;
    for (final x0 in [0.0, w * 0.5]) {
      final tri = Path()
        ..moveTo(x0 + w * 0.03, h * 0.06)
        ..lineTo(x0 + w * 0.48, h * 0.5)
        ..lineTo(x0 + w * 0.03, h * 0.94)
        ..close();
      canvas.drawPath(tri, fill);
      canvas.drawPath(tri, round);
    }
  }

  @override
  bool shouldRepaint(_SkipGlyphPainter o) => o.check != check;
}
