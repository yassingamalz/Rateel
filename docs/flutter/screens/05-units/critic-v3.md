# Screen 05 (course units): critic v3 (on Flutter v4)

Date: 2026-11-22. Branch `flutter/05-units` at `24cfab5` (v4 = `d96b827`, critic-v2 fixes; then the U6b prompt).
Reviewer: separate critic sub-agent (did not write the code).

Compared:
- Reference `reference.webp` 1672×941, u = 9.41 px. The right rail (x ≥ 1497) is not scored (approved side nav).
- Flutter `capture-v4.png` 1672×941 (reference state: unit 1 open 0 %, unit 2 locked), `capture-v4-unit2.png`,
  `capture-v4-unit3.png`, `phone-v4.png` (915×412 @2.625), `unlock-frames-v4.jpg`, `compare-v4.jpg`.

Method: Python/PIL/numpy pixel sampling on both images at the same coordinates: 60×60 / 80×80 patch medians and
p99−p50 for background and pattern; colour masks (gold, cream, green, dark) for extents; row/column profiles
through the circle centres; radial profiles (median over 20 angles, line/badge/check angles excluded) and the
brightest rim pixel every 15° around each ring, rim FWHM by bilinear sampling every 0.25 px. All x/y are pixels in
the 1672×941 frame. Where a mask differs from critic v2 (arch), both images were re-measured with the same mask.

Not scored (owner ✅, DECISIONS.md 2026-11-22 unless noted): title on the right with the arch centred on it;
corners top left + bottom right; padlock all green; completed units keep the play disc + check badge; padlock at
the lower right of narrow icons; shared course progress; sequential unlock; sound and haptics; title cream
gradient/shadow and unit titles in `titleCream` (✅ 2026-11-21); data shown (✅ 2026-11-21: third unit, the line
running off the left edge). Still-open owner decisions are listed in §4 and **not scored as code defects**:
bright reference line vs thin line, background base #013222 vs screen-03 background, unit ring/badge colours vs
approved tokens, pill text cream vs gold.

## 0. Status of the critic-v2 findings

| v2 # | Finding | v4 status (measured) |
|---|---|---|
| D1 | Girih contrast 20–22 lum, teal, also behind the header | **fixed**: p99−p50 **2.3–6.3 lum** vs ref 3.0–6.2; header patch 1.0 vs ref 3–4 (masked, fine). Residual: line pixel **#063326** vs **#093522** (slightly teal, B +4): low (N6) |
| D1a | Girih geometry (asset) | **not fixed**: same 8-point U6 tile; U6b prompt written (`prompts/05-units/images-v1.txt`), asset pending |
| D2 | Swap icon was an icon-font glyph | **fixed**: owner's `swap.svg`, 37 × 30 px vs 33 × 32. Residual: text **155 × 29** vs 143 × 27, content starts x **99** vs 121 (low, D2b) |
| D3 | Connector line | owner conflict (§4). v4 = thin variant: core 1 px **#C9A23A** + AA #A38B34, dark edges #022A1F / #01281C. New: line centre **y 548.3** vs 546.5 (N2, low) |
| D4 | Disc edge darkened | **partly fixed**: rim lit (r 190 → lum 46, rim 58; ref 43–44) **but a new dark trough** r 158–182 (lum **29** vs ref 37–41) → D4b, medium |
| D5 | Flat ring rims | **fixed**: active sides #F8BC2C, top #EFB42D…#FED145, bottom #FFD54A (ref #F9BB2F / #FFDB55 / #FAD351); locked sides #B98F2C, top #FBE068, bottom #FDC849 (ref #C09327 / #FCE36A / #FDC849); FWHM 3.75 / 3.88 px vs 4.0 / 3.5; inner hairline #11301B; locked contact shadow lum 28–30 at r 222–234 (ref 28–29) |
| D6 | Ring Ø 433 | **fixed**: row 548 locked 170–613 (**444**), active 796–1239 (**444**); ref 170–611 (442), 799–1235 (437), vertical 324–769 (≈ 446) |
| D7 | Badge | **fixed** (gradient, shadow, text height): top **#F7C140** → bottom **#E6A619** (ref #F8C245 → #E7A61A); no gold glow (sides #153925 vs ref #1F3D1E); text 25 px tall (ref 25). Residual: badge centre **y 325** vs 329 (4 px high), text **52** vs 46 px wide (D7b, low) |
| D8 | Background base | owner conflict (§4), unchanged: body **#012B21–#012C22** (lum 29–30) vs **#013121** (lum 33); top **#063428** (lum 37) vs #012F20 (lum 31) |
| D9 | Arch | **partly fixed**: same mask on both: span **x 984–1413 (430 px, 45.7u)** vs **705–1111 (407 px, 43.3u)** (v3 485); height y **28–122** vs **24–109**; stroke flat **#F7C13A** 4 px at every point vs ref gradient (apex #FFCA32 / #F7B521, shoulders #F9D571 / #F9CA32, tails #EEAA21 → #CB9C31) with a 1 px dark under-edge **#01181B**; F has none → D9b, medium |
| D10 | Play disc pale, halo | **fixed**: #F4E0A3 → #F2D889 (ref #F4DFA2 → #F3D887), 108 × 109 vs 108 × 110, centre (1017.5, 473) vs (1019.5, 472.5); dark edge below (#042F1F) |
| D11 | Diamond | **fixed**: 23 × 20 px (ref 23 × 20), body #F0B128, top #F9D051 (ref #F0B024 / #FFE76D), glow at −14 px #093224 (ref #153D1F, faint in both). Sits 2 px low with the line (N2) |
| D12 | Corners beige, no relief | **partly fixed**: median **#C6A242** / p90 **#F4C453** / p99 #F6CF68 vs **#AF8B23 / #F3AE1A / #FFCB35** (now bright enough but yellower: B 0x53 vs 0x1A); run width 4 px vs 3 px; dark relief present (p2 #041F16 vs #001F16) → D12b, low |
| D13 | WebP missing on the phone | **fixed**: `phone-v4.png` shows mosque, both corners and the book |
| D14 | Title 6 px low, 4 % narrow | **not fixed**: 986–1402 × 140–206 (**417 × 67**, centre y **173**) vs 980–1413 × 134–200 (434 × 67, centre y 167) |
| D15 | Path clipped on the right | **not fixed in the settled state**: in `capture-v4-unit2/3` rows 546–548, x 1240–1497 contain **no** pixel above lum 90 (only the active ring at 1236–1239). Expected: lit connector, diamond at x ≈ 1330, completed ring arc from x ≈ 1421 (pitch 626 px). During the glide (unlock frames row 2, frame 1) the completed unit *is* drawn, so it vanishes when the glide ends → medium |
| D16 | Mosque greener/brighter | **not fixed**: mean **#335732**, top 5 % #446738 vs **#2D4B26** / #425829 |
| D17 | Padlock 15 % short | **mostly fixed**: 65 px tall (6.9u) vs 69 (7.3u); body 58 × 36 vs 56 × 42 (asset shape); centre y **498** vs 493 (5 px low) → low |
| D18 | Divider | **not fixed**: x 1049–1349 (**301 px**) vs 1055–1335 (281); 3 rows vs 4; peak **#F4C94D** vs #F5BD35; ends #204128 vs #6C6722; colours still hard-coded (`units_screen.dart` l. 636–642) |
| D19 | Pill rim | **not fixed**: #9C8430 2 px, no dark edges vs #93883D with #002216 hairlines |
| D20 | Locked title large | **not fixed**: 298–484 × 551–663 (**187 × 113**) vs 303–477 × 560–666 (175 × 107); active 210 × 106 vs 218 × 102 |
| D21 | Unlock fades | **partly fixed**: play disc enters at full colour (#F2DC98 in frame 4); but the book still fades to olive and overlaps the play disc, the padlock is ghosted (§2) |
| D22 | Mosque composition (asset) | unchanged (library mosque kept), low |
| Assets | U1–U5 used; U6 tile wrong geometry | U5 now used (D2 fixed); U6 still the 8-point tile (D1a) |

## 1. Element measurements (v4)

| Element | Reference | Flutter v4 | Verdict |
|---|---|---|---|
| Background base | #013121 / #013222 (lum 33), top #012F20 (lum 31) | #012B21 (lum 29) body, #063428 (lum 37) top | owner conflict (§4) |
| Girih | contrast 3.0–6.2 lum, lines #093522–#0D3822 | contrast 2.3–6.3 lum, lines #063125–#08362A, masked at the top | ok in strength; hue slightly teal; geometry is the asset item |
| Corners | TL 0–299 × 0–196, median #AF8B23, p90 #F3AE1A, strokes 3 px | TL 0–299 × 0–195, median #C6A242, p90 #F4C453, strokes 4 px, relief ok | yellower, slightly heavier |
| Mosque | mean #2D4B26 | mean #335732 | greener/brighter |
| Crescent | 700–807 × 110–203, mean #284926 | 732–806 × 128–197, mean #264428 | ok |
| Arch | 407 × 86 px (705–1111, y 24–109), gradient gold + dark under-edge | 430 × 95 px (984–1413, y 28–122), flat #F7C13A | 5.7 % wide, 1.4u longer tails, flat |
| Title | 434 × 67, centre (1196.5, 167) | 417 × 67, centre (1194, 173) | 4 % narrow, 6 px low |
| Divider | 281 px, 4 rows, peak #F5BD35 | 301 px, 3 rows, peak #F4C94D | 7 % long, thinner, yellower |
| Pill | rim 68–355 #93883D + dark hairlines; text 121–263 (143 × 27); icon 292–324 (33 × 32) | rim 68–353 #9C8430; text 99–253 (155 × 29); icon 284–320 (37 × 30) | icon ok; text 8 % wide and 22 px left |
| Rings | Ø 442–449, rims see D5 | Ø 444, rims match | ok |
| Inner disc radial (lum, r = 150 / 166 / 176 / 186 / 190 / 192) | 37 / 40 / 38 / 39 / 38–44 / 44 | 36 / **29** / **31** / 41 / 46 / 58 | **dark trough 0.81–0.95 R** (D4b) |
| Disc bottom lattice | p99−p50 32–35 lum | 23 lum | 30 % fainter (N3) |
| Badge | 89 × 87, centre (1019, 329), #F8C245 → #E7A61A, text 46 × 25 | 90 × 89, centre (1017.5, 325), #F7C140 → #E6A619, text 52 × 25 | 4 px high, text 13 % wide |
| Play disc | 108 × 110, #F4DFA2 → #F3D887 | 108 × 109, #F4E0A3 → #F2D889 | ok |
| Connector line | 2 px #FFCF41 / #F4BF3D, centre y 546.5 | 1 px #C9A23A (+ AA), centre y 548.3 | brightness = conflict; 2 px low = code |
| Diamond | rows 535–557, cols 697–716 | rows 537–559, cols 695–714 | ok, 2 px low |
| Unit titles | locked 175 × 107, active 218 × 102 | locked 187 × 113, active 210 × 106 | locked 7 % large |
| Book | 140 × 100, centre x 396.5 (ring +6), mean #EEDDA9, bottom edge #EBD48D | 140 × 99, centre x 391.5 (ring +0), mean #E7CE95, bottom edge #E0BB65 | slightly darker/yellower edge (N4) |
| Padlock | 56 × 69, body 56 × 42, centre y 493, #286A47 | 58 × 65, body 58 × 36, centre y 498, #276646 | 5 px low, squat body (asset) |

Phone (`phone-v4.png`): all raster assets present (D13 fixed); geometry consistent with the desktop capture
(ring ≈ 46u, pitch ≈ 66.5u, arch ends before the rail).

## 2. Unlock frames (`unlock-frames-v4.jpg`)

Tiles are crops at scale ≈ 0.50 (pitch 315 tile px = 626 px). Order: light runs along the line → padlock lifts →
book sinks → play disc + badge in → glide → settled. Measured inside the locked disc (tile px 95–175 × 85–150):

| # | Frame | What | Sev. |
|---|---|---|---|
| G1 | row 1, frame 2 | the padlock grows and fades with `Opacity` while still on the book: green **#58835E** (settled #2A6645), the book shows through it (ghost) | low |
| G2 | row 1, frame 3 | the book still fades by opacity to olive **#B1A45F** (light-pixel median; settled #EED8A9) **and the play disc has already appeared inside it** (small disc over the half-faded book): the two icons overlap, which reads as the "icons swapping" look the owner rejected on the phone (DECISIONS 2026-11-22) | **medium** |
| G3 | row 1, frame 4 | play disc and «0%» badge are fully in while the ring still has the dim locked colour; the ring turns gold only afterwards | low |
| G4 | row 2, frame 1 → settled | during the glide the completed unit, its lit connector and diamond are drawn at the right; once settled they are gone (D15: `capture-v4-unit2/3` empty at x 1240–1497) → they pop out | medium (D15) |
| G5 | row 1, frames 1–4 | «100%» badge on top and check badge at the bottom together (✅ play disc + check badge); info for the owner only | info |

## 3. Differences (open items)

| # | Element | Difference | Sev. | Type | Fix (u = 1 % of the height = 9.41 px) |
|---|---|---|---|---|---|
| D4b | Inner disc edge | dark trough at r 158–182 (lum 29–31 vs ref 37–41), the lit rim only in the last 0.4u; disc top at y 362–375 #0A3A26 / #0A3322 vs #124934 / #104733. Cause: `unit_circle.dart` l. 210–213 `RadialGradient(stops [0.80, 0.985], colors [Color(0x00000000), unitDiscEdge])`: the transparent stop is transparent **black**, so the mid-stops are half-alpha dark green over the fill | **medium** | code | colours **[Color(0x000B422A), RateelColors.unitDiscEdge]** (transparent of the same colour); keep stops [0.80, 0.985]. Expected radial lum 36 → 40 → 44 at the rim |
| D15 | Completed unit right of the active one | settled: nothing between x 1240 and the rail (expected connector, diamond x ≈ 1330, ring arc from x ≈ 1421); visible only during the glide (G4) | **medium** | code | the `PageView` viewport ends at `trackRightInset` (17.75u from the rail) and pages beyond it are not painted. Make the viewport reach the rail: `Positioned(right: 0)`, `viewportFraction = 66.5u / w`, and move the page content left by **17.75u** (leading spacer of 17.75u before page 0, or `Transform.translate(-17.75u)` on the PageView with the gesture area unchanged); keep `Clip.none`, add a **4u** horizontal fade at the rail edge. Verify on `capture-unit2`: lit line x 1239–1421 at y 547, diamond at x ≈ 1330 |
| D9b | Header arch | 430 × 95 px vs 407 × 86; flat #F7C13A; no dark under-edge | **medium** | code | `archW` **48u → 45.4u**, apex **0.4u** higher (y 24.5 px → 2.6u); stroke as a horizontal gradient: ends **#CB9C31**, tails **#EEAA21**, shoulders **#F9CA32**, apex **#FFCA32** (core #F7B521 under it); 1 px under-stroke **#01181B** at 0.1u offset y (`Shadow` blur 0) |
| G2 | Unlock: book + play overlap | book fades to olive #B1A45F while the play disc is already in | **medium** | code | book: no opacity change until 85 % of its segment, sink by scale **1 → 0.5** and translate **+2u**; play disc starts at **≥ 62 %** (after the book has gone), never overlapping; start the ring lock→active colour lerp with the play disc (G3) |
| D1a | Girih geometry | 8-point grid tile vs large irregular 10-point girih (stars ≈ 18u) | **medium** | asset | U6b prompt (already in `prompts/05-units/images-v1.txt`), owner generates |
| D12b | Corners | median #C6A242 / p90 #F4C453 vs #AF8B23 / #F3AE1A; strokes 4 vs 3 px | low | code | tint `unitCornerTop/Bottom` **#FAD26A → #F3B526**, **#E9A41E → #C98816**; relief shadow offset **0.25u → 0.15u** |
| D14 | Title | 417 × 67 at y-centre 173 vs 434 × 67 at 167 | low | code | title box **−0.65u**; font **7.2u → 7.5u** |
| D18 | Divider | 301 vs 281 px, 3 vs 4 rows, #F4C94D vs #F5BD35, hard-coded | low (rule) | code | width **37u → 34.5u**, height **3.2u → 3.6u**; stops **#6C6722 → #EBAA20 → #F5BD35 → #EBAA20 → #6C6722**, moved to `RateelColors` (`dividerEdge/dividerMid/dividerPeak`) |
| D2b | Pill content | text 155 × 29 vs 143 × 27; content x 99–320 vs 121–324 | low | code | text **3.15u → 2.9u**; padding right (start) **3.3u**, left (end) **3.3u → 5.6u** |
| D19 | Pill rim | #9C8430, no hairlines | low | code | rim **#93883D** 0.22u + **0.1u #002216** inside and outside |
| D20 | Locked unit title | 187 × 113 vs 175 × 107 | low | code | locked title **4.9u → 4.6u** (keep 4.9u for the active title) |
| D7b | Badge | centre y 325 vs 329; text 52 vs 46 px wide | low | code | badge **+0.4u** down; «0%» letterSpacing **−0.04em** or weight one step lighter |
| N2 | Line + diamond | centre y 548.3 / diamond 537–559 vs 546.5 / 535–557 | low | code | move line and diamond **−0.2u** (snap the 1 px core to the ring centre row) |
| D17b | Padlock on the book | centre y 498 vs 493; 65 vs 69 px tall | low | code + asset | padlock centre **+0.5u** up, box **6.6u → 7.0u**; squat body is the asset |
| D16 | Mosque | #335732 vs #2D4B26 | low | code | `unitMosqueTint` **#8C4A6A33 → #CC3C5426** |
| N3 | Disc bottom lattice | contrast 23 vs 32–35 lum | low | code | lattice alpha **×1.4** (`cardPattern` on the unit disc only) |
| N4 | Book tint | mean #E7CE95 vs #EEDDA9, bottom edge #E0BB65 vs #EBD48D; centred on the ring (ref +6 px right) | low | asset (or code) | none needed unless the owner wants it; optional **+0.6u** x offset |
| N6 | Girih hue | line #063326 vs #093522 | low | code | `girihLine` **#2C6B4F → #2F6B3C** at the same opacity |
| G1 | Unlock: padlock ghost | padlock fades over the book (#58835E) | low | code | full opacity until it has moved **1.5u** off the book, then fade |
| G3 | Unlock: ring colour late | ring locked-dim while badge and play disc are in | low | code | see G2 (lerp starts at 55 %) |
| D22 | Mosque composition | no cloud base / arched building | low | asset | keep the library mosque unless the owner asks |

No high item remains.

## 4. Conflicts with DESIGN-SYSTEM tokens / open owner decisions (not scored as code defects)

| Value on screen 05 (reference) | Current v4 / token | Status | Note |
|---|---|---|---|
| Connector line bright 2 px #FFCF41 / #F4BF3D before any progress | v4: thin 1 px `unitLine` #C9A23A at 100 % with dark edges; course rule: dim track lit by progress | 🟡 owner | bright line vs thin line still open |
| Background flat #013222 (lum 33), no lighter top | v4: screen-03 background #012B21 body, #063428 top | 🟡 owner | still open |
| Unit ring 4 px, sides #F8BC2C, top/bottom #FFD54A; badge vertical #F8C343 → #E5A416 | Active-ring token 1.7 px #D8C35A; gold fill flat #E2A51E | ✅ tokens | v4 follows the reference; owner to decide if unit rings/badge are their own style |
| Pill text cream #F4EECE, rim #93883D | Pill token: gold text, gold 2 px rim | 🟡 owner | v4 uses cream (reference) |
| Screen-05 corners tinted saturated gold | screen-03 glowing corners | 🟡 | D12b makes them differ further from screen 03 |
| Unit tokens (`unitRing*`, `unitDisc*`, `playCream*`, `badge*`, `girihLine`, `unitLine`, `unitArch`, `unitCorner*`, `unitMosqueTint`) | not in `DESIGN-SYSTEM.md` | — | add as 🟡 |
| Divider colours hard-coded (`units_screen.dart` l. 636–642) | rule: screens never hard-code a style value | ✅ rule | D18 |

## 5. Score

- Layout and geometry: 8.7/10 (rings now Ø 444; title, divider, locked title, badge and line still a few px off;
  completed unit missing to the right of the active one in later units).
- Code styling: 8.0/10 (pattern, rings, badge, play disc, diamond, corners close; disc trough, flat arch, divider).
- Assets: 7.5/10 (U5 now used, WebP on the phone fixed; U6 geometry still wrong).
- Motion: unlock sequence correct in order; book/play overlap and padlock ghost remain.

**Whole-screen fidelity: 8.1 / 10** (v1 6.5, v2 7.2). With D4b, D15, D9b and G2 fixed: ≈ 8.6; with the low
items: ≈ 8.8; with U6b: ≈ 9.1.
