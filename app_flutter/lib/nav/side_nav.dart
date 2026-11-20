import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/rateel_theme.dart';
import 'nav_items.dart';

/// Side navigation, screen 04 (docs/flutter/screens/04-side-nav.md).
///
/// One widget draws both states. The closed rail (style C) widens into the
/// open menu: every tile morphs into its row, every icon and count bubble
/// glides to its place in the row, the menu button becomes the close button.
/// All geometry is in units of 1% of the screen height, measured on the
/// ChatGPT references (05 for the rail, 04 for the open menu).
class SideNavScaffold extends StatefulWidget {
  const SideNavScaffold({super.key, required this.builder});

  /// Builds the screen shown next to the rail for the selected section.
  final Widget Function(BuildContext context, int selected) builder;

  @override
  State<SideNavScaffold> createState() => _SideNavScaffoldState();
}

class _SideNavScaffoldState extends State<SideNavScaffold> with TickerProviderStateMixin {
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _select = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  int _selected = 0;
  double _selectFrom = 0;

  bool get _isOpen => _open.value > 0.5 || _open.status == AnimationStatus.forward;

  double get _active =>
      lerpDouble(_selectFrom, _selected.toDouble(), Curves.easeInOutCubic.transform(_select.value))!;

  @override
  void dispose() {
    _open.dispose();
    _select.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    _isOpen ? _close() : _open.forward();
  }

  void _close() => _open.reverse();

  void _pick(int index) {
    HapticFeedback.selectionClick();
    if (index != _selected) {
      setState(() {
        _selectFrom = _active;
        _selected = index;
      });
      _select.forward(from: 0);
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
      child: LayoutBuilder(builder: (context, box) {
        final g = _Geometry(box.maxWidth, box.maxHeight);
        return AnimatedBuilder(
          animation: Listenable.merge([_open, _select]),
          builder: (context, _) {
            final t = Curves.easeInOutCubic.transform(_open.value);
            return Stack(
              fit: StackFit.expand,
              children: [
                // Screen content, left of the rail.
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
                // Dimmed content while the menu is open; tap to close.
                if (t > 0)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _close,
                      child: ColoredBox(color: Colors.black.withValues(alpha: 0.42 * t)),
                    ),
                  ),
                ..._panel(g, t),
              ],
            );
          },
        );
      }),
    );
  }

  List<Widget> _panel(_Geometry g, double t) {
    final panelLeft = lerpDouble(g.w - g.railWidth, g.w - g.panelWidth, t)!;
    final active = _active;
    final widgets = <Widget>[
      // Panel body (the rail when closed). Swipe right to close.
      Positioned(
        left: panelLeft,
        top: 0,
        bottom: 0,
        right: 0,
        child: GestureDetector(
          onHorizontalDragUpdate: (d) {
            if (_open.value == 0) return;
            _open.value -= d.delta.dx / (g.panelWidth - g.railWidth);
          },
          onHorizontalDragEnd: (d) {
            if (_open.value == 0) return;
            final v = d.primaryVelocity ?? 0;
            (v > 300 || _open.value < 0.6) ? _close() : _open.forward();
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [RateelColors.panelTop, RateelColors.panelBottom],
              ),
              border: const Border(left: BorderSide(color: RateelColors.railEdge, width: 1.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35 + 0.2 * t),
                  blurRadius: g.u * (2 + 3 * t),
                  offset: Offset(-g.u * 0.4, 0),
                ),
              ],
            ),
          ),
        ),
      ),
      // Selected row highlight (open menu), glides with the selection.
      _selectedRow(g, t, active),
    ];

    for (var i = 0; i < navItems.length; i++) {
      widgets.add(_item(g, t, i, active));
    }
    widgets.add(_activeBadge(g, t, active));
    for (var i = 0; i < navItems.length; i++) {
      widgets.add(_icon(g, t, i, active));
      widgets.add(_bubble(g, t, i));
    }
    widgets.add(_menuButton(g, t));
    return widgets;
  }

  /// Tile (closed) that morphs into the row capsule (open).
  Widget _item(_Geometry g, double t, int i, double active) {
    final rect = Rect.lerp(g.tileRect(i), g.rowRect(i), t)!;
    final radius = lerpDouble(g.u * 2.4, rect.height / 2, t)!;
    final activeness = (1 - (active - i).abs()).clamp(0.0, 1.0);
    // The active rail item has no tile: only the gold circle.
    final tileOpacity = lerpDouble(1 - activeness, 1, t)!;
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
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.055), Colors.white.withValues(alpha: 0.015)],
                    ),
                    border: Border.all(color: RateelColors.glassRim, width: 1),
                  ),
                ),
              ),
            ),
            if (label > 0) ...[
              // Label, right-aligned before the icon.
              Positioned(
                right: rect.right - g.labelRight + g.u * 2 * (1 - label),
                top: 0,
                bottom: 0,
                child: Opacity(
                  opacity: label,
                  child: Center(
                    child: Text(
                      navItems[i].label,
                      textDirection: TextDirection.rtl,
                      style: readex(g.u * 3.6, weight: 500),
                    ),
                  ),
                ),
              ),
              // Thin divider between label and count.
              Positioned(
                left: g.dividerX - rect.left,
                top: rect.height / 2 - g.u * 1.8,
                child: Opacity(
                  opacity: label * 0.5,
                  child: Container(width: 1, height: g.u * 3.6, color: RateelColors.cream.withValues(alpha: 0.5)),
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
    // Grows out of the active rail tile, like the other rows.
    final rect = Rect.lerp(g.tileRectAt(active), g.rowRectAt(active), t)!;
    return Positioned.fromRect(
      rect: rect,
      child: IgnorePointer(
        child: Opacity(
          opacity: t,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(lerpDouble(g.u * 2.4, rect.height / 2, t)!),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.alphaBlend(RateelColors.gold.withValues(alpha: 0.13), RateelColors.panelTop),
                  Color.alphaBlend(RateelColors.gold.withValues(alpha: 0.04), RateelColors.panelBottom),
                ],
              ),
              border: Border.all(color: RateelColors.gold, width: 2),
              boxShadow: [
                BoxShadow(color: RateelColors.gold.withValues(alpha: 0.28), blurRadius: g.u * 2.4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gold circle of the active item: filled in the rail, ringed in the menu.
  Widget _activeBadge(_Geometry g, double t, double active) {
    final center = Offset.lerp(g.railIconCenter(active), g.rowIconCenter(active), t)!;
    final inner = lerpDouble(g.u * 9.2, g.u * 7.6, t)!;
    final ring = lerpDouble(g.u * 12.6, g.u * 7.6, t)!;
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
                  color: RateelColors.gold.withValues(alpha: 0.10),
                  border: Border.all(color: RateelColors.gold.withValues(alpha: 0.75), width: 1.6),
                  boxShadow: [
                    BoxShadow(color: RateelColors.gold.withValues(alpha: 0.30), blurRadius: g.u * 2.4),
                  ],
                ),
              ),
            ),
            Container(
              width: inner,
              height: inner,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.4),
                  colors: [
                    Color.lerp(RateelColors.goldLight, const Color(0xFF2B3A1B), t)!,
                    Color.lerp(RateelColors.gold, const Color(0xFF1B3220), t)!,
                  ],
                ),
                border: Border.all(color: RateelColors.gold, width: lerpDouble(0, 2, t)!),
                boxShadow: [
                  BoxShadow(
                    color: RateelColors.gold.withValues(alpha: lerpDouble(0.55, 0.25, t)!),
                    blurRadius: g.u * 2,
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
    final item = navItems[i];
    final center = Offset.lerp(g.railIconCenter(i.toDouble()) + Offset(g.u * 0.6, g.u * 0.6),
        g.rowIconCenter(i.toDouble()), t)!;
    final size = lerpDouble(g.u * 5.0, g.u * 4.2, t)!;
    final activeness = (1 - (active - i).abs()).clamp(0.0, 1.0);
    final activeColor = Color.lerp(const Color(0xFF1E2A12), RateelColors.gold, t)!;
    final color = Color.lerp(RateelColors.cream, activeColor, activeness)!;
    // The active rail icon sits centred in its gold circle.
    final c = Offset.lerp(center, Offset.lerp(g.railIconCenter(i.toDouble()), g.rowIconCenter(i.toDouble()), t)!,
        activeness)!;
    final box = size * 1.6;
    return Positioned(
      left: c.dx - box / 2,
      top: c.dy - box / 2,
      width: box,
      height: box,
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(opacity: 1 - t, child: FaIcon(item.railIcon, size: size, color: color)),
            Opacity(opacity: t, child: FaIcon(item.menuIcon, size: size, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _bubble(_Geometry g, double t, int i) {
    final item = navItems[i];
    final tile = g.tileRect(i);
    final from = Offset(tile.left + g.u * 2.0, tile.top + g.u * 2.6);
    final to = Offset(g.pillX, g.rowY(i.toDouble()));
    final center = Offset.lerp(from, to, t)!;
    final h = lerpDouble(g.u * 4.4, g.u * 4.0, t)!;
    final railW = item.count >= 100 ? g.u * 7.6 : g.u * 6.4;
    final w = lerpDouble(railW, g.u * 7.6, t)!;
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
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [RateelColors.goldLight, RateelColors.gold],
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.30), blurRadius: g.u * 0.8, offset: Offset(0, g.u * 0.3)),
            ],
          ),
          child: Text(
            '${item.count}',
            style: readex(g.u * 2.5, weight: 700, color: RateelColors.bubbleText).copyWith(height: 1),
          ),
        ),
      ),
    );
  }

  /// Rounded-square menu button (closed) that becomes the round close button.
  Widget _menuButton(_Geometry g, double t) {
    final from = Rect.fromCenter(center: Offset(g.railCenterX, g.u * 6.4), width: g.u * 8.4, height: g.u * 8.4);
    final to = Rect.fromCenter(
        center: Offset(g.w - g.panelWidth + g.u * 8.8, g.u * 6.4), width: g.u * 7.4, height: g.u * 7.4);
    final rect = Rect.lerp(from, to, t)!;
    return Positioned.fromRect(
      rect: rect,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(lerpDouble(g.u * 2.3, rect.width / 2, t)!),
            color: Colors.white.withValues(alpha: lerpDouble(0.04, 0.02, t)!),
            border: Border.all(
              color: Color.lerp(RateelColors.glassRim, RateelColors.gold.withValues(alpha: 0.85), t)!,
              width: lerpDouble(1, 1.6, t)!,
            ),
          ),
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: AlwaysStoppedAnimation(t),
            size: g.u * 4.4,
            color: RateelColors.cream,
            semanticLabel: t > 0.5 ? 'إغلاق القائمة' : 'القائمة',
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
}

/// Reference geometry, in units of 1% of the screen height.
class _Geometry {
  _Geometry(this.w, this.h) : u = h / 100;

  final double w;
  final double h;
  final double u;

  double get railWidth => u * 19;
  double get panelWidth => math.min(u * 78, w * 0.45);
  double get railCenterX => w - u * 9.2;

  double railY(double i) => u * 20.4 + i * u * 13;
  double rowY(double i) => u * 22 + i * u * 11.1;

  Offset railIconCenter(double i) => Offset(railCenterX, railY(i));
  Offset rowIconCenter(double i) => Offset(w - u * 12.6, rowY(i));

  Rect tileRectAt(double i) =>
      Rect.fromCenter(center: Offset(railCenterX, railY(i)), width: u * 12.3, height: u * 10.8);

  Rect tileRect(int i) => tileRectAt(i.toDouble());

  Rect rowRectAt(double i) {
    final left = w - panelWidth + u * 10;
    final right = w - u * 5.3;
    return Rect.fromLTRB(left, rowY(i) - u * 4.9, right, rowY(i) + u * 4.9);
  }

  Rect rowRect(int i) => rowRectAt(i.toDouble());

  double get labelRight => w - u * 19.5;
  double get dividerX => w - panelWidth + u * 21.7;
  double get pillX => w - panelWidth + u * 15.3;
}
