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

  /// 0..1 repeating (4 s): breathing glow of the open unit, badge shine,
  /// check pulse. Passed as an animation so that only the parts it drives
  /// repaint each frame, never the whole path (PERFORMANCE.md).
  final Animation<double> ambient;

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
              width: u * _d,
              height: u * _d,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: _lockedLook(
                      u,
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: RepaintBoundary(
                                child: CustomPaint(
                                  painter: _RingPainter(
                                    u: u,
                                    progress: widget.progress,
                                    unlock: 1 - _locked,
                                    done: widget.done,
                                    flash: widget.flash,
                                    breath: _open && widget.done == 0
                                        ? widget.ambient
                                        : null,
                                    head: widget.filling,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _disc(u),
                          ..._content(u),
                        ],
                      ),
                    ),
                  ),
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
      width: u * 41,
      height: u * 41,
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
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                gradient: const RadialGradient(
                  stops: [0.80, 0.985],
                  colors: [Color(0x000B422A), RateelColors.unitDiscEdge],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1 while locked, 0 once open: the dark look lifts while the padlock
  /// flies off (owner, 2026-11-22: the unit icon never changes, it only
  /// lights up).
  double get _locked => 1 - _seg(widget.unlock, 0.3, 0.8);

  /// Locked units are darkened by a veil (owner's choice B, 2026-11-22),
  /// which lifts while the padlock flies off.
  Widget _lockedLook(double u, Widget child) {
    final l = _locked;
    if (l == 0) return child;
    final k = 1 - 0.45 * l;
    return ColorFiltered(
      colorFilter: ColorFilter.matrix([
        k,
        0,
        0,
        0,
        0,
        0,
        k,
        0,
        0,
        0,
        0,
        0,
        k,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: child,
    );
  }

  List<Widget> _content(double u) {
    // The unit-type icon stays the same in every state (video units: the play
    // disc); a light ring passes over it as the unit opens.
    final video = widget.unit.type == UnitType.video;
    final glow = _seg(widget.unlock, 0.45, 0.95);
    return [
      if (glow > 0 && glow < 1)
        Positioned(
          top: u * (_r - 6.2) - u * 9,
          child: IgnorePointer(
            child: Container(
              width: u * 18,
              height: u * 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: RateelColors.goldHighlight.withValues(
                    alpha: 0.6 * (1 - glow),
                  ),
                  width: u * 0.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: RateelColors.gold.withValues(
                      alpha: 0.35 * (1 - glow),
                    ),
                    blurRadius: u * 3,
                  ),
                ],
              ),
              transform: Matrix4.diagonal3Values(
                0.6 + 0.5 * glow,
                0.6 + 0.5 * glow,
                1,
              ),
              transformAlignment: Alignment.center,
            ),
          ),
        ),
      Positioned(
        top: video ? u * (_r - 7.9) - u * 5.85 : u * (_r - 6.2) - u * 5.6,
        child: video ? _playDisc(u) : _typeIcon(u),
      ),
      // Title, two lines, centred at +6.4u.
      Positioned(
        top: u * (_r + 6.4) - u * 6.4,
        width: u * 32,
        height: u * 12.8,
        child: Center(
          child: Text(
            widget.unit.title,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            // Locked titles 4.6u, open ones 4.9u (reference).
            style: readex(
              u * lerpDouble(4.6, 4.9, 1 - _locked)!,
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
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.playCreamTop, RateelColors.playCream],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: u * 1.2,
            offset: Offset(0, u * 0.4),
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
    final t = _seg(widget.unlock, 0, 0.45);
    final pop = 1 + 0.35 * math.sin(math.pi * (t * 1.3).clamp(0.0, 1.0));
    // Centred on the unit icon for every type, larger than the reference
    // (owner, 2026-11-22).
    final size = lockSize;
    final cy = widget.unit.type == UnitType.video ? 7.9 : 6.2;
    return Positioned(
      top: u * (_r - cy) - u * size / 2 - u * 5 * t,
      left: u * _r - u * size / 2 + widget.lockShake * u * 0.9,
      width: u * size,
      height: u * size,
      child: Opacity(
        // Solid while it lifts off the book, fades on the second half.
        opacity: 1 - _seg(t, 0.5, 1),
        child: Transform.rotate(
          angle: widget.lockShake * 0.18 - t * 0.6,
          child: Transform.scale(
            scale: pop,
            child: SvgPicture.asset('assets/ui/units/padlock_green.svg'),
          ),
        ),
      ),
    );
  }

  /// Gold progress badge on top of the ring (Ø 9.8u); drops in when the unit
  /// opens; a soft shine sweeps it every 4 s (Angular: every 3 s).
  Widget _badge(double u) {
    final t = Curves.easeOutBack.transform(_seg(widget.unlock, 0.6, 1));
    final pct = (widget.progress * 100).round();
    return Positioned(
      top: -u * 4.5,
      left: u * _r - u * 4.9,
      width: u * 9.8,
      height: u * 9.8,
      child: Transform.scale(
        scale: _seg(widget.unlock, 0.6, 1) > 0 ? t.clamp(0.0, 1.2) : 0,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [RateelColors.badgeTop, RateelColors.badge],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: u * 0.8,
                offset: Offset(0, u * 0.3),
              ),
              if (widget.flash > 0)
                BoxShadow(
                  color: RateelColors.gold.withValues(
                    alpha: 0.75 * math.sin(math.pi * widget.flash),
                  ),
                  blurRadius: u * 3.6,
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
                    padding: EdgeInsets.only(
                      left: u * 1.2,
                      right: u * 1.2,
                      bottom: u * 0.45,
                    ),
                    child: Text(
                      '$pct%',
                      textDirection: TextDirection.ltr,
                      style: readex(
                        u * 3.8,
                        weight: 600,
                        color: RateelColors.badgeText,
                      ).copyWith(height: 1),
                    ),
                  ),
                ),
                // Shine: the first second of every 4 s loop. Its own small
                // builder, so the loop never rebuilds the badge or the path.
                Positioned.fill(
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: widget.ambient,
                      builder: (context, _) {
                        final shine = (widget.ambient.value * 4).clamp(
                          0.0,
                          1.0,
                        );
                        if (shine <= 0 || shine >= 1) {
                          return const SizedBox.shrink();
                        }
                        return Transform.translate(
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
                        );
                      },
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
    return Positioned(
      top: u * _d - u * 3.6,
      left: u * _r - u * 3.6,
      width: u * 7.2,
      height: u * 7.2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (d >= 1)
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: widget.ambient,
                builder: (context, _) {
                  final pulse = widget.ambient.value;
                  return Transform.scale(
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
                  );
                },
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
        width: u * 41 * (0.35 + 0.65 * t),
        height: u * 41 * (0.35 + 0.65 * t),
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
/// Ring diameter and radius in u (critic v2: 441–449 px on the reference).
const _d = 47.2;
const _r = _d / 2;

/// 0..1 progress of [t] inside the segment [a, b].
double _seg(double t, double a, double b) =>
    ((t - a) / (b - a)).clamp(0.0, 1.0);

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
  }) : super(repaint: breath);

  final double u;
  final double progress;
  final double unlock;
  final double done;
  final double flash;

  /// The 4 s ambient loop while the ring breathes (open unit), else null.
  /// The painter repaints from it without a rebuild.
  final Animation<double>? breath;
  final bool head;

  @override
  void paint(Canvas canvas, Size size) {
    final a = breath?.value;
    final breath_ = a == null ? 0.0 : 0.5 - 0.5 * math.cos(2 * math.pi * a);
    final c = size.center(Offset.zero);
    final r = size.width / 2 - u * 0.21;
    // Glow of the open ring (breathing), stronger on the flash.
    final glow = 0.16 * unlock + 0.14 * breath_ + 0.5 * flash;
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
    final rect0 = Rect.fromCircle(center: c, radius: r);
    final k = unlock.clamp(0.0, 1.0);
    if (k < 1) {
      // Locked ring: soft drop shadow (reference).
      canvas.drawCircle(
        c + Offset(0, u * 0.3),
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * 0.5
          ..color = Colors.black.withValues(alpha: 0.35 * (1 - k))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.6),
      );
    }
    // Dark hairlines on both sides of the rim.
    for (final d in [-0.26, 0.26]) {
      canvas.drawCircle(
        c,
        r + u * d,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * 0.11
          ..color = RateelColors.unitRingEdge.withValues(alpha: 0.7),
      );
    }
    // Rim lit at the top and bottom, deeper on the sides (sweep from 3 o'clock).
    Color mix(Color a, Color b) => Color.lerp(a, b, k)!;
    final side = mix(
      RateelColors.unitRingLockedSide,
      RateelColors.unitRingSide,
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.42
        ..shader = SweepGradient(
          colors: [
            side,
            mix(
              RateelColors.unitRingLockedBottom,
              RateelColors.unitRingTopBottom,
            ),
            side,
            mix(RateelColors.unitRingLockedTop, RateelColors.unitRingTopBottom),
            side,
          ],
          stops: const [0, 0.25, 0.5, 0.75, 1],
        ).createShader(rect0),
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
