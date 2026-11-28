# Critic v1, screen 31 daily practice (light pass, phone 915x412 only)

Method: phone captures scaled by height to 853 (the phone is wider: 1894 px vs 1843, content box 1735 vs 1686, so x of the
build is compared as `build / 1.0294`). Ink boxes / colours sampled with PIL (numpy) on both images. Owner-approved items
(header as ref, rail 04, calendar icon, «آيتان», week order, A1 background, standard gold card) are not scored.
Numbers are in reference px (u = 8.53 px) unless noted; accuracy about +-2 px.

## The three items the owner noticed

### 1. Emblem overlaps the title (H, code)
| | Ref dark/light | Build (phone) |
|---|---|---|
| Emblem bottom tip (gold ink) | y 113-115 | y 121 (+7 px) |
| Title ink top (tall letters under the emblem, ا ل) | y ~118 (dark), light 100 at the far letters | y 113 |
| Gap emblem bottom to title top under it | +4/+5 px (0.5u), no contact | **-8 px overlap (1u)** |
| Title ink box (light, clean) | 651-1133 x 100-198 (cx 892, cy 17.5u) | 657-1188 x 113-212 (cx 923, cy 19.0u) |
So the title is 13-14 px (1.6u) too low, **31 px (3.6u) too far right**, ink 10 % too wide (531 vs 482 px; same ink height 98-99).
The plan table (ink 651-1199) was mis-measured: the reference title ends at 1133, centred on the axis (892 vs axis 896).
Fix in `PracMetrics`: `titleCx` 925 -> **893**; `titleCy` 17.5 -> **15.9** (the Readex line box puts the ink 1.5u lower than the
requested cy); `titleSize` 9.6 -> **8.8** (width 482 px; height then 7 % short, acceptable, or keep 9.2 and accept +5 % width);
`emblemTop` 1.7 -> **0.8** (tip -8 px). Re-measure: gap must be +4..5 px. Same constants serve dark and light.

### 2. Week day discs "too far left" (M, code; partly not reproducible)
Measured on gold discs, row 1 (ref px; build already divided by 1.0294):
| disc (R to L) | ref cx | build phone | build desktop 1844 |
|---|---|---|---|
| س | 465 | 464.6 (478/1.0294) | 465 |
| ح | 370-372 | 371 | 372 |
| ن | 279-280 | 278.5 | 280 |
| ث ring | 187 | 187 | 187 |
cy row 1: ref 425-426, build 425 (phone and desktop). Ø: ref 67-70 gold ink, build 72 (+3 %).
Row 2 centres x: ref 232 / 325 / 417; build 232 / 325 / 417 (desktop), phone same. cy row 2: ref 515.5, build desktop 515, **build phone
about 511 (-4.5 px, 0.5u)**: row 2 rides slightly high at phone height; check `row2Cy` against the panel top offset
(`cy = u*(row2Cy - panelTop)`) when the panel is shorter than the reference at phone width.
Only real left-shift I can find: the letters inside row 2 (order ر خ ج, approved) and the done glyphs (item 3), which make the
group look lopsided; centres themselves match within 2 px. If the owner sees it at another size (e.g. a narrower phone), the
cause is `pcx = pw/2 + x(discDx) - x(0)` using width scale for x while `dayStep` is width-scaled too: fine at 2.2:1, would drift
at 16:9. Proposal: none for x at phone; for row 2 add +0.5u (`row2Cy` 60.4 -> 60.9) only if a re-capture still shows 511.

### 3. Letter overlaps the check on done discs (H, code)
Ref done disc Ø 75: letter ink about 24 px tall, centre 9 px above the disc centre; check ink 18 x 12 px, centre 11 px below.
Build: letter font d*0.40 (29 px) in Readex: ح/ج/خ draw a long hooked tail (ink about 37 px tall, bottom at +14 px) that runs
into the check (ink 22 x 14 px at +15 px). Fix in `_DayDisc`: done letter `d*0.40` -> **d*0.30**, `top` d*0.10 -> **d*0.08**;
check `width d*0.36, height d*0.28, bottom d*0.16` -> **width d*0.27, height d*0.20, bottom d*0.12**. Verify with ح and ج
(the worst glyphs) on a done disc; letter bottom must be above the check top by >= 2 px.

## Header (31-A)
| # | Item | Ref | Build | Sev | Type |
|---|---|---|---|---|---|
| H1 | Emblem / title | see item 1 | | H | code |
| H2 | Divider under title | cy 25.2u, ink 741-1063 | cx follows the title offset: after item 1 recheck (title and divider axis differ by 31 px now) | M | code |
| H3 | Mosque dark | green gradient, domes brighter (#3F7A5A body) | similar silhouette, darker/flatter (#1E4A36), minaret thinner | L | asset (standard mosque) |
| H4 | Light arch | gold line #E9B94A | tan/bronze line (#C9A07A), thicker | M | code (standard `header_arch` light tint; check with owner) |

## Week panel
| # | Item | Ref | Build | Sev | Type |
|---|---|---|---|---|---|
| W1 | Panel fill dark | #023E2A top, lighter, visible mint inner glow at the top | flat #00291B at bottom, #013925 top (darker overall by about 6 L) | M | code `pracPanel*` |
| W2 | Today ring | ring 0.4u glow, letter cream | ring thinner (about 2 px vs 3 px), glow weaker | L | code |
| W3 | Inactive discs | rim #42785F, fill #0C442C, letter #C9D4BA, Ø 70 | same colours, Ø 70, letter glyphs smaller than ref (ح ج ر 0.30d vs 0.36d) | L | code |
| W4 | Flame / «4 أيام متتالية» / dividers | flame 298-347 x 598-657, text cy 80.5u | within 3 px; streak text 4 % smaller | L | code (`streakSize` 4.4 -> 4.6) |
| W5 | Light panel | rim #E1C7B0, fill #FEF7EE, soft | same colours; ogee lattice at the bottom more visible than ref | L | code |

## Session card, tiles, button
| # | Item | Ref | Build | Sev | Type |
|---|---|---|---|---|---|
| C1 | Tile fill dark | #0B4F34 -> #023926, rim #73B991 / #4C966F | build top #11472E, bottom #17503A: bottom is LIGHTER than ref (#063F23) and rim dimmer (#3E7F63) | M | code `pracTile*` |
| C2 | Tile text stack | name cy 61.4u, divider 65.7u, count 69.4u | count sits on the ogee band and 0.4u higher (`tileCountCy` 69.2 -> 69.6); lattice drawn over the count in dark | M | code |
| C3 | Start button dark | luminous gold outline, bright glow, rim 0.5u #F9E688 | `LessonButton` standard: thinner outline, no outer glow, text 5 % smaller | L | standard (conflict list) |
| C4 | Start button light | filled gold gradient #E9B53C -> #C98F1A, white text, glow | same style, gradient paler (#D9B25A), no glow | L | standard |
| C5 | Card subtitle | cy 42.1u, #E7E6C5 | within 3 px | L | - |
| C6 | Tile glyph colour light | brown #5E3A17 tint | same | ok | - |

## Popup (31-B)
| # | Item | Ref | Build | Sev | Type |
|---|---|---|---|---|---|
| P1 | Light card rim | gold rim about 3 px #E0A323 + glow, card reads as cream with gold frame | **no visible gold rim** in light (soft grey shadow only); sampled rim #E5CB94 at the edge vs ref #E0A323 | H | code (`GoldCardPainter` light rim or `RemindMetrics`; P31-3 expects #EDB02E 3 px) |
| P2 | Veil dark | #052518 at corner, texts of the lesson sharp | #002012 (about 6 L darker, same hue) | L | code `pracVeil` opacity 76 -> 70 % |
| P3 | Veil light | cream-tan #D8C1B0 | #C3B7A8, greyer (less warm) | M | code `pracLVeil` colour toward #D8C1B0 |
| P4 | Title | 7.4u bold, light ink 190-695 (505 px wide), heavier | 475 px wide (-6 %), weight 600 looks lighter; light title in ref uses bolder weight | M | code `titleSize` 7.35 -> 7.7, weight 700 in light |
| P5 | «لاحقاً» dark | rim 0.3u #478D65, fill #013720 | rim a bit dimmer (#3B7E5A), fill equal; text size equal | L | code |
| P6 | «اذهب إلى التدريب» dark | luminous gold outline with glow halo about 1.2u | outline thinner, no halo | M | code/standard `LessonButton` |
| P7 | Light divider | bolder gold (#B8801A) | lighter, thinner | L | code |
| P8 | Card width light | ref draws 104.5 x 56u (bigger) | 99.4 x 54.5u (approved, as dark) | - | - |
| P9 | Lesson behind | ref lesson shows 1/5 chip and «اختبار الاستماع» | build shows 0/5 and «الغنة» (live app lesson) | n/a | - |

## Fidelity (phone size)
| Image | Score | Main reasons |
|---|---|---|
| 31-A dark | 7.0 | emblem/title (H), done-disc glyphs (H), title 31 px off axis, tile fill |
| 31-A light | 7.0 | same header and discs, arch colour, lattice |
| 31-B dark | 8.0 | structure and text match; button glow, veil a bit dark |
| 31-B light | 6.5 | missing gold rim and glow, grey veil, lighter title |

## Conflicts with confirmed tokens (for the owner, not fixed)
- P31-8 header scale: title 9.6u / ink wider than the 12 standard (7.4u); even corrected to 8.8u it stays above the app standard.
- `LessonButton` (standard) cannot show the reference luminous outline / glow (C3, P6): either accept or extend the standard.
- Light header arch colour: reference gold vs standard tan tint (H4).
- Light popup card: P31-3 says gold rim 3 px, the standard gold card in light draws none (P1): decide if the standard card gets a light rim.
- Reference letters ح ج خ are short glyphs; Readex Pro draws long tails: size reduction only, font stays (standard).

## Next fix list (code)
1. `PracMetrics`: `titleCx` 893, `titleCy` 15.9, `titleSize` 8.8, `emblemTop` 0.8.
2. `_DayDisc`: letter 0.30d, check 0.27d x 0.20d at bottom 0.12d (done state).
3. Light popup rim (P1) and veil colour (P3).
4. Tile fill gradient (C1) and count position (C2); panel fill (W1).
5. Re-capture phone: gap emblem-title +4..5 px, row 2 cy 515 +-2.
