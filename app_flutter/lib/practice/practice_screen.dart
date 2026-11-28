import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/app_settings.dart';
import '../core/screen_decor.dart';
import '../lessons/lesson_decor.dart';
import '../lessons/test_lesson_page.dart' show LessonButton, LessonBtnGlyph;
import '../theme/rateel_theme.dart';
import 'practice_session.dart';
import 'practice_store.dart';

/// Screen 31, daily practice (owner's references
/// `screens/31-daily-practice/reference-a-practice-{dark,light}.webp`, plan
/// `screens/31-daily-practice.md`). Opened by the rail item «التدريب».
///
/// Geometry measured on the 1843×853 reference: sizes in u (1 % of the
/// height); places and box widths along x in [PracMetrics.ux] units of the
/// content width (reference content box 0–1686 px = 197.66u, as screen 29),
/// so wider phones keep the reference's proportions.
class PracMetrics {
  PracMetrics._();

  static const refW = 1686.0; // content box of the reference, px
  static const refU = 8.53;

  /// Reference px along x → fraction of the content width.
  static double fx(double px) => px / refW;

  // Header (owner Q1 = as the reference, STYLE-CONFLICTS P31-8).
  static const axis = 896.0; // header axis, px
  static const archW = 97.6;
  static const archH = 22.0;
  static const archTop = 0.15;
  static const emblemW = 12.4;
  static const emblemTop = 1.7;
  static const titleCy = 17.5;
  static const titleSize = 9.6;
  static const titleCx =
      925.0; // px: the reference's title sits right of the axis
  static const titleDividerCy = 25.2;
  static const titleDividerW = 37.9;
  static const mosqueLeft = 191.0; // px
  static const mosqueTop = 5.6;
  static const mosqueW = 38.8;
  static const crescentRight = 30.3; // from the content's right edge, u
  static const crescentTop = 8.3;
  static const crescentW = 10.3;
  static const crescentH = 9.4;

  // Week panel (px on x, u on y).
  static const panelX0 = 109.0, panelX1 = 536.0;
  static const panelTop = 29.66, panelBottom = 92.38;
  static const panelRadius = 2.8;
  static const panelTitleCy = 35.4;
  static const panelTitleSize = 5.55;
  // The reference's texts sit right of the box centres (px).
  static const panelTextDx = 12.0, streakDx = 7.0, discDx = 3.0;
  static const cardTextDx = 16.0, tileTextDx = 4.0;
  static const panelDividerCy = 41.4;
  static const panelDividerW = 25.0;
  static const row1Cy = 49.9, row1D = 8.9;
  static const row2Cy = 60.4, row2D = 8.2;
  static const dayStep = 92.7; // px between disc centres
  static const separatorY = 68.3;
  static const separatorInset = 40.0; // px
  static const flameCy = 73.6, flameH = 7.0;
  static const streakCy = 80.5, streakSize = 4.4;
  static const streakDividerCy = 85.9, streakDividerW = 24.4;

  // Session card.
  static const cardX0 = 562.0, cardX1 = 1555.0;
  static const cardTop = 29.43, cardBottom = 92.26;
  static const cardRadius = 2.8;
  static const cardTitleCy = 35.2, cardTitleSize = 7.3;
  static const cardSubCy = 42.1, cardSubSize = 3.95;
  static const cardDividerCy = 47.0, cardDividerW = 32.1;
  static const tiles = [(1223.0, 1511.0), (922.0, 1201.0), (609.0, 897.0)];
  static const tileTop = 49.7, tileBottom = 75.4;
  static const tileRadius = 2.9;
  static const tileGlyphCy = 54.8, tileGlyphH = 6.0;
  static const tileNameCy = 61.4, tileNameSize = 4.6;
  static const tileDividerCy = 65.7, tileDividerW = 19.0;
  static const tileCountCy = 69.2, tileCountSize = 3.8;
  static const buttonX0 = 838.0, buttonX1 = 1255.0;
  static const buttonCy = 84.1, buttonH = 10.9, buttonText = 5.0;
  static const ornaments = [714.0, 1392.0];
  static const ornamentW = 17.3;
}

/// Review aid: `?practiceBg=30` uses the light background of 30 in the light
/// theme (default until the owner's light version of the 14 background, A1).
String practiceLightBg = 'assets/ui/splash/background_light.webp';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..forward();

  /// Today's disc filling after a practice (350 ms + check pop).
  late final AnimationController _done = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: 1,
  );

  /// Review aid `?practiceSession=1`: the session opens on start.
  static bool openOnStart = Uri.base.queryParameters['practiceSession'] == '1';

  @override
  void initState() {
    super.initState();
    AppSettings.light.addListener(_rebuild);
    PracticeStore.days.addListener(_rebuild);
    if (openOnStart) {
      openOnStart = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppSettings.light.removeListener(_rebuild);
    PracticeStore.days.removeListener(_rebuild);
    _entry.dispose();
    _done.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final before = PracticeStore.doneToday;
    final done = await Navigator.of(context).push<bool>(practiceSessionRoute());
    if (!mounted) return;
    if (done == true && !before) _done.forward(from: 0);
  }

  Animation<double> _interval(double a, double b) => CurvedAnimation(
    parent: _entry,
    curve: Interval(a, b, curve: Curves.easeOutCubic),
  );

  Widget _rise(Animation<double> a, Widget child) => AnimatedBuilder(
    animation: a,
    child: RepaintBoundary(child: child),
    builder: (context, child) => Opacity(
      opacity: a.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, (1 - a.value) * 18),
        child: child,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final p = LessonPal(AppSettings.light.value ? 1 : 0);
      final w = box.maxWidth;
      final u = box.maxHeight / 100;
      double x(double px) => w * PracMetrics.fx(px);
      final header = _interval(0, 0.55);
      final panel = _interval(0.15, 0.75);
      final card = _interval(0.2, 0.8);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Background: the 14 background (also 23), the reference's whole decor.
          Positioned.fill(
            child: RepaintBoundary(
              child: p.t > 0.5
                  ? Image(image: AssetImage(practiceLightBg), fit: BoxFit.fill)
                  : const Image(
                      image: AssetImage(
                        'assets/ui/coming_soon/background.webp',
                      ),
                      fit: BoxFit.fill,
                      color: RateelColors.soonBgTone,
                      colorBlendMode: BlendMode.modulate,
                    ),
            ),
          ),
          Positioned.fill(
            child: _rise(header, _Header(p: p, u: u, w: w)),
          ),
          Positioned(
            left: x(PracMetrics.panelX0),
            width: x(PracMetrics.panelX1) - x(PracMetrics.panelX0),
            top: u * PracMetrics.panelTop,
            height: u * (PracMetrics.panelBottom - PracMetrics.panelTop),
            child: _rise(panel, _WeekPanel(p: p, u: u, x: x, done: _done)),
          ),
          Positioned(
            left: x(PracMetrics.cardX0),
            width: x(PracMetrics.cardX1) - x(PracMetrics.cardX0),
            top: u * PracMetrics.cardTop,
            height: u * (PracMetrics.cardBottom - PracMetrics.cardTop),
            child: _rise(
              card,
              _SessionCard(p: p, u: u, x: x, entry: _entry, onStart: _start),
            ),
          ),
        ],
      );
    },
  );
}

/// Text centred on a horizontal line at [cy] (u), optically: Readex sets
/// Arabic low in its line box, so the box is lifted by 0.08 × size.
Widget _centredText(
  String text,
  TextStyle style, {
  required double left,
  required double width,
  required double cy,
  required double u,
}) {
  final h = style.fontSize! * 2;
  return Positioned(
    left: left,
    width: width,
    top: u * cy - h / 2 - style.fontSize! * 0.08,
    height: h,
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: style.copyWith(height: 1.0),
      ),
    ),
  );
}

Color _ink(LessonPal p) => p.c(RateelColors.pracInk, RateelColors.pracLInk);

class _Header extends StatelessWidget {
  const _Header({required this.p, required this.u, required this.w});

  final LessonPal p;
  final double u;
  final double w;

  @override
  Widget build(BuildContext context) {
    final cx = w * PracMetrics.fx(PracMetrics.axis);
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Header arch of 03/12 (standard asset), flatter as the reference.
          Positioned(
            left: cx - u * PracMetrics.archW / 2,
            top: u * PracMetrics.archTop,
            width: u * PracMetrics.archW,
            height: u * PracMetrics.archH,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.55, 1.0],
                colors: [Color(0xFF000000), Color(0x00000000)],
              ).createShader(r),
              child: SvgPicture.asset(
                'assets/ui/decor/header_arch.svg',
                fit: BoxFit.fill,
                colorFilter: p.t > 0.5
                    ? const ColorFilter.mode(
                        RateelColors.readLCopper,
                        BlendMode.srcIn,
                      )
                    : null,
              ),
            ),
          ),
          Positioned(
            left: w * PracMetrics.fx(PracMetrics.mosqueLeft),
            top: u * PracMetrics.mosqueTop,
            width: u * PracMetrics.mosqueW,
            height: u * PracMetrics.mosqueW * 542 / 900,
            child: Opacity(
              opacity: p.t > 0.5 ? 1 : 0.83,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.66, 0.86],
                  colors: [Color(0xFF000000), Color(0x00000000)],
                ).createShader(r),
                child: Image.asset(
                  p.t > 0.5
                      ? 'assets/ui/decor/mosque_light.webp'
                      : 'assets/ui/decor/mosque.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            right: u * PracMetrics.crescentRight,
            top: u * PracMetrics.crescentTop,
            width: u * PracMetrics.crescentW,
            height: u * PracMetrics.crescentH,
            child: SvgPicture.asset(
              'assets/ui/decor/crescent_star.svg',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: cx - u * PracMetrics.emblemW / 2,
            top: u * PracMetrics.emblemTop,
            width: u * PracMetrics.emblemW,
            height: u * PracMetrics.emblemW * 322 / 312,
            child: _Emblem(p: p),
          ),
          _centredText(
            'التدريب اليومي',
            readex(
              u * PracMetrics.titleSize,
              weight: 700,
              color: p.c(RateelColors.pracTitle, RateelColors.pracLTitle),
            ).copyWith(
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.35 * (1 - p.t)),
                  blurRadius: u * 0.6,
                  offset: Offset(0, u * 0.25),
                ),
              ],
            ),
            left: w * PracMetrics.fx(PracMetrics.titleCx) - u * 50,
            width: u * 100,
            cy: PracMetrics.titleCy,
            u: u,
          ),
          Positioned(
            left: cx - u * PracMetrics.titleDividerW / 2,
            top: u * (PracMetrics.titleDividerCy - 2),
            width: u * PracMetrics.titleDividerW,
            height: u * 4,
            child: GoldDivider(u: u, diamond: 1.3),
          ),
        ],
      ),
    );
  }
}

/// The splash emblem; light theme: its centre filled green (30, emblem B).
class _Emblem extends StatelessWidget {
  const _Emblem({required this.p});

  final LessonPal p;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (p.t > 0)
        Opacity(
          opacity: p.t,
          child: Image.asset(
            'assets/ui/splash/emblem_inner.webp',
            fit: BoxFit.contain,
            color: const Color(0xFF0B5A2B),
          ),
        ),
      Image.asset('assets/ui/splash/emblem.webp', fit: BoxFit.contain),
    ],
  );
}

/// Glass panel / tile of the reference (no app standard: P31-1, P31-4): fill lit
/// from the top, rim lighter at the top, a band of ogee lattice at the bottom.
class _GlassBox extends StatelessWidget {
  const _GlassBox({
    required this.p,
    required this.u,
    required this.radius,
    required this.tile,
    required this.child,
    this.band = 9.0,
  });

  final LessonPal p;
  final double u;
  final double radius;
  final bool tile;
  final double band;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final r = u * radius;
    return CustomPaint(
      painter: _GlassPainter(p: p, u: u, radius: r, tile: tile),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: u * band,
              child: _Band(p: p, u: u),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  _GlassPainter({
    required this.p,
    required this.u,
    required this.radius,
    required this.tile,
  });

  final LessonPal p;
  final double u;
  final double radius;
  final bool tile;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    // Soft shadow under the box.
    canvas.drawRRect(
      rr.shift(Offset(0, u * 0.4)),
      Paint()
        ..color = p
            .c(Colors.black, const Color(0xFF8A6A4A))
            .withValues(alpha: p.d(0.35, 0.14))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.2),
    );
    final fill = tile
        ? [
            p.c(RateelColors.pracTileTop, RateelColors.pracLTileTop),
            p.c(RateelColors.pracTileMid, RateelColors.pracLTileBottom),
            p.c(RateelColors.pracTileBottom, RateelColors.pracLTileBottom),
          ]
        : [
            p.c(RateelColors.pracPanelTop, RateelColors.pracLPanel),
            p.c(RateelColors.pracPanelMid, RateelColors.pracLPanel),
            p.c(RateelColors.pracPanelBottom, RateelColors.pracLPanel),
          ];
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: fill,
          stops: const [0, 0.3, 1],
        ).createShader(rect),
    );
    final rimW = u * p.d(tile ? 0.3 : 0.35, 0.24);
    final rim = tile
        ? [
            p.c(RateelColors.pracTileRimTop, RateelColors.pracLTileRim),
            p.c(RateelColors.pracTileRimSide, RateelColors.pracLTileRim),
            p.c(RateelColors.pracTileRimSide, RateelColors.pracLTileRim),
          ]
        : [
            p.c(RateelColors.pracPanelRimTop, RateelColors.pracLPanelRim),
            p.c(RateelColors.pracPanelRimSide, RateelColors.pracLPanelRim),
            p.c(RateelColors.pracPanelRimBottom, RateelColors.pracLPanelRim),
          ];
    canvas.drawRRect(
      rr.deflate(rimW / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rimW
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: rim,
          stops: const [0, 0.25, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassPainter o) =>
      o.p.t != p.t || o.u != u || o.radius != radius || o.tile != tile;
}

/// Ogee lattice band along the bottom (03 card bottoms, `card_pattern.svg`),
/// repeated, fading out upwards.
class _Band extends StatelessWidget {
  const _Band({required this.p, required this.u});

  final LessonPal p;
  final double u;

  @override
  Widget build(BuildContext context) {
    final stripW = u * 60;
    final stripH = stripW * 392 / 2172;
    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.7],
          colors: [Color(0x00000000), Color(0xFF000000)],
        ).createShader(r),
        child: OverflowBox(
          alignment: Alignment.bottomCenter,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 5; i++)
                SizedBox(
                  width: stripW,
                  height: stripH,
                  child: SvgPicture.asset(
                    'assets/ui/decor/card_pattern.svg',
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      p.c(RateelColors.pracBand, RateelColors.pracLBand),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekPanel extends StatelessWidget {
  const _WeekPanel({
    required this.p,
    required this.u,
    required this.x,
    required this.done,
  });

  final LessonPal p;
  final double u;
  final double Function(double px) x;
  final Animation<double> done;

  @override
  Widget build(BuildContext context) {
    const m = PracMetrics.panelTop;
    final pw = x(PracMetrics.panelX1) - x(PracMetrics.panelX0);
    final pcx = pw / 2 + x(PracMetrics.discDx) - x(0);
    final tdx = x(PracMetrics.panelTextDx) - x(0);
    final step = x(PracMetrics.dayStep) - x(0);
    final week = PracticeStore.week;
    final today = PracticeStore.today;
    final streak = PracticeStore.streak;
    final ink = _ink(p);
    final discs = <Widget>[];
    for (var i = 0; i < 7; i++) {
      final row1 = i < 4;
      // RTL: Saturday on the right.
      final k = row1 ? i : i - 4;
      final cx = row1 ? pcx + step * (1.5 - k) : pcx + step * (1 - k);
      final d = u * (row1 ? PracMetrics.row1D : PracMetrics.row2D);
      final cy = u * ((row1 ? PracMetrics.row1Cy : PracMetrics.row2Cy) - m);
      final day = week[i];
      final isToday = day == today;
      final isDone = PracticeStore.doneOn(day);
      discs.add(
        Positioned(
          left: cx - d / 2,
          top: cy - d / 2,
          width: d,
          height: d,
          child: _DayDisc(
            p: p,
            u: u,
            letter: PracticeStore.dayInitials[i],
            state: isDone
                ? _DayState.done
                : isToday
                ? _DayState.today
                : _DayState.idle,
            fill: isToday && isDone ? done : null,
          ),
        ),
      );
    }
    return _GlassBox(
      p: p,
      u: u,
      radius: PracMetrics.panelRadius,
      tile: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _centredText(
            'هذا الأسبوع',
            readex(u * PracMetrics.panelTitleSize, weight: 700, color: ink),
            left: tdx,
            width: pw,
            cy: PracMetrics.panelTitleCy - m,
            u: u,
          ),
          Positioned(
            left: pcx - u * PracMetrics.panelDividerW / 2,
            top: u * (PracMetrics.panelDividerCy - m - 1.5),
            width: u * PracMetrics.panelDividerW,
            height: u * 3,
            child: GoldDivider(u: u, diamond: 1.0),
          ),
          ...discs,
          Positioned(
            left: x(PracMetrics.separatorInset) - x(0),
            right: x(PracMetrics.separatorInset) - x(0),
            top: u * (PracMetrics.separatorY - m),
            height: math.max(1.0, u * 0.14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    p
                        .c(
                          RateelColors.pracSeparator,
                          RateelColors.pracLSeparator,
                        )
                        .withValues(alpha: 0),
                    p.c(
                      RateelColors.pracSeparator,
                      RateelColors.pracLSeparator,
                    ),
                    p
                        .c(
                          RateelColors.pracSeparator,
                          RateelColors.pracLSeparator,
                        )
                        .withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: pcx - u * PracMetrics.flameH * 314 / 384 / 2,
            top: u * (PracMetrics.flameCy - m - PracMetrics.flameH / 2),
            width: u * PracMetrics.flameH * 314 / 384,
            height: u * PracMetrics.flameH,
            child: _Glowing(
              u: u,
              p: p,
              radius: 3.2,
              child: _Flame(p: p),
            ),
          ),
          _centredText(
            streak == 0
                ? 'ابدأ سلسلتك اليوم'
                : arabicDays(streak, consecutive: true),
            readex(u * PracMetrics.streakSize, weight: 700, color: ink),
            left: x(PracMetrics.streakDx) - x(0),
            width: pw,
            cy: PracMetrics.streakCy - m,
            u: u,
          ),
          Positioned(
            left: pcx - u * PracMetrics.streakDividerW / 2,
            top: u * (PracMetrics.streakDividerCy - m - 1.5),
            width: u * PracMetrics.streakDividerW,
            height: u * 3,
            child: GoldDivider(u: u, diamond: 1.0),
          ),
        ],
      ),
    );
  }
}

/// Warm glow behind a gold glyph (dark: gold; light: pale cream halo).
class _Glowing extends StatelessWidget {
  const _Glowing({
    required this.u,
    required this.p,
    required this.radius,
    required this.child,
  });

  final double u;
  final LessonPal p;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    fit: StackFit.expand,
    children: [
      Positioned(
        left: -u * radius,
        right: -u * radius,
        top: -u * radius,
        bottom: -u * radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                p
                    .c(const Color(0xFFF5B82A), const Color(0xFFFFE7A6))
                    .withValues(alpha: p.d(0.32, 0.75)),
                p
                    .c(const Color(0xFFF5B82A), const Color(0xFFFFE7A6))
                    .withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
      child,
    ],
  );
}

/// The owner's flame (`flame_inner`, 30) coloured with the reference's
/// gradient; light: amber, its hole filled pale as the reference.
class _Flame extends StatelessWidget {
  const _Flame({required this.p});

  final LessonPal p;

  @override
  Widget build(BuildContext context) {
    final light = p.t > 0.5;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (light)
          Image.asset(
            'assets/ui/icons/flame_inner_hole.webp',
            fit: BoxFit.contain,
            color: RateelColors.pracLFlameInner,
          ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: light ? RateelColors.pracLFlame : RateelColors.pracFlame,
          ).createShader(r),
          child: Image.asset(
            'assets/ui/icons/flame_inner.webp',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ],
    );
  }
}

enum _DayState { done, today, idle }

class _DayDisc extends StatelessWidget {
  const _DayDisc({
    required this.p,
    required this.u,
    required this.letter,
    required this.state,
    this.fill,
  });

  final LessonPal p;
  final double u;
  final String letter;
  final _DayState state;

  /// Today just completed: the gold fills in and the check pops.
  final Animation<double>? fill;

  @override
  Widget build(BuildContext context) {
    Widget build(double t) {
      final done = state == _DayState.done;
      final f = done ? t : 0.0;
      final ink = switch (state) {
        _DayState.done => p.c(RateelColors.pracDoneInk, Colors.white),
        _DayState.today => p.c(
          RateelColors.pracTodayInk,
          RateelColors.pracLInk,
        ),
        _DayState.idle => p.c(
          RateelColors.pracDayInk,
          RateelColors.pracLDayInk,
        ),
      };
      final check = done
          ? Curves.easeOutBack.transform(((t - 0.4) / 0.6).clamp(0, 1))
          : 0.0;
      return LayoutBuilder(
        builder: (context, box) {
          final d = box.maxWidth;
          return CustomPaint(
            painter: _DiscPainter(
              p: p,
              u: u,
              state: state == _DayState.done && f < 1 ? _DayState.today : state,
              fill: f,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: d * (done ? 0.10 : 0.18),
                  left: 0,
                  right: 0,
                  child: Text(
                    letter,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: readex(
                      d * 0.40,
                      weight: 600,
                      color: Color.lerp(
                        p.c(RateelColors.pracTodayInk, RateelColors.pracLInk),
                        ink,
                        done ? f : 1,
                      )!,
                    ).copyWith(height: 1.0),
                  ),
                ),
                if (done && check > 0)
                  Positioned(
                    bottom: d * 0.16,
                    width: d * 0.36,
                    height: d * 0.28,
                    child: Transform.scale(
                      scale: check,
                      child: Image.asset(
                        'assets/ui/icons_white/checkmark.webp',
                        color: ink,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

    final a = fill;
    if (a == null) return build(1);
    return AnimatedBuilder(
      animation: a,
      builder: (context, _) => build(a.value),
    );
  }
}

class _DiscPainter extends CustomPainter {
  _DiscPainter({
    required this.p,
    required this.u,
    required this.state,
    required this.fill,
  });

  final LessonPal p;
  final double u;
  final _DayState state;
  final double fill;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    switch (state) {
      case _DayState.done:
        // Warm glow (dark) / soft shadow (light).
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..color = p
                .c(const Color(0xFFF2B630), const Color(0xFFB57A10))
                .withValues(alpha: p.d(0.45, 0.25))
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * p.d(1.2, 0.6)),
        );
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                p.c(RateelColors.pracDoneTop, RateelColors.pracLDoneTop),
                p.c(RateelColors.pracDoneMid, RateelColors.pracLDoneMid),
                p.c(RateelColors.pracDoneBottom, RateelColors.pracLDoneBottom),
              ],
            ).createShader(rect),
        );
        canvas.drawCircle(
          c,
          r - u * 0.12,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = u * 0.24
            ..color = p
                .c(const Color(0xFFF6D46A), const Color(0xFFFFD87A))
                .withValues(alpha: 0.8),
        );
      case _DayState.today:
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..color = p
                .c(const Color(0xFFE8D25A), const Color(0xFFF3C46A))
                .withValues(alpha: p.d(0.35, 0.3))
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.0),
        );
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..color = p.c(RateelColors.pracPanelMid, RateelColors.pracLPanel),
        );
        canvas.drawCircle(
          c,
          r - u * 0.22,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = u * 0.42
            ..color = p.c(
              RateelColors.pracTodayRim,
              RateelColors.pracLTodayRim,
            ),
        );
        if (fill > 0) {
          canvas.drawCircle(
            c,
            r * fill,
            Paint()
              ..color = p
                  .c(RateelColors.pracDoneMid, RateelColors.pracLDoneMid)
                  .withValues(alpha: fill),
          );
        }
      case _DayState.idle:
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                p.c(RateelColors.pracDayTop, RateelColors.pracLDay),
                p.c(RateelColors.pracDayBottom, RateelColors.pracLDay),
              ],
            ).createShader(rect),
        );
        canvas.drawCircle(
          c,
          r - u * 0.12,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = u * 0.24
            ..color = p.c(RateelColors.pracDayRim, const Color(0xFFEEDDCA)),
        );
    }
  }

  @override
  bool shouldRepaint(_DiscPainter o) =>
      o.p.t != p.t || o.u != u || o.state != state || o.fill != fill;
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.p,
    required this.u,
    required this.x,
    required this.entry,
    required this.onStart,
  });

  final LessonPal p;
  final double u;
  final double Function(double px) x;
  final Animation<double> entry;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    const m = PracMetrics.cardTop;
    final x0 = x(PracMetrics.cardX0);
    final cw = x(PracMetrics.cardX1) - x0;
    final ccx = cw / 2;
    final tdx = x(PracMetrics.cardTextDx) - x(0);
    final ink = _ink(p);
    final done = PracticeStore.doneToday;
    final tiles = [
      ('قراءة', arabicAyat(practiceAyat), _TileGlyph.book),
      ('أحكام', arabicQuestions(practiceRuleQuestions), _TileGlyph.question),
      (
        'استماع',
        arabicQuestions(practiceListenQuestions),
        _TileGlyph.headphones,
      ),
    ];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gold card of 08/10 (standard).
        Positioned.fill(
          child: CustomPaint(
            painter: GoldCardPainter(p, u, u * PracMetrics.cardRadius),
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(u * PracMetrics.cardRadius),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: u * 10,
                child: _Band(p: p, u: u),
              ),
            ),
          ),
        ),
        _centredText(
          'تدريب اليوم',
          readex(u * PracMetrics.cardTitleSize, weight: 700, color: ink),
          left: tdx,
          width: cw,
          cy: PracMetrics.cardTitleCy - m,
          u: u,
        ),
        _centredText(
          done
              ? 'أحسنت! أكملت تدريب اليوم'
              : 'راجع ما تعلّمته في 5 دقائق تقريباً',
          readex(
            u * PracMetrics.cardSubSize,
            weight: 400,
            color: p.c(RateelColors.pracSub, RateelColors.pracLInk),
          ),
          left: tdx,
          width: cw,
          cy: PracMetrics.cardSubCy - m,
          u: u,
        ),
        Positioned(
          left: ccx - u * PracMetrics.cardDividerW / 2,
          top: u * (PracMetrics.cardDividerCy - m - 1.5),
          width: u * PracMetrics.cardDividerW,
          height: u * 3,
          child: GoldDivider(u: u, diamond: 1.0),
        ),
        for (var i = 0; i < 3; i++)
          Positioned(
            left: x(PracMetrics.tiles[i].$1) - x0,
            width: x(PracMetrics.tiles[i].$2) - x(PracMetrics.tiles[i].$1),
            top: u * (PracMetrics.tileTop - m),
            height: u * (PracMetrics.tileBottom - PracMetrics.tileTop),
            child: _stagger(
              i,
              RepaintBoundary(
                child: _Tile(
                  p: p,
                  u: u,
                  name: tiles[i].$1,
                  count: tiles[i].$2,
                  glyph: tiles[i].$3,
                ),
              ),
            ),
          ),
        for (final ox in PracMetrics.ornaments)
          Positioned(
            left:
                x(ox) -
                x0 -
                (x(PracMetrics.ornamentW * PracMetrics.refU) - x(0)) / 2,
            width: x(PracMetrics.ornamentW * PracMetrics.refU) - x(0),
            top: u * (PracMetrics.buttonCy - m - 1.5),
            height: u * 3,
            child: GoldDivider(u: u, diamond: 1.0),
          ),
        Positioned(
          left: x(PracMetrics.buttonX0) - x0,
          width: x(PracMetrics.buttonX1) - x(PracMetrics.buttonX0),
          top: u * (PracMetrics.buttonCy - m - PracMetrics.buttonH / 2),
          height: u * PracMetrics.buttonH,
          child: LessonButton(
            u: u,
            p: p,
            label: done ? 'تدرّب مرة أخرى' : 'ابدأ التدريب',
            glyph: LessonBtnGlyph.chevron,
            height: PracMetrics.buttonH,
            fontSize: PracMetrics.buttonText,
            onTap: onStart,
          ),
        ),
      ],
    );
  }

  Widget _stagger(int i, Widget child) {
    final a = CurvedAnimation(
      parent: entry,
      curve: Interval(0.35 + 0.1 * i, 0.85 + 0.05 * i, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: a,
      child: child,
      builder: (context, child) => Opacity(
        opacity: a.value,
        child: Transform.scale(scale: 0.94 + 0.06 * a.value, child: child),
      ),
    );
  }
}

enum _TileGlyph { headphones, question, book }

class _Tile extends StatelessWidget {
  const _Tile({
    required this.p,
    required this.u,
    required this.name,
    required this.count,
    required this.glyph,
  });

  final LessonPal p;
  final double u;
  final String name;
  final String count;
  final _TileGlyph glyph;

  @override
  Widget build(BuildContext context) {
    const m = PracMetrics.tileTop;
    final ink = _ink(p);
    final light = p.t > 0.5;
    // One colour for the three glyphs (owner, 2026-11-28), sampled on the
    // references.
    final tint = p.c(RateelColors.pracGlyph, RateelColors.pracLGlyph);
    final (asset, aspect) = switch (glyph) {
      _TileGlyph.headphones => (
        light
            ? 'assets/ui/icons_white/headphones_brown.webp'
            : 'assets/ui/icons_white/headphones_cream.webp',
        512 / 443,
      ),
      _TileGlyph.question => (
        'assets/ui/icons_white/question_circle.webp',
        512 / 497,
      ),
      _TileGlyph.book => (
        light
            ? 'assets/ui/icons_white/open_book_brown.webp'
            : 'assets/ui/icons_white/open_book.webp',
        512 / 299,
      ),
    };
    final gh = u * (glyph == _TileGlyph.book ? 5.2 : PracMetrics.tileGlyphH);
    return _GlassBox(
      p: p,
      u: u,
      radius: PracMetrics.tileRadius,
      tile: true,
      band: 7,
      child: LayoutBuilder(
        builder: (context, box) {
          final tw = box.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: tw / 2 - gh * aspect / 2,
                top: u * (PracMetrics.tileGlyphCy - m) - gh / 2,
                width: gh * aspect,
                height: gh,
                child: Image.asset(asset, fit: BoxFit.contain, color: tint),
              ),
              _centredText(
                name,
                readex(u * PracMetrics.tileNameSize, weight: 700, color: ink),
                left: u * PracMetrics.tileTextDx / PracMetrics.refU,
                width: tw,
                cy: PracMetrics.tileNameCy - m,
                u: u,
              ),
              Positioned(
                left: tw / 2 - u * PracMetrics.tileDividerW / 2,
                top: u * (PracMetrics.tileDividerCy - m - 1.2),
                width: u * PracMetrics.tileDividerW,
                height: u * 2.4,
                child: GoldDivider(u: u, diamond: 0.8),
              ),
              _centredText(
                count,
                readex(u * PracMetrics.tileCountSize, weight: 500, color: ink),
                left: u * PracMetrics.tileTextDx / PracMetrics.refU,
                width: tw,
                cy: PracMetrics.tileCountCy - m,
                u: u,
              ),
            ],
          );
        },
      ),
    );
  }
}
