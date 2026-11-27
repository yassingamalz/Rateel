import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../badges/badges_screen.dart'
    show
        ArchPanelPainter,
        BadgeProgressBar,
        DragScroll,
        GoldDivider,
        GoldSubtitle,
        RewardBox;
import '../core/haptics.dart';
import '../courses/course_data.dart';
import '../gamification/points.dart';
import '../leaderboard/leaderboard_screen.dart'
    show GoldRimPainter, LeaderLattice, LeaderRibbon, latticeAsset, ribbonAsset;
import '../lessons/lesson_data.dart';
import '../theme/rateel_theme.dart';
import '../units/unit_data.dart';

/// Level detail page «المستوى الثالث» (screen 13, owner's second reference:
/// docs/flutter/screens/13-achievements/reference-level-detail.webp, plan §9).
/// Opened by tapping the level emblem of 13. Level N = course N: the rows are
/// the real units of that course with their real progress today (owner,
/// 2026-11-27); the tabs الإنجازات / ترتيب المستوى are «coming soon».
class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key, required this.level});
  final int level;

  /// Review aid: `?level=1` opens the level page of level 1 above 13.
  static int? startLevel;

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

const _ordinals = [
  'الأول',
  'الثاني',
  'الثالث',
  'الرابع',
  'الخامس',
  'السادس',
  'السابع',
  'الثامن',
  'التاسع',
  'العاشر',
  'الحادي عشر',
  'الثاني عشر',
];

String levelName(int level) => level >= 1 && level <= _ordinals.length
    ? 'المستوى ${_ordinals[level - 1]}'
    : 'المستوى $level';

class _LevelScreenState extends State<LevelScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  int _tab = 0;
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    Future.wait([
          for (final a in [
            ribbonAsset,
            latticeAsset,
            'assets/ui/badges/blank_gold.webp',
            coinAssetOf,
          ])
            precacheImage(AssetImage(a), context),
        ])
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

  double _iv(double b, double e, [Curve c = Curves.easeOutCubic]) =>
      c.transform(((_entry.value - b) / (e - b)).clamp(0.0, 1.0));

  int get _course => widget.level - 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final u = box.maxHeight / 100;
        final w = box.maxWidth;
        final left = u * 4.2;
        const leftW = 57.6;
        final panelTop = u * 23.4;
        final panelBottom = box.maxHeight - u * 5.3;
        final rightLeft = left + u * leftW + u * 3.4;
        final rightRight = w - u * 3.6;
        final course = _course >= 0 && _course < courses.length
            ? courses[_course]
            : null;
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
                  left: (w - u * 66.8) / 2,
                  top: u * 1.7 - u * 2 * (1 - _iv(0, 0.3, Curves.easeOutBack)),
                  width: u * 66.8,
                  height: u * 12.0,
                  child: Opacity(
                    opacity: _iv(0, 0.2),
                    child: RepaintBoundary(
                      child: LeaderRibbon(
                        u: u * 0.8,
                        title: levelName(widget.level),
                      ),
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
                    child: GoldSubtitle(
                      u: u,
                      text: course?.description ?? 'دروس هذا المستوى',
                    ),
                  ),
                ),
                Positioned(
                  key: const ValueKey('left'),
                  left: left,
                  top: panelTop + u * 1.2 * (1 - _iv(0.1, 0.4)),
                  width: u * leftW,
                  height: panelBottom - panelTop,
                  child: Opacity(
                    opacity: _iv(0.1, 0.4),
                    child: RepaintBoundary(
                      child: _LeftPanel(u: u, level: widget.level),
                    ),
                  ),
                ),
                Positioned(
                  key: const ValueKey('right'),
                  left: rightLeft,
                  right: w - rightRight,
                  top: panelTop + u * 1.2 * (1 - _iv(0.15, 0.45)),
                  height: panelBottom - panelTop,
                  child: Opacity(
                    opacity: _iv(0.15, 0.45),
                    child: RepaintBoundary(
                      child: _RightPanel(
                        u: u,
                        tab: _tab,
                        course: _course,
                        entry: _entry,
                        onTab: (i) {
                          if (i == _tab) return;
                          Haptics.tap();
                          setState(() => _tab = i);
                        },
                      ),
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
}

const coinAssetOf = 'assets/ui/leaderboard/coins_gold.webp';

// ------------------------------------------------------------- left panel

class _LeftPanel extends StatelessWidget {
  const _LeftPanel({required this.u, required this.level});
  final double u;
  final int level;

  @override
  Widget build(BuildContext context) {
    final points = userPoints.value;
    final reached = levelOf(points);
    // Progress through this level: full when it is behind, empty when ahead.
    final share = reached == level
        ? levelShare(points)
        : (reached > level ? 1.0 : 0.0);
    final start = levelStart(level);
    final end = levelEnd(level);
    final size = end == null ? 0 : end - start;
    final current = reached == level
        ? points - start
        : (reached > level ? size : 0);
    // Mock reward (display only, BACKLOG): 1K coins per level.
    final reward = '${level}K';
    const inset = 4.6;
    return CustomPaint(
      painter: ArchPanelPainter(u: u),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: u * 2.9,
            height: u * 25.4,
            child: Center(
              child: AspectRatio(
                aspectRatio: 487 / 512,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/ui/badges/blank_gold.webp',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
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
                                offset: Offset(0, -u * 0.5),
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    '$level',
                                    style: readex(
                                      u * 12,
                                      weight: 760,
                                      color: RateelColors.countText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                  levelName(level),
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
                'أكمل دروس هذا المستوى لتنتقل إلى المستوى التالي',
                textAlign: TextAlign.center,
                style: readex(
                  u * 3.0,
                  weight: 380,
                  color: RateelColors.leaderText.withValues(alpha: 0.92),
                ).copyWith(height: 1.35),
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
                  end == null ? '$points' : '$current / $size',
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
            width: u * 27,
            height: u * 3.5,
            child: BadgeProgressBar(u: u, share: share),
          ),
          Positioned(
            left: u * inset,
            right: u * inset,
            top: u * 52.3,
            height: u * 1.2,
            child: GoldDivider(u: u),
          ),
          Positioned(
            left: u * inset,
            right: u * inset,
            top: u * 56.0,
            height: u * 11.7,
            child: RewardBox(
              u: u,
              reward: reward,
              label: 'مكافأة إتمام المستوى',
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ right panel

class _RightPanel extends StatelessWidget {
  const _RightPanel({
    required this.u,
    required this.tab,
    required this.course,
    required this.entry,
    required this.onTab,
  });
  final double u;
  final int tab;
  final int course;
  final Animation<double> entry;
  final ValueChanged<int> onTab;

  static const _labels = ['الدروس', 'الإنجازات', 'ترتيب المستوى'];
  static const _icons = [
    'assets/ui/nav/quran.svg',
    'assets/ui/nav/leaderboard.svg',
    'assets/ui/nav/training.svg',
  ];
  static const _widths = [25.5, 28.5, 33.5];

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(u * 5.3);
    return DecoratedBox(
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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: u * 9.2,
                  bottom: 0,
                  child: tab == 0
                      ? _UnitList(u: u, course: course, entry: entry)
                      : _SoonNote(u: u),
                ),
                Positioned(
                  right: u * 4.9,
                  top: u * 2.3,
                  height: u * 6.1,
                  child: _tabs(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    final h = u * 6.1;
    final rights = <double>[];
    var x = 0.0;
    for (final w in _widths) {
      rights.add(x);
      x += (w + 2.4) * u;
    }
    return SizedBox(
      width: x,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < 3; i++)
            Positioned(
              right: rights[i],
              top: 0,
              width: _widths[i] * u,
              height: h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(h / 2),
                  border: Border.all(
                    color: RateelColors.rowRim,
                    width: math.max(1.0, u * 0.2),
                  ),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeInOutCubic,
            right: rights[tab],
            top: 0,
            width: _widths[tab] * u,
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
              right: rights[i],
              top: 0,
              width: _widths[i] * u,
              height: h,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTab(i),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          _icons[i],
                          width: u * 3.6,
                          height: u * 3.6,
                          theme: SvgTheme(
                            currentColor: i == tab
                                ? RateelColors.countText
                                : const Color(0xFFF4EAD0),
                          ),
                        ),
                        SizedBox(width: u * 1.2),
                        Transform.translate(
                          offset: Offset(0, -u * 0.45),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: readex(
                              u * 3.0,
                              weight: i == tab ? 560 : 420,
                              color: i == tab
                                  ? RateelColors.countText
                                  : RateelColors.leaderText,
                            ),
                            child: Text(_labels[i]),
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

class _SoonNote extends StatelessWidget {
  const _SoonNote({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'قريبًا',
            style: readex(u * 6, weight: 600, color: RateelColors.setGoldTop),
          ),
          SizedBox(height: u * 1.2),
          Text(
            'هذه الميزة قادمة في التحديث القادم',
            style: readex(
              u * 3.0,
              weight: 400,
              color: RateelColors.leaderText.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

enum _RowState { done, current, locked }

class _UnitList extends StatelessWidget {
  const _UnitList({required this.u, required this.course, required this.entry});
  final double u;
  final int course;
  final Animation<double> entry;

  @override
  Widget build(BuildContext context) {
    final units = course >= 0 && course < courses.length
        ? unitsOf(course)
        : const <Unit>[];
    if (units.isEmpty) return _SoonNote(u: u);
    final locked = course >= courses.length || courses[course].locked;
    final current = unitsProgressOf(course).current;
    return ScrollConfiguration(
      behavior: const DragScroll(),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(u * 3.8, u * 1.0, u * 3.8, u * 4),
        itemCount: units.length,
        itemBuilder: (context, i) {
          final unit = units[i];
          final state = locked
              ? _RowState.locked
              : i < current
              ? _RowState.done
              : i == current
              ? _RowState.current
              : _RowState.locked;
          final n = lessonsOf(unit.id).length;
          final done = state == _RowState.done ? n : lessonsDone(unit.id);
          return Padding(
            padding: EdgeInsets.only(bottom: u * 2.2),
            child: RepaintBoundary(
              child: _UnitRow(
                u: u,
                unit: unit,
                state: state,
                lessons: n,
                done: done,
              ),
            ),
          );
        },
      ),
    );
  }
}

const _typeIcons = {
  UnitType.video: 'assets/ui/lessons/video.webp',
  UnitType.reading: 'assets/ui/lessons/read.webp',
  UnitType.practice: 'assets/ui/lessons/practice.webp',
  UnitType.test: 'assets/ui/lessons/test.webp',
};

class _UnitRow extends StatelessWidget {
  const _UnitRow({
    required this.u,
    required this.unit,
    required this.state,
    required this.lessons,
    required this.done,
  });
  final double u;
  final Unit unit;
  final _RowState state;
  final int lessons;
  final int done;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(u * 3.6);
    final isCurrent = state == _RowState.current;
    final isLocked = state == _RowState.locked;
    final subtitle = lessons == 0 ? 'قريبًا' : '$lessons دروس';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: Haptics.tap,
      child: SizedBox(
        height: u * 15.6,
        child: CustomPaint(
          foregroundPainter: isCurrent
              ? GoldRimPainter(u: u * 0.7, radius: u * 3.6, bright: true)
              : _RowRimPainter(u: u, radius: u * 3.6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [RateelColors.cardTop, RateelColors.cardMid],
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: RateelColors.gold.withValues(alpha: 0.22),
                        blurRadius: u * 1.6,
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: u * 2.4),
              child: Row(
                children: [
                  // RTL: emblem at the right, then the texts, status at the left.
                  _UnitEmblem(u: u, type: unit.type, locked: isLocked),
                  SizedBox(width: u * 2.4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: readex(
                            u * 4.3,
                            weight: 560,
                            color: RateelColors.leaderText,
                          ).copyWith(shadows: titleShadows(u)),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          style: readex(
                            u * 3.0,
                            weight: 380,
                            color: RateelColors.leaderText.withValues(
                              alpha: 0.78,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _status(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _status() {
    switch (state) {
      case _RowState.done:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusPill(u: u, text: 'مكتمل', color: RateelColors.achDoneGreen),
            SizedBox(width: u * 1.6),
            _Disc(
              u: u,
              ring: RateelColors.achDoneGreen,
              child: CustomPaint(
                painter: _TickPainter(u, RateelColors.achDoneGreen),
              ),
            ),
          ],
        );
      case _RowState.current:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: u * 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '$done / $lessons',
                      style: readex(
                        u * 3.3,
                        weight: 620,
                        color: RateelColors.leaderText,
                      ),
                    ),
                  ),
                  SizedBox(height: u * 0.5),
                  SizedBox(
                    height: u * 2.2,
                    child: BadgeProgressBar(
                      u: u * 0.62,
                      share: lessons == 0 ? 0 : done / lessons,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: u * 2),
            Container(
              width: u * 6.6,
              height: u * 6.6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [RateelColors.setGoldTop, RateelColors.setGoldBottom],
                ),
              ),
              child: CustomPaint(painter: _PlayPainter(u)),
            ),
          ],
        );
      case _RowState.locked:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusPill(
              u: u,
              text: 'مقفل',
              color: RateelColors.leaderText.withValues(alpha: 0.7),
            ),
            SizedBox(width: u * 1.6),
            _Disc(
              u: u,
              ring: RateelColors.leaderTabSeparator,
              child: SvgPicture.asset(
                'assets/ui/glyphs/lock.svg',
                theme: SvgTheme(
                  currentColor: RateelColors.leaderText.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _RowRimPainter extends CustomPainter {
  _RowRimPainter({required this.u, required this.radius});
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
        ..color = RateelColors.leaderRowEdge,
    );
  }

  @override
  bool shouldRepaint(_RowRimPainter old) => old.u != u || old.radius != radius;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.u, required this.text, required this.color});
  final double u;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: u * 15.5,
      height: u * 5.6,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 2.8),
        border: Border.all(
          color: color.withValues(alpha: 0.65),
          width: math.max(1.0, u * 0.18),
        ),
      ),
      child: Transform.translate(
        offset: Offset(0, -u * 0.35),
        child: Text(text, style: readex(u * 3.3, weight: 540, color: color)),
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({required this.u, required this.child, required this.ring});
  final double u;
  final Widget child;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: u * 6.6,
      height: u * 6.6,
      padding: EdgeInsets.all(u * 1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: math.max(1.0, u * 0.24)),
      ),
      child: child,
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter(this.u, this.color);
  final double u;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - u * 1.1, c.dy + u * 0.05)
        ..lineTo(c.dx - u * 0.25, c.dy + u * 0.9)
        ..lineTo(c.dx + u * 1.2, c.dy - u * 0.85),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.55
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_TickPainter old) => old.u != u || old.color != color;
}

class _PlayPainter extends CustomPainter {
  _PlayPainter(this.u);
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // Triangle pointing left (RTL: forward is to the left).
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - u * 1.5, c.dy)
        ..lineTo(c.dx + u * 1.1, c.dy - u * 1.6)
        ..lineTo(c.dx + u * 1.1, c.dy + u * 1.6)
        ..close(),
      Paint()..color = RateelColors.countText,
    );
  }

  @override
  bool shouldRepaint(_PlayPainter old) => old.u != u;
}

/// Scalloped octagon (two squares) with the unit type icon, gold line.
class _UnitEmblem extends StatelessWidget {
  const _UnitEmblem({
    required this.u,
    required this.type,
    required this.locked,
  });
  final double u;
  final UnitType type;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final icon = Image.asset(
      _typeIcons[type]!,
      width: u * 6.4,
      height: u * 6.4,
      fit: BoxFit.contain,
      color: locked ? const Color(0x99FFFFFF) : null,
      colorBlendMode: locked ? BlendMode.modulate : null,
    );
    return SizedBox(
      width: u * 11.4,
      height: u * 11.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(u * 11.4),
            painter: _OctagonPainter(u: u, locked: locked),
          ),
          icon,
        ],
      ),
    );
  }
}

class _OctagonPainter extends CustomPainter {
  _OctagonPainter({required this.u, required this.locked});
  final double u;
  final bool locked;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - u * 0.3;
    Path square(double a) {
      final p = Path();
      for (var i = 0; i < 4; i++) {
        final ang = a + i * math.pi / 2;
        final pt = c + Offset(math.cos(ang), math.sin(ang)) * r * 1.0;
        if (i == 0) {
          p.moveTo(pt.dx, pt.dy);
        } else {
          p.lineTo(pt.dx, pt.dy);
        }
      }
      return p..close();
    }

    final path = Path.combine(
      PathOperation.union,
      square(math.pi / 4),
      square(0),
    );
    final color = locked ? const Color(0xFF8E9A55) : RateelColors.setGoldTop;
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: locked ? 0.08 : 0.18),
            const Color(0x00000000),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, u * 0.3)
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: locked ? 0.7 : 0.95),
    );
  }

  @override
  bool shouldRepaint(_OctagonPainter old) => old.u != u || old.locked != locked;
}
