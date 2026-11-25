import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'coming_soon/coming_soon_screen.dart';
import 'courses/course_data.dart';
import 'core/learn_flow.dart';
import 'nav/side_nav.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'screens/section_placeholder.dart';
import 'theme/rateel_theme.dart';
import 'lessons/lesson_data.dart';
import 'lessons/lesson_page.dart';
import 'lessons/video_lesson_page.dart';
import 'units/unit_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Review aid: `?slow=10` (web) plays every animation 10× slower.
  final slow = double.tryParse(Uri.base.queryParameters['slow'] ?? '');
  if (slow != null && slow > 0) timeDilation = slow;
  // Review aid: `?complete=0` plays the completion of course 0 on start
  // (the lesson flow sets this when screens 05–07 exist).
  courseCompleted.value = int.tryParse(
    Uri.base.queryParameters['complete'] ?? '',
  );
  // Review aid: `?cards=classic|green|gold|abstract|emblem` switches the card style.
  final cards = Uri.base.queryParameters['cards'];
  if (cards != null) cardArtSet = cards == 'classic' ? null : cards;
  // Review aids (screen 05): `?units=0` opens the units of course 0,
  // `?unit=2` makes unit 2 the one in progress, `?completeUnit=0` plays the
  // completion of unit 0 on start.
  LearnFlow.startUnits = int.tryParse(Uri.base.queryParameters['units'] ?? '');
  final startUnit = int.tryParse(Uri.base.queryParameters['unit'] ?? '');
  if (LearnFlow.startUnits != null && startUnit != null) {
    unitsProgressOf(LearnFlow.startUnits!).current = startUnit;
  }
  lockSize =
      double.tryParse(Uri.base.queryParameters['lock'] ?? '') ?? lockSize;
  unitCompleted.value = int.tryParse(
    Uri.base.queryParameters['completeUnit'] ?? '',
  );
  // Review aids (screen 06): `?lessons=0,1` opens the lessons of unit 1 of
  // course 0 (its units screen below it), `?lessonDone=2` marks 2 lessons
  // done, `?completeLesson=2` plays the completion of lesson 2 on start,
  // `?origScale=1.35` tries another card scale.
  final lp = (Uri.base.queryParameters['lessons'] ?? '').split(',');
  if (lp.length == 2) {
    final c = int.tryParse(lp[0]);
    final u = int.tryParse(lp[1]);
    if (c != null && u != null && u < unitsOf(c).length) {
      LearnFlow.startUnits ??= c;
      LearnFlow.startLessons = (c, u);
      final up = unitsProgressOf(c);
      if (startUnit == null) up.current = u;
      final done = int.tryParse(Uri.base.queryParameters['lessonDone'] ?? '');
      if (done != null) {
        final id = unitsOf(c)[u].id;
        setLessonsDone(id, done);
        if (u == up.current) up.progress[u] = unitShareFromLessons(id);
      }
    }
  }
  // Review aid (screen 02): `?steps=16` steps in the placeholder lesson.
  placeholderSteps =
      int.tryParse(Uri.base.queryParameters['steps'] ?? '') ?? placeholderSteps;
  startCompleteLesson = int.tryParse(
    Uri.base.queryParameters['completeLesson'] ?? '',
  );
  // Review aids (screen 07): `?openLesson=0` opens that lesson on start,
  // `?video=demo|none`, `?videoAt=0.37`.
  startOpenLesson = int.tryParse(Uri.base.queryParameters['openLesson'] ?? '');
  videoMode = Uri.base.queryParameters['video'];
  videoStartAt =
      double.tryParse(Uri.base.queryParameters['videoAt'] ?? '') ?? 0;
  lessonLockPos = Uri.base.queryParameters['lessonLock'] ?? lessonLockPos;
  lessonLockColor =
      Uri.base.queryParameters['lessonLockColor'] ?? lessonLockColor;
  origScale =
      double.tryParse(Uri.base.queryParameters['origScale'] ?? '') ?? origScale;
  // Review aid (screen 11): `?section=3` opens the leaderboard on start.
  SideNavScaffold.startSection =
      int.tryParse(Uri.base.queryParameters['section'] ?? '') ?? 0;
  // Landscape is the main orientation (owner, 2026-11-20).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const RateelApp());
}

class RateelApp extends StatelessWidget {
  const RateelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'رتّل',
        debugShowCheckedModeBanner: false,
        theme: rateelDarkTheme(), // light theme: not designed yet
        darkTheme: rateelDarkTheme(),
        themeMode: mode,
        locale: const Locale('ar'),
        // Text keeps its designed size (in u) whatever the phone's text zoom
        // (owner, 2026-11-21): the system scale would break the proportions
        // between text and cards/ornaments. A text-size option will live in the
        // app's settings and scale the text proportionally.
        builder: (context, child) => MediaQuery.withNoTextScaling(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        ),
        home: Scaffold(
          body: SideNavScaffold(
            builder: (context, selected) => switch (selected) {
              0 => const LearnFlow(),
              3 => const LeaderboardScreen(),
              // Sections not built yet: coming soon (screen 14, as Angular).
              1 || 2 || 5 => const ComingSoonScreen(),
              _ => SectionPlaceholder(index: selected),
            },
          ),
        ),
      ),
    );
  }
}
