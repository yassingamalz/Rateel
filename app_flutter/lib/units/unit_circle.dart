import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../theme/rateel_theme.dart';
import 'unit_data.dart';

/// One unit of screen 05: a gold ring (also the progress ring, as in the
/// Angular app) around a glass disc with the unit icon and title.
///
/// Geometry in u (1% of the screen height), measured on reference 05
/// (1672×941, u = 9.41 px). The widget box is the outer ring (46u); badge,
/// check and sparkles overflow it.
class UnitCircle extends StatefulWidget {
  const UnitCircle({
    super.key,
    required this.unit,
    required this.u,
    required this.progress,
    required this.unlock,
    required this.done,
    required this.flash,
    required this.ambient,
    required this.lockShake,
    required this.filling,
    this.onTap,
    this.onLongPress,
  });

  final Unit unit;
  final double u;

  /// 0..1, the arc of the progress ring.
  final double progress;

  /// 0 = locked, 1 = open (the lock pops, the ring turns gold, the badge
  /// drops in, the type icon turns into the play disc).
  final double unlock;

  /// 0 = in progress, 1 = completed (play disc → type icon, check badge).
  final double done;

  /// 0..1 burst of light and sparkles when the ring reaches 100%.
  final double flash;

  /// 0..1 repeating (4 s): breathing glow of the open unit, badge shine.
  final double ambient;

  /// Damped −1..1 shake of the padlock (locked tap).
  final double lockShake;

  /// The ring is filling (completion sequence): a light head runs on its tip.
  final bool filling;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<UnitCircle> createState() => _UnitCircleState();
}

class _UnitCircleState extends State<UnitCircle> with TickerProviderStateMixin {
  /// Press-down scale (Angular: hover scale 1.05).
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 260),
  );

  /// After a tap: a ripple ring grows out of the icon and a shine sweeps it
  /// (Angular: icon ripple + shine on hover).
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void dispose() {
    _press.dispose();
    _ripple.dispose();
    super.dispose();
  }

  bool get _open => widget.unlock >= 1;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _press.forward(),
      onTapCancel: () => _press.reverse(),
      onTapUp: (_) {
        _press.reverse();
        if (_open) {
          Haptics.tap();
          _ripple.forward(from: 0);
        }
        widget.onTap?.call();
      },
      onLongPress: () {
        _press.reverse();
        widget.onLongPress?.call();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_press, _ripple]),
        builder: (context, _) {
          final press = Curves.easeOut.transform(_press.value);
          return Transform.scale(
            scale: 1 - 0.04 * press,
            child: SizedBox(
              width: u * 46,
              height: u * 46,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _RingPainter(
                          u: u,
                          progress: widget.progress,
                          unlock: widget.unlock,
                          done: widget.done,
                          flash: widget.flash,
                          breath: _open && widget.done == 0
                              ? 0.5 -
                                    0.5 * math.cos(2 * math.pi * widget.ambient)
                              : 0,
                          head: widget.filling,
                        ),
                      ),
                    ),
                  ),
                  _disc(u),
                  ..._content(u),
                  if (_ripple.value > 0 && _ripple.value < 1) _rippleRing(u),
                  if (widget.unlock < 1) _padlock(u),
                  if (widget.unlock > 0) _badge(u),
                  if (widget.done > 0) _check(u),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Glass disc inside the ring (Ø 41u), lighter at the top, with the faint
  /// star lattice along its bottom (shared CR-07, as on the course cards).
  Widget _disc(double u) {
    return SizedBox(
      width: u * 40.8,
      height: u * 40.8,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -1),
                  radius: 0.85,
                  stops: [0, 0.45, 1],
                  colors: [
                    RateelColors.unitDiscTop,
                    RateelColors.unitDiscMid,
                    RateelColors.unitDiscBottom,
                  ],
                ),
              ),
            ),
            Positioned(
              left: -u * 6,
              right: -u * 6,
              bottom: -u * 1.5,
              height: u * 52.8 * 392 / 2172,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.6],
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
            // Rim and soft inner shadow at the edge of the glass.
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: RateelColors.unitDiscRim,
                  width: u * 0.22,
                ),
                gradient: const RadialGradient(
                  stops: [0.86, 1],
                  colors: [Color(0x00000000), Color(0x40000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(double u) {
    final unlock = widget.unlock;
    final done = widget.done;
    // Locked and completed units show the unit-type icon; the open unit
    // shows the play disc (start / continue).
    final video = widget.unit.type == UnitType.video;
    final playOpacity = (unlock * (video ? 1 : 1 - done)).clamp(0.0, 1.0);
    final iconOpacity = 1 - playOpacity;
    return [
      if (iconOpacity > 0)
        Positioned(
          top: u * (23 - 6.2) - u * 5.6,
          child: Opacity(
            opacity: iconOpacity,
            child: Transform.scale(
              scale: done > 0 ? lerpDouble(0.6, 1, _bounce(done))! : 1,
              child: _typeIcon(u),
            ),
          ),
        ),
      if (playOpacity > 0)
        Positioned(
          top: u * (23 - 7.9) - u * 5.85,
          child: Opacity(
            opacity: playOpacity,
            child: Transform.scale(
              scale:
                  lerpDouble(0.6, 1, _bounce(unlock))! *
                  (video ? 1 : 1 - 0.3 * done),
              child: _playDisc(u),
            ),
          ),
        ),
      // Title, two lines, centred at +6.4u.
      Positioned(
        top: u * (23 + 6.4) - u * 6.4,
        width: u * 32,
        height: u * 12.8,
        child: Center(
          child: Text(
            widget.unit.title,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: readex(
              u * 4.9,
              weight: 560,
              color: titleCream,
            ).copyWith(height: 1.22, shadows: titleShadows(u)),
          ),
        ),
      ),
    ];
  }

  /// Cream play disc (Ø 11.7u) with a dark triangle; the shine sweeps it
  /// after a tap.
  Widget _playDisc(double u) {
    final shine = _ripple.value;
    return Container(
      width: u * 11.7,
      height: u * 11.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(0, -0.5),
          radius: 0.9,
          colors: [RateelColors.playCreamTop, RateelColors.playCream],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: u * 1.2,
            offset: Offset(0, u * 0.4),
          ),
          BoxShadow(
            color: RateelColors.goldHighlight.withValues(alpha: 0.18),
            blurRadius: u * 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: u * 0.5),
              child: SvgPicture.asset(
                'assets/ui/glyphs/play.svg',
                width: u * 9,
                height: u * 9,
                theme: const SvgTheme(currentColor: RateelColors.playGlyph),
              ),
            ),
            if (shine > 0 && shine < 1)
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(u * 14 * (shine * 2 - 1), 0),
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Container(
                      width: u * 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x00FFFFFF),
                            Color(0x66FFFFFF),
                            Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Unit-type icon, owner's assets 2026-11-22 (ASSETS.md, "Units"): book
  /// (PNG, closest to the reference), microphone and test scroll (SVG). A
  /// locked video unit shows the play glyph in cream gold.
  Widget _typeIcon(double u) {
    final Widget icon = switch (widget.unit.type) {
      UnitType.reading => Image.asset(
        'assets/ui/units/book.webp',
        fit: BoxFit.contain,
      ),
      UnitType.practice => SvgPicture.asset(
        'assets/ui/units/microphone.svg',
        fit: BoxFit.contain,
      ),
      UnitType.test => SvgPicture.asset(
        'assets/ui/units/test_scroll.svg',
        fit: BoxFit.contain,
      ),
      UnitType.video => SvgPicture.asset(
        'assets/ui/glyphs/play.svg',
        fit: BoxFit.contain,
        theme: const SvgTheme(currentColor: RateelColors.unitIconTop),
      ),
    };
    return SizedBox(width: u * 14.9, height: u * 11.2, child: icon);
  }

  /// Emerald padlock (owner's U2) on the icon of a locked unit: it shakes on
  /// a tap and pops off when the unit opens.
  Widget _padlock(double u) {
    final t = widget.unlock;
    final pop = 1 + 0.45 * math.sin(math.pi * (t * 1.3).clamp(0.0, 1.0));
    return Positioned(
      top: u * (23 - 5.3) - u * 3.7 - u * 4 * t,
      left: u * 23 - u * 3.7 + widget.lockShake * u * 0.9,
      width: u * 7.4,
      height: u * 7.4,
      child: Opacity(
        opacity: (1 - t * 1.2).clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: widget.lockShake * 0.18 - t * 0.5,
          child: Transform.scale(
            scale: pop,
            child: SvgPicture.asset('assets/ui/units/padlock.svg'),
          ),
        ),
      ),
    );
  }

  /// Gold progress badge on top of the ring (Ø 9.8u); drops in when the unit
  /// opens; a soft shine sweeps it every 4 s (Angular: every 3 s).
  Widget _badge(double u) {
    final t = Curves.easeOutBack.transform(widget.unlock.clamp(0.0, 1.0));
    final pct = (widget.progress * 100).round();
    final shine = (widget.ambient * 4).clamp(0.0, 1.0);
    return Positioned(
      top: -u * 4.9 - u * 3 * (1 - t),
      left: u * 23 - u * 4.9,
      width: u * 9.8,
      height: u * 9.8,
      child: Opacity(
        opacity: widget.unlock.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(0, -0.6),
              radius: 1,
              colors: [RateelColors.badgeTop, RateelColors.badge],
            ),
            boxShadow: [
              BoxShadow(
                color: RateelColors.gold.withValues(
                  alpha: 0.35 + 0.4 * widget.flash,
                ),
                blurRadius: u * (1.6 + 2 * widget.flash),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: u * 1.2),
                    child: Text(
                      '$pct%',
                      textDirection: TextDirection.ltr,
                      style: readex(
                        u * 3.3,
                        weight: 600,
                        color: RateelColors.badgeText,
                      ).copyWith(height: 1),
                    ),
                  ),
                ),
                if (shine > 0 && shine < 1)
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(u * 12 * (shine * 2 - 1), 0),
                      child: Transform.rotate(
                        angle: 0.45,
                        child: Container(
                          width: u * 2.4,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0x00FFFFFF),
                                Color(0x55FFFFFF),
                                Color(0x00FFFFFF),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Completed unit: gold check badge on the bottom of the ring, spinning in
  /// with a bounce, and a pulse ring (Angular: scale 0 + rotate −180°, pulse).
  Widget _check(double u) {
    final d = widget.done;
    final s = _bounce(d);
    final pulse = widget.ambient;
    return Positioned(
      top: u * 46 - u * 3.6,
      left: u * 23 - u * 3.6,
      width: u * 7.2,
      height: u * 7.2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (d >= 1)
            Transform.scale(
              scale: 1 + 0.5 * pulse,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: RateelColors.badge.withValues(
                      alpha: 0.7 * (1 - pulse),
                    ),
                    width: u * 0.25,
                  ),
                ),
              ),
            ),
          Transform.rotate(
            angle: -math.pi * (1 - d.clamp(0.0, 1.0)),
            child: Transform.scale(
              scale: s,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(0, -0.6),
                    radius: 1,
                    colors: [RateelColors.badgeTop, RateelColors.badge],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RateelColors.gold.withValues(alpha: 0.45),
                      blurRadius: u * 1.6,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/ui/glyphs/check.svg',
                  width: u * 4,
                  height: u * 4,
                  theme: const SvgTheme(currentColor: RateelColors.badgeText),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rippleRing(double u) {
    final t = Curves.easeOutCubic.transform(_ripple.value);
    return IgnorePointer(
      child: Container(
        width: u * 40.8 * (0.35 + 0.65 * t),
        height: u * 40.8 * (0.35 + 0.65 * t),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: RateelColors.goldHighlight.withValues(alpha: 0.5 * (1 - t)),
            width: u * 0.3,
          ),
          boxShadow: [
            BoxShadow(
              color: RateelColors.gold.withValues(alpha: 0.18 * (1 - t)),
              blurRadius: u * 3,
            ),
          ],
        ),
      ),
    );
  }
}

/// Overshoot 0 → 1.2 → 1 (Angular `bounce`).
double _bounce(double t) {
  final x = t.clamp(0.0, 1.0);
  if (x < 0.5) return Curves.easeOut.transform(x / 0.5) * 1.2;
  return 1.2 - 0.2 * Curves.easeInOut.transform((x - 0.5) / 0.5);
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.u,
    required this.progress,
    required this.unlock,
    required this.done,
    required this.flash,
    required this.breath,
    required this.head,
  });

  final double u;
  final double progress;
  final double unlock;
  final double done;
  final double flash;
  final double breath;
  final bool head;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - u * 0.21;
    final ring = Color.lerp(
      RateelColors.unitRingLocked,
      RateelColors.unitRing,
      unlock.clamp(0.0, 1.0),
    )!;
    // Glow of the open ring (breathing), stronger on the flash.
    final glow = 0.16 * unlock + 0.14 * breath + 0.5 * flash;
    if (glow > 0) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * (1.2 + 1.5 * flash)
          ..color = RateelColors.gold.withValues(alpha: glow.clamp(0.0, 1.0))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * (1 + flash)),
      );
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.42
        ..color = ring,
    );
    // Progress arc from the top, clockwise, brighter and thicker.
    final p = progress.clamp(0.0, 1.0);
    if (p > 0) {
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * p,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * 1.6
          ..strokeCap = StrokeCap.round
          ..color = RateelColors.gold.withValues(alpha: 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.7),
      );
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * p,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * 0.8
          ..strokeCap = StrokeCap.round
          ..color = RateelColors.goldHighlight,
      );
      if (head && p < 1) {
        final a = -math.pi / 2 + 2 * math.pi * p;
        final tip = c + Offset(math.cos(a), math.sin(a)) * r;
        canvas.drawCircle(
          tip,
          u * 2,
          Paint()
            ..color = RateelColors.goldHighlight.withValues(alpha: 0.75)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.2),
        );
        canvas.drawCircle(tip, u * 0.6, Paint()..color = RateelColors.label);
      }
    }
    if (flash > 0 && flash < 1) _sparkles(canvas, c, r);
  }

  /// Gold sparkles flying out of the ring when it reaches 100%.
  void _sparkles(Canvas canvas, Offset c, double r) {
    final t = Curves.easeOutCubic.transform(flash);
    final fade = (1 - flash).clamp(0.0, 1.0);
    for (var k = 0; k < 14; k++) {
      final a = 2 * math.pi * k / 14 + 0.21 * (k.isEven ? 1 : -1);
      final dist = r + u * (2 + (k % 3 + 2) * 2.6 * t);
      final p = c + Offset(math.cos(a), math.sin(a)) * dist;
      final s = u * (0.9 + 0.5 * (k % 3)) * (0.6 + 0.4 * fade);
      final paint = Paint()
        ..color = (k.isEven ? RateelColors.goldHighlight : RateelColors.label)
            .withValues(alpha: fade);
      final path = Path()
        ..moveTo(p.dx, p.dy - s)
        ..quadraticBezierTo(p.dx, p.dy, p.dx + s * 0.35, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + s)
        ..quadraticBezierTo(p.dx, p.dy, p.dx - s * 0.35, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - s)
        ..close();
      canvas.drawCircle(
        p,
        s * 0.8,
        Paint()
          ..color = RateelColors.gold.withValues(alpha: 0.35 * fade)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.6),
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.unlock != unlock ||
      old.done != done ||
      old.flash != flash ||
      old.breath != breath ||
      old.head != head ||
      old.u != u;
}
