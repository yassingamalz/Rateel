# Screen 05 (course units): critic v2 (on Flutter v3)

Date: 2026-11-22. Branch `flutter/05-units` at `a1e9d5e` (v3: sequential unlock, shared progress, green padlock).
Reviewer: separate critic sub-agent (did not write the code).

Compared:
- Reference `reference.webp` 1672×941, u = 9.41 px. The right rail (x ≥ 1497) is not scored (approved side nav).
- Flutter `capture-v3.png` 1672×941 (unit 1 in progress, unit 2 locked = reference state), `capture-v3-unit2.png`,
  `capture-v3-unit3.png`, `phone-v3.png` (915×412 @2.625), `unlock-frames-v3.jpg`, `compare-v3.jpg`.

Method: pixels sampled with Python/PIL/numpy (scripts adapted from `tools/flutter-review/measure.py`): row/column
profiles through the circle centres, radial profiles (median over 28 angles) around the rings, the brightest
rim pixel every 15° around each ring, colour masks for text/icons/badge/diamond/divider/arch/corners,
5×5 medians for gradients, 60×60 percentiles for the background and pattern contrast, and a luminance
stretch (p20 → p20+12) to compare the background patterns. All x/y are pixels in the 1672×941 frame.

Not scored (owner ✅, DECISIONS.md 2026-11-22 unless noted): title on the right with the header arch **centred on
the title**; corners **top left + bottom right**; padlock **all green**; completed units keep the **play disc + gold
check badge**; on narrow icons (microphone, scroll) the padlock sits at the **icon's lower right**; course progress
shared with the units; sequential unlock animation; sound and haptics; title cream gradient and shadow
(`titleTop/titleBottom/titleShadows`, ✅ 2026-11-21); unit titles in `titleCream` (✅ 2026-11-21); data shown
(✅ 2026-11-21 "references are visual only": a third unit and the line running off the left edge are data).
🟡 items (line kept dim, screen-03 background) **are scored**.

## 0. Status of the critic-v1 findings

| v1 # | Finding | v3 status |
|---|---|---|
| 1 | Title descenders white | **fixed** (bottom rows #ECDCB2 / #EAD9AC, gradient covers the glyphs) |
| 2 | Title 15 % large | **fixed**, now 4 % small (417 vs 434 px) and 6 px low (see D14) |
| 3 | Connector line 1 px dim | **not fixed** (still 1 px #988534, AA rows #3A4E29/#69692F); kept dim as 🟡 conflict → D3 |
| 4 | Play triangle small | **fixed** (45 × 50 px vs 43 × 51) |
| 5 | Arch too wide/high | partly: apex y 28 (ok), visible span 485 px vs 429 px; colour still pale #F5D269 → D9 |
| 6 | Disc middle too light | **fixed** in the centre; new finding: the edge is darkened instead of lit (D4) |
| 7 | Diamond small/flat | size **fixed** (23 × 23 vs 22 × 21); colour too yellow and glow too big (D11) |
| 8 | Background base | **not changed** (🟡 conflict) → D8 |
| 9 | Mosque teal | partly: now #365A33 (greener, brighter) vs #314D26 → D16 |
| 10 | Padlock position | **fixed** (centre 5.25u above vs 5.5u); padlock 15 % short (D17) |
| 11 | Crescent bright | **fixed** (mean #21442A vs #274825) |
| 12 | Ring Ø small | **not fixed** (433 vs 441–449 px) → D6 |
| 13 | Locked ring colour | colour fixed (#C29A33) but flat; reference ring has highlights (D5) |
| 14 | Play disc pale, halo | **not fixed** → D10 |
| 15 | Badge colour/text | **not fixed** → D7 |
| 16 | Lattice hue | **fixed** (lines #6B7234 vs #59672D, contrast 25 vs 29 lum) |
| 17 | Pill content | **not fixed**; the owner's `swap.svg` (U5) is in the assets but the code still uses `Icons.sync_alt_rounded` → D2 |
| 18 | Divider long/pale, hard-coded | **not fixed** → D12 |
| 19 | Completed unit look | resolved by the owner (play disc + check badge, ✅) |
| 20–24 | Assets U1–U5 | U1 book, U2 padlock, U3 microphone, U4 scroll **delivered and used**; U5 delivered, **unused** (D2) |
| 25 | Background pattern U6 | delivered, but **4× too strong and a different geometry** (D1) |

## 1. Element measurements

| Element | Reference | Flutter v3 | Verdict |
|---|---|---|---|
| **Background base** | near flat **#013222** (zones #012F20…#013322, lum 30–34), top #012F20 (no lighter top) | **#022B21 / #012C21** in the body (lum 29–30), lighter top **#073529** (lum 38) | ~3 levels darker, bluer (B 0x21 vs 0x20, G 0x2B vs 0x32), lighter top not in the reference |
| **Girih pattern** | large irregular girih, 10-point stars ≈ 150–200 px (16–21u) across, organic polygons; lines **#0B3722** on #013222, contrast p99−p50 **3–7 lum**; almost absent behind the header (2 lum at y 40) | regular rectilinear grid of 8-point stars with "H" connectors, cells ≈ 110 px, uniform over the whole screen incl. the header; lines **#134533**, contrast **20–22 lum**; tile 95 % h, opacity 0.4, `girihLine` #2C6B4F | **4× too strong, teal instead of olive, wrong geometry, no fade at the top** |
| **Corners** | TL lattice to x 259 / y 196, BR from x 1284 / y 774; gold median **#B38B23**, p90 **#F8BA32**, p99 #FAE08C; strokes 2–2.5 px; **dark drop shadow** under each bar (relief) | same shapes and extents (TL 0–259 × 0–196, BR 1292–1493 × 782–940); median #B1944D, p90 **#D5AD59**, p99 #DEB45E; strokes 3 px; no shadow | **desaturated beige** instead of glowing orange gold; no relief |
| **Mosque** | x 446–739, minaret top y 68, base y 196 + cloud base to y 218; olive mean **#314D26**, dome #3D5427 | x 456–?, minaret top y 66, base y 200, no cloud; mean **#365A33**, dome #446737 | size ok; greener and ~8 levels brighter; cloud base / arched building missing (asset, low) |
| Crescent + star | 732–807 × 129–203, mean #274825, max #33542A | 720–819 × 122–214 (mask incl. pattern), mean #21442A, max #385A35 | ok |
| **Header arch** | visible span **x 690–1118 (429 px, 45.6u)**, apex y 24–31, core 3 px **#FFC029 / #F5B81F**, shoulders #FFD962, 1 px dark edge under the stroke (#0D2614), tails fade by y 113 | centred on the title (✅). Span **x 957–1441 (485 px, 51.5u)**, apex y 28–31 (4 px **#F5D269**), sides #E5BF57 → #B4973D, no dark edge, tails to y 124 | **11 % too wide; pale yellow instead of saturated gold** |
| **Title** | x 980–1413 × 134–200: **434 × 67 px**, centre (1196.5, 167); flat #F6EBCD | x 986–1402 × 140–206: **417 × 67**, centre (1194, **173**); gradient #FAF3DB → #EAD9AC (✅ token) | 4 % narrow, **6 px (0.65u) low** |
| **Divider** | gold x **1060–1331 (272 px, 28.9u)**, 3–4 px (y 226–229), core **#EBAA20 / #F5C336**, ends #9B7E1F → #5A5A20; outline diamond centre (1195, 228), 24 px tall | x **1051–1347 (297 px, 31.6u)**, 2 px (y 226–228), core **#DFB743 / #F5CC4F**, ends #968737; diamond centre (1199, 227), 23 px; extra dots by the diamond | 9 % long, thinner, paler/yellower (B 0x43–0x4F vs 0x20–0x36) |
| **Change-course pill** | rim x 68–355, y 122–196 (288 × 75), 2 px **#989043** with 1 px dark edges (#002316) both sides; fill #012F1F. Text x 121–263 (143 × 28), #E2E2C5. Icon ⇆ bold arrows x 292–324 (**33 × 32**), #E8E3C5; gaps text→icon 29 px, icon→rim 31 px | rim x 67–354, y 123–196, 2 px **#9C8430** (more orange), no dark edges; fill #052D21. Text x 105–260 (**156 × 29**), #E4DDC4. Icon `Icons.sync_alt_rounded` x 282–311 (**30 × 22**); gaps 22 / 43 px | box ok; icon is an icon-font glyph although `ui/glyphs/swap.svg` exists; text 9 % wide, content 10–16 px left |
| **Active ring** | centre (1017, 548); outer x 799–1235, y ≈ 322–771 → **Ø 441–449 (≈ 47.3u)**; rim 4 px, brightest pixel every 15°: sides **#FABE30 / #F8BF27**, top/bottom **#FFD548 / #FAD351**; 1 px dark contact edges (#063418 in, #012E1D out); inner glow 12 px (#193D20 at the rim), outer glow 14 px (#13391E → #03321F) | centre (1017.5, 547.5); outer x 801–1233 → **Ø 433 (46u)**; rim 3 px + AA, **flat #EAAA16** at every angle; no dark edges; inner glow 22 px (#173922), outer 18 px (#253F1F → #032C20) | **ring ~10 px small; rim darker/more orange and flat (no top/bottom light); glow slightly wider** |
| **Locked ring** | outer x 170–611, y 322–771 → **Ø 441–449**; rim 3–4 px: top **#FBE269 / #FFE06E**, bottom **#FDC849**, sides **#B48E2A–#C79028**; 1 px dark edge outside (#0C2C13 / #042B1C), **contact shadow under the ring** (#001411 → #052316, 6 px) | x 175–608 → **Ø 433**; rim 3 px **flat #C29A33**; no edge, no shadow | small; flat (reference ring is lit top and bottom) |
| **Inner disc** | rim x 199–200 / 583–584 (#154F37 / #104A30, 2 px) → **Ø 385**; vertical: top #134A34 → y 480 #053C27 → 540 #033725 → bottom #013623; **edge lit**: radial lum 40 (r 150) → 47 (r 189) → 54 rim (r 192); ring→disc gap 28 px, lum 32 → 36 towards the ring | rim x 202–203 / 580–581 (#10492E, 2 px) → **Ø 379**; top #0E3A29 → 480 #043B26 → 540 #033926 → bottom #013524; **edge darkened**: lum 40 (r 150) → **31** (r 186) (inner vignette 0 → 25 % black, stops 0.86–1); 1–2 px dark gap between rim and fill at the top (#043025); gap 21 px, flat #022C21 | gradient ok in the middle; **edge inverted (sunken instead of glassy)**; top ~5 levels dark |
| Disc bottom lattice | band y 668–740, contrast 4 → 44 lum, lines #59672D (lock) / #6C732F (active) | band y 668–730, 1 → 29 lum, lines #6B7234 / #807A25 | ok |
| **Progress badge** | y 284–373, x 974–1064: **Ø 90**, centre (1019, 328.5); vertical gradient **#F8C141 → #F3B52A → #E7A415**; **dark contact shadow** around the lower edge (#052816 → #022415); text «0%» 46 × **26** px, y 315–340, #12341C | y 285–376, x 972–1063: Ø 91, centre (1017.5, **330.5**); radial **#FCCA51 → #F5BB3A** (pale, almost flat); **gold glow** around it (#194129 → #29552D, gold 35 % blur 1.6u); text 46 × **22** px, y 321–342, #163722 | bottom 14 levels too light; glow instead of shadow; text short and 4 px low |
| **Play disc** | x 965–1074, y 418–527: Ø 110, centre (1019.5, 472.5); **#F4E1A8 → #F4DD9A → #F3D887** (warm), **dark shadow** under it (#223422, #08301F) | Ø 110 (963–1072 × 419–527); **#F9E9B8 → #F6E3AA** (pale), **light halo** under it (#163B24 → #0B3D27, goldHighlight 18 %) | colour too pale; halo instead of shadow |
| Play triangle | 1003–1045 × 448–498: **43 × 51**, centroid (1018.5, 472.8), #033421 | 1003–1047 × 448–497: **45 × 50**, centroid (1018.8, 472.8), #013321 | ok |
| **Unit titles** | locked x 303–477 × 560–666 (**175 × 107**), active 913–1130 × 562–663 (218 × 102), #F3EBCC | locked 298–484 × 551–663 (**187 × 113**), active 912–1121 × 558–663 (210 × 106), #F7EFD6 (✅ token) | locked title 7 % large, both start 4–9 px higher |
| **Book (U1)** | 327–466 × 441–539: **140 × 99**, centre (396.5, 490), mean #EEDEA9, pages #F1E4BB → #F1DDA9, bright bottom edge #FCE592 | 322–461 × 440–537: **140 × 98**, centre (391.5, 488.5), mean #EDD5A0, pages #F3DFB3 → #F0D7A6, gold edge #BE993B | ok (edge slightly darker: asset, low) |
| **Padlock (U2)** | shackle top y 462, shackle 378–413 (36 px), body **368–422 × 487–529 (55 × 43)**, total **68 px tall (7.2u)**, centre (395, 496); body #286947 (p10 #1D5D40, p90 #2C714C) | shackle top y 470, 376–408 (33 px), body **363–421 × 490–527 (59 × 38)**, total **58 px (6.2u)**, centre (392, 498.5); body #266445 (p10 #12553C) | 15 % short; body squatter (asset shape) |
| **Connector line** | y 545–548: **2 px core #FCBF34 / #E9B433**, AA rows #706F25 / #6E6D26, **1 px dark edges** #002A1C / #00281D; x 611–799 | y 546–548: **1 px #988534**, AA #3A4E29 / #69692F, no edges, no glow | **far too dim and thin** (unchanged) |
| **Diamond** | 697–716 × 536–557 (**22 h × 20 w**), centre (706.5, 547); orange **#F0B024** body, highlight #FFE76D only on the top edge, bottom #F7AF1A; almost no glow (#153D1F at −14 px) | 694–716 × 536–558 (**23 × 23**), centre (705, 547); gradient **#FDE471 → #F1C84C → #E5AC27** (yellow); **glow blob** #2C4624 at −14 px (gold 30 % blur 1u r 2u + 35 % r 2.4u) | size ok; too yellow; glow ~2× too strong |

Phone (`phone-v3.png`, u = 10.82): geometry is consistent (ring Ø ≈ 46u, pitch 66.5u, the arch tail ends ≈ 60 px
before the rail: v1 defect fixed). **But every WebP asset is missing in this capture**: no mosque, no top-left
or bottom-right corner, and the locked reading unit (أساسيات التلاوة) shows **only the padlock, without the
book**. The SVG assets (crescent, padlock, microphone, girih) are there. Either the capture was taken before the
WebP images decoded, or they pop in late on a cold start: both must be checked (D13).

## 2. Unlock frames (`unlock-frames-v3.jpg`)

Sequence read left to right, top to bottom: completed unit with 100 % badge + check, light runs along the line,
diamond pops, padlock flies off, book sinks, play disc pops in, badge drops in, path glides, settled. The order
matches the plan and reads as one sequence (no more swapping). Glitches:

| # | Frame | What | Sev. |
|---|---|---|---|
| G1 | row 1, frame 3 | the sinking book is faded with `Opacity` over the dark disc and turns **grey-olive #ACAD81** (dirty) before it vanishes | low |
| G2 | row 1, frame 4 | the play disc fades in at partial opacity: it reads **grey #D7D1A3**, and the ring is still the dim locked colour while the «0%» badge (also half transparent, #B7AE49) has already appeared | low |
| G3 | row 2, frame 1 (glide) | the outgoing completed circle at the right is cut by a hard vertical edge. In the frames the cut coincides with the tile border so it cannot be confirmed there, but the code clips the `PageView` at `trackRightInset` = 17.75u from the rail (x ≈ 1330): see D15, the settled screens confirm the clip | medium (D15) |
| G4 | row 1, frames 1–4 | the completed unit shows the «100%» badge on top **and** the check badge at the bottom at the same time; consistent with ✅ "play disc + check badge", but two gold badges on one ring look busy. Owner may want the 100 % badge to fade once the check lands | info (owner) |

## 3. Differences

| # | Element | Difference | Sev. | Type | Fix (u = 1 % of the height) |
|---|---|---|---|---|---|
| D1 | Girih background | contrast 20–22 lum vs 3–7; teal #134533 vs olive #0B3722; pattern also behind the header | **high** | code | `girihLine` **#2C6B4F → #1A4022** at opacity 0.4 (line pixel ≈ **#0B3722**, contrast ≈ 6 lum), or keep the colour and set opacity **0.4 → 0.11**; add a vertical `ShaderMask` (dstIn) **0 % at y ≤ 20u → 100 % at y ≥ 38u** so the header stays clean |
| D1a | Girih geometry | regular 8-point grid with "H" bars, cells ≈ 110 px vs large irregular 10-point girih, stars 16–21u | **medium** | asset | new U6b prompt: large girih with 10-point stars ≈ 18u across, pentagon/bow-tie cells, thin uniform lines, seamless tile, ~2 stars per tile height (the U6 prompt itself asked for an 8-point lattice, which is why it differs) |
| D2 | Swap icon | `Icons.sync_alt_rounded` (icon font, 30 × 22) while the owner's `ui/glyphs/swap.svg` (U5) exists | **medium** | code | `SvgPicture.asset('assets/ui/glyphs/swap.svg', width: 3.5u, height: 3.4u, theme: SvgTheme(currentColor: cream))`; gap text→icon **2u → 3.1u**, horizontal padding **4u → 3.3u**, text size **3.4u → 3.15u** (143 px wide) |
| D3 | Connector line | 1 px #988534 vs 2 px #FCBF34 core with 1 px dark edges | **medium** | code + 🟡 conflict | unlit track: under-stroke **0.45u #00261A**, then stroke **0.25u #EAB233 at 100 %**, y snapped to a pixel row; lit part unchanged. If the owner keeps the "dim track" course rule, at least **#C9A23A at 100 % and 0.25u** (now 75 % and 0.22u) |
| D4 | Inner disc edge | edge darkened to lum 31 (vignette 0 → 25 % black) vs lit edge lum 47 in the reference; 1–2 px dark gap under the rim at the top | **medium** | code | replace the inner-shadow `RadialGradient(stops [0.86, 1], 0 → #40000000)` with a rim light: stops **[0.80, 0.985]**, colours **#000B422A → #FF0B422A** (≈ #0B422A at the edge); rim border **#10492E → #154F37**, drawn inside the fill (`BorderSide.strokeAlignInside`) so no gap shows |
| D5 | Ring rims | flat #EAAA16 (active) / #C29A33 (locked); no top/bottom light, no dark contact edges, no shadow under the locked ring | **medium** | code | paint the ring with a `SweepGradient` (or a vertical `LinearGradient` shader): active **sides #F8BC2C, top/bottom #FFD54A**; locked **sides #B98F2C, top #FBE068, bottom #FDC849**; add 1 px (0.1u) **#002316 at 70 %** strokes at r ± 0.26u; locked: shadow **black 35 % blur 0.6u offset y 0.3u** under the ring |
| D6 | Ring diameter | Ø 433 px (46u) vs 441–449 (≈ 47.3u) | **medium** | code | ring box and `_Geo.ring` **46u → 47.2u** (stroke centre radius 23.4u); keep the disc **40.8u → 41u**; re-anchor the badge (top −4.9u) and the check (`u*46` → `u*47.2`) to the new box |
| D7 | Badge | radial #FCCA51 → #F5BB3A vs vertical #F8C141 → #E7A415; gold glow vs dark contact shadow; text 22 px tall, 4 px low | **medium** | code + token conflict | `LinearGradient(top→bottom)` **#F8C343 → #E5A416** (`badgeTop`, `badge`); boxShadow **black 35 % blur 0.8u y 0.3u** instead of gold 35 % blur 1.6u (keep the gold flash only during completion); text **3.3u → 3.8u**, lift **0.45u** |
| D8 | Background base | #022B21 + lighter top #073529 vs flat #013222 | **medium** | code + 🟡 conflict | for screen 05: flat **#013222** with at most a ±2-level radial, no lighter top (owner decision, see §4) |
| D9 | Header arch | 51.5u visible vs 45.6u; pale #F5D269 vs #FFC029 | **medium** | code | `archW` **54u → 48u**; tint the SVG `ColorFilter.mode(#FFC029, srcIn)` (or a horizontal gradient #F5B81F → #FFD962 → #F5B81F); optional 1 px dark under-stroke (`Shadow` #0D2614 y 0.1u) |
| D10 | Play disc | #F9E9B8 → #F6E3AA vs #F4E1A8 → #F3D887; light halo vs dark shadow | **medium** | code | `playCreamTop` **#FBEDC4 → #F4E1A8**, `playCream` **#F4E0A1 → #F2D784**, gradient vertical (top→bottom); **remove** the goldHighlight 18 % blur 2u halo; keep black 35 % blur 1.2u y 0.4u |
| D11 | Diamond | yellow #FDE471 → #E5AC27; glow blob (two gold glows 30 % + 35 %) vs almost none | **medium** | code | gradient stops **[0, 0.2, 1] #FFE76D → #F2B32C → #ECAB1C**; permanent glow alpha **0.30 → 0.10**, radius **2u → 1.4u**; the lit/pop glow unchanged |
| D12 | Corners | p90 #D5AD59 (beige) vs #F8BA32; strokes 3 vs 2–2.5 px; no relief shadow | **medium** | code (or asset) | tint the corner images: `ColorFiltered(ColorFilter.mode(#F2B12C, BlendMode.modulate))` after raising them to full brightness, or a srcATop gradient **#FAD26A → #E9A41E**; add a shadow copy (black 45 %, offset 0.25u/0.25u, blur 0.3u). If the tint cannot reach #F8BA32, ask the owner for a saturated version (asset) |
| D13 | WebP assets on the phone | mosque, corners and the book are missing in `phone-v3.png` | **medium** (high if it happens on the device) | code | `precacheImage` for `book.webp`, `mosque.webp`, `corner_units_*.webp` when the courses screen builds (before `unitsRoute`), and give `Image.asset` a `frameBuilder` fade so nothing pops; re-capture the phone after `networkidle` + 500 ms |
| D14 | Title | glyph centre y 173 vs 167; 417 vs 434 px wide | low | code | title box top **−0.65u** (glyph centre 17.75u); font **7.2u → 7.5u** |
| D15 | Path clip on the right | the `PageView` is clipped at x ≈ 1330 (17.75u inside the rail edge): in `capture-v3-unit2/3` the completed unit (ring from x ≈ 1426) and its lit connector + diamond (x 1233–1426, diamond 1330) are **missing**, and a gliding circle is cut by a hard vertical edge | **medium** | code | let the track run to the rail edge: `Positioned(right: 0)` with the page offset kept by `padEnds`/a leading spacer of 17.75u, or `clipBehavior: Clip.none` on the `PageView` plus a 4u horizontal fade mask at the rail edge |
| D16 | Mosque | #365A33 dome #446737 vs #314D26 / #3D5427 | low | code | `unitMosqueTint` **#8C4A6A33 → #CC3C5426** (srcATop 80 %) |
| D17 | Padlock size | 58 px (6.2u) tall vs 68 px (7.2u); body squatter (59 × 38 vs 55 × 43) | low | code + asset | book padlock box **6.6u → 7.3u**, centre stays 5.5u above; the squat body is in the asset (low) |
| D18 | Divider | 31.6u vs 28.9u; 2 vs 3–4 px; #F5CC4F vs #F5C336; dots by the diamond; colours hard-coded (l. 425–431) | low | code | width **37u → 34u**, height **3.2u → 3.6u** (stroke ≈ 3.5 px); stops **#9B7E1F, #EBAA20, #F5C336, #EBAA20, #9B7E1F**, moved to `RateelColors` (`dividerEdge/dividerMid/dividerPeak`) |
| D19 | Pill rim | #9C8430 vs #989043; no dark edges | low | code | rim **#989043** 0.22u + 1 px (0.1u) **#002316** inside and outside |
| D20 | Locked unit title | 187 × 113 vs 175 × 107 | low | code | locked-title size **4.9u → 4.6u** only if both lines fit (active title is already 210 vs 218 wide: keep 4.9u there) |
| D21 | Unlock frames | G1 grey book fade, G2 grey half-transparent play disc and badge | low | code | book: scale 1 → 0.6 with opacity only in the last 30 % of its segment; play disc and badge: full opacity from their first frame, entry by scale only (0.4 → 1.08 → 1); start the ring colour lerp together with the badge drop |
| D22 | Mosque composition | no cloud base / arched building | low | asset | keep the library mosque (screen 03 ✅) unless the owner wants the reference composition |

## 4. Conflicts with DESIGN-SYSTEM tokens (for the owner, not to fix silently)

| Value on screen 05 (reference) | Token | Token status | Note |
|---|---|---|---|
| Unit ring 4 px, sides #F8BC2C, top/bottom #FFD54A, glow gold ~14 px | Active ring: 1.7 px #D8C35A, outer glow 28 % blur 2.4u | ✅ | the code follows the reference ring (#EAAA16, not the token); D5 makes it even closer to the reference. Owner: unit rings are their own style, or align to the token |
| Badge vertical #F8C343 → #E5A416, text #12341C, dark contact shadow | Gold fill flat #E2A51E, text on gold #132C1A | ✅ | bottom of the reference gradient ≈ token; text colour ≈ token |
| Connector line bright 2 px #FCBF34 before any progress | Path: line 3 px #D1A93C on dim track #265343, lit by progress | 🟡 (✅ rule for courses 2026-11-20) | still open from critic v1 |
| Background flat #013222 | Content background radial #07362A → #00271D | 🟡 | still open from critic v1 |
| Change-course pill: cream text, rim #989043 | Pill: gold text 3.3u, gold 2 px rim, fill #062D20 | 🟡 | reference text is cream |
| Corner gold #F8BA32 / median #B38B23 | screen-03 corners (glowing lattice) | ✅ for screen 03 only; screen-05 corners 🟡 | tinting the corners (D12) makes them differ from screen 03 |
| Unit tokens (`unitRing*`, `unitDisc*`, `playCream*`, `badge*`, `padlock*`, `girihLine`, `unitLine`, `unitDiamond*`, `unitMosqueTint`) | — | not in `DESIGN-SYSTEM.md` | add them as 🟡 |
| Divider colours hard-coded in `units_screen.dart` (l. 425–431) | rule "screens never hard-code a style value" | ✅ rule | move to `RateelColors` (D18) |

## 5. Score

- Layout and geometry (positions, pitch, badge, play disc, triangle, titles, book, padlock): 8.5/10.
- Code styling (girih strength, line, ring rims and size, disc edge, badge, play disc, diamond, arch, corners,
  background): 6.5/10.
- Assets (U1–U4 in and good; U5 unused; U6 wrong geometry; WebP missing on the phone capture): 7/10.

**Whole-screen fidelity: 7.2 / 10** (v1: 6.5). The jump in assets (book, padlock, triangle, title fix) is offset
by the background pattern, which is now the most visible difference on the whole screen. With D1–D15 applied:
≈ 8.3; with U6b and a saturated corner asset: ≈ 8.8.
