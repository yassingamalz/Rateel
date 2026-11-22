import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/rateel_theme.dart';

// Background layers shared by the learning screens (05 units, 06 lessons).

/// Faint girih lattice over the whole content (owner's U6, seamless tile,
/// tinted `girihLine`).
class ScreenGirih extends StatelessWidget {
  const ScreenGirih({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final tile = box.maxHeight * 0.95;
        final cols = (box.maxWidth / tile).ceil();
        final rows = (box.maxHeight / tile).ceil();
        // The header stays clean: the pattern fades in from 20u to 38u.
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.20, 0.38],
            colors: [Color(0x00000000), Color(0xFF000000)],
          ).createShader(r),
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              maxWidth: cols * tile,
              maxHeight: rows * tile,
              child: Opacity(
                opacity: 0.11,
                child: Column(
                  children: [
                    for (var r = 0; r < rows; r++)
                      Row(
                        children: [
                          for (var c = 0; c < cols; c++)
                            SvgPicture.asset(
                              'assets/ui/decor/girih_tile.svg',
                              width: tile,
                              height: tile,
                              theme: const SvgTheme(
                                currentColor: RateelColors.girihLine,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Owner's corner lattice, tinted to the reference's saturated gold with a
/// soft relief shadow (critic v2).
class GoldCorner extends StatelessWidget {
  const GoldCorner(this.asset, {super.key, required this.u});

  final String asset;
  final double u;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, fit: BoxFit.contain);
    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.translate(
          offset: Offset(u * 0.15, u * 0.25),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color(0x73000000),
              BlendMode.srcIn,
            ),
            child: image,
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [RateelColors.unitCornerTop, RateelColors.unitCornerBottom],
          ).createShader(r),
          child: image,
        ),
      ],
    );
  }
}

/// Same background as screen 03 (one style).
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.85, 1],
          colors: [Color(0x00002D23), RateelColors.contentLift],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.0),
            radius: 1.2,
            colors: [RateelColors.contentTop, RateelColors.contentBottom],
          ),
        ),
      ),
    );
  }
}
