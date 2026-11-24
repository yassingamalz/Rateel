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
    this.waiting = false,
    this.onPlay,
  });

  /// The lesson stopped by itself and waits for the learner (screen 07: end
  /// of a video section): the button shows the gold play with its pulse,
  /// without the menu and the veil; a tap calls [onPlay].
  final bool waiting;
  final VoidCallback? onPlay;

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

  // Gold of the button while [LessonShell.waiting].
  late final _wait = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: widget.waiting ? 1 : 0,
  );

  @override
  void initState() {
    super.initState();
    if (widget.waiting) _pulse.repeat();
  }

  @override
  void didUpdateWidget(LessonShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.waiting == widget.waiting) return;
    if (widget.waiting) {
      _wait.forward();
      _pulse.repeat();
    } else {
      _wait.reverse();
      if (!paused) {
        _pulse.stop();
        _pulse.value = 0;
      }
    }
  }

  // True while the completion plays: controls and back are blocked
  // (critic v1 #6).
  bool _locked = false;

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
      if (!widget.waiting) {
        _pulse.stop();
        _pulse.value = 0;
      }
    }
    widget.onPausedChanged?.call(p);
  }

  /// The lesson is complete: the light runs along the full capsule, with a
  /// milestone haptic. Completes when the light has passed.
  /// Blocks the controls and the back button (the lesson is finishing).
  void lock() {
    setPaused(false);
    setState(() => _locked = true);
  }

  Future<void> celebrate() async {
    lock();
    Haptics.milestone();
    await _sweep.forward(from: 0);
  }

  @override
  void dispose() {
    _menu.dispose();
    _wait.dispose();
    _pulse.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // Android back toggles the pause menu; nothing while the controls are
        // hidden or the completion plays (critic v1 #7, #6).
        if (didPop || _locked || !widget.controlsVisible) return;
        setPaused(!paused);
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
                    onTap: () {
                      Haptics.tap();
                      setPaused(false);
                    },
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
                  ignoring: !widget.controlsVisible || _locked,
                  child: LessonTopBar(
                    u: u,
                    step: widget.step,
                    total: widget.total,
                    menu: _menu,
                    wait: _wait,
                    pulse: _pulse,
                    sweep: _sweep,
                    onToggle: () {
                      if (widget.waiting && !paused && widget.onPlay != null) {
                        widget.onPlay!();
                      } else {
                        setPaused(!paused);
                      }
                    },
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
/// approved mockup v2, then «slightly larger» (owner, 2026-11-24); after the
/// phone test the buttons as large as Angular's (64 px on a 412 dp phone =
/// 15.5u) and the capsule only a little larger (owner, 2026-11-24).
class LessonBarMetrics {
  LessonBarMetrics._();
  static const margin = 3.0; // from the top, left and right edges
  static const button = 15.5; // pause / back / restart circles
  static const gap = 2.8; // between the circles
  static const capsuleW = 46.0;
  static const capsuleH = 7.0;
  static const number = 3.6; // «n/N»
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
    this.wait = kAlwaysDismissedAnimation,
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

  /// 1 while the lesson waits for the learner: gold play with the pulse.
  final Animation<double> wait;
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
    // Buttons keep their drawn size; the tap area grows to 48 dp on small
    // screens (critic v1 #8).
    final e = _GlassButton.extra(u);
    // Items slide out from under the pause button (Angular: 20 px, 300 ms).
    Widget item(int k, String label, _Glyph g, VoidCallback onTap) {
      return AnimatedBuilder(
        key: ValueKey('item$k'),
        animation: menu,
        builder: (context, child) {
          final t = Curves.easeOutCubic.transform(menu.value);
          final x = m + (b + LessonBarMetrics.gap) * k * t;
          return Positioned(
            top: u * m - e,
            right: u * x - e,
            child: IgnorePointer(
              ignoring: menu.value < 0.5,
              child: Opacity(opacity: t, child: child),
            ),
          );
        },
        child: _GlassButton(u: u, semantics: label, glyph: g, onTap: onTap),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Capsule, vertically centred on the button.
        Positioned(
          key: const ValueKey('capsule'),
          // Whole pixels: the 1 px rim stays crisp (critic v2 N2).
          top: (u * (m + b / 2 - LessonBarMetrics.capsuleH / 2))
              .roundToDouble(),
          left: (u * m).roundToDouble(),
          width: (u * LessonBarMetrics.capsuleW).roundToDouble(),
          height: (u * LessonBarMetrics.capsuleH).roundToDouble(),
          // Angular: the open menu's veil covers the progress bar, so the
          // capsule fades out while paused (owner, 2026-11-24).
          child: AnimatedBuilder(
            animation: menu,
            builder: (context, child) => Opacity(
              opacity: 1 - Curves.easeOut.transform(menu.value),
              child: child,
            ),
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
        ),
        item(2, 'من البداية', _Glyph.restart, onRestart),
        item(1, 'رجوع', _Glyph.back, onBack),
        Positioned(
          key: const ValueKey('pause'),
          top: u * m - e,
          right: u * m - e,
          child: AnimatedBuilder(
            animation: Listenable.merge([menu, wait, pulse]),
            builder: (context, _) {
              final g = math.max(menu.value, wait.value);
              return _GlassButton(
                u: u,
                semantics: g > 0.5 ? 'متابعة' : 'إيقاف مؤقت',
                glyph: g > 0.5 ? _Glyph.play : _Glyph.pause,
                goldness: Curves.easeOut.transform(g),
                pulse: g > 0 ? pulse.value : null,
                onTap: onToggle,
              );
            },
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
    // Dark glass (card gradient).
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.cardTop, RateelColors.cardMid],
        ).createShader(Offset.zero & size),
    );
    // Inset shadow on the empty glass, under the gold (critic v2 N1)
    // (CSS inset 0 0.2u 0.5u black 45%): a thin shade at the
    // top, a hint at the bottom.
    canvas.drawPath(
      (Path()
        ..fillType = PathFillType.evenOdd
        ..addRect((Offset.zero & size).inflate(u * 3))
        ..addRRect(rr.shift(Offset(0, u * 0.2)))),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.25),
    );
    final fw = size.width * share;
    final fill = Rect.fromLTWH(size.width - fw, 0, fw, size.height);
    if (fw > 0) {
      // Gold glow spilling into the empty part (mockup: 1.6u, 45%).
      canvas.drawRect(
        fill,
        Paint()
          ..color = RateelColors.gold.withValues(alpha: 0.45)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.8),
      );
      // Gold fill from the right.
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
      // Top sheen, relative to the fill.
      canvas.save();
      canvas.clipRect(fill);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            fill.left + fw * 0.04,
            size.height * 0.1,
            fw * 0.92,
            size.height * 0.27,
          ),
          Radius.circular(size.height * 0.14),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
      canvas.restore();
      // Soft light at the leading edge (2.2u, fading into the gold), also at
      // 16/16 on the left end.
      final lead = Rect.fromLTWH(fill.left, 0, u * 2.2, size.height);
      canvas.drawRect(
        lead.intersect(fill),
        Paint()
          ..shader = LinearGradient(
            colors: [
              RateelColors.lessonBarLight.withValues(alpha: 0.9),
              RateelColors.lessonBarLight.withValues(alpha: 0),
            ],
          ).createShader(lead),
      );
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
        weight: 500,
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
        weight: 500,
        color: RateelColors.countText,
      ),
    );
    final at = Offset(
      (size.width - light.width) / 2,
      (size.height - light.height) / 2,
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
    // Rim: thin (mockup 1 px at 853), in u.
    canvas.drawRRect(
      rr.deflate(math.max(1.0, u * 0.12) / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, u * 0.12)
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
/// lesson is paused, with a static halo and Angular's pulse.
class _GlassButton extends StatefulWidget {
  const _GlassButton({
    required this.u,
    required this.semantics,
    required this.glyph,
    required this.onTap,
    this.goldness = 0,
    this.pulse,
  });

  final double u;
  final String semantics;
  final _Glyph glyph;
  final double goldness;
  final double? pulse;
  final VoidCallback onTap;

  /// Extra tap margin around the drawn circle, so the target is ≥ 48 dp.
  static double extra(double u) =>
      math.max(0, (48 - u * LessonBarMetrics.button) / 2);

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final d = u * LessonBarMetrics.button;
    final e = _GlassButton.extra(u);
    return Semantics(
      button: true,
      label: widget.semantics,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) {
          setState(() => _down = false);
          Haptics.tap();
          widget.onTap();
        },
        child: Padding(
          padding: EdgeInsets.all(e),
          child: AnimatedScale(
            scale: _down ? 0.92 : 1,
            duration: const Duration(milliseconds: 120),
            child: SizedBox(
              width: d,
              height: d,
              child: CustomPaint(
                painter: _GlassPainter(
                  u: u,
                  goldness: widget.goldness,
                  pulse: widget.pulse,
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

/// The glass circle: glow outside the circle only (critic v1 #1, the glow must
/// not show through the glass), radial gold 8% → 24%, ring `ringLine`;
/// cross-fades to the gold disc with a static 1.2u halo and the pulse.
class _GlassPainter extends CustomPainter {
  _GlassPainter({required this.u, required this.goldness, this.pulse});

  final double u;
  final double goldness;
  final double? pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final g = goldness;
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final outside = (Path()
      ..fillType = PathFillType.evenOdd
      ..addRect((Offset.zero & size).inflate(u * 6))
      ..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.save();
    canvas.clipPath(outside);
    // Outer glow: gold 22% sigma 1u (glass) → 45% sigma 1.2u (gold).
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = RateelColors.gold.withValues(
          alpha: lerpDouble(0.22, 0.45, g)!,
        )
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          u * lerpDouble(1.0, 1.2, g)!,
        ),
    );
    if (g > 0) {
      // Static halo ring 1.2u, amber 25% (mockup).
      canvas.drawCircle(
        c,
        r + u * 1.2 * LessonBarMetrics.button / 9,
        Paint()..color = RateelColors.amber.withValues(alpha: 0.25 * g),
      );
      // Angular pulse: ring 0 → 1.8u, alpha 0.7 → 0, every 2 s.
      final t = pulse;
      if (t != null) {
        final k = (t / 0.7).clamp(0.0, 1.0);
        canvas.drawCircle(
          c,
          r + u * 1.8 * LessonBarMetrics.button / 9 * k,
          Paint()
            ..color = RateelColors.amber.withValues(alpha: 0.7 * (1 - k) * g),
        );
      }
    }
    canvas.restore();
    final disc = Rect.fromCircle(center: c, radius: r);
    // Glass fill (radial, CSS «circle» = farthest corner: radius 0.707).
    if (g < 1) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            radius: 0.707,
            colors: [
              RateelColors.gold.withValues(alpha: 0.08 * (1 - g)),
              RateelColors.gold.withValues(alpha: 0.24 * (1 - g)),
            ],
          ).createShader(disc),
      );
    }
    if (g > 0) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              RateelColors.badgeTop.withValues(alpha: g),
              RateelColors.amber.withValues(alpha: g),
            ],
          ).createShader(disc),
      );
    }
    // Ring.
    canvas.drawCircle(
      c,
      r - u * 0.1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.2
        ..color = Color.lerp(
          RateelColors.ringLine,
          RateelColors.goldHighlight,
          g,
        )!,
    );
  }

  @override
  bool shouldRepaint(_GlassPainter o) =>
      o.u != u || o.goldness != goldness || o.pulse != pulse;
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
