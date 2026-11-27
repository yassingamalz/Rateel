# Screen 13: achievements (الإنجازات), the page with the levels

Branch: `flutter/13-achievements` (session branch `claude/flutter-13-achievements-xa7myj`), from `master` a20159c (27 badges merged, PR #59).
Reference (visual only): `13-achievements/reference.webp` (= `ref-13-traguardi.png` of 27; original `13-traguardi.webp` on
`lesson-production`), 1844×853. Angular origin: `src/app/features/gamification/achievements/` (+ `services/gamification.service.ts`).
**Status (2026-11-27): plan v1, waiting for the owner's yes.** No visual work started.

13 is the page of the rail item «الإنجازات». It shows the **points**, the **level with its progress bar**, **4 tabs**
(الإنجازات / الأوسمة / النقاط / المجموعة) and, in the first tab, a **carousel of achievement cards**. **27 (badges) is part of 13**:
it opens from the tab «الأوسمة». Until 13 is built the rail opens 27; with 13 the rail opens 13 (`DECISIONS.md` 2026-11-27).

## 1. What the Angular app does (source of the data; the reference is only visual)
| Part | Angular behaviour |
|---|---|
| Points | `getUserScore()`, shown in a circle with a star, label «النقاط». Mock: random 500–1500 (`generateMockData`). |
| Level | `1 + floor(sqrt(points / 100))`, cap 99. Level 2 at 100 pts, 3 at 400, 4 at 900, … Label «المستوى». |
| «n التالي» | `(level+1)² · 100 − points`. **Bug**: at 511 pts the level is 3 and shows «1089 التالي», but level 4 starts at 900 (389 pts away). The reference copies the bug (Q2). |
| Progress bar | `unlocked achievements / total achievements` (2 of 5 = 40 %), **not** the level progress (Q1). The reference shows ≈ 53 %. |
| Tabs | الإنجازات `all` (carousel of achievement cards) · الأوسمة `badges` (3 categories, becomes **27**) · النقاط `points` (summary earned / bonus / spent + activity cards) · المجموعة `collection` (grid of badges with rarity). Swipe changes tab. |
| Achievement card | emblem, title, **not earned**: progress bar + «n %»; **earned**: «مكتمل ✓»; points pill «★ n». Tap opens a detail modal (description, progress, date, share). |
| Carousel | arrows, dots, swipe; 3 cards per page in Angular (the reference shows 2, 3 dots: 5 achievements / 2 = 3 pages). |
| Achievements (5, mock) | بداية الرحلة bronze 50 (5 lessons, earned) · متقن القراءة silver 100 (10 lessons, earned) · حافظ النص gold 200 (all lessons of the basic course, 70 %) · المتفوق platinum 300 (full marks in 5 tests, 40 %) · سيد التجويد diamond 500 (all courses, 0 %). |
| Rarity | bronze → common, silver → uncommon, gold → rare, platinum → epic, diamond → legendary (used by المجموعة). |

## 2. Layout (measured by eye on the reference; exact numbers come from `measure.py` at build time)
Content area x 0–1665, rail from 1665 (the approved rail, unchanged). u = 8.53 px = 1 % of the height (1844×853).
| Element | Reference px | u |
|---|---|---|
| Header panel, gold rim, arch bump at the top centre with the mosque skyline + crescent | x 25–1625, y 108–278 (arch to y 0) | 187.6 × 19.9 |
| Points medal: gold ring, laurel branches, star disc at the bottom, number inside, label «النقاط» below; **points on the left, level on the right** (as the reference) | centre (203, 128), Ø ≈ 190, laurel 252 wide | 22.3 / 29.5 |
| Level emblem (eight-pointed star, number inside), «المستوى» below, «n التالي» in gold below that | centre (1515, 108), ≈ 130; labels y 198 and 242 | 15.2; 3.8 / 2.9 |
| Progress bar: dark track with rim, gold fill from the **right** (RTL) | x 380–1400, y 180–207, fill ≈ 53 % | 119.6 × 3.2 |
| Tab bar (glass pill, dividers) | x 93–1585, y 306–404 | 175 × 11.5 |
| Active tab: gold pill with trophy + label | x 1197–1585, y 306–402 | 45.5 × 11.3 |
| Achievement card | 654 × 314; right card x 871–1517, left x 159–813, y 449–763; gap 58 | 76.7 × 36.8; gap 6.8 |
| Card green strip (earned) | 16 px on the **left** edge, full height | 1.9 |
| Card emblem (gold arch frame + picture) | ≈ 165 × 162, top centre | 19.3 × 19 |
| Card title (cream) | ≈ 42 px glyph, y 640 | 4.9 |
| Pills «★ 100» and «مكتمل ✓» | y 680–740; 154 and 210 wide | 7 tall; 18 / 24.6 |
| Arrow buttons (glass, ‹ at the left = next, › at the right = previous) | centres (83, 597) and (1591, 597), Ø 80 | 9.4 |
| Dots (active gold, first page at the **right**) | y 807, pitch 39, Ø ≈ 20 | 2.3 |

Everything fits in one screen (no vertical scroll). Phone 915×412: same layout in u; tap targets ≥ 48 dp; check at text size 110 %.

## 3. States
- **Header:** level and next-level points from the points (Q2); bar from Q1; level 99 → «المستوى الأقصى», bar full.
- **Tabs:** one selected (gold pill, glides to the tapped tab); swipe left/right changes tab; content cross-fades (Angular: scale 0.95 → 1, 400 ms).
- **Card earned:** green strip, «مكتمل ✓» pill, full colour. **Card in progress:** no strip, progress bar + «n %» in place of the pill, emblem dimmed and desaturated as the locked medals of 27 (0.35 / 0.6), small padlock. **Card tap:** detail sheet (Q7).
- **Carousel:** page 0 at the right; arrows disabled (dimmed) at the ends; dots; drag with finger/mouse.
- **Tab الأوسمة:** opens 27 (Q8). **النقاط:** summary + activity cards (Q5). **المجموعة:** grid with rarity (Q4).
- **Level up** (points cross a level threshold, review aid `?points=`): short gold burst on the level emblem, the number rolls up, `Sounds.passed` + `Haptics.success` (same piece as the badge celebration of 27).

## 4. Motion (proposal, as 11 and 27; no endless animation, `PERFORMANCE.md`)
- Entry: header panel fades and rises, **points count up** 0 → value (700 ms easeOut), the **bar fills** to its value (900 ms easeOutCubic), tabs fade, cards pop in staggered (60 ms, 1.2u rise + fade), dots last.
- Tab change: gold pill glides (as the 04 selection), `Haptics.tap`, content cross-fade.
- Carousel: `PageView`-like drag with snap; arrows and dots animate the page (350 ms easeInOutCubic); card tap = press scale 0.98.
- One controller per small `AnimatedBuilder`; `RepaintBoundary` on the header, the tab bar and each card; no blur on live content.

## 5. Code, reused pieces, new assets
| Element | Source |
|---|---|
| Header panel, arch bump, mosque skyline, crescent | **reuse** 03 pieces: `ui/decor/header_arch.svg`, `mosque.webp`, `crescent_star.svg`; gold rim = `GoldRimPainter` of 11 |
| Background, girih / lattice, corner ornaments | **reuse** 03/11 background (`bgTop → bgBottom`) + `girih_tile.svg` tint (the reference has a faint carved lattice all over) |
| Progress bar | **reuse** 27 `_ProgressBar` / 03 progress token (moved to a shared widget, same look) |
| Tab bar, active pill | code, glass token + gold fill (as the 11 tabs) |
| Tab icons: trophy, medal, book | **reuse** `ui/nav/leaderboard.svg`, `ui/nav/achievements.svg`, `ui/leaderboard/book.webp` or `nav/quran.svg` (cream, `currentColor`) |
| Tab icon: coins | code (3 stacked ellipses, one glyph painter) or `coins_gold.webp` of 11 (owner's choice at review) |
| Cards: fill, rim, radius, pills, green strip | code, card token of 03 + rim tokens; completed green from 10's «correct» green if it matches, else a new token (tell the owner) |
| Star in the pills | **reuse** `ui/glyphs/star.svg` (as 11) |
| Check ring, padlock, burst, selection glow, divider, reward box | **reuse** 27 painters (`_CheckRingPainter`, `_BurstPainter`, `kitPadlock`, `_Divider`, `_RewardBox`), promoted to shared widgets |
| Arrow buttons, dots | code (glass button token of 02/11, chevron painter of 11) |
| Level emblem (eight-pointed star) | **new asset P2** (ChatGPT), number drawn in code. Fallback: code painter (two rotated squares, gold rim) |
| Points medal (gold ring + laurel + star disc) | **new asset P1** (ChatGPT), number drawn in code |
| Card emblems ×5 (gold arch frame + picture) | **new assets C1–C5** (ChatGPT); the dimmed in-progress state is done in code |
| Level, points, bar, titles, descriptions | from the app data (Angular service), never from the reference |

Prompts: `docs/flutter/prompts/13-achievements/images-v1.txt` (also pasted in the chat). Attach the **app screenshots**
(`docs/flutter/app-references/`: 03, 11, 12, 27) as the style, the old reference only for the layout idea.

## 6. Conflicts with the confirmed tokens (owner decides; registered in `STYLE-CONFLICTS.md` when built)
| # | What | Token | Reference | Proposal |
|---|---|---|---|---|
| N1 | Header panel and tab bar rim | gold rim 1.2 px + 1 px, glow 15 % | ≈ 3 px gold, soft glow | as 11: reference values (owner chose them for 11) |
| N2 | Active tab | flat amber | vertical gold gradient | as 11 K3: flat `amber` + gold rim |
| N3 | «Earned» green (strip, pill, check) | none confirmed | bright green ≈ #22C55E | 10's «correct» green if close, else one new token `doneGreen` |
| N4 | Card fill | `cardTop → cardMid` (03) | dark green with a faint lattice | token + `card_pattern` tint |

## 7. Questions for the owner (recommendation first)
1. **Progress bar**: level progress (points between this level and the next), or unlocked / total achievements as Angular? *Recommended: level progress*: the bar sits between the level and «التالي».
2. **«n التالي» bug**: Angular shows 1089 at 511 pts, but level 4 starts at 900. *Recommended: fix it* (level L starts at (L−1)²·100, next = L²·100 − points → **389**) and say so in the docs; or keep 1089 as the reference.
3. **Two lists of achievements**: Angular has 5 achievements (13 cards), 27 has 12 badges (invented by Claude); three overlap (بداية الرحلة 5 lessons, المتفوق, سيد التجويد) with different rewards. *Recommended: keep both lists; the 13 cards follow Angular; the three overlapping ones become the same event with the same reward (paid once)*. Alternative: drop M01 / M11 / M12 from 27.
4. **Tab المجموعة**: *recommended: build it as Angular* (grid of all 5 achievements + 12 badges with rarity common → legendary, padlock when locked, tap = detail), reusing the 27 tile. Or «coming soon» for now.
5. **Tab النقاط** (this is also screen 26, points history): *recommended: build it now with a mock ledger* (earned / bonus / spent totals + activity cards, Angular titles) and a small shared points ledger `userPoints` (start at 511, as the leaderboard user), so that 11, 22 (+10), 27 (rewards) and 13 read one number. Or «coming soon».
6. **Points of the demo**: start at **511 / level 3** (matches the reference and the leaderboard user) as a mock; real progress later (BACKLOG). OK?
7. **Detail of a card** (not in the reference): *recommended: a sheet over the page* with the big emblem, description, progress, reward, date earned (Angular modal), **without the share button** (needs a plugin → BACKLOG).
8. **How الأوسمة opens 27**: the 27 screen needs the full height (4-column grid + detail panel), the area under the tabs is only 45u. *Recommended: the tab opens 27 full screen* (as 12 opens from 03); back = the same way back as 12 (swipe / Android back / tap «الإنجازات» in the rail), and 13 reopens on that tab. Alternative: shrink 27 inside the area (loses the approved layout).
9. **Tier look**: should the card frame change with the tier (bronze, silver, gold, platinum, diamond) so the next card looks different, as you asked for the badges? *Recommended: yes, subtle metal tint on the arch frame* (3 more prompt variants later); or all gold as the reference.
10. **Level-up celebration** and **count-up / bar-fill entry** (section 4): OK?
11. **Conflicts N1–N4** (section 6): accept the proposals?

## 8. Plan of the work (after the owner's yes)
1. Shared points ledger + level maths (`lib/gamification/`), unit tests for the formula (levels, next points, cap 99).
2. Promote the reusable 27 / 11 pieces to shared widgets (no visual change) and run the 27 tests.
3. Screen 13: header, tabs, carousel, card, detail sheet; hook the rail (`section 4 → 13`), 27 from the tab; review aids `?section=4`, `?achTab=`, `?points=`.
4. Placeholders from the owner's assets (P1, P2, C1–C5) until they arrive; tabs النقاط / المجموعة (per Q4–Q5).
5. Capture at 1844×853 and 915×412, number checks, then **ask the owner before the critic** (phone 915×412 only), APK when asked.
