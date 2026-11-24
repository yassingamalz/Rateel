import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/screen_decor.dart';
import '../theme/rateel_theme.dart';

/// Screen 14, coming soon (reference `14-in-arrivo.webp`, 1844×853, Angular
/// `coming-soon`). Shown for the sections that do not exist yet: Quran,
/// training, certificates (as the Angular routes).
///
/// Every size is in u = height / 100, measured on the reference (u = 8.53 px).
/// The left column (cards) is anchored to the left edge, the right column
/// (emblem, title) to the rail: extra width on wider phones goes between them.
///
/// Motion (Angular, light): the emblem scales and turns in, the title rises,
/// the cards rise one after the other. One controller, played once: nothing
/// repeats (PERFORMANCE.md).
class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

const _bg = 'assets/ui/coming_soon/background.webp';
const _emblem = 'assets/ui/coming_soon/quran_emblem.webp';
const _frame = 'assets/ui/coming_soon/badge_frame.webp';

class _Feature {
  const _Feature(this.glyph, this.glyphW, this.glyphH, this.title, this.text);
  final String glyph;
  final double glyphW; // glyph box in u, measured on the reference
  final double glyphH;
  final String title;
  final String text;
}

/// Texts from the Angular original (coming-soon.component.html), in the
/// reference's places: RTL, so the first card is on the right.
const _features = [
  _Feature(
    'assets/ui/coming_soon/glyph_headphones.webp',
    6.4,
    5.6,
    'دروس صوتية',
    'استمع إلى تلاوات نموذجية\nمع شرح مفصل للقواعد',
  ),
  _Feature(
    'assets/ui/coming_soon/glyph_microphone.webp',
    4.7,
    7.2,
    'تدريب النطق',
    'تسجيل صوتي وتحليل أدائك\nفي قراءة القرآن',
  ),
  _Feature(
    'assets/ui/coming_soon/glyph_group.webp',
    7.3,
    4.9,
    'جلسات جماعية',
    'تعلم وتدرب مع مجموعات\nأخرى من المتعلمين',
  ),
  _Feature(
    'assets/ui/coming_soon/glyph_certificate.webp',
    5.6,
    5.7,
    'شهادات إتمام',
    'احصل على شهادة معتمدة\nبعد إكمال كل مستوى',
  ),
];

class _ComingSoonScreenState extends State<ComingSoonScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    final assets = [_bg, _emblem, _frame, for (final f in _features) f.glyph];
    Future.wait([for (final a in assets) precacheImage(AssetImage(a), context)])
        .timeout(const Duration(seconds: 2), onTimeout: () => [])
        .whenComplete(() {
          if (mounted) _entry.forward();
        });
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Animation<double> _interval(double a, double b, Curve curve) =>
      CurvedAnimation(parent: _entry, curve: Interval(a, b, curve: curve));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final u = box.maxHeight / 100;
        // Right column centre: 321 px left of the content's right edge.
        final rightCx = w - u * 37.6;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Owner's background (arcs, girih corners, waves, mosque), drawn
            // over the whole content box as in the reference.
            const Positioned.fill(
              child: RepaintBoundary(
                child: Image(
                  image: AssetImage(_bg),
                  fit: BoxFit.fill,
                  color: RateelColors.soonBgTone,
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
            ..._cards(u),
            ..._right(u, rightCx),
          ],
        );
      },
    );
  }

  List<Widget> _right(double u, double cx) {
    final emblem = _interval(0.0, 0.7, Curves.easeOutBack);
    final emblemFade = _interval(0.0, 0.35, Curves.easeOut);
    final text = _interval(0.15, 0.6, Curves.easeOut);
    Widget rise(Widget child) => AnimatedBuilder(
      animation: text,
      child: RepaintBoundary(child: child),
      builder: (context, child) => Opacity(
        opacity: text.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, u * 4.7 * (1 - text.value)),
          child: child,
        ),
      ),
    );
    final half = u * 30;
    return [
      Positioned(
        left: cx - u * 14.05,
        top: u * 7.75,
        width: u * 28.1,
        height: u * 31,
        child: AnimatedBuilder(
          animation: emblem,
          child: const RepaintBoundary(
            child: Image(image: AssetImage(_emblem), fit: BoxFit.fill),
          ),
          builder: (context, child) => Opacity(
            opacity: emblemFade.value.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: -15 * math.pi / 180 * (1 - emblem.value),
              child: Transform.scale(
                scale: 0.5 + 0.5 * emblem.value,
                child: child,
              ),
            ),
          ),
        ),
      ),
      // Two title lines placed one by one: cream glyphs y 333–407, gold 415–505.
      for (final (top, line, color) in [
        (37.9, 'ميزات تجويد', RateelColors.soonTitle),
        (49.7, 'القرآن قريباً', RateelColors.soonTitleGold),
      ])
        Positioned(
          left: cx - half,
          width: half * 2,
          top: u * top,
          child: rise(
            Text(
              line,
              textAlign: TextAlign.center,
              style: readex(
                u * 8.7,
                weight: 700,
                color: color,
              ).copyWith(height: 1.0, shadows: _textShadow(u)),
            ),
          ),
        ),
      Positioned(
        left: cx - u * 21.5,
        width: u * 43,
        top: u * 62.6,
        height: u * 5.2,
        // The reference's ornament is 44 px tall: the shared divider at 1.2×.
        child: rise(GoldDivider(u: u * 1.2)),
      ),
      Positioned(
        left: cx - half,
        width: half * 2,
        top: u * 68.6,
        child: rise(
          Text(
            'نعمل على تطوير ميزات جديدة\nلمساعدتك في تعلم وإتقان قواعد\nالتجويد',
            textAlign: TextAlign.center,
            style: readex(
              u * 3.6,
              weight: 340,
              color: RateelColors.soonSubtitle,
            ).copyWith(height: 1.37),
          ),
        ),
      ),
    ];
  }

  List<Shadow> _textShadow(double u) => [
    Shadow(
      color: const Color(0x66000000),
      offset: Offset(0, u * 0.3),
      blurRadius: u * 0.8,
    ),
  ];

  List<Widget> _cards(double u) {
    // Reference boxes: columns x 84–552 and 579–1045, rows y 77–414 and
    // 440–777 (px at 853).
    const lefts = [67.9, 9.85]; // RTL: first card on the right
    const tops = [9.0, 51.6];
    return [
      for (var i = 0; i < 4; i++)
        Positioned(
          left: u * lefts[i % 2],
          top: u * tops[i ~/ 2],
          width: u * 54.7,
          height: u * 39.5,
          child: _rising(
            i,
            u,
            RepaintBoundary(child: _FeatureCard(feature: _features[i], u: u)),
          ),
        ),
    ];
  }

  /// Angular stagger: 150 ms apart, 500 ms each, rising 30 px.
  Widget _rising(int i, double u, Widget child) {
    final start = 0.25 + 0.107 * i;
    final a = _interval(start, math.min(1, start + 0.36), Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: a,
      child: child,
      builder: (context, child) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, u * 3.5 * (1 - a.value)),
          child: child,
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.u});

  final _Feature feature;
  final double u;

  @override
  Widget build(BuildContext context) {
    final f = feature;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 4.7),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.soonCardTop, RateelColors.soonCardBottom],
        ),
        border: Border.all(color: RateelColors.soonCardRim, width: u * 0.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0x40000000),
            offset: Offset(0, u * 0.6),
            blurRadius: u * 1.6,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lobed gold badge with the glyph (frame 113×123 px at 853).
          Positioned(
            left: 0,
            right: 0,
            top: u * 2.2,
            height: u * 14.4,
            child: Center(
              child: SizedBox(
                width: u * 13.2,
                height: u * 14.4,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(
                      child: Image(image: AssetImage(_frame), fit: BoxFit.fill),
                    ),
                    SizedBox(
                      width: u * f.glyphW,
                      height: u * f.glyphH,
                      child: Image(
                        image: AssetImage(f.glyph),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: u * 17.0,
            child: Text(
              f.title,
              textAlign: TextAlign.center,
              style: readex(
                u * 4.45,
                weight: 650,
                color: RateelColors.soonTitle,
              ).copyWith(height: 1.2),
            ),
          ),
          // Short gold rule, 58×4 px.
          Positioned(
            top: u * 24.9,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: u * 6.8,
                height: u * 0.45,
                decoration: BoxDecoration(
                  color: RateelColors.soonRule,
                  borderRadius: BorderRadius.circular(u * 0.2),
                ),
              ),
            ),
          ),
          Positioned(
            left: u * 2,
            right: u * 2,
            top: u * 26.9,
            child: Text(
              f.text,
              textAlign: TextAlign.center,
              style: readex(
                u * 3.1,
                weight: 400,
                color: RateelColors.soonText,
              ).copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
