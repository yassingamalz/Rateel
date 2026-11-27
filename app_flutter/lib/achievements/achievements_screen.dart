import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../badges/badge_data.dart';
import '../badges/badges_screen.dart'
    show
        ArchPanelPainter,
        BadgesScreen,
        BadgeProgressBar,
        DragScroll,
        GoldDivider,
        RewardBox;
import '../core/haptics.dart';
import '../core/screen_decor.dart' show ScreenGirih;
import '../core/sounds.dart';
import '../gamification/points.dart';
import '../theme/rateel_theme.dart';
import 'achievement_data.dart';
import 'level_screen.dart';

/// Screen 13, achievements (الإنجازات). Reference (visual only):
/// docs/flutter/screens/13-achievements/reference.webp (1844×853), plan in
/// docs/flutter/screens/13-achievements.md. Geometry in u = 1% of the height,
/// measured on the reference (u = 8.53 px). Data from the app (points, levels:
/// `gamification/points.dart`; achievements: `achievement_data.dart`), never
/// from the reference.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  /// Review aid: `?achTab=badges|points|collection` opens that tab at start
  /// (`badges` opens screen 27 above 13).
  static String? startTab;

  /// Review aid: `?pointsTo=950` sets the points once the screen is open
  /// (plays the level-up when a level is crossed).
  static int? pointsTo;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

enum _Tab { achievements, badges, points, collection }

const _tabLabels = ['الإنجازات', 'الأوسمة', 'النقاط', 'المجموعة'];

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final AnimationController _levelFx = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  _Tab _tab = _Tab.achievements;
  bool _precached = false;
  int _level = levelOf(userPoints.value);

  @override
  void initState() {
    super.initState();
    userPoints.addListener(_onPoints);
    switch (AchievementsScreen.startTab) {
      case 'points':
        _tab = _Tab.points;
      case 'collection':
        _tab = _Tab.collection;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    final assets = <String>{
      _blankGold,
      kitPadlock,
      for (final a in achievements) achievementEmblem(a),
    };
    Future.wait(
      [for (final a in assets) precacheImage(AssetImage(a), context)],
    ).timeout(const Duration(seconds: 2), onTimeout: () => []).whenComplete(() {
      if (!mounted) return;
      _entry.forward().whenComplete(() {
        final to = AchievementsScreen.pointsTo;
        if (to != null && mounted) {
          AchievementsScreen.pointsTo = null;
          Future<void>.delayed(const Duration(milliseconds: 400), () {
            if (mounted) userPoints.value = to;
          });
        }
      });
      if (LevelScreen.startLevel != null) {
        final l = LevelScreen.startLevel!;
        LevelScreen.startLevel = null;
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          if (mounted) Navigator.of(context).push(_fade(LevelScreen(level: l)));
        });
      }
      if (AchievementsScreen.startTab == 'badges') {
        AchievementsScreen.startTab = null;
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _openBadges();
        });
      }
    });
  }

  @override
  void dispose() {
    userPoints.removeListener(_onPoints);
    _entry.dispose();
    _levelFx.dispose();
    super.dispose();
  }

  double _iv(double begin, double end, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_entry.value - begin) / (end - begin)).clamp(0.0, 1.0));

  /// Level up: a short gold burst on the level emblem, sound and haptics (the
  /// same as the badge celebration of 27). One-shot, no endless animation.
  void _onPoints() {
    final l = levelOf(userPoints.value);
    if (l > _level) {
      _levelFx.forward(from: 0);
      Sounds.passed();
      Haptics.success();
    }
    setState(() => _level = l);
  }

  void _openBadges() {
    Haptics.tap();
    Navigator.of(context).push(_fade(const BadgesScreen()));
  }

  void _openLevel() {
    Haptics.tap();
    Navigator.of(context).push(_fade(LevelScreen(level: _level)));
  }

  void _pickTab(int i) {
    final t = _Tab.values[i];
    if (t == _Tab.badges) {
      _openBadges(); // 27 opens full screen, the tab keeps its place
      return;
    }
    if (t == _tab) return;
    Haptics.tap();
    setState(() => _tab = t);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final u = box.maxHeight / 100;
        final w = box.maxWidth;
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
                const Positioned.fill(
                  key: ValueKey('girih'),
                  child: RepaintBoundary(
                    child: ScreenGirih(fadeTop: false, opacity: 0.09),
                  ),
                ),
                _header(u, w),
                Positioned(
                  key: const ValueKey('tabs'),
                  left: u * 10.9,
                  right: u * 9.4,
                  top: u * 35.9 + u * 1.2 * (1 - _iv(0.15, 0.5)),
                  height: u * 11.5,
                  child: Opacity(
                    opacity: _iv(0.15, 0.5),
                    child: RepaintBoundary(
                      child: _TabBar(
                        u: u,
                        selected: _tab.index,
                        onPick: _pickTab,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  key: const ValueKey('content'),
                  left: 0,
                  right: 0,
                  top: u * 49.5 + u * 1.2 * (1 - _iv(0.3, 0.7)),
                  bottom: 0,
                  child: Opacity(
                    opacity: _iv(0.3, 0.7),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: ScaleTransition(
                          scale: Tween(begin: 0.96, end: 1.0).animate(a),
                          child: child,
                        ),
                      ),
                      child: switch (_tab) {
                        _Tab.achievements => _AchievementsPager(
                          key: const ValueKey('t-ach'),
                          u: u,
                          onOpen: _showDetail,
                        ),
                        _Tab.points => _PointsTab(
                          key: const ValueKey('t-pts'),
                          u: u,
                        ),
                        _Tab.collection => _CollectionTab(
                          key: const ValueKey('t-col'),
                          u: u,
                          onOpen: _showDetail,
                        ),
                        _Tab.badges => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetail(CollectionItem item) {
    Haptics.tap();
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, a, b) => _DetailDialog(item: item),
      transitionBuilder: (context, a, b, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween(
            begin: 0.94,
            end: 1.0,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- header

  Widget _header(double u, double w) {
    final k = _iv(0, 0.4);
    final points = userPoints.value;
    final level = _level;
    final next = pointsToNext(points);
    return Stack(
      key: const ValueKey('header'),
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: u * 2.9,
          right: u * 4.7,
          top: u * 12.7 + u * 1.2 * (1 - k),
          height: u * 19.9,
          child: Opacity(
            opacity: k,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: ArchPanelPainter(
                  u: u,
                  radiusU: 6.6,
                  archHalfU: 39,
                  archRiseU: 12.7,
                  innerArch: false,
                  dome: true,
                ),
              ),
            ),
          ),
        ),
        // Mosque skyline and crescent in the arch (03 pieces).
        Positioned(
          left: (w - u * 4.7 - u * 2.9) / 2 + u * 2.9 - u * 23,
          top: u * 0.6,
          width: u * 46,
          height: u * 46 * 542 / 900,
          child: Opacity(
            opacity: k,
            child: IgnorePointer(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.62, 0.78],
                  colors: [Color(0xFF000000), Color(0x00000000)],
                ).createShader(r),
                child: Image.asset(
                  'assets/ui/decor/mosque.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        // Points (left): empty gold medal of the library, number in code.
        Positioned(
          left: u * 2.9 + u * 20.9 - u * 10.7,
          top: u * 3.3,
          width: u * 21.4,
          height: u * 21.4 * 512 / 487,
          child: Opacity(
            opacity: k,
            child: _MedalNumber(
              u: u,
              child: _entry.value > 0.12
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: points.toDouble()),
                      duration: const Duration(milliseconds: 750),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => _num(u, v.round(), 6.4),
                    )
                  : _num(u, 0, 6.4),
            ),
          ),
        ),
        Positioned(
          left: u * 2.9 + u * 20.9 - u * 12,
          top: u * 26.9,
          width: u * 24,
          height: u * 4.6,
          child: Opacity(
            opacity: k,
            child: Center(child: _label(u, 'النقاط', 3.9)),
          ),
        ),
        // Level (right): the same medal, smaller; tap opens the level page.
        Positioned(
          right: u * 4.7 + u * 12.9 - u * 9.5,
          top: u * 4.6,
          width: u * 19,
          height: u * 31,
          child: Opacity(
            opacity: k,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openLevel,
              child: Column(
                children: [
                  SizedBox(
                    height: u * 15.5,
                    child: AnimatedBuilder(
                      animation: _levelFx,
                      builder: (context, _) {
                        final t = _levelFx.value;
                        final bump = math.sin(math.pi * t.clamp(0.0, 1.0));
                        return Transform.scale(
                          scale: 1 + 0.22 * bump,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: RateelColors.goldHighlight.withValues(
                                    alpha: 0.55 * bump,
                                  ),
                                  blurRadius: u * 5 * bump,
                                  spreadRadius: u * 1.2 * bump,
                                ),
                              ],
                            ),
                            child: AspectRatio(
                              aspectRatio: 487 / 512,
                              child: _MedalNumber(
                                u: u,
                                child: _num(u, level, 6.8),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: u * 2.2),
                  _label(u, 'المستوى', 3.9),
                  SizedBox(height: u * 0.8),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      next == 0 ? 'المستوى الأقصى' : '$next للتالي',
                      maxLines: 1,
                      style: readex(
                        u * 2.9,
                        weight: 420,
                        color: RateelColors.setGoldTop,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Progress through the level (owner: level progress, not unlocked / total).
        Positioned(
          left: u * 44.5,
          right: u * 4.7 + u * 26.4,
          top: u * 20.85,
          height: u * 3.5,
          child: Opacity(
            opacity: k,
            child: _entry.value > 0.3
                ? BadgeProgressBar(u: u, share: levelShare(points))
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _num(double u, int n, double size) => Directionality(
    textDirection: TextDirection.ltr,
    child: Text(
      '$n',
      maxLines: 1,
      style: readex(u * size, weight: 700, color: RateelColors.countText),
    ),
  );

  Widget _label(double u, String text, double size) => Text(
    text,
    maxLines: 1,
    style: readex(
      u * size,
      weight: 520,
      color: RateelColors.leaderText,
    ).copyWith(shadows: titleShadows(u)),
  );
}

const _blankGold = 'assets/ui/badges/blank_gold.webp';

/// The library's empty gold medal with [child] (a number) on its disc.
class _MedalNumber extends StatelessWidget {
  const _MedalNumber({required this.u, required this.child});
  final double u;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _blankGold,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
        // The disc: centre at 0.5 / 0.40 of the image, 0.62 wide.
        Align(
          alignment: const Alignment(0, -0.2),
          child: FractionallySizedBox(
            widthFactor: 0.62,
            child: AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Transform.translate(
                    offset: Offset(0, -u * 0.3), // Readex sets digits low
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Route<T> _fade<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 260),
  reverseTransitionDuration: const Duration(milliseconds: 200),
  pageBuilder: (context, a, b) => page,
  transitionsBuilder: (context, a, b, child) =>
      FadeTransition(opacity: a, child: child),
);

// -------------------------------------------------------------------- tabs

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.u,
    required this.selected,
    required this.onPick,
  });
  final double u;
  final int selected;
  final ValueChanged<int> onPick;

  static const _icons = [
    'assets/ui/nav/leaderboard.svg',
    'assets/ui/nav/achievements.svg',
    null, // coins: drawn
    'assets/ui/nav/quran.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        final segW = box.maxWidth / 4;
        // RTL: tab 0 at the right edge.
        double rightOf(int i) => i * segW;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(h / 2),
                  color: RateelColors.achTabBar,
                  border: Border.all(
                    color: RateelColors.leaderRowEdge,
                    width: math.max(1.0, u * 0.25),
                  ),
                ),
              ),
            ),
            for (var i = 1; i < 4; i++)
              if (i != selected && i - 1 != selected)
                Positioned(
                  right: rightOf(i) - u * 0.08,
                  top: h * 0.24,
                  width: math.max(1.0, u * 0.16),
                  height: h * 0.52,
                  child: const ColoredBox(color: RateelColors.leaderRowEdge),
                ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOutCubic,
              right: rightOf(selected),
              top: 0,
              width: segW,
              height: h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(h / 2),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      RateelColors.setGoldTop,
                      RateelColors.setGoldBottom,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RateelColors.gold.withValues(alpha: 0.22),
                      blurRadius: u * 1.4,
                    ),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < 4; i++)
              Positioned(
                right: rightOf(i),
                top: 0,
                width: segW,
                height: h,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onPick(i),
                  child: _tabContent(i, i == selected),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _tabContent(int i, bool on) {
    final color = on ? RateelColors.countText : const Color(0xFFF4EAD0);
    final icon = _icons[i];
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // RTL: icon at the right of the label (first child).
            SizedBox(
              width: u * 5.4,
              height: u * 5.4,
              child: icon == null
                  ? CustomPaint(painter: _CoinsPainter(color))
                  : SvgPicture.asset(
                      icon,
                      theme: SvgTheme(currentColor: color),
                      fit: BoxFit.contain,
                    ),
            ),
            SizedBox(width: u * 1.6),
            Transform.translate(
              // Readex sets Arabic low: lift it 0.45u (LESSONS-LEARNED).
              offset: Offset(0, -u * 0.45),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: readex(u * 4.0, weight: on ? 580 : 440, color: color),
                child: Text(_tabLabels[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coins glyph of the tab (3 stacked discs), drawn in code.
class _CoinsPainter extends CustomPainter {
  _CoinsPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final disc = Paint()..color = color;
    final gap = Paint()
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.07;
    final rw = w * 0.92;
    final rh = h * 0.3;
    for (var i = 0; i < 3; i++) {
      final cy = h * (0.78 - i * 0.26);
      final r = Rect.fromCenter(
        center: Offset(w / 2, cy),
        width: rw,
        height: rh,
      );
      canvas.drawOval(r, disc);
      canvas.drawOval(r, gap);
    }
  }

  @override
  bool shouldRepaint(_CoinsPainter old) => old.color != color;
}

// ---------------------------------------------------------------- carousel

/// Pages of [perPage] items with arrows, dots and drag; page 0 at the right
/// (RTL). Arrows: «‹» at the left = next, «›» at the right = previous.
class _Pager extends StatefulWidget {
  const _Pager({
    required this.u,
    required this.count,
    required this.perPage,
    required this.rowTop,
    required this.rowH,
    required this.itemBuilder,
    this.dotsTop = 45.1,
  });

  final double u;
  final int count;
  final int perPage;

  /// In u from the top of the content area, and the height of the row.
  final double rowTop;
  final double rowH;
  final double dotsTop;
  final Widget Function(BuildContext context, int index, double width)
  itemBuilder;

  @override
  State<_Pager> createState() => _PagerState();
}

class _PagerState extends State<_Pager> {
  final _c = PageController();
  int _page = 0;

  int get _pages => math.max(1, (widget.count / widget.perPage).ceil());

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _go(int p) {
    if (p < 0 || p >= _pages) return;
    Haptics.tap();
    _c.animateToPage(
      p,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    return LayoutBuilder(
      builder: (context, box) {
        final left = u * 18.6;
        final right = u * 17.4;
        final gap = u * 6.8;
        final cardW =
            (box.maxWidth - left - right - gap * (widget.perPage - 1)) /
            widget.perPage;
        final midY = u * widget.rowTop + u * widget.rowH / 2;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: left,
              right: right,
              top: u * widget.rowTop,
              height: u * widget.rowH,
              child: ScrollConfiguration(
                behavior: const DragScroll(),
                child: PageView.builder(
                  controller: _c,
                  itemCount: _pages,
                  onPageChanged: (p) => setState(() => _page = p),
                  itemBuilder: (context, p) => RepaintBoundary(
                    child: Row(
                      children: [
                        for (var i = 0; i < widget.perPage; i++) ...[
                          if (i > 0) SizedBox(width: gap),
                          SizedBox(
                            width: cardW,
                            child: p * widget.perPage + i < widget.count
                                ? widget.itemBuilder(
                                    context,
                                    p * widget.perPage + i,
                                    cardW,
                                  )
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // «‹» at the left = next page.
            Positioned(
              left: u * (9.7 - 4.7),
              top: midY - u * 4.7,
              width: u * 9.4,
              height: u * 9.4,
              child: _Arrow(
                u: u,
                pointsLeft: true,
                enabled: _page < _pages - 1,
                onTap: () => _go(_page + 1),
              ),
            ),
            Positioned(
              right: u * (8.7 - 4.7),
              top: midY - u * 4.7,
              width: u * 9.4,
              height: u * 9.4,
              child: _Arrow(
                u: u,
                pointsLeft: false,
                enabled: _page > 0,
                onTap: () => _go(_page - 1),
              ),
            ),
            if (_pages > 1)
              Positioned(
                left: 0,
                right: 0,
                top: u * widget.dotsTop - u * 1.2,
                height: u * 2.4,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _pages; i++)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _go(i),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: u * 1.15),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: u * 2.3,
                              height: u * 2.3,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == _page
                                    ? RateelColors.setGoldBottom
                                    : RateelColors.leaderTabSeparator
                                          .withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.u,
    required this.pointsLeft,
    required this.enabled,
    required this.onTap,
  });
  final double u;
  final bool pointsLeft;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.35,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RateelColors.achPillFill,
            border: Border.all(
              color: RateelColors.leaderTabSeparator.withValues(alpha: 0.5),
              width: math.max(1.0, u * 0.2),
            ),
          ),
          child: CustomPaint(
            painter: _ChevronPainter(u: u, pointsLeft: pointsLeft),
          ),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({required this.u, required this.pointsLeft});
  final double u;
  final bool pointsLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final d = u * 1.35;
    final s = pointsLeft ? 1.0 : -1.0;
    final path = Path()
      ..moveTo(c.dx + s * d * 0.55, c.dy - d * 1.2)
      ..lineTo(c.dx - s * d * 0.55, c.dy)
      ..lineTo(c.dx + s * d * 0.55, c.dy + d * 1.2);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.62
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFF4EAD0),
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter old) =>
      old.u != u || old.pointsLeft != pointsLeft;
}

// ------------------------------------------------------ tab: achievements

class _AchievementsPager extends StatelessWidget {
  const _AchievementsPager({super.key, required this.u, required this.onOpen});
  final double u;
  final ValueChanged<CollectionItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = collectionItems().take(achievements.length).toList();
    return _Pager(
      u: u,
      count: achievements.length,
      perPage: 2,
      rowTop: 3.1,
      rowH: 36.8,
      itemBuilder: (context, i, w) => _AchievementCard(
        u: u,
        a: achievements[i],
        onTap: () => onOpen(items[i]),
      ),
    );
  }
}

/// Dimmed and desaturated, as the locked medals of 27 (saturation 0.35,
/// brightness 0.6).
ColorFilter _dimFilter() {
  const sat = 0.35;
  const bri = 0.6;
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  double m(double l, bool diag) => ((1 - sat) * l + (diag ? sat : 0)) * bri;
  return ColorFilter.matrix([
    m(lr, true),
    m(lg, false),
    m(lb, false),
    0,
    0,
    m(lr, false),
    m(lg, true),
    m(lb, false),
    0,
    0,
    m(lr, false),
    m(lg, false),
    m(lb, true),
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);
}

/// Locked medal as screen 27: the brown engraving dimmed and desaturated,
/// the padlock over its centre (same fractions as 27's `_BadgeMedal`).
class _LockedMedal extends StatelessWidget {
  const _LockedMedal({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 487 / 512,
      child: LayoutBuilder(
        builder: (context, b) => Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: _dimFilter(),
                child: Image.asset(
                  asset,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            Positioned(
              left: b.maxWidth * 0.3660,
              top: b.maxHeight * 0.2633,
              width: b.maxWidth * 0.2610,
              height: b.maxHeight * 0.3153,
              child: Image.asset(kitPadlock, fit: BoxFit.fill),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatefulWidget {
  const _AchievementCard({
    required this.u,
    required this.a,
    required this.onTap,
  });
  final double u;
  final Achievement a;
  final VoidCallback onTap;

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final a = widget.a;
    final earned = achievementEarned(a);
    final share = achievementShare(a);
    final radius = BorderRadius.circular(u * 4.0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: u * 1.4,
                offset: Offset(0, u * 0.5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [RateelColors.cardTop, RateelColors.cardMid],
                    ),
                  ),
                ),
                if (earned)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: u * 1.9,
                    child: const ColoredBox(color: RateelColors.achDoneStrip),
                  ),
                // Emblem: gold arch frame (tier tint) + medal (placeholder
                // until the card emblems C1–C5 arrive).
                Positioned(
                  top: u * 1.1,
                  left: 0,
                  right: 0,
                  height: u * 19.4,
                  child: Center(
                    child: SizedBox(
                      width: u * 19.4,
                      child: _Emblem(u: u, a: a, earned: earned),
                    ),
                  ),
                ),
                Positioned(
                  left: u * 3,
                  right: u * 3,
                  top: u * 20.6,
                  height: u * 5.6,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        a.name,
                        maxLines: 1,
                        style: readex(
                          u * 4.7,
                          weight: 520,
                          color: RateelColors.leaderText,
                        ).copyWith(shadows: titleShadows(u)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: u * 2.5,
                  right: u * 2.5,
                  top: u * 27.1,
                  height: u * 7,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Pill(
                          u: u,
                          width: 18,
                          child: _PointsLabel(u: u, text: '${a.reward}'),
                        ),
                        SizedBox(width: u * 2.6),
                        _Pill(
                          u: u,
                          width: earned ? 24.6 : 27,
                          child: earned
                              ? _DoneLabel(u: u)
                              : _ProgressLabel(u: u, share: share),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CardRimPainter(u: u, radius: u * 4.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardRimPainter extends CustomPainter {
  _CardRimPainter({required this.u, required this.radius});
  final double u;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final w = math.max(1.0, u * 0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(w / 2),
        Radius.circular(radius - w / 2),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..color = RateelColors.leaderRimEdge.withValues(alpha: 0.75),
    );
  }

  @override
  bool shouldRepaint(_CardRimPainter old) => old.u != u || old.radius != radius;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.u, required this.width, required this.child});
  final double u;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: u * width,
      height: u * 7,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 3.5),
        color: RateelColors.achPillFill,
        border: Border.all(
          color: RateelColors.leaderRowEdge,
          width: math.max(1.0, u * 0.22),
        ),
      ),
      child: child,
    );
  }
}

class _PointsLabel extends StatelessWidget {
  const _PointsLabel({required this.u, required this.text});
  final double u;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: readex(u * 4.0, weight: 560, color: RateelColors.leaderText),
          ),
          SizedBox(width: u * 0.9),
          SvgPicture.asset(
            'assets/ui/glyphs/star.svg',
            width: u * 3.9,
            height: u * 3.9,
            theme: SvgTheme(currentColor: RateelColors.leaderStar[0]),
          ),
        ],
      ),
    );
  }
}

class _DoneLabel extends StatelessWidget {
  const _DoneLabel({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: u * 4.8,
            height: u * 4.8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: RateelColors.achDoneGreen,
            ),
            child: CustomPaint(painter: _CheckPainter(u)),
          ),
          SizedBox(width: u * 1.6),
          Transform.translate(
            offset: Offset(0, -u * 0.35),
            child: Text(
              'مكتمل',
              style: readex(
                u * 3.7,
                weight: 560,
                color: RateelColors.achDoneGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.u);
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - u * 1.2, c.dy + u * 0.05)
        ..lineTo(c.dx - u * 0.3, c.dy + u * 0.95)
        ..lineTo(c.dx + u * 1.35, c.dy - u * 0.95),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.62
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = RateelColors.achPillFill,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.u != u;
}

class _ProgressLabel extends StatelessWidget {
  const _ProgressLabel({required this.u, required this.share});
  final double u;
  final double share;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: u * 2.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: u * 2.4,
                child: BadgeProgressBar(u: u * 0.7, share: share),
              ),
            ),
            SizedBox(width: u * 1.4),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${(share * 100).round()}%',
                style: readex(
                  u * 3.3,
                  weight: 560,
                  color: RateelColors.leaderText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold pointed-arch frame (tinted by tier) with the medal inside. In
/// progress: the medal is dimmed with a padlock over it.
class _Emblem extends StatelessWidget {
  const _Emblem({required this.u, required this.a, required this.earned});
  final double u;
  final Achievement a;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      achievementEmblem(a),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _ArchFramePainter(u: u, color: tierColors[a.tier]!),
        ),
        Align(
          alignment: const Alignment(0, 0.35),
          child: FractionallySizedBox(
            widthFactor: 0.7,
            heightFactor: 0.7,
            child: earned
                ? img
                : _LockedMedal(asset: achievementEmblemStart(a)),
          ),
        ),
      ],
    );
  }
}

class _ArchFramePainter extends CustomPainter {
  _ArchFramePainter({required this.u, required this.color});
  final double u;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Path arch(double inset) {
      final l = inset;
      final r = w - inset;
      final top = inset;
      return Path()
        ..moveTo(l, h)
        ..lineTo(l, h * 0.52)
        ..cubicTo(l, h * 0.34, w * 0.22, h * 0.24, w * 0.36, h * 0.16)
        ..cubicTo(w * 0.44, h * 0.11, w * 0.48, top + h * 0.03, w / 2, top)
        ..cubicTo(
          w * 0.52,
          top + h * 0.03,
          w * 0.56,
          h * 0.11,
          w * 0.64,
          h * 0.16,
        )
        ..cubicTo(w * 0.78, h * 0.24, r, h * 0.34, r, h * 0.52)
        ..lineTo(r, h);
    }

    final inner = arch(w * 0.07);
    // Dark inside with a soft warm glow behind the picture.
    final fill = Path.from(inner)..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.3),
          radius: 0.9,
          colors: [color.withValues(alpha: 0.16), const Color(0x00000000)],
        ).createShader(Offset.zero & size),
    );
    Paint stroke(double width, Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeJoin = StrokeJoin.round
      ..color = c;
    canvas.drawPath(
      arch(w * 0.015),
      stroke(math.max(1.0, u * 0.5), color.withValues(alpha: 0.95)),
    );
    canvas.drawPath(
      inner,
      stroke(math.max(1.0, u * 0.22), color.withValues(alpha: 0.65)),
    );
  }

  @override
  bool shouldRepaint(_ArchFramePainter old) => old.u != u || old.color != color;
}

// ------------------------------------------------------------- tab: points

class _PointsTab extends StatelessWidget {
  const _PointsTab({super.key, required this.u});
  final double u;

  static const _kinds = [
    (PointsKind.earned, 'المكتسبة', Color(0xFF2FCB6A)),
    (PointsKind.bonus, 'المكافآت', Color(0xFFF2B623)),
    (PointsKind.spent, 'المستخدمة', Color(0xFFE8624E)),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final left = u * 18.6;
        final right = u * 17.4;
        final gap = u * 4;
        final tileW = (box.maxWidth - left - right - gap * 2) / 3;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: left,
              right: right,
              top: u * 2.2,
              height: u * 11.2,
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) SizedBox(width: gap),
                    SizedBox(
                      width: tileW,
                      child: _SummaryTile(
                        u: u,
                        label: _kinds[i].$2,
                        value: pointsSum(_kinds[i].$1),
                        color: _kinds[i].$3,
                        spent: _kinds[i].$1 == PointsKind.spent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              left: left,
              right: right,
              top: u * 14.8,
              height: u * 4.6,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'آخر النشاطات',
                  style: readex(
                    u * 3.6,
                    weight: 520,
                    color: RateelColors.leaderText,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _Pager(
                u: u,
                count: pointsActivities.length,
                perPage: 3,
                rowTop: 20.6,
                rowH: 22.4,
                dotsTop: 46.6,
                itemBuilder: (context, i, w) =>
                    _ActivityCard(u: u, activity: pointsActivities[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.u,
    required this.label,
    required this.value,
    required this.color,
    required this.spent,
  });
  final double u;
  final String label;
  final int value;
  final Color color;
  final bool spent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 3.4),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.cardTop, RateelColors.cardMid],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.55),
          width: math.max(1.0, u * 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${spent ? '-' : '+'}$value',
                style: readex(u * 4.8, weight: 640, color: color),
              ),
            ),
            Text(
              label,
              style: readex(
                u * 3.0,
                weight: 420,
                color: RateelColors.leaderText.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.u, required this.activity});
  final double u;
  final PointsActivity activity;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final spent = a.kind == PointsKind.spent;
    final color = switch (a.kind) {
      PointsKind.earned => RateelColors.achDoneGreen,
      PointsKind.bonus => RateelColors.setGoldBottom,
      PointsKind.spent => const Color(0xFFE8624E),
    };
    final when = a.daysAgo == 0
        ? 'اليوم'
        : a.daysAgo == 1
        ? 'أمس'
        : a.daysAgo == 2
        ? 'منذ يومين'
        : 'منذ ${a.daysAgo} أيام';
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 3.4),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.cardTop, RateelColors.cardMid],
        ),
        border: Border.all(
          color: RateelColors.leaderRimEdge.withValues(alpha: 0.6),
          width: math.max(1.0, u * 0.18),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: u * 2.6, vertical: u * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: u * 4.6,
                  height: u * 4.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.18),
                    border: Border.all(
                      color: color,
                      width: math.max(1.0, u * 0.16),
                    ),
                  ),
                  child: Icon(
                    spent ? Icons.remove_rounded : Icons.add_rounded,
                    size: u * 3.2,
                    color: color,
                  ),
                ),
                const Spacer(),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/ui/glyphs/star.svg',
                        width: u * 3.2,
                        height: u * 3.2,
                        theme: SvgTheme(
                          currentColor: RateelColors.leaderStar[0],
                        ),
                      ),
                      SizedBox(width: u * 0.8),
                      Text(
                        '${spent ? '' : '+'}${a.points}',
                        style: readex(u * 3.8, weight: 620, color: color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              a.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: readex(
                u * 3.2,
                weight: 480,
                color: RateelColors.leaderText,
              ).copyWith(height: 1.3),
            ),
            SizedBox(height: u * 0.8),
            Text(
              when,
              style: readex(
                u * 2.7,
                weight: 380,
                color: RateelColors.leaderText.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------- tab: collection

class _CollectionTab extends StatelessWidget {
  const _CollectionTab({super.key, required this.u, required this.onOpen});
  final double u;
  final ValueChanged<CollectionItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = collectionItems();
    final earned = items.where((e) => e.earned).length;
    return LayoutBuilder(
      builder: (context, box) {
        final pad = u * 8;
        final gap = u * 2.6;
        const cols = 6;
        final tileW = (box.maxWidth - pad * 2 - gap * (cols - 1)) / cols;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: pad,
              right: pad,
              top: u * 0.6,
              height: u * 4,
              child: Align(
                alignment: Alignment.centerRight,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    'المجموعة  \u2066$earned\u2009/\u2009${items.length}\u2069',
                    style: readex(
                      u * 3.3,
                      weight: 480,
                      color: RateelColors.leaderText.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: u * 5.2,
              bottom: 0,
              child: ScrollConfiguration(
                behavior: const DragScroll(),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(pad, u * 0.6, pad, u * 4),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: gap,
                    mainAxisSpacing: gap,
                    childAspectRatio: tileW / (u * 24),
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) => RepaintBoundary(
                    child: _CollectionTile(
                      u: u,
                      item: items[i],
                      onTap: () => onOpen(items[i]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

const _rarityColors = {
  Rarity.common: Color(0xFFB9C4BC),
  Rarity.uncommon: Color(0xFF6FD08C),
  Rarity.rare: Color(0xFF6FB6F2),
  Rarity.epic: Color(0xFFB98CF0),
  Rarity.legendary: Color(0xFFF2B623),
};

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.u,
    required this.item,
    required this.onTap,
  });
  final double u;
  final CollectionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      item.image,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
    final rc = _rarityColors[item.rarity]!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(u * 3.0),
          color: RateelColors.badgeTileFill,
          border: Border.all(
            color: RateelColors.tileRim,
            width: math.max(1.0, u * 0.22),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: u * 1.6),
            SizedBox(
              height: u * 12.5,
              child: item.earned ? img : _LockedMedal(asset: item.startImage),
            ),
            SizedBox(height: u * 0.9),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: u * 1.2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.name,
                  maxLines: 1,
                  style: readex(
                    u * 3.1,
                    weight: 520,
                    color: RateelColors.leaderText,
                  ),
                ),
              ),
            ),
            SizedBox(height: u * 0.9),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: u * 1.8,
                vertical: u * 0.4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(u * 2),
                color: rc.withValues(alpha: 0.16),
                border: Border.all(
                  color: rc.withValues(alpha: 0.7),
                  width: math.max(1.0, u * 0.14),
                ),
              ),
              child: Text(
                rarityLabels[item.rarity]!,
                style: readex(u * 2.4, weight: 520, color: rc),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ detail sheet

/// Detail of an achievement or a badge (Angular `achievement-details-modal`,
/// without the share button: backlog). Same panel as 27.
class _DetailDialog extends StatelessWidget {
  const _DetailDialog({required this.item});
  final CollectionItem item;

  @override
  Widget build(BuildContext context) {
    final u = MediaQuery.sizeOf(context).height / 100;
    final img = Image.asset(
      item.image,
      height: u * 25.4,
      filterQuality: FilterQuality.medium,
    );
    const inset = 4.6;
    return Center(
      child: SizedBox(
        width: u * 57.6,
        height: u * 70.5,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: ArchPanelPainter(u: u)),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: u * 2.9,
              height: u * 25.4,
              child: Center(
                child: item.earned
                    ? img
                    : SizedBox(
                        height: u * 25.4,
                        child: _LockedMedal(asset: item.startImage),
                      ),
              ),
            ),
            Positioned(
              left: u * 2,
              right: u * 2,
              top: u * 28.8,
              height: u * 6,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.name,
                    maxLines: 1,
                    style:
                        readex(
                          u * 5.2,
                          weight: 600,
                          color: RateelColors.leaderText,
                        ).copyWith(
                          shadows: titleShadows(u),
                          decoration: TextDecoration.none,
                        ),
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
                  item.description,
                  textAlign: TextAlign.center,
                  style: readex(
                    u * 3.0,
                    weight: 380,
                    color: RateelColors.leaderText.withValues(alpha: 0.92),
                  ).copyWith(height: 1.35, decoration: TextDecoration.none),
                ),
              ),
            ),
            Positioned(
              left: u * 4.9,
              top: u * 45.2,
              height: u * 3.5,
              child: Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    item.progressText.replaceAll(' / ', ' / '),
                    style: readex(
                      u * 3.4,
                      weight: 600,
                      color: RateelColors.leaderText,
                    ).copyWith(decoration: TextDecoration.none),
                  ),
                ),
              ),
            ),
            Positioned(
              right: u * inset,
              top: u * 45.2,
              width: u * 35.4,
              height: u * 3.5,
              child: BadgeProgressBar(u: u, share: item.share),
            ),
            Positioned(
              left: u * inset,
              right: u * inset,
              top: u * 52.0,
              height: u * 1.2,
              child: GoldDivider(u: u),
            ),
            Positioned(
              left: u * inset,
              right: u * inset,
              top: u * 54.9,
              height: u * 11.7,
              child: RewardBox(u: u, reward: item.reward),
            ),
          ],
        ),
      ),
    );
  }
}
