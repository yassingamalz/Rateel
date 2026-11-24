import 'package:material_ui/material_ui.dart';

/// Design tokens of the glassy gamified line (dark). Every value is sampled
/// from the ChatGPT references by the critic (docs/flutter/screens/04-side-nav/
/// critic-v1.md) and listed in docs/flutter/DESIGN-SYSTEM.md. Screens use these
/// names only; they never hard-code a colour.
class RateelColors {
  // Backgrounds
  static const bgTop = Color(0xFF063728);
  static const bgBottom = Color(0xFF00281C);
  static const panelTop = Color(0xFF053627);
  static const panelMid = Color(0xFF012E20);
  static const panelBottom = Color(0xFF00281C);

  /// 4 px light bevel on the left edge of the rail / panel.
  static const edgeBevel = [
    Color(0xFF1B4E37),
    Color(0xFF295F45),
    Color(0xFF134732),
  ];

  // Gold
  static const gold = Color(0xFFF2B623);
  static const goldRim = Color(0xFFF2B132);
  static const goldHighlight = Color(0xFFFFDA6B);
  static const goldEdge = Color(0xFFDAA42A);
  static const amber = Color(0xFFE2A51E); // count bubbles, active disc
  static const amberPill = Color(0xFFEDB120); // count pills in the open menu
  static const ringLine = Color(0xFFD8C35A);
  static const goldTintRow = Color(0xFF3B4C1F); // selected row fill (flat)
  static const iconDisc = Color(
    0xFF1E361B,
  ); // disc behind the selected menu icon
  static const iconRing = Color(0xFFECBE3B);

  // Glass (outline-only on the dark panel)
  static const rowRim = Color(0xFF245843);
  static const tileRim = Color(0xFF1C4E38);
  static const menuTileRim = Color(0xFF184C35);
  static const divider = Color(0xFF2C5845);

  // Content
  static const cream = Color(0xFFF4EAD0);
  static const iconCream = Color(0xFFFCF1D0);
  static const label = Color(0xFFFFFDF5);
  static const closeWhite = Color(0xFFF7F8F8);
  static const hamburger = Color(0xFFEFEACF);
  static const countText = Color(0xFF132C1A);
  static const activeGlyph = Color(0xFF06291C);
}

/// Shadow of the side rail / open menu on the content (owner, 2026-11-21):
/// the navigation reads as a layer above the screen.
List<BoxShadow> railShadows(double u) => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.45),
    blurRadius: u * 3.2,
    offset: Offset(-u * 0.9, 0),
  ),
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.30),
    blurRadius: u * 0.8,
    offset: Offset(-u * 0.25, 0),
  ),
];

/// Text in Readex Pro (variable font): the closest match to the ChatGPT titles.
TextStyle readex(
  double size, {
  double weight = 500,
  Color color = RateelColors.cream,
}) {
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
