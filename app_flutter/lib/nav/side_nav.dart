import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../theme/rateel_theme.dart';
import 'nav_items.dart';

/// Side navigation, screen 04 (docs/flutter/screens/04-side-nav.md).
///
/// One widget draws both states. The closed rail (style C) widens into the
/// open menu: every tile morphs into its row, every icon and count bubble
/// glides to its place in the row, ☰ morphs into ✕. Geometry is in units of
/// 1% of the screen height (u), measured by the critic on the ChatGPT
/// references (05 for the rail, 04 for the open menu): see critic-v1.md.
class SideNavScaffold extends StatefulWidget {
  const SideNavScaffold({super.key, required this.builder});

  /// Builds the screen shown next to the rail for the selected section.
  final Widget Function(BuildContext context, int selected) builder;

  /// Review aid: section selected on start (`?section=3` opens the leaderboard).
  static int startSection = 0;

  /// Tap on the section that is already selected (its index): a screen deep
  /// inside the section may go back to the section's first screen (screen 12
  /// → courses, owner 2026-11-26). On the first screen it does nothing.
  static final reselected = ValueNotifier<int?>(null);

  @override
  State<SideNavScaffold> createState() => _SideNavScaffoldState();
}

class _SideNavScaffoldState extends State<SideNavScaffold>
    with TickerProviderStateMixin {
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _select = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  int _selected = SideNavScaffold.startSection;
  bool _dragging = false;

  /// Vertical scroll of the closed rail in px (owner, 2026-11-25: the rail
  /// scrolls when its items do not fit, e.g. with the settings gear). The open
  /// menu does not scroll: its rows fit.
  double _scroll = 0;
  bool _scrolling = false;
  bool _scrollReady = false;
  _Geometry? _g;
  double _selectFrom = SideNavScaffold.startSection.toDouble();

  bool get _isOpen =>
      _open.value > 0.5 || _open.status == AnimationStatus.forward;

  double get _active => lerpDouble(
    _selectFrom,
    _selected.toDouble(),
    Curves.easeInOutCubic.transform(_select.value),
  )!;

  @override
  void dispose() {
    _open.dispose();
    _select.dispose();
    super.dispose();
  }

  void _toggle() {
    Haptics.tap();
    _isOpen ? _close() : _open.forward();
  }

  void _close() => _open.reverse();

  /// Scroll that keeps rail item [i] fully visible below the menu tile.
  double _scrollToShow(_Geometry g, int i) {
    final top = g.railY0(i.toDouble()) - g.u * 5.55 - g.railTop;
    final bottom = g.railY0(i.toDouble()) + g.u * 5.55 + g.u * 2.5 - g.h;
    return _scroll.clamp(bottom, top).clamp(0.0, g.maxScroll);
  }

  void _pick(int index) {
    Haptics.tick();
    if (index != _selected) {
      setState(() {
        _selectFrom = _active;
        _selected = index;
        final g = _g;
        if (g != null) _scroll = _scrollToShow(g, index);
      });
      _select.forward(from: 0);
    } else {
      // Fire even when the same index is tapped twice in a row.
      SideNavScaffold.reselected.value = null;
      SideNavScaffold.reselected.value = index;
    }
    if (_isOpen) _close();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isOpen) _close();
      },
      child: LayoutBuilder(
        builder: (context, box) {
          var g = _Geometry(box.maxWidth, box.maxHeight, 0);
          if (!_scrollReady) {
            _scrollReady = true;
            _scroll = _scrollToShow(g, _selected);
          }
          _scroll = _scroll.clamp(0.0, g.maxScroll);
          g = _g = _Geometry(box.maxWidth, box.maxHeight, _scroll);
          // Owner: swipe right-to-left on the rail opens the menu, left-to-right
          // closes it, following the finger. While closed, only drags that start
          // on the rail count (the content may scroll horizontally).
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (d) {
              _dragging =
                  _open.value > 0 || d.localPosition.dx >= g.w - g.railWidth;
            },
            onHorizontalDragUpdate: (d) {
              if (!_dragging) return;
              _open.value -= d.delta.dx / (g.panelWidth - g.railWidth);
            },
            onVerticalDragStart: (d) {
              _scrolling =
                  _open.value == 0 &&
                  g.maxScroll > 0 &&
                  d.localPosition.dx >= g.w - g.railWidth;
            },
            onVerticalDragUpdate: (d) {
              if (!_scrolling) return;
              setState(
                () => _scroll = (_scroll - d.delta.dy).clamp(0.0, g.maxScroll),
              );
            },
            onVerticalDragEnd: (_) => _scrolling = false,
            onHorizontalDragEnd: (d) {
              if (!_dragging) return;
              _dragging = false;
              final v = d.primaryVelocity ?? 0;
              if (v < -300) {
                _open.forward();
              } else if (v > 300) {
                _close();
              } else {
                _open.value >= 0.5 ? _open.forward() : _close();
              }
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([_open, _select]),
              builder: (context, _) {
                final t = Curves.easeInOutCubic.transform(_open.value);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      right: g.railWidth,
                      child: IgnorePointer(
                        ignoring: t > 0,
                        child: widget.builder(context, _selected),
                      ),
                    ),
                    // The reference has no dimming; the owner approved a light one
                    // (kept subtle, see DECISIONS.md).
                    if (t > 0)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _close,
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: 0.12 * t),
                          ),
                        ),
                      ),
                    ..._panel(g, t),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<Widget> _panel(_Geometry g, double t) {
    final panelLeft = lerpDouble(g.w - g.railWidth, g.panelLeft, t)!;
    final active = _active;
    // Every layer has a stable key: layers that appear late (arch, caps)
    // must not shift the others (v3 bug: icons drawn one row off).
    Widget k(String id, Widget w) => KeyedSubtree(key: ValueKey(id), child: w);
    final caps = _filigree(g, t, active);
    final back = <Widget>[
      k(
        'panel',
        Positioned(
          left: panelLeft,
          top: 0,
          bottom: 0,
          right: 0,
          child: _PanelBackground(g: g, t: t),
        ),
      ),
      // Gold arch above the rows (open state only). Owner: a little lower than
      // the reference so its tails meet the selected row; the tails pass
      // behind the row and the caps.
      if (t > 0)
        k(
          'arch',
          Positioned(
            left: g.panelLeft + g.u * 39.3 - g.u * 22.35 + (1 - t) * g.u * 6,
            top: g.u * 4.0,
            width: g.u * 44.7,
            height: g.u * 44.7 * 222 / 720,
            child: IgnorePointer(
              child: Opacity(
                opacity: _late(t),
                child: SvgPicture.asset(
                  'assets/ui/decor/arch.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
    ];
    final widgets = <Widget>[
      for (var c = 0; c < caps.length; c++) k('cap$c', caps[c]),
      k('selected', _selectedRow(g, t, active)),
    ];
    for (var i = 0; i < navItems.length; i++) {
      widgets.add(k('item$i', _item(g, t, i, active)));
    }
    widgets.add(k('badge', _activeBadge(g, t, active)));
    for (var i = 0; i < navItems.length; i++) {
      widgets.add(k('icon$i', _icon(g, t, i, active)));
      widgets.add(k('bubble$i', _bubble(g, t, i, active)));
    }
    // Scrolled rail items slide under the menu tile: clip them there
    // (closed rail only; the open menu needs no clip).
    final clipTop = g.scroll > 0 ? g.railTop * (1 - t) : 0.0;
    return [
      ...back,
      k(
        'items',
        Positioned.fill(
          child: ClipRect(
            clipper: _TopClip(clipTop),
            child: Stack(fit: StackFit.expand, children: widgets),
          ),
        ),
      ),
      k('menu', _menuButton(g, t)),
    ];
  }

  /// Filigree end caps, half hidden behind both ends of the selected row.
  List<Widget> _filigree(_Geometry g, double t, double active) {
    if (t == 0) return const [];
    final o = ((t - 0.85) / 0.15).clamp(0.0, 1.0);
    if (o == 0) return const [];
    // Filled PNG caps from the owner (row_end_caps_pair.png, owner's choice
    // over the vector kit): the flat side sits just under the row rim.
    final row = Rect.lerp(g.tileRectAt(active), g.selectedRect(active), t)!;
    final h = g.u * 10.4;
    final w = h * 267 / 442;
    Widget cap(double left, String asset) => Positioned(
      left: left,
      top: row.center.dy - h / 2,
      width: w,
      height: h,
      child: IgnorePointer(
        child: Opacity(
          opacity: o,
          child: Image(image: AssetImage(asset), fit: BoxFit.fill),
        ),
      ),
    );
    return [
      cap(row.left - w + g.u * 1.7, 'assets/ui/decor/cap_left.png'),
      cap(row.right - g.u * 1.7, 'assets/ui/decor/cap_right.png'),
    ];
  }

  /// Tile (closed) that morphs into the row (open).
  Widget _item(_Geometry g, double t, int i, double active) {
    final row = g.rowRect(i);
    final rect = Rect.lerp(g.tileRect(i), row, t)!;
    final radius = lerpDouble(g.u * 3.0, g.u * 4.1, t)!;
    final activeness = (1 - (active - i).abs()).clamp(0.0, 1.0);
    // The active rail item has no tile, only the gold disc; the selected row
    // draws its own capsule.
    final tileOpacity = 1 - activeness;
    final label = _stagger(t, i);
    return Positioned.fromRect(
      rect: rect,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _pick(i),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: tileOpacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: Color.lerp(
                        RateelColors.tileRim,
                        RateelColors.rowRim,
                        t,
                      )!,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            if (label > 0) ...[
              Positioned(
                right: row.right - g.labelRight + g.u * 2 * (1 - label),
                top: 0,
                bottom: 0,
                child: Opacity(
                  opacity: label,
                  child: Center(
                    child: Text(
                      navItems[i].label,
                      textDirection: TextDirection.rtl,
                      style: readex(
                        g.u * 4.0,
                        weight: 340,
                        color: RateelColors.label,
                      ),
                    ),
                  ),
                ),
              ),
              if (navItems[i].count != null)
                Positioned(
                  left: g.dividerX - row.left,
                  top: rect.height / 2 - g.u * 2.1,
                  child: Opacity(
                    opacity: label,
                    child: Container(
                      width: 2,
                      height: g.u * 4.2,
                      color: RateelColors.divider,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _selectedRow(_Geometry g, double t, double active) {
    if (t == 0) return const SizedBox.shrink();
    final rect = Rect.lerp(g.tileRectAt(active), g.selectedRect(active), t)!;
    final radius = lerpDouble(g.u * 3.0, g.u * 4.4, t)!;
    return Positioned.fromRect(
      rect: rect,
      child: IgnorePointer(
        child: Opacity(
          opacity: t,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: RateelColors.goldTintRow,
              border: Border.all(color: RateelColors.goldEdge, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: RateelColors.gold.withValues(alpha: 0.15),
                  blurRadius: g.u * 2,
                ),
              ],
            ),
            // 1 px light-gold highlight inside the rim (top and bottom edges).
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius - 1.2),
                border: Border.all(color: RateelColors.goldHighlight, width: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Gold disc of the active item: flat amber in the rail, dark disc with a
  /// gold ring in the menu.
  Widget _activeBadge(_Geometry g, double t, double active) {
    final center = Offset.lerp(
      g.railCenter(active),
      g.rowIconCenter(active),
      t,
    )!;
    final inner = lerpDouble(g.u * 8.5, g.u * 8.9, t)!;
    final ring = lerpDouble(g.u * 12.3, g.u * 8.9, t)!;
    return Positioned(
      left: center.dx - ring / 2,
      top: center.dy - ring / 2,
      width: ring,
      height: ring,
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 1 - t,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Inner glow: the gap brightens toward the ring (#415423 → #73772C).
                  gradient: RadialGradient(
                    stops: const [0.6, 1],
                    colors: [
                      RateelColors.gold.withValues(alpha: 0.12),
                      RateelColors.gold.withValues(alpha: 0.30),
                    ],
                  ),
                  border: Border.all(color: RateelColors.ringLine, width: 1.7),
                  boxShadow: [
                    BoxShadow(
                      color: RateelColors.gold.withValues(alpha: 0.28),
                      blurRadius: g.u * 2.4,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: inner,
              height: inner,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(RateelColors.amber, RateelColors.iconDisc, t),
                border: Border.all(
                  color: RateelColors.iconRing,
                  width: lerpDouble(0, 2, t)!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: RateelColors.gold.withValues(
                      alpha: lerpDouble(0.15, 0.0, t)!,
                    ),
                    blurRadius: g.u * 1.2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _icon(_Geometry g, double t, int i, double active) {
    final activeness = (1 - (active - i).abs()).clamp(0.0, 1.0);
    // Idle icons shift right/down to leave room for their count bubble; the
    // settings gear has no bubble and stays centred in its tile.
    final railC =
        g.railCenter(i.toDouble()) +
        (navItems[i].count == null
            ? Offset.zero
            : Offset(g.u * 0.95, g.u * 0.5) * (1 - activeness));
    final c = Offset.lerp(railC, g.rowIconCenter(i.toDouble()), t)!;
    final size = lerpDouble(
      g.u * 6.8,
      lerpDouble(g.u * 6.9, g.u * 7.8, activeness)!,
      t,
    )!;
    final activeColor = Color.lerp(
      RateelColors.activeGlyph,
      RateelColors.gold,
      t,
    )!;
    final idle = Color.lerp(RateelColors.cream, RateelColors.iconCream, t)!;
    final color = Color.lerp(idle, activeColor, activeness)!;
    return Positioned(
      left: c.dx - size / 2,
      top: c.dy - size / 2,
      width: size,
      height: size,
      child: IgnorePointer(
        child: navItems[i].iconData != null
            ? Icon(navItems[i].iconData, size: size * 0.95, color: color)
            : SvgPicture.asset(
                navItems[i].icon!,
                theme: SvgTheme(currentColor: color),
              ),
      ),
    );
  }

  Widget _bubble(_Geometry g, double t, int i, double active) {
    final item = navItems[i];
    final count = item.count;
    if (count == null) return const SizedBox.shrink();
    final threeDigits = count >= 100;
    final activeness = (1 - (active - i).abs()).clamp(0.0, 1.0);
    final tile = g.tileRect(i);
    final railW = threeDigits ? g.u * 7.5 : g.u * 6.5;
    final railH = g.u * 4.65;
    // Rail: right edge 5.7u from the tile's left edge, top on the tile's top
    // edge; the active bubble sits higher and further left (reference 05).
    final railRight = tile.left + lerpDouble(g.u * 5.7, g.u * 5.0, activeness)!;
    final railCy = tile.top + lerpDouble(g.u * 2.4, g.u * 1.9, activeness)!;
    final from = Offset(railRight - railW / 2, railCy);
    final pillW = threeDigits ? g.u * 8.6 : g.u * 7.9;
    final to = Offset(g.pillX, g.rowY(i.toDouble()));
    final center = Offset.lerp(from, to, t)!;
    final h = lerpDouble(railH, g.u * 5.1, t)!;
    final w = lerpDouble(railW, pillW, t)!;
    return Positioned(
      left: center.dx - w / 2,
      top: center.dy - h / 2,
      width: w,
      height: h,
      child: IgnorePointer(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(h / 2),
            color: Color.lerp(RateelColors.amber, RateelColors.amberPill, t),
          ),
          child: Text(
            '$count',
            style: readex(
              lerpDouble(g.u * 2.75, g.u * 2.85, t)!,
              weight: 700,
              color: RateelColors.countText,
            ).copyWith(height: 1),
          ),
        ),
      ),
    );
  }

  /// Rounded-square menu tile (closed) that becomes the round gold close button.
  Widget _menuButton(_Geometry g, double t) {
    final from = Rect.fromCenter(
      center: Offset(g.railCenterX, g.u * 6.55),
      width: g.u * 8.55,
      height: g.u * 8.1,
    );
    final to = Rect.fromCenter(
      center: Offset(g.panelLeft + g.u * 9.6, g.u * 6.45),
      width: g.u * 8.2,
      height: g.u * 8.2,
    );
    final rect = Rect.lerp(from, to, t)!;
    return Positioned.fromRect(
      rect: rect,
      child: Semantics(
        button: true,
        label: t > 0.5 ? 'إغلاق القائمة' : 'القائمة',
        child: GestureDetector(
          onTap: _toggle,
          child: Container(
            // Owner: the close button uses the same light glass as the active
            // rail item: thin gold ring, soft inner glow, gentle outer glow.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                lerpDouble(g.u * 2.4, rect.width / 2, t)!,
              ),
              gradient: RadialGradient(
                stops: const [0.55, 1],
                colors: [
                  Color.lerp(
                    Colors.white.withValues(alpha: 0.025),
                    RateelColors.gold.withValues(alpha: 0.08),
                    t,
                  )!,
                  Color.lerp(
                    Colors.white.withValues(alpha: 0.025),
                    RateelColors.gold.withValues(alpha: 0.24),
                    t,
                  )!,
                ],
              ),
              border: Border.all(
                color: Color.lerp(
                  RateelColors.menuTileRim,
                  RateelColors.ringLine,
                  t,
                )!,
                width: lerpDouble(2, 1.7, t)!,
              ),
              boxShadow: [
                BoxShadow(
                  color: RateelColors.gold.withValues(alpha: 0.22 * t),
                  blurRadius: g.u * 2.0,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _MenuCloseGlyph(t: t, u: g.u),
            ),
          ),
        ),
      ),
    );
  }

  /// Labels fade in one after the other while the menu opens.
  double _stagger(double t, int i) {
    final start = 0.35 + i * 0.06;
    return ((t - start) / (1 - start)).clamp(0.0, 1.0);
  }

  /// Ornaments appear in the last part of the opening.
  double _late(double t) => ((t - 0.5) / 0.5).clamp(0.0, 1.0);
}

class _PanelBackground extends StatelessWidget {
  const _PanelBackground({required this.g, required this.t});

  final _Geometry g;
  final double t;

  @override
  Widget build(BuildContext context) {
    // Owner, 2026-11-21: the rail/panel casts a shadow on the content, so it
    // reads as a layer above it (soft wide shadow + tight contact shadow).
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: railShadows(g.u)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.45, 1],
                colors: [
                  RateelColors.panelTop,
                  RateelColors.panelMid,
                  RateelColors.panelBottom,
                ],
              ),
            ),
          ),
          // Emerald glow rising from the bottom edge (reference: the panel
          // brightens toward the bottom).
          if (t > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: g.u * 11,
              child: Opacity(
                opacity: ((t - 0.4) / 0.6).clamp(0.0, 1.0),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0x800E4630), Color(0x000E4630)],
                    ),
                  ),
                ),
              ),
            ),
          // Star band along the bottom: seamless vector tile from the owner's
          // ornament kit, faint as in the reference.
          if (t > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: g.u * 0.6,
              height: g.u * 8.1,
              child: Opacity(
                opacity: 0.38 * ((t - 0.4) / 0.6).clamp(0.0, 1.0),
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var n = 0; n < 9; n++)
                          SvgPicture.asset(
                            'assets/ui/decor/star_tile.svg',
                            height: g.u * 8.1,
                            width: g.u * 8.1 * 216 / 170,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // 4 px light bevel on the left edge.
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: RateelColors.edgeBevel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ☰ (three 5 px bars) that morphs into ✕ (two 4.8 px strokes), as measured
/// on the references: bars 35 px wide with a 13 px pitch, X 27 px wide.
class _MenuCloseGlyph extends CustomPainter {
  _MenuCloseGlyph({required this.t, required this.u});

  final double t;
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final stroke = lerpDouble(u * 0.59, u * 0.56, t)! + 0.8;
    final paint = Paint()
      ..color = Color.lerp(RateelColors.hamburger, RateelColors.closeWhite, t)!
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final barHalf = (u * 4.1 - stroke) / 2;
    final xHalf = (u * 3.17 * math.sqrt2 - stroke) / 2;
    final half = lerpDouble(barHalf, xHalf, t)!;
    final pitch = u * 1.52 * (1 - t);
    final angle = t * math.pi / 4;
    for (final s in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(c.dx, c.dy + s * pitch);
      canvas.rotate(s * angle);
      canvas.drawLine(Offset(-half, 0), Offset(half, 0), paint);
      canvas.restore();
    }
    if (t < 1) {
      final mid = Paint()
        ..color = paint.color.withValues(alpha: 1 - t)
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      final m = barHalf * (1 - t);
      canvas.drawLine(Offset(c.dx - m, c.dy), Offset(c.dx + m, c.dy), mid);
    }
  }

  @override
  bool shouldRepaint(_MenuCloseGlyph old) => old.t != t || old.u != u;
}

/// Reference geometry, in units of 1% of the screen height (critic-v1.md).
class _Geometry {
  _Geometry(this.w, this.h, this.scroll) : u = h / 100;

  final double w;
  final double h;
  final double u;

  /// Rail scroll in px (closed rail only).
  final double scroll;

  /// Top of the area where rail items may show (below the menu tile).
  double get railTop => u * 11.6;

  double get maxScroll => math.max(
    0,
    railY0((navItems.length - 1).toDouble()) + u * 5.55 + u * 2.5 - h,
  );

  double get railWidth => u * 18.5;
  double get panelWidth => math.min(u * 78.4, w * 0.45);
  double get panelLeft => w - panelWidth;
  double get railCenterX => w - u * 8.8;

  double railY0(double i) => u * 21.3 + i * u * 13.9;
  double railY(double i) => railY0(i) - scroll;
  double rowY(double i) => u * 22.2 + i * u * 11.14;

  Offset railCenter(double i) => Offset(railCenterX, railY(i));
  Offset rowIconCenter(double i) => Offset(w - u * 14.15, rowY(i));

  Rect tileRectAt(double i) =>
      Rect.fromCenter(center: railCenter(i), width: u * 12.3, height: u * 11.1);
  Rect tileRect(int i) => tileRectAt(i.toDouble());

  Rect rowRectAt(double i) => Rect.fromLTRB(
    panelLeft + u * 8.1,
    rowY(i) - u * 5.15,
    w - u * 5.85,
    rowY(i) + u * 5.15,
  );
  Rect rowRect(int i) => rowRectAt(i.toDouble());

  /// The selected row is taller (99 px vs 88 px) and slightly wider on the left.
  Rect selectedRect(double i) {
    final r = rowRectAt(i);
    return Rect.fromLTRB(
      r.left - u * 0.45,
      r.top - u * 0.65,
      r.right,
      r.bottom + u * 0.65,
    );
  }

  double get labelRight => w - u * 23.6;
  double get pillX => panelLeft + u * 16.9;
  double get dividerX => panelLeft + u * 24.0;
}

class _TopClip extends CustomClipper<Rect> {
  _TopClip(this.top);

  final double top;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-size.width, top, size.width * 2, size.height * 2);

  @override
  bool shouldReclip(_TopClip old) => old.top != top;
}
