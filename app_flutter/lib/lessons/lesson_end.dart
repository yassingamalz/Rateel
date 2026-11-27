import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../challenges/challenge_data.dart';
import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../core/sounds.dart';
import '../theme/rateel_theme.dart';
import 'lesson_decor.dart';
import 'lesson_widgets.dart';
import 'reading_lesson_page.dart' show ReadMetrics;
import 'test_lesson_page.dart'
    show LessonButton, LessonBtnGlyph, LessonTone, MarkDisc, tintedDivider;

/// Screen 24, end of lesson (owner, 2026-11-27; plan
/// `docs/flutter/screens/24-end-of-lesson.md`, references
/// `24-end-of-lesson/reference-{dark,light}.webp`): over the finished lesson,
/// under a veil, one gold card with the stars, «أحسنت، أكملت الدرس», the
/// numbers (points, right answers, streak) and «متابعة» / «إعادة الدرس».
/// Shown by [LessonShellState.finish] for every kind of lesson.

/// What the learner chose on the card.
enum LessonEndChoice { next, again }

/// What the finished lesson reports to screen 24.
class LessonEndResult {
  const LessonEndResult({
    required this.stars,
    required this.points,
    this.right,
    this.total,
    this.sound = true,
  });

  /// Lesson without questions (video, reading): 3 stars, +10 points.
  const LessonEndResult.done() : this(stars: 3, points: 10);

  /// Lesson with questions: 3 = all right, 2 = at least 70%, 1 = below
  /// (owner, 2026-11-27, Q2).
  factory LessonEndResult.answers({
    required int right,
    required int total,
    required int points,
    bool sound = true,
  }) => LessonEndResult(
    stars: starsFor(right, total),
    points: points,
    right: right,
    total: total,
    sound: sound,
  );

  /// Stars of a lesson with questions.
  static int starsFor(int right, int total) {
    if (total <= 0 || right >= total) return 3;
    return right * 10 >= total * 7 ? 2 : 1;
  }

  /// Stars of a passed test: 3 from 90%, 2 from 70% (the pass mark), else 1.
  static int starsForScore(int score) => score >= 90
      ? 3
      : score >= 70
      ? 2
      : 1;

  final int stars;
  final int points;

  /// Right answers and questions; null for a lesson without questions (the
  /// «إجابات صحيحة» tile is then left out).
  final int? right;
  final int? total;

  /// Play the «passed» sound when the card opens (off when the lesson has
  /// just played it: listening 22, test results 10).
  final bool sound;
}

/// Review aid (screen 24): `?end=3|2|1` opens the end card with that many
/// stars as soon as a lesson opens (demo numbers: +40, 4 / 5).
int? lessonEndReview;

/// Geometry in u (1% of the screen height), measured on
/// `reference-dark.webp` at 1844×853 (u = 8.53 px); card-local offsets.
typedef _M = LessonEndMetrics;

class LessonEndMetrics {
  static const cardW = 117.9;
  static const cardH = 66.6;
  static const cardTop = 23.6; // reference 21.2u: lowered under the 22 header g (title ink to 22.6u)
  static const cardRadius = 3.4;
  static const starsH = 18.5; // earned row asset, 1024×287
  static const starsTop = -0.4;
  static const titleCentre = 21.0;
  static const titleSize = 7.2;
  static const dividerCentre = 27.9;
  static const dividerW = 56.0;
  static const tilesTop = 32.4;
  static const tileH = 14.5;
  static const tileW = 31.0;
  static const tileGap = 4.1;
  static const tileRadius = 2.6;
  static const numberSize = 5.0;
  static const labelSize = 2.9;
  static const iconD = 4.7;
  static const buttonsTop = 52.4;
  static const buttonH = 10.9;
  static const nextW = 39.9; // «متابعة»
  static const againW = 42.2; // «إعادة الدرس»
  static const buttonGap = 4.6;
  // The veil leaves the header and the 02 bar lit (reference): clear down to
  // 20u (under the titles), full from 27u.
  static const veilFrom = 20.0;
  static const veilTo = 27.0;
}

// Star geometry inside the owner's assets (px), measured with alpha > 128.
const _earnedRowW = 1024.0, _earnedRowH = 287.0;
// Cuts between the three stars of the earned row (each slice pops alone).
const _earnedCuts = [0.0, 374.5, 652.5, 1024.0];
const _earnedCentres = [
  Offset(263, 178),
  Offset(513.5, 144),
  Offset(763.5, 176),
];
const _emptyRowW = 1024.0, _emptyRowH = 231.0;
// Stars of the empty row: centre and width (px).
const _emptyStars = [
  (Offset(289.5, 137), 163.0),
  (Offset(516, 107), 202.0),
  (Offset(742, 137), 163.0),
];
// Single earned star: core box 41–567 × 13–564 of 609×578.
const _oneW = 609.0, _oneH = 578.0;
const _oneCore = Rect.fromLTRB(41, 13, 567, 564);

class LessonEndOverlay extends StatefulWidget {
  const LessonEndOverlay({
    super.key,
    required this.result,
    required this.light,
    required this.onChoice,
  });

  final LessonEndResult result;
  final double light;
  final ValueChanged<LessonEndChoice> onChoice;

  @override
  State<LessonEndOverlay> createState() => _LessonEndOverlayState();
}

class _LessonEndOverlayState extends State<LessonEndOverlay>
    with SingleTickerProviderStateMixin {
  // One entry sequence (ms of 1700): veil 0–300, card 150–750, stars from
  // 500 every 120, title 600, tiles from 800 every 100 (points count up to
  // 1400), buttons from 1100 every 100. Stops at the end: nothing endless.
  static const _ms = 1700.0;
  late final _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  bool _chosen = false;

  @override
  void initState() {
    super.initState();
    _in.forward();
    if (widget.result.sound) Sounds.passed();
    Haptics.success();
    for (var i = 0; i < widget.result.stars; i++) {
      Future<void>.delayed(Duration(milliseconds: 560 + 120 * i), () {
        if (mounted) Haptics.tick();
      });
    }
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  void _choose(LessonEndChoice c) {
    if (_chosen) return;
    _chosen = true;
    widget.onChoice(c);
  }

  /// 0 → 1 between [from] and [from] + [len] ms of the entry.
  double _t(double from, double len, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_in.value * _ms - from) / len).clamp(0.0, 1.0));

  Widget _appear(double from, Widget child, {double len = 400}) =>
      AnimatedBuilder(
        animation: _in,
        child: child,
        builder: (context, child) {
          final t = _t(from, len);
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 10),
              child: child,
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final p = LessonPal(widget.light);
    return LayoutBuilder(
      builder: (context, box) {
        final u = box.maxHeight / 100;
        final veil = p.c(RateelColors.lessonVeil, RateelColors.readLBgEdge);
        final veilA = veil.a * p.d(1, 0.62);
        return Stack(
          fit: StackFit.expand,
          children: [
            // Veil over the lesson (no blur: PERFORMANCE.md); a tap on it does
            // nothing, the learner chooses on the card.
            AnimatedBuilder(
              key: const ValueKey('veil'),
              animation: _in,
              builder: (context, _) {
                final t = _t(0, 300, Curves.easeOut);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          veil.withValues(alpha: 0),
                          veil.withValues(alpha: veilA * t),
                        ],
                        stops: [
                          LessonEndMetrics.veilFrom / 100,
                          LessonEndMetrics.veilTo / 100,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              key: const ValueKey('card'),
              left: (box.maxWidth - u * LessonEndMetrics.cardW) / 2,
              top: u * LessonEndMetrics.cardTop,
              width: u * LessonEndMetrics.cardW,
              height: u * LessonEndMetrics.cardH,
              child: AnimatedBuilder(
                animation: _in,
                builder: (context, child) {
                  final t = _t(150, 600);
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * u * 3.5),
                      child: child,
                    ),
                  );
                },
                child: _card(p, u),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _card(LessonPal p, double u) {
    final r = widget.result;
    final tiles = <Widget>[
      // RTL: the streak on the right, the answers, the points on the left.
      if (dailyStreak.value > 0)
        _Tile(
          u: u,
          p: p,
          icon: Image.asset(
            'assets/ui/test/flame.webp',
            width: u * _M.iconD,
            height: u * _M.iconD,
          ),
          value: '${dailyStreak.value}',
          label: 'يوم متتالي',
        ),
      if (r.right != null && r.total != null)
        _Tile(
          u: u,
          p: p,
          icon: MarkDisc(u: u, ok: true, d: _M.iconD * 0.92),
          value: '\u2066${r.right} / ${r.total}\u2069',
          label: 'إجابات صحيحة',
        ),
      _Tile(
        u: u,
        p: p,
        icon: Image.asset(
          'assets/ui/test/star_coin_gold.webp',
          width: u * _M.iconD,
          height: u * _M.iconD,
        ),
        value: null,
        points: r.points,
        animation: _in,
        countFrom: 800,
        label: 'نقطة',
      ),
    ];
    return RepaintBoundary(
      child: CustomPaint(
        painter: GoldCardPainter(p, u, u * _M.cardRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(u * _M.cardRadius),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Faint lattice at the bottom of the card, as the 22 card.
              Positioned.fill(
                child: LatticeField(
                  p: p,
                  u: u,
                  cell: ReadMetrics.cell,
                  opacity: p.d(0.2, 0.4),
                  mask: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xFF000000)],
                    stops: [0.55, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: u * _M.starsTop,
                height: u * _M.starsH,
                child: Center(
                  child: _Stars(u: u, stars: r.stars, entry: _in, ms: _ms),
                ),
              ),
              Positioned(
                left: u * 4,
                right: u * 4,
                top: u * (_M.titleCentre - _M.titleSize),
                height: u * _M.titleSize * 2,
                child: _appear(
                  600,
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'أحسنت، أكملت الدرس',
                        textDirection: TextDirection.rtl,
                        style: readex(
                          u * _M.titleSize,
                          weight: 700,
                          color: p.c(
                            RateelColors.leaderText,
                            RateelColors.readLInk,
                          ),
                        ).copyWith(height: 1.2),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (u * _M.cardW - u * _M.dividerW) / 2,
                width: u * _M.dividerW,
                top: u * (_M.dividerCentre - 2),
                height: u * 4,
                child: _appear(
                  700,
                  tintedDivider(p, GoldDivider(u: u, diamond: 1.15)),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: u * _M.tilesTop,
                height: u * _M.tileH,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    for (final (i, t) in tiles.indexed) ...[
                      if (i > 0) SizedBox(width: u * _M.tileGap),
                      SizedBox(
                        width: u * _M.tileW,
                        height: u * _M.tileH,
                        child: _appear(800 + 100.0 * i, t),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: u * _M.buttonsTop,
                height: u * _M.buttonH,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    SizedBox(
                      width: u * _M.nextW,
                      child: _appear(
                        1100,
                        LessonButton(
                          u: u,
                          p: p,
                          label: 'متابعة',
                          glyph: LessonBtnGlyph.chevron,
                          height: _M.buttonH,
                          onTap: () => _choose(LessonEndChoice.next),
                        ),
                      ),
                    ),
                    SizedBox(width: u * _M.buttonGap),
                    SizedBox(
                      width: u * _M.againW,
                      child: _appear(
                        1200,
                        LessonButton(
                          u: u,
                          p: p,
                          label: 'إعادة الدرس',
                          glyph: LessonBtnGlyph.replay,
                          tone: LessonTone.green,
                          height: _M.buttonH,
                          onTap: () => _choose(LessonEndChoice.again),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The three stars: with 3 the owner's earned row (arc and sparkles), cut in
/// three slices that pop one after the other; with 1–2 the empty row with
/// the earned single stars popping over its first stars (right to left).
class _Stars extends StatelessWidget {
  const _Stars({
    required this.u,
    required this.stars,
    required this.entry,
    required this.ms,
  });

  final double u;
  final int stars;
  final Animation<double> entry;
  final double ms;

  double _pop(int i) {
    final t = ((entry.value * ms - (500 + 120.0 * i)) / 300).clamp(0.0, 1.0);
    // 0 → 1.15 → 1.
    if (t < 0.6) return Curves.easeOut.transform(t / 0.6) * 1.15;
    return 1.15 - 0.15 * Curves.easeInOut.transform((t - 0.6) / 0.4);
  }

  @override
  Widget build(BuildContext context) {
    final h = u * LessonEndMetrics.starsH;
    final s = h / _earnedRowH; // asset px → screen
    final w = _earnedRowW * s;
    return SizedBox(
      width: w,
      height: h,
      child: stars >= 3 ? _earned(s, w, h) : _partial(s, w, h),
    );
  }

  Widget _earned(double s, double w, double h) => Stack(
    children: [
      for (var i = 0; i < 3; i++)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: entry,
            builder: (context, child) {
              final k = _pop(i);
              if (k == 0) return const SizedBox.shrink();
              return Opacity(
                opacity: k.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: k,
                  origin: _earnedCentres[i] * s - Offset(w / 2, h / 2),
                  child: child,
                ),
              );
            },
            child: ClipRect(
              clipper: _SliceClip(_earnedCuts[i] * s, _earnedCuts[i + 1] * s),
              child: Image.asset(
                'assets/ui/end_of_lesson/stars_row_earned.webp',
                width: w,
                height: h,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
    ],
  );

  Widget _partial(double s, double w, double h) {
    // The empty row's big star as large as the earned row's (core without
    // the glow, ≈ 215 px), centred, bottoms aligned.
    final sm = 215 * s / _emptyStars[1].$2;
    final ew = _emptyRowW * sm, eh = _emptyRowH * sm;
    final left = (w - ew) / 2;
    final top = 264 * s - 207 * sm;
    final base = Offset(left, top);
    // Earned stars fill from the right (RTL): the order on screen is
    // right → left, so star 2, then 1, then 0 of the row.
    final order = [2, 1, 0];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: left,
          top: top,
          width: ew,
          height: eh,
          child: Image.asset(
            'assets/ui/end_of_lesson/stars_row_empty.webp',
            fit: BoxFit.fill,
          ),
        ),
        for (var k = 0; k < stars; k++)
          Builder(
            builder: (context) {
              final (c, sw) = _emptyStars[order[k]];
              final scale = sw * sm / _oneCore.width;
              final cw = _oneW * scale, ch = _oneH * scale;
              final centre = base + c * sm;
              final coreC = _oneCore.center * scale;
              return Positioned(
                left: centre.dx - coreC.dx,
                top: centre.dy - coreC.dy,
                width: cw,
                height: ch,
                child: AnimatedBuilder(
                  animation: entry,
                  builder: (context, child) {
                    final p = _pop(k);
                    if (p == 0) return const SizedBox.shrink();
                    return Opacity(
                      opacity: p.clamp(0.0, 1.0),
                      child: Transform.scale(scale: p, child: child),
                    );
                  },
                  child: Image.asset(
                    'assets/ui/end_of_lesson/star_earned.webp',
                    fit: BoxFit.fill,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SliceClip extends CustomClipper<Rect> {
  _SliceClip(this.from, this.to);

  final double from;
  final double to;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(from, -size.height, to, size.height * 2);

  @override
  bool shouldReclip(_SliceClip o) => o.from != from || o.to != to;
}

/// A number tile of the card: icon and number on one line, label under it,
/// glass with a thin gold rim (reference).
class _Tile extends StatelessWidget {
  const _Tile({
    required this.u,
    required this.p,
    required this.icon,
    required this.value,
    required this.label,
    this.points,
    this.animation,
    this.countFrom = 0,
  });

  final double u;
  final LessonPal p;
  final Widget icon;
  final String? value;
  final String label;

  /// Points, counted up from 0 with [animation] (600 ms from [countFrom]).
  final int? points;
  final Animation<double>? animation;
  final double countFrom;

  @override
  Widget build(BuildContext context) {
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    final r = u * _M.tileRadius;
    final numberStyle = readex(
      u * _M.numberSize,
      weight: 700,
      color: ink,
    ).copyWith(height: 1);
    Widget number(String v) =>
        Text(v, textDirection: TextDirection.ltr, style: numberStyle);
    final anim = animation;
    final pts = points;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        color: p
            .c(RateelColors.testRowFill, RateelColors.testLRowFill)
            .withValues(alpha: p.d(0.55, 0.9)),
      ),
      child: CustomPaint(
        foregroundPainter: GradientRimPainter(
          width: math.max(1.0, u * 0.24),
          radius: r,
          top: p.c(RateelColors.readCardRim, RateelColors.readLCardRimSide),
          bottom: p.c(
            RateelColors.readCardRimSide,
            RateelColors.readLCardRimSide,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: u * 1.5),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: [
                    icon,
                    SizedBox(width: u * 2.0),
                    if (pts != null && anim != null)
                      AnimatedBuilder(
                        animation: anim,
                        builder: (context, _) {
                          final t = Curves.easeOut.transform(
                            ((anim.value * 1700 - countFrom) / 600).clamp(
                              0.0,
                              1.0,
                            ),
                          );
                          return number('+${(pts * t).round()}');
                        },
                      )
                    else
                      number(value ?? ''),
                  ],
                ),
                SizedBox(height: u * 1.4),
                Text(
                  label,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  style: readex(
                    u * _M.labelSize,
                    weight: 400,
                    color: ink.withValues(alpha: 0.85),
                  ).copyWith(height: 1.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
