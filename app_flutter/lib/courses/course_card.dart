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
    required this.breath,
    required this.progress,
    required this.lockShake,
    required this.onTap,
  });

  final Course course;
  final double u;

  /// 0..1, breathing glow of the active rim.
  final double breath;

  /// Displayed progress (animated on entry).
  final double progress;

  /// -1..1, horizontal shake of the lock.
  final double lockShake;
  final VoidCallback onTap;

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final c = widget.course;
    final active = !c.locked;
    final radius = BorderRadius.circular(u * 3.5);
    return Semantics(
      button: true,
      label: c.title,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.40),
                  blurRadius: u * 2.2,
                  offset: Offset(0, u * 0.6),
                ),
                if (active)
                  BoxShadow(
                    color: RateelColors.gold.withValues(
                      alpha: lerpDouble(0.08, 0.22, widget.breath)!,
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
                        stops: [0, 0.45, 1],
                        colors: [
                          RateelColors.cardTop,
                          RateelColors.cardMid,
                          RateelColors.cardBottom,
                        ],
                      ),
                    ),
                  ),
                  _pattern(u),
                  ...(active ? _activeContent(u) : _lockedContent(u)),
                  _rim(u, radius, active),
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
                        Color(0x8C1A6046),
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

  Widget _rim(double u, BorderRadius radius, bool active) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: active ? RateelColors.goldRim : RateelColors.cardRimDark,
            width: 1.4,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.topLeft.x - 1.4),
              border: Border.all(
                color: active
                    ? RateelColors.goldHighlight
                    : RateelColors.cardRim,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
          padding: EdgeInsets.symmetric(horizontal: u * 2.0),
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
                      u * 3.0,
                      weight: 400,
                      color: RateelColors.label,
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
      _rule(u, centerY: u * 23.6, opacity: 1),
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
        width: u * 40.4,
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
        right: u * 6.3,
        top: u * 39.8 - u * 2,
        height: u * 4,
        child: Center(
          child: Text(
            '$pct%',
            textDirection: TextDirection.ltr,
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

  List<Widget> _lockedContent(double u) {
    final c = widget.course;
    return [
      Positioned(
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
            size: u * 3.4,
            color: RateelColors.lockGlyph,
          ),
        ),
      ),
      _icon(u, centerX: u * 72.4 * 0.475, top: u * 3.2, height: u * 9.6),
      _title(u, c.title, centerY: u * 18.1),
      _rule(u, centerY: u * 24.3, opacity: 0.55),
      _description(u, c.description, firstCenterY: u * 28.2),
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

  Widget _title(double u, String text, {required double centerY}) {
    return Positioned(
      left: u * 4,
      right: u * 6.4,
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
  Widget _rule(double u, {required double centerY, required double opacity}) {
    return Positioned(
      right: u * 6.5,
      width: u * 51.5,
      top: centerY - 1,
      height: 2,
      child: Opacity(
        opacity: opacity,
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
      ),
    );
  }

  Widget _description(double u, String text, {required double firstCenterY}) {
    final lineH = u * 5.1;
    return Positioned(
      left: u * 15.5,
      right: u * 6.4,
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
