import 'package:material_ui/material_ui.dart';

import '../coming_soon/coming_soon_screen.dart';
import '../core/learn_flow.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../nav/nav_items.dart';
import '../nav/side_nav.dart';
import '../screens/section_placeholder.dart';
import 'profile_screen.dart';

/// The profile shares the app navigation rail and opens from settings.
class ProfileDestination extends StatelessWidget {
  const ProfileDestination({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SideNavScaffold(
      initialSection: settingsSection,
      builder: (context, selected) => switch (selected) {
        0 => const LearnFlow(),
        3 => const LeaderboardScreen(),
        1 || 2 || 5 => const ComingSoonScreen(),
        settingsSection => ProfileScreen(
          onBack: () => Navigator.of(context).maybePop(),
        ),
        _ => SectionPlaceholder(index: selected),
      },
    ),
  );
}
