import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../lessons/lesson_decor.dart';
import '../lessons/reading_data.dart' show readingLight;
import '../lessons/test_lesson_page.dart' show LessonButton, LessonBtnGlyph;
import '../theme/rateel_theme.dart';
import 'practice_store.dart';

/// True while the reminder popup is over a lesson: the lesson waits (22 does
/// not start its audio).
final practiceReminderOpen = ValueNotifier<bool>(false);

/// Geometry of 31-B, measured on `reference-b-reminder-dark.webp` (no rail:
/// x in u from the screen centre).
class RemindMetrics {
  RemindMetrics._();

  static const cardW = 99.4, cardH = 54.5, cardTop = 23.1, radius = 3.9;
  static const iconCy = 31.7, iconH = 11.0;
  static const titleCy = 42.0, titleSize = 7.35;
  static const dividerCy = 49.5, dividerW = 37.6;
  static const lineCy = 55.5, lineSize = 4.2;
  static const goX0 = -6.74, goX1 = 42.6; // «اذهب إلى التدريب»
  static const laterX0 = -42.5, laterX1 = -9.8; // «لاحقاً»
  static const buttonCy = 67.3, buttonH = 10.8, buttonText = 4.6;
}

/// Shows the reminder (screen 31-B) over the lesson that is opening. Returns
/// `true` for «اذهب إلى التدريب», `false` for «لاحقاً» or Android back.
Future<bool> showPracticeReminder(BuildContext context) async {
  practiceReminderOpen.value = true;
  final go = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, a, b) => const _Reminder(),
    transitionBuilder: (context, a, b, child) => AnimatedBuilder(
      animation: a,
      child: child,
      builder: (context, child) => _ReminderFrame(t: a.value, child: child!),
    ),
  );
  practiceReminderOpen.value = false;
  return go == true;
}

/// Veil (fades in 250 ms) and the card (scale 0.92 → 1 with a fade).
class _ReminderFrame extends StatelessWidget {
  const _ReminderFrame({required this.t, required this.child});

  final double t;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = LessonPal(readingLight.value ? 1 : 0);
    final e = Curves.easeOutCubic.transform(t);
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: p
              .c(RateelColors.pracVeil, RateelColors.pracLVeil)
              .withValues(
                alpha:
                    p.c(RateelColors.pracVeil, RateelColors.pracLVeil).a *
                    (t / 0.83).clamp(0.0, 1.0),
              ),
        ),
        Opacity(
          opacity: e,
          child: Transform.scale(scale: 0.92 + 0.08 * e, child: child),
        ),
      ],
    );
  }
}

class _Reminder extends StatelessWidget {
  const _Reminder();

  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(
    child: Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, box) {
          final p = LessonPal(readingLight.value ? 1 : 0);
          final u = box.maxHeight / 100;
          final cx = box.maxWidth / 2;
          const m = RemindMetrics.cardTop;
          final ink = p.c(RateelColors.pracInk, RateelColors.pracLInk);
          final days = PracticeStore.daysAway.clamp(1, 99);
          Widget text(String s, double size, double cy, int w) => Positioned(
            left: 0,
            right: 0,
            top: u * (cy - m) - u * size - u * size * 0.08,
            height: u * size * 2,
            child: Center(
              child: Text(
                s,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                maxLines: 1,
                softWrap: false,
                style: readex(
                  u * size,
                  weight: w.toDouble(),
                  color: w > 500
                      ? p.c(const Color(0xFFF0E2BB), RateelColors.pracLTitle)
                      : ink,
                ).copyWith(height: 1.0),
              ),
            ),
          );
          final left = cx - u * RemindMetrics.cardW / 2;
          double bx(double v) => cx + u * v - left;
          return Stack(
            children: [
              Positioned(
                left: left,
                top: u * m,
                width: u * RemindMetrics.cardW,
                height: u * RemindMetrics.cardH,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GoldCardPainter(
                          p,
                          u,
                          u * RemindMetrics.radius,
                        ),
                      ),
                    ),
                    Positioned(
                      left:
                          u * RemindMetrics.cardW / 2 -
                          u * RemindMetrics.iconH * 499 / 512 / 2,
                      top:
                          u *
                          (RemindMetrics.iconCy - m - RemindMetrics.iconH / 2),
                      width: u * RemindMetrics.iconH * 499 / 512,
                      height: u * RemindMetrics.iconH,
                      child: _Calendar(p: p, u: u),
                    ),
                    text(
                      'لم تتدرّب منذ ${arabicDays(days)}',
                      RemindMetrics.titleSize,
                      RemindMetrics.titleCy,
                      700,
                    ),
                    Positioned(
                      left:
                          u *
                          (RemindMetrics.cardW - RemindMetrics.dividerW) /
                          2,
                      top: u * (RemindMetrics.dividerCy - m - 1.5),
                      width: u * RemindMetrics.dividerW,
                      height: u * 3,
                      child: GoldDivider(u: u, diamond: 1.3),
                    ),
                    text(
                      'خمس دقائق من التدريب تثبّت ما تعلّمته',
                      RemindMetrics.lineSize,
                      RemindMetrics.lineCy,
                      400,
                    ),
                    Positioned(
                      left: bx(RemindMetrics.goX0),
                      width: u * (RemindMetrics.goX1 - RemindMetrics.goX0),
                      top:
                          u *
                          (RemindMetrics.buttonCy -
                              m -
                              RemindMetrics.buttonH / 2),
                      height: u * RemindMetrics.buttonH,
                      child: LessonButton(
                        u: u,
                        p: p,
                        label: 'اذهب إلى التدريب',
                        glyph: LessonBtnGlyph.none,
                        height: RemindMetrics.buttonH,
                        fontSize: RemindMetrics.buttonText,
                        onTap: () => Navigator.of(context).pop(true),
                      ),
                    ),
                    Positioned(
                      left: bx(RemindMetrics.laterX0),
                      width:
                          u * (RemindMetrics.laterX1 - RemindMetrics.laterX0),
                      top:
                          u *
                          (RemindMetrics.buttonCy -
                              m -
                              RemindMetrics.buttonH / 2),
                      height: u * RemindMetrics.buttonH,
                      child: _LaterButton(
                        p: p,
                        u: u,
                        onTap: () => Navigator.of(context).pop(false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

/// The owner's calendar (A2, cream line icon) tinted gold, its page filled
/// lighter in the light theme as the reference, with a warm halo.
class _Calendar extends StatelessWidget {
  const _Calendar({required this.p, required this.u});

  final LessonPal p;
  final double u;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    fit: StackFit.expand,
    children: [
      Positioned(
        left: -u * 5,
        right: -u * 5,
        top: -u * 5,
        bottom: -u * 5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                p
                    .c(const Color(0xFFF5B82A), const Color(0xFFFFD98A))
                    .withValues(alpha: p.d(0.30, 0.55)),
                const Color(0x00F5B82A),
              ],
            ),
          ),
        ),
      ),
      if (p.t > 0)
        Positioned(
          left: u * 1.1,
          right: u * 1.1,
          top: u * 3.3,
          bottom: u * 1.1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: RateelColors.pracLCalendarPage.withValues(alpha: p.t),
              borderRadius: BorderRadius.circular(u * 0.6),
            ),
          ),
        ),
      Image.asset(
        'assets/ui/icons/calendar_cream.webp',
        fit: BoxFit.contain,
        color: RateelColors.pracCalendar,
      ),
    ],
  );
}

/// «لاحقاً»: quiet pill of the reference (no app standard, P31-7).
class _LaterButton extends StatefulWidget {
  const _LaterButton({required this.p, required this.u, required this.onTap});

  final LessonPal p;
  final double u;
  final VoidCallback onTap;

  @override
  State<_LaterButton> createState() => _LaterButtonState();
}

class _LaterButtonState extends State<_LaterButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final u = widget.u;
    return Semantics(
      button: true,
      label: 'لاحقاً',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {
          Haptics.tap();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(u * 10),
              color: p.c(
                RateelColors.pracLaterFill,
                RateelColors.pracLLaterFill,
              ),
              border: Border.all(
                color: p.c(
                  RateelColors.pracLaterRim,
                  RateelColors.pracLLaterRim,
                ),
                width: u * 0.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: p
                      .c(Colors.black, const Color(0xFF8A6A4A))
                      .withValues(alpha: p.d(0.3, 0.15)),
                  blurRadius: u * 1.0,
                  offset: Offset(0, u * 0.4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'لاحقاً',
                textDirection: TextDirection.rtl,
                style: readex(
                  u * RemindMetrics.buttonText,
                  weight: 700,
                  color: p.c(
                    const Color(0xFFF2E7C2),
                    RateelColors.pracLLaterInk,
                  ),
                ).copyWith(height: 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
