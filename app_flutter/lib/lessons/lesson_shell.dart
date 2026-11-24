import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../theme/rateel_theme.dart';

/// Screen 02: the frame shared by every kind of lesson (video, reading,
/// practice, listening, test, guided). Same structure and behaviour as the
/// Angular `lesson-details` bar, restyled (owner, 2026-11-24, plan
/// `docs/flutter/screens/02-lesson-bar.md`):
/// - a glass **capsule** at the top left that fills with gold from the right,
///   with the lesson step «n/N» (cream on the dark part, dark on the gold);
/// - a glass **pause** button at the top right; pausing turns it gold with ▶
///   and a pulse, and slides in «back» (→) and «restart» (↻);
/// - while paused the lesson is veiled, blurred and pulled back a little
///   (Angular's strong veil);
/// - when the last step is reached a light runs along the capsule
///   ([LessonShellState.celebrate]).
///
/// The lesson page owns the step and the media: [onPausedChanged] tells it to
/// stop or resume, [onBack] / [onRestart] are the menu actions. The Android
/// back button opens the pause menu (and closes it when open).
class LessonShell extends StatefulWidget {
  const LessonShell({
    super.key,
    required this.step,
    required this.total,
    required this.onBack,
    required this.onRestart,
    required this.child,
    this.onPausedChanged,
    this.controlsVisible = true,
  });

  /// Current step (1-based; 0 before the first) and number of steps.
  final int step;
  final int total;

  /// Menu «back»: the page saves and leaves.
  final VoidCallback onBack;

  /// Menu «restart»: the page goes back to the start of the lesson.
  final VoidCallback onRestart;
  final ValueChanged<bool>? onPausedChanged;

  /// Hides bar and button (Angular `hideControls`, e.g. a test in review).
  final bool controlsVisible;

  /// The lesson content.
  final Widget child;

  @override
  State<LessonShell> createState() => LessonShellState();
}

class LessonShellState extends State<LessonShell>
    with TickerProviderStateMixin {
  // Menu (veil, items) 300 ms, as Angular.
  late final _menu = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  // Pulse ring of the gold button: 2 s loop while paused.
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  // Light along the capsule at 100%.
  late final _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  bool get paused =>
      _menu.status == AnimationStatus.forward ||
      _menu.status == AnimationStatus.completed;

  void setPaused(bool p) {
    if (p == paused) return;
    setState(() {});
    if (p) {
      _menu.forward();
      _pulse.repeat();
    } else {
      _menu.reverse();
      _pulse.stop();
      _pulse.value = 0;
    }
    widget.onPausedChanged?.call(p);
  }

  /// The lesson is complete: the light runs along the full capsule, with a
  /// milestone haptic. Completes when the light has passed.
  Future<void> celebrate() async {
    Haptics.milestone();
    await _sweep.forward(from: 0);
  }

  @override
  void dispose() {
    _menu.dispose();
    _pulse.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setPaused(!paused);
      },
      child: LayoutBuilder(
        builder: (context, box) {
          final u = box.maxHeight / 100;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Base under the content: the scaled-down, blurred lesson
              // never shows what is behind the route.
              const ColoredBox(
                key: ValueKey('base'),
                color: RateelColors.contentBottom,
              ),
              // Content: pulled back, dimmed and blurred while paused
              // (Angular: scale 0.98, brightness 0.8, blur 5 px).
              AnimatedBuilder(
                key: const ValueKey('content'),
                animation: _menu,
                child: widget.child,
                builder: (context, child) {
                  final t = Curves.easeOut.transform(_menu.value);
                  if (t == 0) return child!;
                  final b = 1 - 0.2 * t;
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: u * 0.55 * t,
                      sigmaY: u * 0.55 * t,
                      tileMode: TileMode.clamp,
                    ),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix([
                        b, 0, 0, 0, 0, //
                        0, b, 0, 0, 0, //
                        0, 0, b, 0, 0, //
                        0, 0, 0, 1, 0, //
                      ]),
                      child: Transform.scale(scale: 1 - 0.02 * t, child: child),
                    ),
                  );
                },
              ),
              // Veil; a tap on it resumes the lesson.
              AnimatedBuilder(
                key: const ValueKey('veil'),
                animation: _menu,
                builder: (context, _) => IgnorePointer(
                  ignoring: _menu.value == 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setPaused(false),
                    child: ColoredBox(
                      color: RateelColors.lessonVeil.withValues(
                        alpha:
                            RateelColors.lessonVeil.a *
                            Curves.easeOut.transform(_menu.value),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                key: const ValueKey('bar'),
                opacity: widget.controlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !widget.controlsVisible,
                  child: LessonTopBar(
                    u: u,
                    step: widget.step,
                    total: widget.total,
                    menu: _menu,
                    pulse: _pulse,
                    sweep: _sweep,
                    onToggle: () => setPaused(!paused),
                    onBack: () {
                      setPaused(false);
                      widget.onBack();
                    },
                    onRestart: () {
                      setPaused(false);
                      widget.onRestart();
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Geometry of the bar in u (1% of the screen height), measured on the
/// approved mockup v2, then «slightly larger» (owner, 2026-11-24).
class LessonBarMetrics {
  LessonBarMetrics._();
  static const margin = 3.0; // from the top, left and right edges
  static const button = 9.0; // pause / back / restart circles
  static const gap = 1.6; // between the circles
  static const capsuleW = 41.0;
  static const capsuleH = 6.2;
  static const number = 3.2; // «n/N»
}

/// The bar itself (capsule + buttons). Used by [LessonShell]; public so a
/// lesson that builds its own frame can place it.
class LessonTopBar extends StatelessWidget {
  const LessonTopBar({
    super.key,
    required this.u,
    required this.step,
    required this.total,
    required this.menu,
    required this.pulse,
    required this.sweep,
    required this.onToggle,
    required this.onBack,
    required this.onRestart,
  });

  final double u;
  final int step;
  final int total;
  final Animation<double> menu;
  final Animation<double> pulse;
  final Animation<double> sweep;
  final VoidCallback onToggle;
  final VoidCallback onBack;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    const m = LessonBarMetrics.margin;
    const b = LessonBarMetrics.button;
    final share = total == 0 ? 0.0 : (step / total).clamp(0.0, 1.0);
    // Items slide out from under the pause button (Angular: 20 px, 300 ms).
    Widget item(int k, String label, _Glyph g, VoidCallback onTap) {
      return AnimatedBuilder(
        key: ValueKey('item$k'),
        animation: menu,
        builder: (context, child) {
          final t = Curves.easeOutCubic.transform(menu.value);
          final x = m + (b + LessonBarMetrics.gap) * k * t;
          return Positioned(
            top: u * m,
            right: u * x,
            child: IgnorePointer(
              ignoring: menu.value < 0.5,
              child: Opacity(opacity: t, child: child),
            ),
          );
        },
        child: _GlassButton(
          u: u,
          semantics: label,
          glyph: g,
          gold: false,
          onTap: onTap,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Capsule, vertically centred on the button.
        Positioned(
          key: const ValueKey('capsule'),
          top: u * (m + b / 2 - LessonBarMetrics.capsuleH / 2),
          left: u * m,
          width: u * LessonBarMetrics.capsuleW,
          height: u * LessonBarMetrics.capsuleH,
          child: Semantics(
            label: 'الخطوة $step من $total',
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: share),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, v, _) => AnimatedBuilder(
                animation: sweep,
                builder: (context, _) => CustomPaint(
                  painter: _CapsulePainter(
                    u: u,
                    share: v,
                    text: '$step/$total',
                    sweep: sweep.value,
                  ),
                ),
              ),
            ),
          ),
        ),
        item(2, 'من البداية', _Glyph.restart, onRestart),
        item(1, 'رجوع', _Glyph.back, onBack),
        Positioned(
          key: const ValueKey('pause'),
          top: u * m,
          right: u * m,
          child: AnimatedBuilder(
            animation: Listenable.merge([menu, pulse]),
            builder: (context, _) => _GlassButton(
              u: u,
              semantics: menu.value > 0.5 ? 'متابعة' : 'إيقاف مؤقت',
              glyph: menu.value > 0.5 ? _Glyph.play : _Glyph.pause,
              gold: menu.value > 0.5,
              goldness: Curves.easeOut.transform(menu.value),
              pulse: menu.value > 0 ? pulse.value : null,
              onTap: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

/// The capsule: dark glass that fills with gold from the right (RTL), the
/// number split at the fill edge, the light at 100%.
class _CapsulePainter extends CustomPainter {
  _CapsulePainter({
    required this.u,
    required this.share,
    required this.text,
    required this.sweep,
  });

  final double u;
  final double share;
  final String text;
  final double sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    final rr = RRect.fromRectAndRadius(Offset.zero & size, r);
    // Shadow (card shadow token).
    canvas.drawRRect(
      rr.shift(Offset(0, u * 0.6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.1),
    );
    canvas.save();
    canvas.clipRRect(rr);
    // Dark glass (card gradient) with a soft inner shadow at the top.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.cardTop, RateelColors.cardMid],
        ).createShader(Offset.zero & size),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.45),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.35),
            Colors.black.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.45)),
    );
    // Gold fill from the right.
    final fw = size.width * share;
    final fill = Rect.fromLTWH(size.width - fw, 0, fw, size.height);
    if (fw > 0) {
      canvas.drawRect(
        fill,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              RateelColors.lessonIconTop,
              RateelColors.amberPill,
              RateelColors.origGoldBottom,
            ],
            stops: [0, 0.55, 1],
          ).createShader(fill),
      );
      // Top sheen, only on the gold.
      canvas.save();
      canvas.clipRect(fill);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.04,
            size.height * 0.08,
            size.width * 0.92,
            size.height * 0.28,
          ),
          Radius.circular(size.height * 0.14),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
      canvas.restore();
      // Soft light at the leading edge (2.2u, fading into the gold).
      if (share < 1) {
        final lead = Rect.fromLTWH(
          fill.left,
          0,
          math.min(u * 2.2, fw),
          size.height,
        );
        canvas.drawRect(
          lead,
          Paint()
            ..shader = LinearGradient(
              colors: [
                RateelColors.lessonBarLight.withValues(alpha: 0.9),
                RateelColors.lessonBarLight.withValues(alpha: 0),
              ],
            ).createShader(Rect.fromLTWH(fill.left, 0, u * 2.2, size.height)),
        );
      }
    }
    // Light running along the capsule (right → left, as the fill grows).
    if (sweep > 0 && sweep < 1) {
      final band = u * 9;
      final x = lerpDouble(
        size.width + band,
        -band,
        Curves.easeInOut.transform(sweep),
      )!;
      final rect = Rect.fromLTWH(x - band / 2, 0, band, size.height);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.6),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }
    // The number: cream on the dark part, dark on the gold.
    final light = _text(
      readex(
        u * LessonBarMetrics.number,
        weight: 520,
        color: RateelColors.label,
      ).copyWith(
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: u * 0.6,
          ),
        ],
      ),
    );
    final dark = _text(
      readex(
        u * LessonBarMetrics.number,
        weight: 520,
        color: RateelColors.countText,
      ),
    );
    // Readex sets the glyphs low in the line box: lift (as the pills, 03).
    final at = Offset(
      (size.width - light.width) / 2,
      (size.height - light.height) / 2 - u * 0.25,
    );
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, fill.left, size.height));
    light.paint(canvas, at);
    canvas.restore();
    canvas.save();
    canvas.clipRect(fill);
    dark.paint(canvas, at);
    canvas.restore();
    canvas.restore();
    // Rim.
    canvas.drawRRect(
      rr.deflate(u * 0.115),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.23
        ..color = RateelColors.cardRimTop,
    );
  }

  TextPainter _text(TextStyle s) => TextPainter(
    text: TextSpan(text: text, style: s),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(_CapsulePainter o) =>
      o.u != u || o.share != share || o.text != text || o.sweep != sweep;
}

enum _Glyph { pause, play, restart, back }

/// Glass circle (the glass button token of screens 04/06); gold when the
/// lesson is paused, with Angular's pulse ring.
class _GlassButton extends StatefulWidget {
  const _GlassButton({
    required this.u,
    required this.semantics,
    required this.glyph,
    required this.gold,
    required this.onTap,
    this.goldness = 0,
    this.pulse,
  });

  final double u;
  final String semantics;
  final _Glyph glyph;
  final bool gold;
  final double goldness;
  final double? pulse;
  final VoidCallback onTap;

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final d = u * LessonBarMetrics.button;
    final g = widget.goldness;
    return Semantics(
      button: true,
      label: widget.semantics,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) {
          setState(() => _down = false);
          Haptics.tap();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? 0.92 : 1,
          duration: const Duration(milliseconds: 120),
          child: SizedBox(
            width: d,
            height: d,
            child: CustomPaint(
              painter: _PulsePainter(u: u, t: widget.pulse, strength: g),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: g == 0
                      ? RadialGradient(
                          colors: [
                            RateelColors.gold.withValues(alpha: 0.08),
                            RateelColors.gold.withValues(alpha: 0.24),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.lerp(
                              RateelColors.gold.withValues(alpha: 0.14),
                              RateelColors.badgeTop,
                              g,
                            )!,
                            Color.lerp(
                              RateelColors.gold.withValues(alpha: 0.2),
                              RateelColors.amber,
                              g,
                            )!,
                          ],
                        ),
                  border: Border.all(
                    color: Color.lerp(
                      RateelColors.ringLine,
                      RateelColors.goldHighlight,
                      g,
                    )!,
                    width: u * 0.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RateelColors.gold.withValues(
                        alpha: lerpDouble(0.22, 0.45, g)!,
                      ),
                      blurRadius: u * lerpDouble(2, 2.4, g)!,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.6, end: 1.0).animate(a),
                      child: c,
                    ),
                  ),
                  child: CustomPaint(
                    key: ValueKey(widget.glyph),
                    size: Size(d, d),
                    painter: _GlyphPainter(widget.glyph),
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

/// Angular's pulse: a gold ring growing 0 → 1.8u and fading, every 2 s.
class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.u, required this.t, required this.strength});

  final double u;
  final double? t;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final t = this.t;
    if (t == null || strength == 0) return;
    final k = (t / 0.7).clamp(0.0, 1.0);
    final c = size.center(Offset.zero);
    final r = size.width / 2 + u * 1.8 * k;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = RateelColors.amber.withValues(
          alpha: 0.55 * (1 - k) * strength,
        ),
    );
  }

  @override
  bool shouldRepaint(_PulsePainter o) =>
      o.t != t || o.u != u || o.strength != strength;
}

/// Pause, play, restart and back, drawn on a 24-unit grid with the stroke of
/// the approved 06 back arrow (owner, 2026-11-24: icons by Claude, no asset).
class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph);

  final _Glyph glyph;

  @override
  void paint(Canvas canvas, Size size) {
    // The glyph box is 48% of the button (mockup: 3.6u in 7.5u).
    final s = size.width * 0.48 / 24;
    canvas.save();
    canvas.translate(size.width / 2 - 12 * s, size.height / 2 - 12 * s);
    canvas.scale(s);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = RateelColors.closeWhite;
    switch (glyph) {
      case _Glyph.pause:
        final p = Paint()..color = RateelColors.iconCream;
        for (final x in [6.0, 14.4]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, 5, 3.6, 14),
              const Radius.circular(1.4),
            ),
            p,
          );
        }
      case _Glyph.play:
        final tri = Path()
          ..moveTo(8, 5.2)
          ..lineTo(8, 18.8)
          ..lineTo(19, 12)
          ..close();
        canvas.drawPath(tri, Paint()..color = RateelColors.countText);
        canvas.drawPath(
          tri,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..strokeJoin = StrokeJoin.round
            ..color = RateelColors.countText,
        );
      case _Glyph.restart:
        // Open circle (centre 12,12, r 7.5) from 0° clockwise to −47°,
        // arrow head at the top right.
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(12, 12), radius: 7.5),
          0,
          (360 - 47.2) * math.pi / 180,
          false,
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(19.6, 3.6)
            ..lineTo(19.6, 7.9)
            ..lineTo(15.3, 7.9),
          stroke,
        );
      case _Glyph.back:
        // → : back in RTL (as the 06 header).
        canvas.drawLine(const Offset(4, 12), const Offset(20, 12), stroke);
        canvas.drawPath(
          Path()
            ..moveTo(13.5, 5.2)
            ..lineTo(20, 12)
            ..lineTo(13.5, 18.8),
          stroke,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter o) => o.glyph != glyph;
}

/// Route of a lesson: above the whole app (the side rail is hidden during a
/// lesson, owner 2026-11-24). Enters sliding down from the top (500 ms
/// ease-out), leaves sliding out to the right (500 ms ease-in), as Angular.
Route<T> lessonRoute<T>(WidgetBuilder builder) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 500),
  reverseTransitionDuration: const Duration(milliseconds: 500),
  // Above the app's Scaffold: the lesson gets its own Material (text style).
  pageBuilder: (context, a, b) =>
      Material(color: Colors.transparent, child: builder(context)),
  transitionsBuilder: (context, a, b, child) {
    if (a.status == AnimationStatus.reverse) {
      final e = Curves.easeIn.transform(1 - a.value);
      return FractionalTranslation(translation: Offset(e, 0), child: child);
    }
    final t = Curves.easeOut.transform(a.value);
    return FractionalTranslation(translation: Offset(0, t - 1), child: child);
  },
);
