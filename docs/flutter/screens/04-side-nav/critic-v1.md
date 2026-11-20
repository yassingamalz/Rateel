# Critic v1: side navigation

Fidelity score: 6/10 (open menu), 7/10 (closed rail)

All numbers come from `scratchpad/critic/measure.py` (re-runnable for v2: `python3 -I measure.py > out.txt`).

- **Frame and scaling.** The frame is 1844x853. The reference rail image (1672x941) is scaled by 853/941 = 0.906 and right-aligned, so rail x values are in the same 1844 frame.
- **How elements are found.** Rims are narrow luminance peaks, at most 6 px wide. Gold and amber elements are found with colour masks; text and icons with light-pixel masks.
- **Radius.** The radius is measured where the rim straightens within 1 px. The value in brackets corrects for that tolerance.
- **"Ink density".** This is filled pixels divided by bbox area. It is used as a weight proxy: higher means bolder or more solid.
- **Glow.** Glow numbers are the colour at N px outside the rim.
- **`u`.** `u` = 1% of screen height = 8.53 px.

## Differences

### Open menu

| # | Region | Reference | Flutter | Severity | Type | Fix suggestion |
|---|---|---|---|---|---|---|
| 1 | Panel edge / width | Edge x=1175; panel 669 px. 4 px light bevel band #164230 / **#1F4F3A** / #194935 / #1A4B36 | Edge x=1179; panel 665 px. **1 px** line #275744, then panel #053023 | low | code | Replace the 1.2 px `railEdge` border with a 3-4 px inner highlight band ≈ #1F4F3A |
| 2 | Panel background | Top-right #012D1F, bottom #012A1E, top-left #013525 (nearly flat deep emerald) | Top #0B3F30, bottom #063024 (≈ +10 L lighter and more teal) | low | code | `panelTop` ≈ #023324, `panelBottom` ≈ #012A1E |
| 3 | Content scrim | Content next to the panel #002217 to #003A26 and far content #002A1E: **no dimming** | Content darkens from #032D22 (closed) to **#021A14** (open), about 40% black. The edge shadow goes from #021A13 at x-40 to #01130E at x-3 | medium | code | Remove the scrim, or cap it at alpha ≤ 0.12. Shadow blur ≤ 8 px |
| 4 | Close button size and position | Ø **70 px**, x1223-1292, centre (1257,55) | Ø **63 px**, x1222-1284, centre (1253,54) | medium | code | Size u*8.2 (70 px); centre x = panelLeft + u*9.6 |
| 5 | Close button rim | **3 px #F2B132** | 2 px **#AC9228** (gold at 85% alpha, 1.6 px) | medium | code | Rim width 2.5-3, full-opacity gold #F2B132 |
| 6 | Close button fill | #023826 on bg #003324 (+3 L: faint glass) | #0F4133 on bg #0B3E2F (+3 L) | low | code | OK |
| 7 | Close button X glyph | **27x26 px, stroke ≈ 4.8 px**, colour **#F7F8F8** (white), round caps | **22x21 px, stroke ≈ 2.5 px**, colour #F4EAD0 (stock `AnimatedIcons.menu_close`) | high | code | Custom-painted X: 27 px, stroke u*0.56 (4.8 px), white, round caps |
| 8 | Row pitch / vertical positions | Centres 187 / 287 / 382 / 477 / 572 / 667; pitch 100 after the selected row, then 95 | Centres 187 / 281 / 376 / 471 / 565 / 660; pitch 94-95 | low | code | Comes from #9 (taller selected row). Rows 2-6 sit 6-7 px higher |
| 9 | Selected row size | **y138-236, h=99**, x1240-1793 (**w=554**) | **y145-229, h=85**, x1264-1797 (w=534) | medium | code | Selected rect = row rect inflated by ≈ 7 px vertically and 4 px left (h ≈ u*11.6) |
| 10 | Unselected row size and extent | h=87-88, x1244/1245-1794 (w=550), 69 px from the panel edge, right margin 50 | h=84-85, x1264-1798 (**w=535**), **85 px** from the panel edge, right margin 46 | medium | code | `rowRectAt.left = panelLeft + u*8.1`, `right = w - u*5.85`, half-height u*5.15 |
| 11 | Row corner radius | ≈ 23-24 measured (**r ≈ 31 px**): rounded rectangle | ≈ 31 measured (**r ≈ 40 px** = h/2): full stadium | medium | code | Open-state radius u*3.6 (31 px) instead of `rect.height / 2` (in `_item`, `_selectedRow` and the lerp target) |
| 12 | Unselected row rim | 2-3 px, #235641 / #1C503B (top), #255A46 to #295D48 (left) | **1-2 px**, #245544 / #295948 (top), #265845 (left) | low | code | Rim width 2 px |
| 13 | Unselected row fill | Top #012D1F, bottom #012C1F, which equals the panel bg (#012B1D): **no fill** | Top **#154235**, bottom #0D3B2D on bg #083629: **visible white glass** (5.5% to 1.5%) and a vertical gradient | medium | code | Fill alpha 0 to 0.015, no gradient. The capsule should read as outline only |
| 14 | Selected row rim | Top 2 px **#FFDA6B**, bottom 2 px #FFD36E (light-gold highlight); left 4 px #DAA42A | Top 2 px **#E3BE42**, bottom 3 px #E8BA33, left 2 px #E1BD41 | medium | code | 2.5-3 px rim using a gradient border (#FFDA6B on top/bottom edges, #DAA42A at the ends) or two strokes (outer #DAA42A, inner 1 px #FFDA6B) |
| 15 | Selected row fill | **Flat** olive-gold: top #3B4C1F, bottom #3A4B1F | **Gradient** greenish: top #315438, bottom **#163A27** | high | code | Solid fill ≈ #3B4C1F (gold #E7B030 at 25% over #012B1D). No vertical fade |
| 16 | Selected row glow | Above rim: 1px #133618, 3px #1C3E1E, 5px #183A20, 8px #113720, 12px #093320, bg by about 16-20 px. Warm olive, peak ≈ +18 L | 1px #284C2C, 3px #234A2C, 5px #20482C, 8px #1A452D, 12px #15422E, bg by about 20-25 px. Greener, peak ≈ +14 L over a lighter bg | low | code | Keep blur ≈ u*2 but tint warmer: gold @ 0.30 with no green bias. Mostly fixed by #2 and #15 |
| 17 | Selected icon circle | **76x75 px**, centre (1723,187), 70 px from the row's right rim; ring 2 px #ECBE3B; disc #1E361B; gold glyph **54x54** | **65x65 px**, centre (1736,187), 61 px from the rim; ring 2 px #F2B623; disc #1C3220; glyph **46x46** | medium | code | Circle u*8.9 (76 px), glyph u*6.3 (54 px). `rowIconCenter.x = w - u*14.2` |
| 18 | Row icons: size | Book 61x37, mic 31x47, trophy 51x47, medal 43x49, certificate 42x47 px; centre x≈1725 | Book 36x34, mic 27x36, trophy 35x36, medal 31x37, doc 27x36 px; centre x 1736 | high | code | Menu icon box ≈ u*5.6 (48 px tall glyphs, book 61 px wide). Centre x = w - u*14.1 |
| 19 | Row icon: القرآن (book) | **Outline** open book, line art; ink density **0.21** | **Solid** FA `bookOpen`; density **0.66** | high | asset (ChatGPT icon) | Export the reference outline open-book icon |
| 20 | Row icon: المتصدرين (trophy) | Trophy with a **star emblem** cut into the cup; 51x47 | Plain FA `trophy`, no star; 35x36 | medium | asset (ChatGPT icon) | Export the reference trophy icon |
| 21 | Row icon: الشهادات (certificate) | Document outline with a **gold ribbon seal** (244 gold px); density 0.29 | Plain FA `fileLines` (0 gold px); density 0.51 | medium | asset (ChatGPT icon) | Export the reference certificate icon (two-tone cream plus gold) |
| 22 | Row icon: الإنجازات (medal), التدريب (mic) | Medal with star 43x49, density 0.48; mic 31x47, density 0.47 | Medal 31x37; mic 27x36 (similar style, too small) | low | asset (ChatGPT icon) | Use the reference icon set for consistent stroke weight. Otherwise just enlarge (#18) |
| 23 | Row icon colour | #FFF8CC to #FAEAC1 (warm near-white) | #F4EAD0 | low | code | Icon colour ≈ #FCF1D0 |
| 24 | Labels: size | Width / height: الدروس 114x34, القرآن 82x36, التدريب 100x32, المتصدرين 150x34, الإنجازات 119x34, الشهادات 137x25 | 102x30, 78x37, 98x30, 144x31, 115x31, 122x30, which is **4-11% smaller** | medium | code | Font size u*3.6 → u*4.0 (34 px) |
| 25 | Labels: weight | Ink density **0.19-0.22** (regular to medium) | Ink density **0.25-0.30** (heavier) | medium | code | Readex weight 500 → 400 |
| 26 | Labels: colour | **#FFFFFF** to #FFFFFB | **#F4EAD0** (cream) | medium | code | Label colour #FFFFFF (or #FFFDF5) |
| 27 | Labels: position | Right edge x=**1643** (43 px left of the icon circle; 151 px from the row's right rim) | Right edge x=**1674** (30 px from the circle; 124 px from the rim) | medium | code | `labelRight = w - u*23.6` |
| 28 | Count pill size | **67x43-44 px** (73x43 for 114; 74x46 selected) | **64x33-34 px** (77x33 selected) | high | code | Pill height u*5.1 (43 px), width u*7.9 (67 px), u*8.6 for 3 digits |
| 29 | Count pill position | x1287-1353, **inset 40-42 px** from the row's left rim | x1277-1340, **inset 13 px** from the rim | high | code | `pillX = rowLeft + 42 + w/2`, i.e. `panelLeft + u*16.9` (centre ≈ x1320) |
| 30 | Count pill colour | **Flat amber**: top #EDB11F, bottom #EDB222 | **Gradient** lemon to gold: top **#FED554**, bottom #F3BA29 | medium | code | Solid #EDB120 (no gradient) or a very subtle #F0B526 to #E8AC1E |
| 31 | Count pill text | Digit height 17-18 px; colour **#1A321C** (dark green-black); density ≈ 0.60 (bold) | Digit height 16 px; colour **#2A2210** (brown-black) | low | code | Text colour #10301B. Size u*2.1 (18 px glyph); weight 700 is OK |
| 32 | Count pill shadow | None. Pixel under the pill +2 px #002820 = bg | Dark drop shadow: +2 px #0B3227 vs bg #0D3B2D | low | code | Remove the pill BoxShadow in the open state |
| 33 | Divider | x=1380 (27 px from the pill's right edge), 2 px wide, 35-37 px tall, peak #295743 to #2E5C46 (green-tinted) | x=1364 (24 px from the pill), 1 px, 31-36 px, peak #3B5F4E (greyer, cream @ 25%) | low | code | 2 px wide, colour ≈ #2C5845 (rim green, not cream). Position follows #29 |
| 34 | Thin gold arch above the rows | Present (y≈30-130, x≈1340-1690) | Missing | medium | asset | Add the asset |
| 35 | Filigree end caps on the selected row | Present (x 1202-1233 and 1800-1830) | Missing | medium | asset | Add the asset |
| 36 | Geometric pattern strip at the bottom of the panel | Present (y≈760-853) | Missing | medium | asset | Add the asset |

### Closed rail (ref scaled ×0.906)

| # | Region | Reference | Flutter | Severity | Type | Fix suggestion |
|---|---|---|---|---|---|---|
| 37 | Rail width and edge | Width **158 px**. Edge band 4 px: #1B4E37 / #245940 / **#295F45** / #134732 | Width 162 px. Edge **1 px** #2D614C | low | code | 4 px highlight band, peak #295F45 |
| 38 | Rail background | Top #073928, mid #002E20, bottom #00281C | Top #0B3F30, mid #083729, bottom #052E22 (≈ +7 L lighter) | low | code | Same palette fix as #2 |
| 39 | Menu button tile | x1733-1805, y25-87: 73x63 px; r≈20; rim 2 px #184C35; fill #053A27 on #002E20 (+6 L) | x1730-1800, y24-84: 71x61 px; **r≈11-16**; rim 1-2 px #255A47; fill **#154637** on #083729 (+10 L) | low | code | Radius u*2.4 (20 px). Fill alpha 0.04 → 0.025 |
| 40 | Hamburger glyph | **35x31 px**, 3 bars, **5 px** thick, #EFEACF | **27x19 px**, 3 bars, **3 px** thick, #F4EAD0 | medium | code | Custom painter: bars 35 px wide, 5 px stroke, 13 px pitch, round caps |
| 41 | Active disc | **73x72 px**, centre (1771,182). Flat amber: top #E3A926, left #DDA01F, right #E4A51D, bottom #E0A41D | **79x80 px**, centre (1765,173). Radial: top **#F7C43A**, right/bottom #F2B623 | medium | code | Inner u*8.5 (73 px). Flat #E2A51E (or a radial gradient from #E8AC24 to #DDA01F) |
| 42 | Active ring | Ø ≈ 103-106 px, **1 px** #9B822C at its centre line. Gap to disc 14 px, gap colour **#415423** (olive glow) | Ø 107 px, 2 px #C79F25. Gap 13 px, gap colour **#60692B** (brighter, yellower) | medium | code | Ring fill gold @0.10 → @0.05 and glow alpha 0.30 → 0.18, so the gap lands at ≈ #415423 |
| 43 | Active outer glow | Below the ring: colour at 3 px #2D4B22, fades to bg in ≈ 35 px | Colour at 3 px #24492C; still above bg at 44 px | low | code | Glow blur u*2.4 → u*2.0; warmer tint |
| 44 | Active glyph | Cap 67x66 px bbox (dark #06291C) | Cap 73x74 px bbox (dark #1E2A12) | low | code | Glyph colour #06291C (dark green, not olive-black) |
| 45 | Active bubble "30" | Left edge 13 px left of the ring's left edge; bottom 11 px above the disc centre; covers the disc's upper-left only | Left edge 9 px left of the ring; bottom 5 px above the centre, so it sits 6 px lower and covers more of the cap glyph | low | code | Move the active bubble up ≈ 6 px and left ≈ 4 px |
| 46 | Tile size and pitch | 105x94-95 px, x1717-1821; pitch 122 (5 items) | 105x90-91 px, x1713-1817; pitch 110-111 (6 items, by the owner's decision) | low | code | Height u*10.8 → u*11.1 if space allows. Pitch is not a defect |
| 47 | Tile radius | Measured 15-16 (**r ≈ 22 px**) | Measured 11-13 (**r ≈ 17-19 px**) | low | code | Radius u*2.4 → u*2.6 (22 px) |
| 48 | Tile rim | 2 px all sides, #1B4C37 / #1E5139 (top), #0E412A (left) | **1 px** top/left/right, 2 px bottom; #2B5C4A (top), #245443 (left) | low | code | 2 px rim, colour ≈ #1C4E38 |
| 49 | Tile fill | Top #012F1F, bottom #012E1F on rail bg #002E20: **transparent** | Top **#164437**, bottom #0E3D2F on #083729: **+8 L white glass** with a gradient | medium | code | Same as #13 |
| 50 | Rail bubble size | 55-56x39-40 px (114: 64x40) | 54x37 px (114: 64x38) | low | code | Height u*4.4 → u*4.65 |
| 51 | Rail bubble position | Offset from the tile's top-left (-7…-8, +0…+1); 114: (-13,+3) | (-10, +2); 114: (-15, +2) | low | code | Move 3 px right (`tile.left + u*2.35`) |
| 52 | Rail bubble colour | **Flat** #E1A41D to #E2A51E (deep amber) | **Gradient** #FED655 to #F3BA29 (lemon) | medium | code | Flat #E1A41D |
| 53 | Rail bubble text | 17 px digits, colour #132C1A to #213318 (dark green) | 16 px, #2A2210 (brown) | low | code | Text #132C1A |
| 54 | Rail bubble shadow | None (+2 px under the bubble #002C20 = bg) | Present (+2 px #0E3328, darker than bg #10392D) | low | code | Remove the BoxShadow |
| 55 | Rail icon size and offset | Book 35x42, mic 31x46, trophy 46x44, medal 37x43; centre offset (+7…+9, +2…+7) | Book 37x42, mic 32x42, trophy 42x42, medal 34x44, award 37x47; offset (+5…+6, +4…+5) | low | code | Horizontal bias u*0.6 → u*0.95 |
| 56 | Rail icon colour | #F5EACC to #F6EACB | #F4EAD0 | none | — | OK |
| 57 | Rail icon الشهادات | n/a (item not in the reference) | FA `award` rosette, which differs from the menu glyph (`fileLines`) | low | asset (ChatGPT icon) | Ask for a matching rail certificate icon. Use the same glyph in both states |
| 58 | Lattice corner ornaments | Present in the content corners | Only the top-left one | low | asset | Add the asset |

## Animation notes

Frames s1, s2 and s3 (1280x592), slowed.

1. **Dividers render outside the panel (bug, high).** In s2 all six dividers sit at x≈947, left of the panel edge (x≈951), over the content. `_item` places the divider at the absolute final `g.dividerX` (`left: g.dividerX - rect.left`, `Clip.none`) while the panel and rows are still sliding. Fix: compute it from the morphing rect, `rect.left + (dividerX - rowRect.left)`, or start its fade only once the panel edge has passed it.
2. **Labels are also absolutely positioned.** `right: rect.right - g.labelRight` does not travel with its row. It is hidden by the stagger today, but it is the same class of bug.
3. **Icon double exposure.** Rail and menu glyphs cross-fade 1:1 at equal size (book → open book, award → document). At t≈0.5 both are at about 50% opacity (visible ghosting in s2 on القرآن and الشهادات). Fix: switch at t=0.5 with a scale dip, or use the same glyph in both states.
4. **Pills ride the row's top-left corner.** The bubbles lerp independently of the row rect. In s2 the pill centre is about 7 px above the row centre and touches the left rim.
5. **The hamburger→X midpoint looks broken.** The stock `menu_close` midpoint (s1/s2) is a set of thin diagonal scratches. A custom painter with 5 px bars (rotate the outer bars ±45°, fade the middle bar) matches the reference's stroke weight.
6. **Tiles widen before the panel moves.** In s1 the tiles are already about 130 px wide while the panel edge has barely moved, and the gold disc shrinks inside an empty wide tile. Drive the tile width with the same curve as the panel edge.
7. **The scrim darkens the content progressively** (see #3). The reference has no dimming.
8. **What works:** the selected capsule growing out of the active tile, the staggered label fade, and the close button travelling from the rail top to the panel corner.

## Summary

Several things already match within a few px: panel width (665 vs 669 px), rail width (162 vs 158), row pitch (95), tile width (105), ring diameter (107 vs ≈105), the gold-glyph-in-a-ring selected icon, and the icon cream colour.

The open menu loses fidelity in these areas:
- **Icons:** solid and about 40% smaller (book 36 vs 61 px wide). Three glyphs differ (outline book, trophy with star, certificate with seal), which is ChatGPT icon work.
- **Count pills:** 33 px instead of 43 px tall, placed 13 px instead of 42 px from the rim, with a lemon gradient instead of flat #EDB120.
- **Selected row:** a green gradient (#315438 to #163A27) instead of flat olive-gold #3B4C1F. It is also 14 px too short (85 vs 99).
- **Row shape and fill:** a stadium radius (≈40 vs ≈31), and white glass fill (+8 L) where the reference is an outline only.
- **Close X:** thin, cream and small (22 px, 2.5 px stroke) vs bold white (27 px, 4.8 px).
- **Labels:** about 8% smaller, too heavy (density 0.27 vs 0.21) and cream instead of white.

The closed rail is close, apart from these:
- tile glass fill
- 1 px vs 2 px rims
- lemon-gradient vs flat-amber bubbles
- a 79 px lemon disc vs a 73 px amber disc, with a too-bright ring gap
- a thin, small hamburger (27x19 / 3 px vs 35x31 / 5 px)

The morph has one real bug (dividers outside the panel) and two polish issues (icon ghosting, the menu_close midpoint). The four missing image assets account for most of the remaining "bare" look of the open panel.
