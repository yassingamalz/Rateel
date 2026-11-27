import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/screen_decor.dart';
import '../theme/rateel_theme.dart';

/// Decor shared by the lesson screens with the 08 look (reading 08, test 10):
/// the two-theme palette, background with the stepped-lattice corners, the
/// lattice field, the header (arch, mosque, crescent and star, title), the
/// verse/question badge, the gold card and the small painters. Moved here
/// from `reading_lesson_page.dart` unchanged (2026-11-25, screen 10); the
/// header takes its geometry from a [HeaderSpec].
class LessonDecor {
  LessonDecor._();
  // Corners (stepped lattice R1), measured on reference 08.
  static const cornerW = 58.0;
  static const cornerH = 30.4;
  static const cornerCell = 9.6;
}

/// Geometry of a lesson header in u (x from the screen centre).
class HeaderSpec {
  const HeaderSpec({
    required this.archW,
    required this.archH,
    required this.archTop,
    required this.archClipDx,
    required this.mosqueDx,
    required this.mosqueTop,
    required this.mosqueW,
    required this.crescentDx,
    required this.crescentTop,
    required this.crescentH,
    required this.starDx,
    required this.starTop,
    required this.starH,
    required this.titleCentre,
    required this.titleSize,
    required this.dividerTop,
    required this.dividerW,
    required this.dividerDiamond,
    this.book = true,
    this.bookW = 0,
    this.bookH = 0,
    this.bookTop = 0,
    this.goldTitle = false,
    this.subtitleCentre = 0,
    this.subtitleSize = 0,
    this.starOpacity = 0.55,
    this.subtitleColor,
    this.emblem,
  });

  /// Raster emblem at the arch apex instead of the 08 book (screen 22:
  /// gold headphones), in the book box.
  final String? emblem;

  final double archW, archH, archTop, archClipDx;
  final double mosqueDx, mosqueTop, mosqueW;
  final double crescentDx, crescentTop, crescentH;
  final double starDx, starTop, starH;
  final double titleCentre, titleSize;
  final double dividerTop, dividerW, dividerDiamond;
  final bool book;
  final double bookW, bookH, bookTop;

  /// Title in a gold gradient (reference 10) instead of cream (08).
  final bool goldTitle;
  final double subtitleCentre, subtitleSize;

  /// Dark-theme subtitle colour (default `leaderText`).
  final Color? subtitleColor;

  /// Star opacity in the dark theme (03/05/08: 55%).
  final double starOpacity;
}

/// Colours of the two themes; [t] 0 = dark, 1 = light.
class LessonPal {
  const LessonPal(this.t);

  final double t;

  Color c(Color dark, Color light) => Color.lerp(dark, light, t)!;
  double d(double dark, double light) => dark + (light - dark) * t;
}

class LessonBackground extends StatelessWidget {
  const LessonBackground({super.key, required this.p, required this.u});

  final LessonPal p;
  final double u;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.9,
              colors: [
                p.c(RateelColors.readBgCentre, RateelColors.readLBgCentre),
                p.c(RateelColors.readBgEdge, RateelColors.readLBgEdge),
              ],
            ),
          ),
        ),
        // Stepped lattice in the top corners, strongest at the corner and
        // fading inwards and down (reference: x ≤ 58u, y ≤ 30u).
        for (final left in [true, false])
          Positioned(
            left: left ? 0 : null,
            right: left ? null : 0,
            top: 0,
            width: u * LessonDecor.cornerW,
            height: u * LessonDecor.cornerH,
            child: LatticeField(
              p: p,
              u: u,
              cell: LessonDecor.cornerCell,
              opacity: p.d(0.27, 0.5),
              alignment: left ? Alignment.topLeft : Alignment.topRight,
              mask: RadialGradient(
                center: left ? Alignment.topLeft : Alignment.topRight,
                radius: 1.1,
                colors: const [
                  Color(0xFF000000),
                  Color(0x99000000),
                  Color(0x00000000),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
      ],
    );
  }
}

/// The owner's stepped lattice tile (R1, 2 cells per tile), repeated with a
/// given cell size, tinted per theme, faded with [mask].
class LatticeField extends StatelessWidget {
  const LatticeField({
    super.key,
    required this.p,
    required this.u,
    required this.cell,
    required this.opacity,
    required this.mask,
    this.alignment = Alignment.bottomCenter,
  });

  final LessonPal p;
  final double u;
  final double cell;
  final double opacity;
  final Gradient mask;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final tile = u * cell * 2;
    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: mask.createShader,
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            'assets/ui/reading/lattice_tile.webp',
            repeat: ImageRepeat.repeat,
            fit: BoxFit.none,
            alignment: alignment,
            scale: 512 / tile,
            color: p.t > 0
                ? p.c(Colors.white, RateelColors.readLLattice)
                : null,
            colorBlendMode: p.t > 0 ? BlendMode.modulate : null,
          ),
        ),
      ),
    );
  }
}

class LessonHeader extends StatelessWidget {
  const LessonHeader({
    super.key,
    required this.p,
    required this.u,
    required this.cx,
    required this.title,
    required this.s,
    this.subtitle,
  });

  final LessonPal p;
  final double u;
  final double cx;
  final String title;
  final HeaderSpec s;
  final String? subtitle;

  Widget _title() {
    final style = readex(
      u * s.titleSize,
      weight: s.goldTitle ? 700 : 600,
      color: p.c(titleCream, RateelColors.readLTitle),
    ).copyWith(height: 1.2, shadows: p.t > 0.5 ? null : titleShadows(u));
    final text = Text(
      title,
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      maxLines: 1,
      style: style,
    );
    if (!s.goldTitle || p.t >= 1) return text;
    // Reference 10: warm gold title, lighter at the top (faded out in light).
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          p.c(RateelColors.testTitleTop, RateelColors.readLTitle),
          p.c(RateelColors.testTitleBottom, RateelColors.readLTitle),
        ],
      ).createShader(r),
      child: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final copper = p.t > 0
        ? ColorFilter.mode(
            p.c(RateelColors.archShoulder, RateelColors.readLCopper),
            BlendMode.srcIn,
          )
        : null;
    ColorFilter? lightTint(Color light) => p.t > 0
        ? ColorFilter.mode(
            p.c(RateelColors.glyphGoldBottom, light),
            BlendMode.srcIn,
          )
        : null;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // archW / dividerW 0: that ornament is left out (screen 22 review).
          if (s.archW > 0)
            Positioned(
              left: cx - u * s.archW / 2,
              top: u * s.archTop,
              width: u * s.archW,
              height: u * s.archH,
              // Left of the mosque the arch is not drawn (reference).
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) {
                  final f = (s.archW / 2 + s.archClipDx) / s.archW;
                  return LinearGradient(
                    colors: const [Color(0x00000000), Color(0xFF000000)],
                    stops: [f - 0.01, f + 0.02],
                  ).createShader(r);
                },
                child: Image.asset(
                  'assets/ui/reading/arch.webp',
                  fit: BoxFit.fill,
                  color: copper == null
                      ? null
                      : p.c(
                          RateelColors.archShoulder,
                          RateelColors.readLCopper,
                        ),
                  colorBlendMode: copper == null ? null : BlendMode.srcIn,
                ),
              ),
            ),
          Positioned(
            left: cx + u * s.mosqueDx,
            top: u * s.mosqueTop,
            width: u * s.mosqueW,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.55, 1],
                colors: [Color(0xFF000000), Color(0x00000000)],
              ).createShader(r),
              child: ColorFiltered(
                colorFilter: p.t > 0.5
                    ? const ColorFilter.mode(
                        RateelColors.readLMosque,
                        BlendMode.srcIn,
                      )
                    : lessonMosqueTone,
                child: Image.asset('assets/ui/decor/mosque.webp'),
              ),
            ),
          ),
          if (s.book)
            Positioned(
              left: cx - u * s.bookW / 2,
              top: u * s.bookTop,
              width: u * s.bookW,
              height: u * s.bookH,
              child: s.emblem != null
                  ? Image.asset(
                      s.emblem!,
                      fit: BoxFit.contain,
                      color: p.t > 0
                          ? p.c(
                              RateelColors.glyphGoldTop,
                              RateelColors.readLBook,
                            )
                          : null,
                      colorBlendMode: p.t > 0 ? BlendMode.srcIn : null,
                    )
                  : SvgPicture.asset(
                      'assets/ui/decor/header_book.svg',
                      colorFilter: p.t > 0
                          ? ColorFilter.mode(
                              p.c(
                                RateelColors.glyphGoldTop,
                                RateelColors.readLBook,
                              ),
                              BlendMode.srcIn,
                            )
                          : null,
                    ),
            ),
          // Crescent and star as two pieces of the 03 asset, each placed on
          // the reference; colours as the app (star at 55%, as 03/05).
          Positioned(
            left: cx + u * s.crescentDx,
            top: u * s.crescentTop,
            height: u * s.crescentH,
            child: SvgPicture.asset(
              'assets/ui/reading/crescent.svg',
              colorFilter: lightTint(RateelColors.readLCrescent),
            ),
          ),
          Positioned(
            left: cx + u * s.starDx,
            top: u * s.starTop,
            height: u * s.starH,
            child: Opacity(
              opacity: p.d(s.starOpacity, 1),
              child: SvgPicture.asset(
                'assets/ui/reading/star.svg',
                colorFilter: lightTint(RateelColors.readLCrescent),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: u * (s.titleCentre - 6),
            height: u * 12,
            child: Center(child: _title()),
          ),
          if (subtitle != null && s.subtitleSize > 0)
            Positioned(
              left: 0,
              right: 0,
              top: u * (s.subtitleCentre - 3),
              height: u * 6,
              child: Center(
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      readex(
                        u * s.subtitleSize,
                        weight: 400,
                        color: p.c(
                          s.subtitleColor ?? RateelColors.leaderText,
                          RateelColors.readLInk,
                        ),
                      ).copyWith(
                        height: 1.2,
                        shadows: p.t > 0.5
                            ? null
                            : [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: u * 0.5,
                                  offset: Offset(0, u * 0.15),
                                ),
                              ],
                      ),
                ),
              ),
            ),
          if (s.dividerW > 0)
            Positioned(
              left: cx - u * s.dividerW / 2,
              top: u * s.dividerTop - u * 2,
              width: u * s.dividerW,
              height: u * 4,
              child: p.t > 0
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        p.c(
                          RateelColors.videoDivider,
                          RateelColors.readLCopper,
                        ),
                        BlendMode.srcIn,
                      ),
                      child: GoldDivider(u: u, diamond: s.dividerDiamond),
                    )
                  : GoldDivider(u: u, diamond: s.dividerDiamond),
            ),
        ],
      ),
    );
  }
}

/// Mosque tone of the lesson screens (as 07: dome #4E7743).
final lessonMosqueTone = () {
  const r = 1.32, g = 1.21, b = 1.08;
  return const ColorFilter.matrix([
    r, 0, 0, 0, 0, //
    0, g, 0, 0, 0, //
    0, 0, b, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);
}();

class LessonBadge extends StatelessWidget {
  const LessonBadge({
    super.key,
    required this.p,
    required this.u,
    required this.number,
  });

  final LessonPal p;
  final double u;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/ui/reading/badge_fill.webp',
          color: p.t > 0
              ? p.c(Colors.white, RateelColors.readLBadgeFill)
              : null,
          colorBlendMode: p.t > 0
              ? (p.t > 0.5 ? BlendMode.srcIn : BlendMode.modulate)
              : null,
        ),
        Image.asset(
          'assets/ui/reading/badge_line.webp',
          color: p.t > 0
              ? p.c(RateelColors.goldHighlight, RateelColors.readLCopper)
              : null,
          colorBlendMode: p.t > 0 ? BlendMode.srcIn : null,
        ),
        Center(
          child: Text(
            '$number',
            textDirection: TextDirection.ltr,
            style: readex(
              u * 4.3,
              weight: 600,
              color: p.c(RateelColors.leaderText, RateelColors.readLInk),
            ).copyWith(height: 1.0),
          ),
        ),
      ],
    );
  }
}

/// Rounded rim with a vertical colour change (top light edge → bottom).
class ToolRimPainter extends CustomPainter {
  ToolRimPainter({
    required this.radius,
    required this.width,
    required this.top,
    required this.bottom,
  });

  final double radius;
  final double width;
  final Color top;
  final Color bottom;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(width / 2),
      Radius.circular(radius),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(ToolRimPainter o) =>
      o.top != top ||
      o.bottom != bottom ||
      o.width != width ||
      o.radius != radius;
}

/// The verse card: dark green glass lit from the top, thin bright gold rim
/// with a soft gold glow (light: cream card, tan rim, soft shadow).
class GoldCardPainter extends CustomPainter {
  GoldCardPainter(
    this.p,
    this.u,
    this.radius, {
    this.rimWidth = 0.35,
    this.fill,
  });

  /// Dark-theme fill (top, upper, bottom) when it differs from the 08 card
  /// (screen 10: darker, conflict T3).
  final List<Color>? fill;

  /// Rim width in u (08: 0.35u).
  final double rimWidth;

  final LessonPal p;
  final double u;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    // Glow (dark) / shadow (light), outside the card only.
    canvas.save();
    canvas.clipPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rect.inflate(u * 6))
        ..addRRect(rr),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..color = RateelColors.videoSkipRim.withValues(alpha: 0.38 * (1 - p.t))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.4),
    );
    canvas.drawRRect(
      rr.shift(Offset(0, u * 0.6)),
      Paint()
        ..color = const Color(0xFF8A6A4A).withValues(alpha: 0.22 * p.t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.2),
    );
    canvas.restore();
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.c(
              fill?[0] ?? RateelColors.readCardTop,
              RateelColors.readLCardTop,
            ),
            p.c(
              fill?[1] ?? RateelColors.readCardMid,
              RateelColors.readLCardMid,
            ),
            p.c(
              fill?[2] ?? RateelColors.readCardBottom,
              RateelColors.readLCardBottom,
            ),
          ],
          stops: const [0, 0.28, 1],
        ).createShader(rect),
    );
    final w = u * rimWidth;
    canvas.drawRRect(
      rr.deflate(w / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.c(RateelColors.readCardRim, RateelColors.readLCardRim),
            p.c(RateelColors.readCardRimSide, RateelColors.readLCardRimSide),
            p.c(RateelColors.readCardRim, RateelColors.readLCardRim),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(GoldCardPainter o) =>
      o.p.t != p.t || o.u != u || o.radius != radius || o.rimWidth != rimWidth;
}

/// Crescent of the moon button.
class MoonPainter extends CustomPainter {
  MoonPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = size.center(Offset.zero);
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Path()..addOval(
        Rect.fromCircle(
          center: c + Offset(r * 0.55, -r * 0.35),
          radius: r * 0.82,
        ),
      ),
    );
    canvas.drawPath(moon, Paint()..color = color);
  }

  @override
  bool shouldRepaint(MoonPainter o) => o.color != color;
}
