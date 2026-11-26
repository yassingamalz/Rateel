import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'challenges/challenge_data.dart';
import 'coming_soon/coming_soon_screen.dart';
import 'core/app_settings.dart';
import 'courses/course_data.dart';
import 'courses/courses_screen.dart';
import 'core/learn_flow.dart';
import 'nav/nav_items.dart';
import 'nav/side_nav.dart';
import 'settings/settings_screen.dart';
import 'splash/startup_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'screens/section_placeholder.dart';
import 'theme/rateel_theme.dart';
import 'lessons/lesson_data.dart';
import 'lessons/lesson_page.dart';
import 'lessons/listening_lesson_page.dart';
import 'lessons/reading_lesson_page.dart';
import 'lessons/test_lesson_page.dart';
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
  // Review aids (screen 08): `?readTheme=light`, `?verse=3`, `?rules=1`,
  // `?fontMenu=1` (with `?lessons=0,1&openLesson=0`).
  final q = Uri.base.queryParameters;
  readingStartLight = q['readTheme'] == 'light';
  readingStartVerse = int.tryParse(q['verse'] ?? '') ?? 0;
  readingStartRules = q['rules'] == '1';
  readingStartFontMenu = q['fontMenu'] == '1';
  // Review aids (screen 10): `?testQ=4&testPick=1&testState=ok|ko|partial|
  // streak|results|fail|details`, `?testRight=6` (with `?lessons=0,<unit>&openLesson=0`).
  testStartQuestion = int.tryParse(q['testQ'] ?? '') ?? 0;
  testStartPick = [
    for (final s in (q['testPick'] ?? '').split(','))
      if (int.tryParse(s) != null) int.parse(s),
  ];
  testStartState = q['testState'];
  testStartRight = int.tryParse(q['testRight'] ?? '');
  // Review aids (screen 22): `?listenQ=2&listenPick=0&listenState=ok|ko`,
  // `?listenAt=0.4` (with `?lessons=1,2&openLesson=0`).
  listenStartQuestion = int.tryParse(q['listenQ'] ?? '') ?? 0;
  listenStartPick = int.tryParse(q['listenPick'] ?? '');
  listenStartState = q['listenState'];
  listenStartAt = double.tryParse(q['listenAt'] ?? '');
  listenLogAudio = q['logAudio'] == '1';
  listenPlayPos = q['playPos'] ?? listenPlayPos;
  listenLitAll = q['litAll'] == '1';
  listenWordLight = q['wordLight'] ?? listenWordLight;
  // Review aids (screen 12): `?challenges=1` opens the daily challenges,
  // `?chalDone=3` marks 3 challenges done, `?streak=4` sets the streak.
  LearnFlow.startChallenges = q['challenges'] == '1';
  streakChipVariant = q['chip'] ?? streakChipVariant;
  challengesDone.value = int.tryParse(q['chalDone'] ?? '') ?? 0;
  dailyStreak.value = int.tryParse(q['streak'] ?? '') ?? 0;
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

Future<void> _initialize(BuildContext context) async {
  // Warm the images used by the first course header while the logo is visible.
  // A failed decode can be retried before settings listeners are installed.
  await Future.wait([
    for (final name in ['mosque', 'corner_glow_left', 'corner_glow_right'])
      _loadHeaderImage(context, 'assets/ui/decor/$name.webp'),
  ]);
  await AppSettings.load();
  // Review aid (screen 23): `?textScale=1.2` tries the text size setting.
  final ts = double.tryParse(Uri.base.queryParameters['textScale'] ?? '');
  if (ts != null) AppSettings.textScale.value = ts;
}

Future<void> _loadHeaderImage(BuildContext context, String asset) async {
  Object? failure;
  await precacheImage(
    AssetImage(asset),
    context,
    onError: (error, _) => failure = error,
  );
  if (failure != null) throw StateError('Cannot load $asset: $failure');
}

class RateelApp extends StatelessWidget {
  const RateelApp({super.key, this.initialize = _initialize});

  final Future<void> Function(BuildContext) initialize;

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
        // Settings «حجم الخط» (screen 23) scales the app's own text, 90–110%.
        builder: (context, child) => ValueListenableBuilder<double>(
          valueListenable: AppSettings.textScale,
          builder: (context, scale, _) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
          ),
        ),
        home: StartupScreen(initialize: initialize, child: const _Home()),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SideNavScaffold(
      builder: (context, selected) => switch (selected) {
        0 => const LearnFlow(),
        3 => const LeaderboardScreen(),
        // Sections not built yet: coming soon (screen 14, as Angular).
        1 || 2 || 5 => const ComingSoonScreen(),
        settingsSection => const SettingsScreen(),
        _ => SectionPlaceholder(index: selected),
      },
    ),
  );
}
