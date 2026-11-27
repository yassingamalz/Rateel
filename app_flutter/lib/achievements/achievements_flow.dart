import 'package:material_ui/material_ui.dart';

import '../nav/side_nav.dart';
import 'achievements_screen.dart';

/// The achievements section (rail item 4): screen 13 with screen 27 (badges)
/// and the level page stacked in their own navigator, so the side navigation
/// stays in place (as `LearnFlow`). The system back button closes the top
/// screen first; a tap on the rail item «الإنجازات» goes back to 13.
class AchievementsFlow extends StatefulWidget {
  const AchievementsFlow({super.key});

  @override
  State<AchievementsFlow> createState() => _AchievementsFlowState();
}

class _AchievementsFlowState extends State<AchievementsFlow> {
  final _nav = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    SideNavScaffold.reselected.addListener(_onReselected);
  }

  @override
  void dispose() {
    SideNavScaffold.reselected.removeListener(_onReselected);
    super.dispose();
  }

  void _onReselected() {
    if (SideNavScaffold.reselected.value == 4) {
      _nav.currentState?.popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) => _nav.currentState?.maybePop(),
      child: Navigator(
        key: _nav,
        clipBehavior: Clip.none,
        onGenerateInitialRoutes: (navigator, name) => [
          PageRouteBuilder<void>(
            pageBuilder: (context, a, b) => const AchievementsScreen(),
          ),
        ],
      ),
    );
  }
}
