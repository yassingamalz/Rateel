import 'dart:math' as math;
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
  double get margin => u * 4.4;
  double get tabsW => u * 8.8;
  double get tabsGap => u * 1.8;
  Rect get panel => Rect.fromLTRB(
    margin,
    u * 18.4,
    size.width - margin - tabsW - tabsGap,
    size.height - u * 6.4,
  );
  Rect get tabs => Rect.fromLTRB(
    size.width - margin - tabsW,
    u * 19.3,
    size.width - margin,
    size.height - u * 6.4,
  );
  double get headerH => u * 13.6;
  double get rowH => u * 16.4;
  double get rowGap => u * 1.2;
  double get rowInset => u * 1.2;
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
      final top = m.rowGap + i * m.pitch - _scroll.offset;
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
    final top = m.rowGap + i * m.pitch;
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
              colors: [RateelColors.bgTop, RateelColors.bgBottom],
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
                  height: u * 31,
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
                  rect: m.tabs,
                  child: Opacity(
                    opacity: _iv(0.1, 0.4),
                    child: _Tabs(u: u, filter: _filter, onPick: _setFilter),
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
                      return _list(m, box.maxWidth);
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
    final height = m.rowGap + entries.length * m.pitch + u * 1.2;
    final children = <Widget>[];
    for (final p in players) {
      final i = index[p];
      final top = i == null ? (_lastTop[p] ?? 0) : m.rowGap + i * m.pitch;
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

/// Gold rim token (goldEdge 0.15u outside + goldHighlight 0.12u inside),
/// conflict K1: thinner than the reference's 4 px rim.
class _GoldRimPainter extends CustomPainter {
  _GoldRimPainter({required this.u, required this.radius, this.extra = 0});

  final double u;
  final double radius;
  final double extra;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = math.max(1.0, u * 0.15);
    final inner = math.max(1.0, u * 0.12);
    final r1 = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(outer / 2),
      Radius.circular(radius - outer / 2),
    );
    canvas.drawRRect(
      r1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = outer
        ..color = RateelColors.goldEdge,
    );
    final r2 = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(outer + inner / 2),
      Radius.circular(radius - outer - inner / 2),
    );
    canvas.drawRRect(
      r2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = inner
        ..color = RateelColors.goldHighlight,
    );
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

class _Header extends StatelessWidget {
  const _Header({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    final style = readex(
      u * 4.0,
      weight: 600,
      color: titleCream,
    ).copyWith(shadows: titleShadows(u));
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        Widget at(double cx, String t) => Positioned(
          left: cx - u * 15,
          width: u * 30,
          top: 0,
          bottom: u * 0.8,
          child: Center(
            child: Text(t, style: style, textAlign: TextAlign.center),
          ),
        );
        return Stack(
          children: [
            // Header shade: a little darker than the rows (reference #012419).
            Positioned.fill(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.12)),
            ),
            // Right group: المركز over the medal column, المستخدم next to it.
            Positioned(
              right: u * 4.8,
              top: 0,
              bottom: u * 0.8,
              child: Center(child: Text('المركز المستخدم', style: style)),
            ),
            at(u * 37.5, 'النقاط'),
            at(u * 14.1, 'المكافآت'),
            // Gold divider under the header (reference #DDD88B, ~2 px).
            Positioned(
              left: u * 1.2,
              right: u * 1.2,
              bottom: 0,
              height: math.max(1.0, u * 0.25),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      RateelColors.goldEdge.withValues(alpha: 0.6),
                      RateelColors.goldHighlight,
                      RateelColors.goldHighlight,
                      RateelColors.goldEdge.withValues(alpha: 0.6),
                    ],
                    stops: const [0, 0.15, 0.85, 1],
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: me
              ? const [
                  RateelColors.meRowTop,
                  RateelColors.meRowMid,
                  RateelColors.meRowBottom,
                ]
              : const [RateelColors.cardTop, RateelColors.cardMid],
        ),
        border: me
            ? null
            : Border.all(
                color: RateelColors.rowRim,
                width: math.max(1.0, u * 0.23),
              ),
      ),
      child: _RowContent(
        u: u,
        player: player,
        rank: rank,
        place: place,
        pop: pop,
        shine: shine,
        avatarRight: u * 23.7,
        badgeRight: u * 9.8,
        nameRight: u * 33,
        pointsCx: u * 36.3,
        trailing: place < 3
            ? _Reward(u: u, place: place)
            : Text('-', style: readex(u * 4.2, weight: 600, color: titleCream)),
        trailingCx: u * 12.9,
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
            foregroundPainter: _GoldRimPainter(u: u, radius: radius, extra: v),
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
  });

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
    final avatarD = u * 10.8;
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
                  u * 3.8,
                  weight: 500,
                  color: titleCream,
                ).copyWith(shadows: titleShadows(u)),
              ),
              SizedBox(height: u * 0.6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Book(u: u),
                  SizedBox(width: u * 1.0),
                  Text(
                    '${player.lessons} درس',
                    style: readex(
                      u * 3.1,
                      weight: 400,
                      color: RateelColors.label.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: pointsCx - u * 12,
          width: u * 24,
          top: 0,
          bottom: 0,
          child: Center(
            child: _Points(u: u, score: player.score),
          ),
        ),
        Positioned(
          left: trailingCx - u * 10,
          width: u * 20,
          top: 0,
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
        style: readex(u * 3.6, weight: 600, color: titleCream),
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
    final rim = u * 0.45;
    return Container(
      width: d,
      height: d,
      padding: EdgeInsets.all(rim),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.goldHighlight, RateelColors.goldEdge],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: u * 1.0,
            offset: Offset(0, u * 0.3),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          player.avatarAsset,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class _Book extends StatelessWidget {
  const _Book({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    return Image.asset(bookAsset, height: u * 3.0);
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
              colors: [RateelColors.glyphGoldTop, RateelColors.glyphGoldBottom],
            ).createShader(r),
            child: SvgPicture.asset(
              'assets/ui/glyphs/star.svg',
              width: u * 5.2,
              height: u * 5.2,
            ),
          ),
          SizedBox(width: u * 1.0),
          Text(
            '$score',
            style: readex(
              u * 4.4,
              weight: 600,
              color: titleCream,
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
              color: titleCream,
            ).copyWith(shadows: titleShadows(u)),
          ),
          SizedBox(width: u * 0.8),
          Image.asset(coinAssets[place], height: u * 6),
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
            color: RateelColors.gold.withValues(alpha: 0.15),
            blurRadius: u * 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: u * 2.2,
            offset: Offset(0, -u * 0.4),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _GoldRimPainter(u: u, radius: radius),
        child: _RowContent(
          u: u,
          player: player,
          rank: rank,
          place: 99,
          pop: 1,
          avatarRight: u * 24.6,
          badgeRight: u * 9.5,
          nameRight: u * 34.2,
          pointsCx: u * 35.2,
          badge: _GoldRank(u: u, rank: rank),
          trailing: _Chevron(u: u),
          trailingCx: u * 11.6,
        ),
      ),
    );
  }
}

/// Rank of the user in the pinned bar: flat gold disc (K6: tokens).
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
        color: RateelColors.amber,
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

/// Chevron in a glass circle (glass button token, as screen 02).
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
    final disc = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          radius: 0.707,
          colors: [
            RateelColors.gold.withValues(alpha: 0.08),
            RateelColors.gold.withValues(alpha: 0.24),
          ],
        ).createShader(disc),
    );
    canvas.drawCircle(
      c,
      r - u * 0.1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.2
        ..color = RateelColors.ringLine,
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
  const _Tabs({required this.u, required this.filter, required this.onPick});
  final double u;
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
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.black.withValues(alpha: 0.25),
            border: Border.all(
              color: RateelColors.rowRim,
              width: math.max(1.0, u * 0.23),
            ),
          ),
          child: Stack(
            children: [
              for (var i = 1; i < 3; i++)
                Positioned(
                  left: u * 0.6,
                  right: u * 0.6,
                  top: h * i,
                  height: math.max(1.0, u * 0.15),
                  child: const ColoredBox(color: RateelColors.divider),
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
                    color: RateelColors.amber,
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: [
                      BoxShadow(
                        color: RateelColors.gold.withValues(alpha: 0.15),
                        blurRadius: u * 2,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    foregroundPainter: _GoldRimPainter(u: u, radius: radius),
                  ),
                ),
              ),
              for (var i = 0; i < 3; i++)
                Positioned(
                  left: 0,
                  right: 0,
                  top: h * i,
                  height: h,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onPick(LeaderboardFilter.values[i]),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: readex(
                            u * 4.0,
                            weight: 600,
                            color: i == sel
                                ? RateelColors.countText
                                : titleCream,
                          ),
                          child: Text(_labels[i]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
        // Title arched as Angular (textPath M30,35 Q100,15 170,35).
        CustomPaint(painter: _ArchedTitle(u: u)),
      ],
    );
  }
}

/// Text along a gentle arch: the laid-out title is drawn in thin vertical
/// strips, each moved and turned along the curve (keeps Arabic shaping).
class _ArchedTitle extends CustomPainter {
  _ArchedTitle({required this.u});
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'المتصدرين',
        style: readex(
          u * 5.9,
          weight: 600,
          color: titleCream,
        ).copyWith(shadows: titleShadows(u)),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    final w = tp.width;
    final h = tp.height;
    // Angular arch: chord 70% of the ribbon, rise 7.1% of the chord.
    final chord = size.width * 0.7;
    final rise = chord * 0.071;
    double dy(double x) =>
        rise * (math.pow(2 * x / chord, 2) - math.pow(w / chord, 2) / 3);
    double slope(double x) => rise * 8 * x / (chord * chord);
    final cx = size.width / 2;
    final cy = size.height * 0.48;
    const n = 60;
    for (var i = 0; i < n; i++) {
      final x0 = -w / 2 + w * i / n;
      final x1 = -w / 2 + w * (i + 1) / n;
      final xc = (x0 + x1) / 2;
      canvas.save();
      canvas.translate(cx + xc, cy + dy(xc));
      canvas.rotate(math.atan(slope(xc)));
      canvas.clipRect(Rect.fromLTRB(x0 - xc - 0.6, -h, x1 - xc + 0.6, h));
      tp.paint(canvas, Offset(-w / 2 - xc, -h / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ArchedTitle old) => old.u != u;
}

/// Gold ogee lattice (A2), tiled and faded out downwards (reference: gone by
/// y ≈ 31u). The asset's black is keyed to alpha when it is imported.
class _Lattice extends StatelessWidget {
  const _Lattice({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (r) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.7),
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(r),
        child: Image.asset(
          latticeAsset,
          repeat: ImageRepeat.repeat,
          // 4 cells per tile, reference cell ≈ 7.9u.
          scale: 512 / (u * 31.6),
          alignment: Alignment.topLeft,
        ),
      ),
    );
  }
}
