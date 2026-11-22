import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'courses/course_data.dart';
import 'core/learn_flow.dart';
import 'nav/side_nav.dart';
import 'screens/section_placeholder.dart';
import 'theme/rateel_theme.dart';
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
  // Review aid: `?cards=green|gold|abstract` shows the illustrated card style.
  cardArtSet = Uri.base.queryParameters['cards'];
  // Review aids (screen 05): `?units=0` opens the units of course 0,
  // `?unit=2` makes unit 2 the one in progress, `?completeUnit=0` plays the
  // completion of unit 0 on start.
  LearnFlow.startUnits = int.tryParse(Uri.base.queryParameters['units'] ?? '');
  final startUnit = int.tryParse(Uri.base.queryParameters['unit'] ?? '');
  if (LearnFlow.startUnits != null && startUnit != null) {
    unitsProgressOf(LearnFlow.startUnits!).current = startUnit;
  }
  lockedStyle = Uri.base.queryParameters['locked'] ?? lockedStyle;
  lockSize =
      double.tryParse(Uri.base.queryParameters['lock'] ?? '') ?? lockSize;
  unitCompleted.value = int.tryParse(
    Uri.base.queryParameters['completeUnit'] ?? '',
  );
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
            builder: (context, selected) => selected == 0
                ? const LearnFlow()
                : SectionPlaceholder(index: selected),
          ),
        ),
      ),
    );
  }
}
