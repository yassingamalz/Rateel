import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../theme/rateel_theme.dart';
import 'lesson_data.dart';

/// Placeholder lesson page (plan of screen 06, question 6 A) until the lesson
/// screens (07+) exist: title, description and «أكملت الدرس», so the whole
/// flow lessons → units → courses can be tried on the phone. Returns `true`
/// when the lesson is finished.
Route<bool> lessonPageRoute(Lesson lesson, int step, int total) =>
    PageRouteBuilder<bool>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (context, a, b) =>
          LessonPage(lesson: lesson, step: step, total: total),
      transitionsBuilder: (context, a, b, child) {
        final t = Curves.easeOutCubic.transform(a.value);
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: lerpDouble(1.05, 1, t), child: child),
        );
      },
    );

class LessonPage extends StatelessWidget {
  const LessonPage({
    super.key,
    required this.lesson,
    required this.step,
    required this.total,
  });

  final Lesson lesson;
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final u = box.maxHeight / 100;
        return Stack(
          fit: StackFit.expand,
          children: [
            const ScreenBackground(),
            const Positioned.fill(child: IgnorePointer(child: ScreenGirih())),
            Center(
              child: Container(
                width: u * 110,
                padding: EdgeInsets.fromLTRB(u * 6, u * 5, u * 6, u * 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(u * 4.7),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [RateelColors.cardTop, RateelColors.cardBottom],
                  ),
                  border: Border.all(
                    color: RateelColors.cardRimGold,
                    width: u * 0.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: u * 2.2,
                      offset: Offset(0, u * 0.6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الدرس $step من $total',
                      textDirection: TextDirection.rtl,
                      style: readex(
                        u * 3,
                        weight: 500,
                        color: RateelColors.gold,
                      ),
                    ),
                    SizedBox(height: u * 1.5),
                    Text(
                      lesson.title,
                      textDirection: TextDirection.rtl,
                      style: readex(
                        u * 6,
                        weight: 600,
                        color: titleCream,
                      ).copyWith(shadows: titleShadows(u)),
                    ),
                    SizedBox(height: u * 1.5),
                    Text(
                      lesson.description,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: readex(u * 3.4, weight: 360),
                    ),
                    SizedBox(height: u * 2.5),
                    Text(
                      'صفحة مؤقتة: شاشة الدرس قادمة',
                      textDirection: TextDirection.rtl,
                      style: readex(
                        u * 2.6,
                        weight: 360,
                        color: RateelColors.cream.withValues(alpha: 0.55),
                      ),
                    ),
                    SizedBox(height: u * 4),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        _Button(
                          u: u,
                          label: 'أكملت الدرس',
                          gold: true,
                          onTap: () => Navigator.of(context).pop(true),
                        ),
                        SizedBox(width: u * 2.5),
                        _Button(
                          u: u,
                          label: 'رجوع',
                          gold: false,
                          onTap: () => Navigator.of(context).pop(false),
                        ),
                      ],
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

class _Button extends StatelessWidget {
  const _Button({
    required this.u,
    required this.label,
    required this.gold,
    required this.onTap,
  });

  final double u;
  final String label;
  final bool gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: u * 4, vertical: u * 1.8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(u * 4),
          gradient: gold
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [RateelColors.badgeTop, RateelColors.badge],
                )
              : null,
          border: gold
              ? null
              : Border.all(color: RateelColors.unitRingLocked, width: u * 0.22),
        ),
        child: Text(
          label,
          textDirection: TextDirection.rtl,
          style: readex(
            u * 3.2,
            weight: 560,
            color: gold ? RateelColors.badgeText : RateelColors.cream,
          ).copyWith(height: 1.1),
        ),
      ),
    );
  }
}
