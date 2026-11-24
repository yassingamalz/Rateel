# Screen 05 (course units): critic v1

Date: 2026-11-22. Branch `flutter/05-units` (working tree, uncommitted `app_flutter/lib/units/`).
Reviewer: separate critic sub-agent (did not write the code).

Compared:
- Reference `reference.webp` 1672×941, u = 9.41 px. The right rail (x ≥ 1497) is not scored (approved side nav).
- Flutter `capture-v1.png` 1672×941 (same size, same u). Phone `phone-v1.png` 2402×1082 (915×412 @2.625,
  u = 10.82 px). Completion `completion-frames-v1.jpg` (14 frames).

Method: pixels sampled with Python/PIL/numpy (scripts adapted from `tools/flutter-review/measure.py`):
gold runs along rows/columns through the circle centres, luminance profiles across rims, colour masks for
text, icons, badge, diamond, divider, arch; medians / percentiles over 15×220 px strips for gradients and
the lattice. All x/y are pixels in the 1672×941 frame.

Not scored (owner decisions 2026-11-22, given with the task): title on the right with the **arch centred on
the title**; corner ornaments **top left + bottom right**, reusing the **glowing lattice approved on screen
03** (approved 2026-11-21 with its radial fade); **completed unit = gold check badge on the ring**; sound and
haptics on completion. Also not scored: title cream gradient + shadow (`titleTop/titleBottom/titleShadows`,
✅ 2026-11-21); data shown (references are visual only, ✅ 2026-11-21), so the third unit and the line
running off the left edge are data, not a defect.

Placeholders waiting for owner assets are scored as **asset** defects (prompts U1–U6 in
`docs/flutter/prompts/05-units/images-v1.txt`).

## 1. Element measurements

| Element | Reference | Flutter v1 | Verdict |
|---|---|---|---|
| **Title** «وحدات المقرر» | glyph bbox x 980–1413, y 134–200: **434 × 67 px (46.1u × 7.1u)**, centre x 1196.5, y 167 (17.7u). Flat cream: #EFE9D4 top, #F3EBD3 mid, #F6EBCB bottom (no visible gradient) | bbox x 944–1442, y 135–211: **499 × 77 px (53u × 8.2u)**, centre x 1193. Gradient #F8F1DB → #E7D7AA (approved), **but descenders y 203–211 are pure white #FAF7EF/#FCFDFD** | **15 % too large**; **white descenders = bug** (ShaderMask rect is the `height: 1` text box, glyph parts below it are painted unmasked white) |
| **Divider** | gold line x 1052–1339 (288 px, 30.6u), y 227, 3–4 px, peak #F1BB34 / #F0B82E, ends #6A6521; gap around the diamond | x 1048–1350 (303 px, 32.2u), y 227, 2–3 px, peak #F1C548 / #F8D053 (paler, more yellow), ends #797634; small dots each side of the diamond | close; slightly long and paler |
| Divider diamond | outline diamond 55 × 24 px box incl. line stubs, centre x 1195.5, y 228, #FFC529 / #F8B329 | same box 55 × 23, centre x 1199, y 227, #F8D053 | ok |
| **Header arch** | gold stroke apex x 906, y 25–30 (4 px: #E9B135 #FFC029 #F5B81F #E9B021), visible span ≈ x 650–1150 (**≈ 500 px, 53u**), shoulders y ≈ 105, tails end y ≈ 150 | centred on the title (approved). Apex x 1199, **y 15** (1.6u), stroke #F5D269 4 px, span **x 905–1490 (585 px, 62u)**, tails down to y ≈ 175, right tail ends 7 px from the rail; on the phone the tail touches the rail | **too wide and too high**: it boxes the title and crowds the rail. Colour paler/yellower than #FFC029 |
| **Mosque** | x ≈ 438–719 incl. cloud base, minaret top y 68, base y 207; olive: dome #3B5327, minaret #305028, mean #2D4B26 | x 462–656, minaret top y 66, base y 192; mean **#1C4631**, peak #295338 (teal, dimmer); no cloud base | silhouette size ok; **colour cooler and ~30 % dimmer**; cloud base missing (asset composition, low) |
| **Crescent + star** | bbox 732–807 × 129–202 (76 × 74), mean **#294926**, max #35542D (very muted) | 732–806 × 128–197 (75 × 70), mean **#4A5727**, max #5B622B | position/size ok; **too bright/yellow** |
| **Change-course pill** | rim x 68–355, y 123–196 (288 × 74 = 30.6u × 7.9u), rim 2 px peak #989043 / #93883D with dark edges, fill #012E20 (bg #002C1E). Text x 121–263 (143 × 28), #E9E7CB. Icon x 292–324 (33 × 32 = 3.5u × 3.4u), bold double arrows. Gaps: text→icon 29 px, icon→rim 31 px | rim x 68–354 same box, 2 px #82722C / #636129, fill #052D21. Text x 105–260 (156 × 29), #E9E1C8. Icon `Icons.sync_alt_rounded` x 282–311 (**30 × 22**). Gaps: text→icon 22 px, icon→rim **43 px** | box ok; content shifted 10–15 px left; **icon is an icon-font glyph (U5)** |
| **Outer ring, active** | outer extents x 799–1235 (437 px), bottom y 766–769 → **Ø ≈ 437–440 px (46.6u)**, centre (1017, ≈ 549). Rim 4 px #B58D1D **#F2B41C #EAAA16** #DBA327. Outer glow ~20 px (#183B18 → #05311D), inner glow ~20 px (#173B20 → #03301D) | x 802–1233 (432), y bottom 760–763 → **Ø 431 px (45.8u)**, centre (1017.5, 547.5). Rim 4 px #EAAA16 ×3. Outer glow ~22 px (#153924 → #042E22), inner ~22 px | rim colour and glow match; ring **≈ 7 px (0.8u) small** |
| **Outer ring, locked** | x 171–610 (440), y 323–770 (448) → **Ø ≈ 444 px (47.2u)**, centre (390.5, 546.5). Rim 4 px #766728 **#B99133 / #CE992F** #AC8322 #A1832E, faint dark halo (#0B2A14) | x 176–607, y 332–763 → **Ø 431 (45.8u)**, centre (391.5, 547.5). Rim 4 px **#A1832E** flat | ~13 px small; rim ~15 % dimmer |
| **Inner disc** | rim at x 197–198 (#134630 / #0D432F, 2 px) → **Ø ≈ 386 px (41.0u)**; ring→disc gap ≈ 23 px. Vertical gradient at x = cx−60: y 380 **#104631** → 440 #083E2B → 500 #043927 → 540 **#023625** → 560 #013524 → bottom #013825 | rim x 200–201 #10492E 2 px → **Ø ≈ 382 (40.6u)**, gap 21 px. y 380 #0C3C2A → 400 **#0E4430** → 500 #0C422E → 540 **#0B402D** → 560 #0A402D → 700 #073B29 | size ok; **middle of the disc 6–9 levels too light** (gradient too flat) |
| Disc bottom lattice | band y ≈ 675–745; contrast p98 − median 9 → 35 lum; lines warm olive **#2C4F2B … #3A572F** on #013825 | band y ≈ 675–745; contrast 9 → 32 (same); lines teal **#1E543C / #1F5336** on #073827 | intensity matches; **hue too cool/teal** |
| **Progress badge** | x 974–1064, y 284–373: **Ø 90 px (9.6u)**, centre (1019, 328.5). Gradient #F8C349 → **#E4A518**. Text «0%» 46 × 26 px, y 315–340, #14371D | x 972–1063, y 285–376: Ø 91–92 px (9.7u), centre (1017.5, 330.5). #FDCD57 → **#F5BA3A**. Text 46 × 22, y 321–342, #153923 | size/position ok; bottom of the gradient too light; text 4 px low and slightly short |
| **Play disc** | x 965–1074, y 418–527: **Ø 110 (11.7u)**, centre (1019.5, 472.5). Cream gold #F3DEA6 top → #F3DC96 → **#F2D784** bottom. Dark shadow under it (#03311F). **Triangle 43 × 51 px (4.6u × 5.4u)** #053422 | Ø 110, centre (1017.5, 472.5). **#F9EABD → #F5E3A9** (paler). Light halo under it (#17402B, goldHighlight 18 %). **Triangle 32 × 36 px (3.4u × 3.8u)** #023321 | disc ok; **triangle 30 % too small**; cream too pale |
| **Unit titles** | locked x 302–477 (176 w), y 560–667, centre 6.9u below the ring centre, #EFE7C9; active x 913–1130 (218 w), y 562–663, #EFE8C9. Line pitch ≈ 58 px | locked x 298–485 (188 w), y 555–663 (6.5u below), #F4ECD4; active x 912–1122 (211 w), y 558–664, #F2EBD2 | ok (±5 %) |
| **Locked icon (book)** | open book x 327–466, y 440–539: **140 × 100 px (14.9u × 10.6u)**, centre 6.1u above ring centre, cream #EDDDA9 (pages #F6E6B4, gold edges) | placeholder `nav/quran.svg` outline x 344–439, y 459–531: **96 × 73 px**, thin outline, #E1CE90 | **asset U1** |
| **Padlock** | emerald padlock with cream-gold shackle, x 367–422, y 451–527: **56 × 77 px (6.0u × 8.2u)**, body #276947, centre ≈ (394.5, 489) = **6.2u above** ring centre | rounded square tile + `lock.svg` glyph x 367–416, y 479–528: **50 × 50**, #267951, centre (391.5, 503.5) = **4.6u above** ring centre | **asset U2**; also positioned 14 px (1.6u) too low |
| **Connector line** | y 546–547, x 610–799; **2 px bright core #E8AD2B / #FFDB4F / #FFD13D**, ends #C69621, 1 px dark edge each side (#00291D / #002519), soft glow (#10361A → #0A361E) | y 547, x 609–804 (and on to the left edge, data); **1 px #988534** + AA rows #3A4E29 / #69692F, no edge, no glow | **far too dim and thin** |
| **Diamond node** | centre (706.5, 547.5), **24 px tall (2.55u)**, 20 px wide on the centre row, #EEB52D with highlight **#FFEA79**, glow above it (#BFAE4F at −12 px) | centre (704.5, 547.5), **19 px tall (2.0u)**, 18 px wide, flat **#DDA31F**, max #ECAB34, no glow (#042F23 at −12 px) | ~20 % small, flat, no glow |
| **Corners** | TL bright gold lattice to ≈ x 200 / y 150, gold median #A08525, p99 #FFFAD8; BR to ≈ x 1290 / y 780 (median #9F741A, p99 #FFC538) | screen-03 glowing lattice (approved), same extents, gold median #646521 (TL) / #5A5F1A (BR), p99 #F4EAD0 / #EAAA24 | approved asset; ~40 % dimmer because of opacity 0.75 + approved radial fade (info only) |
| **Background** | near-flat **#013222** (zones: #013222, #013322, #013121, #013021), top #002F20 (no lighter top); **faint large girih line pattern**, contrast p99 − median **5.5–7.1 lum** | radial: top #063529 / #053126, body **#022C21 / #01291F**; pattern contrast **0.7–1.6 lum** (none) | **pattern missing (asset U6)**; base ~5 levels darker and cooler (G 0x2C vs 0x32), lighter top not in the reference |
| Layout | ring centres (390.5, 546.5) / (1017, ≈549); pitch 626.5 px (66.6u) | (391.5, 547.5) / (1017.5, 547.5); pitch 626 px (66.5u); phone pitch 722 px = 66.7u | ok |

Phone (`phone-v1.png`, u = 10.82): ring Ø ≈ 494 px (45.7u), pitch 66.7u, proportions consistent with the
desktop capture. The arch's right tail reaches the rail (x ≈ 2196 vs rail edge ≈ 2204): visible defect.

Completion frames: ring fill with light head, 100 % badge, check badge popping at the bottom of the ring,
light running along the line, diamond pop, padlock off, next badge drops in, path glides: matches the plan.
After completion the completed unit shows the **bare cream play glyph without its disc** (type icon of a
`video` unit), which reads weaker than the open state (low).

## 2. Differences

| # | Element | Difference | Sev. | Type | Fix (u = 1 % of height) |
|---|---|---|---|---|---|
| 1 | Title | descenders painted pure white (#FCFDFD) under the gradient | **high** | code | ShaderMask must cover the whole glyph: give both Text widgets `height: 1.3` (or wrap the ShaderMask child in `Padding(bottom: 0.25 × size)`) so the shader rect includes descenders; re-centre (title centre y 17.7u) |
| 2 | Title | 53u × 8.2u vs 46.1u × 7.1u (15 % large), reaches x 1442 | **medium** | code | font size **7.6u → 6.6u**; centre x stays `w − 31.7u`, glyph centre y **17.7u** |
| 3 | Connector line | 1 px #988534 vs 2 px #FFD13D core with dark edges and glow | **medium** | code | unlit track: stroke **0.25u**, colour **#E0AE30** at **100 %**, centred on a pixel row; add a 1 px dark edge (stroke 0.45u #00261A under it) and a glow (gold 25 %, blur 0.8u); lit part keeps goldHighlight. (Conflicts with the screen-03 path rule "dim track", see §3) |
| 4 | Play triangle | 32 × 36 px vs 43 × 51 px | **medium** | code | `play.svg` size **6.4u → 9.0u** (triangle 4.6u × 5.4u), keep optical offset left 0.5u |
| 5 | Header arch | 62u wide, apex 1.6u, tails to 18.6u, hits the rail on the phone | **medium** | code | `archW` **64u → 54u**, top **0.8u → 2.4u**, height **18.5u → 14u** (tails end ≈ 16u, shoulders ≈ 11u) so it frames the title from above without boxing it; stroke tint toward #FFC029 |
| 6 | Inner disc | middle 6–9 levels too light (#0B402D vs #023625 at 0.85 radius) | **medium** | code | RadialGradient centre (0, −1.0), **radius 0.85**, stops [0, 0.45, 1] = **#104631, #053C27, #013524** (or a linear top→bottom with the same stops) |
| 7 | Diamond | 2.0u, flat #DDA31F, no glow | **medium** | code | half-diagonal **1.05u → 1.3u**; vertical gradient **#FFEA79 → #E2A51E**; permanent glow gold 30 % blur 1.0u (r 2u) |
| 8 | Background base | #022C21/#01291F + lighter top #063529 vs flat #013222 | **medium** | code (token) | for this screen base **#013222** with at most a ±2-level radial; remove the lighter top. Owner decision needed (conflicts with the 🟡 screen-03 background, §3) |
| 9 | Mosque | mean #1C4631 teal vs #2D4B26 olive | **medium** | code | opacity **0.78 → 1.0** + `ColorFilter.mode(#3E5628, BlendMode.modulate)` (or srcATop tint), keep the bottom fade |
| 10 | Padlock position | centre 4.6u above ring centre vs 6.2u | **medium** | code | padlock centre **−6.2u** from the circle centre (`top: u*(23-6.2) - h/2`), box **6.0u × 8.2u** when U2 arrives |
| 11 | Crescent | mean #4A5727 vs #294926 | low | code | opacity **0.30 → 0.18** (or tint #35542D) |
| 12 | Ring diameter | 45.8u vs 46.6u (active) / 47.2u (locked) | low | code | `ring` **46u → 46.8u**; disc stays 40.8–41u |
| 13 | Locked ring colour | #A1832E vs peak #B99133/#CE992F | low | code | rendered locked rim **#BE9330** (unitRingLocked at full alpha, check any opacity on the locked node) |
| 14 | Play disc colour | #F9EABD → #F5E3A9 vs #F3DEA6 → #F2D784; halo vs dark shadow | low | code | `playCreamTop` **#F4E0A8**, `playCream` **#F0D27C**; drop the goldHighlight 18 % halo, keep the black shadow (25 %, blur 1.2u, y 0.4u) |
| 15 | Badge | bottom #F5BA3A vs #E4A518; text 4 px low, 22 vs 26 px tall | low | code | `badge` **#E4A518**, `badgeTop` **#F8C349**; text **3.3u → 3.6u**, lift 0.4u |
| 16 | Disc lattice hue | teal #1F5336 vs olive #3A572F | low | code | lattice tint **#3A572F** (screen-05 only, or token decision) |
| 17 | Pill content | text 10–15 px left of the reference, gap icon→rim 43 vs 31 px | low | code | gap text→icon **2u → 3.1u**, right padding **4u → 3.3u**, icon box **3.5u** (with U5) |
| 18 | Divider | 32.2u long, paler #F8D053, dots by the diamond | low | code | width 37u → **33u**; peak colour **#F1BB34** (no hard-coded hex in the screen: move to a token) |
| 19 | Completed unit | bare cream play glyph without disc after completion | low | code | keep the cream disc and swap the triangle for `check.svg` (plan: "play disc morphs into a check") — confirm with the owner |
| 20 | Reading icon | placeholder `nav/quran.svg` outline 96 × 73 vs filled book 140 × 100 | **high** | asset | **U1** open book; display box 14.9u × 10.6u, centre 6.1u above the ring centre |
| 21 | Padlock | rounded tile + glyph vs emerald padlock with shackle 6u × 8.2u | **high** | asset | **U2** |
| 22 | Practice icon | placeholder `nav/training.svg` | medium | asset | **U3** microphone |
| 23 | Test icon | placeholder `nav/lessons.svg` | medium | asset | **U4** scroll with check |
| 24 | Swap arrows | `Icons.sync_alt_rounded` (icon font, 30 × 22) vs bold arrows 33 × 32 | medium | asset | **U5** (CRITIC.md: no icon-font glyphs) |
| 25 | Background pattern | missing (contrast 1 vs 6 lum) | **high** | asset | **U6** seamless girih tile, then draw it at ~6 lum contrast (lines ≈ #0B3C2A on #013222) |

## 3. Conflicts with DESIGN-SYSTEM tokens (for the owner, not to fix silently)

| Value on screen 05 | Token | Status of token | Note |
|---|---|---|---|
| Active unit ring 4 px (0.42u) #EAAA16, glow gold 16–30 % | Active ring: 1.7 px #D8C35A, outer glow 28 % blur 2.4u | ✅ | Reference ring is thicker and more orange; the code follows the reference. Owner: keep #EAAA16 for unit rings or align to the token |
| Badge gradient #FFD25E → #F2B32E, text #062016 | Gold fill flat #E2A51E, text on gold #132C1A | ✅ | Reference badge is a gradient #F8C349 → #E4A518, bottom equals the token; text colour differs |
| Change-course pill: rim #C29A33 80 % 2 px, fill #062D20 60 %, **cream** text 3.4u | Pill: outline gold 2 px, fill #062D20, **gold** text 3.3u | 🟡 | reference has cream text |
| Connector line 0.22u #C9A23A 75 %, diamond #ECAB1C 1.05u | Path: line 3 px #D1A93C on track #265343, node #FCC24A r 1.3u | 🟡 | the reference unit line is bright gold even before progress; the screen-03 "dim track, lit by progress" rule (✅ for courses) would keep it dim. Owner decides whether units follow the course rule or the reference |
| Background base #013222, no lighter top (reference) | Content background radial #07362A → #00271D | 🟡 | code uses the token; reference is lighter and flatter |
| Unit tokens `unitRing`, `unitRingLocked`, `unitDisc*`, `playCream*`, `badge*`, `padlock*`, `unitLine`, `unitDiamond` | — | new, proposed | they are in `RateelColors` (good) but not in `DESIGN-SYSTEM.md`; add them as 🟡 |
| Divider gradient `Color(0xFFB2983A)`, `#EFC246`, `#F8D053` hard-coded in `units_screen.dart` (l. 635–641) | rule "screens never hard-code a style value" | ✅ rule | move to `RateelColors` (shared with screen 03's divider if identical) |

## 4. Score

- Layout and geometry (positions, pitch, ring, disc, badge, play disc, titles): 8.5/10.
- Code styling (title bug, line, triangle, arch, disc gradient, background tone, mosque): 6.5/10.
- Assets (6 placeholders, including the very visible book/padlock and the background pattern): 4/10.

**Whole-screen fidelity: 6.5 / 10.** With fixes 1–10 applied: ≈ 7.5; with U1–U6 delivered: ≈ 8.5–9.
