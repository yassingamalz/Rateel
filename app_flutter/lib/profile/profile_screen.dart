import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../challenges/challenge_data.dart';
import '../core/app_settings.dart';
import '../core/screen_decor.dart';
import '../core/user_profile.dart';
import '../leaderboard/leaderboard_data.dart';
import '../onboarding/onboarding_screen.dart';
import '../theme/rateel_theme.dart';

/// Screen 29, profile (references `screens/29-profile/reference-dark.webp` and
/// `reference-light.webp`, 1844×853; plan docs/flutter/screens/29-profile.md).
///
/// Geometry in u = 1% of the height (u = 8.53 px on the reference), measured on
/// the reference; horizontal values are offsets from the centre of the content
/// box (1687 px wide on the reference: the rail starts there).
abstract final class ProfMetrics {
  // Header.
  static const archTop = 0.9;
  static const archW = 88.0;
  static const archH = 23.0;
  static const bookDx = 2.8;
  static const bookTop = 5.85;
  static const bookW = 12.0;
  static const titleDx = 3.1;
  static const titleCentre = 16.4;
  static const titleSize = 6.45;
  static const dividerDx = 3.1;
  static const dividerCentre = 22.8;
  static const dividerW = 40.0;
  // Mosque (ink 150–391 × 20–185 px) and crescent + star (1388–1455 × 61–126).
  static const mosqueLeft = 13.6;
  static const mosqueTop = 3.9;
  static const mosqueW = 42.0;
  static const mosqueLLeft = 25.2;
  static const mosqueLTop = 2.4;
  static const mosqueLW = 38.5;
  static const crescentRight = 26.3;
  static const crescentTop = 6.7;
  static const crescentW = 8.9;
  // Identity card 102–1591 × 218–457 px.
  static const cardDx = 0.35;
  static const cardW = 174.5;
  static const cardTop = 25.6;
  static const cardH = 28.0;
  static const radius = 3.6;
  // Avatar ring 1228–1424 × 243–439 px.
  static const avatarDx = 56.7;
  static const avatarCy = 40.0;
  static const avatarD = 24.3;
  // Name (right edge 1102 px, ink 253–316), city row (centre y 365).
  static const textRight = 31.0;
  static const nameCy = 33.15;
  static const nameSize = 6.05;
  static const cityCy = 42.05;
  static const citySize = 3.6;
  // Vertical divider x 571, y 262–418 (bright 298–389).
  static const vDivDx = -32.0;
  // Quran art: arch 190–480 × 228–440 px.
  static const artDx = -59.6;
  static const artW = 47.0;
  static const artTop = 25.6;
  // Stats panel 105–1590 × 474–822 px.
  static const panelW = 174.1;
  static const panelTop = 55.6;
  static const panelH = 40.8;
  // Tiles: 309 × 188 px, gap 51 px, y 487–675.
  static const tileW = 36.2;
  static const tileH = 22.0;
  static const tileGap = 6.0;
  static const tileTop = 57.1;
  static const iconCy = 60.6;
  static const iconH = 5.0;
  static const labelCy = 66.4;
  static const labelSize = 3.5;
  static const tileDivCy = 70.6;
  static const tileDivW = 20.5;
  static const numberCy = 74.6;
  static const numberSize = 5.25;
  // Level bar 137–1564 × 702–804 px.
  static const levelW = 167.3;
  static const levelTop = 82.3;
  static const levelH = 12.0;
  static const levelRadius = 4.2;
  static const levelSepDx = 31.1;
  static const levelLabelRight = 63.3;
  static const levelLabelSize = 4.3;
  static const layersDx = 68.5;
  static const layersH = 5.6;
  // Level pill 659–977 × 724–783 px.
  static const pillLeft = -21.6;
  static const pillRight = 15.6;
  static const pillTop = 84.9;
  static const pillH = 6.9;
  static const pillTextSize = 3.42;
}

/// Colours of the screen, dark and light (reference values, `prof*` tokens).
class _Palette {
  const _Palette({
    required this.light,
    required this.text,
    required this.textSoft,
    required this.cardTop,
    required this.cardBottom,
    required this.cardRim,
    required this.cardRimSide,
    required this.cardGlow,
    required this.panelFill,
    required this.panelRim,
    required this.tileTop,
    required this.tileBottom,
    required this.tileRim,
    required this.levelFill,
    required this.levelRim,
    required this.pillRim,
    required this.pillText,
    required this.gold,
    required this.bookGlyph,
    required this.medal,
    required this.divider,
    required this.vDivider,
    required this.lattice,
    required this.shadow,
  });

  final bool light;
  final Color text;
  final Color textSoft;
  final Color cardTop;
  final Color cardBottom;
  final Color cardRim;
  final Color cardRimSide;
  final Color cardGlow;
  final Color panelFill;
  final Color panelRim;
  final Color tileTop;
  final Color tileBottom;
  final Color tileRim;
  final Color levelFill;
  final Color levelRim;
  final Color pillRim;
  final Color pillText;
  final Color gold;
  final Color bookGlyph;
  final Color medal;
  final Color divider;
  final Color vDivider;
  final Color lattice;
  final Color shadow;

  static const dark = _Palette(
    light: false,
    text: RateelColors.leaderText,
    textSoft: RateelColors.profCity,
    cardTop: RateelColors.profCardTop,
    cardBottom: RateelColors.profCardBottom,
    cardRim: RateelColors.profCardRim,
    cardRimSide: RateelColors.profCardRim,
    cardGlow: RateelColors.profCardGlow,
    panelFill: RateelColors.profPanelFill,
    panelRim: RateelColors.profPanelRim,
    tileTop: RateelColors.profTileTop,
    tileBottom: RateelColors.profTileBottom,
    tileRim: RateelColors.profPanelRim,
    levelFill: RateelColors.profPanelFill,
    levelRim: RateelColors.profLevelRim,
    pillRim: RateelColors.profPillRim,
    pillText: RateelColors.profPillText,
    gold: RateelColors.profGlyph,
    bookGlyph: RateelColors.leaderText,
    medal: RateelColors.profGlyph,
    divider: RateelColors.profDivider,
    vDivider: RateelColors.profVDivider,
    lattice: RateelColors.profLattice,
    shadow: Color(0x66000000),
  );

  static const lightP = _Palette(
    light: true,
    text: RateelColors.profLInk,
    textSoft: RateelColors.profLCity,
    cardTop: RateelColors.profLCardTop,
    cardBottom: RateelColors.profLCardBottom,
    cardRim: RateelColors.profLCardRim,
    cardRimSide: RateelColors.profLCardRimSide,
    cardGlow: RateelColors.profLCardGlow,
    panelFill: RateelColors.profLPanelFill,
    panelRim: RateelColors.profLPanelRim,
    tileTop: RateelColors.profLCardTop,
    tileBottom: RateelColors.profLCardBottom,
    tileRim: RateelColors.profLTileRim,
    levelFill: RateelColors.profLPanelFill,
    levelRim: RateelColors.profLLevelRim,
    pillRim: RateelColors.profLPill,
    pillText: RateelColors.profLPill,
    gold: RateelColors.profLGlyph,
    bookGlyph: RateelColors.profLBook,
    medal: RateelColors.profLMedal,
    divider: RateelColors.profLDivider,
    vDivider: RateelColors.profLDivider,
    lattice: RateelColors.profLLattice,
    shadow: Color(0x2E7A4A1C),
  );
}

/// Starting level chosen on the first start (screen 30, step B).
String get userStartLevel => UserProfile.levelName;

/// Screen 29. Data: the user of the leaderboard (mock: name, avatar, city,
/// points, lessons, rank), the streak of screen 12 (mock), the starting level
/// (mock, screen 30). Back: Android back or a drag to the right (as 12).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final AnimationController _back = AnimationController.unbounded(
    vsync: this,
  );
  final _drag = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _back.addListener(() => _drag.value = _back.value);
  }

  @override
  void dispose() {
    _entry.dispose();
    _back.dispose();
    _drag.dispose();
    super.dispose();
  }

  Animation<double> _interval(double a, double b) => CurvedAnimation(
    parent: _entry,
    curve: Interval(a, b, curve: Curves.easeOutCubic),
  );

  void _endDrag(double w, double velocity) {
    final close = _drag.value > w * 0.25 || velocity > 700;
    _back.value = _drag.value;
    if (close) {
      _back
          .animateTo(
            w,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeIn,
          )
          .whenComplete(() => widget.onBack?.call());
    } else {
      _back.animateTo(
        0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onBack?.call();
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: AppSettings.light,
        builder: (context, light, _) => LayoutBuilder(
          builder: (context, box) {
            final u = box.maxHeight / 100;
            final w = box.maxWidth;
            final p = light ? _Palette.lightP : _Palette.dark;
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (_) => _back.stop(),
              onHorizontalDragUpdate: (d) =>
                  _drag.value = (_drag.value + d.delta.dx).clamp(0.0, w),
              onHorizontalDragEnd: (d) => _endDrag(w, d.primaryVelocity ?? 0),
              onHorizontalDragCancel: () => _endDrag(w, 0),
              child: AnimatedBuilder(
                animation: _drag,
                builder: (context, child) {
                  final t = (_drag.value / w).clamp(0.0, 1.0);
                  return Opacity(
                    opacity: 1 - 0.6 * t,
                    child: Transform.translate(
                      offset: Offset(_drag.value, 0),
                      child: child,
                    ),
                  );
                },
                // Horizontal unit: the reference's content box is 197.8u wide; on
                // wider phones horizontal places stretch with the width.
                child: _content(u, w / 2, p, w / 197.8),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _editProfile() async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, _, _) => OnboardingScreen(
          edit: true,
          onDone: () => Navigator.of(context).pop(),
        ),
        transitionsBuilder: (context, a, _, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _content(double u, double cx, _Palette p, double ux) {
    final me = players.firstWhere((e) => e.isMe);
    final rank = players.indexOf(me) + 1;
    final header = _interval(0, 0.5);
    final card = _interval(0.12, 0.62);
    final panel = _interval(0.25, 0.75);
    Widget tile(int i, String glyph, String label, Widget number) {
      // Tile centres 311.5 … 1391.5 px (from the content centre, right first).
      const centres = [64.2, 21.8, -20.2, -62.4];
      return Positioned(
        left: cx + ux * (centres[i] - ProfMetrics.tileW / 2),
        top: u * ProfMetrics.tileTop,
        width: ux * ProfMetrics.tileW,
        height: u * ProfMetrics.tileH,
        child: _Rise(
          animation: _interval(0.32 + 0.07 * i, 0.82 + 0.04 * i),
          u: u,
          child: _Tile(u: u, p: p, glyph: glyph, label: label, number: number),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: p.light
                ? const ColoredBox(color: RateelColors.profLBg)
                : const ScreenBackground(),
          ),
        ),
        Positioned.fill(
          child: _Corners(u: u, p: p),
        ),
        Positioned.fill(
          child: _Rise(
            animation: header,
            u: u,
            down: true,
            child: _Header(u: u, ux: ux, cx: cx, p: p),
          ),
        ),
        // Identity card.
        Positioned(
          left: cx + ux * (ProfMetrics.cardDx - ProfMetrics.cardW / 2),
          top: u * ProfMetrics.cardTop,
          width: ux * ProfMetrics.cardW,
          height: u * ProfMetrics.cardH,
          child: _Rise(
            animation: card,
            u: u,
            // A tap opens step A of the first start, prefilled, to change
            // name and avatar (screen 30, owner 2026-11-28 Q9).
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _editProfile,
              child: _IdentityCard(u: u, ux: ux, p: p, player: me),
            ),
          ),
        ),
        // Stats panel.
        Positioned(
          left: cx + ux * (ProfMetrics.cardDx - ProfMetrics.panelW / 2),
          top: u * ProfMetrics.panelTop,
          width: ux * ProfMetrics.panelW,
          height: u * ProfMetrics.panelH,
          child: _Rise(
            animation: panel,
            u: u,
            child: _Panel(u: u, p: p),
          ),
        ),
        tile(0, 'star', 'النقاط', _Number('${me.score}', u: u, p: p)),
        tile(1, 'book', 'الدروس', _Number('${me.lessons}', u: u, p: p)),
        tile(2, 'medal', 'الترتيب', _Number('$rank', u: u, p: p)),
        tile(
          3,
          'flame',
          'أيام متتالية',
          ValueListenableBuilder<int>(
            valueListenable: dailyStreak,
            builder: (context, v, _) => _Number('$v', u: u, p: p),
          ),
        ),
        Positioned(
          left: cx + ux * (ProfMetrics.cardDx - ProfMetrics.levelW / 2),
          top: u * ProfMetrics.levelTop,
          width: ux * ProfMetrics.levelW,
          height: u * ProfMetrics.levelH,
          child: _Rise(
            animation: _interval(0.5, 1),
            u: u,
            child: _LevelBar(u: u, ux: ux, p: p),
          ),
        ),
      ],
    );
  }
}

class _Rise extends StatelessWidget {
  const _Rise({
    required this.animation,
    required this.u,
    required this.child,
    this.down = false,
  });

  final Animation<double> animation;
  final double u;
  final Widget child;
  final bool down;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: RepaintBoundary(child: child),
    builder: (context, child) => Opacity(
      opacity: animation.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, u * 3.5 * (1 - animation.value) * (down ? -0.6 : 1)),
        child: child,
      ),
    ),
  );
}

/// Top corners: the screen 03/12 standard (owner's glowing lattice), beige in
/// the light theme.
class _Corners extends StatelessWidget {
  const _Corners({required this.u, required this.p});

  final double u;
  final _Palette p;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        for (final (left, dx, dy, w, ratio) in [
          (true, -2.6, -2.8, 30.0, 703 / 800),
          (false, -5.75, -2.6, 32.0, 674 / 800),
        ])
          Positioned(
            left: left ? u * dx : null,
            right: left ? null : u * dx,
            top: u * dy,
            width: u * w,
            height: u * w * ratio,
            child: Opacity(
              opacity: p.light ? 0.55 : 0.75,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => RadialGradient(
                  center: left ? Alignment.topLeft : Alignment.topRight,
                  radius: 1.25,
                  stops: const [0.0, 0.45, 1.0],
                  colors: const [
                    Color(0xFF000000),
                    Color(0xCC000000),
                    Color(0x00000000),
                  ],
                ).createShader(r),
                child: Image.asset(
                  'assets/ui/decor/corner_glow_${left ? 'left' : 'right'}.webp',
                  color: p.light ? RateelColors.profLLattice : null,
                  colorBlendMode: p.light ? BlendMode.srcIn : null,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.u,
    required this.ux,
    required this.cx,
    required this.p,
  });

  final double u;
  final double ux;
  final double cx;
  final _Palette p;

  @override
  Widget build(BuildContext context) {
    ColorFilter? tint(Color c) =>
        p.light ? ColorFilter.mode(c, BlendMode.srcIn) : null;
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: cx + ux * ProfMetrics.titleDx - u * ProfMetrics.archW / 2,
            top: u * ProfMetrics.archTop,
            width: u * ProfMetrics.archW,
            height: u * ProfMetrics.archH,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.72, 1.0],
                colors: [Color(0xFF000000), Color(0x33000000)],
              ).createShader(r),
              // Reference: the arch line glows softly (blurred copy under it).
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: u * 0.5,
                      sigmaY: u * 0.5,
                    ),
                    child: SvgPicture.asset(
                      'assets/ui/decor/header_arch.svg',
                      fit: BoxFit.fill,
                      colorFilter: ColorFilter.mode(
                        p.light
                            ? RateelColors.profLArch.withValues(alpha: 0.5)
                            : RateelColors.profArchGlow,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/ui/decor/header_arch.svg',
                    fit: BoxFit.fill,
                    colorFilter: tint(RateelColors.profLArch),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: u * ProfMetrics.mosqueLeft,
            top: u * ProfMetrics.mosqueTop,
            width: u * ProfMetrics.mosqueW,
            height: u * ProfMetrics.mosqueW * 542 / 900,
            child: p.light
                ? const SizedBox.shrink()
                : Opacity(
                    opacity: 1.0,
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (r) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.66, 0.84],
                        colors: [Color(0xFF000000), Color(0x00000000)],
                      ).createShader(r),
                      child: Image.asset(
                        'assets/ui/decor/mosque.webp',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
          ),
          // Light theme: the owner's beige skyline (A6), as reference-light
          // (x 215–540 px, base faded at ≈ 200 px).
          if (p.light)
            Positioned(
              left: u * ProfMetrics.mosqueLLeft,
              top: u * ProfMetrics.mosqueLTop,
              width: u * ProfMetrics.mosqueLW,
              height: u * ProfMetrics.mosqueLW * 465 / 900,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.6, 1.0],
                  colors: [Color(0xFF000000), Color(0x00000000)],
                ).createShader(r),
                child: Image.asset(
                  'assets/ui/decor/mosque_light.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Positioned(
            right: u * ProfMetrics.crescentRight,
            top: u * ProfMetrics.crescentTop,
            width: u * ProfMetrics.crescentW,
            height: u * ProfMetrics.crescentW,
            child: SvgPicture.asset(
              'assets/ui/decor/crescent_star.svg',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: cx + ux * ProfMetrics.bookDx - u * ProfMetrics.bookW / 2,
            top: u * ProfMetrics.bookTop,
            width: u * ProfMetrics.bookW,
            height: u * ProfMetrics.bookW * 449 / 988,
            child: SvgPicture.asset(
              'assets/ui/decor/header_book.svg',
              fit: BoxFit.fill,
              colorFilter: tint(RateelColors.profLHeaderBook),
            ),
          ),
          Positioned(
            left: cx + ux * ProfMetrics.titleDx - u * 60,
            width: u * 120,
            top: u * (ProfMetrics.titleCentre - 6),
            height: u * 12,
            child: Center(
              child: p.light
                  ? Text(
                      'الملف الشخصي',
                      textAlign: TextAlign.center,
                      style: readex(
                        u * ProfMetrics.titleSize,
                        weight: 600,
                        color: RateelColors.profLInk,
                      ).copyWith(height: 1.2),
                    )
                  : ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (r) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [titleTop, titleBottom],
                      ).createShader(r),
                      child: Text(
                        'الملف الشخصي',
                        textAlign: TextAlign.center,
                        style: readex(
                          u * ProfMetrics.titleSize,
                          weight: 600,
                          color: titleCream,
                        ).copyWith(height: 1.2, shadows: titleShadows(u)),
                      ),
                    ),
            ),
          ),
          Positioned(
            left:
                cx + ux * ProfMetrics.dividerDx - u * ProfMetrics.dividerW / 2,
            top: u * (ProfMetrics.dividerCentre - 2),
            width: u * ProfMetrics.dividerW,
            height: u * 4,
            child: CustomPaint(
              // Reference: line 0.35u, diamond 2.8u wide with a 0.45u stroke,
              // small rhombus caps next to it.
              painter: _DividerPainter(
                u: u,
                color: p.light
                    ? RateelColors.profLDivider
                    : RateelColors.profHeaderDivider,
                diamond: 1.25,
                line: 0.35,
                stroke: 0.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass box: vertical fill, rim, optional glow and drop shadow.
class _Glass extends StatelessWidget {
  const _Glass({
    required this.u,
    required this.top,
    required this.bottom,
    required this.rim,
    this.rimBottom,
    required this.rimWidth,
    required this.radius,
    this.glow,
    this.shadow,
    this.child,
  });

  final double u;
  final Color top;
  final Color bottom;
  final Color rim;
  final Color? rimBottom;
  final double rimWidth;
  final double radius;
  final Color? glow;
  final Color? shadow;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(u * radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          if (shadow != null)
            BoxShadow(
              color: shadow!,
              offset: Offset(0, u * 0.5),
              blurRadius: u * 1.4,
            ),
          if (glow != null) BoxShadow(color: glow!, blurRadius: u * 1.6),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(u * rimWidth),
        decoration: BoxDecoration(
          borderRadius: r,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [rim, rimBottom ?? rim],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(u * (radius - rimWidth)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [top, bottom],
              ),
            ),
            child: child ?? const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

/// Owner's star lattice (white tile, tinted) faded by [mask].
class _Lattice extends StatelessWidget {
  const _Lattice({
    required this.u,
    required this.color,
    required this.mask,
    this.cell = 7.0,
  });

  final double u;
  final Color color;
  final Gradient mask;
  final double cell;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: mask.createShader,
      child: Image.asset(
        'assets/ui/decor/lattice_star_tile.webp',
        repeat: ImageRepeat.repeat,
        // The tile holds 2×2 cells.
        scale: 512 / (u * cell * 2),
        fit: BoxFit.none,
        alignment: Alignment.topRight,
        color: color,
        colorBlendMode: BlendMode.srcIn,
      ),
    ),
  );
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.u,
    required this.ux,
    required this.p,
    required this.player,
  });

  final double u;
  final double ux;
  final _Palette p;
  final Player player;

  @override
  Widget build(BuildContext context) {
    // Card-local x of a content offset (from the content centre).
    final w = ux * ProfMetrics.cardW;
    double lx(double dx) => w / 2 + ux * (dx - ProfMetrics.cardDx);
    final top = u * ProfMetrics.cardTop;
    return _Glass(
      u: u,
      top: p.cardTop,
      bottom: p.cardBottom,
      rim: p.cardRim,
      rimBottom: p.cardRimSide,
      rimWidth: 0.35,
      radius: ProfMetrics.radius,
      glow: p.cardGlow,
      shadow: p.shadow,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lattice in an arch behind the avatar (reference x 1150–1545).
          Positioned(
            left: lx(ProfMetrics.avatarDx) - u * 23.5,
            width: u * 47,
            top: u * 0.4,
            bottom: 0,
            child: ClipPath(
              clipper: _ArchClipper(),
              child: _Lattice(
                u: u,
                cell: 5.4,
                // Brighter than the level bar's (reference #48673B lines).
                color: p.light ? p.lattice : RateelColors.profAvatarLattice,
                mask: const RadialGradient(
                  radius: 0.75,
                  colors: [
                    Color(0xFF000000),
                    Color(0x99000000),
                    Color(0x00000000),
                  ],
                  stops: [0.3, 0.6, 1],
                ),
              ),
            ),
          ),
          // Avatar ring as the reference (owner, 2026-11-28: «il cerchio non come
          // il riferimento»): outer Ø 207 px (24.3u), a pale-gold band ≈ 4 px
          // (#F9EFA0 → #EFDA6F) and a darker gold line ≈ 2 px (#B69818) inside,
          // a soft gold glow outside; the yellow disc fills the rest.
          Positioned(
            left: lx(ProfMetrics.avatarDx) - u * ProfMetrics.avatarD / 2,
            top: u * ProfMetrics.avatarCy - top - u * ProfMetrics.avatarD / 2,
            width: u * ProfMetrics.avatarD,
            height: u * ProfMetrics.avatarD,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    RateelColors.profRingTop,
                    RateelColors.profRingBottom,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: RateelColors.profRingGlow.withValues(
                      alpha: p.light ? 0.25 : 0.35,
                    ),
                    blurRadius: u * 1.0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(u * 0.47),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: RateelColors.profRingLine,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(u * 0.22),
                    child: ClipOval(
                      child: Image.asset(player.avatarAsset, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Name.
          Positioned(
            right: w - lx(ProfMetrics.textRight),
            top: u * (ProfMetrics.nameCy - 5) - top,
            height: u * 10,
            child: Center(
              child: Text(
                player.name,
                textDirection: TextDirection.rtl,
                style: readex(
                  u * ProfMetrics.nameSize,
                  weight: 600,
                  color: p.text,
                ).copyWith(height: 1.2),
              ),
            ),
          ),
          // City with the gold pin.
          Positioned(
            right: w - lx(ProfMetrics.textRight + 0.45),
            top: u * (ProfMetrics.cityCy - 3) - top,
            height: u * 6,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.location_on_rounded, color: p.gold, size: u * 5.2),
                SizedBox(width: u * 0.9),
                Text(
                  player.region,
                  textDirection: TextDirection.rtl,
                  style: readex(
                    u * ProfMetrics.citySize,
                    weight: 400,
                    color: p.textSoft,
                  ).copyWith(height: 1.2),
                ),
              ],
            ),
          ),
          // Vertical divider.
          Positioned(
            left: lx(ProfMetrics.vDivDx) - u * 0.1,
            width: u * 0.2,
            top: u * 30.7 - top,
            height: u * 18.3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    p.vDivider.withValues(alpha: 0),
                    p.vDivider,
                    p.vDivider,
                    p.vDivider.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.25, 0.75, 1],
                ),
              ),
            ),
          ),
          // Quran in the mihrab: arch 190–480 × 228–440 px on the reference;
          // the art is scaled so its stand ends at ≈ 440 px (feet at 88% of its height),
          // centre at 49.4%. Clipped by the card (the floor light ends at the rim).
          Positioned(
            left: lx(ProfMetrics.artDx) - u * ProfMetrics.artW * 0.494,
            width: u * ProfMetrics.artW,
            top: u * (ProfMetrics.artTop) - top,
            height: u * ProfMetrics.artW * 655 / 1024,
            child: _QuranArt(p: p),
          ),
        ],
      ),
    );
  }
}

/// The Quran on its stand in the glowing mihrab, with the yellow light on the
/// floor: owner's full art (`decor/quran_mihrab_{dark,light}.webp`, 2026-11-28),
/// its edges faded into the card fill.
class _QuranArt extends StatelessWidget {
  const _QuranArt({required this.p});

  final _Palette p;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback: (r) => const RadialGradient(
      center: Alignment(0, -0.1),
      radius: 0.62,
      stops: [0.62, 1.0],
      colors: [Color(0xFF000000), Color(0x00000000)],
    ).createShader(r),
    child: Image.asset(
      p.light
          ? 'assets/ui/decor/quran_mihrab_light.webp'
          : 'assets/ui/decor/quran_mihrab_dark.webp',
      fit: BoxFit.fill,
    ),
  );
}

Path _onionArch(Size s) {
  final w = s.width;
  final h = s.height;
  return Path()
    ..moveTo(0, h)
    ..lineTo(0, h * 0.5)
    ..cubicTo(0, h * 0.30, w * 0.18, h * 0.22, w * 0.34, h * 0.15)
    ..cubicTo(w * 0.44, h * 0.10, w * 0.48, h * 0.05, w * 0.5, 0)
    ..cubicTo(w * 0.52, h * 0.05, w * 0.56, h * 0.10, w * 0.66, h * 0.15)
    ..cubicTo(w * 0.82, h * 0.22, w, h * 0.30, w, h * 0.5)
    ..lineTo(w, h);
}

class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _onionArch(size)..close();

  @override
  bool shouldReclip(_ArchClipper oldClipper) => false;
}

class _Panel extends StatelessWidget {
  const _Panel({required this.u, required this.p});

  final double u;
  final _Palette p;

  @override
  Widget build(BuildContext context) => _Glass(
    u: u,
    top: p.panelFill,
    bottom: p.panelFill,
    rim: p.panelRim,
    rimWidth: 0.3,
    radius: ProfMetrics.radius,
    shadow: p.shadow,
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.u,
    required this.p,
    required this.glyph,
    required this.label,
    required this.number,
  });

  final double u;
  final _Palette p;
  final String glyph;
  final String label;
  final Widget number;

  Widget _glyph() {
    // Owner's glyphs (2026-11-28), sizes measured on the reference.
    return switch (glyph) {
      'star' => SvgPicture.asset(
        'assets/ui/glyphs/star.svg',
        height: u * ProfMetrics.iconH * 1.38,
        colorFilter: ColorFilter.mode(p.gold, BlendMode.srcIn),
      ),
      'book' => Image.asset(
        'assets/ui/glyphs/open_book.webp',
        width: u * 7.0,
        height: u * 4.6,
        fit: BoxFit.fill,
        color: p.bookGlyph,
        colorBlendMode: BlendMode.srcIn,
      ),
      'medal' => Image.asset(
        'assets/ui/glyphs/rank_rosette.webp',
        height: u * 5.9,
      ),
      _ => Image.asset('assets/ui/icons/flame_gold_04.webp', height: u * 5.2),
    };
  }

  @override
  Widget build(BuildContext context) {
    final top = u * ProfMetrics.tileTop;
    return _Glass(
      u: u,
      top: p.tileTop,
      bottom: p.tileBottom,
      rim: p.tileRim,
      rimWidth: 0.3,
      radius: ProfMetrics.radius,
      shadow: p.shadow,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: u * (ProfMetrics.iconCy - 3.5) - top,
            height: u * 7,
            child: Center(child: _glyph()),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: u * (ProfMetrics.labelCy - 3) - top,
            height: u * 6,
            child: Center(
              child: Text(
                label,
                textDirection: TextDirection.rtl,
                style: readex(
                  u * ProfMetrics.labelSize,
                  weight: 600,
                  color: p.text,
                ).copyWith(height: 1.2),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: u * (ProfMetrics.tileDivCy - 1.5) - top,
            height: u * 3,
            // Reference: 166–180 px wide, gold fading to the ends.
            child: Center(
              child: SizedBox(
                width: u * ProfMetrics.tileDivW,
                child: CustomPaint(
                  size: Size.infinite,
                  // Reference: line 0.25u with a soft glow, diamond 1.4u
                  // wide with a 0.28u stroke, small caps next to it.
                  painter: _DividerPainter(
                    u: u,
                    color: p.divider,
                    diamond: 0.7,
                    line: 0.25,
                    stroke: 0.28,
                    glow: !p.light,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: u * (ProfMetrics.numberCy - 4) - top,
            height: u * 8,
            // Centred on the tile (owner, 2026-11-28).
            child: Center(child: number),
          ),
        ],
      ),
    );
  }
}

class _Number extends StatelessWidget {
  const _Number(this.value, {required this.u, required this.p});

  final String value;
  final double u;
  final _Palette p;

  @override
  Widget build(BuildContext context) => Text(
    value,
    textDirection: TextDirection.ltr,
    style: readex(
      u * ProfMetrics.numberSize,
      weight: 600,
      color: p.text,
    ).copyWith(height: 1.2),
  );
}

class _LevelBar extends StatelessWidget {
  const _LevelBar({required this.u, required this.ux, required this.p});

  final double u;
  final double ux;
  final _Palette p;

  @override
  Widget build(BuildContext context) {
    final w = ux * ProfMetrics.levelW;
    double lx(double dx) => w / 2 + ux * (dx - ProfMetrics.cardDx);
    return _Glass(
      u: u,
      top: p.levelFill,
      bottom: p.levelFill,
      rim: p.levelRim,
      rimWidth: 0.3,
      radius: ProfMetrics.levelRadius,
      shadow: p.shadow,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lattice on the left, fading to the right.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: w * 0.45,
            child: _Lattice(
              u: u,
              cell: 8.0,
              color: p.lattice,
              mask: const LinearGradient(
                colors: [Color(0xFF000000), Color(0x00000000)],
              ),
            ),
          ),
          // Separator.
          Positioned(
            left: lx(ProfMetrics.levelSepDx) - u * 0.1,
            width: u * 0.2,
            top: u * 1.8,
            bottom: u * 1.8,
            child: ColoredBox(color: p.vDivider),
          ),
          // «المستوى» with the layers glyph on its right.
          Positioned(
            right: w - lx(ProfMetrics.levelLabelRight),
            top: 0,
            bottom: 0,
            child: Center(
              child: Transform.translate(
                offset: Offset(0, -u * 0.85),
                child: Text(
                  'المستوى',
                  textDirection: TextDirection.rtl,
                  style: readex(
                    u * ProfMetrics.levelLabelSize,
                    weight: 600,
                    color: p.text,
                  ).copyWith(height: 1.2),
                ),
              ),
            ),
          ),
          Positioned(
            left: lx(ProfMetrics.layersDx) - u * ProfMetrics.layersH * 0.6,
            width: u * ProfMetrics.layersH * 1.2,
            top: 0,
            bottom: 0,
            child: Center(
              // Owner's layers glyph, 54×47 px on the reference.
              child: Image.asset(
                'assets/ui/glyphs/layers.webp',
                width: u * 6.3,
                height: u * 5.5,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Level pill.
          Positioned(
            left: lx(ProfMetrics.pillLeft),
            width: ux * (ProfMetrics.pillRight - ProfMetrics.pillLeft),
            top: u * (ProfMetrics.pillTop - ProfMetrics.levelTop),
            height: u * ProfMetrics.pillH,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(u * ProfMetrics.pillH / 2),
                border: Border.all(color: p.pillRim, width: u * 0.3),
              ),
              // Content 10 px right of the pill axis on the reference.
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: u * 2.4),
                // Scales down if the text grows (text size 110%).
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    // Text lifted 0.3u (Readex sits low).
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      SvgPicture.asset(
                        'assets/ui/glyphs/star.svg',
                        height: u * 4.0,
                        colorFilter: ColorFilter.mode(p.gold, BlendMode.srcIn),
                      ),
                      SizedBox(width: u * 0.8),
                      Transform.translate(
                        offset: Offset(0, -u * 0.3),
                        child: Text(
                          'مستوى $userStartLevel',
                          textDirection: TextDirection.rtl,
                          style: readex(
                            u * ProfMetrics.pillTextSize,
                            weight: 500,
                            color: p.pillText,
                          ).copyWith(height: 1.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Divider of the reference: a gold line brightest next to the diamond and
/// fading out towards both ends, a small rhombus cap at its inner end, an open
/// diamond in the middle. Sizes in u.
class _DividerPainter extends CustomPainter {
  _DividerPainter({
    required this.u,
    required this.color,
    required this.diamond,
    required this.line,
    required this.stroke,
    this.glow = false,
  });

  final double u;
  final Color color;

  /// Half diagonal of the diamond.
  final double diamond;
  final double line;
  final double stroke;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final d = u * diamond;
    final t = math.max(u * line, 1.0);
    final cap = t * 1.6; // half diagonal of the rhombus cap
    final gap = u * 0.35;
    for (final side in [-1.0, 1.0]) {
      final capX = c.dx + side * (d + gap + cap);
      final inner = capX + side * cap * 0.6;
      final outer = c.dx + side * size.width / 2;
      // Brightest at the inner end, gone at the outer end.
      final shader =
          LinearGradient(
            begin: side < 0 ? Alignment.centerRight : Alignment.centerLeft,
            end: side < 0 ? Alignment.centerLeft : Alignment.centerRight,
            colors: [
              color,
              color,
              color.withValues(alpha: 0.6),
              color.withValues(alpha: 0),
            ],
            stops: const [0, 0.35, 0.7, 1],
          ).createShader(
            Rect.fromLTRB(
              math.min(inner, outer),
              0,
              math.max(inner, outer),
              size.height,
            ),
          );
      final rect = Rect.fromLTRB(
        math.min(inner, outer),
        c.dy - t / 2,
        math.max(inner, outer),
        c.dy + t / 2,
      );
      if (glow) {
        canvas.drawRect(
          rect.inflate(t * 0.8),
          Paint()
            ..shader = shader
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, t * 1.2)
            ..color = color.withValues(alpha: 0.3),
        );
      }
      canvas.drawRect(rect, Paint()..shader = shader);
      // Rhombus cap next to the diamond.
      canvas.drawPath(
        Path()
          ..moveTo(capX - cap, c.dy)
          ..lineTo(capX, c.dy - cap * 0.75)
          ..lineTo(capX + cap, c.dy)
          ..lineTo(capX, c.dy + cap * 0.75)
          ..close(),
        Paint()..color = color,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - d)
        ..lineTo(c.dx + d, c.dy)
        ..lineTo(c.dx, c.dy + d)
        ..lineTo(c.dx - d, c.dy)
        ..close(),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(u * stroke, 1.0)
        ..strokeJoin = StrokeJoin.miter
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_DividerPainter o) =>
      o.u != u ||
      o.color != color ||
      o.diamond != diamond ||
      o.line != line ||
      o.stroke != stroke ||
      o.glow != glow;
}
