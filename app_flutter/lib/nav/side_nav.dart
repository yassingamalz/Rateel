import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

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
                      child: ColoredBox(color: Colors.black.withValues(alpha: 0.12 * t)),
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
    final panelLeft = lerpDouble(g.w - g.railWidth, g.panelLeft, t)!;
    final active = _active;
    final widgets = <Widget>[
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
          child: _PanelBackground(g: g, t: t),
        ),
      ),
      // Thin gold arch above the rows (open state only).
      if (t > 0)
        Positioned(
          left: g.panelLeft + g.u * 39.9 - g.u * 20.5 + (1 - t) * g.u * 6,
          top: g.u * 3.6,
          width: g.u * 41,
          child: IgnorePointer(
            child: Opacity(opacity: _late(t), child: Image.asset('assets/ui/decor/arch.png')),
          ),
        ),
      ..._filigree(g, t, active),
      _selectedRow(g, t, active),
    ];
    for (var i = 0; i < navItems.length; i++) {
      widgets.add(_item(g, t, i, active));
    }
    widgets.add(_activeBadge(g, t, active));
    for (var i = 0; i < navItems.length; i++) {
      widgets.add(_icon(g, t, i, active));
      widgets.add(_bubble(g, t, i, active));
    }
    widgets.add(_menuButton(g, t));
    return widgets;
  }

  /// Filigree end caps, half hidden behind both ends of the selected row.
  List<Widget> _filigree(_Geometry g, double t, double active) {
    if (t == 0) return const [];
    final row = g.selectedRect(active);
    final h = g.u * 11.1;
    final w = h * 296 / 500;
    Widget cap(double cx, bool mirror) => Positioned(
          left: cx - w / 2,
          top: row.center.dy - h / 2,
          width: w,
          height: h,
          child: IgnorePointer(
            child: Opacity(
              opacity: _late(t),
              child: Transform.flip(flipX: mirror, child: Image.asset('assets/ui/decor/filigree.png')),
            ),
          ),
        );
    return [cap(row.left - g.u * 1.8, false), cap(row.right + g.u * 1.8, true)];
  }

  /// Tile (closed) that morphs into the row (open).
  Widget _item(_Geometry g, double t, int i, double active) {
    final row = g.rowRect(i);
    final rect = Rect.lerp(g.tileRect(i), row, t)!;
    final radius = lerpDouble(g.u * 2.6, g.u * 3.6, t)!;
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
                    color: Colors.white.withValues(alpha: 0.012),
                    border: Border.all(color: Color.lerp(RateelColors.tileRim, RateelColors.rowRim, t)!, width: 2),
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
                      style: readex(g.u * 4.0, weight: 400, color: RateelColors.label),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: g.dividerX - row.left,
                top: rect.height / 2 - g.u * 2.1,
                child: Opacity(
                  opacity: label,
                  child: Container(width: 2, height: g.u * 4.2, color: RateelColors.divider),
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
    final radius = lerpDouble(g.u * 2.6, g.u * 3.9, t)!;
    return Positioned.fromRect(
      rect: rect,
      child: IgnorePointer(
        child: Opacity(
          opacity: t,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: RateelColors.goldTintRow,
              border: Border.all(color: RateelColors.goldEdge, width: 2.5),
              boxShadow: [
                BoxShadow(color: RateelColors.gold.withValues(alpha: 0.30), blurRadius: g.u * 2),
              ],
            ),
            // 1 px light-gold highlight inside the rim (top and bottom edges).
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius - 2.5),
                border: Border.all(color: RateelColors.goldHighlight.withValues(alpha: 0.85), width: 1),
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
    final center = Offset.lerp(g.railCenter(active), g.rowIconCenter(active), t)!;
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
                  color: RateelColors.gold.withValues(alpha: 0.05),
                  border: Border.all(color: RateelColors.ringLine, width: 1),
                  boxShadow: [
                    BoxShadow(color: RateelColors.gold.withValues(alpha: 0.18), blurRadius: g.u * 2),
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
                border: Border.all(color: RateelColors.iconRing, width: lerpDouble(0, 2, t)!),
                boxShadow: [
                  BoxShadow(
                    color: RateelColors.gold.withValues(alpha: lerpDouble(0.35, 0.0, t)!),
                    blurRadius: g.u * 1.6,
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
    final railC = g.railCenter(i.toDouble()) + Offset(g.u * 0.95, g.u * 0.5) * (1 - activeness);
    final c = Offset.lerp(railC, g.rowIconCenter(i.toDouble()), t)!;
    final size = lerpDouble(g.u * 6.8, lerpDouble(g.u * 6.9, g.u * 7.8, activeness)!, t)!;
    final activeColor = Color.lerp(RateelColors.activeGlyph, RateelColors.gold, t)!;
    final idle = Color.lerp(RateelColors.cream, RateelColors.iconCream, t)!;
    final color = Color.lerp(idle, activeColor, activeness)!;
    return Positioned(
      left: c.dx - size / 2,
      top: c.dy - size / 2,
      width: size,
      height: size,
      child: IgnorePointer(
        child: SvgPicture.asset(
          navItems[i].icon,
          theme: SvgTheme(currentColor: color),
        ),
      ),
    );
  }

  Widget _bubble(_Geometry g, double t, int i, double active) {
    final item = navItems[i];
    final threeDigits = item.count >= 100;
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
            '${item.count}',
            style: readex(lerpDouble(g.u * 2.75, g.u * 2.85, t)!, weight: 700, color: RateelColors.countText)
                .copyWith(height: 1),
          ),
        ),
      ),
    );
  }

  /// Rounded-square menu tile (closed) that becomes the round gold close button.
  Widget _menuButton(_Geometry g, double t) {
    final from = Rect.fromCenter(center: Offset(g.railCenterX, g.u * 6.55), width: g.u * 8.55, height: g.u * 7.4);
    final to = Rect.fromCenter(
        center: Offset(g.panelLeft + g.u * 9.6, g.u * 6.45), width: g.u * 8.2, height: g.u * 8.2);
    final rect = Rect.lerp(from, to, t)!;
    return Positioned.fromRect(
      rect: rect,
      child: Semantics(
        button: true,
        label: t > 0.5 ? 'إغلاق القائمة' : 'القائمة',
        child: GestureDetector(
          onTap: _toggle,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(lerpDouble(g.u * 2.4, rect.width / 2, t)!),
              color: Colors.white.withValues(alpha: lerpDouble(0.025, 0.012, t)!),
              border: Border.all(
                color: Color.lerp(RateelColors.menuTileRim, RateelColors.goldRim, t)!,
                width: lerpDouble(2, 3, t)!,
              ),
            ),
            child: CustomPaint(painter: _MenuCloseGlyph(t: t, u: g.u)),
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
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.45, 1],
              colors: [RateelColors.panelTop, RateelColors.panelMid, RateelColors.panelBottom],
            ),
          ),
        ),
        // Geometric pattern strip along the bottom (open state).
        if (t > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: g.u * 11,
            child: Opacity(
              opacity: ((t - 0.4) / 0.6).clamp(0.0, 1.0),
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.bottomLeft,
                  maxWidth: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var k = 0; k < 4; k++)
                        SvgPicture.asset('assets/ui/decor/bottom_pattern.svg',
                            height: g.u * 11, width: g.u * 11 * 256 / 96),
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
    final stroke = lerpDouble(u * 0.59, u * 0.56, t)!;
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
  _Geometry(this.w, this.h) : u = h / 100;

  final double w;
  final double h;
  final double u;

  double get railWidth => u * 18.5;
  double get panelWidth => math.min(u * 78.4, w * 0.45);
  double get panelLeft => w - panelWidth;
  double get railCenterX => w - u * 8.8;

  double railY(double i) => u * 21.3 + i * u * 13.9;
  double rowY(double i) => u * 22.2 + i * u * 11.14;

  Offset railCenter(double i) => Offset(railCenterX, railY(i));
  Offset rowIconCenter(double i) => Offset(w - u * 14.15, rowY(i));

  Rect tileRectAt(double i) => Rect.fromCenter(center: railCenter(i), width: u * 12.3, height: u * 11.1);
  Rect tileRect(int i) => tileRectAt(i.toDouble());

  Rect rowRectAt(double i) =>
      Rect.fromLTRB(panelLeft + u * 8.1, rowY(i) - u * 5.15, w - u * 5.85, rowY(i) + u * 5.15);
  Rect rowRect(int i) => rowRectAt(i.toDouble());

  /// The selected row is taller (99 px vs 88 px) and slightly wider on the left.
  Rect selectedRect(double i) {
    final r = rowRectAt(i);
    return Rect.fromLTRB(r.left - u * 0.45, r.top - u * 0.65, r.right, r.bottom + u * 0.65);
  }

  double get labelRight => w - u * 23.6;
  double get pillX => panelLeft + u * 16.9;
  double get dividerX => panelLeft + u * 24.0;
}
