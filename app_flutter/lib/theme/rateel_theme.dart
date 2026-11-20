import 'package:material_ui/material_ui.dart';

/// Glassy gamified palette (dark). Values sampled from the ChatGPT references
/// in `docs/design/glassy-gamified/` (branch `lesson-production`).
class RateelColors {
  static const bgTop = Color(0xFF06392B);
  static const bgBottom = Color(0xFF02261C);
  static const panelTop = Color(0xFF0B3F30);
  static const panelBottom = Color(0xFF052E22);
  static const gold = Color(0xFFF2B623);
  static const goldLight = Color(0xFFFFD95A);
  static const goldDark = Color(0xFFB5850A);
  static const cream = Color(0xFFF4EAD0);
  static const bubbleText = Color(0xFF2A2210);
  static const glassFill = Color(0x0DFFFFFF);
  static const glassRim = Color(0x2E8FD4AE);
  static const railEdge = Color(0x5578B894);
}

/// Text in Readex Pro (variable font): the closest match to the ChatGPT titles.
TextStyle readex(double size, {double weight = 500, Color color = RateelColors.cream}) {
  return TextStyle(
    fontFamily: 'ReadexPro',
    fontSize: size,
    color: color,
    height: 1.25,
    fontVariations: [FontVariation('wght', weight)],
  );
}

/// Light theme is not designed yet: the toggle (settings screen) is planned,
/// both modes resolve to the dark palette until the owner enables light mode.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.dark);

ThemeData rateelDarkTheme() => ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'ReadexPro',
      scaffoldBackgroundColor: RateelColors.bgBottom,
      colorScheme: const ColorScheme.dark(
        primary: RateelColors.gold,
        surface: RateelColors.bgBottom,
      ),
    );
