import 'package:material_ui/material_ui.dart';

import '../courses/courses_screen.dart';
import '../lessons/lessons_screen.dart';
import '../units/units_screen.dart';

/// The learning section (rail item 0): courses → units → lessons, stacked in
/// their own navigator so the side navigation stays in place. The system
/// back button closes the top screen first.
class LearnFlow extends StatefulWidget {
  const LearnFlow({super.key});

  /// Review aid: `?units=<course>` (web) opens the units of that course.
  static int? startUnits;

  /// Review aid: `?lessons=<course>,<unit>` (web) opens the lessons of that
  /// unit (above its units screen).
  static (int, int)? startLessons;

  @override
  State<LearnFlow> createState() => _LearnFlowState();
}

class _LearnFlowState extends State<LearnFlow> {
  final _nav = GlobalKey<NavigatorState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Raster assets of the units screen are decoded ahead, so they do not
    // pop in after the screen appears (critic v2, phone capture).
    for (final a in const [
      'assets/ui/units/book.webp',
      'assets/ui/decor/mosque.webp',
      'assets/ui/decor/corner_units_top_left.webp',
      'assets/ui/decor/corner_units_bottom_right.webp',
      'assets/ui/decor/angular_pattern_2.webp',
    ]) {
      precacheImage(AssetImage(a), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) => _nav.currentState?.maybePop(),
      child: Navigator(
        key: _nav,
        // Ornaments run on under the side rail (screens 03, 05).
        clipBehavior: Clip.none,
        onGenerateInitialRoutes: (navigator, name) => [
          PageRouteBuilder<void>(
            pageBuilder: (context, a, b) => const CoursesScreen(),
          ),
          if (LearnFlow.startUnits != null) unitsRoute(LearnFlow.startUnits!),
          if (LearnFlow.startLessons case (final c, final u))
            lessonsRoute(c, u),
        ],
      ),
    );
  }
}
