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
  static const unitDiscTop = Color(0xFF104631);
  static const unitDiscMid = Color(0xFF053C27);
  static const unitDiscBottom = Color(0xFF013524);
  static const unitMosqueTint = Color(0xCC3C5426); // srcATop, 80%
  static const unitDiscRim = Color(0xFF154F37);
  static const unitDiscEdge = Color(0xFF0B422A); // lit edge of the glass disc
  // Ring rims (critic v2): lit at the top and bottom, deeper on the sides.
  static const unitRingSide = Color(0xFFF8BC2C);
  static const unitRingTopBottom = Color(0xFFFFD54A);
  static const unitRingLockedSide = Color(0xFFB98F2C);
  static const unitRingLockedTop = Color(0xFFFBE068);
  static const unitRingLockedBottom = Color(0xFFFDC849);
  static const unitRingEdge = Color(0xFF002316);
  static const playCream = Color(0xFFF2D784);
  static const playCreamTop = Color(0xFFF4E1A8);
  static const playGlyph = Color(0xFF013321);
  static const badge = Color(0xFFE5A416);
  static const badgeTop = Color(0xFFF8C343);
  static const badgeText = Color(0xFF062016);
  static const unitIconTop = Color(0xFFF6E6B4);
  static const unitIconBottom = Color(0xFFE2C680);
  static const padlockTop = Color(0xFF2E8A5E);
  static const padlockBottom = Color(0xFF1B6644);
  static const padlockRim = Color(0xFFE8CF86);
  static const girihLine = Color(0xFF2F6B3C); // U6 background lattice
  static const unitLine = Color(0xFFC9A23A); // line between units, 100%
  static const unitDiamond = Color(0xFFECAB1C);
  static const unitDiamondMid = Color(0xFFF2B32C);
  static const unitDiamondTop = Color(0xFFFFE76D);
  static const unitLineEdge = Color(0xFF00261A);
  static const unitCornerTop = Color(0xFFF3B526);
  static const unitCornerBottom = Color(0xFFC98816);
  // Header arch of screen 05, gold along the stroke (critic v3).
  static const archEnd = Color(0xFFCB9C31);
  static const archTail = Color(0xFFEEAA21);
  static const archShoulder = Color(0xFFF9CA32);
  static const archApex = Color(0xFFFFCA32);
  // Title divider (screens 03, 05): brightest next to the diamond.
  static const dividerEndClear = Color(0x00B2983A);
  static const dividerEnd = Color(0xFFB2983A);
  static const dividerMid = Color(0xFFEFC246);
  static const dividerPeak = Color(0xFFF8D053);
  // Screen 06, lessons (sampled from reference 06). Proposed tokens.
  static const lessonIconMuted = Color(
    0xFF4F7E5E,
  ); // locked lesson icon (critic v1 A3)
  static const lessonIconTop = Color(0xFFFFD95A); // lesson icon gold, top
  static const lessonIconBottom = Color(0xFFF2B623);
  // Variant B (original Angular look, improved): filled gold active card.
  static const origGoldTop = Color(0xFFF1C23E);
  static const origGoldBottom = Color(0xFFD9A11C);
  static const origCardText = Color(0xFF13261A);
  static const origGlass = Color(
    0xFF123F2E,
  ); // glass card, Angular rgba(27,67,50)

  // Screen 02 (lesson top bar), owner 2026-11-24.
  /// Veil over a paused lesson (Angular's strong veil, with blur 0.55u).
  static const lessonVeil = Color(0x7300140E);

  /// Soft light at the leading edge of the gold fill in the capsule.
  static const lessonBarLight = Color(0xFFFFF3C2);

  // Screen 11 (leaderboard), sampled from reference 11. Provisional: conflict
  // K2 in docs/flutter/STYLE-CONFLICTS.md (owner decides at the end).
  /// The user's own row / pinned bar: green, brighter than the rows.
  static const meRowTop = Color(0xFF195826);
  static const meRowMid = Color(0xFF0A4523);
  static const meRowBottom = Color(0xFF04361B);

  /// Leaderboard text cream, brighter/warmer than `titleCream` (owner
  /// 2026-11-24: brightness as the reference). Conflict K9.
  static const leaderText = Color(0xFFFFFBDC);

  /// Leaderboard title in the ribbon: warm gold-cream (reference #F5E9B4).
  /// Conflict K10 with the screen-title gradient titleTop → titleBottom.
  static const leaderTitleTop = Color(0xFFF8F0C6);
  static const leaderTitleBottom = Color(0xFFF1DFA2);

  // Leaderboard golds measured on reference 11 (owner 2026-11-24: "the gold
  // brightness must match the reference"). Conflicts K1, K3, K6, K7, K8, K11.
  static const leaderRimEdge = Color(0xFFA89C48);
  static const leaderRimCore = Color(0xFFFCE75A);
  static const leaderRimLight = Color(0xFFFFF878);
  static const leaderRimCoreBright = Color(0xFFF8F27D);
  static const leaderRimLightBright = Color(0xFFFFFFA8);
  static const leaderRimThin = Color(0xCCCFC57A);
  static const leaderDivider = [
    Color(0xFFDDD88B),
    Color(0xFFFFFFB8),
    Color(0xFFE7E091),
  ];
  static const leaderTab = [
    Color(0xFF9D7514),
    Color(0xFFBE8E19),
    Color(0xFFE5A71C),
    Color(0xFFEAAC1F),
    Color(0xFFFDE66E),
  ];
  static const leaderBg = Color(0xFF00251C);
  static const leaderHeader = Color(0xFF01251A);
  static const leaderBgCentre = Color(0xFF02291F);
  static const leaderRow = [
    Color(0xFF02281C),
    Color(0xFF052B1D),
    Color(0xFF0E371E),
  ];
  static const leaderRowEdge = Color(0xFF0C3B2D);
  static const leaderRowLight = Color(0xFF89A87F);
  static const leaderDisc = [
    Color(0xFFEBAE1D),
    Color(0xFFEDAB15),
    Color(0xFFF2B827),
  ];
  static const leaderDiscRim = Color(0xFFF6E17A);
  static const leaderStar = [Color(0xFFF0B42C), Color(0xFFF4B81C)];

  // Screen 07 (video lesson), sampled from reference 07 (`07-lezione-video`,
  // `reference-playing`). Conflicts V1–V4 in docs/flutter/STYLE-CONFLICTS.md.
  /// Background: radial, lighter in the centre (V1, vs contentTop/Bottom).
  static const videoBgCentre = Color(0xFF012D22);
  static const videoBgEdge = Color(0xFF01261D);

  /// «تخطي» glass pill: dark green fill, thin gold rim with a soft glow (V2).
  static const videoSkipFill = Color(0xFF033223);
  static const videoSkipFillEdge = Color(0xFF062E1F);
  static const videoSkipRim = Color(0xFFE6A533);

  /// Player frame: thin bright gold rim, gold glow (V3).
  static const videoPlayerRimTop = Color(0xFFF5C958);
  static const videoPlayerRimSide = Color(0xFFF5AB32);

  /// Progress line under the player (V4).
  static const videoTrack = Color(0xFF687538);
  static const videoFill = Color(0xFFF1B53E);
  static const videoFillEnd = Color(0xFFEDAC37);
  static const videoKnob = Color(0xFFFDF1DA);

  /// Divider under the title: gold peak next to the diamond.
  static const videoDivider = Color(0xFFE7B142);
  static const videoDividerEnd = Color(0xFFB59135);
  static const leaderAvatarRim = [
    Color(0xFFFEFEC6),
    Color(0xFFF6C840),
    Color(0xFFFEE476),
  ];
  static const leaderAvatarInner = Color(0xFFD49302);
  static const leaderTabSeparator = Color(0xFF93985F);
  static const leaderTabLeft = Color(0xFF8A6514); // shaded left edge
  static const leaderTabRight = Color(0xFFFFC738); // lit right rim
  static const leaderTabOutlineLeft = Color(0xFF595722);
  static const leaderTabOutlineRight = Color(0xFFEEE695);
  static const leaderRing = Color(0xFFFCD542);
  static const leaderLattice = Color(
    0xFFD9A632,
  ); // reference lines #D29F20…#E0B040

  /// Modulates the gold art (medals, coins, avatars) to the reference's
  /// warmer, slightly darker gold (#FCBA2D → #F3B02E, #FED210 → #F6BB2C).
  static const leaderArtTone = Color(0xFFF8E6D8);

  // Screen 14, coming soon (measured on 14-in-arrivo.webp).
  /// Darkens the owner's background (#02331F-ish) to the reference (#062A21).
  static const soonBgTone = Color(0xFFE0D8D8);
  static const soonTitle = Color(0xFFFFFFE4); // titles, cream
  static const soonTitleGold = Color(0xFFF5B71F); // second title line
  static const soonSubtitle = Color(0xFFFFFFFF);
  static const soonText = Color(0xFFEFFFE6); // card descriptions
  static const soonRule = Color(0xFFF9C44C); // short rule under card titles
  static const soonCardTop = Color(0xFF09332A);
  static const soonCardBottom = Color(0xFF0B382B);
  static const soonCardRim = Color(0xFF3F7558);
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

/// Cairo (variable, wght 200–1000): screen 14 lettering, chosen by the owner
/// as the closest to its reference (2026-11-25). Style conflict S4.
TextStyle cairo(
  double size, {
  double weight = 500,
  Color color = RateelColors.cream,
}) {
  return TextStyle(
    fontFamily: 'Cairo',
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
