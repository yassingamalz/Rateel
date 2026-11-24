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
    this.artSet,
    this.number = 1,
    this.widthU = 72.4,
    this.heightU = 50,
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

  /// Illustrated card style (owner's mockup, 2026-11-21): a large course
  /// illustration on the left fading into the card, a gold arc, text on the
  /// right. `green`, `gold`, `abstract` or `emblem` (`assets/ui/course_art/<set>/`);
  /// null = the reference-03 card.
  final String? artSet;

  /// Course number (1-based), for the illustration file.
  final int number;

  /// Card width in u (the illustrated cards are narrower).
  final double widthU;

  /// Card height in u (illustrated cards: 42u, owner 2026-11-24).
  final double heightU;

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
                BoxShadow(
                  color: RateelColors.cardContact,
                  offset: Offset(0, u * 0.18),
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
                  // Glass sheen: edges slightly lighter than the middle.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        stops: [0, 0.15, 0.85, 1],
                        colors: [
                          Color(0x400A4A36),
                          Color(0x000A4A36),
                          Color(0x000A4A36),
                          Color(0x400A4A36),
                        ],
                      ),
                    ),
                  ),
                  _pattern(u),
                  if (widget.artSet != null) _art(u),
                  if (lockedOpacity > 0)
                    ..._fade(
                      lockedOpacity,
                      widget.artSet != null
                          ? _illustratedText(u, active: false)
                          : _lockedContent(u),
                    ),
                  if (t > 0)
                    ..._fade(
                      activeOpacity,
                      widget.artSet != null
                          ? _illustratedActive(u)
                          : _activeContent(u),
                    ),
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

  /// Faint tone-on-tone lattice along the bottom (CR-07, tinted emerald).
  Widget _pattern(double u) {
    final h = u * 72.4 * 392 / 2172;
    return Positioned(
      left: 0,
      right: 0,
      bottom: -u * 3,
      height: h,
      child: IgnorePointer(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.35, 0.85],
            colors: [Color(0x00000000), Color(0xFF000000)],
          ).createShader(r),
          child: SvgPicture.asset(
            'assets/ui/decor/card_pattern.svg',
            fit: BoxFit.fill,
            colorFilter: const ColorFilter.mode(
              RateelColors.cardPattern,
              BlendMode.srcIn,
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
      painter: _RimPainter(radius: radius.topLeft.x, t: t, u: u),
    ),
  );

  /// Illustration on the left, fading out towards the text.
  Widget _art(double u) {
    final set = widget.artSet!;
    // The green set only has courses 1–3: the others use the gold set.
    final n = widget.number;
    final folder = set == 'green' && n > 3 ? 'gold' : set;
    final file =
        'assets/ui/course_art/$folder/course_${n.toString().padLeft(2, '0')}.webp';
    // Owner, 2026-11-21 (style D, background): the course art, enlarged, comes
    // in from the left edge of the card as a translucent background (45%) and
    // fades out towards the text. No gold arc.
    // Box scaled with the card height (46u on a 50u card).
    final h = widget.heightU;
    return Positioned(
      left: -u * h * 0.12,
      top: -u * h * 0.04,
      width: u * h * 0.92,
      height: u * h * 0.92,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.45,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              stops: [0, 0.45, 0.92],
              colors: [Color(0xFF000000), Color(0xFF000000), Color(0x00000000)],
            ).createShader(r),
            child: Image.asset(file, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  /// Title (up to two lines), small gold divider and description on the right
  /// half of an illustrated card.
  List<Widget> _illustratedText(double u, {required bool active}) {
    final c = widget.course;
    // Owner, 2026-11-24: wider-than-tall cards (62u × 42u). Title (up to two
    // lines), divider and a two-line description flow from the top.
    return [
      Positioned(
        right: u * 3.5,
        width: u * 36,
        top: u * 11.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              c.title,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: readex(
                u * 4.4,
                weight: 560,
                color: titleCream,
              ).copyWith(height: 1.15, shadows: titleShadows(u)),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: u * 7,
                top: u * 0.8,
                bottom: u * 0.8,
              ),
              child: SvgPicture.asset(
                'assets/ui/decor/title_divider.svg',
                width: u * 22,
                height: u * 2.2,
                fit: BoxFit.fill,
              ),
            ),
            Text(
              c.description,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: readex(
                u * 3.0,
                weight: 340,
                color: RateelColors.cream,
              ).copyWith(height: 4.3 / 3.0),
            ),
          ],
        ),
      ),
    ];
  }

  /// Course in progress, illustrated: pill top right, text, play + progress.
  List<Widget> _illustratedActive(double u) {
    final base = _activeContent(u);
    // base: [pill, icon, title, rule, description, play, bar, percent]
    final pill = base[0] as Positioned;
    final play = base[5] as Positioned;
    final bar = base[6] as Positioned;
    final pct = base[7] as Positioned;
    // Play row 6.7u above the bottom edge (base layout: 39.8u on a 50u card).
    final dy = u * (widget.heightU - 6.7 - 39.8);
    Positioned down(Positioned p, {double? width}) => Positioned(
      left: p.left,
      right: p.right,
      top: p.top! + dy,
      width: width ?? p.width,
      height: p.height,
      child: p.child,
    );
    return [
      Positioned(
        right: u * 3.5,
        top: pill.top,
        width: pill.width,
        height: pill.height,
        child: pill.child,
      ),
      ..._illustratedText(u, active: true),
      down(play),
      down(bar, width: u * (widget.widthU - 18.7 - 6.2 - 7.6)),
      down(pct),
    ];
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
            border: Border.all(color: RateelColors.gold, width: u * 0.23),
          ),
          // Reference: ~16 px from the rim to the star, ~20 px from the text to
          // the left rim; the text scales down rather than touch the rim
          // (owner, 2026-11-21, seen on the phone).
          padding: EdgeInsets.only(left: u * 2.3, right: u * 1.9),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Transform.translate(
                // Star centred on the body of the text (owner, 2026-11-24).
                offset: Offset(0, -u * 0.25),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (r) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      RateelColors.glyphGoldTop,
                      RateelColors.glyphGoldBottom,
                    ],
                  ).createShader(r),
                  child: SvgPicture.asset(
                    'assets/ui/glyphs/star.svg',
                    width: u * 3.6,
                    height: u * 3.6,
                  ),
                ),
              ),
              SizedBox(width: u * 1.0),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  // Readex sets Arabic low in its line box: lift it to the
                  // optical centre of the pill (owner, 2026-11-21).
                  child: Transform.translate(
                    offset: Offset(0, -u * 0.75),
                    child: Text(
                      'مستوى مبتدئ',
                      textDirection: TextDirection.rtl,
                      style: readex(
                        u * 3.0,
                        weight: 400,
                        color: RateelColors.gold,
                      ).copyWith(height: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      _icon(u, right: u * 5.3, top: u * 3.75, height: u * 8.3, width: u * 13.0),
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
            border: Border.all(
              color: RateelColors.goldHighlight,
              width: u * 0.3,
            ),
          ),
          alignment: Alignment.center,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [RateelColors.glyphGoldTop, RateelColors.glyphGoldBottom],
            ).createShader(r),
            child: SvgPicture.asset(
              'assets/ui/glyphs/play.svg',
              width: u * 5.3,
              height: u * 5.3,
            ),
          ),
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
        // Fixed right-aligned slot: «100%» keeps clear of the bar.
        right: u * 6.2,
        width: u * 6.0,
        top: u * 39.8 - u * 2,
        height: u * 4,
        child: FittedBox(
          fit: BoxFit.scaleDown,
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
      // The owner's lock badge (CR-10: cream padlock in a dark disc with a
      // green ring), owner 2026-11-21.
      child: Image.asset('assets/ui/glyphs/lock_badge.webp'),
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
      _icon(
        u,
        centerX: u * 72.4 * 0.479,
        top: u * 3.35,
        height: u * 9.3,
        width: u * 13,
      ),
      _title(u, c.title, centerY: u * 17.2, right: u * 5.35),
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
    required double width,
  }) {
    final asset = widget.course.icon;
    final w = width;
    // Course icons (shared library, assets/ui/courses/): right-aligned on the
    // course in progress, centred on locked cards.
    final align = right != null ? Alignment.centerRight : Alignment.center;
    final child = asset == null
        ? const SizedBox.shrink()
        : asset.endsWith('.svg')
        ? SvgPicture.asset(asset, fit: BoxFit.contain, alignment: align)
        : Image.asset(asset, fit: BoxFit.contain, alignment: align);
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
              color: titleCream,
            ).copyWith(height: 1, shadows: titleShadows(u)),
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
    final lineH = u * 4.95;
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

/// Card rim. Locked: 4 px emerald glass edge, lighter at the top and bright at
/// the bottom (#2F6954 → #27654F → #559174). Unlocked: 4 px muted gold rim
/// (cardRimGold 1.6 px outside, cardRimGoldInner 2.4 px inside). [t] blends
/// them.
class _RimPainter extends CustomPainter {
  _RimPainter({required this.radius, required this.t, required this.u});

  final double radius;
  final double t;

  /// 1% of the screen height: rim widths scale with the screen (owner,
  /// 2026-11-21: fixed pixels looked far too thick on the phone).
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    RRect inset(double d) =>
        RRect.fromRectAndRadius(rect.deflate(d), Radius.circular(radius - d));
    if (t < 1) {
      canvas.drawRRect(
        inset(u * 0.235),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * 0.47
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
        inset(u * 0.095),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * 0.19
          ..color = RateelColors.cardRimGold.withValues(alpha: t),
      );
      canvas.drawRRect(
        inset(u * 0.33),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * 0.28
          ..color = RateelColors.cardRimGoldInner.withValues(alpha: t),
      );
    }
  }

  @override
  bool shouldRepaint(_RimPainter old) =>
      old.t != t || old.radius != radius || old.u != u;
}
