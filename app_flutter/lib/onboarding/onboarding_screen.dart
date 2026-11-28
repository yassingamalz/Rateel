import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../core/app_settings.dart';
import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../core/user_profile.dart';
import '../lessons/lesson_decor.dart';
import '../lessons/lesson_widgets.dart';
import '../lessons/test_lesson_page.dart' show LessonButton, LessonBtnGlyph;
import '../theme/rateel_theme.dart';

/// Geometry of screen 30 in u (1% of the height), measured on the dark
/// references `screens/30-onboarding/reference-*-dark.webp` at 1844×853
/// (u = 8.53 px); x from the screen centre unless said. Shared elements have
/// one place for the three steps (owner, 2026-11-28, plan Q1).
class OnbMetrics {
  OnbMetrics._();
  // Shared.
  static const emblemW = 15.8;
  static const emblemTop = 2.3;
  static const titleCy = 22.4;
  static const titleSize = 7.6;
  static const dividerTop = 29.3;
  static const dividerW = 45.0; // owner Q2
  static const subtitleCy = 34.1;
  static const subtitleSize = 3.6;
  static const dotsCy = 90.5;
  static const dotW = 4.5;
  static const dotOnW = 7.7;
  static const dotH = 1.9;
  static const dotGap = 2.1;
  static const btnLeft = 7.0;
  static const btnW = 29.3;
  static const btnWideW = 43.4; // «ابدأ التعلّم»
  static const btnH = 9.8;
  static const btnText = 4.3;
  static const backD = 10.2;
  static const backRight = 5.4;
  static const mosqueW = 40.0;
  static const mosqueRight = 4.6;
  static const mosqueBottom = 90.3; // base line of the mosque
  static const moonCx = 11.5; // the moon button of 10 (owner Q10)
  static const moonCy = 22.0;
  static const moonD = 8.8;
  // Step A card.
  static const cardW = 117.0;
  static const cardTop = 39.4;
  static const cardH = 46.0;
  static const cardRadius = 3.5;
  static const labelRight = 6.4;
  static const labelSize = 3.6;
  static const label1Cy = 43.7;
  static const fieldInset = 6.0;
  static const fieldTop = 48.1;
  static const fieldH = 7.3;
  static const fieldTextRight = 5.2;
  static const fieldTextSize = 3.2;
  static const sepY = 58.3;
  static const sepInset = 2.3;
  static const label2Cy = 61.5;
  static const avatarD = 15.0;
  static const avatarCy = 73.9;
  static const avatarPitch = 17.6;
  static const avatarFirstRight = 14.5; // first centre from the card's right
  static const bandH = 6.5; // lattice band at the card bottom (owner Q6)
  // Option cards (B, C).
  static const optRadius = 3.0; // tile radius token
  static const levelW = 41.4;
  static const levelH = 35.3;
  static const levelTop = 42.4;
  static const levelPitch = 45.9;
  static const levelGlyphCy = 50.4;
  static const levelGlyphH = 8.0;
  static const levelNameCy = 59.2;
  static const levelNameSize = 4.9;
  static const levelDivY = 65.1;
  static const levelLineCy = 70.3;
  static const levelLineSize = 3.3;
  static const goalW = 39.3;
  static const goalH = 34.6;
  static const goalTop = 41.6;
  static const goalPitch = 43.3;
  static const goalGlyphCy = 48.5;
  static const goalGlyphH = 7.5;
  static const goalNumCy = 57.0;
  static const goalNumSize = 4.9;
  static const goalDivY = 62.3;
  static const goalWordCy = 67.5;
  static const goalWordSize = 3.9;
  static const cardDivW = 32.0;
  static const checkD = 6.4;
  static const checkRight = 5.5; // centre from the card's right edge
  static const checkTop = 5.3; // centre from the card's top edge
  static const flameH = 6.4;
  static const flameLeft = 6.6; // centre from the card's left edge
  static const flameCy = 46.7;
  static const keyboardGap = 3.0; // field bottom above the keyboard
}

/// Review aids: `?step=a|b|c` opens that step, `?emblemL=none|green|dark`
/// tries the fills of the emblem in the light theme (owner Q7: examples).
String? onboardingStartStep;
String onboardingEmblemLight = 'green';

const _texts = [
  ('أهلاً بك في رتّل', 'لنتعرّف عليك قبل أن نبدأ'),
  ('ما مستواك في التجويد؟', 'سنقترح عليك البداية المناسبة'),
  ('ما هدفك اليومي؟', 'يمكنك تغييره لاحقاً من الإعدادات'),
];
const _levelLines = [
  'أبدأ من الصفر',
  'أعرف بعض الأحكام',
  'أريد المراجعة والإتقان',
];
const _goalWords = ['خفيف', 'منتظم', 'جاد', 'مكثف'];

/// Screen 30: the first start (name + avatar, level, daily goal), shown after
/// the splash until it is completed (docs/flutter/screens/30-onboarding.md).
/// [edit]: step A alone, prefilled, «حفظ» (opened from the profile 29, Q9).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone, this.edit = false});

  final VoidCallback onDone;
  final bool edit;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final _theme = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    value: AppSettings.light.value ? 1 : 0,
  );
  late final _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();
  final _name = TextEditingController();
  final _focus = FocusNode();
  int _step = 0;
  int _dir = 1; // 1 forward, -1 back (slide direction)
  late int _avatar;
  late int _level;
  late int _goal;

  @override
  void initState() {
    super.initState();
    _name.text = UserProfile.name.value;
    _avatar = UserProfile.avatar.value;
    if (!UserProfile.avatarChoices.contains(_avatar)) {
      _avatar = UserProfile.avatarChoices.first;
    }
    _level = UserProfile.level.value;
    _goal = UserProfile.goalMinutes.value;
    if (!widget.edit) {
      _step = switch (onboardingStartStep) {
        'b' => 1,
        'c' => 2,
        _ => 0,
      };
    }
    _name.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() {}));
    AppSettings.light.addListener(_onTheme);
  }

  void _onTheme() =>
      AppSettings.light.value ? _theme.forward() : _theme.reverse();

  @override
  void dispose() {
    AppSettings.light.removeListener(_onTheme);
    _theme.dispose();
    _entry.dispose();
    _name.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _nameOk => _name.text.trim().isNotEmpty;

  void _go(int step) {
    _focus.unfocus();
    setState(() {
      _dir = step > _step ? 1 : -1;
      _step = step;
    });
  }

  void _next() {
    if (widget.edit) {
      UserProfile.name.value = _name.text.trim();
      UserProfile.avatar.value = _avatar;
      UserProfile.save();
      widget.onDone();
      return;
    }
    if (_step < 2) {
      _go(_step + 1);
      return;
    }
    UserProfile.complete(
      newName: _name.text,
      newAvatar: _avatar,
      newLevel: _level,
      newGoal: _goal,
    );
    Haptics.success();
    widget.onDone();
  }

  void _back() {
    if (widget.edit) {
      widget.onDone();
    } else if (_step > 0) {
      _go(_step - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.edit && _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: RateelColors.readBgEdge,
        body: LayoutBuilder(
          builder: (context, c) {
            final u = c.maxHeight / 100;
            final w = c.maxWidth;
            return AnimatedBuilder(
              animation: _theme,
              builder: (context, _) {
                final p = LessonPal(Curves.easeInOut.transform(_theme.value));
                return _screen(context, p, u, w);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _screen(BuildContext context, LessonPal p, double u, double w) {
    final cx = w / 2;
    // Keyboard (landscape: about half of the phone): the content slides up so
    // the name field stays above it.
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final fieldBottom = u * (OnbMetrics.fieldTop + OnbMetrics.fieldH);
    final lift = _step == 0 && _focus.hasFocus && inset > 0
        ? math.max(
            0.0,
            fieldBottom + u * OnbMetrics.keyboardGap - (u * 100 - inset),
          )
        : 0.0;
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: _Backdrop(p: p, u: u),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(end: lift),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          builder: (context, dy, child) =>
              Transform.translate(offset: Offset(0, -dy), child: child),
          child: AnimatedBuilder(
            animation: _entry,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(_entry.value);
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, u * 2.5 * (1 - t)),
                  child: child,
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  key: const ValueKey('emblem'),
                  left: cx - u * OnbMetrics.emblemW / 2,
                  top: u * OnbMetrics.emblemTop,
                  width: u * OnbMetrics.emblemW,
                  height: u * OnbMetrics.emblemW,
                  child: _Emblem(p: p, u: u),
                ),
                Positioned(
                  key: const ValueKey('divider'),
                  left: cx - u * OnbMetrics.dividerW / 2,
                  top: u * OnbMetrics.dividerTop - u * 2,
                  width: u * OnbMetrics.dividerW,
                  height: u * 4,
                  child: _Divider(p: p, u: u, diamond: 1.8),
                ),
                Positioned.fill(
                  key: const ValueKey('step'),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (current, previous) => Stack(
                      fit: StackFit.expand,
                      children: [...previous, ?current],
                    ),
                    transitionBuilder: (child, a) {
                      final incoming = child.key == ValueKey(_step);
                      // RTL: the next step comes from the left.
                      final dx = u * 10 * _dir * (incoming ? -1 : 1);
                      return AnimatedBuilder(
                        animation: a,
                        builder: (context, child) => Opacity(
                          opacity: a.value,
                          child: Transform.translate(
                            offset: Offset(dx * (1 - a.value), 0),
                            child: child,
                          ),
                        ),
                        child: child,
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _stepContent(p, u, cx, ink),
                    ),
                  ),
                ),
                if (!widget.edit)
                  Positioned(
                    key: const ValueKey('dots'),
                    left: 0,
                    right: 0,
                    top: u * (OnbMetrics.dotsCy - OnbMetrics.dotH / 2),
                    height: u * OnbMetrics.dotH,
                    child: _Dots(p: p, u: u, step: _step),
                  ),
                Positioned(
                  key: const ValueKey('button'),
                  left: u * OnbMetrics.btnLeft,
                  top: u * (OnbMetrics.dotsCy - OnbMetrics.btnH / 2),
                  height: u * OnbMetrics.btnH,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width:
                        u *
                        (_step == 2 && !widget.edit
                            ? OnbMetrics.btnWideW
                            : OnbMetrics.btnW),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _step > 0 || _nameOk ? 1 : 0.45,
                      child: LessonButton(
                        u: u,
                        p: p,
                        label: widget.edit
                            ? 'حفظ'
                            : (_step == 2 ? 'ابدأ التعلّم' : 'التالي'),
                        glyph: widget.edit
                            ? LessonBtnGlyph.check
                            : LessonBtnGlyph.chevron,
                        enabled: _step > 0 || _nameOk,
                        height: OnbMetrics.btnH,
                        fontSize: OnbMetrics.btnText,
                        onTap: _next,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  key: const ValueKey('back'),
                  right: u * OnbMetrics.backRight,
                  top: u * (OnbMetrics.dotsCy - OnbMetrics.backD / 2),
                  width: u * OnbMetrics.backD,
                  height: u * OnbMetrics.backD,
                  child: IgnorePointer(
                    ignoring: !(widget.edit || _step > 0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: widget.edit || _step > 0 ? 1 : 0,
                      child: LessonRoundButton(
                        u: u,
                        label: 'رجوع',
                        glyph: PillGlyph.previous,
                        light: p.t,
                        onTap: _back,
                        child: Image.asset(
                          'assets/ui/icons_white/chevron_right.webp',
                          width: u * 3.6,
                          height: u * 3.6,
                          color: p.c(
                            RateelColors.iconCream,
                            RateelColors.readLInk,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  key: const ValueKey('moon'),
                  left: u * (OnbMetrics.moonCx - OnbMetrics.moonD / 2),
                  top: u * (OnbMetrics.moonCy - OnbMetrics.moonD / 2),
                  width: u * OnbMetrics.moonD,
                  height: u * OnbMetrics.moonD,
                  child: LessonRoundButton(
                    u: u,
                    label: p.t > 0.5 ? 'الوضع المظلم' : 'الوضع الفاتح',
                    compact: true,
                    glyph: PillGlyph.play,
                    light: p.t,
                    onTap: () =>
                        AppSettings.light.value = !AppSettings.light.value,
                    child: SizedBox(
                      width: u * 4.4,
                      height: u * 4.4,
                      child: CustomPaint(
                        painter: MoonPainter(
                          p.c(RateelColors.leaderText, RateelColors.readLInk),
                        ),
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
  }

  /// Title, subtitle and the card(s) of the current step (they slide).
  Widget _stepContent(LessonPal p, double u, double cx, Color ink) {
    final (title, subtitle) = _texts[_step];
    return Stack(
      fit: StackFit.expand,
      children: [
        _centredText(
          u,
          cx,
          OnbMetrics.titleCy,
          title,
          readex(
            u * OnbMetrics.titleSize,
            weight: 600,
            color: p.c(titleCream, RateelColors.readLTitle),
          ).copyWith(shadows: p.t > 0.5 ? null : titleShadows(u)),
        ),
        _centredText(
          u,
          cx,
          OnbMetrics.subtitleCy,
          subtitle,
          readex(u * OnbMetrics.subtitleSize, weight: 340, color: ink),
        ),
        ...switch (_step) {
          0 => _stepA(p, u, cx, ink),
          1 => _stepB(p, u, cx, ink),
          _ => _stepC(p, u, cx, ink),
        },
      ],
    );
  }

  List<Widget> _stepA(LessonPal p, double u, double cx, Color ink) {
    final left = cx - u * OnbMetrics.cardW / 2;
    final right = cx + u * OnbMetrics.cardW / 2;
    final labelStyle = readex(
      u * OnbMetrics.labelSize,
      weight: 600,
      color: p.c(RateelColors.leaderText, RateelColors.readLInk),
    );
    Widget label(double cy, String text) => Positioned(
      right: (cx * 2) - right + u * OnbMetrics.labelRight,
      top: u * (cy - 3),
      height: u * 6,
      child: Center(
        child: Text(text, textDirection: TextDirection.rtl, style: labelStyle),
      ),
    );
    final focused = _focus.hasFocus;
    return [
      Positioned(
        left: left,
        top: u * OnbMetrics.cardTop,
        width: u * OnbMetrics.cardW,
        height: u * OnbMetrics.cardH,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: GoldCardPainter(
              p,
              u,
              u * OnbMetrics.cardRadius,
              fill: const [
                RateelColors.testCardTop,
                RateelColors.testCardMid,
                RateelColors.testCardBottom,
              ],
            ),
            child: _Band(p: p, u: u, radius: u * OnbMetrics.cardRadius),
          ),
        ),
      ),
      label(OnbMetrics.label1Cy, 'ما اسمك؟'),
      Positioned(
        left: left + u * OnbMetrics.fieldInset,
        right: (cx * 2) - right + u * OnbMetrics.fieldInset,
        top: u * OnbMetrics.fieldTop,
        height: u * OnbMetrics.fieldH,
        child: _Field(
          p: p,
          u: u,
          focused: focused,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: u * OnbMetrics.fieldTextRight,
            ),
            // Readex sets Arabic low in its line box: lift it optically.
            child: Transform.translate(
              offset: Offset(0, -u * 0.45),
              child: Center(
                child: TextField(
                  controller: _name,
                  focusNode: _focus,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  textInputAction: TextInputAction.done,
                  cursorColor: p.c(
                    RateelColors.testSelRim,
                    RateelColors.testLSelRim,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(UserProfile.maxName),
                  ],
                  onSubmitted: (_) => _focus.unfocus(),
                  style: readex(
                    u * OnbMetrics.fieldTextSize,
                    weight: 500,
                    color: ink,
                  ).copyWith(height: 1.3),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'اكتب اسمك',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: readex(
                      u * OnbMetrics.fieldTextSize,
                      weight: 340,
                      color: ink.withValues(alpha: 0.6),
                    ).copyWith(height: 1.3),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: left + u * OnbMetrics.sepInset,
        right: (cx * 2) - right + u * OnbMetrics.sepInset,
        top: u * OnbMetrics.sepY,
        height: math.max(1.0, u * 0.12),
        child: ColoredBox(
          color: p
              .c(RateelColors.testRowRimBottom, RateelColors.readLSeparator)
              .withValues(alpha: p.d(0.6, 1)),
        ),
      ),
      label(OnbMetrics.label2Cy, 'اختر صورتك'),
      for (var i = 0; i < UserProfile.avatarChoices.length; i++)
        Positioned(
          left:
              right -
              u *
                  (OnbMetrics.avatarFirstRight +
                      OnbMetrics.avatarPitch * i +
                      OnbMetrics.avatarD / 2),
          top: u * (OnbMetrics.avatarCy - OnbMetrics.avatarD / 2),
          width: u * OnbMetrics.avatarD,
          height: u * OnbMetrics.avatarD,
          child: _Avatar(
            p: p,
            u: u,
            number: UserProfile.avatarChoices[i],
            selected: UserProfile.avatarChoices[i] == _avatar,
            onTap: () {
              Haptics.tick();
              setState(() => _avatar = UserProfile.avatarChoices[i]);
            },
          ),
        ),
    ];
  }

  List<Widget> _stepB(LessonPal p, double u, double cx, Color ink) {
    final glyphs = <Widget Function(Color)>[
      (c) => Image.asset('assets/ui/icons_white/open_book.webp', color: c),
      (c) => SvgPicture.asset(
        'assets/ui/glyphs/star.svg',
        colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
      ),
      // The library's rosette keeps its gold (owner Q5: use what we have).
      (_) => Image.asset('assets/ui/glyphs/rank_rosette.webp'),
    ];
    return [
      for (var i = 0; i < 3; i++)
        Positioned(
          // Right → left: مبتدئ، متوسط، متقدم.
          left:
              cx +
              u * (OnbMetrics.levelPitch * (1 - i) - OnbMetrics.levelW / 2),
          top: u * OnbMetrics.levelTop,
          width: u * OnbMetrics.levelW,
          height: u * OnbMetrics.levelH,
          child: _OptionCard(
            p: p,
            u: u,
            selected: _level == i,
            onTap: () {
              Haptics.tick();
              setState(() => _level = i);
            },
            child: _cardBody(
              p,
              u,
              top: OnbMetrics.levelTop,
              glyph: glyphs[i](
                p.c(RateelColors.iconCream, RateelColors.readLInk),
              ),
              glyphCy: OnbMetrics.levelGlyphCy,
              glyphH: OnbMetrics.levelGlyphH,
              big: UserProfile.levels[i],
              bigCy: OnbMetrics.levelNameCy,
              bigSize: OnbMetrics.levelNameSize,
              divY: OnbMetrics.levelDivY,
              small: _levelLines[i],
              smallCy: OnbMetrics.levelLineCy,
              smallSize: OnbMetrics.levelLineSize,
              ink: ink,
            ),
          ),
        ),
    ];
  }

  List<Widget> _stepC(LessonPal p, double u, double cx, Color ink) {
    const offsets = [1.5, 0.5, -0.5, -1.5]; // right → left
    return [
      for (var i = 0; i < 4; i++)
        Positioned(
          left:
              cx +
              u * (OnbMetrics.goalPitch * offsets[i] - OnbMetrics.goalW / 2),
          top: u * OnbMetrics.goalTop,
          width: u * OnbMetrics.goalW,
          height: u * OnbMetrics.goalH,
          child: _OptionCard(
            p: p,
            u: u,
            selected: _goal == UserProfile.goals[i],
            flame: true,
            onTap: () {
              Haptics.tick();
              setState(() => _goal = UserProfile.goals[i]);
            },
            child: _cardBody(
              p,
              u,
              top: OnbMetrics.goalTop,
              glyph: Image.asset(
                'assets/ui/icons_white/stopwatch.webp',
                color: p.c(RateelColors.iconCream, RateelColors.readLInk),
              ),
              glyphCy: OnbMetrics.goalGlyphCy,
              glyphH: OnbMetrics.goalGlyphH,
              big: UserProfile.goalLabel(UserProfile.goals[i]),
              bigCy: OnbMetrics.goalNumCy,
              bigSize: OnbMetrics.goalNumSize,
              divY: OnbMetrics.goalDivY,
              small: _goalWords[i],
              smallCy: OnbMetrics.goalWordCy,
              smallSize: OnbMetrics.goalWordSize,
              ink: ink,
            ),
          ),
        ),
    ];
  }

  /// Glyph, big text, small divider and the small line of an option card
  /// (y in absolute u, converted to the card).
  Widget _cardBody(
    LessonPal p,
    double u, {
    required double top,
    required Widget glyph,
    required double glyphCy,
    required double glyphH,
    required String big,
    required double bigCy,
    required double bigSize,
    required double divY,
    required String small,
    required double smallCy,
    required double smallSize,
    required Color ink,
  }) {
    Widget line(double cy, String text, TextStyle style) => Positioned(
      left: 0,
      right: 0,
      top: u * (cy - top) - u * 4,
      height: u * 8,
      child: Center(
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          style: style.copyWith(height: 1.2),
        ),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: u * (glyphCy - top - glyphH / 2),
          height: u * glyphH,
          child: Center(child: glyph),
        ),
        line(
          bigCy,
          big,
          readex(
            u * bigSize,
            weight: 600,
            color: p.c(RateelColors.leaderText, RateelColors.readLInk),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: u * (divY - top) - u * 1.5,
          height: u * 3,
          child: Center(
            child: SizedBox(
              width: u * OnbMetrics.cardDivW,
              height: u * 3,
              child: _Divider(p: p, u: u * 0.6, diamond: 1.6),
            ),
          ),
        ),
        line(smallCy, small, readex(u * smallSize, weight: 340, color: ink)),
      ],
    );
  }

  Widget _centredText(
    double u,
    double cx,
    double cy,
    String text,
    TextStyle style,
  ) => Positioned(
    left: 0,
    right: 0,
    top: u * cy - u * 6,
    height: u * 12,
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        maxLines: 1,
        style: style.copyWith(height: 1.2),
      ),
    ),
  );
}

/// Background: the lesson background (gradient + lattice corners, both
/// themes), the big thin arc, the waves at the bottom and the mosque with its
/// glow on the bottom right.
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.p, required this.u});

  final LessonPal p;
  final double u;

  @override
  Widget build(BuildContext context) {
    final mosqueH = u * OnbMetrics.mosqueW * 542 / 900;
    return Stack(
      fit: StackFit.expand,
      children: [
        LessonBackground(p: p, u: u),
        CustomPaint(painter: _ArcPainter(p, u)),
        Positioned(
          right: u * OnbMetrics.mosqueRight,
          top: u * OnbMetrics.mosqueBottom - mosqueH,
          width: u * OnbMetrics.mosqueW,
          height: mosqueH,
          child: Opacity(
            opacity: p.d(0.75, 0.9),
            child: p.t > 0.5
                ? Image.asset(
                    'assets/ui/decor/mosque_light.webp',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  )
                : ColorFiltered(
                    colorFilter: lessonMosqueTone,
                    child: Image.asset('assets/ui/decor/mosque.webp'),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.p, this.u);

  final LessonPal p;
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Glow behind the mosque (bottom right).
    final glowC = Offset(w - u * 24, u * 76);
    canvas.drawCircle(
      glowC,
      u * 30,
      Paint()
        ..shader = RadialGradient(
          colors: [
            p.c(const Color(0x3D2FA36B), const Color(0x00FFFFFF)),
            p.c(const Color(0x002FA36B), const Color(0x00FFFFFF)),
          ],
        ).createShader(Rect.fromCircle(center: glowC, radius: u * 30)),
    );
    // Big thin arc: an ellipse wider than the screen (reference: from the
    // left edge at ≈ 31u, over the top at ≈ 41u and 175u, to the right edge).
    final gold = p.c(RateelColors.videoDivider, RateelColors.readLCopper);
    final arc = Rect.fromCenter(
      center: Offset(w / 2, u * 72.7),
      width: u * 246.2 * (w / (u * 216.2)),
      height: u * 173.2,
    );
    canvas.drawOval(
      arc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, u * 0.24)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gold.withValues(alpha: p.d(0.75, 0.6)),
            gold.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.42],
        ).createShader(arc),
    );
    // Bottom waves: a lighter band under a pale green line and a thin gold
    // line (reference: from the left at ≈ 76u, lowest near the centre).
    final band = Path()
      ..moveTo(0, u * 76)
      ..cubicTo(w * 0.22, u * 88, w * 0.45, u * 99, w * 0.62, u * 96)
      ..cubicTo(w * 0.78, u * 93, w * 0.9, u * 86, w, u * 84)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      band,
      Paint()..color = p.c(const Color(0x1446A877), const Color(0x0FB08A5A)),
    );
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, u * 0.2);
    canvas.drawPath(
      Path()
        ..moveTo(0, u * 76)
        ..cubicTo(w * 0.22, u * 88, w * 0.45, u * 99, w * 0.62, u * 96)
        ..cubicTo(w * 0.78, u * 93, w * 0.9, u * 86, w, u * 84),
      line
        ..color = p
            .c(RateelColors.testRowRimTop, RateelColors.readLCardRimSide)
            .withValues(alpha: p.d(0.45, 0.5)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, u * 86)
        ..cubicTo(w * 0.25, u * 96, w * 0.5, u * 103, w * 0.7, u * 98)
        ..cubicTo(w * 0.85, u * 94, w * 0.94, u * 89, w, u * 87),
      line..color = gold.withValues(alpha: p.d(0.5, 0.45)),
    );
  }

  @override
  bool shouldRepaint(_ArcPainter o) => o.p.t != p.t || o.u != u;
}

/// The app emblem of the splash with a soft gold glow. Light theme: its
/// transparent centre is filled (owner Q7: examples via `?emblemL=`).
class _Emblem extends StatelessWidget {
  const _Emblem({required this.p, required this.u});

  final LessonPal p;
  final double u;

  @override
  Widget build(BuildContext context) {
    final fill = switch (onboardingEmblemLight) {
      'none' => null,
      'dark' => RateelColors.readBgCentre,
      _ => const Color(0xFF0B5A2B), // sampled on the light reference
    };
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Positioned(
          left: -u * 4,
          right: -u * 4,
          top: -u * 4,
          bottom: -u * 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  RateelColors.goldRim.withValues(alpha: p.d(0.22, 0.12)),
                  RateelColors.goldRim.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        if (fill != null && p.t > 0)
          Opacity(
            opacity: p.t,
            child: Image.asset(
              'assets/ui/splash/emblem_inner.webp',
              fit: BoxFit.contain,
              color: fill,
            ),
          ),
        Image.asset('assets/ui/splash/emblem.webp', fit: BoxFit.contain),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.p, required this.u, required this.diamond});

  final LessonPal p;
  final double u;
  final double diamond;

  @override
  Widget build(BuildContext context) => p.t > 0
      ? ColorFiltered(
          colorFilter: ColorFilter.mode(
            p.c(RateelColors.videoDivider, RateelColors.readLCopper),
            BlendMode.srcIn,
          ),
          child: GoldDivider(u: u, diamond: diamond),
        )
      : GoldDivider(u: u, diamond: diamond);
}

/// Faded lattice band at the bottom of a card (owner Q6: on every card).
class _Band extends StatelessWidget {
  const _Band({required this.p, required this.u, required this.radius});

  final LessonPal p;
  final double u;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: u * OnbMetrics.bandH,
        width: double.infinity,
        child: LatticeField(
          p: p,
          u: u,
          cell: 3.2,
          opacity: p.d(0.32, 0.55),
          alignment: Alignment.bottomCenter,
          mask: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xFF000000), Color(0x00000000)],
          ),
        ),
      ),
    ),
  );
}

/// Name field: pill with the option-row rim of 10 (selected rim on focus).
class _Field extends StatelessWidget {
  const _Field({
    required this.p,
    required this.u,
    required this.focused,
    required this.child,
  });

  final LessonPal p;
  final double u;
  final bool focused;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final h = u * OnbMetrics.fieldH;
    final rimTop = focused
        ? p.c(RateelColors.testSelRim, RateelColors.testLSelRim)
        : p.c(RateelColors.testRowRimTop, RateelColors.testLRowRim);
    final rimBottom = focused
        ? rimTop
        : p.c(RateelColors.testRowRimBottom, RateelColors.testLRowRim);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(h),
        color: p.c(RateelColors.testRowFill, RateelColors.testLRowFill),
        boxShadow: [
          BoxShadow(
            color: RateelColors.testSelRim.withValues(
              alpha: focused ? 0.22 * (1 - p.t) : 0,
            ),
            blurRadius: u * 1.4,
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: GradientRimPainter(
          width: math.max(1.0, u * 0.3),
          radius: h,
          top: rimTop,
          bottom: rimBottom,
        ),
        child: child,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.p,
    required this.u,
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final LessonPal p;
  final double u;
  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = p.c(RateelColors.testSelRim, RateelColors.testLSelRim);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(u * (selected ? 0.5 : 0.25)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? gold
                : p.c(RateelColors.testRowRimTop, RateelColors.testLRowRim),
            boxShadow: [
              BoxShadow(
                color: gold.withValues(alpha: selected ? p.d(0.5, 0.35) : 0),
                blurRadius: u * 1.8,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/ui/leaderboard/avatar_$number.webp',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

/// Level / goal card: option row of 10 (idle) or selected row (gold rim,
/// glow), check disc in the top right corner, flame on the selected goal.
class _OptionCard extends StatefulWidget {
  const _OptionCard({
    required this.p,
    required this.u,
    required this.selected,
    required this.onTap,
    required this.child,
    this.flame = false,
  });

  final LessonPal p;
  final double u;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final bool flame;

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final u = widget.u;
    final s = widget.selected;
    final r = u * OnbMetrics.optRadius;
    final top = s
        ? p.c(RateelColors.testSelTop, RateelColors.testLSelTop)
        : p.c(RateelColors.testRowFill, RateelColors.testLRowFill);
    final bottom = s
        ? p.c(RateelColors.testSelBottom, RateelColors.testLSelBottom)
        : p.c(RateelColors.testRowFill, RateelColors.testLRowFill);
    final rimTop = s
        ? p.c(RateelColors.testSelRim, RateelColors.testLSelRim)
        : p.c(RateelColors.testRowRimTop, RateelColors.testLRowRim);
    final rimBottom = s
        ? rimTop
        : p.c(RateelColors.testRowRimBottom, RateelColors.testLRowRim);
    return Semantics(
      button: true,
      selected: s,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [top, bottom],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RateelColors.testSelRim.withValues(
                        alpha: s ? 0.28 * (1 - p.t) : 0,
                      ),
                      blurRadius: u * 1.6,
                    ),
                    BoxShadow(
                      color: p
                          .c(Colors.black, const Color(0xFF8A6A4A))
                          .withValues(alpha: p.d(0.3, 0.12)),
                      blurRadius: u * 0.6,
                      offset: Offset(0, u * 0.35),
                    ),
                  ],
                ),
                child: CustomPaint(
                  foregroundPainter: GradientRimPainter(
                    width: math.max(1.0, u * 0.3),
                    radius: r,
                    top: rimTop,
                    bottom: rimBottom,
                  ),
                  child: _Band(p: p, u: u, radius: r),
                ),
              ),
              widget.child,
              Positioned(
                right: u * (OnbMetrics.checkRight - OnbMetrics.checkD / 2),
                top: u * (OnbMetrics.checkTop - OnbMetrics.checkD / 2),
                width: u * OnbMetrics.checkD,
                height: u * OnbMetrics.checkD,
                child: _Pop(
                  on: s,
                  child: _CheckDisc(p: p, u: u),
                ),
              ),
              if (widget.flame)
                Positioned(
                  left: u * (OnbMetrics.flameLeft - OnbMetrics.flameH / 2),
                  top:
                      u *
                      (OnbMetrics.flameCy -
                          OnbMetrics.goalTop -
                          OnbMetrics.flameH / 2),
                  width: u * OnbMetrics.flameH,
                  height: u * OnbMetrics.flameH,
                  child: _Pop(
                    on: s,
                    child: Image.asset('assets/ui/icons/flame_gold_01.webp'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scale + fade in when [on] (check disc, flame).
class _Pop extends StatelessWidget {
  const _Pop({required this.on, required this.child});

  final bool on;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: on ? 1 : 0),
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOutBack,
    builder: (context, v, child) => Opacity(
      opacity: v.clamp(0, 1),
      child: Transform.scale(scale: 0.6 + 0.4 * v, child: child),
    ),
    child: child,
  );
}

class _CheckDisc extends StatelessWidget {
  const _CheckDisc({required this.p, required this.u});

  final LessonPal p;
  final double u;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          p.c(RateelColors.testSelTop, RateelColors.testLGoldTop),
          p.c(RateelColors.testSelBottom, RateelColors.testLGoldBottom),
        ],
      ),
      border: Border.all(
        color: p.c(RateelColors.testSelRim, RateelColors.testLGoldBottom),
        width: math.max(1.0, u * 0.3),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(u * 1.5),
      child: Image.asset(
        'assets/ui/icons_white/checkmark.webp',
        color: p.c(RateelColors.iconCream, Colors.white),
      ),
    ),
  );
}

/// Step dots: the current one gold and longer (RTL: step 1 on the right).
class _Dots extends StatelessWidget {
  const _Dots({required this.p, required this.u, required this.step});

  final LessonPal p;
  final double u;
  final int step;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    textDirection: TextDirection.rtl,
    children: [
      for (var i = 0; i < 3; i++) ...[
        if (i > 0) SizedBox(width: u * OnbMetrics.dotGap),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: u * (i == step ? OnbMetrics.dotOnW : OnbMetrics.dotW),
          height: u * OnbMetrics.dotH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(u),
            color: i == step
                ? p.c(RateelColors.amberPill, RateelColors.testLSelRim)
                : p.c(RateelColors.cardRimTop, RateelColors.readLDotOff),
          ),
        ),
      ],
    ],
  );
}
