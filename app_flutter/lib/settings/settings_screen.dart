import 'package:material_ui/material_ui.dart';

import '../core/app_settings.dart';
import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../theme/rateel_theme.dart';

/// Screen 23, settings (reference `23-impostazioni.webp`, 1844×853; plan
/// docs/flutter/screens/23-settings.md).
///
/// Owner changes to the reference (2026-11-25): the list fills the whole
/// content width (no left column), «عن التطبيق» and «إعادة ضبط التقدم» are rows
/// of the list. The list scrolls inside the card (8 rows, about 6 visible).
///
/// Sizes in u = height / 100 (u = 8.53 px on the reference).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

const _bg = 'assets/ui/coming_soon/background.webp';
const _badgeFill = 'assets/ui/reading/badge_fill.webp';
const _badgeLine = 'assets/ui/reading/badge_line.webp';

/// Row pitch on the reference: 95.5 px.
const _rowH = 11.2;
const _rowCount = 8;

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Animation<double> _interval(double a, double b) => CurvedAnimation(
    parent: _entry,
    curve: Interval(a, b, curve: Curves.easeOutCubic),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final u = box.maxHeight / 100;
        final title = _interval(0, 0.6);
        final card = _interval(0.15, 0.85);
        return Stack(
          children: [
            const Positioned.fill(
              child: RepaintBoundary(
                child: Image(
                  image: AssetImage(_bg),
                  fit: BoxFit.fill,
                  color: RateelColors.soonBgTone,
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
            // Title «الإعدادات»: glyphs y 25–78 px, centred on the content.
            Positioned(
              left: 0,
              right: 0,
              top: u * 1.6,
              child: _Rise(
                animation: title,
                u: u,
                child: Text(
                  'الإعدادات',
                  textAlign: TextAlign.center,
                  style: cairo(
                    u * 6.6,
                    weight: 700,
                    color: RateelColors.soonTitle,
                  ).copyWith(height: 1.2),
                ),
              ),
            ),
            // Gold divider with the diamond, 700 px wide at y 108.
            Positioned(
              left: w / 2 - u * 41,
              width: u * 82,
              top: u * 10.4,
              height: u * 4.6,
              child: _Rise(
                animation: title,
                u: u,
                child: GoldDivider(u: u * 1.15),
              ),
            ),
            Positioned(
              left: u * 5,
              right: u * 5,
              top: u * 17.0,
              bottom: u * 10.4,
              child: _Rise(
                animation: card,
                u: u,
                child: _Card(u: u),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Rise extends StatelessWidget {
  const _Rise({required this.animation, required this.u, required this.child});

  final Animation<double> animation;
  final double u;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: RepaintBoundary(child: child),
    builder: (context, child) => Opacity(
      opacity: animation.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, u * 3.5 * (1 - animation.value)),
        child: child,
      ),
    ),
  );
}

/// Glass card with the bright gold rim (3 px pale gold, soft glow) and the
/// scrolling rows.
class _Card extends StatelessWidget {
  const _Card({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) {
    final r = u * 3.6;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            color: RateelColors.setRimGlow.withValues(alpha: 0.35),
            blurRadius: u * 1.6,
          ),
          BoxShadow(
            color: const Color(0x59000000),
            offset: Offset(0, u * 0.6),
            blurRadius: u * 1.6,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(u * 0.38),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [RateelColors.setRimTop, RateelColors.setRimSide],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r - u * 0.38),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.28, 1],
                colors: [
                  RateelColors.setCardTop,
                  RateelColors.setCardMid,
                  RateelColors.setCardBottom,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ListView.builder(
                    // First row band 148–268 px on the reference: 2.4u above the rows.
                    padding: EdgeInsets.fromLTRB(u, u * 2.4, u, u * 2.4),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _rowCount,
                    itemExtent: u * _rowH,
                    itemBuilder: (context, i) => RepaintBoundary(
                      child: _Row(index: i, u: u, last: i == _rowCount - 1),
                    ),
                  ),
                ),
                // Hint that the list goes on: the card colour fades the last
                // visible row.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: u * 4,
                  child: const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            RateelColors.setCardBottom,
                            Color(0x00002E1E),
                          ],
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
    );
  }
}

/// One row: lobed badge with the glyph and the label on the right, the
/// control on the left, a thin light line under it.
class _Row extends StatelessWidget {
  const _Row({required this.index, required this.u, required this.last});

  final int index;
  final double u;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final (glyph, label, control) = switch (index) {
      0 => (_icon(Icons.nightlight_round, 0.9), 'المظهر', _ThemeSwitch(u: u)),
      1 => (
        Text(
          'A',
          style: readex(
            u * 4.6,
            weight: 600,
            color: RateelColors.iconCream,
          ).copyWith(height: 1),
        ),
        'حجم الخط',
        _TextSize(u: u),
      ),
      2 => (
        _icon(Icons.volume_up_rounded, 1),
        'المؤثرات الصوتية',
        _Toggle(u: u, value: AppSettings.sounds),
      ),
      3 => (
        _icon(Icons.vibration_rounded, 1),
        'الاهتزاز',
        _Toggle(u: u, value: AppSettings.haptics),
      ),
      4 => (_icon(Icons.mic_rounded, 1), 'القارئ', _Reciter(u: u)),
      5 => (
        _icon(Icons.notifications_rounded, 1),
        'تذكير يومي',
        _Reminder(u: u),
      ),
      6 => (_icon(Icons.info_outline_rounded, 1), 'عن التطبيق', _Chevron(u: u)),
      _ => (
        _icon(Icons.restart_alt_rounded, 1),
        'إعادة ضبط التقدم',
        _ResetButton(u: u),
      ),
    };
    final tap = switch (index) {
      6 => () => _showAbout(context, u),
      7 => () => _confirmReset(context, u),
      _ => null,
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: tap,
      child: Stack(
        children: [
          Positioned(
            right: u * 3.6,
            top: (u * _rowH - u * 10) / 2,
            width: u * 9.8,
            height: u * 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Image(image: AssetImage(_badgeFill)),
                const Image(image: AssetImage(_badgeLine)),
                Center(child: glyph),
              ],
            ),
          ),
          Positioned(
            right: u * 17.0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                label,
                textDirection: TextDirection.rtl,
                style: cairo(
                  u * 4.4,
                  weight: 700,
                  color: RateelColors.setLabel,
                ).copyWith(height: 1.2),
              ),
            ),
          ),
          Positioned(
            left: u * 4.3,
            top: 0,
            bottom: 0,
            child: Center(child: control),
          ),
          if (!last)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: RateelColors.setLine, width: 1),
                    bottom: BorderSide(
                      color: RateelColors.setLineDark,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, double scale) =>
      Icon(icon, size: u * 5.0 * scale, color: RateelColors.iconCream);
}

/// Dark glass pill with a thin pale-gold rim (reciter, time, value).
BoxDecoration _pill(double u, {Color rim = RateelColors.setPillRim}) =>
    BoxDecoration(
      borderRadius: BorderRadius.circular(u * 4),
      color: RateelColors.setPillFill,
      border: Border.all(color: rim, width: u * 0.2),
    );

/// «داكن | فاتح»: gold thumb slides to the chosen half (RTL: dark on the right).
class _ThemeSwitch extends StatelessWidget {
  const _ThemeSwitch({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) {
    final w = u * 46;
    final h = u * 7.3;
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.light,
      builder: (context, light, _) => SizedBox(
        width: w,
        height: h,
        child: Stack(
          children: [
            Positioned.fill(child: DecoratedBox(decoration: _pill(u))),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOutCubic,
              left: light ? 0 : w / 2,
              width: w / 2,
              top: 0,
              bottom: 0,
              child: const _GoldFill(),
            ),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                for (final (label, isLight) in [
                  ('داكن', false),
                  ('فاتح', true),
                ])
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (light == isLight) return;
                        Haptics.tick();
                        AppSettings.light.value = isLight;
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 260),
                          style: cairo(
                            u * 3.7,
                            weight: 700,
                            color: light == isLight
                                ? RateelColors.countText
                                : RateelColors.setLabel,
                          ),
                          child: Text(label),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold fill of the selected segment and of the switches (#FDC146 → #E8A51F).
class _GoldFill extends StatelessWidget {
  const _GoldFill();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(box.maxHeight / 2),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RateelColors.setGoldTop, RateelColors.setGoldBottom],
        ),
        boxShadow: [
          BoxShadow(
            color: RateelColors.gold.withValues(alpha: 0.3),
            blurRadius: box.maxHeight * 0.25,
          ),
        ],
      ),
    ),
  );
}

/// «+  100%  −» (RTL as the reference: − on the right, + on the left).
class _TextSize extends StatelessWidget {
  const _TextSize({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: AppSettings.textScale,
      builder: (context, s, _) {
        void step(double d) {
          final next = (s + d).clamp(
            AppSettings.textScaleMin,
            AppSettings.textScaleMax,
          );
          if ((next - s).abs() < 0.001) {
            Haptics.denied();
            return;
          }
          Haptics.tick();
          AppSettings.textScale.value =
              (next / AppSettings.textScaleStep).round() *
              AppSettings.textScaleStep;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            _RoundButton(
              u: u,
              icon: Icons.add_rounded,
              enabled: s < AppSettings.textScaleMax - 0.001,
              onTap: () => step(AppSettings.textScaleStep),
            ),
            SizedBox(width: u * 3),
            Container(
              width: u * 20.5,
              height: u * 7,
              alignment: Alignment.center,
              decoration: _pill(u),
              child: Text(
                '${(s * 100).round()}%',
                textDirection: TextDirection.ltr,
                // The value itself does not scale, so the row never grows.
                textScaler: TextScaler.noScaling,
                style: readex(
                  u * 3.6,
                  weight: 500,
                  color: RateelColors.setLabel,
                ),
              ),
            ),
            SizedBox(width: u * 3),
            _RoundButton(
              u: u,
              icon: Icons.remove_rounded,
              enabled: s > AppSettings.textScaleMin + 0.001,
              onTap: () => step(-AppSettings.textScaleStep),
            ),
          ],
        );
      },
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.u,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final double u;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        width: u * 8.2,
        height: u * 8.2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: RateelColors.setPillFill,
          border: Border.all(color: RateelColors.setPillRim, width: u * 0.2),
        ),
        child: Icon(icon, size: u * 4.8, color: RateelColors.setLabel),
      ),
    ),
  );
}

/// Gold switch, 100×47 px: on = gold track, cream knob on the right.
class _Toggle extends StatelessWidget {
  const _Toggle({required this.u, required this.value});

  final double u;
  final ValueNotifier<bool> value;

  @override
  Widget build(BuildContext context) {
    final w = u * 11.7;
    final h = u * 5.5;
    final k = h - u * 1.0;
    return ValueListenableBuilder<bool>(
      valueListenable: value,
      builder: (context, on, _) => GestureDetector(
        onTap: () {
          value.value = !on;
          // Felt only when switched on (switching vibration off is silent).
          Haptics.tick();
        },
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: on ? 0 : 1,
                  child: DecoratedBox(decoration: _pill(u)),
                ),
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: on ? 1 : 0,
                  child: const _GoldFill(),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOutCubic,
                left: on ? w - k - u * 0.5 : u * 0.5,
                top: u * 0.5,
                width: k,
                height: k,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: on ? RateelColors.setKnob : RateelColors.setKnobOff,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x40000000),
                        offset: Offset(0, u * 0.15),
                        blurRadius: u * 0.4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reciter pill (427–848 px): name, gold chevron on the left; opens the list.
class _Reciter extends StatelessWidget {
  const _Reciter({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: AppSettings.reciter,
    builder: (context, r, _) => GestureDetector(
      onTap: () => _pickReciter(context, u),
      child: Container(
        width: u * 49,
        height: u * 7.5,
        decoration: _pill(u),
        padding: EdgeInsets.symmetric(horizontal: u * 3),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Text(
                AppSettings.reciters[r],
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: cairo(
                  u * 3.5,
                  weight: 600,
                  color: RateelColors.setLabel,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: u * 5.5,
              color: RateelColors.gold,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Reminder: time pill (opens the clock) and its switch.
class _Reminder extends StatelessWidget {
  const _Reminder({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    textDirection: TextDirection.ltr,
    children: [
      ValueListenableBuilder<int>(
        valueListenable: AppSettings.reminderMinutes,
        builder: (context, m, _) => ValueListenableBuilder<bool>(
          valueListenable: AppSettings.reminder,
          builder: (context, on, _) => GestureDetector(
            onTap: () => _pickTime(context),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: on ? 1 : 0.5,
              child: Container(
                width: u * 26,
                height: u * 7,
                alignment: Alignment.center,
                decoration: _pill(u),
                child: Text(
                  formatReminder(m),
                  textDirection: TextDirection.rtl,
                  style: readex(
                    u * 3.6,
                    weight: 500,
                    color: RateelColors.setLabel,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: u * 3.4),
      _Toggle(u: u, value: AppSettings.reminder),
    ],
  );
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.chevron_right_rounded, size: u * 7, color: RateelColors.gold);
}

/// «إعادة الضبط»: the reference's muted-red pill (2–3 px #E17A6F rim).
class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.u});

  final double u;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _confirmReset(context, u),
    child: Container(
      height: u * 7,
      padding: EdgeInsets.symmetric(horizontal: u * 4),
      alignment: Alignment.center,
      decoration: _pill(u, rim: RateelColors.setDanger),
      child: Text(
        'إعادة الضبط',
        style: cairo(u * 3.5, weight: 700, color: RateelColors.setLabel),
      ),
    ),
  );
}

// Dialogs: veil without blur (PERFORMANCE.md), glass card with the gold rim.

Future<T?> _dialog<T>(
  BuildContext context, {
  required double u,
  required double width,
  required Widget Function(BuildContext) builder,
}) {
  Haptics.tap();
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'إغلاق',
    barrierColor: RateelColors.lessonVeil,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: SizedBox(
          width: width,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: EdgeInsets.all(u * 0.3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(u * 3.6),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [RateelColors.setRimTop, RateelColors.setRimSide],
                ),
                boxShadow: [
                  BoxShadow(
                    color: RateelColors.setRimGlow.withValues(alpha: 0.3),
                    blurRadius: u * 2,
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(u * 4, u * 3.5, u * 4, u * 3.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(u * 3.3),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.4, 1],
                    colors: [
                      RateelColors.setCardTop,
                      RateelColors.setCardMid,
                      RateelColors.setCardBottom,
                    ],
                  ),
                ),
                child: builder(context),
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, a, _, child) {
      final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: c,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(c),
          child: child,
        ),
      );
    },
  );
}

Widget _dialogTitle(double u, String text) => Text(
  text,
  textAlign: TextAlign.center,
  style: cairo(u * 5, weight: 700, color: RateelColors.soonTitle),
);

/// Pill button of the dialogs: gold (main) or glass with a rim.
Widget _dialogButton(
  double u,
  String label, {
  required VoidCallback onTap,
  bool gold = false,
  Color rim = RateelColors.setPillRim,
}) => GestureDetector(
  onTap: onTap,
  child: SizedBox(
    height: u * 7.5,
    child: Stack(
      children: [
        Positioned.fill(
          child: gold
              ? const _GoldFill()
              : DecoratedBox(decoration: _pill(u, rim: rim)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: u * 5),
          child: Center(
            widthFactor: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: cairo(
                  u * 3.6,
                  weight: 700,
                  color: gold ? RateelColors.countText : RateelColors.setLabel,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);

void _pickReciter(BuildContext context, double u) {
  _dialog<void>(
    context,
    u: u,
    width: u * 70,
    builder: (context) => ValueListenableBuilder<int>(
      valueListenable: AppSettings.reciter,
      builder: (context, current, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _dialogTitle(u, 'القارئ'),
          SizedBox(height: u * 1.5),
          SizedBox(
            height: u * 3,
            child: GoldDivider(u: u * 0.8),
          ),
          SizedBox(height: u * 2),
          for (var i = 0; i < AppSettings.reciters.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : u * 1.6),
              child: _dialogButton(
                u,
                AppSettings.reciters[i],
                gold: i == current,
                onTap: () {
                  Haptics.tick();
                  AppSettings.reciter.value = i;
                  Navigator.of(context).pop();
                },
              ),
            ),
        ],
      ),
    ),
  );
}

Future<void> _pickTime(BuildContext context) async {
  Haptics.tap();
  final m = AppSettings.reminderMinutes.value;
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
    helpText: 'وقت التذكير',
    cancelText: 'إلغاء',
    confirmText: 'حفظ',
    builder: (context, child) => Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: RateelColors.gold,
          onPrimary: RateelColors.countText,
          surface: RateelColors.setCardMid,
          onSurface: RateelColors.setLabel,
        ),
      ),
      child: Directionality(textDirection: TextDirection.rtl, child: child!),
    ),
  );
  if (picked == null) return;
  AppSettings.reminderMinutes.value = picked.hour * 60 + picked.minute;
  AppSettings.reminder.value = true;
}

void _showAbout(BuildContext context, double u) {
  const version = String.fromEnvironment('RATEEL_VERSION', defaultValue: '1.0');
  _dialog<void>(
    context,
    u: u,
    width: u * 80,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dialogTitle(u, 'رتّل'),
        SizedBox(height: u * 1.5),
        SizedBox(
          height: u * 3,
          width: u * 40,
          child: GoldDivider(u: u * 0.8),
        ),
        SizedBox(height: u * 2.5),
        Text(
          'تطبيق لتعلّم أحكام التجويد خطوة بخطوة:\nدروس مرئية ومقروءة، تدريب على التلاوة، واختبارات.',
          textAlign: TextAlign.center,
          style: cairo(
            u * 3.5,
            weight: 400,
            color: RateelColors.soonText,
          ).copyWith(height: 1.5),
        ),
        SizedBox(height: u * 2),
        Text(
          'الإصدار $version',
          textDirection: TextDirection.rtl,
          style: readex(u * 3, weight: 400, color: RateelColors.setMuted),
        ),
        SizedBox(height: u * 3),
        _dialogButton(
          u,
          'حسنًا',
          gold: true,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

void _confirmReset(BuildContext context, double u) {
  _dialog<void>(
    context,
    u: u,
    width: u * 80,
    builder: (dialog) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dialogTitle(u, 'إعادة ضبط التقدم'),
        SizedBox(height: u * 1.5),
        SizedBox(
          height: u * 3,
          width: u * 40,
          child: GoldDivider(u: u * 0.8),
        ),
        SizedBox(height: u * 2.5),
        Text(
          'سيعود تقدمك في كل الدورات والوحدات والدروس إلى البداية.\nلا يمكن التراجع عن ذلك.',
          textAlign: TextAlign.center,
          style: cairo(
            u * 3.5,
            weight: 400,
            color: RateelColors.soonText,
          ).copyWith(height: 1.5),
        ),
        SizedBox(height: u * 3.5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _dialogButton(
                u,
                'إلغاء',
                onTap: () => Navigator.of(dialog).pop(),
              ),
            ),
            SizedBox(width: u * 3),
            Flexible(
              child: _dialogButton(
                u,
                'إعادة الضبط',
                rim: RateelColors.setDanger,
                onTap: () {
                  AppSettings.resetProgress();
                  Haptics.success();
                  Navigator.of(dialog).pop();
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: RateelColors.setCardTop,
                      width: u * 60,
                      content: Text(
                        'تمت إعادة ضبط التقدم',
                        textAlign: TextAlign.center,
                        style: cairo(
                          u * 3.4,
                          weight: 600,
                          color: RateelColors.setLabel,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
