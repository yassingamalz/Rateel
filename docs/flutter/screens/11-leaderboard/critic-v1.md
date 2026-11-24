# Screen 11 (leaderboard): critic v1 (phone only)

Scope (owner, 2026-11-24): **phone 915×412 dp** (dpr 2.625). Captures `capture-v2-{start,me,friends,region}-phone.png`
(2402×1082) vs `reference.webp` (1844×853). All values in **u = 1% of the screen height** (reference 8.53 px/u,
phone capture 10.82 px/u = 4.12 dp/u). The phone is wider than the reference (content right edge, CR, at 203.6u vs
195.2u), so right-anchored elements are compared from CR, left-anchored ones from the screen/panel left edge.
Colours sampled from pixels (scripts in the session scratchpad: `m.py`, `circ.py`, `txt.py`, `base.py`).
Not scored: owner decisions ✅ (arched title 2026-11-24; filters / rows 4+ / pinned bar as Angular; Angular medals
and avatars; mock data) and conflicts K1–K6 (`STYLE-CONFLICTS.md`), listed in section 5.

## 1. Scores
| | Score |
|---|---|
| Look (fidelity to the reference, phone) | **7.4 / 10** |
| Behaviour (filters, pinned bar, scroll, motion, tap targets) | **8.4 / 10** |
| Overall | **7.7 / 10** |

The geometry is close (panel, bar, tabs, avatars, medals, gold disc within 0.1–0.5u). What separates it from the
reference: text vertical positions (header labels, names, title), the type styles not taken from the app's scale,
the darker avatar rims, the small star, the row pitch, the lattice/ribbon brightness and the tab tap width.

## 2. Owner's checks

### 2.1 Brightness of the round elements (reference vs Flutter)
| Element | Reference | Flutter | Δ | Verdict |
|---|---|---|---|---|
| Avatar gold rim | top #FEFEC6 (L 250), sides #F6C548 / #FBDF6E (L 201 / 220), bottom #FEE670 (L 226); width ≈ 0.6u | top #FED96A (L 218), sides #EDBF4B (L 192), bottom #DAA42A (L 170); width 0.45u | −10 … −56 L, darkest at the bottom | **medium** (A6) |
| Avatar fill / art | #FDC001 | #FCC302 | 0 | ok (same asset) |
| Avatar Ø | 11.0u | 10.7u | −0.3u | ok |
| Medal 1st (mean of the ink) | #EEB342 L 184, 8.4×10.9u | #F3BB42 L 190, 8.1×10.8u | +6 L | ok |
| Medal 2nd | #BAA8A9 L 172 | #C8B6B5 L 186 | +14 L | low |
| Gold rank disc «15» fill | #EEB020…#F1B624 (L ≈ 180), pale top highlight #FCE77D ≈ 0.3u, darker lower edge #DCA82B | flat #E2A51E (L 168), no highlight | −12 L, flat | conflict **K6** (logged) |
| Gold disc Ø / centre | 9.26u, 24.6u from CR, y 85.1u | 9.33u, 24.6u, y 85.1u | 0 | ok |
| Chevron button ring | 0.5u, #FCD441/#FFDC4A (L ≈ 210), lit #F0E16D at the top → #E3B938 bottom | 0.2u #D8C35A (L 191) | thinner, dimmer | new conflict **K8** (glass-button token) |
| Chevron button interior | dark green, #1D5722 at the edge → #0B3818 centre (L ≈ 50) | gold radial 8 → 24 %: #345822 edge → #1D4C22 centre (L ≈ 73) | +23 L, olive | part of **K8** |
| Chevron glyph | pale gold-cream #F4E897/#FAED9C, stroke ≈ 0.75u, 4.0 × 2.4u | #FFFDF5, stroke 0.5u, 3.9 × 2.2u | whiter, thinner | low (A20) |
| Rank discs rows 4+ (no reference) | – | rim 0.23u #205440 (L ≈ 70) on #023126 (L ≈ 40): contrast 1.5:1, the disc barely reads | – | low (A17) |
| Star (points) | #EAAE1F L 177, ink 4.9 × 4.6u | #EDBF3D L 192, ink **3.9 × 3.7u** | lighter, 20 % smaller | size **medium** (A5), colour low |
| Coins gold / silver | #E7B732 L 184, 6.2×6.1u / #C1C3C1 L 195 | #E6B617 L 181, 6.3×6.0u / #B9C1C8 L 193 | ≈ 0 | ok |

### 2.2 Fonts against the reference and against the app's type scale
App type scale found in the approved screens: screen title = titleTop → titleBottom gradient + `titleShadows`, w530
(03, 9.3u) / w560 (05, 7.5u); card title = `titleCream` w560 + `titleShadows` (03: 4.4u, 5.3u; 05 unit circle
4.6–4.9u); secondary line = `label` w400 3.0u (05, 06); nav label = `label` w340 4.0u; count text = `countText` w700;
badge text = w600 3.8u (05 only). **Weights 600 and 500 for cream text and «label 75 %» do not exist elsewhere.**

| Text | Reference (ink, measured) | Flutter (code / ink) | App style it should use | Severity |
|---|---|---|---|---|
| Title المتصدرين | ink 32.1 × 6.45u, stroke 0.70u, #FDF5BC with soft shadow | 5.9u **w600** solid titleCream + shadows; ink 28.3 × 6.3u, stroke 0.83u, ink area 57 vs 45 u² (26 % heavier) | screen title: gradient titleTop→titleBottom, w560 | **medium** (A7) |
| Header المركز المستخدم / النقاط / المكافآت | ink widths 35.8 / 12.3 / 17.1u, stroke 0.59u, #FDFBDB | 4.0u **w600** + shadows; widths 29.9 / 10.7 / 15.7u (83–92 %), stroke 0.55u | card title 4.4u w560 + titleShadows (as the 03 card title) | **medium** (A2) |
| Names | widths 22.5 / 16.5 / 28.7u, stroke 0.47u | 3.8u **w500**; widths 22.0 / 16.5 / 27.2u, stroke 0.46u | card-title weight w560 (keep 3.8u) | low (A12) |
| «n درس» | width 11.7u, #DCDAC9 (warm light grey, L ≈ 218) | 3.1u w400 `label` 75 %: 10.8u, #C0CAC2 (greenish, L ≈ 199) | secondary line `label` w400, 3.3u, alpha 0.85 | low (A13) |
| Points «1406» | 10.1 × 3.3u, stroke 0.59u | 4.4u **w600**: 10.3 × 3.2u, stroke 0.74u (25 % heavier) | card title 4.4u w560 | low (A12) |
| Rewards «10K» | 7.3 × 2.9u | 4.2u **w600**: 7.8 × 3.05u (+7 %) | card title w560, 4.0u | low (A12) |
| Rank «15» (gold disc) | 4.3 × 3.05u, #0B2315 | 4.0u w700 countText: 4.1 × 2.9u (94 %) | count text w700 ✔, 4.2u | low (A14) |
| Tab labels | (reference text is garbled) glyph body ≈ 3.2u thick | 4.0u **w600**: body 3.5u | card-title weight w560, 3.6u; active = countText ✔ | low (A15) |
| Rank numbers rows 4+ | – | 3.6u **w600** titleCream | w560 | low (A12) |
| Cream colour | #FDFBDB (names, headers) | titleCream #FAF1D8 | titleCream (token) – keep | conflict note K9 |

### 2.3 Text positioning
Optical baseline = row of maximum ink of the Arabic strokes; row centres taken from the medal / disc centres
(reference rows 40.8u, 58.0u, bar 85.1u; Flutter 41.2u, 58.8u, 85.1u).

| Text | Reference | Flutter | Δ | Severity |
|---|---|---|---|---|
| Header labels baseline | 26.73 / 26.85 / 26.85u | 25.69 / 25.60 / 25.69u | **FL 1.15u too high** (header band 18.4–31.8u in both) | **medium** (A1) |
| Header horizontal | user right edge 20.2u from CR; النقاط centre 37.5u, المكافآت 14.1u from panel left | 20.2u; 37.3u; 13.9u | ≤ 0.2u | ok |
| Header over its column | النقاط centre 41.7u vs star+number group centre 40.7u (from screen left) | 41.7u vs 42.3u | group 1.6u to the right of ref (star) | covered by A5 |
| Name baseline vs row centre | −2.11 (row 1), −2.99 (row 2), −2.58 (bar) | −1.02, −1.07, −1.15 | **FL names 1.1–1.9u too low** | **medium** (A3) |
| «n درس» baseline vs row centre | +4.33, +3.87 (bar) | +3.79, +3.75 | −0.1 … −0.5u | ok |
| Name → «n درس» baseline distance | 6.44u (row 1), 6.45u (bar) | 4.81u, 4.90u | **−1.6u** | **medium** (A3) |
| Points / rewards ink centre vs row centre | +0.3 / +0.35u | +0.1 / 0.0u | ≤ 0.3u | ok |
| «15» in the disc | ink centre −0.06u / +0.18u from disc centre | −0.13u / 0.0u | ok | ok |
| Title in the ribbon band (band 4.3–13.2u in both) | ink centre 9.03u, baseline 9.96u | ink centre 10.67u, baseline 11.0u | **FL 1.0–1.6u too low** | **medium** (A7) |
| Tab labels | – (garbled) | ink centre 0.1–0.4u left of the tab centre, vertical centre ±0.1u | – | ok |
| Name right edge | 49.2u from CR | 49.8u | 0.6u further left | low (A18) |
| Points number left edge (from row left) | 33.8u | 34.6u | +0.8u | covered by A5 |
| Rewards group (from panel left) | text 6.6u, coins centre 18.1u | 7.0u, 18.8u | +0.4…0.7u | low (A18) |

## 3. Region by region (phone)

| # | Region / element | Reference | Flutter | Sev. | Type | Fix |
|---|---|---|---|---|---|---|
| A1 | Header labels vertical | baseline 26.8u | 25.65u (1.15u high) | **medium** | code | `leaderboard_screen.dart` `_Header`: wrap the three label Texts in `Transform.translate(offset: Offset(0, u * 1.15))` (or `top: u * 1.5, bottom: 0` instead of `top: 0, bottom: u * 0.8`) |
| A2 | Header label style | bold, ≈ 12 % wider ink than FL | 4.0u w600 | **medium** | code | `_Header` style → `readex(u * 4.4, weight: 560, color: titleCream).copyWith(shadows: titleShadows(u))` (course-card title style) |
| A3 | Name / lessons block | name baseline 2.6u above the row centre, 6.45u above the lessons baseline | 1.1u above, 4.85u | **medium** | code | `_RowContent`: `SizedBox(height: u * 0.6)` → `u * 2.2` (the centred block then moves the name ≈ 0.8u up and the lessons ≈ 0.8u down: name −1.9u, lessons +4.6u) |
| A4 | Row pitch and first row | rows 16.4u high, **gap ≈ 0.5u**, first row 0.3u under the divider (row 1 top 32.6u), row 2 bottom edge 66.35u | gap 1.2u, first row 1.3u under the divider (33.2u); row centres +0.4u (row 1), +0.9u (row 2), row 3 +1.3u | **medium** | code | `_Metrics.rowGap` 1.2u → 0.5u, and a separate `listTop = u * 0.3` for the first row (`_list` top, `_checkMe`, `_scrollToMe` use `listTop + i * pitch`) |
| A5 | Star size and points column | star ink 4.9 × 4.6u, centre 29.4u from the row's left edge, number starts 33.8u (gap 1.95u) | star ink 3.9 × 3.7u, centre 30.5u, number 34.6u | **medium** | code | `_Points`: star box 5.2u → **6.6u**, gap 1.0u → 1.1u; `pointsCx` 36.3u → 35.0u (rows) and 35.2u → 33.9u (bar). Better: anchor the star at a fixed left (29.4u) and left-align the number, so different scores keep one column |
| A6 | Avatar rim | bright all round (top #FEFEC6, sides #F6C548/#FBDF6E, bottom #FEE670), ≈ 0.6u, dark contact line #0B210D outside | goldHighlight → goldEdge, bottom #DAA42A, 0.45u | **medium** | code | `_Avatar`: rim `u * 0.55`; gradient lit top and bottom as the approved 05 unit ring: `[RateelColors.unitRingLockedTop, RateelColors.unitRingSide, RateelColors.unitRingTopBottom]`, stops `[0, 0.5, 1]` (L 220 / 190 / 210) |
| A7 | Title in the ribbon | ink centre 9.0u (0.3u under the band centre), stroke 0.70u | 10.7u (2.0u under), w600 solid | **medium** | code | `_ArchedTitle`: `cy = size.height * 0.48 - u * 1.6`; style = screen-title style: `readex(u * 6.2, weight: 560, ...)` painted with a `titleTop → titleBottom` shader (as `courses_screen.dart` 609–625), keep `titleShadows` on a shadow layer |
| A8 | Lattice | gold lines #D29F20, p99 L 150 at 0–5u, 91 at 5–10u, **gone (49) by 10–15u** | olive lines #9A954D, p99 L 138 / 116 / **101** at 10–15u: still visible down to the panel and around the ribbon | **medium** | code | `_Lattice`: `height: u * 16` (not 31); mask stops `[1.0 @0, 0.45 @0.4, 0 @1]`; tint the lines warmer with `ColorFiltered(ColorFilter.mode(RateelColors.pathLine, BlendMode.srcIn))` (#D1A93C, closest token to #D29F20) |
| A9 | Ribbon band (A1 asset) | band fill #012418 … #022317 (L ≈ 30), almost black-green | #055120 → #02401B (L ≈ 55–60), saturated green | **medium** | asset | darken the band in `tools/assets/leaderboard_assets.py` (multiply the band's green pixels to ≈ #03291B, keep the gold edges) or ask ChatGPT for A1 with a «very dark green band, almost black (#02261A)» |
| A10 | Pinned bar glow | gold glow outside the rim: #505C14 next to the rim → #163A18 2u away (above), #324310 → #1E3E1D (below) | #0E2B1C next to the rim: no visible glow; the black shadow `offset (0, −0.4u)` 45 % darkens the top side | **medium** | code | `_UserBar`: remove the upward black shadow (or `offset: Offset(0, u * 0.6)`, 30 %) so the token glow shows; the glow strength itself is conflict K7 |
| A11 | Tab container | gold outline (outer side #EEE695, inner #595722), fill #01120D (L ≈ 14) | glass rim 0.23u #245843, fill black 25 % (#032116, L ≈ 24) | **medium** | code | `_Tabs`: container rim = `_GoldRimPainter` (gold rim token, as the panel), fill `Colors.black` 45 % |
| A12 | Off-scale weights | – | w600 / w500 for cream text | low | code | names, points, rewards, rank numbers, tabs → w560 (card-title weight) |
| A13 | «n درس» | 3.3u, #DCDAC9 | 3.1u, #C0CAC2 | low | code | `readex(u * 3.3, weight: 400, color: RateelColors.label.withValues(alpha: 0.85))` |
| A14 | «15» size | ink 4.3u wide | 4.1u | low | code | `_GoldRank` text 4.0u → 4.2u |
| A15 | Tab labels | body ≈ 3.2u | 3.5u | low | code | 4.0u → 3.6u, w560 |
| A16 | Divider under the header | 0.45u, pale #FCFDCD core (#EAE19F edges) between dark hairlines #00120A | 0.25u #FFDA6B, no hairlines | low | code | height `u * 0.35`, centre colour `titleTop` #FFFBEA → `goldHighlight` at the ends, 1 px black 40 % line above and below |
| A17 | Rank discs rows 4+ | (not in the reference) | contrast 1.5:1 | low | code | rim `RateelColors.cardRimTop` #2F6954 at `u * 0.3`, fill black 20 % |
| A18 | Column x offsets | see 2.3 | name +0.6u left, rewards +0.4–0.7u right, medal centre 26.4u vs 26.0u from CR | low | code | `nameRight` 33 → 32.4u; `trailingCx` 12.9 → 12.4u; `badgeRight` 9.8 → 9.4u |
| A19 | Gold disc «15» bevel | pale top highlight #FCE77D 0.3u, lower edge #DCA82B | flat | low | code | thin `goldHighlight` arc on the upper rim (0.25u, 60 %); fill colour stays K6 |
| A20 | Chevron glyph | #F4E897, stroke ≈ 0.75u | #FFFDF5, 0.5u | low | code | stroke `u * 0.7`, colour `RateelColors.playCreamTop` #F4E1A8 (or keep `closeWhite` as the 02 icons: owner) |
| A21 | Star colour | #EAAE1F (L 177) | #EDBF3D (L 192) | low | code | keep the glyphGold token (consistency with 03); note only |
| A22 | Panel inner light | 1u lighter band inside the rim (#1C351C → #0B2917) | flat #002319 | low | code | part of K1 (rim); inner glow `goldEdge` 8 % blur 1u if K1 goes to the reference |

### Behaviour and motion
| # | Item | Finding | Sev. | Fix |
|---|---|---|---|---|
| B1 | **Tab tap targets** | tabs 8.8u = **36.3 dp wide** (× 102 dp): below 48 dp | **high** | `_Metrics.tabs`: give the hit area `left −1.4u, right +1.4u` (11.6u = 48 dp) by placing the `GestureDetector`s in a wider `Positioned` than the drawn tab (hit tests do not reach outside a parent's bounds, so the parent rect itself must be wider; the right side can use the 4.4u margin before the rail) |
| B2 | Own row in the list | after tapping the bar the own row shows the **glass** rank disc «15» while the pinned bar shows the **gold** disc: the bar → row hand-off changes the user's mark (`capture-v2-me-phone.png`) | **medium** | `_PlayerRow`: for `player.isMe` pass `badge: _GoldRank(u: u, rank: rank)` (scaled to 7.4u) |
| B3 | Highlight pulse | fires again every time the own row scrolls into view by hand (`_checkMe`) | low | pulse only after `_scrollToMe` |
| B4 | Friends = Region | with the mock data both filters give the same list (عبدالله، ليلى، فاطمة + me): the filter change cannot be seen | low | vary the mock regions/friends in `leaderboard_data.dart` |
| B5 | Pinned bar tap target | whole bar 16.5u = 68 dp | ok | – |
| B6 | Entry / tab glide / reorder / scroll to own row | as plan §5 (approved), images precached | ok | – |

## 4. Geometry that matches (for the record)
Panel x 4.4u … 15.25u from CR (ref 4.2u … 15.0u), top 18.4u (18.3u), radius 5.3u; header band 13.6u, divider at
31.8u (32.1u); rows inset 1.2u, height 16.3u (16.4u); tabs 13.3–4.6u from CR (13.25–4.45u), 19.3–93.6u, active tab
24.8u (24.3u); bar 76.9–93.4u (76.7–93.55u), radius 4.1u; gold disc and chevron centres within 0.05u; avatars
40.2u from CR (40.0u); medals 8.1 × 10.8u (8.4 × 10.9u); coins 6.3 × 6.0u (6.2 × 6.1u); ribbon band 3.8–13.0u
(3.9–13.2u).

## 5. Conflicts with confirmed tokens (owner decides; not scored)
| # | What | Reference (measured) | Token / built | Status |
|---|---|---|---|---|
| K1 | Panel rim | 0.59u, core #FFFC95/#FCF177 (L ≈ 240), edges #B5AC58/#B29A3A, inner light #1C351C | 0.46u: #DAA42A outer + #FFDA6B inner | logged |
| K2 | Bar fill | under the rim #23672B (L 84) → #1C5C27 → bottom #17461D; rim 0.5u pale #F8F7C0/#FFFD99 | meRow #175627 (L 69) → #0A4322 → #13431C; gold rim token | logged |
| K3 | Active tab | gradient #977114 (top) → #C08F19 → #EBAD21 | flat #E2A51E | logged |
| K4 | Background | #02261C at 10–15u, #00251C below | radial bgTop #063728 → bgBottom: #083121 at 10–15u (+10 L) | logged |
| K5 | Rows | **correction to the log:** the light edge is at the **bottom** (#7CA078, 0.25u) with a faint top line #0A4031; fill brightens downwards #02261B → #0E3821; no side rim | cardTop #033428 → cardMid #012F25, 0.23u #245843 all round | logged (update the description) |
| K6 | Gold disc «15» | #EEB020…#F1B624 (L ≈ 180) + top highlight #FCE77D | flat amber #E2A51E (L 168), countText | logged. Option for the owner: the 02 paused-button gold `badgeTop → amber` (✅ mockup) is closer to the reference |
| **K7** (new) | Outer gold glow of the pinned bar and panel | gold glow ≈ 2.5u, #505C14 at the rim (≈ 35 % gold) | gold 15 % blur 2u (gold rim token) | new |
| **K8** (new) | Chevron button | ring 0.5u #FFDC4A (lit #F0E16D top, #E3B938 bottom), dark interior #0B3818 | glass button token: 0.2u #D8C35A, radial gold 8 → 24 % | new |
| **K9** (new, minor) | Cream text | #FDFBDB / #FEFBD7 (paler, yellower white) | titleCream #FAF1D8 | new (recommend keeping the token) |

## 6. Summary of high / medium items
High: B1 (tab tap width 36 dp).
Medium (code): A1 header baseline, A2 header style, A3 name/lessons spacing, A4 row pitch, A5 star size/points
column, A6 avatar rim brightness, A7 title position and style, A8 lattice fade/colour, A10 bar glow killed by the
black shadow, A11 tab container rim, B2 own-row gold disc. Medium (asset): A9 ribbon band too bright.
