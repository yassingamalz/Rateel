import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind, lerpDouble;

import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../core/sounds.dart';
import '../leaderboard/leaderboard_screen.dart'
    show GoldRimPainter, LeaderLattice, LeaderRibbon, coinAssets, latticeAsset, ribbonAsset;
import '../theme/rateel_theme.dart';
import 'badge_data.dart';

/// Screen 27, badges (الأوسمة). Reference:
/// docs/flutter/screens/27-badges/reference.webp (1843×853), plan in
/// docs/flutter/screens/27-badges.md. Header, lattice, gold rims and coins are
/// the ones of screen 11 (one style for the whole app). Geometry in
/// u = 1% of the height, measured on the reference (u = 8.53 px).
class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _M {
  _M(this.size) : u = size.height / 100;
  final Size size;
  final double u;

  double get panelTop => u * 23.4; // reference panels' rim at y 200
  double get panelBottom => size.height - u * 5.3;
  double get left => u * 4.2;
  double get leftW => u * 57.6;
  double get gap => u * 3.4;
  double get right => size.width - u * 3.6;
  Rect get leftPanel =>
      Rect.fromLTRB(left, panelTop, left + leftW, panelBottom);
  Rect get rightPanel =>
      Rect.fromLTRB(left + leftW + gap, panelTop, right, panelBottom);

  // Grid (inside the right panel): 4 columns, tiles 27.7u × 24.7u.
  double get gridPad => u * 3.8;
  double get tileGap => u * 3.6;
  double get tileH => u * 24.7;
  double get rowGap => u * 3.0;
  double get tileRadius => u * 3.2;
  double get tabsTop => u * 2.3;
  double get tabsH => u * 6.1;
  double get gridViewTop => u * 9.2;
  double get gridFirstTop => u * 3.1; // tiles start at 12.3u in the panel
  double get gridBottomPad => u * 5.4;
}

class _BadgesScreenState extends State<BadgesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final AnimationController _fx = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  final _scroll = ScrollController();
  BadgeFilter _filter = BadgeFilter.all;
  late int _selected = firstInProgress().id;
  bool _precached = false;

  /// Badge being celebrated: kept «locked» for the order until the end.
  int? _fxId;

  /// Last top-left of every tile, so a tile that leaves the filter fades out
  /// where it was.
  final Map<int, Offset> _lastPos = {};

  @override
  void initState() {
    super.initState();
    badgeEarned.addListener(_onEarned);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    final assets = <String>{
      ribbonAsset,
      latticeAsset,
      coinAssets[0],
      medalAsset(badges.first, locked: true),
      for (final b in badges) medalAsset(b),
    };
    Future.wait([
          for (final a in assets) precacheImage(AssetImage(a), context),
        ])
        .timeout(const Duration(seconds: 2), onTimeout: () => [])
        .whenComplete(() {
          if (!mounted) return;
          _entry.forward().whenComplete(() {
            // The celebration of a badge given before the screen opened.
            if (mounted && badgeEarned.value != null) {
              Future<void>.delayed(const Duration(milliseconds: 500), () {
                if (mounted) _onEarned();
              });
            }
          });
        });
  }

  @override
  void dispose() {
    badgeEarned.removeListener(_onEarned);
    _entry.dispose();
    _fx.dispose();
    _scroll.dispose();
    super.dispose();
  }

  double _iv(double begin, double end, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_entry.value - begin) / (end - begin)).clamp(0.0, 1.0));

  BadgeDef _def(int id) => badges.firstWhere((b) => b.id == id);

  List<BadgeDef> get _list => orderedBadges(_filter, holdLocked: _fxId);

  void _setFilter(BadgeFilter f) {
    if (f == _filter) return;
    Haptics.tap();
    setState(() {
      _filter = f;
      final list = _list;
      if (list.isNotEmpty && !list.any((b) => b.id == _selected)) {
        _selected = list.first.id;
      }
    });
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _pick(BadgeDef b) {
    if (b.id == _selected) return;
    Haptics.tap();
    setState(() => _selected = b.id);
  }

  /// The first time a badge is earned: the locked medal turns gold, a short
  /// gold burst, the check ring pops (plan, «Motion»). One-shot, no endless
  /// animation (PERFORMANCE.md).
  Future<void> _onEarned() async {
    final id = badgeEarned.value;
    if (id == null || _fxId != null || !mounted) return;
    badgeEarned.value = null;
    final b = _def(id);
    if (isEarned(b)) return;
    setState(() {
      _fxId = id;
      _filter = BadgeFilter.all;
      _selected = id;
    });
    // Scroll the tile into view.
    final list = _list;
    final i = list.indexWhere((e) => e.id == id);
    if (i >= 0 && _scroll.hasClients) {
      final m = _M(context.size ?? Size.zero);
      final row = i ~/ 4;
      final top = row * (m.tileH + m.rowGap);
      _scroll.animateTo(
        top.clamp(0.0, _scroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
    _fx.forward(from: 0);
    // The medal turns gold at 24% of the effect.
    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (!mounted) return;
    badgeProgress[id] = b.total;
    Sounds.passed();
    Haptics.success();
    setState(() {});
    await _fx.forward();
    if (!mounted) return;
    setState(() => _fxId = null); // the tile glides to the earned group
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final m = _M(box.biggest);
        final u = m.u;
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 1.2,
              colors: [RateelColors.leaderBgCentre, RateelColors.leaderBg],
            ),
          ),
          child: AnimatedBuilder(
            animation: _entry,
            builder: (context, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  key: const ValueKey('lattice'),
                  left: 0,
                  right: 0,
                  top: 0,
                  height: u * 19,
                  child: Opacity(
                    opacity: _iv(0, 0.35),
                    child: RepaintBoundary(child: LeaderLattice(u: u)),
                  ),
                ),
                Positioned(
                  key: const ValueKey('ribbon'),
                  left: (m.size.width - u * 66.8) / 2,
                  top: u * 1.7 - u * 2 * (1 - _iv(0, 0.3, Curves.easeOutBack)),
                  width: u * 66.8,
                  height: u * 12.0,
                  child: Opacity(
                    opacity: _iv(0, 0.2),
                    child: RepaintBoundary(
                      child: LeaderRibbon(u: u, title: 'الأوسمة'),
                    ),
                  ),
                ),
                Positioned(
                  key: const ValueKey('subtitle'),
                  left: 0,
                  right: 0,
                  top: u * 15.6,
                  height: u * 4.4,
                  child: Opacity(
                    opacity: _iv(0.05, 0.35),
                    child: _Subtitle(u: u),
                  ),
                ),
                Positioned.fromRect(
                  key: const ValueKey('detail'),
                  // The arch rises above the panel's top edge.
                  rect: m.leftPanel.translate(0, u * 1.2 * (1 - _iv(0.1, 0.4))),
                  child: Opacity(
                    opacity: _iv(0.1, 0.4),
                    child: _detailPanel(m),
                  ),
                ),
                Positioned.fromRect(
                  key: const ValueKey('grid-panel'),
                  rect: m.rightPanel.translate(
                    0,
                    u * 1.2 * (1 - _iv(0.15, 0.45)),
                  ),
                  child: Opacity(
                    opacity: _iv(0.15, 0.45),
                    child: _gridPanel(m),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------ left

  Widget _detailPanel(_M m) {
    final u = m.u;
    final b = _def(_selected);
    final earned = isEarned(b);
    return RepaintBoundary(
      child: CustomPaint(
        painter: _DetailPanelPainter(u: u),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          layoutBuilder: (current, previous) => Stack(
            clipBehavior: Clip.none,
            children: [...previous, ?current],
          ),
          child: _Detail(
            key: ValueKey('${b.id}-$earned'),
            u: u,
            badge: b,
            earned: earned,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- right

  Widget _gridPanel(_M m) {
    final u = m.u;
    final radius = BorderRadius.circular(u * 5.3);
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: RateelColors.gold.withValues(alpha: 0.15),
              blurRadius: u * 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: u * 2.2,
              offset: Offset(0, u * 0.6),
            ),
          ],
        ),
        child: CustomPaint(
          foregroundPainter: GoldRimPainter(u: u, radius: u * 5.3),
          child: ClipRRect(
            borderRadius: radius,
            child: ColoredBox(
              color: RateelColors.leaderBg,
              child: LayoutBuilder(
                builder: (context, box) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        key: const ValueKey('grid'),
                        left: 0,
                        right: 0,
                        top: m.gridViewTop,
                        bottom: 0,
                        child: _grid(m, box.maxWidth),
                      ),
                      Positioned(
                        key: const ValueKey('tabs'),
                        right: u * 4.9,
                        top: m.tabsTop,
                        height: m.tabsH,
                        width: box.maxWidth,
                        child: _FilterTabs(
                          u: u,
                          filter: _filter,
                          onPick: _setFilter,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _grid(_M m, double panelW) {
    final u = m.u;
    final list = _list;
    final index = {for (var i = 0; i < list.length; i++) list[i].id: i};
    final tileW = (panelW - m.gridPad * 2 - m.tileGap * 3) / 4;
    Offset posOf(int i) {
      final col = i % 4;
      final row = i ~/ 4;
      return Offset(
        panelW - m.gridPad - (col + 1) * tileW - col * m.tileGap,
        m.gridFirstTop + row * (m.tileH + m.rowGap),
      );
    }

    final rows = (list.length / 4).ceil();
    final height =
        m.gridFirstTop + rows * m.tileH + math.max(0, rows - 1) * m.rowGap +
        m.gridBottomPad;
    final children = <Widget>[];
    for (final b in badges) {
      final i = index[b.id];
      final pos = i == null ? (_lastPos[b.id] ?? Offset.zero) : posOf(i);
      _lastPos[b.id] = pos;
      // Entry: tiles pop in staggered (40 ms apart, plan «Motion»).
      final k = i == null ? 1.0 : _iv(0.3 + i * 0.027, 0.55 + i * 0.027);
      final fxOn = _fxId == b.id;
      children.add(
        AnimatedPositioned(
          key: ValueKey('tile-${b.id}'),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          left: pos.dx,
          top: pos.dy + u * 1.0 * (1 - k),
          width: tileW,
          height: m.tileH,
          child: IgnorePointer(
            ignoring: i == null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: i == null ? 0 : k,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _pick(b),
                child: RepaintBoundary(
                  child: fxOn
                      ? AnimatedBuilder(
                          animation: _fx,
                          builder: (context, _) => _BadgeTile(
                            u: u,
                            badge: b,
                            radius: m.tileRadius,
                            pop: k,
                            fx: _fx.value,
                          ),
                        )
                      : _BadgeTile(
                          u: u,
                          badge: b,
                          radius: m.tileRadius,
                          pop: k,
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    // Selection rim and glow: one overlay that glides between the tiles.
    final si = index[_selected];
    final sp = si == null ? (_lastPos[-1] ?? Offset.zero) : posOf(si);
    if (si != null) _lastPos[-1] = sp;
    children.add(
      AnimatedPositioned(
        key: const ValueKey('rim'),
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
        left: sp.dx,
        top: sp.dy,
        width: tileW,
        height: m.tileH,
        child: IgnorePointer(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: si == null ? 0 : _iv(0.5, 0.75),
            child: _SelectionRim(u: u, radius: m.tileRadius),
          ),
        ),
      ),
    );
    return ScrollConfiguration(
      behavior: const _DragScroll(),
      child: SingleChildScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: height,
          child: Stack(clipBehavior: Clip.none, children: children),
        ),
      ),
    );
  }
}

class _DragScroll extends ScrollBehavior {
  const _DragScroll();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };

  @override
  Widget buildScrollbar(context, child, details) => child;
}

// ---------------------------------------------------------------- subtitle

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    Widget line(bool fadeLeft) => SizedBox(
      width: u * 11.5,
      height: math.max(1.0, u * 0.16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              RateelColors.dividerEndClear,
              RateelColors.dividerMid,
            ],
            begin: fadeLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: fadeLeft ? Alignment.centerRight : Alignment.centerLeft,
          ),
        ),
      ),
    );
    Widget diamond() => Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: u * 1.05,
        height: u * 1.05,
        decoration: BoxDecoration(
          border: Border.all(
            color: RateelColors.dividerPeak,
            width: math.max(1.0, u * 0.18),
          ),
        ),
      ),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          line(true),
          SizedBox(width: u * 0.5),
          diamond(),
          SizedBox(width: u * 2.6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'مجموعة الأوسمة التي تحصل عليها في رحلتك في تعلم التجويد',
                  maxLines: 1,
                  style: readex(
                    u * 3.15,
                    weight: 380,
                    color: RateelColors.leaderText.withValues(alpha: 0.92),
                  ).copyWith(shadows: titleShadows(u)),
                ),
              ),
            ),
          ),
          SizedBox(width: u * 2.6),
          diamond(),
          SizedBox(width: u * 0.5),
          line(false),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------- filter tabs

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.u,
    required this.filter,
    required this.onPick,
  });
  final double u;
  final BadgeFilter filter;
  final ValueChanged<BadgeFilter> onPick;

  static const _labels = ['الكل', 'مكتسبة', 'غير مكتسبة'];
  // Reference pill widths (172 / 197 / 214 px at u = 8.53).
  static const _widths = [20.2, 23.1, 25.1];
  static const _gap = 2.6;

  @override
  Widget build(BuildContext context) {
    final lefts = <double>[]; // from the right edge, RTL order
    var x = 0.0;
    for (final w in _widths) {
      lefts.add(x);
      x += (w + _gap) * u;
    }
    final sel = filter.index;
    final h = u * 6.1;
    final lineW = math.max(1.0, u * 0.2);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var i = 0; i < 3; i++)
          Positioned(
            right: lefts[i],
            top: 0,
            width: _widths[i] * u,
            height: h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(h / 2),
                border: Border.all(color: RateelColors.rowRim, width: lineW),
              ),
            ),
          ),
        // The gold pill glides to the chosen filter.
        AnimatedPositioned(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeInOutCubic,
          right: lefts[sel],
          top: 0,
          width: _widths[sel] * u,
          height: h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(h / 2),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [RateelColors.setGoldTop, RateelColors.setGoldBottom],
              ),
              boxShadow: [
                BoxShadow(
                  color: RateelColors.gold.withValues(alpha: 0.18),
                  blurRadius: u * 1.4,
                ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < 3; i++)
          Positioned(
            right: lefts[i],
            top: 0,
            width: _widths[i] * u,
            height: h,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick(BadgeFilter.values[i]),
              child: Center(
                // Readex sets Arabic low: lift it 0.45u (LESSONS-LEARNED).
                child: Transform.translate(
                  offset: Offset(0, -u * 0.45),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: readex(
                      u * 3.0,
                      weight: i == sel ? 560 : 420,
                      color: i == sel
                          ? RateelColors.countText
                          : RateelColors.leaderText,
                    ),
                    child: Text(_labels[i]),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------------ tile

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.u,
    required this.badge,
    required this.radius,
    required this.pop,
    this.fx,
  });
  final double u;
  final BadgeDef badge;
  final double radius;
  final double pop;

  /// 0…1 while this tile's badge is being earned.
  final double? fx;

  @override
  Widget build(BuildContext context) {
    final fxv = fx;
    final earned = isEarned(badge);
    // Locked → gold: the padlock medal lifts and fades, the gold one pops.
    final s = fxv == null ? (earned ? 1.0 : 0.0) : Curves.easeOut.transform(
      ((fxv - 0.2) / 0.3).clamp(0.0, 1.0),
    );
    final medalH = u * 16.4;
    Widget medal(String asset, {double scale = 1, double opacity = 1}) =>
        Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: Image.asset(
              asset,
              height: medalH,
              filterQuality: FilterQuality.medium,
            ),
          ),
        );
    final poppedScale = fxv == null
        ? 1.0
        : 1 + 0.16 * math.sin(((fxv - 0.2) / 0.5).clamp(0.0, 1.0) * math.pi);
    final checkK = fxv == null
        ? (earned ? 1.0 : 0.0)
        : Curves.easeOutBack.transform(((fxv - 0.35) / 0.3).clamp(0.0, 1.0));
    return Transform.scale(
      scale: lerpDouble(0.85, 1, pop.clamp(0.0, 1.0))!,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: RateelColors.badgeTileFill,
          border: Border.all(
            color: RateelColors.tileRim,
            width: math.max(1.0, u * 0.24),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: u * 2.1,
              height: medalH,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (s < 1)
                      Transform.translate(
                        offset: Offset(0, -u * 1.5 * s),
                        child: medal(
                          medalAsset(badge, locked: true),
                          scale: 1 + 0.12 * s,
                          opacity: 1 - s,
                        ),
                      ),
                    if (s > 0)
                      medal(
                        medalAsset(badge),
                        scale: lerpDouble(0.8, 1, s)! * poppedScale,
                        opacity: s,
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: u * 0.8,
              right: u * 0.8,
              top: u * 17.9,
              height: u * 5.2,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    badge.name,
                    maxLines: 1,
                    style: readex(
                      u * 2.9,
                      weight: 500,
                      color: RateelColors.leaderText,
                    ).copyWith(shadows: titleShadows(u)),
                  ),
                ),
              ),
            ),
            // Check ring, top right (reference): 5.2u, centre 4.1u / 3.6u from
            // the corner.
            Positioned(
              right: u * 1.5,
              top: u * 1.0,
              width: u * 5.2,
              height: u * 5.2,
              child: Transform.scale(
                scale: checkK,
                child: Opacity(
                  opacity: checkK.clamp(0.0, 1.0),
                  child: CustomPaint(painter: _CheckRingPainter(u: u)),
                ),
              ),
            ),
            if (fxv != null && fxv > 0.2 && fxv < 1)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BurstPainter(
                      u: u,
                      t: ((fxv - 0.2) / 0.8).clamp(0.0, 1.0),
                      centre: Offset(0, u * 2.1 + medalH * 0.45),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Thin gold ring with a check, as the reference (dark inside, light check).
class _CheckRingPainter extends CustomPainter {
  _CheckRingPainter({required this.u});
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r - u * 0.14,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.28
        ..color = RateelColors.leaderRing,
    );
    final p = Path()
      ..moveTo(c.dx - u * 1.55, c.dy + u * 0.05)
      ..lineTo(c.dx - u * 0.45, c.dy + u * 1.15)
      ..lineTo(c.dx + u * 1.6, c.dy - u * 1.1);
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.42
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = RateelColors.leaderRimCore,
    );
  }

  @override
  bool shouldRepaint(_CheckRingPainter old) => old.u != u;
}

/// One expanding gold ring and eight sparks that fly out and fade (t 0…1).
/// [centre].dx is ignored: the burst is centred horizontally in the tile.
class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.u, required this.t, required this.centre});
  final double u;
  final double t;
  final Offset centre;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, centre.dy);
    final e = Curves.easeOutCubic.transform(t);
    final fade = (1 - t).clamp(0.0, 1.0);
    canvas.drawCircle(
      c,
      u * (5 + 11 * e),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * (1.0 - 0.7 * t)
        ..color = RateelColors.goldHighlight.withValues(alpha: 0.85 * fade),
    );
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + 0.3;
      final d = u * (7 + 9 * e);
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      final s = u * (0.8 - 0.5 * t);
      canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy - s * 1.6)
          ..lineTo(p.dx + s, p.dy)
          ..lineTo(p.dx, p.dy + s * 1.6)
          ..lineTo(p.dx - s, p.dy)
          ..close(),
        Paint()..color = RateelColors.leaderRimCore.withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t || old.u != u;
}

/// Soft gold halo outside the selected tile and an olive-gold glow just inside
/// the rim (reference: #3F561C at the rim, fading to the tile fill by ≈ 2.5u).
/// Clipped, so the tile's own fill is never covered.
class _SelectionGlowPainter extends CustomPainter {
  _SelectionGlowPainter({required this.u, required this.radius});
  final double u;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.save();
    canvas.clipPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect((Offset.zero & size).inflate(u * 6))
        ..addRRect(rr),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..color = RateelColors.gold.withValues(alpha: 0.34)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.0),
    );
    canvas.drawRRect(
      rr.inflate(u * 0.6),
      Paint()
        ..color = RateelColors.gold.withValues(alpha: 0.14)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 2.2),
    );
    canvas.restore();
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRRect(
      rr.deflate(u * 0.3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 1.6
        ..color = RateelColors.badgeTileGlow.withValues(alpha: 0.85)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SelectionGlowPainter old) =>
      old.u != u || old.radius != radius;
}

/// Gold rim and glow of the selected tile (reference: ≈ 4 px bright rim, soft
/// halo). Drawn above the tiles, one instance that glides.
class _SelectionRim extends StatelessWidget {
  const _SelectionRim({required this.u, required this.radius});
  final double u;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SelectionGlowPainter(u: u, radius: radius),
      foregroundPainter: GoldRimPainter(u: u, radius: radius, bright: true),
    );
  }
}

// ------------------------------------------------------------ left panel

/// Arch-topped panel of the reference: gold rim all around, the top edge
/// rises in a pointed ogee at the centre, and a faint second arch runs inside.
class _DetailPanelPainter extends CustomPainter {
  _DetailPanelPainter({required this.u});
  final double u;

  Path _outline(Size size) {
    final r = u * 5.3;
    final cx = size.width / 2;
    final a = u * 6.6; // half width of the arch at the rim
    final h = u * 3.5; // rise of the apex above the rim
    return Path()
      ..moveTo(r, 0)
      ..lineTo(cx - a, 0)
      ..cubicTo(cx - a * 0.5, 0, cx - a * 0.22, -h * 0.5, cx, -h)
      ..cubicTo(cx + a * 0.22, -h * 0.5, cx + a * 0.5, 0, cx + a, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
      ..lineTo(size.width, size.height - r)
      ..arcToPoint(
        Offset(size.width - r, size.height),
        radius: Radius.circular(r),
      )
      ..lineTo(r, size.height)
      ..arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _outline(size);
    // Glow and shadow as the screen-11 panel.
    canvas.drawPath(
      path,
      Paint()
        ..color = RateelColors.gold.withValues(alpha: 0.15)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.0),
    );
    canvas.drawPath(
      path.shift(Offset(0, u * 0.6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.1),
    );
    final bounds = Rect.fromLTWH(0, -u * 3.5, size.width, size.height + u * 3.5);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            RateelColors.badgePanelTop,
            RateelColors.badgePanelMid,
            RateelColors.badgePanelBottom,
          ],
          stops: [0, 0.5, 1],
        ).createShader(bounds),
    );
    // Faint inner arch (the mihrab line of the reference).
    final cx = size.width / 2;
    final inner = Path()
      ..moveTo(u * 0.9, u * 17.5)
      ..cubicTo(u * 1.6, u * 12.5, u * 6.5, u * 8.3, u * 13, u * 7.4)
      ..cubicTo(u * 19, u * 6.6, u * 24, u * 2.6, cx, -u * 2.6)
      ..cubicTo(
        size.width - u * 24,
        u * 2.6,
        size.width - u * 19,
        u * 6.6,
        size.width - u * 13,
        u * 7.4,
      )
      ..cubicTo(
        size.width - u * 6.5,
        u * 8.3,
        size.width - u * 1.6,
        u * 12.5,
        size.width - u * 0.9,
        u * 17.5,
      );
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, u * 0.14)
        ..color = RateelColors.badgeArchLine.withValues(alpha: 0.28),
    );
    // Gold rim: the three strokes of GoldRimPainter (K1) along the outline.
    final w = u * 0.45;
    Paint stroke(double width, Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeJoin = StrokeJoin.round
      ..color = c;
    canvas.drawPath(path, stroke(w, RateelColors.leaderRimEdge));
    canvas.drawPath(path, stroke(w * 0.62, RateelColors.leaderRimCore));
    canvas.drawPath(path, stroke(w * 0.25, RateelColors.leaderRimLight));
  }

  @override
  bool shouldRepaint(_DetailPanelPainter old) => old.u != u;
}

class _Detail extends StatelessWidget {
  const _Detail({
    super.key,
    required this.u,
    required this.badge,
    required this.earned,
  });
  final double u;
  final BadgeDef badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final current = (badgeProgress[badge.id] ?? 0).clamp(0, badge.total);
    final share = current / badge.total;
    const inset = 4.6; // reference: bar and reward box 4.6u from the sides
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Medal: 25.4u high, its top 2.9u under the rim.
        Positioned(
          left: 0,
          right: 0,
          top: u * 2.9,
          height: u * 25.4,
          child: Center(
            child: Image.asset(
              medalAsset(badge, locked: !earned),
              height: u * 25.4,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
        Positioned(
          left: u * 2,
          right: u * 2,
          top: u * 28.8,
          height: u * 6.0,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                badge.name,
                maxLines: 1,
                style: readex(
                  u * 5.2,
                  weight: 600,
                  color: RateelColors.leaderText,
                ).copyWith(shadows: titleShadows(u)),
              ),
            ),
          ),
        ),
        Positioned(
          left: u * inset,
          right: u * inset,
          top: u * 34.0,
          height: u * 9.4,
          child: Center(
            child: Text(
              badge.description,
              textAlign: TextAlign.center,
              style: readex(
                u * 3.0,
                weight: 380,
                color: RateelColors.leaderText.withValues(alpha: 0.92),
              ).copyWith(height: 1.35),
            ),
          ),
        ),
        // «34 / 50» left, bar right (RTL: the bar fills from the right).
        Positioned(
          left: u * 4.9,
          top: u * 45.2,
          height: u * 3.5,
          child: Center(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '$current\u2009/\u2009${badge.total}',
                style: readex(
                  u * 3.4,
                  weight: 600,
                  color: RateelColors.leaderText,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: u * inset,
          top: u * 45.2,
          width: u * 35.4,
          height: u * 3.5,
          child: _ProgressBar(u: u, share: share),
        ),
        Positioned(
          left: u * inset,
          right: u * inset,
          top: u * 52.3,
          height: u * 1.2,
          child: _Divider(u: u),
        ),
        Positioned(
          left: u * inset,
          right: u * inset,
          top: u * 56.0,
          height: u * 11.7,
          child: _RewardBox(u: u, reward: badge.reward),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.u, required this.share});
  final double u;
  final double share;

  @override
  Widget build(BuildContext context) {
    final rim = math.max(1.0, u * 0.14);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 1.75),
        color: RateelColors.badgeBarTrack,
        border: Border.all(
          color: RateelColors.badgeBarRim.withValues(alpha: 0.7),
          width: rim,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(u * 0.32),
        child: LayoutBuilder(
          builder: (context, box) => Align(
            alignment: Alignment.centerRight,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: share),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Container(
                width: box.maxWidth * v,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(u * 1.4),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [RateelColors.setGoldTop, RateelColors.setGoldBottom],
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

class _Divider extends StatelessWidget {
  const _Divider({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    final t = math.max(1.0, u * 0.16);
    Widget line(bool toRight) => Expanded(
      child: Container(
        height: t,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: toRight ? Alignment.centerLeft : Alignment.centerRight,
            end: toRight ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
              RateelColors.dividerEndClear,
              RateelColors.dividerMid,
            ],
          ),
        ),
      ),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          line(true),
          SizedBox(width: u * 0.7),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: u * 1.05,
              height: u * 1.05,
              decoration: BoxDecoration(
                border: Border.all(color: RateelColors.dividerPeak, width: t),
              ),
            ),
          ),
          SizedBox(width: u * 0.7),
          line(false),
        ],
      ),
    );
  }
}

class _RewardBox extends StatelessWidget {
  const _RewardBox({required this.u, required this.reward});
  final double u;
  final String reward;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 3.3),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.badgeRewardTop, RateelColors.badgeRewardBottom],
        ),
        border: Border.all(
          color: RateelColors.badgeRewardRim.withValues(alpha: 0.75),
          width: math.max(1.0, u * 0.16),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: u * 1.0,
            height: u * 3.4,
            child: Center(
              child: Text(
                'المكافأة',
                style: readex(
                  u * 2.9,
                  weight: 520,
                  color: RateelColors.leaderText,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: u * 4.6,
            height: u * 6,
            child: Center(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(coinAssets[0], height: u * 5.6),
                    SizedBox(width: u * 1.0),
                    Text(
                      reward,
                      style: readex(
                        u * 4.2,
                        weight: 700,
                        color: RateelColors.leaderText,
                      ).copyWith(shadows: titleShadows(u)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
