import 'package:material_ui/material_ui.dart';

import '../courses/courses_screen.dart';
import '../units/units_screen.dart';

/// The learning section (rail item 0): courses → units → lessons, stacked in
/// their own navigator so the side navigation stays in place. The system
/// back button closes the top screen first.
class LearnFlow extends StatefulWidget {
  const LearnFlow({super.key});

  /// Review aid: `?units=<course>` (web) opens the units of that course.
  static int? startUnits;

  @override
  State<LearnFlow> createState() => _LearnFlowState();
}

class _LearnFlowState extends State<LearnFlow> {
  final _nav = GlobalKey<NavigatorState>();

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
        ],
      ),
    );
  }
}
