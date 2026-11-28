import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../coming_soon/coming_soon_screen.dart';
import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../core/sounds.dart';
import '../nav/nav_items.dart';
import '../nav/side_nav.dart';
import '../theme/rateel_theme.dart';
import 'challenge_data.dart';

/// Opens screen 12 inside the learning navigator (the side rail stays), from
/// the streak chip of screen 03 (owner Q1 = B).
Route<void> dailyChallengesRoute() => PageRouteBuilder<void>(
  transitionDuration: const Duration(milliseconds: 520),
  reverseTransitionDuration: const Duration(milliseconds: 420),
  pageBuilder: (context, a, b) => const DailyChallengesScreen(),
  transitionsBuilder: (context, a, b, child) {
    final t = Curves.easeOutCubic.transform(a.value);
    return Opacity(
      opacity: t,
      child: Transform.scale(scale: lerpDouble(1.06, 1, t), child: child),
    );
  },
);

/// Geometry of screen 12 in u = 1% of the height, measured on the reference
/// (`screens/12-daily-challenges/reference.webp`, 1844×853, u = 8.53 px; the
/// content box is 1683 px wide, the rail starts there). Horizontal values are
/// offsets from the centre of the content box.
abstract final class ChalMetrics {
  // Header (title centre x 897 px: +6.5u).
  static const headerDx = 6.4;
  // Shared header arch of screen 03 (CR-01) with 03's own proportions
  // (critic v1 H1–H3: the stretched 128×36u arch pinched the dome and its
  // tail cut the mosque), on the title's axis.
  static const archDx = 6.2;
  static const archW = 102.8;
  static const archH = 26.4;
  static const archTop = 0.6;
  // Calendar ink 6.2–17.2u as the reference (6.5–17.1), centred on the title.
  static const calendarDx = 6.2;
  static const calendarTop = 5.8;
  static const calendarH = 11.6;
  static const titleCentre = 22.4; // as 03
  static const titleSize = 7.4;
  static const dividerCentre = 30.7;
  static const dividerW = 38.0; // 03's title divider (critic H7)
  static const subtitleCentre = 35.75;
  static const subtitleSize = 3.9;
  // Mosque and crescent + star: screen 03 standard (from the content edges).
  static const mosqueLeft = 10.5;
  static const mosqueTop = 8.0;
  static const mosqueW = 49.0;
  static const crescentRight = 25.5;
  static const crescentTop = 7.5;
  static const crescentW = 10.65;
  static const crescentH = 9.75;
  // Path: tile centres 199 … 1508 px, first challenge on the right (RTL).
  static const pathDx = 1.4;
  static const pitch = 25.6;
  static const tileCy = 54.6;
  static const tileW = 20.2;
  static const tileH = 21.0;
  static const openScale = 1.07; // open tile 187×184 px vs 172×179
  static const tileRadius = 3.8;
  static const lineCy = 53.6;
  static const iconCy = 51.7;
  static const iconH = 8.2;
  static const iconW = 9.0;
  static const pillCy = 60.4;
  static const pillW = 13.0;
  static const pillH = 5.2;
  static const coinD = 4.2;
  static const numberSize = 3.3;
  // Streak capsule 637–1064 × 615–778 px.
  static const capsuleDx = 1.06;
  static const capsuleCy = 81.65;
  static const capsuleW = 50.0;
  static const capsuleH = 19.1;
  static const discDx = 14.9;
  static const discD = 12.0;
  static const flameH = 7.0;
  static const streakTextRight = 3.1; // right edge of the texts from centre
  static const streakNumberCy = 78.6;
  static const streakNumberSize = 5.6;
  static const streakLabelCy = 85.3;
  static const streakLabelSize = 3.6;
  static const sideLineW = 24.0;
  static const sideLineLeftDx = -38.3;
  static const sideLineRightDx = 39.4;
  static const sideLineCy = 81.4;
}

/// Screen 12, daily challenges (docs/flutter/screens/12-daily-challenges.md).
///
/// Motion: header fades down, tiles pop in one after the other from the right
/// (Angular: scale 0.8 → 1, 300 ms), the light runs along the line to the open
/// tile, the streak capsule rises. Only the open tile breathes, in its own
/// small builder (PERFORMANCE.md).
class DailyChallengesScreen extends StatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

const _mosque = 'assets/ui/decor/mosque.webp';
const _calendar = 'assets/ui/icons/calendar_gold.webp';
const _flame = 'assets/ui/icons/flame_gold_01.webp';
const _coin = 'assets/ui/icons/coin_gold.webp';
const _band = 'assets/ui/video/bottom_band.webp';

class _DailyChallengesScreenState extends State<DailyChallengesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  late final AnimationController _done = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _toast = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  String _toastText = '';
  int _shaking = -1;

  /// Index of the challenge whose completion is playing (null: none).
  int? _completing;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    SideNavScaffold.reselected.addListener(_onReselect);
    _back.addListener(
      () => _drag.value =
          _settleFrom * (1 - Curves.easeOut.transform(_back.value)),
    );
    _entry.addStatusListener((s) {
      if (s == AnimationStatus.completed) _breath.repeat(reverse: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    final assets = [
      _mosque,
      _calendar,
      _flame,
      _coin,
      _band,
      'assets/ui/decor/corner_glow_left.webp',
      'assets/ui/decor/corner_glow_right.webp',
      for (final c in dailyChallenges) c.icon,
    ];
    Future.wait([for (final a in assets) precacheImage(AssetImage(a), context)])
        .timeout(const Duration(seconds: 2), onTimeout: () => [])
        .whenComplete(() {
          if (mounted) _entry.forward();
        });
  }

  @override
  void dispose() {
    SideNavScaffold.reselected.removeListener(_onReselect);
    _drag.dispose();
    _back.dispose();
    _entry.dispose();
    _breath.dispose();
    _done.dispose();
    _shake.dispose();
    _toast.dispose();
    super.dispose();
  }

  Animation<double> _interval(double a, double b, Curve curve) =>
      CurvedAnimation(
        parent: _entry,
        curve: Interval(a, b, curve: curve),
      );

  Future<void> _showToast(String text) async {
    setState(() => _toastText = text);
    await _toast.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (mounted && _toastText == text) await _toast.reverse();
  }

  void _tap(int i) {
    if (_completing != null) return;
    final done = challengesDone.value;
    if (i < done) {
      Haptics.tick();
      _showToast('أكملت هذا التحدي اليوم');
    } else if (i > done) {
      Haptics.denied();
      setState(() => _shaking = i);
      _shake.forward(from: 0);
      _showToast('أكمل التحدي السابق أولًا');
    } else {
      // Owner Q3: the open challenge opens its activity; it is completed when
      // the user comes back having done it (to wire with the real progress).
      Haptics.tap();
      switch (dailyChallenges[i].kind) {
        // Practice → screen 31 (owner, 2026-11-28, plan Q11); the challenge is
        // completed when today's practice is done. Recitation waits for 09.
        case ChallengeKind.practice:
          Navigator.of(context).popUntil((r) => r.isFirst);
          SideNavScaffold.goTo.value = practiceSection;
        case ChallengeKind.recitation:
          Navigator.of(context).push(
            PageRouteBuilder<void>(
              pageBuilder: (context, a, b) => const ComingSoonScreen(),
              transitionsBuilder: (context, a, b, child) =>
                  FadeTransition(opacity: a, child: child),
            ),
          );
        case ChallengeKind.lesson || ChallengeKind.trophy:
          Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }
  }

  /// Review aid: a long press on the open tile completes it.
  Future<void> _complete(int i) async {
    if (_completing != null || i != challengesDone.value) return;
    setState(() => _completing = i);
    Haptics.success();
    Sounds.fill();
    _done.addListener(_unlockHaptic);
    await _done.forward(from: 0);
    _done.removeListener(_unlockHaptic);
    _unlockFired = false;
    completeOpenChallenge();
    if (!mounted) return;
    setState(() => _completing = null);
    _done.value = 0;
    if (challengesDone.value == dailyChallenges.length) {
      _showToast('أحسنت! أتممت تحديات اليوم');
    }
  }

  bool _unlockFired = false;
  void _unlockHaptic() {
    if (!_unlockFired && _done.value > 0.62) {
      _unlockFired = true;
      Haptics.unlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final u = box.maxHeight / 100;
        final cx = box.maxWidth / 2;
        final w = box.maxWidth;
        // Back without a button (owner, 2026-11-26): drag the finger to the
        // right anywhere on the screen, the page follows and closes past 25%
        // of the width or on a fling (same direction that closes the menu).
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
            child: _content(u, cx),
          ),
        );
      },
    );
  }

  /// The courses icon of the rail, tapped while this screen is open, goes
  /// back to the courses (owner, 2026-11-26).
  void _onReselect() {
    if (SideNavScaffold.reselected.value != 0 || _leaving) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    _leaving = true;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  final _drag = ValueNotifier<double>(0);
  late final AnimationController _back = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  bool _leaving = false;
  double _settleFrom = 0;

  void _endDrag(double w, double velocity) {
    if (_leaving) return;
    if (_drag.value > w * 0.25 || velocity > 700) {
      _leaving = true;
      Haptics.tap();
      Navigator.of(context).maybePop();
      return;
    }
    _settleFrom = _drag.value;
    _back.forward(from: 0);
  }

  Widget _content(double u, double cx) {
    return ValueListenableBuilder<int>(
      valueListenable: challengesDone,
      builder: (context, done, _) => Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            key: ValueKey('bg'),
            child: RepaintBoundary(child: ScreenBackground()),
          ),
          Positioned.fill(
            key: const ValueKey('decor'),
            child: RepaintBoundary(child: _Decor(u: u)),
          ),
          Positioned.fill(
            key: const ValueKey('header'),
            child: _fadeDown(
              u,
              RepaintBoundary(
                child: _Header(u: u, cx: cx + u * ChalMetrics.headerDx),
              ),
            ),
          ),
          Positioned.fill(
            key: const ValueKey('line'),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: Listenable.merge([_entry, _done]),
                builder: (context, _) => CustomPaint(
                  painter: _LinePainter(
                    u: u,
                    cx: cx + u * ChalMetrics.pathDx,
                    lit: _litTo(done),
                  ),
                ),
              ),
            ),
          ),
          for (var i = 0; i < dailyChallenges.length; i++)
            _tile(i, done, u, cx),
          Positioned.fill(
            key: const ValueKey('streak'),
            child: _rise(
              u,
              RepaintBoundary(
                child: _Streak(u: u, cx: cx),
              ),
            ),
          ),
          _coinFlight(u, cx),
          _toastLayer(u),
        ],
      ),
    );
  }

  /// How far the light runs along the line, in tile indices from the first
  /// (right) tile: entry grows it to the open tile; a completion carries it on
  /// to the next one.
  double _litTo(int done) {
    final grow = Curves.easeInOutCubic.transform(
      ((_entry.value - 0.5) / 0.32).clamp(0.0, 1.0),
    );
    final open = math.min(done, dailyChallenges.length - 1).toDouble();
    var to = open * grow;
    if (_completing != null) {
      final t = Curves.easeInOutCubic.transform(
        ((_done.value - 0.35) / 0.35).clamp(0.0, 1.0),
      );
      to = open + t;
    }
    return to;
  }

  double _tileX(int i, double u, double cx) =>
      cx + u * (ChalMetrics.pathDx + ChalMetrics.pitch * (3 - i));

  Widget _tile(int i, int done, double u, double cx) {
    final c = dailyChallenges[i];
    final open = i == done;
    final completing = _completing == i;
    // The tile after a completing one turns from locked to open.
    final unlocking = _completing != null && i == _completing! + 1;
    final scale = open && !completing ? ChalMetrics.openScale : 1.0;
    final w = u * ChalMetrics.tileW * scale;
    final h = u * ChalMetrics.tileH * scale;
    final x = _tileX(i, u, cx);
    final y = u * ChalMetrics.tileCy;
    // Angular: nodes pop in (scale 0.8 → 1, 300 ms), here one after the
    // other from the right, 70 ms apart.
    final start = 0.18 + 0.06 * i;
    final pop = _interval(start, start + 0.2, Curves.easeOutBack);
    final fade = _interval(start, start + 0.12, Curves.easeOut);
    Widget tile = _Tile(
      challenge: c,
      u: u,
      state: i < done
          ? _TileState.done
          : open
          ? _TileState.open
          : _TileState.locked,
      breath: open && !completing ? _breath : null,
      completing: completing ? _done : null,
      unlocking: unlocking ? _done : null,
    );
    return Positioned(
      key: ValueKey('tile$i'),
      left: x - w / 2,
      top: y - h / 2,
      width: w,
      height: h,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _tap(i),
        onLongPress: open ? () => _complete(i) : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([pop, _shake]),
          child: RepaintBoundary(child: tile),
          builder: (context, child) {
            final dx = _shaking == i
                ? math.sin(_shake.value * math.pi * 6) *
                      u *
                      0.9 *
                      (1 - _shake.value)
                : 0.0;
            return Opacity(
              opacity: fade.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.scale(
                  scale: 0.8 + 0.2 * pop.value,
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// The tile's coin flies to the flame disc of the streak capsule.
  Widget _coinFlight(double u, double cx) {
    if (_completing == null) {
      return const SizedBox.shrink(key: ValueKey('coin'));
    }
    final i = _completing!;
    final from = Offset(_tileX(i, u, cx) + u * 3.2, u * ChalMetrics.pillCy);
    final to = Offset(cx + u * ChalMetrics.discDx, u * ChalMetrics.capsuleCy);
    final d = u * ChalMetrics.coinD;
    return Positioned.fill(
      key: const ValueKey('coin'),
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _done,
          builder: (context, _) {
            final t = ((_done.value - 0.12) / 0.45).clamp(0.0, 1.0);
            if (t == 0 || t == 1) return const SizedBox.shrink();
            final e = Curves.easeInOutCubic.transform(t);
            // Arc upwards, then down into the disc.
            final p =
                Offset.lerp(from, to, e)! +
                Offset(0, -u * 14 * math.sin(math.pi * e));
            final s = 1 + 0.5 * math.sin(math.pi * e);
            return Stack(
              children: [
                Positioned(
                  left: p.dx - d * s / 2,
                  top: p.dy - d * s / 2,
                  width: d * s,
                  height: d * s,
                  child: Opacity(
                    opacity: t > 0.85 ? (1 - t) / 0.15 : 1,
                    child: const Image(image: AssetImage(_coin)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _fadeDown(double u, Widget child) {
    final a = _interval(0.0, 0.35, Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: a,
      child: child,
      builder: (context, child) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, -u * 3 * (1 - a.value)),
          child: child,
        ),
      ),
    );
  }

  Widget _rise(double u, Widget child) {
    final a = _interval(0.62, 0.95, Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: a,
      child: child,
      builder: (context, child) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, u * 4 * (1 - a.value)),
          child: child,
        ),
      ),
    );
  }

  Widget _toastLayer(double u) {
    return Positioned(
      key: const ValueKey('toast'),
      left: 0,
      right: 0,
      top: u * 3,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _toast,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_toast.value);
            if (t == 0) return const SizedBox.shrink();
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, -u * 2 * (1 - t)),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: u * 3,
                      vertical: u * 1.4,
                    ),
                    decoration: BoxDecoration(
                      color: RateelColors.cardMid.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(u * 3),
                      border: Border.all(
                        color: RateelColors.cardRim,
                        width: u * 0.23,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: u * 2,
                          offset: Offset(0, u * 0.5),
                        ),
                      ],
                    ),
                    child: Text(
                      _toastText,
                      textDirection: TextDirection.rtl,
                      style: readex(
                        u * 3,
                        weight: 400,
                        color: RateelColors.label,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _TileState { open, locked, done }

/// One challenge tile: glass rounded square with a gold rim, the cream glyph
/// and the «50 🪙» pill. Locked tiles are darker than the reference (owner Q2):
/// dark veil, dim rim, no padlock.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.challenge,
    required this.u,
    required this.state,
    this.breath,
    this.completing,
    this.unlocking,
  });

  final Challenge challenge;
  final double u;
  final _TileState state;
  final Animation<double>? breath;
  final Animation<double>? completing;
  final Animation<double>? unlocking;

  @override
  Widget build(BuildContext context) {
    final open = state == _TileState.open;
    final r = BorderRadius.circular(u * ChalMetrics.tileRadius);
    final body = Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: r,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: open
                  ? const [
                      RateelColors.chalOpenTop,
                      RateelColors.chalOpenBottom,
                    ]
                  : const [
                      RateelColors.chalTileTop,
                      RateelColors.chalTileBottom,
                    ],
            ),
            border: open
                ? null
                : Border.all(color: RateelColors.chalRim, width: u * 0.32),
            boxShadow: [
              BoxShadow(
                color: RateelColors.chalRim.withValues(
                  alpha: open ? 0.0 : 0.30,
                ),
                blurRadius: u * 1.0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                offset: Offset(0, u * 0.6),
                blurRadius: u * 1.4,
              ),
            ],
          ),
        ),
        // Open tile rim in three tones (critic T3): dark gold inside, pale
        // core, warm gold outside, ≈ 0.8u.
        if (open) CustomPaint(painter: _OpenRimPainter(u: u)),
        // Inner light along the rim of the open tile (reference: olive glow
        // inside the edge).
        if (open)
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: RadialGradient(
                radius: 0.75,
                colors: [
                  const Color(0x00000000),
                  RateelColors.chalRim.withValues(alpha: 0.22),
                ],
                stops: const [0.6, 1],
              ),
            ),
          ),
        LayoutBuilder(
          builder: (context, box) {
            final k = box.maxHeight / (u * ChalMetrics.tileH);
            final top = box.maxHeight / 2 - u * ChalMetrics.tileH * k / 2;
            double y(double cy) =>
                top +
                (cy - (ChalMetrics.tileCy - ChalMetrics.tileH / 2)) * u * k;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: y(ChalMetrics.iconCy) - u * ChalMetrics.iconH * k / 2,
                  height: u * ChalMetrics.iconH * k,
                  child: Center(
                    child: SizedBox(
                      width: u * ChalMetrics.iconW * k,
                      height: u * ChalMetrics.iconH * k,
                      child: Image.asset(challenge.icon, fit: BoxFit.contain),
                    ),
                  ),
                ),
                Positioned(
                  left: box.maxWidth / 2 - u * ChalMetrics.pillW / 2,
                  top: y(ChalMetrics.pillCy) - u * ChalMetrics.pillH / 2,
                  width: u * ChalMetrics.pillW,
                  height: u * ChalMetrics.pillH,
                  child: _Pill(u: u, points: challenge.points, open: open),
                ),
              ],
            );
          },
        ),
      ],
    );
    final glow = breath == null
        ? null
        : AnimatedBuilder(
            animation: breath!,
            builder: (context, _) {
              final b = Curves.easeInOut.transform(breath!.value);
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: r,
                  boxShadow: [
                    BoxShadow(
                      color: RateelColors.chalRim.withValues(
                        alpha: 0.55 + 0.2 * b,
                      ),
                      blurRadius: u * (1.6 + 0.4 * b),
                      spreadRadius: u * 0.3,
                    ),
                  ],
                ),
              );
            },
          );
    Widget tile = Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [?glow, body],
    );
    if (state == _TileState.locked) {
      // Darker than the reference (owner Q2): veil over the whole tile;
      // it lifts while the previous challenge completes.
      final veil = unlocking;
      tile = Stack(
        fit: StackFit.expand,
        children: [
          tile,
          if (veil == null)
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: r,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            )
          else
            AnimatedBuilder(
              animation: veil,
              builder: (context, _) {
                final t = ((veil.value - 0.62) / 0.3).clamp(0.0, 1.0);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: r,
                    color: Colors.black.withValues(alpha: 0.5 * (1 - t)),
                  ),
                );
              },
            ),
        ],
      );
    }
    if (state == _TileState.done || completing != null) {
      tile = Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          tile,
          Positioned(
            right: -u * 1.4,
            top: -u * 1.4,
            width: u * 5.4,
            height: u * 5.4,
            child: completing == null
                ? _Check(u: u)
                : AnimatedBuilder(
                    animation: completing!,
                    builder: (context, child) {
                      final t = Curves.easeOutBack.transform(
                        (completing!.value / 0.3).clamp(0.0, 1.0),
                      );
                      return Transform.scale(scale: t, child: child);
                    },
                    child: _Check(u: u),
                  ),
          ),
        ],
      );
    }
    return tile;
  }
}

/// Gold check badge of a completed challenge (as the 05 units).
class _Check extends StatelessWidget {
  const _Check({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.badgeTop, RateelColors.amber],
        ),
        border: Border.all(color: RateelColors.goldHighlight, width: u * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: Offset(0, u * 0.3),
            blurRadius: u * 0.8,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(u * 1.25),
        child: SvgPicture.asset(
          'assets/ui/glyphs/check.svg',
          colorFilter: const ColorFilter.mode(
            RateelColors.badgeText,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.u, required this.points, required this.open});

  final double u;
  final int points;
  final bool open;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * ChalMetrics.pillH / 2),
        gradient: open
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [RateelColors.chalPillTop, RateelColors.chalPillBottom],
              ),
        color: open ? RateelColors.chalOpenPill : null,
        border: Border.all(
          color: open ? RateelColors.chalRimLight : RateelColors.chalPillRim,
          width: u * 0.16,
        ),
      ),
      child: Stack(
        children: [
          // «50» left of the coin (reference): number centre −1.9u, coin
          // centre +3.2u from the pill centre.
          Positioned(
            left: 0,
            right: u * (ChalMetrics.pillW / 2 + 1.9 - 3.5),
            top: 0,
            bottom: u * 0.35,
            child: Center(
              child: Text(
                '$points',
                textDirection: TextDirection.ltr,
                style: readex(
                  u * ChalMetrics.numberSize,
                  weight: 500,
                  color: RateelColors.chalText,
                ).copyWith(height: 1.0),
              ),
            ),
          ),
          Positioned(
            left: u * (ChalMetrics.pillW / 2 + 3.2 - ChalMetrics.coinD / 2),
            top: u * (ChalMetrics.pillH - ChalMetrics.coinD) / 2,
            width: u * ChalMetrics.coinD,
            height: u * ChalMetrics.coinD,
            child: const Image(image: AssetImage(_coin)),
          ),
        ],
      ),
    );
  }
}

/// Connector between the tiles: a dim track, lit in gold up to [lit] (tile
/// index from the first, right tile), with a soft glow.
class _LinePainter extends CustomPainter {
  _LinePainter({required this.u, required this.cx, required this.lit});

  final double u;
  final double cx;
  final double lit;

  @override
  void paint(Canvas canvas, Size size) {
    final y = u * ChalMetrics.lineCy;
    double x(double i) => cx + u * ChalMetrics.pitch * (3 - i);
    final n = dailyChallenges.length;
    final t = u * 0.9;
    final track = Paint()
      ..color = RateelColors.chalLineTrack
      ..strokeWidth = t
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x(0), y), Offset(x(n - 1.0), y), track);
    // The reference lights every link: the links up to the open tile are lit,
    // the rest stays a dim track (lines of 03/05, owner's choice B).
    // Before the entry (lit 0) the first short stub next to tile 0 stays dim.
    if (lit <= 0) return;
    final a = Offset(x(0), y);
    final b = Offset(x(lit), y);
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = RateelColors.chalRim.withValues(alpha: 0.75)
        ..strokeWidth = t * 2.4
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.3),
    );
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = RateelColors.chalLine
        ..strokeWidth = t
        ..strokeCap = StrokeCap.round,
    );
    // Pale top edge of the lit line.
    canvas.drawLine(
      a.translate(0, -t * 0.25),
      b.translate(0, -t * 0.25),
      Paint()
        ..color = RateelColors.chalLineEdge
        ..strokeWidth = t * 0.35
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LinePainter o) => o.lit != lit || o.u != u || o.cx != cx;
}

class _Header extends StatelessWidget {
  const _Header({required this.u, required this.cx});

  final double u;
  final double cx;

  @override
  Widget build(BuildContext context) {
    const m = ChalMetrics.headerDx;
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: cx + u * (ChalMetrics.archDx - m - ChalMetrics.archW / 2),
            top: u * ChalMetrics.archTop,
            width: u * ChalMetrics.archW,
            height: u * ChalMetrics.archH,
            // The flanks fade out at the bottom, as on screen 03.
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
              ),
            ),
          ),
          // Mosque and crescent + star: the app standard of screen 03 (same
          // asset, size, place from the content edges and treatment), so they
          // sit in the same place on every screen (owner, 2026-11-25).
          Positioned(
            left: u * ChalMetrics.mosqueLeft,
            top: u * ChalMetrics.mosqueTop,
            width: u * ChalMetrics.mosqueW,
            height: u * ChalMetrics.mosqueW * 542 / 900,
            child: Opacity(
              opacity: 0.83,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.66, 0.80],
                  colors: [Color(0xFF000000), Color(0x00000000)],
                ).createShader(r),
                child: const Image(
                  image: AssetImage(_mosque),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            right: u * ChalMetrics.crescentRight,
            top: u * ChalMetrics.crescentTop,
            width: u * ChalMetrics.crescentW,
            height: u * ChalMetrics.crescentH,
            child: SvgPicture.asset(
              'assets/ui/decor/crescent_star.svg',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left:
                cx +
                u * (ChalMetrics.calendarDx - m) -
                u * ChalMetrics.calendarH / 2,
            top: u * ChalMetrics.calendarTop,
            width: u * ChalMetrics.calendarH,
            height: u * ChalMetrics.calendarH,
            child: const Image(image: AssetImage(_calendar)),
          ),
          Positioned(
            left: cx - u * 60,
            width: u * 120,
            top: u * (ChalMetrics.titleCentre - 6),
            height: u * 12,
            child: Center(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [titleTop, titleBottom],
                ).createShader(r),
                child: Text(
                  'رحلة التحديات اليومية',
                  textAlign: TextAlign.center,
                  style: readex(
                    u * ChalMetrics.titleSize,
                    weight: 600,
                    color: titleCream,
                  ).copyWith(height: 1.2, shadows: titleShadows(u)),
                ),
              ),
            ),
          ),
          Positioned(
            left: cx - u * ChalMetrics.dividerW / 2,
            top: u * (ChalMetrics.dividerCentre - 2.2),
            width: u * ChalMetrics.dividerW,
            height: u * 4.4,
            child: const _TitleDivider(),
          ),
          Positioned(
            left: cx - u * 60,
            width: u * 120,
            top: u * (ChalMetrics.subtitleCentre - 4),
            height: u * 8,
            child: Center(
              child: Text(
                'أكمل التحديات واحصل على المكافآت',
                textAlign: TextAlign.center,
                style: readex(
                  u * ChalMetrics.subtitleSize,
                  weight: 400,
                  color: RateelColors.chalLabel,
                ).copyWith(height: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Streak capsule: «n يوم الاستمرارية» with the flame disc, and the small gold
/// lines with a diamond on both sides.
class _Streak extends StatelessWidget {
  const _Streak({required this.u, required this.cx});

  final double u;
  final double cx;

  @override
  Widget build(BuildContext context) {
    final ccx = cx + u * ChalMetrics.capsuleDx;
    final cy = u * ChalMetrics.capsuleCy;
    final w = u * ChalMetrics.capsuleW;
    final h = u * ChalMetrics.capsuleH;
    final d = u * ChalMetrics.discD;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final dx in [
          ChalMetrics.sideLineLeftDx,
          ChalMetrics.sideLineRightDx,
        ])
          Positioned(
            left: cx + u * (dx - ChalMetrics.sideLineW / 2),
            top: u * (ChalMetrics.sideLineCy - 1.4),
            width: u * ChalMetrics.sideLineW,
            height: u * 2.8,
            child: const _TitleDivider(),
          ),
        Positioned(
          left: ccx - w / 2,
          top: cy - h / 2,
          width: w,
          height: h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(h / 2),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  RateelColors.chalCapsuleTop,
                  RateelColors.chalCapsuleBottom,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: RateelColors.chalRim.withValues(alpha: 0.45),
                  blurRadius: u * 1.8,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  offset: Offset(0, u * 0.6),
                  blurRadius: u * 1.4,
                ),
              ],
            ),
            child: CustomPaint(painter: _RimPainter(u: u)),
          ),
        ),
        // Flame disc.
        Positioned(
          left: cx + u * ChalMetrics.discDx - d / 2,
          top: cy - d / 2,
          width: d,
          height: d,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [RateelColors.chalDisc, RateelColors.chalDiscEdge],
              ),
              border: Border.all(
                color: RateelColors.chalDiscRim,
                width: u * 0.36,
              ),
              boxShadow: [
                BoxShadow(
                  color: RateelColors.chalDiscRim.withValues(alpha: 0.4),
                  blurRadius: u * 1.4,
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                height: u * ChalMetrics.flameH,
                child: const Image(image: AssetImage(_flame)),
              ),
            ),
          ),
        ),
        _rightText(
          ValueListenableBuilder<int>(
            valueListenable: dailyStreak,
            builder: (context, days, _) => Text(
              '$days يوم',
              textDirection: TextDirection.rtl,
              style: readex(
                u * ChalMetrics.streakNumberSize,
                weight: 700,
                color: RateelColors.chalText,
              ).copyWith(height: 1.2),
            ),
          ),
          ChalMetrics.streakNumberCy,
        ),
        _rightText(
          Text(
            'الاستمرارية',
            textDirection: TextDirection.rtl,
            style: readex(
              u * ChalMetrics.streakLabelSize,
              weight: 400,
              color: RateelColors.chalLabel,
            ).copyWith(height: 1.2),
          ),
          ChalMetrics.streakLabelCy,
        ),
      ],
    );
  }

  /// Text whose right edge sits at [ChalMetrics.streakTextRight] from the
  /// content centre, vertically centred on [cy] (u).
  Widget _rightText(Widget child, double cy) => Positioned(
    left: cx - u * 30,
    width: u * (30 + ChalMetrics.streakTextRight),
    top: u * (cy - 5),
    height: u * 10,
    child: Align(alignment: Alignment.centerRight, child: child),
  );
}

/// Bright pale-gold rim of the streak capsule (reference: dark gold outside,
/// pale core, gold inside).
class _RimPainter extends CustomPainter {
  _RimPainter({required this.u});

  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    // Critic S1: warm saturated gold, pale only on top (#FFFE64 → #FAC102),
    // #FFB201 outside, ≈ 0.6u.
    final w = u * 0.65;
    canvas.drawRRect(
      r.deflate(w / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..color = RateelColors.chalCapsuleRimOuter,
    );
    canvas.drawRRect(
      r.deflate(w / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.55
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.chalCapsuleRim, RateelColors.chalCapsuleRimLow],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_RimPainter o) => o.u != u;
}

/// Background ornaments from the shared library (owner, 2026-11-25: one
/// standard set for the whole app): faint lattice corners at the top, and a
/// lattice band at the bottom left and right under a gold wave edge (the
/// reference's shape, drawn in code; the lattice is the 07 band tile).
class _Decor extends StatelessWidget {
  const _Decor({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          clipBehavior: Clip.none,
          children: [
            // Top corners: the screen 03 standard (critic H8): owner's
            // glowing lattice, same place, size, opacity and radial fade.
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
                  opacity: 0.75,
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
                    ),
                  ),
                ),
              ),
            for (final left in [true, false])
              Positioned.fill(
                child: ClipPath(
                  clipper: _WaveClipper(u: u, left: left),
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      _band,
                      repeat: ImageRepeat.repeat,
                      fit: BoxFit.none,
                      scale: 256 / (u * 11.0),
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: CustomPaint(painter: _WaveEdgePainter(u: u)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold wave edge of the bottom band, measured on the reference (px → u):
/// from the side edge at 74u, a small lobe at x 10u, down to 91u at 39u from
/// the edge, reaching the bottom 76u from the edge.
Path _wave(double u, Size size, bool left) {
  Offset p(double x, double y) =>
      Offset(left ? u * x : size.width - u * x, u * y);
  final a = p(0, 74.1);
  final b = p(8.2, 75.0);
  final c = p(10.3, 80.9);
  final d1 = p(12.9, 86.8);
  final d2 = p(23.4, 90.9);
  final d = p(38.7, 91.2);
  final e1 = p(52.8, 91.4);
  final e2 = p(65.6, 93.8);
  final e = p(76.2, 100);
  return Path()
    ..moveTo(a.dx, a.dy)
    ..quadraticBezierTo(b.dx, b.dy, c.dx, c.dy)
    ..cubicTo(d1.dx, d1.dy, d2.dx, d2.dy, d.dx, d.dy)
    ..cubicTo(e1.dx, e1.dy, e2.dx, e2.dy, e.dx, e.dy);
}

class _WaveClipper extends CustomClipper<Path> {
  _WaveClipper({required this.u, required this.left});

  final double u;
  final bool left;

  @override
  Path getClip(Size size) {
    final edge = left ? 0.0 : size.width;
    return _wave(u, size, left)
      ..lineTo(edge, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_WaveClipper o) => o.u != u || o.left != left;
}

class _WaveEdgePainter extends CustomPainter {
  _WaveEdgePainter({required this.u});

  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    for (final left in [true, false]) {
      canvas.drawPath(
        _wave(u, size, left),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * 0.3
          ..color = RateelColors.chalBandEdge,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveEdgePainter o) => o.u != u;
}

/// Small streak chip of screen 03 (owner Q1 = B): the flame disc and «n يوم»
/// in the streak capsule's style; a tap opens the daily challenges.
class StreakChip extends StatefulWidget {
  const StreakChip({
    super.key,
    required this.u,
    required this.onTap,
    this.scale = 1,
    this.label = false,
    this.shape = 'pill',
  });

  /// 'pill' (flame + «n يوم»), 'disc' (round flame disc with a gold count
  /// bubble, as the rail counts), 'column' (flame disc above «n يوم»).
  final String shape;

  final double u;
  final VoidCallback onTap;

  /// Size of the chip relative to v1 (owner, 2026-11-26: v1 too small).
  final double scale;

  /// Second line «الاستمرارية» under «n يوم», as the capsule of screen 12.
  final bool label;

  @override
  State<StreakChip> createState() => _StreakChipState();
}

class _StreakChipState extends State<StreakChip> {
  bool _down = false;

  Widget _tappable(Widget child) => GestureDetector(
    onTapDown: (_) => setState(() => _down = true),
    onTapCancel: () => setState(() => _down = false),
    onTapUp: (_) => setState(() => _down = false),
    onTap: () {
      Haptics.tap();
      widget.onTap();
    },
    child: AnimatedScale(
      scale: _down ? 0.95 : 1,
      duration: const Duration(milliseconds: 120),
      child: child,
    ),
  );

  Widget _flameDisc(double u, double d) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const RadialGradient(
        colors: [RateelColors.chalDisc, RateelColors.chalDiscEdge],
      ),
      border: Border.all(color: RateelColors.chalDiscRim, width: u * 0.3),
      boxShadow: [
        BoxShadow(
          color: RateelColors.chalRim.withValues(alpha: 0.4),
          blurRadius: u * 1.4,
        ),
      ],
    ),
    alignment: Alignment.center,
    child: SizedBox(
      height: d * 0.58,
      child: const Image(image: AssetImage(_flame)),
    ),
  );

  /// Round disc with a count bubble, or a small column card.
  Widget _compact(double u) {
    return ValueListenableBuilder<int>(
      valueListenable: dailyStreak,
      builder: (context, days, _) {
        if (widget.shape == 'disc') {
          final d = u * 11;
          return SizedBox(
            width: d + u * 3,
            height: d + u * 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(left: 0, bottom: 0, child: _flameDisc(u, d)),
                // Count bubble as the rail's (amber, dark text).
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    constraints: BoxConstraints(minWidth: u * 5.4),
                    height: u * 5.4,
                    padding: EdgeInsets.symmetric(horizontal: u * 1.2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: RateelColors.amber,
                      borderRadius: BorderRadius.circular(u * 2.7),
                    ),
                    child: Text(
                      '$days',
                      style: readex(
                        u * 3.2,
                        weight: 700,
                        color: RateelColors.countText,
                      ).copyWith(height: 1.0),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        // Column: disc above «n يوم» (and the label), in a capsule card.
        return Container(
          padding: EdgeInsets.fromLTRB(u * 2.2, u * 1.6, u * 2.2, u * 1.4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(u * 4),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                RateelColors.chalCapsuleTop,
                RateelColors.chalCapsuleBottom,
              ],
            ),
            border: Border.all(
              color: RateelColors.chalCapsuleRimOuter,
              width: u * 0.3,
            ),
            boxShadow: [
              BoxShadow(
                color: RateelColors.chalRim.withValues(alpha: 0.35),
                blurRadius: u * 1.2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _flameDisc(u, u * 7.5),
              SizedBox(height: u * 1.0),
              Text(
                '$days يوم',
                textDirection: TextDirection.rtl,
                style: readex(
                  u * 3.4,
                  weight: 600,
                  color: RateelColors.chalText,
                ).copyWith(height: 1.0),
              ),
              if (widget.label) ...[
                SizedBox(height: u * 0.7),
                Text(
                  'الاستمرارية',
                  textDirection: TextDirection.rtl,
                  style: readex(
                    u * 2.4,
                    weight: 400,
                    color: RateelColors.chalLabel,
                  ).copyWith(height: 1.0),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.u * widget.scale;
    if (widget.shape != 'pill') return _tappable(_compact(u));
    final h = u * (widget.label ? 10.4 : 8.4);
    final d = u * 6.2;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: () {
        Haptics.tap();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: h,
          padding: EdgeInsets.only(left: u * 2.6, right: u * 1.1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(h / 2),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                RateelColors.chalCapsuleTop,
                RateelColors.chalCapsuleBottom,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: RateelColors.chalRim.withValues(alpha: 0.35),
                blurRadius: u * 1.2,
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(h / 2),
            border: Border.all(
              color: RateelColors.chalCapsuleRimOuter,
              width: u * 0.3,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: d,
                height: d,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [RateelColors.chalDisc, RateelColors.chalDiscEdge],
                  ),
                  border: Border.all(
                    color: RateelColors.chalDiscRim,
                    width: u * 0.25,
                  ),
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  height: u * 3.7,
                  child: const Image(image: AssetImage(_flame)),
                ),
              ),
              SizedBox(width: u * 1.6),
              ValueListenableBuilder<int>(
                valueListenable: dailyStreak,
                builder: (context, days, _) => Padding(
                  padding: EdgeInsets.only(bottom: u * 0.45),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$days يوم',
                        textDirection: TextDirection.rtl,
                        style: readex(
                          u * 3.6,
                          weight: 600,
                          color: RateelColors.chalText,
                        ).copyWith(height: 1.0),
                      ),
                      if (widget.label) ...[
                        SizedBox(height: u * 0.9),
                        Text(
                          'الاستمرارية',
                          textDirection: TextDirection.rtl,
                          style: readex(
                            u * 2.6,
                            weight: 400,
                            color: RateelColors.chalLabel,
                          ).copyWith(height: 1.0),
                        ),
                      ],
                    ],
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

/// Title divider of screen 03 (CR-06, `title_divider.svg` with 03's gradient):
/// one divider style for the titles (critic H7, S4).
class _TitleDivider extends StatelessWidget {
  const _TitleDivider();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => const LinearGradient(
        stops: [0, .12, .33, .5, .67, .88, 1],
        colors: [
          Color(0x00B2983A),
          Color(0xFFB2983A),
          Color(0xFFEFC246),
          Color(0xFFF8D053),
          Color(0xFFEFC246),
          Color(0xFFB2983A),
          Color(0x00B2983A),
        ],
      ).createShader(r),
      child: SvgPicture.asset(
        'assets/ui/decor/title_divider.svg',
        fit: BoxFit.fill,
      ),
    );
  }
}

/// Rim of the open tile in three tones (reference: #EBC952→#B47F01 outside,
/// pale #FDFBD1 core, #E9DD97 inside), ≈ 0.8u.
class _OpenRimPainter extends CustomPainter {
  _OpenRimPainter({required this.u});

  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(u * ChalMetrics.tileRadius),
    );
    final w = u * 0.8;
    canvas.drawRRect(
      r.deflate(w / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.chalOpenRimTop, RateelColors.chalOpenRimBottom],
        ).createShader(Offset.zero & size),
    );
    canvas.drawRRect(
      r.deflate(w * 0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.4
        ..color = RateelColors.chalOpenRimCore,
    );
    canvas.drawRRect(
      r.deflate(w * 0.92),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.16
        ..color = RateelColors.chalOpenRimInner,
    );
  }

  @override
  bool shouldRepaint(_OpenRimPainter o) => o.u != u;
}
