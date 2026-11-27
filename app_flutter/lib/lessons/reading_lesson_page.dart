import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../help/reading_help.dart';

import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../theme/rateel_theme.dart';
import 'lesson_data.dart';
import 'lesson_decor.dart';
import 'lesson_shell.dart';
import 'lesson_widgets.dart';
import 'reading_data.dart';

/// Review aids (screen 08): `?readTheme=light`, `?verse=3` (0-based),
/// `?rules=1` opens the rules panel, `?fontMenu=1` opens the «A» menu.
bool readingStartLight = false;
int readingStartVerse = 0;
bool readingStartRules = false;
bool readingStartFontMenu = false;

/// Geometry of screen 08 in u (1% of the screen height), measured on
/// `screens/08-reading-lesson/reference-dark.webp` (1842×854, u = 8.54 px) and
/// `reference-panel.png` (rules panel, «A» menu). x values are from the left
/// or right edge of the content (side margin [side]); header x values from
/// the screen centre.
class ReadMetrics {
  ReadMetrics._();
  static const side = 4.6;
  // Header.
  // Owner's arch R4, fitted by correlation (F1 0.88): 102.1 × 21.5u.
  static const archW = 102.1;
  static const archH = 21.5;
  static const archTop = 0.94;
  static const bookW = 13.8;
  static const bookH = 6.6;
  static const bookTop = 6.0;
  static const mosqueDx = -57.8; // left edge of the mosque image
  static const mosqueTop = 6.4;
  static const mosqueW = 29.4;
  // The arch is hidden left of this x (reference: the mosque covers it).
  static const archClipDx = -37.0;
  // Crescent and star placed separately (IoU 0.85 / 0.93 on the reference).
  static const crescentDx = 49.65; // left edge
  static const crescentTop = 9.6;
  static const crescentH = 9.02;
  static const starDx = 55.04;
  static const starTop = 11.71;
  static const starH = 3.63;
  static const titleCentre = 18.2;
  static const titleSize = 6.3;
  static const dividerTop = 24.6;
  static const dividerW = 72.0;
  static const dividerDiamond = 1.5; // half diagonal
  // Toolbar.
  static const toolTop = 27.9;
  static const toolH = 12.6;
  static const toolRadius = 3.2;
  static const toolMid = 34.3; // vertical centre of its controls
  static const pillInset = 3.7;
  static const pillW = 36.1;
  static const pillH = 8.0;
  static const pillText = 3.5;
  static const infoDisc = 4.4;
  static const moonDx = -8.9; // from the toolbar centre
  static const aDx = 7.6;
  static const sepDx = -0.8;
  static const moonD = 8.2;
  static const aD = 7.7;
  static const chevD = 7.9;
  static const nextInset = 4.5; // toolbar right edge → › rim
  static const counterW = 15.3;
  static const counterH = 6.9;
  static const navGap = 3.6;
  // Card.
  static const cardTop = 43.6;
  static const cardH = 35.4;
  static const cardRadius = 3.6;
  static const cardRim = 0.35;
  static const badgeInset = 6.4; // card right edge → badge
  static const badgeTop = 3.5; // from the card top
  static const badgeH = 9.8;
  static const verseRight = 17.1; // card right edge → text
  static const verseLeft = 8.0;
  static const verseCentre = 18.0; // from the card top
  static const verseSize = 6.9;
  static const bandTop = 17.4; // lattice band, from the card top
  static const cell = 9.2; // lattice cell (card band)
  static const shelf = 83.7;
  // Dots.
  static const dotsY = 90.2;
  static const dot = 2.6;
  static const dotOn = 2.8;
  static const dotGap = 5.5;
  // «تخطي»: the standard lesson button (07), bottom left, centred on the
  // reference's skip centre (88.4u).
  static const skipTop = 81.95;
  // Corners (stepped lattice R1).
  static const cornerW = 58.0;
  static const cornerH = 30.4;
  static const cornerCell = 9.6;
  // Rules panel (reference-panel.png).
  static const panelW = 58.2;
  static const panelMargin = 2.3;
  static const panelTop = 24.0;
  static const panelBottom = 4.0;
  static const panelGap = 1.2;
  // «A» menu.
  // Larger than the reference's menu (owner, 2026-11-25: it must be clear at
  // once that it controls the text size).
  static const menuW = 52.0;
  // Text size only (owner, 2026-11-25: no line spacing control).
  static const menuH = 30.0;

  static const header = HeaderSpec(
    archW: archW,
    archH: archH,
    archTop: archTop,
    archClipDx: archClipDx,
    mosqueDx: mosqueDx,
    mosqueTop: mosqueTop,
    mosqueW: mosqueW,
    crescentDx: crescentDx,
    crescentTop: crescentTop,
    crescentH: crescentH,
    starDx: starDx,
    starTop: starTop,
    starH: starH,
    titleCentre: titleCentre,
    titleSize: titleSize,
    dividerTop: dividerTop,
    dividerW: dividerW,
    dividerDiamond: dividerDiamond,
    bookW: bookW,
    bookH: bookH,
    bookTop: bookTop,
  );
}

Route<bool> readingLessonRoute(
  Lesson lesson,
  int index,
  int count, {
  bool completed = false,
}) => lessonRoute<bool>(
  (context) => ReadingLessonPage(
    lesson: lesson,
    index: index,
    count: count,
    completed: completed,
  ),
);

/// Screen 08, reading lesson (owner, 2026-11-25; plan
/// `docs/flutter/screens/08-reading-lesson.md`): one sentence of the lesson
/// at a time on a gold card, ‹ › / dots / swipe to move, the shared 02 bar
/// (capsule = sentence n/N), «قواعد التجويد» side panel, «A» text-size menu,
/// moon = light/dark reading. Reaching the last sentence completes the lesson
/// after 1.5 s (Angular, «standard» for the owner); «تخطي» completes it at
/// once. Returns `true` when finished.
class ReadingLessonPage extends StatefulWidget {
  const ReadingLessonPage({
    super.key,
    required this.lesson,
    required this.index,
    required this.count,
    this.completed = false,
  });

  final Lesson lesson;
  final int index;
  final int count;
  final bool completed;

  @override
  State<ReadingLessonPage> createState() => _ReadingLessonPageState();
}

class _ReadingLessonPageState extends State<ReadingLessonPage>
    with TickerProviderStateMixin {
  final _shell = GlobalKey<LessonShellState>();
  late final _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _theme = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    value: readingLight.value ? 1 : 0,
  );
  late final _panel = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final _menu = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final _verse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
    value: 1,
  );

  ReadingContent? _content;
  bool _loaded = false;
  bool _helpVisible = false;
  SharedPreferences? _helpPrefs;
  int _index = 0;
  int _from = 0; // sentence leaving during [_verse]
  int _dir = 1; // 1: forward (the card content leaves to the right)
  int _reached = 0;
  String _query = '';
  String? _selectedRule;
  Timer? _autoFinish;
  bool _paused = false;
  bool _finishing = false;
  bool _left = false;
  double _drag = 0;

  int get _n => _content?.verses.length ?? 1;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((prefs) {
          _helpPrefs = prefs;
          if (mounted && !(prefs.getBool('reading_help_seen') ?? false)) {
            setState(() => _helpVisible = true);
            _autoFinish?.cancel();
          }
        })
        .catchError((Object _) {});
    if (readingStartLight) {
      readingLight.value = true;
      _theme.value = 1;
    }
    ReadingContent.load(widget.lesson.id).then((c) {
      if (!mounted) return;
      setState(() {
        _content = c;
        _loaded = true;
        if (c != null) {
          _index = readingStartVerse.clamp(0, c.verses.length - 1);
          _from = _index;
          _reached = _index;
        }
      });
      if (readingStartRules) _panel.value = 1;
      if (readingStartFontMenu) _menu.value = 1;
      _scheduleAutoFinish();
    });
  }

  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    const assets = [
      'assets/ui/reading/lattice_tile.webp',
      'assets/ui/reading/badge_line.webp',
      'assets/ui/reading/badge_fill.webp',
      'assets/ui/reading/arch.webp',
      'assets/ui/decor/mosque.webp',
    ];
    // The entry waits for the images, at most 400 ms.
    Future.any([
      Future.wait([
        for (final a in assets) precacheImage(AssetImage(a), context),
      ]),
      Future<void>.delayed(const Duration(milliseconds: 400)),
    ]).whenComplete(() {
      if (mounted && !_entry.isAnimating && _entry.value == 0) {
        _entry.forward();
      }
    });
  }

  @override
  void dispose() {
    _autoFinish?.cancel();
    _entry.dispose();
    _theme.dispose();
    _panel.dispose();
    _menu.dispose();
    _verse.dispose();
    super.dispose();
  }

  void _leave(bool done) {
    if (_left || !mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    _left = true;
    Navigator.of(context).pop(done);
  }

  /// Angular: the last sentence sets progress 100 and the lesson completes
  /// 1.5 s later. Cancelled while paused or when the learner goes back.
  void _scheduleAutoFinish() {
    if (_helpVisible) return;
    _autoFinish?.cancel();
    if (_content == null || _paused || _index < _n - 1) return;
    _autoFinish = Timer(const Duration(milliseconds: 1500), _finish);
  }

  Future<void> _finish() async {
    if (_finishing || _left) return;
    _finishing = true;
    _autoFinish?.cancel();
    _closeOverlays();
    _shell.currentState?.lock();
    setState(() => _index = _n - 1);
    await Future<void>.delayed(const Duration(milliseconds: 320));
    await _shell.currentState?.celebrate();
    _leave(true);
  }

  void _goTo(int i) {
    final c = _content;
    if (c == null || _finishing) return;
    if (i < 0 || i >= c.verses.length) {
      Haptics.denied();
      return;
    }
    if (i == _index) return;
    Haptics.tick();
    setState(() {
      _dir = i > _index ? 1 : -1;
      _from = _index;
      _index = i;
      _reached = math.max(_reached, i);
    });
    _verse.forward(from: 0);
    _scheduleAutoFinish();
  }

  void _restart() {
    _autoFinish?.cancel();
    _closeOverlays();
    setState(() {
      _from = _index;
      _dir = -1;
      _index = 0;
    });
    _verse.forward(from: 0);
  }

  void _closeOverlays() {
    if (_menu.value > 0) _menu.reverse();
    if (_panel.value > 0) _panel.reverse();
  }

  void _toggleTheme() {
    readingLight.value = !readingLight.value;
    readingLight.value ? _theme.forward() : _theme.reverse();
  }

  void _toggleRules() {
    if (_menu.value > 0) _menu.reverse();
    _panel.value > 0.5 ? _panel.reverse() : _panel.forward();
    setState(() {});
  }

  void _toggleMenu() {
    _menu.value > 0.5 ? _menu.reverse() : _menu.forward();
    setState(() {});
  }

  // Entry: header first, then toolbar, card, dots (70 ms steps), as 07.
  Widget _enter(int k, Widget child) => AnimatedBuilder(
    animation: _entry,
    child: child,
    builder: (context, child) {
      final t = Curves.easeOutCubic.transform(
        ((_entry.value - k * 0.07) / 0.6).clamp(0.0, 1.0),
      );
      return Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 12),
          child: child,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        final light = Curves.easeInOut.transform(_theme.value);
        return Stack(
          children: [
            Positioned.fill(
              child: LessonShell(
                key: _shell,
                step: _content == null ? 0 : _index + 1,
                total: _content == null ? 1 : _n,
                light: light,
                onBack: () => _leave(false),
                onRestart: _restart,
                onPausedChanged: (p) {
                  _paused = p;
                  p ? _autoFinish?.cancel() : _scheduleAutoFinish();
                },
                child: LayoutBuilder(
                  builder: (context, box) =>
                      _page(box, LessonPal(light), box.maxHeight / 100),
                ),
              ),
            ),
            if (_helpVisible)
              Positioned.fill(
                child: ReadingHelp(
                  onClose: () {
                    setState(() => _helpVisible = false);
                    _helpPrefs?.setBool('reading_help_seen', true);
                    _scheduleAutoFinish();
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _page(BoxConstraints box, LessonPal p, double u) {
    final w = box.maxWidth;
    final cx = w / 2;
    _fullWidth = w - 2 * u * ReadMetrics.side;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        RepaintBoundary(
          key: const ValueKey('bg'),
          child: LessonBackground(p: p, u: u),
        ),
        RepaintBoundary(
          key: const ValueKey('header'),
          child: _enter(
            0,
            LessonHeader(
              p: p,
              u: u,
              cx: cx,
              title: _title,
              s: ReadMetrics.header,
            ),
          ),
        ),
        // Content (toolbar, card, dots): narrows while the rules panel is
        // open (reference-panel.png: the panel pushes, it does not cover).
        AnimatedBuilder(
          key: const ValueKey('content'),
          animation: Listenable.merge([_panel, _menu, _verse]),
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_panel.value);
            final right =
                u *
                lerpDoubleSafe(
                  ReadMetrics.side,
                  ReadMetrics.panelMargin +
                      ReadMetrics.panelW +
                      ReadMetrics.panelGap,
                  t,
                );
            final left = u * ReadMetrics.side;
            return Stack(
              fit: StackFit.expand,
              children: _contentLayers(p, u, w, left, right),
            );
          },
        ),
        Positioned(
          key: const ValueKey('skip'),
          left: u * SkipMetrics.side,
          top: u * ReadMetrics.skipTop,
          width: u * SkipMetrics.width,
          height: u * SkipMetrics.height,
          child: _enter(
            3,
            SkipButton(
              u: u,
              light: p.t,
              completed: widget.completed,
              onTap: _finish,
            ),
          ),
        ),
        // Tap outside closes the «A» menu.
        AnimatedBuilder(
          key: const ValueKey('menuScrim'),
          animation: _menu,
          builder: (context, _) => _menu.value == 0
              ? const SizedBox.shrink()
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleMenu,
                ),
        ),
        AnimatedBuilder(
          key: const ValueKey('fontMenu'),
          animation: Listenable.merge([_menu, _panel]),
          builder: (context, _) => _fontMenu(p, u, w),
        ),
        AnimatedBuilder(
          key: const ValueKey('panel'),
          animation: _panel,
          builder: (context, _) => _rulesPanel(p, u, w, box.maxHeight),
        ),
      ],
    );
  }

  String get _title => _content?.title ?? widget.lesson.title;

  /// Card width with the rules panel closed (set in [_page]).
  double _fullWidth = 0;

  // Toolbar, card, shelf and dots inside the content box [left, w - right].
  List<Widget> _contentLayers(
    LessonPal p,
    double u,
    double w,
    double left,
    double right,
  ) {
    final toolW = w - left - right;
    final toolCx = left + toolW / 2;
    final card = Rect.fromLTWH(
      left,
      u * ReadMetrics.cardTop,
      toolW,
      u * ReadMetrics.cardH,
    );
    return [
      Positioned(
        key: const ValueKey('toolbar'),
        left: left,
        right: right,
        top: u * ReadMetrics.toolTop,
        height: u * ReadMetrics.toolH,
        child: _enter(1, _toolbarFrame(p, u)),
      ),
      ..._toolbarControls(p, u, left, right, toolCx, w),
      Positioned.fromRect(
        key: const ValueKey('card'),
        rect: card,
        child: _enter(2, _card(p, u, card.width)),
      ),
      Positioned(
        key: const ValueKey('shelf'),
        left: left,
        right: right,
        top: u * ReadMetrics.shelf - u * 0.6,
        height: u * 1.2,
        child: IgnorePointer(child: CustomPaint(painter: _ShelfPainter(p, u))),
      ),
      if (_content != null)
        Positioned(
          key: const ValueKey('dots'),
          left: left,
          right: right,
          top: u * (ReadMetrics.dotsY - 2.5),
          height: u * 5,
          child: _enter(3, _dots(p, u)),
        ),
    ];
  }

  Widget _toolbarFrame(LessonPal p, double u) => RepaintBoundary(
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * ReadMetrics.toolRadius),
        color: p.c(RateelColors.readToolFill, RateelColors.readLToolFill),
        boxShadow: [
          BoxShadow(
            color: p
                .c(Colors.black, const Color(0xFF8A6A4A))
                .withValues(alpha: p.d(0.35, 0.10)),
            blurRadius: u * 1.6,
            offset: Offset(0, u * 0.5),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: ToolRimPainter(
          radius: u * ReadMetrics.toolRadius,
          width: math.max(1.0, u * 0.25),
          top: p.c(RateelColors.readToolRimTop, RateelColors.readLToolRimTop),
          bottom: p.c(
            RateelColors.readToolRimBottom,
            RateelColors.readLToolRimBottom,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(u * ReadMetrics.toolRadius),
          child: LatticeField(
            p: p,
            u: u,
            cell: ReadMetrics.cell,
            opacity: p.d(0.10, 0.22),
            // Faint lattice behind the controls (reference: two patches,
            // between the pill and the moon and left of the ‹).
            mask: const LinearGradient(
              colors: [
                Color(0x00000000),
                Color(0x00000000),
                Color(0xFF000000),
                Color(0x00000000),
                Color(0x00000000),
                Color(0xFF000000),
                Color(0x00000000),
                Color(0x00000000),
              ],
              stops: [0, 0.17, 0.24, 0.33, 0.66, 0.75, 0.80, 1],
            ),
          ),
        ),
      ),
    ),
  );

  List<Widget> _toolbarControls(
    LessonPal p,
    double u,
    double left,
    double right,
    double toolCx,
    double w,
  ) {
    final mid = u * ReadMetrics.toolMid;
    final rulesOn = _panel.value > 0.5;
    Positioned round(String key, double cx, double d, Widget child) =>
        Positioned(
          key: ValueKey(key),
          left: cx - u * d / 2,
          top: mid - u * d / 2,
          width: u * d,
          height: u * d,
          child: _enter(1, child),
        );
    final toolRight = w - right;
    final nextCx =
        toolRight - u * (ReadMetrics.nextInset + ReadMetrics.chevD / 2);
    final counterCx =
        nextCx -
        u *
            (ReadMetrics.chevD / 2 +
                ReadMetrics.navGap +
                ReadMetrics.counterW / 2);
    final prevCx =
        counterCx -
        u *
            (ReadMetrics.counterW / 2 +
                ReadMetrics.navGap +
                ReadMetrics.chevD / 2);
    return [
      Positioned(
        key: const ValueKey('rulesPill'),
        left: left + u * ReadMetrics.pillInset,
        top: mid - u * ReadMetrics.pillH / 2,
        width: u * ReadMetrics.pillW,
        height: u * ReadMetrics.pillH,
        child: _enter(
          1,
          LessonPill(
            u: u,
            label: 'قواعد التجويد',
            glyph: null,
            gold: rulesOn,
            light: p.t,
            height: ReadMetrics.pillH,
            fontSize: ReadMetrics.pillText,
            leading: _InfoDisc(
              u: u,
              onGold: rulesOn || p.t > 0.5,
              light: p.t > 0.5,
            ),
            onTap: _toggleRules,
          ),
        ),
      ),
      round(
        'moon',
        toolCx + u * ReadMetrics.moonDx,
        ReadMetrics.moonD,
        LessonRoundButton(
          u: u,
          label: p.t > 0.5 ? 'الوضع المظلم' : 'الوضع الفاتح',
          compact: true,
          glyph: PillGlyph.play,
          light: p.t,
          onTap: _toggleTheme,
          child: SizedBox(
            width: u * 3.6,
            height: u * 3.6,
            child: CustomPaint(
              painter: MoonPainter(
                p.c(RateelColors.leaderText, RateelColors.readLInk),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        key: const ValueKey('sep'),
        left: toolCx + u * ReadMetrics.sepDx - u * 0.15,
        top: mid - u * 2.1,
        width: u * 0.3,
        height: u * 4.2,
        child: _enter(
          1,
          ColoredBox(
            color: p.c(RateelColors.readSeparator, RateelColors.readLSeparator),
          ),
        ),
      ),
      round(
        'fontA',
        toolCx + u * ReadMetrics.aDx,
        ReadMetrics.aD,
        LessonRoundButton(
          u: u,
          label: 'حجم الخط',
          glyph: PillGlyph.play,
          light: p.t,
          plain: true,
          onTap: _toggleMenu,
          child: Text(
            'A',
            textDirection: TextDirection.ltr,
            style:
                readex(
                  u * 5.2,
                  weight: 600,
                  // Light: dark ink as the other toolbar glyphs (owner,
                  // 2026-11-25: the reference's white «A» was hard to see).
                  color: p.c(RateelColors.leaderText, RateelColors.readLInk),
                ).copyWith(
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.35 * (1 - p.t)),
                      blurRadius: u * 0.5,
                      offset: Offset(0, u * 0.15),
                    ),
                  ],
                ),
          ),
        ),
      ),
      round(
        'next',
        prevCx,
        ReadMetrics.chevD,
        LessonRoundButton(
          u: u,
          label: 'التالي',
          compact: true,
          glyph: PillGlyph.next,
          glyphSize: 3.2,
          light: p.t,
          onTap: () => _goTo(_index + 1),
        ),
      ),
      Positioned(
        key: const ValueKey('counter'),
        left: counterCx - u * ReadMetrics.counterW / 2,
        top: mid - u * ReadMetrics.counterH / 2,
        width: u * ReadMetrics.counterW,
        height: u * ReadMetrics.counterH,
        child: _enter(
          1,
          IgnorePointer(
            child: LessonPill(
              u: u,
              label: '${_index + 1} / $_n',
              glyph: null,
              dim: true,
              light: p.t,
              height: ReadMetrics.counterH,
              fontSize: 3.0,
              onTap: () {},
            ),
          ),
        ),
      ),
      round(
        'prev',
        nextCx,
        ReadMetrics.chevD,
        LessonRoundButton(
          u: u,
          label: 'السابق',
          compact: true,
          glyph: PillGlyph.previous,
          glyphSize: 3.2,
          light: p.t,
          onTap: () => _goTo(_index - 1),
        ),
      ),
    ];
  }

  Widget _card(LessonPal p, double u, double width) {
    final c = _content;
    final r = u * ReadMetrics.cardRadius;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => _drag = 0,
      onHorizontalDragUpdate: (d) => _drag += d.delta.dx,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        // RTL: the next sentence comes from the left, the finger moves right.
        if (_drag > u * 8 || v > 300) {
          _goTo(_index + 1);
        } else if (_drag < -u * 8 || v < -300) {
          _goTo(_index - 1);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: GoldCardPainter(p, u, r)),
          ),
          // Lattice band along the bottom, fading upwards.
          Positioned(
            left: 0,
            right: 0,
            top: u * ReadMetrics.bandTop,
            bottom: 0,
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(r)),
                child: LatticeField(
                  p: p,
                  u: u,
                  cell: ReadMetrics.cell,
                  opacity: p.d(0.36, 0.5),
                  mask: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xFF000000)],
                    stops: [0.3, 0.92],
                  ),
                ),
              ),
            ),
          ),
          if (c == null)
            Center(
              child: Text(
                _loaded ? 'عذراً، لا يمكن تحميل المحتوى' : '',
                textDirection: TextDirection.rtl,
                style: readex(
                  u * 4.2,
                  weight: 400,
                  color: p.c(RateelColors.cream, RateelColors.readLInk),
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(r),
              child: _verseLayer(p, u, width),
            ),
        ],
      ),
    );
  }

  Widget _verseLayer(LessonPal p, double u, double width) {
    final t = Curves.easeOutCubic.transform(_verse.value);
    final shift = u * 14;
    Widget one(int i, double dx, double o, double badgeScale) => Opacity(
      opacity: o.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: _sentence(p, u, width, i, badgeScale),
      ),
    );
    final moving = _verse.value < 1 && _from != _index;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Forward: the old sentence leaves to the right, the new one comes in
        // from the left (RTL reading); backward the other way.
        if (moving) one(_from, _dir * shift * t, 1 - t * 1.6, 1),
        one(
          _index,
          moving ? -_dir * shift * (1 - t) : 0,
          moving ? (t * 1.4 - 0.2) : 1,
          moving ? 0.8 + 0.2 * Curves.easeOutBack.transform(t) : 1,
        ),
      ],
    );
  }

  Widget _sentence(
    LessonPal p,
    double u,
    double width,
    int i,
    double badgeScale,
  ) {
    final verse = _content!.verses[i];
    final scale = readingFontSize / 24;
    final badgeH = u * ReadMetrics.badgeH;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: u * ReadMetrics.badgeInset,
          top: u * ReadMetrics.badgeTop,
          height: badgeH,
          width: badgeH * 250 / 256,
          child: Transform.scale(
            scale: badgeScale,
            child: LessonBadge(p: p, u: u, number: i + 1),
          ),
        ),
        Positioned(
          left: u * ReadMetrics.verseLeft,
          right: u * ReadMetrics.verseRight,
          top: u * (ReadMetrics.verseCentre - 11),
          height: u * 22,
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              // Laid out at the width of the card with the panel closed, then
              // scaled down while the panel narrows the card: the lines never
              // re-wrap (reference-panel: one line under the open panel).
              child: SizedBox(
                width:
                    _fullWidth -
                    u * (ReadMetrics.verseLeft + ReadMetrics.verseRight),
                // Lesson text keeps its own colour (owner, 2026-11-25: the
                // tajweed wheel colours are for the Quran's ayat, not for the
                // lessons' sentences).
                child: Text.rich(
                  TextSpan(text: verse.text),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style:
                      readex(
                        u * ReadMetrics.verseSize * scale,
                        weight: 600,
                        color: p.c(
                          RateelColors.leaderText,
                          RateelColors.readLInk,
                        ),
                      ).copyWith(
                        // Fixed line height (owner: no spacing control; larger spacing
                        // with a larger text made the lines collide).
                        height: readingLineHeight,
                        shadows: p.t >= 1
                            ? null
                            : [
                                for (final s in titleShadows(u))
                                  Shadow(
                                    color: s.color.withValues(
                                      alpha: s.color.a * (1 - p.t),
                                    ),
                                    blurRadius: s.blurRadius,
                                    offset: s.offset,
                                  ),
                              ],
                      ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dots(LessonPal p, double u) {
    final n = _n;
    // RTL: the first sentence is the rightmost dot.
    return LayoutBuilder(
      builder: (context, box) {
        final cx = box.maxWidth / 2;
        double x(int i) => cx + u * ReadMetrics.dotGap * ((n - 1) / 2 - i);
        final t = Curves.easeOutCubic.transform(_verse.value);
        final onX = _verse.value < 1
            ? x(_from) + (x(_index) - x(_from)) * t
            : x(_index);
        final cy = box.maxHeight / 2;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < n; i++)
              Positioned(
                left: x(i) - u * 2.4,
                top: cy - u * 2.4,
                width: u * 4.8,
                height: u * 4.8,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _goTo(i),
                  child: Center(
                    child: Container(
                      width: u * ReadMetrics.dot,
                      height: u * ReadMetrics.dot,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _reached || i < _index
                            ? p.c(
                                RateelColors.readDotDone,
                                RateelColors.readLDotDone,
                              )
                            : p.c(
                                RateelColors.readDotOff,
                                RateelColors.readLDotOff,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            // The gold dot glides to the current sentence.
            Positioned(
              left: onX - u * ReadMetrics.dotOn / 2,
              top: cy - u * ReadMetrics.dotOn / 2,
              width: u * ReadMetrics.dotOn,
              height: u * ReadMetrics.dotOn,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.c(RateelColors.readDotOn, RateelColors.readLDotOn),
                    boxShadow: [
                      BoxShadow(
                        color: RateelColors.readDotOn.withValues(
                          alpha: 0.45 * (1 - p.t),
                        ),
                        blurRadius: u * 1.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // «A» menu: text size and line spacing (reference-panel.png), under the A.
  Widget _fontMenu(LessonPal p, double u, double w) {
    final v = _menu.value;
    if (v == 0) return const SizedBox.shrink();
    final t = Curves.easeOutCubic.transform(v);
    final right =
        u *
        lerpDoubleSafe(
          ReadMetrics.side,
          ReadMetrics.panelMargin + ReadMetrics.panelW + ReadMetrics.panelGap,
          Curves.easeOutCubic.transform(_panel.value),
        );
    final left = u * ReadMetrics.side;
    final toolCx = left + (w - left - right) / 2;
    final ax = toolCx + u * ReadMetrics.aDx;
    final top = u * (ReadMetrics.toolTop + ReadMetrics.toolH) + u * 0.3;
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    // Plain − (left) and + (right), drawn centred in luminous circles
    // (owner, 2026-11-25: variant A of `size-popup-variants-v2.png`).
    Widget step(String label, VoidCallback onTap, bool enabled) => SizedBox(
      width: u * 10,
      height: u * 10,
      child: LessonRoundButton(
        u: u,
        label: label,
        glyph: PillGlyph.play,
        light: p.t,
        enabled: enabled,
        onTap: onTap,
        child: SizedBox(
          width: u * 4.2,
          height: u * 4.2,
          child: CustomPaint(
            painter: _SignPainter(plus: label == 'تكبير', color: ink),
          ),
        ),
      ),
    );
    Widget value(String s) => Container(
      width: u * 15,
      height: u * 7.6,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 3.8),
        color: p.c(RateelColors.videoSkipFill, RateelColors.readLPillFill),
        border: Border.all(
          color: p.c(RateelColors.readCounterRim, RateelColors.readLPillRim),
          width: u * 0.22,
        ),
      ),
      child: Text(
        s,
        textDirection: TextDirection.ltr,
        style: readex(u * 4.4, weight: 600, color: ink).copyWith(height: 1.0),
      ),
    );
    Widget title(String s) => Text(
      s,
      textDirection: TextDirection.rtl,
      style: readex(u * 4.8, weight: 600, color: ink),
    );
    return Positioned(
      left: ax - u * ReadMetrics.menuW / 2,
      top: top,
      width: u * ReadMetrics.menuW,
      height: u * ReadMetrics.menuH + u * 1.6,
      child: Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, -u * 1.5 * (1 - t)),
          child: Transform.scale(
            scale: 0.94 + 0.06 * t,
            alignment: Alignment.topCenter,
            child: CustomPaint(
              painter: _MenuPainter(p, u),
              child: Padding(
                padding: EdgeInsets.only(top: u * 1.6),
                child: Column(
                  children: [
                    SizedBox(height: u * 2.8),
                    title('حجم الخط'),
                    SizedBox(height: u * 2.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.ltr,
                      children: [
                        step('تصغير', () {
                          Haptics.tick();
                          setState(() => readingFontSize -= 2);
                        }, readingFontSize > 18),
                        SizedBox(width: u * 2.6),
                        value('$readingFontSize'),
                        SizedBox(width: u * 2.6),
                        step('تكبير', () {
                          Haptics.tick();
                          setState(() => readingFontSize += 2);
                        }, readingFontSize < 36),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Rule detail (owner, 2026-11-25): opens over the whole screen, which is
  /// veiled and blurred with the pause-menu tokens (`lessonVeil`, blur σ
  /// 0.55u); explains the rule in words, with an audio-example button for
  /// later (not active yet).
  void _openRule(TajweedRule r, LessonPal p) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierLabel: 'إغلاق',
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, a, _) => Material(
          type: MaterialType.transparency,
          child: _RuleSheet(rule: r, p: p, anim: a),
        ),
      ),
    );
  }

  // «قواعد التجويد» side panel (reference-panel.png).
  Widget _rulesPanel(LessonPal p, double u, double w, double h) {
    final v = _panel.value;
    if (v == 0) return const SizedBox.shrink();
    final t = Curves.easeOutCubic.transform(v);
    final pw = u * ReadMetrics.panelW;
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    final soft = p.c(
      RateelColors.cream.withValues(alpha: 0.82),
      RateelColors.readLInk.withValues(alpha: 0.75),
    );
    final q = _query.trim();
    final rules = [
      for (final r in tajweedRules)
        if (q.isEmpty || r.name.contains(q) || r.description.contains(q)) r,
    ];
    return Positioned(
      right: u * ReadMetrics.panelMargin - (pw + u * 3) * (1 - t),
      top: u * ReadMetrics.panelTop,
      bottom: u * ReadMetrics.panelBottom,
      width: pw,
      child: Opacity(
        opacity: (t * 1.5).clamp(0.0, 1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(u * 3.2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                p.c(RateelColors.readCardTop, RateelColors.readLCardTop),
                p.c(RateelColors.readCardBottom, RateelColors.readLCardBottom),
              ],
            ),
            border: Border.all(
              color: p.c(
                RateelColors.readCardRimSide,
                RateelColors.readLCardRimSide,
              ),
              width: u * 0.3,
            ),
            boxShadow: [
              BoxShadow(
                color: p
                    .c(RateelColors.videoSkipRim, const Color(0xFF8A6A4A))
                    .withValues(alpha: p.d(0.35, 0.18)),
                blurRadius: u * 2.2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: p.d(0.4, 0.08)),
                blurRadius: u * 3,
                offset: Offset(-u * 0.8, u * 0.6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(u * 3.2, u * 2.6, u * 3.2, u * 2.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: u * 7,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'قواعد التجويد',
                              textDirection: TextDirection.rtl,
                              style: readex(u * 4.6, weight: 600, color: ink)
                                  .copyWith(
                                    shadows: p.t > 0.5 ? null : titleShadows(u),
                                  ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: u * 1.6),
                      SizedBox(
                        width: u * 6.6,
                        height: u * 6.6,
                        child: LessonRoundButton(
                          u: u,
                          label: 'إغلاق',
                          glyph: PillGlyph.play,
                          light: p.t,
                          onTap: _toggleRules,
                          child: SizedBox(
                            width: u * 2.6,
                            height: u * 2.6,
                            child: CustomPaint(painter: _ClosePainter(ink)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: u * 1.6),
                _SearchField(
                  p: p,
                  u: u,
                  onChanged: (s) => setState(() => _query = s),
                ),
                SizedBox(height: u * 2.6),
                Expanded(
                  child: rules.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد نتائج للبحث',
                            textDirection: TextDirection.rtl,
                            style: readex(u * 3.2, weight: 400, color: soft),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: rules.length,
                          separatorBuilder: (_, _) => SizedBox(height: u * 1.4),
                          itemBuilder: (context, i) {
                            final r = rules[i];
                            final on = _selectedRule == r.id;
                            return GestureDetector(
                              onTap: () {
                                Haptics.tap();
                                setState(() => _selectedRule = r.id);
                                _openRule(r, p);
                              },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                  u * 2.4,
                                  u * 1.5,
                                  u * 2.0,
                                  u * 1.5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(u * 2.6),
                                  color: p.c(
                                    RateelColors.readToolFill,
                                    RateelColors.readLToolFill,
                                  ),
                                  border: Border.all(
                                    color: on
                                        ? p.c(
                                            RateelColors.videoSkipRim,
                                            RateelColors.readLCopper,
                                          )
                                        : p.c(
                                            RateelColors.readToolRimTop,
                                            RateelColors.readLPillRim,
                                          ),
                                    width: u * 0.25,
                                  ),
                                ),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Container(
                                      width: u * 2.4,
                                      height: u * 2.4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: r.color,
                                        boxShadow: [
                                          BoxShadow(
                                            color: r.color.withValues(
                                              alpha: 0.5,
                                            ),
                                            blurRadius: u * 0.8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: u * 2.2),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            r.name,
                                            textDirection: TextDirection.rtl,
                                            style: readex(
                                              u * 3.8,
                                              weight: 600,
                                              color: ink,
                                            ).copyWith(height: 1.25),
                                          ),
                                          // One line as the reference; the
                                          // selected rule shows it whole.
                                          Text(
                                            r.description,
                                            textDirection: TextDirection.rtl,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: readex(
                                              u * 2.7,
                                              weight: 360,
                                              color: soft,
                                            ).copyWith(height: 1.35),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
}

double lerpDoubleSafe(double a, double b, double t) => a + (b - a) * t;

/// ⓘ disc of «قواعد التجويد»: gold disc, dark «i»; on the gold (panel open)
/// a dark disc with a gold «i».
class _InfoDisc extends StatelessWidget {
  const _InfoDisc({required this.u, required this.onGold, this.light = false});

  final double u;
  final bool light;

  /// Dark disc with a light «i» (on the gold pill, and in the light theme).
  final bool onGold;

  @override
  Widget build(BuildContext context) {
    final d = u * ReadMetrics.infoDisc;
    return Container(
      width: d,
      height: d,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: onGold
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [RateelColors.badgeTop, RateelColors.amber],
              ),
        color: onGold
            ? (light ? RateelColors.readLInk : RateelColors.countText)
            : null,
      ),
      child: Text(
        'i',
        textDirection: TextDirection.ltr,
        style: readex(
          u * 3.2,
          weight: 800,
          color: onGold
              ? (light ? Colors.white : RateelColors.badgeTop)
              : RateelColors.countText,
        ).copyWith(height: 1.0),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.p,
    required this.u,
    required this.onChanged,
  });

  final LessonPal p;
  final double u;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    return Container(
      height: u * 6.4,
      padding: EdgeInsets.symmetric(horizontal: u * 2.4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 3.2),
        color: p.c(RateelColors.readToolFill, RateelColors.readLToolFill),
        border: Border.all(
          color: p.c(RateelColors.readToolRimTop, RateelColors.readLPillRim),
          width: u * 0.25,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: u * 3.2,
            height: u * 3.2,
            child: CustomPaint(painter: _SearchPainter(ink)),
          ),
          SizedBox(width: u * 1.6),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textDirection: TextDirection.rtl,
              cursorColor: ink,
              style: readex(u * 3.0, weight: 400, color: ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'ابحث عن قاعدة...',
                hintTextDirection: TextDirection.rtl,
                hintStyle: readex(
                  u * 3.0,
                  weight: 340,
                  color: ink.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint line under the card (reference: a lighter line at 83.7u, fading
/// out towards both ends).
class _ShelfPainter extends CustomPainter {
  _ShelfPainter(this.p, this.u);

  final LessonPal p;
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final c = p.c(RateelColors.readShelf, RateelColors.readLShelf);
    final rect = Rect.fromLTWH(
      0,
      size.height / 2 - u * 0.12,
      size.width,
      u * 0.24,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [c.withValues(alpha: 0), c, c, c.withValues(alpha: 0)],
          stops: const [0, 0.15, 0.85, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ShelfPainter o) => o.p.t != p.t || o.u != u;
}

/// Box of the «A» menu with its pointer at the top centre.
class _MenuPainter extends CustomPainter {
  _MenuPainter(this.p, this.u);

  final LessonPal p;
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final nub = u * 1.6;
    final body = Rect.fromLTWH(0, nub, size.width, size.height - nub);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(body, Radius.circular(u * 2.8)))
      ..moveTo(size.width / 2 - nub, nub + 1)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width / 2 + nub, nub + 1)
      ..close();
    canvas.drawPath(
      path.shift(Offset(0, u * 0.6)),
      Paint()
        ..color = Colors.black.withValues(alpha: p.d(0.45, 0.12))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.4),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = RateelColors.videoSkipRim.withValues(alpha: 0.35 * (1 - p.t))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 1.2),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.c(RateelColors.readCardTop, RateelColors.readLCardTop),
            p.c(RateelColors.readCardBottom, RateelColors.readLCardBottom),
          ],
        ).createShader(body),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.28
        ..strokeJoin = StrokeJoin.round
        ..color = p.c(RateelColors.videoSkipRim, RateelColors.readLCardRimSide),
    );
  }

  @override
  bool shouldRepaint(_MenuPainter o) => o.p.t != p.t || o.u != u;
}

class _ClosePainter extends CustomPainter {
  _ClosePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), s);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), s);
  }

  @override
  bool shouldRepaint(_ClosePainter o) => o.color != color;
}

class _SearchPainter extends CustomPainter {
  _SearchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final s = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.11
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(w * 0.58, w * 0.42), w * 0.32, s);
    canvas.drawLine(Offset(w * 0.34, w * 0.66), Offset(w * 0.08, w * 0.92), s);
  }

  @override
  bool shouldRepaint(_SearchPainter o) => o.color != color;
}

/// The rule detail over the veiled, blurred lesson (pause-menu tokens).
class _RuleSheet extends StatefulWidget {
  const _RuleSheet({required this.rule, required this.p, required this.anim});

  final TajweedRule rule;
  final LessonPal p;
  final Animation<double> anim;

  @override
  State<_RuleSheet> createState() => _RuleSheetState();
}

class _RuleSheetState extends State<_RuleSheet> {
  bool _soon = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final r = widget.rule;
    return LayoutBuilder(
      builder: (context, box) {
        final u = box.maxHeight / 100;
        final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
        final soft = p.c(
          RateelColors.cream.withValues(alpha: 0.86),
          RateelColors.readLInk.withValues(alpha: 0.8),
        );
        return AnimatedBuilder(
          animation: widget.anim,
          builder: (context, _) {
            final t = Curves.easeOut.transform(widget.anim.value);
            return Stack(
              fit: StackFit.expand,
              children: [
                // Veil + blur of everything underneath (02 pause menu).
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: u * 0.55 * t,
                      sigmaY: u * 0.55 * t,
                    ),
                    child: ColoredBox(
                      color: RateelColors.lessonVeil.withValues(
                        alpha: RateelColors.lessonVeil.a * t,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: 0.92 + 0.08 * t,
                      child: Container(
                        width: u * 100,
                        padding: EdgeInsets.fromLTRB(
                          u * 5,
                          u * 3.6,
                          u * 5,
                          u * 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(u * 3.6),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              p.c(
                                RateelColors.readCardTop,
                                RateelColors.readLCardTop,
                              ),
                              p.c(
                                RateelColors.readCardMid,
                                RateelColors.readLCardMid,
                              ),
                              p.c(
                                RateelColors.readCardBottom,
                                RateelColors.readLCardBottom,
                              ),
                            ],
                            stops: const [0, 0.28, 1],
                          ),
                          border: Border.all(
                            color: p.c(
                              RateelColors.readCardRim,
                              RateelColors.readLCardRimSide,
                            ),
                            width: u * 0.35,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: RateelColors.videoSkipRim.withValues(
                                alpha: 0.38 * (1 - p.t),
                              ),
                              blurRadius: u * 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: p.d(0.45, 0.15),
                              ),
                              blurRadius: u * 3,
                              offset: Offset(0, u * 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Container(
                                  width: u * 3.2,
                                  height: u * 3.2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: r.color,
                                    boxShadow: [
                                      BoxShadow(
                                        color: r.color.withValues(alpha: 0.5),
                                        blurRadius: u * 1,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: u * 2.4),
                                Expanded(
                                  child: Text(
                                    r.name,
                                    textDirection: TextDirection.rtl,
                                    style:
                                        readex(
                                          u * 7,
                                          weight: 600,
                                          color: ink,
                                        ).copyWith(
                                          shadows: p.t > 0.5
                                              ? null
                                              : titleShadows(u),
                                        ),
                                  ),
                                ),
                                SizedBox(
                                  width: u * 7.4,
                                  height: u * 7.4,
                                  child: LessonRoundButton(
                                    u: u,
                                    label: 'إغلاق',
                                    glyph: PillGlyph.play,
                                    light: p.t,
                                    onTap: () =>
                                        Navigator.of(context).maybePop(),
                                    child: SizedBox(
                                      width: u * 2.8,
                                      height: u * 2.8,
                                      child: CustomPaint(
                                        painter: _ClosePainter(ink),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: u * 1.6),
                            SizedBox(
                              width: u * 52,
                              height: u * 4,
                              child: p.t > 0
                                  ? ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        p.c(
                                          RateelColors.videoDivider,
                                          RateelColors.readLCopper,
                                        ),
                                        BlendMode.srcIn,
                                      ),
                                      child: GoldDivider(u: u, diamond: 1.5),
                                    )
                                  : GoldDivider(u: u, diamond: 1.5),
                            ),
                            SizedBox(height: u * 2.4),
                            Text(
                              r.description,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: readex(
                                u * 4.6,
                                weight: 400,
                                color: soft,
                              ).copyWith(height: 1.5),
                            ),
                            SizedBox(height: u * 4),
                            // Audio example: the button only, for later.
                            SizedBox(
                              width: u * 44,
                              height: u * 10,
                              child: Opacity(
                                opacity: 0.75,
                                child: LessonPill(
                                  u: u,
                                  label: 'استمع إلى مثال',
                                  glyph: PillGlyph.play,
                                  light: p.t,
                                  height: 10,
                                  fontSize: 4.0,
                                  onTap: () {
                                    Haptics.denied();
                                    setState(() => _soon = true);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: u * 1.4),
                            AnimatedOpacity(
                              opacity: _soon ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                'المثال الصوتي قريبًا',
                                textDirection: TextDirection.rtl,
                                style: readex(
                                  u * 3.2,
                                  weight: 400,
                                  color: soft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// «−» / «+» of the text-size popup, centred in their box.
class _SignPainter extends CustomPainter {
  _SignPainter({required this.plus, required this.color});

  final bool plus;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final h = size.width / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.17
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c - Offset(h * 0.8, 0), c + Offset(h * 0.8, 0), paint);
    if (plus) {
      canvas.drawLine(c - Offset(0, h * 0.8), c + Offset(0, h * 0.8), paint);
    }
  }

  @override
  bool shouldRepaint(_SignPainter o) => o.plus != plus || o.color != color;
}
