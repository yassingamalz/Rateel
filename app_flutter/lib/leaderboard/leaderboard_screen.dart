import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui' show PointerDeviceKind, lerpDouble;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../theme/rateel_theme.dart';
import 'leaderboard_data.dart';

/// Screen 11, leaderboard (المتصدرين). Reference:
/// docs/flutter/screens/11-leaderboard/reference.webp; behaviour from the
/// Angular original (src/app/features/gamification/leaderboard): three
/// filters, medals for the first three rows, pinned user bar that scrolls to
/// the user's row. Geometry in u = 1% of the height (plan §2).
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

/// Owner's art (ChatGPT prompts A1–A4, 2026-11-24), keyed by
/// tools/assets/leaderboard_assets.py.
const String ribbonAsset = 'assets/ui/leaderboard/ribbon.webp'; // A1
const String latticeAsset = 'assets/ui/leaderboard/lattice.webp'; // A2
const String bookAsset = 'assets/ui/leaderboard/book.webp'; // A4
const List<String> coinAssets = [
  'assets/ui/leaderboard/coins_gold.webp',
  'assets/ui/leaderboard/coins_silver.webp',
  'assets/ui/leaderboard/coins_bronze.webp',
]; // A3

class _Metrics {
  _Metrics(this.size) : u = size.height / 100;
  final Size size;
  final double u;

  // Content box: margins 4.4u, tabs 8.8u, gap 1.8u (reference 1844×853).
  double get margin => u * 3.95; // reference panel rim at x 36
  double get tabsW => u * 8.8;
  double get tabsGap => u * 1.8;
  Rect get panel => Rect.fromLTRB(
    margin,
    u * 18.4,
    size.width - u * 4.4 - tabsW - tabsGap,
    size.height - u * 6.4,
  );
  Rect get tabs => Rect.fromLTRB(
    size.width - u * 4.4 - tabsW,
    u * 19.3,
    size.width - u * 4.4,
    size.height - u * 6.4,
  );

  /// Tap area of the tabs: 1.4u wider on each side (≥ 48 dp on a phone,
  /// critic v1 B1); the drawn tabs keep [tabs].
  double get tabsHitPad => u * 1.4;
  double get headerH => u * 14.05; // reference divider at y 273–275
  // Reference: rows almost touch (pitch 146 px = 17.1u, 2–3 px apart) and
  // sit 0.5u inside the panel rim.
  double get rowH => u * 16.8;
  double get rowGap => u * 0.3;
  double get listTop => u * 0.3;
  double get rowInset => u * 0.5;
  double get pitch => rowH + rowGap;
  double get barH => u * 16.5;
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  bool _precached = false;
  late final AnimationController _highlight = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  final _scroll = ScrollController();
  LeaderboardFilter _filter = LeaderboardFilter.all;
  bool _meVisible = false;
  bool _scrollingToMe = false;
  double _viewportH = 0;

  /// Last top of every player in the list, so a row that leaves the filter
  /// fades out where it was.
  final Map<Player, double> _lastTop = {};

  List<(int, Player)> get _entries => rankedFor(_filter);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_checkMe);
  }

  /// The entry starts once the ribbon, medals and avatars are decoded, so
  /// nothing pops in late (seen in demo v1).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    final assets = <String>[
      ribbonAsset,
      for (final m in medals) 'assets/ui/leaderboard/medal_$m.webp',
      for (final p in players) p.avatarAsset,
      latticeAsset,
      bookAsset,
      ...coinAssets,
    ];
    Future.wait(
      [for (final a in assets.toSet()) precacheImage(AssetImage(a), context)],
    ).timeout(const Duration(seconds: 2), onTimeout: () => []).whenComplete(() {
      if (mounted) _entry.forward();
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    _highlight.dispose();
    _scroll.dispose();
    super.dispose();
  }

  int get _meIndex => _entries.indexWhere((e) => e.$2.isMe);

  void _checkMe() {
    if (_scrollingToMe || !mounted || !_scroll.hasClients) return;
    final i = _meIndex;
    bool visible = false;
    if (i >= 0 && _viewportH > 0) {
      final m = _Metrics(context.size ?? Size.zero);
      final top = m.listTop + i * m.pitch - _scroll.offset;
      visible = top >= -0.5 && top + m.rowH <= _viewportH + 0.5;
    }
    if (visible != _meVisible) {
      setState(() => _meVisible = visible);
      if (visible && !_highlight.isAnimating) _highlight.forward(from: 0);
    }
  }

  void _setFilter(LeaderboardFilter f) {
    if (f == _filter) return;
    Haptics.tap();
    setState(() {
      _filter = f;
      _meVisible = false;
    });
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 400), _checkMe);
    });
  }

  /// Angular `scrollToCurrentUser`: smooth scroll to the own row, then the
  /// gold pulse (1.5 s).
  Future<void> _scrollToMe() async {
    final i = _meIndex;
    if (i < 0 || !_scroll.hasClients) return;
    Haptics.tap();
    final m = _Metrics(context.size!);
    final top = m.listTop + i * m.pitch;
    final target = (top - (_viewportH - m.rowH) / 2).clamp(
      0.0,
      _scroll.position.maxScrollExtent,
    );
    _scrollingToMe = true;
    await _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
    _scrollingToMe = false;
    if (!mounted) return;
    Haptics.milestone();
    setState(() => _meVisible = true);
    _highlight.forward(from: 0);
  }

  /// Entry interval of the controller, eased.
  double _iv(double begin, double end, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_entry.value - begin) / (end - begin)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final m = _Metrics(box.biggest);
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
                  height: u * 19, // reference: full to ≈ 15u, gone by the panel
                  child: Opacity(
                    opacity: _iv(0, 0.35),
                    child: _Lattice(u: u),
                  ),
                ),
                Positioned(
                  key: const ValueKey('ribbon'),
                  left: (m.size.width - u * 69.8) / 2,
                  top: u * 2.9 - u * 2 * (1 - _iv(0, 0.3, Curves.easeOutBack)),
                  width: u * 69.8,
                  height: u * 13.5,
                  child: Opacity(
                    opacity: _iv(0, 0.2),
                    child: _Ribbon(u: u),
                  ),
                ),
                Positioned.fromRect(
                  key: const ValueKey('tabs'),
                  rect: Rect.fromLTRB(
                    m.tabs.left - m.tabsHitPad,
                    m.tabs.top,
                    m.tabs.right + m.tabsHitPad,
                    m.tabs.bottom,
                  ),
                  child: Opacity(
                    opacity: _iv(0.1, 0.4),
                    child: _Tabs(
                      u: u,
                      pad: m.tabsHitPad,
                      filter: _filter,
                      onPick: _setFilter,
                    ),
                  ),
                ),
                Positioned.fromRect(
                  key: const ValueKey('panel'),
                  rect: m.panel.translate(0, u * 1.2 * (1 - _iv(0.1, 0.4))),
                  child: Opacity(opacity: _iv(0.1, 0.4), child: _panel(m)),
                ),
                _bar(m),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _panel(_Metrics m) {
    final u = m.u;
    final radius = BorderRadius.circular(u * 5.3);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        // K1 (provisional): gold rim token, glow gold 15%.
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
        foregroundPainter: _GoldRimPainter(u: u, radius: u * 5.3),
        child: ClipRRect(
          borderRadius: radius,
          child: ColoredBox(
            color: RateelColors.panelBottom,
            child: Column(
              children: [
                SizedBox(
                  height: m.headerH,
                  child: _Header(u: u),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      if (_viewportH != box.maxHeight) {
                        _viewportH = box.maxHeight;
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _checkMe(),
                        );
                      }
                      // Reference: the rows fade out just above the pinned
                      // bar (row 3 dimmed); no fade while the bar is hidden.
                      final barTop =
                          m.size.height -
                          u * 6.6 -
                          m.barH -
                          m.panel.top -
                          m.headerH;
                      final showBar = _meIndex >= 3 && !_meVisible;
                      final f0 = ((barTop - u * 5) / box.maxHeight).clamp(
                        0.0,
                        1.0,
                      );
                      final f1 = (barTop / box.maxHeight).clamp(0.0, 1.0);
                      return ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (r) => LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white.withValues(alpha: showBar ? 0.55 : 1),
                          ],
                          stops: [0, f0, f1],
                        ).createShader(r),
                        child: _list(m, box.maxWidth),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(_Metrics m, double width) {
    final u = m.u;
    final entries = _entries;
    final index = {for (var i = 0; i < entries.length; i++) entries[i].$2: i};
    final rank = {for (final e in entries) e.$2: e.$1};
    final height = m.listTop + entries.length * m.pitch + u * 1.2;
    final children = <Widget>[];
    for (final p in players) {
      final i = index[p];
      final top = i == null ? (_lastTop[p] ?? 0) : m.listTop + i * m.pitch;
      _lastTop[p] = top;
      // Entry: rows stagger in (60 ms apart, slide 1.2u + fade, 300 ms).
      final k = i == null ? 1.0 : _iv(0.25 + i * 0.04, 0.45 + i * 0.04);
      children.add(
        AnimatedPositioned(
          key: ValueKey(p.name),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          left: m.rowInset,
          width: width - m.rowInset * 2,
          top: top + u * 1.2 * (1 - k),
          height: m.rowH,
          child: IgnorePointer(
            ignoring: i == null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: i == null ? 0 : k,
              child: _PlayerRow(
                u: u,
                player: p,
                rank: rank[p] ?? 0,
                place: i ?? 99,
                pop: i == null ? 1 : _iv(0.35 + i * 0.04, 0.6 + i * 0.04),
                shine: i == 0 ? _iv(0.55, 0.95, Curves.easeInOut) : null,
                highlight: p.isMe ? _highlight : null,
              ),
            ),
          ),
        ),
      );
    }
    return ScrollConfiguration(
      behavior: const _DragScroll(),
      child: SingleChildScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: height,
          child: Stack(children: children),
        ),
      ),
    );
  }

  /// Pinned user bar (Angular `current-user-fixed`): visible while the own
  /// row is not, and never when the user is in the first three rows.
  Widget _bar(_Metrics m) {
    final u = m.u;
    final i = _meIndex;
    final show = i >= 3 && !_meVisible;
    final entry = i >= 0 ? _entries[i] : null;
    final k = _iv(0.65, 1.0, Curves.easeOutBack);
    final rect = Rect.fromLTRB(
      m.margin,
      m.size.height - u * 6.6 - m.barH,
      m.panel.right,
      m.size.height - u * 6.6,
    );
    return AnimatedPositioned(
      key: const ValueKey('bar'),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: rect.left,
      width: rect.width,
      top: rect.top + (show ? 0 : u * 3) + u * 8 * (1 - k),
      height: rect.height,
      child: IgnorePointer(
        ignoring: !show,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: show ? _iv(0.65, 0.85) : 0,
          child: entry == null
              ? const SizedBox()
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _scrollToMe,
                  child: _UserBar(u: u, rank: entry.$1, player: entry.$2),
                ),
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

/// Gold rim as the reference (owner 2026-11-24, K1): ≈ 0.6u, dark-gold
/// edges #A89C48, bright core #FCE75A, centre #FFF878; the pinned bar's rim
/// is brighter ([bright]: #F8F27D / #FFFFA8).
class _GoldRimPainter extends CustomPainter {
  _GoldRimPainter({
    required this.u,
    required this.radius,
    this.extra = 0,
    this.bright = false,
  });

  final double u;
  final double radius;
  final double extra;
  final bool bright;

  @override
  void paint(Canvas canvas, Size size) {
    final w = u * 0.45; // reference: 4–5 px at the top, 2–3 px at the sides
    final r1 = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(w / 2),
      Radius.circular(radius - w / 2),
    );
    Paint stroke(double width, Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = c;
    {
      canvas.drawRRect(r1, stroke(w, RateelColors.leaderRimEdge));
      canvas.drawRRect(
        r1,
        stroke(
          w * 0.62,
          bright
              ? RateelColors.leaderRimCoreBright
              : RateelColors.leaderRimCore,
        ),
      );
      canvas.drawRRect(
        r1,
        stroke(
          w * 0.25,
          bright
              ? RateelColors.leaderRimLightBright
              : RateelColors.leaderRimLight,
        ),
      );
    }
    if (extra > 0) {
      canvas.drawRRect(
        r1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * 0.5
          ..color = RateelColors.goldHighlight.withValues(alpha: 0.5 * extra)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(_GoldRimPainter old) =>
      old.u != u || old.radius != radius || old.extra != extra;
}

/// Pale 1 px light along the bottom edge of a row (reference #89A87F).
class _RowBottomLight extends CustomPainter {
  _RowBottomLight({required this.u, required this.radius});
  final double u;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    // Inside the dark edge (drawn by the row's foreground border).
    final edge = math.max(1.0, u * 0.12);
    final w = math.max(1.5, u * 0.22);
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(edge + w / 2),
      Radius.circular(radius - edge),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            RateelColors.leaderRowLight.withValues(alpha: 0),
            RateelColors.leaderRowLight.withValues(alpha: 0),
            RateelColors.leaderRowLight.withValues(alpha: 0.95),
          ],
          stops: const [0, 0.8, 0.97],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_RowBottomLight old) => old.u != u;
}

class _Header extends StatelessWidget {
  const _Header({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    // Course-card title style (critic v1 A2).
    final style = readex(
      u * 4.5, // reference header ≈ 4.5u
      weight: 560,
      color: RateelColors.leaderText,
    ).copyWith(shadows: titleShadows(u));
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        Widget at(double cx, String t) => Positioned(
          left: cx - u * 15,
          width: u * 30,
          top: u * 1.5, // critic v1 A1: 1.15u lower
          bottom: 0,
          child: Center(
            child: Text(t, style: style, textAlign: TextAlign.center),
          ),
        );
        return Stack(
          children: [
            // Header shade: a little darker than the rows (reference #012419).
            Positioned.fill(
              child: ColoredBox(color: RateelColors.leaderHeader),
            ),
            // Right group: المركز over the medal column, المستخدم next to it.
            Positioned(
              right: u * 4.8,
              top: u * 1.5, // critic v1 A1: 1.15u lower
              bottom: 0,
              child: Center(child: Text('المركز المستخدم', style: style)),
            ),
            at(u * 37.5, 'النقاط'),
            at(u * 14.1, 'المكافآت'),
            // Gold divider under the header (reference #DDD88B, ~2 px).
            Positioned(
              left: u * 1.2,
              right: u * 1.2,
              bottom: 0,
              // Reference: 3 px, #DDD88B / #FFFFB8 / #E7E091.
              height: u * 0.38,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: RateelColors.leaderDivider,
                  ),
                ),
              ),
            ),
            SizedBox(width: w),
          ],
        );
      },
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.u,
    required this.player,
    required this.rank,
    required this.place,
    required this.pop,
    this.shine,
    this.highlight,
  });

  final double u;
  final Player player;
  final int rank;

  /// Position in the filtered list: 0–2 get medal and reward (Angular).
  final int place;
  final double pop;
  final double? shine;
  final Animation<double>? highlight;

  @override
  Widget build(BuildContext context) {
    final radius = u * 3.5;
    final me = player.isMe;
    Widget body = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        // Reference rows: darker at the top, lighter green at the bottom.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: me
              ? const [
                  RateelColors.meRowTop,
                  RateelColors.meRowMid,
                  RateelColors.meRowBottom,
                ]
              : RateelColors.leaderRow,
          stops: me ? const [0, 0.35, 1] : const [0, 0.55, 1],
        ),
      ),
      foregroundDecoration: me
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              // Thin dark-green edge, a pale line along the bottom (reference).
              border: Border.all(
                color: RateelColors.leaderRowEdge,
                width: math.max(1.0, u * 0.12),
              ),
            ),
      child: CustomPaint(
        foregroundPainter: me ? null : _RowBottomLight(u: u, radius: radius),
        // Reference: the content sits 0.4u above the row's centre.
        child: Transform.translate(
          offset: Offset(0, -u * 0.4),
          child: _RowContent(
            u: u,
            player: player,
            rank: rank,
            place: place,
            pop: pop,
            shine: shine,
            avatarRight: u * 24.4,
            badgeRight: u * 10.5,
            nameRight: u * 33.7,
            pointsCx: u * 35.7,
            // The user's row keeps the gold rank disc of the bar (critic v1 B2).
            badge: me && place >= 3 ? _GoldRank(u: u, rank: rank) : null,
            trailing: place < 3
                ? _Reward(u: u, place: place)
                : Text(
                    '-',
                    style: readex(
                      u * 4.2,
                      weight: 600,
                      color: RateelColors.leaderText,
                    ),
                  ),
            trailingCx: u * 13.55,
          ),
        ),
      ),
    );
    if (me) {
      final h = highlight;
      body = AnimatedBuilder(
        animation: h ?? const AlwaysStoppedAnimation(0.0),
        builder: (context, child) {
          // Two gold pulses in 1.5 s (Angular highlight-pulse).
          final v = h == null || !h.isAnimating && h.value == 1
              ? 0.0
              : math.sin(h.value * math.pi * 2).abs();
          return CustomPaint(
            foregroundPainter: _GoldRimPainter(
              u: u,
              radius: radius,
              extra: v,
              bright: true,
            ),
            child: child,
          );
        },
        child: body,
      );
    }
    return body;
  }
}

/// Shared content of a row and of the pinned bar (RTL positions from the
/// right edge, LTR groups from the left edge).
class _RowContent extends StatelessWidget {
  const _RowContent({
    required this.u,
    required this.player,
    required this.rank,
    required this.place,
    required this.pop,
    required this.avatarRight,
    required this.badgeRight,
    required this.nameRight,
    required this.pointsCx,
    required this.trailing,
    required this.trailingCx,
    this.shine,
    this.badge,
    this.avatarD = 10.8,
    this.nameSize = 3.8,
    this.pointsDy = 0,
  });

  /// Sizes in u (the pinned bar's are larger in the reference).
  final double avatarD;
  final double nameSize;
  final double pointsDy;

  final double u;
  final Player player;
  final int rank;
  final int place;
  final double pop;
  final double? shine;
  final double avatarRight;
  final double badgeRight;
  final double nameRight;
  final double pointsCx;
  final Widget trailing;
  final double trailingCx;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final avatarD = u * this.avatarD;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Medal / rank number, centred badgeRight from the right edge.
        Positioned(
          right: badgeRight - u * 6,
          width: u * 12,
          top: 0,
          bottom: 0,
          child: Center(
            child:
                badge ??
                Transform.scale(
                  scale: lerpDouble(0.6, 1, pop)!,
                  child: Opacity(
                    opacity: pop.clamp(0.0, 1.0),
                    child: place < 3
                        ? _Medal(u: u, place: place, shine: shine)
                        : _RankDisc(u: u, rank: rank),
                  ),
                ),
          ),
        ),
        Positioned(
          right: avatarRight - avatarD / 2,
          width: avatarD,
          top: 0,
          bottom: 0,
          child: Center(
            child: _Avatar(u: u, d: avatarD, player: player),
          ),
        ),
        Positioned(
          right: nameRight,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: readex(
                  u * nameSize,
                  weight: 440, // thinner strokes, as the reference
                  color: RateelColors.leaderText,
                ).copyWith(shadows: titleShadows(u)),
              ),
              SizedBox(height: u * 2.2), // critic v1 A3
              Transform.translate(
                // Reference: the book sits 0.5u further right than the name.
                offset: Offset(u * 0.5, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Book(u: u),
                    SizedBox(width: u * 1.0),
                    Text(
                      '${player.lessons} درس',
                      // Reference: 3.5u, #E1E1CF (owner: size and brightness).
                      style: readex(
                        u * 3.5,
                        weight: 400,
                        color: RateelColors.leaderText.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          // Star at a fixed place, number left-aligned after it, so every
          // score lines up (critic v1 A5); pointsCx = centre of a 4-digit group.
          left: pointsCx - u * 8.8,
          width: u * 30,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(0, u * pointsDy),
              child: _Points(u: u, score: player.score),
            ),
          ),
        ),
        Positioned(
          left: trailingCx - u * 10,
          width: u * 20,
          top: u * (pointsDy > 0 ? pointsDy * 2 : 0),
          bottom: 0,
          child: Center(child: trailing),
        ),
      ],
    );
  }
}

class _Medal extends StatelessWidget {
  const _Medal({required this.u, required this.place, this.shine});
  final double u;
  final int place;
  final double? shine;

  @override
  Widget build(BuildContext context) {
    Widget img = Image.asset(
      'assets/ui/leaderboard/medal_${medals[place]}.webp',
      height: u * 11,
      color: RateelColors.leaderArtTone,
      colorBlendMode: BlendMode.modulate,
      filterQuality: FilterQuality.medium,
    );
    final s = shine;
    if (s != null && s > 0 && s < 1) {
      // One light sweep across the first medal (entry).
      img = ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (r) => LinearGradient(
          begin: Alignment(-1 + 3 * s - 1, -1),
          end: Alignment(-1 + 3 * s, 1),
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.55),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.3, 0.5, 0.7],
        ).createShader(r),
        child: img,
      );
    }
    return img;
  }
}

/// Rank number of rows 4+ (Angular `rank-number`), on a glass disc.
class _RankDisc extends StatelessWidget {
  const _RankDisc({required this.u, required this.rank});
  final double u;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: u * 7.4,
      height: u * 7.4,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: RateelColors.rowRim,
          width: math.max(1.0, u * 0.23),
        ),
      ),
      child: Text(
        '$rank',
        style: readex(u * 3.6, weight: 600, color: RateelColors.leaderText),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.u, required this.d, required this.player});
  final double u;
  final double d;
  final Player player;

  @override
  Widget build(BuildContext context) {
    final rim = u * 0.47; // reference: 4 px ring
    return SizedBox(
      width: d,
      height: d,
      child: CustomPaint(
        // Reference ring: cream at the top (#FEFEC6), gold on the sides
        // (#F6C840), light gold at the bottom (#FEE476), a dark-gold line
        // inside at the top (#D49302) and a soft gold glow outside.
        foregroundPainter: _AvatarRingPainter(u: u, rim: rim),
        child: Padding(
          padding: EdgeInsets.all(rim),
          child: ClipOval(
            child: Image.asset(
              player.avatarAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarRingPainter extends CustomPainter {
  _AvatarRingPainter({required this.u, required this.rim});
  final double u;
  final double rim;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final box = Rect.fromCircle(center: c, radius: r);
    canvas.save();
    canvas.clipPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(box.inflate(u * 3))
        ..addOval(box),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = RateelColors.gold.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.7),
    );
    canvas.restore();
    canvas.drawCircle(
      c,
      r - rim / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rim
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: RateelColors.leaderAvatarRim,
          stops: [0, 0.5, 1],
        ).createShader(box),
    );
    canvas.drawCircle(
      c,
      r - rim - u * 0.06,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.16
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Reference: a dark-gold inner line all around, strongest on top.
          colors: [
            RateelColors.leaderAvatarInner,
            RateelColors.leaderAvatarInner.withValues(alpha: 0.55),
          ],
          stops: const [0.05, 0.6],
        ).createShader(box),
    );
  }

  @override
  bool shouldRepaint(_AvatarRingPainter old) => old.u != u || old.rim != rim;
}

/// Outline of the tab column: dark-gold on the left, bright on the right.
class _TabOutlinePainter extends CustomPainter {
  _TabOutlinePainter({required this.u, required this.radius});
  final double u;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final w = math.max(1.0, u * 0.12);
    final rr = RRect.fromRectAndCorners(
      (Offset.zero & size).deflate(w / 2),
      topRight: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..shader = const LinearGradient(
          colors: [
            RateelColors.leaderTabOutlineLeft,
            RateelColors.leaderTabOutlineLeft,
            RateelColors.leaderTabOutlineRight,
          ],
          stops: [0, 0.5, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_TabOutlinePainter old) =>
      old.u != u || old.radius != radius;
}

class _Book extends StatelessWidget {
  const _Book({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    return Image.asset(bookAsset, height: u * 3.5);
  }
}

class _Points extends StatelessWidget {
  const _Points({required this.u, required this.score});
  final double u;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: RateelColors.leaderStar,
            ).createShader(r),
            child: SvgPicture.asset(
              'assets/ui/glyphs/star.svg',
              width: u * 6.6,
              height: u * 6.6,
            ),
          ),
          SizedBox(width: u * 1.1),
          Text(
            '$score',
            style: readex(
              u * 4.4,
              weight: 600,
              color: RateelColors.leaderText,
            ).copyWith(shadows: titleShadows(u)),
          ),
        ],
      ),
    );
  }
}

class _Reward extends StatelessWidget {
  const _Reward({required this.u, required this.place});
  final double u;
  final int place;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rewards[place],
            style: readex(
              u * 4.2,
              weight: 600,
              color: RateelColors.leaderText,
            ).copyWith(shadows: titleShadows(u)),
          ),
          SizedBox(width: u * 0.8),
          Image.asset(
            coinAssets[place],
            height: u * 6,
            color: RateelColors.leaderArtTone,
            colorBlendMode: BlendMode.modulate,
          ),
        ],
      ),
    );
  }
}

class _UserBar extends StatelessWidget {
  const _UserBar({required this.u, required this.rank, required this.player});
  final double u;
  final int rank;
  final Player player;

  @override
  Widget build(BuildContext context) {
    final radius = u * 4.1;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            RateelColors.meRowTop,
            RateelColors.meRowMid,
            RateelColors.meRowBottom,
          ],
        ),
        boxShadow: [
          BoxShadow(
            // Reference: ≈ 40% gold glow around the bar (K7).
            color: RateelColors.gold.withValues(alpha: 0.6),
            blurRadius: u * 1.3,
          ),
          // The reference glow reaches ≈ 2.5u around the bar.
          BoxShadow(
            color: RateelColors.gold.withValues(alpha: 0.3),
            blurRadius: u * 3.2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: u * 2.2,
            offset: Offset(0, u * 0.6),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _GoldRimPainter(u: u, radius: radius, bright: true),
        child: _RowContent(
          u: u,
          player: player,
          rank: rank,
          place: 99,
          pop: 1,
          avatarRight: u * 25.0,
          badgeRight: u * 9.5,
          nameRight: u * 34.2,
          pointsCx: u * 35.3,
          avatarD: 11.1,
          nameSize: 4.0,
          pointsDy: -0.7,
          badge: _GoldRank(u: u, rank: rank),
          trailing: _Chevron(u: u),
          trailingCx: u * 12.05,
        ),
      ),
    );
  }
}

/// Rank of the user in the pinned bar: gold disc as the reference (K6).
class _GoldRank extends StatelessWidget {
  const _GoldRank({required this.u, required this.rank});
  final double u;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: u * 9.4,
      height: u * 9.4,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Reference (K6, owner 2026-11-24): warm gold, lighter at the bottom,
        // pale rim lit at the top.
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: RateelColors.leaderDisc,
          stops: [0, 0.55, 1],
        ),
        border: Border.all(color: RateelColors.leaderDiscRim, width: u * 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: u * 0.8,
            offset: Offset(0, u * 0.25),
          ),
        ],
      ),
      child: Text(
        '$rank',
        style: readex(u * 4.0, weight: 700, color: RateelColors.countText),
      ),
    );
  }
}

/// Chevron in a gold ring (reference, K8).
class _Chevron extends StatelessWidget {
  const _Chevron({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: u * 8.9,
    height: u * 8.9,
    child: CustomPaint(painter: _ChevronPainter(u: u)),
  );
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({required this.u});
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect((Offset.zero & size).inflate(u * 4))
      ..addOval(Rect.fromCircle(center: c, radius: r));
    canvas.save();
    canvas.clipPath(outside);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = RateelColors.gold.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u),
    );
    canvas.restore();
    // Reference (K8, owner 2026-11-24): bright 0.3u ring, dark inside.
    canvas.drawCircle(
      c,
      r - u * 0.15,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.3
        ..color = RateelColors.leaderRing,
    );
    final w = u * 1.7;
    final p = Path()
      ..moveTo(c.dx - w, c.dy - w * 0.45)
      ..lineTo(c.dx, c.dy + w * 0.55)
      ..lineTo(c.dx + w, c.dy - w * 0.45);
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = RateelColors.label,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.u != u;
}

/// Vertical filter tabs (Angular `vertical-tabs`): الكل / الأصدقاء / المنطقة.
class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.u,
    required this.pad,
    required this.filter,
    required this.onPick,
  });
  final double u;

  /// Extra tap area on each side (the drawn tabs are inset by it).
  final double pad;
  final LeaderboardFilter filter;
  final ValueChanged<LeaderboardFilter> onPick;

  static const _labels = ['الكل', 'الأصدقاء', 'المنطقة'];

  @override
  Widget build(BuildContext context) {
    final radius = u * 3.0;
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight / 3;
        final sel = filter.index;
        final drawn = Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          // Dark fill + thin pale-gold line; attached to the panel: straight
          // left side, rounded on the right only (reference).
          child: DecoratedBox(
            position: DecorationPosition.background,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(radius),
                bottomRight: Radius.circular(radius),
              ),
              color: Colors.black.withValues(alpha: 0.45),
            ),
            child: CustomPaint(
              foregroundPainter: _TabOutlinePainter(u: u, radius: radius),
              child: Stack(
                children: [
                  for (var i = 1; i < 3; i++)
                    Positioned(
                      left: u * 0.6,
                      right: u * 0.6,
                      top: h * i,
                      height: math.max(1.0, u * 0.15),
                      child: const ColoredBox(
                        color: RateelColors.leaderTabSeparator,
                      ),
                    ),
                  // Gold tab glides to the selected filter (K3: flat amber).
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeInOutCubic,
                    left: 0,
                    right: 0,
                    top: h * sel,
                    height: h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        // Reference gold tab: darker at the top, lit at the
                        // bottom (K3, owner 2026-11-24).
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: RateelColors.leaderTab,
                          stops: [0, 0.3, 0.42, 0.95, 1],
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(radius * 1.4),
                          bottomRight: Radius.circular(radius * 0.8),
                          topLeft: Radius.circular(u * 0.6),
                          bottomLeft: Radius.circular(u * 0.6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: RateelColors.gold.withValues(alpha: 0.15),
                            blurRadius: u * 2,
                          ),
                        ],
                      ),
                      // Reference: shaded left edge, lit right rim.
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(radius * 1.4),
                            bottomRight: Radius.circular(radius * 0.8),
                            topLeft: Radius.circular(u * 0.6),
                            bottomLeft: Radius.circular(u * 0.6),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              RateelColors.leaderTabLeft.withValues(alpha: 0.7),
                              RateelColors.leaderTabLeft.withValues(alpha: 0),
                              RateelColors.leaderTabRight.withValues(alpha: 0),
                              RateelColors.leaderTabRight,
                            ],
                            stops: const [0, 0.18, 0.9, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  for (var i = 0; i < 3; i++)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: h * i,
                      height: h,
                      child: Center(
                        child: RotatedBox(
                          // Reference: the label starts at the bottom.
                          quarterTurns: 1,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: readex(
                              i == sel ? u * 4.6 : u * 4.0, // reference
                              // Reference: inactive labels thinner.
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
                ],
              ),
            ),
          ),
        );
        return Stack(
          children: [
            Positioned.fill(child: drawn),
            for (var i = 0; i < 3; i++)
              Positioned(
                left: 0,
                right: 0,
                top: h * i,
                height: h,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onPick(LeaderboardFilter.values[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          ribbonAsset,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.medium,
        ),
        CustomPaint(
          painter: _RibbonTitle(
            u: u,
            dpr: MediaQuery.devicePixelRatioOf(context),
          ),
        ),
      ],
    );
  }
}

/// Title in the ribbon, arched along the ribbon as the reference (owner
/// 2026-11-24): measured sagitta 1.05u over the text width, letters tilted
/// along the curve (≈ 7° at the ends). The title is drawn once into an image
/// and mapped on a triangle mesh along the arch (no strip seams).
class _RibbonTitle extends CustomPainter {
  _RibbonTitle({required this.u, required this.dpr});
  final double u;
  final double dpr;

  static ui.Image? _image;
  static double _imageKey = -1;

  @override
  void paint(Canvas canvas, Size size) {
    final fs = u * 5.9;
    final tp = TextPainter(
      text: TextSpan(
        text: 'المتصدرين',
        style: TextStyle(
          fontFamily: 'ReadexPro',
          fontSize: fs,
          height: 1.25,
          fontVariations: const [FontVariation('wght', 680)],
          shadows: titleShadows(u),
          foreground: Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                RateelColors.leaderTitleTop,
                RateelColors.leaderTitleBottom,
              ],
            ).createShader(Rect.fromLTWH(0, fs * 0.2, 1, fs * 0.9)),
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    final pad = u * 1.5;
    final w = tp.width + pad * 2;
    final h = tp.height + pad * 2;
    final key = u * 1000 + dpr;
    if (_image == null || _imageKey != key) {
      final rec = ui.PictureRecorder();
      final c = Canvas(rec)..scale(dpr);
      tp.paint(c, Offset(pad, pad));
      _image = rec.endRecording().toImageSync(
        (w * dpr).ceil(),
        (h * dpr).ceil(),
      );
      _imageKey = key;
    }
    final image = _image!;
    final half = tp.width / 2;
    final sag = u * 1.05;
    final cx = size.width / 2;
    final cy = size.height * titleCenter;
    const n = 48;
    final tops = <Offset>[],
        bots = <Offset>[],
        tt = <Offset>[],
        tb = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final x = -w / 2 + w * i / n;
      final dy = sag * (x / half) * (x / half);
      final ang = math.atan(2 * sag * x / (half * half));
      final nrm = Offset(-math.sin(ang), math.cos(ang));
      final p = Offset(cx + x, cy + dy);
      tops.add(p - nrm * (h / 2));
      bots.add(p + nrm * (h / 2));
      final tx = (x + w / 2) * dpr;
      tt.add(Offset(tx, 0));
      tb.add(Offset(tx, h * dpr));
    }
    final pos = <Offset>[], tex = <Offset>[];
    for (var i = 0; i < n; i++) {
      pos.addAll([
        tops[i],
        bots[i],
        tops[i + 1],
        bots[i],
        bots[i + 1],
        tops[i + 1],
      ]);
      tex.addAll([tt[i], tb[i], tt[i + 1], tb[i], tb[i + 1], tt[i + 1]]);
    }
    canvas.drawVertices(
      ui.Vertices(ui.VertexMode.triangles, pos, textureCoordinates: tex),
      BlendMode.srcOver,
      Paint()
        ..shader = ImageShader(
          image,
          TileMode.clamp,
          TileMode.clamp,
          Matrix4.identity().storage,
          filterQuality: FilterQuality.medium,
        ),
    );
  }

  @override
  bool shouldRepaint(_RibbonTitle old) => old.u != u || old.dpr != dpr;
}

/// Vertical centre of the title's middle in the ribbon box (fraction of its
/// height); the ends of the arch sit [sag] lower.
double titleCenter = 0.39;

/// Gold ogee lattice (A2), tiled and faded out downwards (reference: gone by
/// y ≈ 31u). The asset's black is keyed to alpha when it is imported.
class _Lattice extends StatelessWidget {
  const _Lattice({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    // Reference: cells ≈ 8u wide, gold lines with a
    // dark relief shadow under them, full down to ≈ 15u then fading.
    Widget layer(Color color) => Image.asset(
      latticeAsset,
      repeat: ImageRepeat.repeat,
      // The tile holds 4 cells; reference cell ≈ 8u. `fit: none`, or the
      // default scaleDown shrinks the tile to the band's height (v2–v6 bug).
      scale: 512 / (u * 8 * 4),
      fit: BoxFit.none,
      alignment: Alignment.topCenter,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (r) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.8),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 0.92],
        ).createShader(r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(0, u * 0.35),
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: u * 0.15,
                  sigmaY: u * 0.15,
                ),
                child: layer(Colors.black.withValues(alpha: 0.6)),
              ),
            ),
            layer(RateelColors.leaderLattice),
          ],
        ),
      ),
    );
  }
}
