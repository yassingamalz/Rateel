import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../theme/rateel_theme.dart';
import 'lesson_data.dart';
import 'lesson_shell.dart';

/// Steps of the placeholder lesson (the data has no steps yet). Review:
/// `?steps=16`.
int placeholderSteps = 8;

/// Placeholder lesson page (plan of screen 06, question 6 A) until the lesson
/// screens (07+) exist, now inside the shared lesson frame of screen 02
/// ([LessonShell]): a demo lesson of [placeholderSteps] steps with «الخطوة
/// التالية» and «أكملت الدرس», so the bar and the whole flow lessons → units
/// → courses can be tried on the phone. Returns `true` when the lesson is
/// finished. Opened above the whole app: the side rail is hidden.
Route<bool> lessonPageRoute(Lesson lesson, int index, int count) =>
    lessonRoute<bool>(
      (context) => LessonPage(lesson: lesson, index: index, count: count),
    );

class LessonPage extends StatefulWidget {
  const LessonPage({
    super.key,
    required this.lesson,
    required this.index,
    required this.count,
  });

  final Lesson lesson;

  /// Position of the lesson in its unit (1-based) and lessons in the unit.
  final int index;
  final int count;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final _shell = GlobalKey<LessonShellState>();
  int _step = 1;
  bool _finishing = false;
  bool _left = false;

  /// Leaves the lesson once (critic v1 #6: no second pop).
  void _leave(bool done) {
    if (_left || !mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    _left = true;
    Navigator.of(context).pop(done);
  }

  int get _total => placeholderSteps;

  Future<void> _finish() async {
    if (_finishing || _left) return;
    _finishing = true;
    setState(() => _step = _total);
    // Fill reaches the end (300 ms), the light runs along the capsule, then
    // the page leaves (Angular: 100 ms, exit).
    await Future<void>.delayed(const Duration(milliseconds: 320));
    await _shell.currentState?.celebrate();
    _leave(true);
  }

  void _next() {
    if (_step >= _total) {
      _finish();
    } else {
      Haptics.tick();
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return LessonShell(
      key: _shell,
      step: _step,
      total: _total,
      onBack: () => _leave(false),
      onRestart: () => setState(() => _step = 1),
      child: LayoutBuilder(
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
                        'الدرس ${widget.index} من ${widget.count}',
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
                        'صفحة مؤقتة: الخطوة $_step من $_total',
                        textDirection: TextDirection.rtl,
                        style: readex(
                          u * 2.6,
                          weight: 360,
                          color: RateelColors.cream.withValues(alpha: 0.55),
                        ),
                      ),
                      SizedBox(height: u * 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            _Button(
                              u: u,
                              label: _step >= _total
                                  ? 'إنهاء الدرس'
                                  : 'الخطوة التالية',
                              gold: true,
                              onTap: _next,
                            ),
                            SizedBox(width: u * 2.5),
                            _Button(
                              u: u,
                              label: 'أكملت الدرس',
                              gold: false,
                              onTap: _finish,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
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
