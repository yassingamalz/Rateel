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

  // Screen 27, badges (measured on 27-badges/reference.webp). Panels use the
  // screen-11 gold rim (leaderRim*); tiles and tabs use the confirmed glass rims (tileRim, rowRim; owner 2026-11-27).
  static const badgePanelTop = Color(0xFF07361F); // left panel, lit top
  static const badgePanelMid = Color(0xFF033421);
  static const badgePanelBottom = Color(0xFF012F1D);
  static const badgeTileFill = Color(0xFF05311E);
  static const badgeTileGlow = Color(0xFF29491C); // olive halo of the selected tile
  static const badgeRewardTop = Color(0xFF0F401D);
  static const badgeRewardBottom = Color(0xFF0C3C1E);
  static const badgeRewardRim = Color(0xFFB9A646);
  static const badgeBarTrack = Color(0xFF053920);
  static const badgeBarRim = Color(0xFF8E9A55);
  static const badgeArchLine = Color(0xFFD9C455); // faint inner arch, drawn at 28%

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

  // Screen 23 settings, measured on `23-impostazioni.webp`.
  static const setRimTop = Color(0xFFF9F59E); // card rim, pale gold (top)
  static const setRimSide = Color(0xFFEFCC5D); // card rim (sides, bottom)
  static const setRimGlow = Color(0xFFF3D567);
  static const setCardTop = Color(0xFF14532B); // lit top edge inside the rim
  static const setCardMid = Color(0xFF02331F);
  static const setCardBottom = Color(0xFF00321F);
  static const setLine = Color(0xFF5E8A6C); // row separator (light half)
  static const setLineDark = Color(0xFF002510); // row separator (dark half)
  static const setLabel = Color(0xFFFFFFDF);
  static const setMuted = Color(0xFFB9CBB0);
  static const setPillRim = Color(0xFFDEDC8A);
  static const setPillFill = Color(0xFF073B26);
  static const setGoldTop = Color(0xFFFDC146);
  static const setGoldBottom = Color(0xFFE8A51F);
  static const setKnob = Color(0xFFF8EBC0);
  static const setKnobOff = Color(0xFFB9C3A6);
  static const setDanger = Color(0xFFE17A6F); // «إعادة ضبط التقدم» rim

  // Screen 08 (reading lesson), sampled from `screens/08-reading-lesson/
  // reference-{dark,light}.webp` and `reference-panel.png`. Built with the
  // reference values (conflicts R1–R6 in docs/flutter/STYLE-CONFLICTS.md).
  // Dark.
  static const readBgCentre = Color(0xFF013024);
  static const readBgEdge = Color(0xFF002B21);
  static const readToolFill = Color(0xFF01362A);
  static const readToolRimTop = Color(0xFF3E7055);
  static const readToolRimBottom = Color(0xFF2E5E45);
  static const readSeparator = Color(0xFF6A9574);
  static const readCardTop = Color(0xFF174C2E);
  static const readCardMid = Color(0xFF033B2C);
  static const readCardBottom = Color(0xFF013729);
  static const readCardRim = Color(0xFFF7E27A); // core of the rim
  static const readCardRimSide = Color(0xFFD4B44A);
  static const readShelf = Color(0xFF175D44); // faint line under the card
  static const readDiscFill = Color(0xFF184832); // «A» disc
  static const readDiscRim = Color(0xFF2A5C40);
  static const readCounterRim = Color(0xFF8E9A55); // «8 / 1» pill, olive gold
  // Toolbar rings (moon, ‹ ›, «8 / 1»): thin, dark olive at the top, light
  // gold at the bottom, faint glow.
  static const readRingTop = Color(0xFF8C7A2C);
  static const readRingBottom = Color(0xFFF7D660);
  static const readCounterRimBottom = Color(0xFFFBEFA0);
  static const readADiscTop = Color(0xFF2F6448);
  static const readADiscRim = Color(0xFF5A8A6C);
  static const readDotOff = Color(0xFF3E6942);
  static const readDotDone = Color(0xFF5F7440);
  static const readDotOn = Color(0xFFFBC950);
  static const readLattice = Color(0xFFB09A3C); // lattice tile tint (dark)
  // Light (the same screen with the moon toggle, reference-light).
  static const readLBgCentre = Color(0xFFF9F1E3);
  static const readLBgEdge = Color(0xFFFBF2E5);
  static const readLToolFill = Color(0xFFF6EDE0);
  static const readLToolRimTop = Color(0xFFFEF9EE);
  static const readLToolRimBottom = Color(0xFFE9DCCB);
  static const readLSeparator = Color(0xFFDCC7B0);
  static const readLCardTop = Color(0xFFFBF3E9);
  static const readLCardMid = Color(0xFFFCF5EA);
  static const readLCardBottom = Color(0xFFFDF6EC);
  static const readLCardRim = Color(0xFFE6D6C2);
  static const readLCardRimSide = Color(0xFFCBAC93);
  static const readLShelf = Color(0xFFEAE3D5);
  static const readLInk = Color(0xFF341E06); // verse, buttons, numbers
  static const readLTitle = Color(0xFFA17550); // copper title
  static const readLCopper = Color(0xFFC99561); // arch, divider, badge line
  static const readLBook = Color(0xFFC1864E);
  static const readLCrescent = Color(0xFFE2B278);
  static const readLMosque = Color(0xFFDEC5A7);
  static const readLLattice = Color(0xFFE4C7A5);
  static const readLPillFill = Color(0xFFE3CFBB);
  static const readLPillRim = Color(0xFFD8BDA4);
  static const readLDiscFill = Color(0xFFEADCCB);
  static const readLDiscRim = Color(0xFFDFC9B3);
  static const readLADisc = Color(0xFFF2E6D8);
  static const readLDotOff = Color(0xFFE9D6C0);
  static const readLDotDone = Color(0xFFD9BC9C);
  static const readLDotOn = Color(0xFF9B6E48);
  static const readLBadgeFill = Color(0xFFFCF4E8);
  // Screen 02 bar in the light reading lesson (capsule, pause button).
  static const lessonLCapsule = Color(0xFFDBD8CB);
  static const lessonLCapsuleRim = Color(0xFFE9E4D7);
  static const lessonLButton = Color(0xFFFBF2E4);
  static const lessonLRing = Color(0xFFEAB87C);
  static const lessonLInk = Color(0xFF341900);

  // Screen 10, test lesson: sampled on screens/10-test-lesson/reference.webp
  // and reference-answer.webp (conflicts T1–T6 in STYLE-CONFLICTS.md).
  static const testTitleTop = Color(0xFFFBDD72); // gold title (T1)
  static const testTitleBottom = Color(0xFFF0BE34);
  static const testSubtitle = Color(0xFFC8DDC6);
  static const testCardTop = Color(0xFF033428); // card, darker than 08 (T3)
  static const testCardMid = Color(0xFF012B21);
  static const testCardBottom = Color(0xFF00251E);
  static const testNavFill = Color(0xFF104430); // question circles
  static const testNavRim = Color(0xFF5C8F6F);
  static const testNavText = Color(0xFFD5E4D2);
  static const testNavOnTop = Color(0xFFF4C842); // current circle (gold)
  static const testNavOnBottom = Color(0xFFDDA00A);
  static const testRowFill = Color(0xFF0B3A2A); // option rows (T2)
  static const testRowRimTop = Color(0xFF70A685);
  static const testRowRimBottom = Color(0xFF498163);
  static const testRadio = Color(0xFFBBD7BD);
  static const testSelTop = Color(0xFF214E2D); // selected row (10b)
  static const testSelBottom = Color(0xFF1A4728);
  static const testSelRim = Color(0xFFFCE680);
  static const testSelDot = Color(0xFFFDCE2D);
  static const testPillTop = Color(0xFF2B481C); // «+10 نقطة», confirm button
  static const testPillBottom = Color(0xFF00211A);
  static const testPillRimTop = Color(0xFFF7EE9E);
  static const testPillRimBottom = Color(0xFFFFD229);
  static const testPillText = Color(0xFFF9EAAC);
  // Feedback (owner's choice A, mockup feedback-a-*): jewel green / red (T5).
  static const testOkTop = Color(0xFF1F6A45);
  static const testOkBottom = Color(0xFF10503A);
  static const testOkRim = Color(0xFF56C98C);
  static const testOkDiscTop = Color(0xFF6EDDA0);
  static const testOkDisc = Color(0xFF2A9A5E);
  static const testOkText = Color(0xFF9BE8BE);
  static const testKoTop = Color(0xFF5A2A22);
  static const testKoBottom = Color(0xFF43201B);
  static const testKoRim = Color(0xFFD0644F);
  static const testKoDiscTop = Color(0xFFF08A72);
  static const testKoDisc = Color(0xFFB4453A);
  // Partly correct answer (owner, 2026-11-26): jewel amber.
  static const testPartTop = Color(0xFF5A4A1A);
  static const testPartBottom = Color(0xFF40351A);
  static const testPartRim = Color(0xFFE2B243);
  static const testPartDiscTop = Color(0xFFF7D47A);
  static const testPartDisc = Color(0xFFC98E1E);
  static const testLPartTop = Color(0xFFFBEFD0);
  static const testLPartBottom = Color(0xFFF4E0AE);
  static const testLPartRim = Color(0xFFC9962E);
  // Light theme of the test (from the 08 light tokens).
  static const testLRowFill = Color(0xFFF7EEE1);
  static const testLRowRim = Color(0xFFDCC5AC);
  static const testLRadio = Color(0xFFB99572);
  static const testLSelTop = Color(0xFFF8E7C4);
  static const testLSelBottom = Color(0xFFF3DDB2);
  static const testLSelRim = Color(0xFFD9A441);
  static const testLNavFill = Color(0xFFF6EDE0);
  static const testLOkTop = Color(0xFFDDF1E2);
  static const testLOkBottom = Color(0xFFCDEAD5);
  static const testLOkRim = Color(0xFF3E9B66);
  static const testLKoTop = Color(0xFFF7E0DA);
  static const testLKoBottom = Color(0xFFF1D0C8);
  static const testLKoRim = Color(0xFFC0503E);
  // Light buttons filled, white text (owner, 2026-11-26).
  static const testLGoldTop = Color(0xFFE6BB58);
  static const testLGoldBottom = Color(0xFFC48F2C);
  static const testLGoldRimTop = Color(0xFFF6DC98);
  static const testLGoldRimBottom = Color(0xFFAE7A22);
  static const testLGreenTop = Color(0xFF4FA676);
  static const testLGreenBottom = Color(0xFF2E7A52);
  static const testLGreenRimTop = Color(0xFF8DD2AA);
  static const testLRedTop = Color(0xFFC95A47); // «إعادة الاختبار» when failed
  static const testLRedBottom = Color(0xFF9C3527);
  static const testLRedRimTop = Color(0xFFEE9C8A);
  // Score colour of the results ring (owner, 2026-11-26).
  static const testScoreRedLow = Color(0xFFB8402F);
  static const testScoreRed = Color(0xFFD9583A);
  static const testScoreAmber = Color(0xFFD98A24); // 51%: dark amber
  static const testScoreAmberHigh = Color(0xFFDDA02A);
  static const testScoreGold = Color(0xFFE9B83A); // pass mark
  // Screen 22, listening lesson: values measured on `22-lezione-ascolto.webp`
  // (conflicts L1–L4 in `STYLE-CONFLICTS.md`).
  static const listenWord = Color(0xFFE2B92B); // asked / recited word
  static const listenWavePlayed = Color(0xFFEAB00B);
  static const listenWaveRest = Color(0xFF3B6C39);
  static const listenLine = Color(0xFF2F6352); // line above the bottom row
  static const listenPillFill = Color(0xFF032F21);
  static const listenPillRim = Color(0xFFC9D39A); // pale gold-cream, 0.25u
  static const listenGoldTop = Color(0xFFF3BF41); // selected answer
  static const listenGoldBottom = Color(0xFFE49F17);
  static const listenGoldRim = Color(0xFFFEE987);
  static const testScoreFull = Color(0xFFFFDC5E); // 100%: full bright gold
  static const testLScoreRed = Color(0xFFB9452F);
  static const testLScoreAmber = Color(0xFFC27A1C);
  static const testLScoreGold = Color(0xFFC9962E);
  static const testLScoreFull = Color(0xFFD9A21E);
  // Screen 12, daily challenges (sampled on the reference, 2026-11-25).
  static const chalRim = Color(0xFFFBC411); // tile rim core
  static const chalRimLight = Color(0xFFFFE98A); // open tile rim highlight
  static const chalTileTop = Color(0xFF052A17);
  static const chalTileBottom = Color(0xFF01200F);
  static const chalOpenTop = Color(0xFF2A3A10); // olive glass of the open tile
  static const chalOpenBottom = Color(0xFF1A2C0B);
  static const chalPillTop = Color(0xFF0E4422);
  static const chalPillBottom = Color(0xFF0B3519);
  static const chalPillRim = Color(0xFFB9A52E);
  static const chalOpenPill = Color(0xFF4A4D0E);
  static const chalLine = Color(0xFFFFE451); // connector core
  static const chalLineTrack = Color(0xFF2C4A25); // connector not yet lit
  static const chalCapsuleTop = Color(0xFF062C18);
  static const chalCapsuleBottom = Color(0xFF022412);
  static const chalCapsuleRim = Color(0xFFFFFE64); // rim core, top
  static const chalCapsuleRimLow = Color(0xFFFAC102); // rim core, bottom
  static const chalCapsuleRimOuter = Color(0xFFFFB201);
  static const chalLineEdge = Color(0xFFFEFCD6); // pale top edge of the line
  static const chalOpenRimTop = Color(0xFFEBC952);
  static const chalOpenRimBottom = Color(0xFFB47F01);
  static const chalOpenRimCore = Color(0xFFFDFBD1);
  static const chalOpenRimInner = Color(0xFFE9DD97);
  static const chalDisc = Color(0xFF3A3C08);
  static const chalDiscEdge = Color(0xFF242E06);
  static const chalDiscRim = Color(0xFFF5CC02);
  static const chalText = Color(0xFFF7F1DC); // «50», streak number
  static const chalLabel = Color(0xFFE1E1C1); // subtitle, streak label
  static const chalBandEdge = Color(0xFFB8932E); // gold edge of the bottom band

  // Screen 29, profile: reference values (`reference-dark.webp`,
  // `reference-light.webp`), conflicts P1–P6 in STYLE-CONFLICTS.md.
  static const profCardTop = Color(0xFF013121);
  static const profCardBottom = Color(0xFF033420);
  static const profCardRim = Color(0xFFF6F3B8); // pale gold core
  static const profCardGlow = Color(0x80E3C94E);
  static const profPanelFill = Color(0xFF012F1F);
  static const profPanelRim = Color(0xFF579177);
  static const profTileTop = Color(0xFF013322);
  static const profTileBottom = Color(0xFF013220);
  static const profLevelRim = Color(0xFFB3E1B6);
  static const profPillRim = Color(0xFFE8D255);
  static const profPillText = Color(0xFFF1D143);
  static const profGlyph = Color(0xFFF2CD5D);
  static const profCity = Color(0xFFDCE3CF);
  static const profDivider = Color(0xFFEDE27A);
  static const profHeaderDivider = Color(0xFFE6D25E);
  static const profVDivider = Color(0xFFD6E6C2);
  static const profAvatarLattice = Color(0xFF5F8248);
  static const profLattice = Color(0x8C5E7A34); // faint olive lines
  static const profRingTop = Color(0xFFF9EFA0);
  static const profRingBottom = Color(0xFFF2DE7C);
  static const profRingLine = Color(0xFFB69818); // darker line inside the ring
  static const profRingGlow = Color(0xFFF2C94C);
  static const profArchGlow = Color(0x99F5D25A);
  static const profFloorGlow = Color(0xFFD9C93A); // light under the Quran stand
  // Light theme.
  static const profLBg = Color(0xFFFEF3E8);
  static const profLInk = Color(0xFF643913);
  static const profLCity = Color(0xFF7A5634);
  static const profLCardTop = Color(0xFFFEF2E6);
  static const profLCardBottom = Color(0xFFFFF6E7);
  static const profLCardRim = Color(0xFFBA8642);
  static const profLCardRimSide = Color(0xFFD59E5E);
  static const profLCardGlow = Color(0x33D59E5E);
  static const profLPanelFill = Color(0xFFFDF2E3);
  static const profLPanelRim = Color(0xFFEBD6BE);
  static const profLTileRim = Color(0xFFC9B193);
  static const profLLevelRim = Color(0xFFAA7534);
  static const profLPill = Color(0xFF114223);
  static const profLGlyph = Color(0xFFE8A302);
  static const profLBook = Color(0xFF91570D);
  static const profLMedal = Color(0xFFD9940A);
  static const profLDivider = Color(0xFFBE8E33);
  static const profLLattice = Color(0xFFEBD8C0);
  static const profLArch = Color(0xFFCFAD82);
  static const profLMosque = Color(0xFFE0C2A3);
  static const profLHeaderBook = Color(0xFFAF751C);
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
