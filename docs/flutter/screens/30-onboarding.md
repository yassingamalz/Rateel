# Screen 30: onboarding (first start)

Branch `flutter/30-onboarding` from `master` `2c64be7` (2026-11-28). Plan v1 approved by the owner with the answers below;
**v1 built** (2026-11-28, section «Build v1» at the end).

## References (owner, 2026-11-28)
`30-onboarding/reference-{a-welcome,b-level,c-goal}-{dark,light}.webp` (1844×853; light C is 1843 wide), prompts
`prompts/30-onboarding/reference-v1.txt`. Owner: implement **exactly the skeleton** of the references (steps, places, sizes,
cards, step dots, buttons, Arabic texts) **with the app's confirmed style** (DESIGN-SYSTEM, `RateelColors`, Readex Pro, u).

Already decided (DECISIONS 2026-11-27): no account; name, level and goal saved on the phone; local data is primary. Name and
avatar must reach the profile 29 (today mock).

## Flow
1. Native launch → splash 01 → **first start only**: onboarding A → B → C → «ابدأ التعلّم» → courses 03 (same fade as
   splash → courses). Next starts: splash → courses, as today.
2. Hook: `StartupScreen(child: …)` in `main.dart` gets `OnboardingScreen` instead of `_Home` while `UserProfile.onboarded`
   is false; the profile is read in `initialize` (with `AppSettings.load` / `ProgressStore.load`).
3. A «التالي» → B; B «التالي» → C; C «ابدأ التعلّم» → save → 03. Round back button (B, C) and Android back → previous step;
   Android back on A leaves the app (normal behaviour).
4. No side rail, no top bar (prompt: the app is not open yet).

## Layout, measured on the dark references (u = 8.53 px; x from the screen centre 922 px unless said)
Measured with grid and ink boxes (`±5 px`). The three references were generated one by one and the **shared elements move
between them** (see Q1).

### Shared by the three steps
| Element | A | B | C | Plan |
|---|---|---|---|---|
| Emblem (splash `emblem.webp`) | 855–990 × 20–155 px: 15.8u, top 2.3u | 14.9u, top 2.1u | ≈ B | 15.8u, top 2.3u, centred, soft gold glow |
| Title, ink box | cy 22.6u, ink h 9.6u | cy 23.5u, 9.0u | cy 22.5u, 9.4u | cy 22.6u; size fitted to ink h 9.4u (≈ 8u, Readex 600, cream title gradient as 29) |
| Divider with diamond (`GoldDivider`) | y 29.1u, w 36.7u | 29.9u, 49.2u | 29.4u, 45.4u | y 29.3u, width = Q2 |
| Subtitle, ink box | cy 33.9u, ink h 4.5u | 35.9u | 34.8u | cy 34.6u (≈ 3.8u, weight 340) |
| Step dots | cy 91.7u | 89.3u | 89.9u | cy 90.5u; inactive 4.5×1.9u, active 7.7×1.9u, gap 2.1u, pills h/2; active = step (RTL: step 1 on the right) |
| Main button | 60–310 × 736–820 px: left 7.0u, 29.3×9.8u, cy 91.2u | 29.1×9.6u, cy 89.9u | 43.4×11.5u, cy 89.9u | app button of 10 (`LessonButton`, gold outline, dark fill, ‹ chevron); left 7.0u, h 9.8u, cy 90.5u; width 29.3u (C: by its text, Q1) |
| Round back button › | — | Ø 10.2u, right 5.4u, cy 89.9u | Ø 11.9u, right 6.6u | `LessonRoundButton` (glass button token), Ø 10.2u, right 5.4u, cy 90.5u |
| Mosque silhouette | 1465–1805 × 615–770 px | ≈ | 1520–1844 | `decor/mosque.webp` (dark) / `mosque_light.webp` (light), bottom right, w 40u, green glow behind (code gradient) |
| Top corner lattice | ≈ 0–300 and 1550–1844 × 0–220 px | | | `decor/corner_top_{left,right}.webp`, standard of 03 |
| Big arc + bottom waves | thin gold ellipse arc from (0, 35u) over the top to (216u, 35u); green + gold wave lines at the bottom | | | thin lines and gradients in code (as the gold wave of 12) |

### 30-A: name and avatar
| Element | Reference | Plan |
|---|---|---|
| Card | 423–1421 × 336–728 px: 117.0 × 46.0u, top 39.4u, centred, radius ≈ 3.5u; rim pale gold ≈ 3 px (#F5E78A core) + glow | gold card of 10/24 (`GoldCardPainter`), same box (Q3 rim) |
| «ما اسمك؟» | ink right 6.4u inside the card, cy 43.7u | Readex 600 ≈ 3.8u, cream |
| Name field | 474–1369 × 410–472 px: inset 6.0u, top 48.1u, h 7.3u, pill; rim ≈ 2 px #B8D498 | `TextField`, pill, glass rim (Q3); placeholder «اكتب اسمك» right 5.2u inside, cy 51.6u, dim cream |
| Separator | y 58.3u, inset 2.3u | 1 px line (glass rim colour) |
| «اختر صورتك» | cy 62.1u, right as the first label | as «ما اسمك؟» |
| Six avatars | Ø 15.0u, cy 73.9u, centres 17.6u apart, first centre 14.5u from the card's right edge | app avatars (Q4), round crop; unselected thin glass ring; selected: gold ring ≈ 0.5u + glow, as the ring of 29/11 |

### 30-B: level
| Element | Reference | Plan |
|---|---|---|
| Three cards | 355–708 / 746–1100 / 1135–1489 × 362–663 px: 41.4 × 35.3u, gap 4.5u, top 42.4u, radius ≈ 4.1u; rim ≈ 3 px #718B50 | option card (Q3), order right → left: مبتدئ، متوسط، متقدم |
| Glyph | box ≈ 9u, cy ≈ 50.4u | مبتدئ `glyphs/open_book.webp` (cream tint); متوسط star, متقدم rosette (Q5) |
| Level name | cy 59.9u, ink h 4.5u | Readex 600 ≈ 4.6u |
| Small divider | y 65.1u, w 32u, small diamond | `GoldDivider(diamond: 1.0)` |
| Line | cy 70.3u, ink h 4.0u | Readex 340 ≈ 3.4u |
| Selected (default مبتدئ) | rim ≈ 4–6 px #FFF8A4 / #BE992A, wide glow; check disc Ø 6.4u, 5.5u from the right, 5.3u from the top | selected rim (Q3) + check (gold ring + `glyphs/check.svg`) |

### 30-C: daily goal
| Element | Reference | Plan |
|---|---|---|
| Four cards | 201–536 / 570–905 / 937–1274 / 1308–1643 × 355–650 px: 39.3 × 34.6u, gap 3.9u, top 41.6u; rim ≈ 3 px #3A7C61 (not the same as B) | same option card as B (Q3), order right → left: 5، 10، 15، 20 |
| Stopwatch | ink 6.3 × 7.5u, cy 48.5u | **missing asset** (G1) |
| «10 دقائق» | cy 57.0u, ink h 5.4u, Latin digits | Readex 600 ≈ 5u |
| Small divider | y 62.3u | as B |
| Word (خفيف، منتظم، جاد، مكثف) | cy 67.5u, ink h 3.9u | Readex 340 ≈ 3.4u |
| Lattice band at the card bottom | ≈ 600–645 px | `reading/lattice_tile.webp`, faded (Q6) |
| Selected (default 10 دقائق) | as B; flame ≈ 6.4u, centre 6.6u from the card's left, cy 46.7u | as B + `icons/flame_gold_01.webp` (flame of 12) |

### Light theme
Same composition as dark (the light A card is drawn bigger, 390–1447 × 323–720 px: the plan keeps the dark box, as the
prompt asked «same composition»). Colours from the app's light lesson palette (`LessonPal` light of 08/10/24): cream
background, copper-brown title, tan rims, gold-filled main button (as the light 10). Emblem: the splash emblem has a
**transparent centre** (the light reference shows it green): Q7. Light A title reads «رتل» without the shadda: the app writes
«رتّل» in both themes.

## Texts (from the references = the approved prompt)
A «أهلاً بك في رتّل» / «لنتعرّف عليك قبل أن نبدأ» / «ما اسمك؟» / «اكتب اسمك» / «اختر صورتك» / «التالي».
B «ما مستواك في التجويد؟» / «سنقترح عليك البداية المناسبة» / مبتدئ «أبدأ من الصفر» / متوسط «أعرف بعض الأحكام» / متقدم
«أريد المراجعة والإتقان». C «ما هدفك اليومي؟» / «يمكنك تغييره لاحقاً من الإعدادات» / 5 دقائق خفيف / 10 دقائق منتظم /
15 دقيقة جاد / 20 دقيقة مكثف / «ابدأ التعلّم».

## States and motion (no endless animation: PERFORMANCE.md)
- Defaults as the references: first avatar, «مبتدئ», «10 دقائق». Empty name: Q8.
- Step change: the card(s), title and subtitle slide out / in sideways (next step comes from the left, RTL) with a fade,
  ≈ 350 ms; emblem, background, dots and buttons stay still; the active dot stretches 4.5 → 7.7u.
- Selection: rim to gold and glow fade 200 ms, check pops (scale 0.6 → 1), flame of C fades in on the selected card; tap
  haptic + the app's tap sound if sounds are on.
- Avatar: gold ring + glow on the chosen one.
- Keyboard: in landscape it covers about half of the phone: while the field has focus the whole content slides up so the
  field sits under the top edge (emblem and title go off-screen), back down when the keyboard closes. To check on the phone.
- First entry after the splash: emblem, title and card rise in (one controller, ≈ 500 ms).
- `RepaintBoundary` around the background (arc, lattice, mosque) and each card.

## Data: where it is saved, how it changes later
- New `lib/core/user_profile.dart`: `UserProfile` with `name`, `avatar` (1–10), `level` (0–2), `goalMinutes` (5/10/15/20),
  `onboarded`; one JSON value `profile.v1` in shared_preferences (as `progress.v1`), read at start-up.
- **Profile 29** reads name and avatar from `UserProfile` (today the mock leaderboard user); `userStartLevel` becomes the
  chosen level. City, points, lessons, rank and streak stay mock (BACKLOG).
- **Settings 23** (the subtitle of C promises it): a row «الهدف اليومي» with the four values (same picker as the reciter).
- Edit name / avatar (BACKLOG item of 29): Q9.
- «إعادة ضبط التقدم» does not delete the profile (proposal).
- Review aids: `?onboarding=1` (force), `?step=a|b|c`, `?theme=light`.

## Code vs assets
- Code: background gradient, big arc and bottom waves, cards, rims, glows, field, separator, step dots, check disc, layout,
  motion. Reused code: `GoldCardPainter`, `LessonButton`, `LessonRoundButton`, `GoldDivider`, `LessonPal`.
- Library assets reused: `splash/emblem.webp`, `leaderboard/avatar_*.webp`, `decor/mosque.webp`, `decor/mosque_light.webp`,
  `decor/corner_top_{left,right}.webp`, `glyphs/open_book.webp`, `glyphs/check.svg`, `icons/flame_gold_01.webp`,
  `reading/lattice_tile.webp`.
- **Missing** (ChatGPT, `prompts/30-onboarding/images-v1.txt`): G1 stopwatch (C); G2 outline star and G3 outline rosette (B)
  only if the owner picks them in Q5.

## Open questions for the owner
- **Q1** Shared elements move between the three references (title ±1u, dots 89.3–91.7u, button 89.9–91.2u, back button Ø
  10.2 vs 11.9u, C button taller 11.5u). Proposal: one place for all steps (table above) so nothing jumps on a step change;
  the C button only wider (its text), same height.
- **Q2** Divider width: the references use 36.7 / 49.2 / 45.4u. Proposal: one width 45u for all.
- **Q3 Token conflicts** (DESIGN-SYSTEM): (a) card A rim ≈ 3 px pale gold + glow vs the gold card of 10/24
  (`GoldCardPainter`, rim 0.35u); (b) option cards rim ≈ 3 px #718B50 (B) / #3A7C61 (C) vs glass tile rim 2 px #1C4E38 ✅;
  (c) selected rim ≈ 4–6 px #FFF8A4 + wide glow vs selected token 1.2 px #DAA42A + 1 px #FFDA6B, glow 15% ✅; (d) field rim
  ≈ 2 px #B8D498: no token (proposal: glass rim token); (e) step dots: no token (proposal: active `amberPill` #EDB120,
  inactive `cardRimTop` #2F6954). Proposal: keep the app tokens in all five, with one rim colour for B and C.
- **Q4 Avatars**: the references show children with faces on a green circle; the library has 10 adult avatars, faceless, on
  yellow (`leaderboard/avatar_1…10`). Which 6, in which order? Proposal (right → left): 6 (white cap), 4, 2, 5, 3, 7
  (man / woman alternating, as the reference). Or a new avatar set (ChatGPT) if the owner wants the reference's children.
- **Q5** Level glyphs: library has `open_book` (outline, as the reference), `star.svg` (filled) and `rank_rosette` (gold,
  filled); the reference has a cream outline star and rosette. Use the existing ones, or generate G2 + G3?
- **Q6** Lattice band at the card bottom: dark C has it, dark A/B do not, light A/B/C have it. Proposal: on every card (A,
  B, C) in both themes.
- **Q7** Light emblem: the splash emblem is transparent inside (shows cream on the light background; the reference fills it
  green). Proposal: a green disc behind it in code, or a light emblem from ChatGPT.
- **Q8** Empty name: «التالي» dimmed and disabled until a name is written (proposal; max 20 characters, trimmed)?
- **Q9** How to change name / avatar / level later: proposal: settings row «الملف الشخصي» → 29, and on 29 a tap on the
  identity card reopens step A prefilled with «حفظ» instead of «التالي» (new text, not in the references).
- **Q10** Light/dark toggle (CLAUDE.md: always present): the references have none. Proposal: the small moon button of 10,
  top left. Or no toggle on the first start (the app starts dark).
- **Q11** (suggestion) The user's row in the mock leaderboard 11 shows the chosen name and avatar too.

## Owner's answers (2026-11-28)
Q1 yes (one place for the shared elements) · Q2 yes (divider 45u) · Q3 **app tokens** · Q4 avatars 6, 4, 2, 5, 3, 7 ·
Q5 use the library's glyphs; the owner generated the stopwatch (G1) in the **white icon set** (`ASSETS.md`) · Q6 lattice band
on every card · Q7 show examples first · Q8 yes · Q9 ok · Q10 ok (moon of 10) · Q11 yes.

## Build v1 (2026-11-28)
- `lib/onboarding/onboarding_screen.dart` (`OnbMetrics` = the tables above), `lib/core/user_profile.dart` (`profile.v1`),
  `_Root` in `main.dart` (onboarding after the splash while not completed), tests `test/onboarding_test.dart`.
- **Tokens (Q3):** card A = gold card of 10 (`GoldCardPainter` with the 10 fill); option cards, field and avatar rings = the
  option rows of 10 (`testRow*` idle, `testSel*` selected, rim 0.3u, glow 28%), radius = tile token 3.0u; step dots
  `amberPill` / `cardRimTop` (light `testLSelRim` / `readLDotOff`); main button `LessonButton` of 10 (light: filled gold);
  round back button `LessonRoundButton`; light palette = the lesson light palette (`LessonPal`).
- **Background:** `LessonBackground` of 08/10 (gradient + stepped-lattice corners, both themes: replaces the dark-only
  `corner_top_*` of the plan), thin arc and waves in code, `decor/mosque.webp` (lesson tone) / `mosque_light.webp`.
- Glyphs: `icons_white/open_book` (مبتدئ), `glyphs/star.svg` cream (متوسط), `glyphs/rank_rosette` gold as it is (متقدم),
  `icons_white/stopwatch`, `icons_white/checkmark` (check disc), `icons_white/chevron_right` (back button),
  `icons/flame_gold_01` (selected goal).
- **Light emblem (Q7):** `splash/emblem_inner.webp` = the emblem's inner area (mask derived from the emblem's gold outline,
  `ASSETS.md`), tinted in code. Variants for the owner: `?emblemL=green` (default, #0B5A2B sampled on the light
  reference), `dark` (`readBgCentre`), `none` (as the splash).
- Settings 23: row «الهدف اليومي» (stopwatch, pill + picker of the four goals). Profile 29: name, avatar and level from
  `UserProfile`; a tap on the identity card opens step A in edit mode («حفظ», back ›). Leaderboard 11: the user's row
  shows the chosen name and avatar.
- Digits: «10 دقائق» is written number first (Arabic order) and renders as the reference.
- Review: `?onboarding=1` (does not read or write the saved profile), `?step=b|c`, `?theme=light`, `?emblemL=`;
  captures `tools/flutter-review/onboarding-capture.js`.

## v2 (2026-11-28): owner's rosettes and «more elegant» decor
Owner: use the two outline rosettes (cream / brown); the reference looks more elegant, find why. Measured on
`reference-b-level-dark` vs the v1 capture, the differences that are **decor, not tokens**, now fixed:
- **Big arc:** reference solid gold #C49100 ≈ 0.8u wide; v1 was #776E2A 0.24u, faded. Now `onbArc` #C99300, 0.75u, soft
  glow (light: copper 0.4u).
- **Top corners:** reference fine gold 8-point-star lattice; v1 had the lesson stepped lattice (big, dim). Now the library's
  star lattice `decor/lattice_star_tile.webp` (A5), cell 5.3u, tinted gold (light: tan), radial fade.
- **Mosque:** reference dark silhouette (#013624) in front of a bright green glow (#03623B); v1 was light green (#225134)
  with a weak glow. Now `onbMosque` #02331F (srcIn on `decor/mosque.webp`) and `onbMosqueGlow` 55%.
- متقدم glyph: the owner's rosette, `icons_white/rosette_cream` (dark) / `rosette_brown` (light).
Differences left because they are **token conflicts** (Q3 = app tokens, owner to decide if they should change):
selected card rim ≈ 4–6 px neon gold #FFF8A4 + wide glow (token 0.3u `testSelRim`, glow 28%); selected fill dark #013921
(token `testSelTop` #214E2D, lighter olive); idle cards lit from the top #014928 → #013622 with an olive rim #718B50 (token
flat `testRowFill` #0B3A2A, rim #70A685 → #498163). Also the متوسط star is filled (the library has no outline star).
Sheet `30-onboarding/compare-v2.jpg`.

## v3 (2026-11-28): «as the reference» (owner)
Owner: «we must reach the reference almost identically, unless something is an app standard used elsewhere». Values
sampled on the six references (dark and light) are now the screen's own `onb*` tokens (`rateel_theme.dart`): card A fill,
name field (fill, pale green rim), separator (light line over a dark one), avatar rings (idle pale, chosen thick gold +
glow), level / goal cards (idle glass lit from the top with an olive rim; selected bright-core gold rim with glow outside and
inside; light: cream / tan, warm fill, gold rim), check disc, step dots, emblem glow.
Kept as app standards: emblem, avatars, `LessonButton`, `LessonRoundButton`, the gold card painter of 08/10 (card A rim),
Readex Pro and the title colours, the mosque of the library (tinted dark).
Owner's new assets (common library, `ASSETS.md`): outline star and open book, cream (dark) and brown (light); gold lattice
corner (left; right = mirror until the owner's right file arrives). Sheet `30-onboarding/compare-v3.jpg`.
Waiting for files: the owner's right corner, light corner and light mosque were shown in the chat but not received as files.

## v4 (2026-11-28): critic v1 items
Critic v1 (`30-onboarding/critic-v1.md`, scores 6.0–7.0) and its finding: the approved **splash background of 01**
(`splash/background.webp`) is the reference's whole decor (star-lattice corners, arc fading at its ends, swoosh, mosque
skyline, glow). Being an app standard, it is now the dark background (S1–S3, mosque). Light keeps the code decor (arc gold
#C99761 fading at its ends, star lattice A5, mosque A6) until a light version of the splash background exists (ChatGPT
prompt `prompts/30-onboarding/images-v2.txt`).
Fixed: separator drawn (A1: the `Column` had no stretch), subtitle 3.9u weight 440 (S4), chosen avatar with a dark gap
0.8u (A2), selected rim outer band 0.4u `onbSelOuter` + warm olive inner glow (B1, C2), rosette 8.2×9.5u (B2), teal idle goal
cards `onbTeal*` (C1), goal number 5.5u and word 4.4u (C3), emblem halo ≈ 8u (S8). Sheet `30-onboarding/compare-v4.jpg`.
Left for the owner (app standards): light body text = `LessonPal` ink (reference warm brown #52320B), light title copper
(reference #633D11), `GoldDivider`, `flame_gold_01`, buttons.

