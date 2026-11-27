# Screen 29, profile: critic v1 (2026-11-27)

Reviewer: separate critic sub-agent (did not write the code). Build: web capture v6 (`?profile=1`, `&theme=light`).
Reference: `reference-dark.webp`, `reference-light.webp` (1844×853). Captures: desktop 1844×853 dpr 1 and **phone
915×412 dpr 2.625 (2402×1082), the primary check**: the reference scaled to 2402×1082 against the phone capture.

**Method.** All numbers are **px at the 1844×853 equivalent** (phone pixels × 1844/2402 horizontally, × 853/1082
vertically, i.e. the reference's own coordinates); u = 1% of height = 8.53 px. Boxes are rim/ink detections on the
pixels (scripts in the session scratchpad `critic/`: `meas.py`, `run1.py`, plus `tools/flutter-review/profile-measure.py`);
colours are 5×5 means or the peak pixel of a profile; radii are circle fits on the corner rim. "Desk" = desktop
capture, "phone" = phone capture mapped to the equivalent. Where desk and phone agree only one value is given.

**Not scored (owner ✅ in `DECISIONS.md`):** the rail scrolls and the selected item is scrolled into view
(2026-11-26, «the side rail may scroll so the settings gear fits as its 7th item … the selected item is scrolled into
view» ✅); the gear at the bottom of the rail (2026-11-25, «Gear at the bottom of the rail as in the reference» ✅); the
yellow light under the Quran drawn in code and the book as a ChatGPT asset (2026-11-27 ✅: only *how* it is made is
approved, its look is still scored). Texts and data come from the app (LESSONS-LEARNED): name, city, numbers, level
word and the avatar drawing are not defects; their layout, size, colour and type are scored.

**What already matches (within 4 px at desktop size):** title box (671–1065 × 119–179 vs 672–1066 × 117–179), name,
city, pin, all four labels and numbers (y 625–656 vs 625–655), «المستوى», card box (102–1588 × 219–455 vs
103–1589 × 219–456), panel, tiles (309×186 vs 306×185), level bar (1425×100), pill box (dark), separator (x 1110),
rim widths (card 3–4 px, tiles 2–3 px), fills of card/panel/tiles in both themes within ±3 per channel. Every text uses
the app style `readex()` (Readex Pro, height 1.2–1.25); no other font or ad-hoc TextStyle.

## Differences

| # | Region | Element | Reference (numbers) | Flutter v6 (numbers) | Sev. | Type | Fix proposal |
|---|---|---|---|---|---|---|---|
| 1 | Identity card | Quran on the stand | Gold-covered open book on a honey-brown wooden X rehal, ~205×135 px (x 245–440, y 300–440); light ref: **green** covers | Placeholder `courses/course_01.webp` (cream pages, yellow plastic-looking X stand), 175×115, light: washed out on cream | high | asset | A1 (dark) / A1b (light, owner to choose one book or two), `prompts/29-profile/images-v2.txt` |
| 2 | Identity card | Quran arch shape and line | Two-tier onion: apex y 229; row y280 x 266–403, y300 240–429, y320 219–438, then a shoulder step out to x 190–480 below y ≈ 330; band ≈ 6 px core + glow (14 px > 50%), colour #E2B833…#FFFFCD (dark), #E1A747 fading to the bottom (light) | Single smooth onion: y280 243–431, y300 209–464, y320 195–479 (≈ 30–35 px wider per side in the upper lobe), no shoulder step; line 0.3u = 2.5 px (4–6 px incl. glow) #F1CC5D; light: thin #E8A303 line + yellow outer halo | high | code | Redraw `_onionArch` as the reference: pointed top lobe ending at x ±110 at y 330, convex shoulder, vertical sides at x 190/480; stroke 0.7u with a 0.8u glow; dark colour pale gold #E6CF55→#F8F0A0 highlight; light: solid #D9A040 fading to 0 at the bottom, no outer halo |
| 3 | Identity card | Floor light under the book (dark) | Wide yellow-olive band: row y450 lum 70–142 from x ≈ 180 to 470, peaks lum ≈ 150–186 at the stand feet (x 240, 420; #A3A62C/#A6A231), reaches the card rim (y 455) | Narrow radial: row y425 peak lum 197 only between the feet, row y440 ≤ 91, row y450 lum 35 (= background): the light is **cut at y 441** (bottom of the 25u art box) | high | code | Extend the art box to the card bottom (or `Clip.none` below it), make the glow an ellipse ≈ 34u × 4u centred at y 52.6u, #D9C93A at 75% → 0, plus a brighter core 18u wide under the feet |
| 4 | Identity card | Floor under the book (light) | Soft **brown shadow** under the stand (#BB946C at 335,435), no yellow light | Yellow halo #F7E9B8 | medium | code | Light theme: replace `profFloorGlow` with a brown contact shadow (#9A6A3A at 35% → 0) |
| 5 | Identity card | Lattice arch behind the avatar | Lattice lines clearly visible: Δlum +22…+37 (p95), line colour #48673B / #688548 near the top, extent x 1100–1592, y 220–459, onion-arch **outline** visible on the right (x ≈ 1540); light: lines #E8D3B8 (Δlum −16) | Barely visible: Δlum +6…+7, line colour #123F23; x 1100–1459, no arch outline, different pattern (star-and-cross of the 11 tile); light #F8EBDA (Δlum −3) | high | asset + code | A5 lattice tile; colour dark #5E8A4A at 70%, light #E3CCAA; add the arch outline (0.25u, lattice colour); radial fade centred on the avatar |
| 6 | Identity card | Avatar ring | Pale-gold rim, even all round: left #F4E397, top #F7F6C5, bottom #F9EC83 (lum 229–242), ≈ 4 px, then a 1 px dark inner line #C89706; light: dark-gold outer line #C79C38/#D3A852 1 px, bright #FFD862 rim, and a contact shadow below (#C4891B, 422–426) | Gradient ring 0.6u = 5 px, top #FEE178 → bottom #E3B027 (lum 222 → 180: bottom 49 lum darker than the reference), no inner line; light: no outer line, no shadow | medium | code | Ring: solid #F6EBA0 with a 0.5 px highlight #FFFBD0 on top, 1 px inner line #C89706; light: add 1 px #C79C38 outline and a 0.6u contact shadow (#8A5A10 30%) |
| 7 | Identity card | Avatar disc brightness | Disc #E7AF03, lum 172 (owner check: round elements) | Disc #FCC302 (the avatar asset's background), lum 190: **+10% brighter**, more lemon (G 195 vs 175) | medium | code | Apply a slight darkening on the avatar only on this screen (ColorFilter.matrix ≈ ×0.92 R, ×0.90 G) or ask the owner whether the app avatars' yellow should be #E7AF03 everywhere |
| 8 | Identity card | Avatar size and position | Ring box 1225–1427 × 239–440, Ø 202, centre (1326, 339.5) | 1231–1426 × 246–441, Ø 195 (−7, −0.8u), centre (1328.5, 343.5) (+4 px low); phone centre x 1317.5 (−8.5) | low | code | `avatarD` 23 → 23.7, `avatarCy` 40 → 39.6 |
| 9 | Identity card | Card inner glow (dark) | Inside the rim: +20 lum at 3 px, +11 at 5 px, +4 at 8 px (#20471F at 3 px) | None: flat fill right to the rim (#013121 at 3 px) | medium | code | Inner glow on the card: rim colour 30% blurred 0.8u inside (`_Glass` inset layer) |
| 10 | All boxes | Corner radii | Card 39–40 px (4.6u), panel 39 (4.6u), tiles 35–36.5 (4.2u), level bar 42–43 (4.9u), pill 28.5 (h/2) | Card 30 (3.6u), panel 29 (3.4u), tiles 28.5 (3.4u), level 34 (4.0u), pill 28.5 | medium | code | `radius` 3.6 → 4.6u (card, panel), tiles 4.2u, `levelRadius` 4.2 → 4.9u |
| 11 | Identity card | Card rim colour (dark) | Core #FFFFC7 / #FAFDAF / #FFFEBA | #F6F3B8 (core 9–14 lum lower) | low | code | `profCardRim` → #FCFCC0 |
| 12 | Identity card | Text colours (dark) | Name/labels/numbers cool white #F1F6E7…#F4F5DA; city #F0FAE0 | Warm `leaderText` #FDF9DA; city #DAE1CD (−20 lum, dimmer than the reference) | low | code | City `profCity` → #E8F2DA; text keeps the app's cream (token, see conflicts) |
| 13 | Header | Arch line (light) | Crisp brown #915B1C, 4 px, no halo | Pale #CFAD82 (≈ 55 lum lighter) with a blurred halo; on the phone it nearly disappears | high | code | `profLArch` → #8E5A1E, no blurred copy in light |
| 14 | Header | Arch line (dark) | Core pale cream-yellow #FFFFC7, 5 px at x 600 (y 92), thin bright glow | Gold #DAB24B, 4 px (y 96) | medium | code | Tint the arch #F6EDA8 with highlight #FFFFD0; glow `profArchGlow` → #F5E38A 50% |
| 15 | Header | Arch apex height | Apex y 7–8 (x 869) | Apex y 15–16 (x 871): 8 px (0.9u) low | low | code | `archTop` 0.9 → 0.0u (keep the shoulder line at y 92) |
| 16 | Header | Quran emblem size | Dark: 102×51 (816–918 × 48–99), strokes ≈ 3 px #F0C030; light: 118×56 (825–943 × 47–103), brown-gold | 96×41 (821–917 × 52–93) both themes: 10–15 px too short | medium | code | `bookW` 12 → 12.6u and height 6.0u (aspect 2.0 instead of the SVG's 2.2); light: ask the owner (the two references differ) |
| 17 | Header | Title colour (dark) | Flat cream-white: top #F3F5E5, bottom #F4F2DB; shadow dark below | App title gradient: top #F3EBCF → bottom #EADBB1 (−20 lum, warmer) | low | code | Conflict with the app's title style (see conflicts); keep unless the owner asks |
| 18 | Header | Title weight (light) | 401×60, ink 5953 px | 393×59, ink 5628 (−5%) | low | code | None (within type tolerance), or weight 600 → 640 in light |
| 19 | Header | Divider under the title | y 194, visible x 698–1038 (340), line 3 px, colour #EAE376 (lemon-gold), diamond 17 px; light: y 198, #C19245 2 px | y 194, visible x 699–1027 (328), line 1–2 px, colour at x 790 #827936 (the fade starts at 25%: dim), diamond 17 px; light #DABB83 | medium | code | Line thickness 0.35u, fade from 60% instead of 25%, colour #EAD86A (dark) / #B8863A (light) |
| 20 | Header | Mosque (dark) | Dome #406C3F (lum 87), base without windows, box 180–469 × 20–213 | Same drawing and box, dome #2D5239 (lum 67, 20 darker), base windows visible | low | code | Mosque opacity/brightness +25% (or a lighter tint #4A7A4A) |
| 21 | Header | Mosque (light) | Different skyline: two minarets + two domes (x ≈ 220–540), beige #EBD2B8 fading down | The dark mosque recoloured #E0C2A3: one minaret + one dome (x 200–420) | medium | asset | A6 light skyline |
| 22 | Header | Crescent + star (light) | x 1307–1386 × 60–134 (79×74), flat #E3A030, solid star of the same colour, star outside the crescent | x 1391–1455 × 59–130 (64×71), gradient crescent, pale star; 84 px further right | medium | code | Light: crescent box 9.3u at right 33.8u, single flat colour #E3A030 for crescent and star |
| 23 | Background | Corner lattice (light) | Lines #DFC9AA (Δlum −26), large clear cells | #F6E8D8 (Δlum −7): almost invisible | medium | code | Light: opacity 0.55 → 1.0, tint #DCC5A3 |
| 24 | Background | Corner lattice (dark) | Line colour #516D41 (green-olive), background under it lum 28; reaches y 186 | #6B6819 (yellow-olive), background lum 38; reaches y 180 | low | code | Standard 03/12 corners (see conflicts); optional tint toward #55704A |
| 25 | Background | Content background (dark) | Header area #002B1E / #00291E, bottom #012317 | #053126 / #053226 (+6 lum, greener), bottom #002C22 | low | code | Conflict with the 03 background token (🟡), owner to decide |
| 26 | Stats | Tile dividers | y 601, width 166–180 px (≈ 20u), bright gold line (#85945F 60 px from the centre) | y 604–605 (+3–4 px), width 106 px (13u), dim at 60 px (background colour) | medium | code | `tileDivW` 13 → 20u, `tileDivCy` 70.6 → 70.4u, fade from 60% |
| 27 | Stats | Star glyph (النقاط) | Dark: 40×36 at y 501–537, shaded gold #FCDA6A → #AF9424 (mean #EDBD30); light: 49×49, 3D orange #FED769 → #C88B19 | Flat #F2CD5D, 42×40 at y 497–537 (4 px taller); light: flat #E8A303, 42×40 | medium | code | Star 36 px high, vertical gradient shader (#FFE070 → #C89A20; light #FFD860 → #D08A10) |
| 28 | Stats | Open book glyph (الدروس) | Bold cream line book 60×39 (999–1059 × 502–541), ink 827 px; light brown 67×43, ink 1158 | Header emblem SVG, thin: 55×34, ink 464 (−44%); light 57×34, ink 589 (−49%) | medium | asset | A3 line book (white, tinted in code) |
| 29 | Stats | Rank rosette (الترتيب) | Scalloped filled gold medal with dark star + two ribbon tails, 38×49 (light 45×57) | Material `workspace_premium` (hollow ring medal), 38×49 | medium | asset | A2 rosette |
| 30 | Stats | Flame (أيام متتالية) | Three-tongue flame, 35×38 at y 503–541 (light 44×52) | App flame `flame_gold_01`, 35×44 at y 497–541 (6 px taller, different shape) | low | asset | Ask the owner: keep the app's streak flame (consistency with 12) or A7 |
| 31 | Stats | Glyph gold | Mean of the reference glyphs #EBBC2A…#EDBD30 (saturated) | `profGlyph` #F2CD5D (B +44: paler) for star, pin, rosette, layers, pill star | medium | code | `profGlyph` → #ECBD2E |
| 32 | Stats | Labels (dark) | «أيام متتالية» 137×39, ink 1016 | 144×43, ink 1276 (+25%: heavier) | low | code | Weight 600 → 540 for tile labels (dark) |
| 33 | Stats / card | Shadows (light) | Below panel #E6D3BE, below tiles #F0DFCD, card/panel gap #EFDDC9 | #F0E1D2, #F7EADA, #F4E6D7: about half the depth | medium | code | Light shadow `#2E7A4A1C` → #7A4A1C 30%, blur 1.6u, y 0.7u |
| 34 | Stats / card | Rim colours (light) | Card rim top #B27B37, bottom #AF7B18; tile rim #D2C0A6 top → #AD8F6A bottom; panel side #D2C1AD | Card top #BA8642, bottom **#D49E5D** (lighter, inverted); tiles flat #C9B193; panel #EBD6BE (fainter) | low | code | Light: card rim #B27B37 both ends; tile rim gradient #D2C0A6 → #AD8F6A; panel rim #D2C1AD |
| 35 | Level bar | Layers glyph | Three stacked plates, 54×47 (1404–1458 × 729–776), gold #E3BD31 | Material `layers_outlined` (two plates) stretched 1.42×, 49×40 (1405–1454 × 732–772) | medium | asset | A4 layers glyph |
| 36 | Level bar | Lattice | Fine star lattice (cells ≈ 60 px), faint, fading across most of the bar (to x ≈ 1440 dark) | Coarser 11 tile (8u ≈ 68 px cells), stronger contrast on the left 45%, ends abruptly ≈ x 780 | low | code + asset | Use A5 at 7u cells, opacity 50%, fade over 85% of the width |
| 37 | Level bar | Pill text optical position | Text y 743–766 (centre 754.5) in pill 725–782 (centre 753.5): text 1 px **above** centre | Text y 746–770 (centre 758) in pill 727–784 (centre 755.5): text 2.5 px **below** centre, whole pill 2 px low (phone: text 747–770) | medium | code | Lift the text 0.3u → 0.6u; `pillTop` 84.9 → 84.7u |
| 38 | Level bar | Pill (light) | 322×63 (659–981 × 723–786), rim #0F4523 3 px, star 30×29 orange gradient, text ink 1380 (bolder) | 315×57, rim #114223 2.5 px, star 23×22 flat, text ink 1042 (−25%, weight 500) | low | code | Light only: pill h 7.4u, star 3.4u with gradient, weight 600; or keep one size for both themes (references differ) |
| 39 | Phone | Horizontal layout on the phone (915×412) | Reference scaled to the phone: card x 103–1589, tiles 157–465 / 517–824 / 875–1182 / 1237–1546, level 138–1563 | Everything sized in height-u, so on the wider phone it shrinks horizontally: card 125–1571 (−40 px, −2.7%), tiles 178–476 / 528–826 / 877–1174 / 1229–1527 (outer tiles 16–21 px inward, width 298 vs 308), level 154–1541, Quran art +20 px right, avatar −8 px | medium | code | Horizontal metrics (widths, centres, gaps) in units of the content width (1% of the 1687-px content box) instead of u; keep sizes of text and glyphs in u |
| 40 | Rail | Rail in the light theme | Cream rail with light tiles, dark icons, gold bubbles | Rail stays dark green (BACKLOG item; no ✅ decision) | medium | code | Light rail (app-wide, separate task; ask the owner) |
| 41 | Rail | Active item | Trophy (leaderboard) active; 6 items from the courses cap | Gear (settings) active, courses item scrolled under ☰ (scroll ✅ 2026-11-26; opening from settings is 🟡 2026-11-27) | low | code | Ask the owner which item is active on the profile (opened from settings → gear is consistent) |
| 42 | Identity card | Arch interior light | Arch top dark (#174123 at 335,300), light only around the book (#4B6A2B at 335,330) | Uniform light in the whole arch (#2B4D2B at 300, #3A562E at 330) | low | code | Radial centre to (0, 0.45), radius 0.45 |

Phone notes (primary check): every vertical position and size is identical on the phone (u-based); the phone adds item
39 only. Rim widths on the phone at native pixels: card 0.35u = 3.8 phone px (3 px equivalent), tiles 0.3u = 3.2 phone px:
match the reference (2–4 px equivalent). Texts are 2–3% narrower than the stretched reference on the phone because the
reference is stretched 2.7% horizontally to 2402×1082; that is not a defect (text must not stretch).

## Assets needed

All prompts, ready to paste, are in **`docs/flutter/prompts/29-profile/images-v2.txt`** (one subject per image, flat
magenta #FF00FF, glows and lights drawn in code; each block says which images to attach: the app screenshots from
`docs/flutter/app-references/` first, then the profile reference).

| Asset | For item | Block in `images-v2.txt` | Notes |
|---|---|---|---|
| Quran on the wooden stand (dark, gold book) | 1 | A1 (revised Q1) | Q1 of `images-v1.txt` improved: the dark and light references show **different books** (gold vs green covers); proportions, wood colours and the app screenshot added |
| Quran on the wooden stand (light, green book) | 1 | A1b | Only if the owner wants the light reference's green book; otherwise A1 in both themes |
| Rank rosette | 29 | A2 | Full colour gold, dark star |
| Open book line glyph | 28 | A3 | White, tinted in code (cream dark, #91570D light) |
| Layers glyph | 35 | A4 | Three plates |
| Seamless lattice tile | 5, 36 | A5 | White lines, tinted and faded in code |
| Light-theme mosque skyline | 21 | A6 | Light theme only |
| Streak flame (optional) | 30 | A7 | Only if the owner prefers the reference's flame to the app's |

## Conflicts with confirmed tokens (`DESIGN-SYSTEM.md`) — for the owner, not fixed silently

| Reference (screen 29) | Confirmed / proposed token | Status of the token |
|---|---|---|
| Tile radius 4.2u, card/panel 4.6u, level bar 4.9u | Radii: tile 3.0u, row 4.1u (side nav) | ✅ conflict |
| Tile rim 2 px #569177 with a dark fill #013322 | Glass capsule / tile: outline only, 2 px #1C4E38, no fill | ✅ conflict (colour and fill) |
| Avatar ring: pale gold #F4E397 ≈ 4 px + 1 px inner line | Active ring 1.7 px #D8C35A with inner radial glow | ✅ conflict (if the ring is meant as the app's "ring") |
| Glyph gold #EBBD2E (star, rosette, pin, layers) | Gold fill #E2A51E, pills #EDB120 | ✅ near (different hue) |
| Labels and numbers: cool white #F1F6E7, bold (~600), 3.5u / 5.25u | Text: Readex Pro, labels #FFFDF5, weight 340, size 4u | ✅ conflict (weight and size; the app's `leaderText` #FFFBDC is used) |
| Level pill: rim #E1CE62–#EDD95B 2–3 px, fill #002D1D, text #E7CF47 3.4u | Pill (03): outline gold 2 px, fill #062D20, text gold 3.3u | 🟡 close; gold hue differs |
| Card rim pale gold #FFFFC7 3–4 px + outer glow (+19…+25 lum at 3–6 px) and inner glow | Gold rim (selected) 1.2 px #DAA42A + 1 px #FFDA6B, glow gold 15% 2u | ✅ conflict (colour, width) |
| Background header #002B1E, bottom #012317 | Content background radial #07362A → #00271D | 🟡 |
| Title flat cream #F3F5E5 | App title gradient `titleTop` #FFFBEA → `titleBottom` #E9D7A8 (not in the table, used app-wide) | not in table |
| Dividers lemon-gold #EAE376 3 px | `videoDivider` #E7B142 (screen 07) | not in table |
| Corner lattice line #516D41 (green-olive) | Corners: screen 03/12 standard (owner's glowing lattice) | standard asset |
| Light theme (cream rail) | Light theme not designed yet; rail dark | ✅ "Dark theme first" (2026-11-20) |

## Fidelity scores (0–10)

| Variant | Score | Why |
|---|---|---|
| Dark, desktop 1844×853 | **6.5** | Layout and every text within 4 px; loses on the placeholder Quran and its arch/floor light, the faint avatar lattice, the ring style, smaller radii, short dim dividers and three placeholder glyphs |
| Dark, phone 915×412 | **6.0** | Same as desktop plus the horizontal shrink on the wider phone (card −40 px, outer tiles 16–21 px inward) |
| Light, desktop 1844×853 | **5.0** | Same defects as dark plus a pale arch line, missing light mosque skyline, wrong crescent, faint corners and lattice, half-depth shadows, washed-out Quran placeholder |
| Light, phone 915×412 | **4.5** | Light defects plus the phone shrink and the dark rail beside a cream screen (very visible on the phone) |

Comparison crops (reference left, Flutter right, phone size): `critic-v1-identity-dark-phone.jpg`,
`critic-v1-identity-light-phone.jpg`, `critic-v1-stats-dark-phone.jpg`, `critic-v1-header-light-phone.jpg`.
