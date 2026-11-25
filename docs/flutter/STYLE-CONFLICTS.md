# Style conflicts register (whole project)

**Single register of every conflict between a reference and the confirmed tokens** (owner, 2026-11-24): every screen adds
its conflicts here, with the value built provisionally. The owner decides them **one by one at the end of the project**;
until then nothing is unified. Sections: screens 03/05/06 (C1–C10), screen 11 (K1–K6).

## Screens 03 / 05 / 06 vs the confirmed tokens (2026-11-24)

Audit of the code on `master` (all four screens merged) against `DESIGN-SYSTEM.md`. **Nothing was changed**:
the owner postponed the unification ("save everything for now, no interventions, we do it in the future").
Take this list when the unification session starts, ask the owner, then apply in `rateel_theme.dart` and the screens,
and run the critic without exclusions (desktop 1844×853 and phone 915×412).

| # | What | Confirmed token | Value in the screens | Proposal |
|---|---|---|---|---|
| C1 | Page background | `bgTop #063728 → bgBottom #00281C` | 03/05/06 `contentTop #07362A → contentBottom #00271D` (1–2 levels apart) | one token: `bgTop/bgBottom` |
| C2 | Glass rim | 2 px `#245843`, no fill | locked course card 4 px gradient `#2F6954→#559174`; «قريبًا» chips and toasts (05/06): solid `cardMid` fill + `cardRim #27654F` 0.23u | chips/toasts → `rowRim`; card rim = documented «card» token (to decide) |
| C3 | Gold rim | `#DAA42A` 1.2 px + `#FFDA6B` 1 px | active course card `#C69F3D/#D3A436` 4 px; unit ring `#EAAA16`, `#F8BC2C`, `#FFD54A`; lesson running light `cardRimGold` | lines = `goldEdge/goldHighlight`; card and unit ring as documented tokens (to decide) |
| C4 | Gold fill | `amber #E2A51E`, pills `#EDB120` | `badge #E5A416` (+`badgeTop #F8C343`), `progressFill #EBB335`, active lesson `#F1C23E→#D9A11C`, `gold #F2B623` as fill | badge → `amber`; progress → `amberPill`; active lesson → `amberPill→amber`; `gold` only for lines/glows |
| C5 | Text on gold | `countText #132C1A` | `badgeText #062016`, `origCardText #13261A`, `playGlyph #013321` | one `onGold #132C1A` |
| C6 | Text | labels `label #FFFDF5` w340 4u; titles `titleCream` ✅; descriptions `cream` ✅ | toasts/chips `titleCream` w450 4u; screen titles 9.3u (03) and 7.5u (05/06) | toasts → `label` w340; title scale 9.3u / 7.5u |
| C7 | Radii | row 4.1u, tile 3.0u, menu button 2.4u, pills h/2 | course card 4.7u (also lesson page); toast 3u; empty chip 4u; lesson card 3.2u; course pill 3.05u fixed | toast 3.0u; chip 4.1u; lesson card 3.0u; pill h/2; course card 4.7u «card» token |
| C8 | Shadows | `railShadows` | cards black 40% blur 2.2u y 0.6u (03 = 06); discs/badges black 35% blur 0.8–1.2u; toasts 35% | tokens `cardShadow`, `smallShadow` |
| C9 | Line widths | – | side nav (04) uses fixed px (1.2 / 1.7 px), screens use u | nav → u |
| C10 | Content dimming under the open menu | 12% black (🟡, reference has none) | unchanged | owner to confirm |

## Screen 11, leaderboard (2026-11-24)
Measured on `screens/11-leaderboard/reference.webp`. **Owner, 2026-11-24 (v5): the leaderboard matches the reference**
(gold brightness, title, text): K1, K3, K6, K7, K8, K9, K10, K11 are built with the **reference values** (`leader*` tokens);
the last column below is the original proposal. Decide at the end of the project whether the tokens or the reference win app-wide.

| # | What | Confirmed token | Reference value | Built provisionally |
|---|---|---|---|---|
| K1 | Panel rim | gold rim 1.2 px #DAA42A + 1 px #FFDA6B, glow 15% | ≈ 4 px gold, core #FFF878/#FDE55F, edge #A18C34, soft gold glow outside | token rim in u (thinner than the reference) |
| K2 | Current-user bar fill | selected row fill #3B4C1F (olive) | green #185727 → #0A4322 → #14431C, gold rim + glow | reference green as `meRowTop/meRowMid/meRowBottom`, rim = gold rim token |
| K3 | Active tab | flat gold #E2A51E | vertical gradient #A47915 → #E5A71C | flat `amber` + gold rim token |
| K4 | Background | `bgTop #063728 → bgBottom #00281C` | flat #00251C … #0A2F1E + gold lattice | `bgTop/bgBottom` + lattice (same as C1) |
| K5 | Rows | glass rim 2 px #245843, no fill | fill #052B1D/#02291E getting lighter downwards, light edge at the **bottom** (#7CA078, critic v1), no visible rim | `rowRim` in u, fill `cardTop → cardMid` |
| K6 | Rank disc «15» | `amber #E2A51E`, `countText #132C1A` | #EEB326, text #0B2315 | tokens (critic option: the screen 02 paused-button gold `badgeTop → amber`) |
| K7 | Glow of the panel and the pinned bar | gold glow 15% | ≈ 35% gold over ≈ 2.5u (critic v1) | token 15% |
| K8 | Chevron button | glass button: ring 0.2u #D8C35A, gold radial fill | ring 0.5u #FFDC4A, dark inside (critic v1) | glass button token |
| K9 | Text cream | `titleCream #FAF1D8` | #FDFBDB … #FFFEDE (critic v1) | **reference value** `leaderText #FFFBDC` (owner 2026-11-24: brightness as the reference) |
| K10 | Title in the ribbon | screen-title gradient `titleTop #FFFBEA → titleBottom #E9D7A8` | warm gold-cream ≈ #F5E9B4 | **reference value** `leaderTitleTop #F8F0C6 → leaderTitleBottom #F1DFA2` (owner 2026-11-24) |
| K11 | Gold glyphs and art | star `glyphGoldTop #FFD556 → glyphGoldBottom #EFB527`; medals/coins as drawn | star #F0B42C → #F4B81C; medals/coins warmer and darker | **reference**: `leaderStar`, `leaderArtTone` modulation |

## Screen 07, video lesson (2026-11-24)
Measured on `screens/07-video-lesson/reference.webp` and `reference-playing.webp`. Built with the **reference values**
(`video*` tokens), as decided for screen 11; the owner decides at the end of the project.

| # | What | Confirmed token | Reference value | Built provisionally |
|---|---|---|---|---|
| V1 | Background | `bgTop #063728 → bgBottom #00281C`; screens 03–06 `contentTop #07362A → contentBottom #00271D` | radial, centre #012D22, edges #01261D, girih over the whole screen | reference (`videoBgCentre/Edge`) (same family as C1/K4) |
| V2 | Skip button | glass button token (ring 1.7 px #D8C35A, gold radial fill) | pill 33.6×12.9u, dark green #033223, thin gold rim #E6A533 ≈ 0.28u, soft gold glow ≈ 16% | reference (`videoSkip*`) |
| V3 (obsolete v5: no frame, full-screen video) | Player frame | gold rim token #DAA42A 1.2 px + #FFDA6B 1 px | ≈ 0.3u #F5C958, gold glow ≈ 20% | reference (`videoPlayerRim*`) |
| V4 (obsolete v5: no time line; the dots use these colours) | Progress line under the video | progress `track #265343 / fill #EBB335` (03); 02 capsule gold | track #687538, fill #EDAC37 → #F1B53E, cream knob #FDF1DA 3u; **fills from the left** while the 02 capsule fills from the right | reference |
| V5 | Text cream | `titleCream #FAF1D8`, `cream #F4EAD0` | titles #F6E8CA–#FAF3D1 (kept `titleCream`), sentence #D2D0C2 (`cream` 82%), times #FBFCE4 (`leaderText`) | tokens |

## Screen 14, coming soon (2026-11-24)

| # | What | Confirmed token | Value in the screen | Proposal |
|---|---|---|---|---|
| S1 | Background | shared `ScreenBackground` + `ScreenGirih` | owner's baked image `ui/coming_soon/background.webp` (arcs, girih, waves, mosque), `soonBgTone` | reference |
| S2 | Text colours | `titleCream #FAF1D8`, `cream #F4EAD0` | titles #FFFFE4, subtitle #FFFFFF, card text #EFFFE6, gold line #F5B71F | reference |
| S3 | Card glass | 03/06 card tokens | fill #09332A → #0B382B, rim #3F7558 0.3u, radius 4.7u | reference |
| S4 | Font | Readex Pro (whole app) | Cairo (variable) on screen 14, owner's choice as closest to the reference (2026-11-25) | owner decides at the end: Cairo everywhere, or Readex here |

## Screen 08, reading lesson (2026-11-25)
Measured on `screens/08-reading-lesson/reference-{dark,light}.webp` and `reference-panel.png`. Built with the **reference
values** (`read*` tokens), as screens 07/11; the owner decides at the end of the project.

| # | What | Confirmed token | Reference value | Built provisionally |
|---|---|---|---|---|
| R1 | Background | `bgTop/bgBottom`; 07 `videoBgCentre/Edge` | flat radial #013024 → #002B21, no girih, lattice only in the top corners | reference (`readBg*`) (same family as C1/K4/V1) |
| R2 | Toolbar, panel rows, search field | glass rim 2 px #245843, no fill | fill #01362A, rim 0.25u #3E7055 (top) → #2E5E45 (bottom), radius 3.2u | reference (`readTool*`) |
| R3 | Verse card | gold rim token #DAA42A 1.2 px + #FFDA6B 1 px; card radius 4.7u | rim 0.35u #F7E27A / #D4B44A with a gold glow ≈ 38%, fill #174C2E → #033B2C → #013729, radius 3.6u | reference (`readCard*`) |
| R4 | Toolbar round buttons and «8 / 1» | glass button token; 07 `videoSkip*` (V2) | thin ring 0.24u #8C7A2C (top) → #F7D660 (bottom), glow ≈ 16%; «A» filled green #2F6448 → #184832 | reference (`readRing*`, `readADisc*`, `LessonRoundButton(compact:)`) |
| R5 | Text cream | `titleCream #FAF1D8` | verse and buttons #FFFBDC (= `leaderText`, K9) | reference |
| R6 | **Light theme** (first light screen of the app) | none yet | cream #F9F1E3 / #FBF2E5, ink #341E06, copper #C99561, title #A17550, tan rims | reference (`readL*`, `lessonL*`; 02 bar and shared lesson buttons take `light:`) |
| R7 | Font of «A» and of the verse number | Readex Pro | serif (Times-like) in the reference | Readex Pro |


## Screen 10, test lesson (2026-11-25)
Measured on `screens/10-test-lesson/reference.webp` and `reference-answer.webp`. Built with the **reference values**
(`test*` tokens), as 07/08/11; the owner decides at the end of the project. Feedback colours have no reference value
(owner's choice A from Claude's mockups).

| # | What | Confirmed token | Reference value | Built provisionally |
|---|---|---|---|---|
| T1 | Lesson title | `titleCream` (08 title cream) | gold gradient ≈ #FBDD72 → #F0BE34, bold | reference (`testTitleTop/Bottom`, `HeaderSpec.goldTitle`) |
| T2 | Option rows, result rows, stat tiles | glass rim 2 px #245843, no fill | flat #0B3A2A, rim 0.3u #70A685 → #498163, radius 1.9u; selected: #214E2D → #1A4728, gold rim #FCE680, gold dot #FDCE2D | reference (`testRow*`, `testSel*`) |
| T3 | Question card | 08 card `readCardTop #174C2E → readCardBottom #013729` (R3) | darker #002F23 → #00251E, same gold rim | reference (`testCard*`, `GoldCardPainter(fill:)`) |
| T4 | Question circles | glass button / `amber #E2A51E` | dark disc #104430, rim #5C8F6F 0.3u, number #D5E4D2; current gold #F4C842 → #DDA00A | reference (`testNav*`) |
| T5 | Correct / wrong (feedback, rows, circles, discs) | none | none in the reference: jewel green #1F6A45 → #10503A rim #56C98C, red #5A2A22 → #43201B rim #D0644F (owner's choice A of the mockups) | `testOk*`, `testKo*`, light `testLOk*`, `testLKo*` |
| T6 | «+10 نقطة» pill, «تأكيد الإجابة», «السؤال التالي», «إنهاء الدرس» | 07 skip `videoSkip*` (V2) / gold rim token | olive → dark fill #2B481C → #00211A, rim #F7EE9E → #FFD229 with a gold glow, text #F9EAAC | reference (`testPill*`) |
| T7 | Subtitle | `leaderText` / `cream` | pale green-cream ≈ #C3DBC2 | reference (`testSubtitle`) |
