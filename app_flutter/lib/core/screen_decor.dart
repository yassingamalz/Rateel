import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/rateel_theme.dart';

// Background layers shared by the learning screens (05 units, 06 lessons).

/// Faint girih lattice over the whole content (owner's U6, seamless tile,
/// tinted `girihLine`).
class ScreenGirih extends StatelessWidget {
  const ScreenGirih({super.key, this.fadeTop = true, this.opacity = 0.11});

  /// Screens 05/06 keep the header clean (fade from 20u to 38u); the lesson
  /// screens (07) show the lattice everywhere, as their reference.
  final bool fadeTop;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    // Static pattern: its own layer (PERFORMANCE.md).
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, box) {
          final tile = box.maxHeight * 0.95;
          final cols = (box.maxWidth / tile).ceil();
          final rows = (box.maxHeight / tile).ceil();
          // The header stays clean: the pattern fades in from 20u to 38u.
          return ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.20, 0.38],
              colors: [
                Color(fadeTop ? 0x00000000 : 0xFF000000),
                const Color(0xFF000000),
              ],
            ).createShader(r),
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxWidth: cols * tile,
                maxHeight: rows * tile,
                child: Opacity(
                  opacity: opacity,
                  child: Column(
                    children: [
                      for (var r = 0; r < rows; r++)
                        Row(
                          children: [
                            for (var c = 0; c < cols; c++)
                              SvgPicture.asset(
                                'assets/ui/decor/girih_tile.svg',
                                width: tile,
                                height: tile,
                                theme: const SvgTheme(
                                  currentColor: RateelColors.girihLine,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Owner's corner lattice, tinted to the reference's saturated gold with a
/// soft relief shadow (critic v2).
class GoldCorner extends StatelessWidget {
  const GoldCorner(this.asset, {super.key, required this.u});

  final String asset;
  final double u;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, fit: BoxFit.contain);
    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.translate(
          offset: Offset(u * 0.15, u * 0.25),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color(0x73000000),
              BlendMode.srcIn,
            ),
            child: image,
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [RateelColors.unitCornerTop, RateelColors.unitCornerBottom],
          ).createShader(r),
          child: image,
        ),
      ],
    );
  }
}

/// Same background as screen 03 (one style).
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // Static: its own layer, never repainted with the content above.
    return const RepaintBoundary(
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.85, 1],
            colors: [Color(0x00002D23), RateelColors.contentLift],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1.0),
              radius: 1.2,
              colors: [RateelColors.contentTop, RateelColors.contentBottom],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gold title divider drawn in code: two lines fading out towards the ends,
/// pointed next to an open diamond in the middle (reference 07). Size: the
/// box of the whole divider; the line is 0.35u thick, the diamond 3.6u wide.
class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key, required this.u, this.diamond = 1.8});

  final double u;

  /// Half diagonal of the diamond in u (07: 1.8u, 08: 1.5u).
  final double diamond;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GoldDividerPainter(u, diamond));
}

class _GoldDividerPainter extends CustomPainter {
  _GoldDividerPainter(this.u, this.diamond);

  final double u;
  final double diamond;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final half = size.width / 2;
    final d = u * diamond; // half diagonal of the diamond
    final gap = u * 0.7; // diamond → pointed line end
    final t = u * 0.35; // line thickness
    for (final side in [-1.0, 1.0]) {
      final inner = c.dx + side * (d + gap);
      final outer = c.dx + side * half;
      // From the diamond outwards on both sides.
      final shader = LinearGradient(
        begin: side < 0 ? Alignment.centerRight : Alignment.centerLeft,
        end: side < 0 ? Alignment.centerLeft : Alignment.centerRight,
        // Measured on reference 07 (fraction of the half line from the
        // diamond): peak to 0.14, then 0.29 #D9A43B, 0.44 #B59135,
        // 0.59 ≈ 55%, 0.73 ≈ 35%, gone at the end.
        colors: const [
          RateelColors.videoDivider,
          RateelColors.videoDivider,
          Color(0xFFD9A43B),
          RateelColors.videoDividerEnd,
          Color(0x8CB59135),
          Color(0x59B59135),
          Color(0x00B59135),
        ],
        stops: const [0, 0.18, 0.33, 0.48, 0.62, 0.76, 1],
      ).createShader(Rect.fromPoints(Offset(inner, 0), Offset(outer, 1)));
      final paint = Paint()..shader = shader;
      // Line, with a spindle (wider, pointed) at the end next to the diamond.
      final p = Path()
        ..moveTo(inner, c.dy)
        ..lineTo(inner + side * u * 1.0, c.dy - t * 1.6)
        ..lineTo(inner + side * u * 1.9, c.dy - t / 2)
        ..lineTo(outer, c.dy - t * 0.3)
        ..lineTo(outer, c.dy + t * 0.3)
        ..lineTo(inner + side * u * 1.9, c.dy + t / 2)
        ..lineTo(inner + side * u * 1.0, c.dy + t * 1.6)
        ..close();
      canvas.drawPath(p, paint);
    }
    final rhombus = Path()
      ..moveTo(c.dx, c.dy - d)
      ..lineTo(c.dx + d, c.dy)
      ..lineTo(c.dx, c.dy + d)
      ..lineTo(c.dx - d, c.dy)
      ..close();
    canvas.drawPath(
      rhombus,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.45
        ..strokeJoin = StrokeJoin.miter
        ..color = RateelColors.videoDivider,
    );
  }

  @override
  bool shouldRepaint(_GoldDividerPainter o) => o.u != u || o.diamond != diamond;
}
