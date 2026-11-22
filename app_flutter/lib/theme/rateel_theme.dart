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
  static const contentLift = Color(0xFF002D23);
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
  // Course in progress: muted gold rim, 4 px (reference 03).
  static const cardRimGold = Color(0xFFC69F3D);
  static const cardRimGoldInner = Color(0xFFD3A436);
  // Small gold glyphs (star, play): vertical gradient.
  static const glyphGoldTop = Color(0xFFFFD556);
  static const glyphGoldBottom = Color(0xFFEFB527);
  static const pathLine = Color(0xFFD1A93C);
  static const pathNode = Color(0xFFFCC24A);
  static const progressTrack = Color(0xFF265343);
  static const progressFill = Color(0xFFEBB335);
  static const playFill = Color(0xFF43552A);
  static const lockDisc = Color(0xFF01261E);
  static const lockRim = Color(0xFF1A533F);
  static const lockGlyph = Color(0xFFEDE3CB);
  static const pillFill = Color(0xFF062D20);

  // Screen 05, units (sampled from reference 05). Proposed tokens.
  static const unitRing = Color(0xFFEAAA16); // open unit ring, 0.42u
  static const unitRingLocked = Color(0xFFC29A33); // locked unit ring
  static const unitDiscTop = Color(0xFF104732);
  static const unitDiscMid = Color(0xFF043727);
  static const unitDiscRim = Color(0xFF10492E);
  static const playCream = Color(0xFFF4E0A1);
  static const playCreamTop = Color(0xFFFBEDC4);
  static const playGlyph = Color(0xFF013321);
  static const badge = Color(0xFFF2B32E);
  static const badgeTop = Color(0xFFFFD25E);
  static const badgeText = Color(0xFF062016);
  static const unitIconTop = Color(0xFFF6E6B4);
  static const unitIconBottom = Color(0xFFE2C680);
  static const padlockTop = Color(0xFF2E8A5E);
  static const padlockBottom = Color(0xFF1B6644);
  static const padlockRim = Color(0xFFE8CF86);
  static const unitLine = Color(0xFFC9A23A); // line between units
  static const unitDiamond = Color(0xFFECAB1C);
}

/// Titles (screen title, card titles): warm cream with a soft drop shadow,
/// as the ChatGPT titles (owner, 2026-11-21). The screen title adds a
/// top-to-bottom cream gradient (titleTop → titleBottom).
const titleCream = Color(0xFFFAF1D8);
const titleTop = Color(0xFFFFFBEA);
const titleBottom = Color(0xFFE9D7A8);
List<Shadow> titleShadows(double u) => [
  Shadow(
    color: Colors.black.withValues(alpha: 0.45),
    offset: Offset(0, u * 0.3),
    blurRadius: u * 0.6,
  ),
];

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
