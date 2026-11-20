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

  // Screen 03, courses (sampled from reference 03, critic-v1 of 03-courses).
  // Proposed tokens: the owner confirms them with the screen.
  static const contentTop = Color(0xFF07362A);
  static const contentBottom = Color(0xFF00271D);
  static const cardTop = Color(0xFF033428);
  static const cardMid = Color(0xFF012F25);
  static const cardLow = Color(0xFF023126);
  static const cardBottom = Color(0xFF053F30);
  static const cardRim = Color(0xFF27654F); // locked card rim, 4 px, middle
  static const cardRimTop = Color(0xFF2F6954);
  static const cardRimBottom = Color(0xFF559174);
  static const cardContact = Color(0xFF00160C); // 1 px line under the card
  static const cardPattern = Color(0xFF2E6A4C);
  static const cardRimDark = Color(0xFF144837); // outer edge of the rim
  static const pathLine = Color(0xFFD1A93C);
  static const pathNode = Color(0xFFFCC24A);
  static const progressTrack = Color(0xFF265343);
  static const progressFill = Color(0xFFEBB335);
  static const playFill = Color(0xFF43552A);
  static const lockDisc = Color(0xFF01261E);
  static const lockRim = Color(0xFF1A533F);
  static const lockGlyph = Color(0xFFDAD7BF);
  static const pillFill = Color(0xFF062D20);
}

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
