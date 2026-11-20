import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/rateel_theme.dart';
import 'course_data.dart';

/// One course card of the path (reference 03). Sizes in u (1% of the screen
/// height), measured on the reference card (616×426 px base, u = 8.51 px).
class CourseCard extends StatefulWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.u,
    required this.unlock,
    required this.breath,
    required this.progress,
    required this.lockShake,
    required this.onTap,
    this.onLongPress,
  });

  final Course course;
  final double u;

  /// 0 = locked, 1 = unlocked (gold rim, level pill, play and progress). In
  /// between during the unlock of the completion sequence.
  final double unlock;

  /// 0..1, breathing glow of the active rim.
  final double breath;

  /// Displayed progress (animated on entry).
  final double progress;

  /// -1..1, horizontal shake of the lock.
  final double lockShake;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final c = widget.course;
    final t = widget.unlock;
    // Content cross-fades: locked layout out first, unlocked layout in after.
    final lockedOpacity = (1 - t / 0.5).clamp(0.0, 1.0);
    final activeOpacity = ((t - 0.4) / 0.5).clamp(0.0, 1.0);
    final radius = BorderRadius.circular(u * 4.7);
    return Semantics(
      button: true,
      label: c.title,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                // 1.5 px dark contact line under the card.
                const BoxShadow(
                  color: RateelColors.cardContact,
                  offset: Offset(0, 1.5),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.40),
                  blurRadius: u * 2.2,
                  offset: Offset(0, u * 0.6),
                ),
                if (t > 0)
                  BoxShadow(
                    color: RateelColors.gold.withValues(
                      alpha:
                          t * lerpDouble(0.0, 0.10, widget.breath)! +
                          // Flash of light when the course unlocks.
                          0.35 * math.sin(math.pi * t),
                    ),
                    blurRadius: u * 2.4,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 0.5, 0.72, 1],
                        colors: [
                          RateelColors.cardTop,
                          RateelColors.cardMid,
                          RateelColors.cardLow,
                          RateelColors.cardBottom,
                        ],
                      ),
                    ),
                  ),
                  _pattern(u),
                  if (lockedOpacity > 0)
                    ..._fade(lockedOpacity, _lockedContent(u)),
                  if (t > 0) ..._fade(activeOpacity, _activeContent(u)),
                  if (t < 1) _lock(u),
                  _rim(u, radius, t),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Faint tone-on-tone star lattice along the bottom (shared star tile,
  /// tinted emerald).
  Widget _pattern(double u) {
    final h = u * 9;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: h,
      child: IgnorePointer(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00000000), Color(0xFF000000)],
          ).createShader(r),
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerRight,
              maxWidth: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var n = 0; n < 7; n++)
                    SvgPicture.asset(
                      'assets/ui/decor/star_tile.svg',
                      height: h,
                      width: h * 216 / 170,
                      colorFilter: const ColorFilter.mode(
                        RateelColors.cardPattern,
                        BlendMode.srcIn,
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

  List<Widget> _fade(double opacity, List<Widget> children) => [
    for (final w in children)
      if (w is Positioned)
        Positioned(
          left: w.left,
          top: w.top,
          right: w.right,
          bottom: w.bottom,
          width: w.width,
          height: w.height,
          child: Opacity(opacity: opacity, child: w.child),
        )
      else
        Opacity(opacity: opacity, child: w),
  ];

  Widget _rim(double u, BorderRadius radius, double t) => IgnorePointer(
    child: CustomPaint(
      painter: _RimPainter(radius: radius.topLeft.x, t: t),
    ),
  );

  List<Widget> _activeContent(double u) {
    final c = widget.course;
    final pct = (widget.progress * 100).round();
    return [
      // Level pill «مستوى مبتدئ» with a star.
      Positioned(
        left: u * 6.25,
        top: u * 4.3,
        width: u * 28.2,
        height: u * 6.1,
        child: Container(
          decoration: BoxDecoration(
            color: RateelColors.pillFill,
            borderRadius: BorderRadius.circular(u * 3.05),
            border: Border.all(color: RateelColors.gold, width: 2),
          ),
          padding: EdgeInsets.symmetric(horizontal: u * 1.0),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PLACEHOLDER glyph until the owner's UI glyph set (prompt P6).
              Icon(Icons.star_rounded, size: u * 4.4, color: RateelColors.gold),
              SizedBox(width: u * 1.2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'مستوى مبتدئ',
                    textDirection: TextDirection.rtl,
                    style: readex(
                      u * 3.3,
                      weight: 400,
                      color: RateelColors.gold,
                    ).copyWith(height: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      _icon(u, right: u * 5.9, top: u * 3.6, height: u * 8.6),
      _title(u, c.title, centerY: u * 17.0),
      _rule(u, centerY: u * 23.6, right: u * 7.3, width: u * 51.5),
      _description(u, c.description, firstCenterY: u * 27.7),
      // Play button: gold ring, olive glass, gold triangle.
      Positioned(
        left: u * 10.3 - u * 4.05,
        top: u * 39.8 - u * 4.05,
        width: u * 8.1,
        height: u * 8.1,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RateelColors.playFill,
            border: Border.all(color: RateelColors.goldHighlight, width: 2.6),
          ),
          child: CustomPaint(painter: _PlayGlyph()),
        ),
      ),
      // Progress bar.
      Positioned(
        left: u * 18.7,
        top: u * 39.8 - u * 0.7,
        width: u * 38.9,
        height: u * 1.4,
        child: Container(
          decoration: BoxDecoration(
            color: RateelColors.progressTrack,
            borderRadius: BorderRadius.circular(u * 0.7),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: widget.progress.clamp(0.0, 1.0),
            heightFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                color: RateelColors.progressFill,
                borderRadius: BorderRadius.circular(u * 0.7),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        // Fixed right-aligned slot: «100%» keeps clear of the bar.
        right: u * 6.3,
        width: u * 7.6,
        top: u * 39.8 - u * 2,
        height: u * 4,
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$pct%',
            textDirection: TextDirection.ltr,
            maxLines: 1,
            softWrap: false,
            style: readex(
              u * 2.7,
              weight: 400,
              color: RateelColors.label,
            ).copyWith(height: 1),
          ),
        ),
      ),
    ];
  }

  /// Lock disc of a locked card; it pops and fades out when the course
  /// unlocks.
  Widget _lock(double u) {
    final t = widget.unlock;
    final pop = 1 + 0.35 * math.sin(math.pi * (t * 1.4).clamp(0.0, 1.0));
    final w = Positioned(
      right: u * 8.1 - u * 3.9 + widget.lockShake * u * 0.8,
      top: u * 7.5 - u * 3.9,
      width: u * 7.8,
      height: u * 7.8,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: RateelColors.lockDisc,
          border: Border.all(color: RateelColors.lockRim, width: 1.6),
        ),
        // PLACEHOLDER glyph until the owner's UI glyph set (prompt P6).
        child: Icon(
          Icons.lock_rounded,
          size: u * 3.7,
          color: RateelColors.lockGlyph,
        ),
      ),
    );
    return Positioned(
      left: w.left,
      top: w.top,
      right: w.right,
      width: w.width,
      height: w.height,
      child: Opacity(
        opacity: (1 - t * 1.3).clamp(0.0, 1.0),
        child: Transform.scale(scale: pop, child: w.child),
      ),
    );
  }

  List<Widget> _lockedContent(double u) {
    final c = widget.course;
    return [
      _icon(u, centerX: u * 72.4 * 0.475, top: u * 3.2, height: u * 9.6),
      _title(u, c.title, centerY: u * 17.2, right: u * 5.7),
      _rule(u, centerY: u * 23.9, right: u * 6.4, width: u * 54.8),
      _description(u, c.description, firstCenterY: u * 28.2, right: u * 5.7),
    ];
  }

  Widget _icon(
    double u, {
    double? right,
    double? centerX,
    required double top,
    required double height,
  }) {
    final asset = widget.course.icon;
    final w = height * 1.4;
    // PLACEHOLDER: the nav's outline Quran glyph in gold for the courses
    // whose icon is not delivered yet (prompts P4/P5).
    final child = asset != null
        ? Image.asset(asset, fit: BoxFit.contain, alignment: Alignment.center)
        : SvgPicture.asset(
            'assets/ui/nav/quran.svg',
            theme: const SvgTheme(currentColor: RateelColors.gold),
          );
    return Positioned(
      right: right,
      left: centerX == null ? null : centerX - w / 2,
      top: top,
      width: w,
      height: height,
      child: IgnorePointer(child: child),
    );
  }

  Widget _title(
    double u,
    String text, {
    required double centerY,
    double? right,
  }) {
    return Positioned(
      left: u * 4,
      right: right ?? u * 6.4,
      top: centerY - u * 4,
      height: u * 8,
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            style: readex(
              u * 5.3,
              weight: 560,
              color: RateelColors.label,
            ).copyWith(height: 1),
          ),
        ),
      ),
    );
  }

  /// Thin gold rule under the title, fading at both ends.
  Widget _rule(
    double u, {
    required double centerY,
    required double right,
    required double width,
  }) {
    return Positioned(
      right: right,
      width: width,
      top: centerY - 1,
      height: 2,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [0, 0.35, 0.85, 1],
            colors: [
              Color(0x00F2B623),
              RateelColors.gold,
              RateelColors.goldHighlight,
              Color(0x00F2B623),
            ],
          ),
        ),
      ),
    );
  }

  Widget _description(
    double u,
    String text, {
    required double firstCenterY,
    double? right,
  }) {
    final lineH = u * 5.1;
    return Positioned(
      left: u * 15.5,
      right: right ?? u * 6.4,
      top: firstCenterY - lineH / 2,
      height: lineH * 2,
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: readex(
          u * 3.4,
          weight: 340,
          color: RateelColors.cream,
        ).copyWith(height: lineH / (u * 3.4)),
      ),
    );
  }
}

/// Gold play triangle with softly rounded corners.
class _PlayGlyph extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final path = Path()
      ..moveTo(s * 0.40, s * 0.30)
      ..lineTo(s * 0.70, s * 0.50)
      ..lineTo(s * 0.40, s * 0.70)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = RateelColors.gold
        ..style = PaintingStyle.fill
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = RateelColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.06
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PlayGlyph old) => false;
}

/// Card rim. Locked: 4 px emerald glass edge, lighter at the top and bright at
/// the bottom (#2F6954 → #27654F → #559174). Unlocked: gold double rim
/// (goldRim 1.4 px outside, goldHighlight 2 px inside). [t] blends them.
class _RimPainter extends CustomPainter {
  _RimPainter({required this.radius, required this.t});

  final double radius;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    RRect inset(double d) =>
        RRect.fromRectAndRadius(rect.deflate(d), Radius.circular(radius - d));
    if (t < 1) {
      canvas.drawRRect(
        inset(2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.85, 1],
            colors: [
              RateelColors.cardRimTop.withValues(alpha: 1 - t),
              RateelColors.cardRim.withValues(alpha: 1 - t),
              RateelColors.cardRimBottom.withValues(alpha: 1 - t),
            ],
          ).createShader(rect),
      );
    }
    if (t > 0) {
      canvas.drawRRect(
        inset(0.7),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = RateelColors.goldRim.withValues(alpha: t),
      );
      canvas.drawRRect(
        inset(2.4),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = RateelColors.goldHighlight.withValues(alpha: t),
      );
    }
  }

  @override
  bool shouldRepaint(_RimPainter old) => old.t != t || old.radius != radius;
}
