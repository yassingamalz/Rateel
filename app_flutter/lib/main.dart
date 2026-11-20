import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'nav/side_nav.dart';
import 'screens/section_placeholder.dart';
import 'theme/rateel_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Review aid: `?slow=10` (web) plays every animation 10× slower.
  final slow = double.tryParse(Uri.base.queryParameters['slow'] ?? '');
  if (slow != null && slow > 0) timeDilation = slow;
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
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: Scaffold(
          body: SideNavScaffold(
            builder: (context, selected) => SectionPlaceholder(index: selected),
          ),
        ),
      ),
    );
  }
}
