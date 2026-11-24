# Critic v3: courses (learning paths), Flutter v4 with the owner's assets

Fidelity score: **7.5/10 for the whole screen** (v2 whole-screen score: 6.5). There is no separate "code-only" score.

This round has **no exclusion list** (`CRITIC.md`, "No exclusions"). Only one difference is skipped: the right rail. The owner-approved side navigation (DECISIONS ✅ 2026-11-20, "Closed rail: style C", "Closed rail approved by the owner") replaces the reference rail. Because of it, the content's right edge is at **x1672 in the reference** and **x1686 in Flutter**, so the content is 14 px wider. Every other difference is scored, including those that rounds 1 and 2 listed as "accepted".

## Method

- **Images.** Reference `ref-03.png` is 1847x851. Flutter `c-settled.png` is 1844x853. They are not resampled. 1 u = 1% of the height = 8.53 px (Flutter), 8.51 px (reference).
- **Positions** are given in two forms:
  - absolute x
  - "rail": the distance from the content's right edge. Header and cards are anchored from that edge; the mosque and the left corner are anchored from the left.
- **Scripts.** `scratchpad/critic3s/a1.py`…`a8.py` are new (asset bounding boxes, arch profile, mosque column profile, divider profile). `v2a/v2b/v2c.py` are the round-2 scripts, re-pointed to the new captures. All are run with `python3 -I`.
- **Masks.**
  - gold: R>110 and R−B>55
  - faint gold: R−B>25 and R>60
  - cream: L>150 and R−B<60
  - mosque: G more than 14 above the row background and R−B<25
  - Colours are p97 / median of the masked pixels, or single pixels on 1-px profiles.

## Matching (within ±3 px or the same hex), not repeated in the table

- **Card geometry.**
  - Pitch, card sizes and tops: locked 617x426, active 627x434.
  - Corner radius: 41.5 / 42.0 vs 42.0 / 41.5.
  - Locked rim: top, bottom and sides. Sides at y650: #28654F vs #27634D. At y720: #3C7960 vs #3D7861 (v2 N4 fixed).
- **Active card content.**
  - Pill box: 244x53 vs 245x55, inset 329-572 vs 328-572.
  - Pill text: 165 vs 168 px wide (v2 #7 fixed).
  - Star glyph: 39x42 vs 40x42.
  - Title: 348x58 vs 353x58, right inset 57 vs 55.
  - Rule: y +204.
  - Description: right inset 57.
  - Play disc: Ø70 vs Ø71, fill #43552A vs #43572A.
  - Bar fill: #EBB335 vs #ECB536.
- **Locked card 2.**
  - Lock disc: 66x66 vs 68x64.
  - Lock glyph: 23x28 vs 22x28.
  - Rule: 73-480 vs 78-479.
- **Node next to the active card.** Ø22, 12 px from the card, core #F9C049 vs #FDC651.
- **Card fill gradient.** Within 2 levels at every 30-px row.
- **Course completion.**
  - «100%» no longer touches the bar: the bar ends at x1497 and the text starts at x1513, a 16 px gap (v2 N1 fixed).
  - The title no longer blinks out: the cross-fades now overlap, 0.4-0.5 (v2 N2 fixed).

## Differences

**Severity:**
- **high** is visible at a glance.
- **medium** is visible side by side.
- **low** is only found by measuring.

**Type:**
- **code**: fix in Flutter.
- **asset**: regenerate the image; a ChatGPT prompt is given below.
- **owner**: a choice that differs from the reference; the owner must decide.

### Header and decor (new assets)

| # | Element | Reference | Flutter v4 | Δ | Sev. | Type | Fix |
|---|---|---|---|---|---|---|---|
| A1 | **Header arch: shape and size** | Apex y15 at x864 (rail 808).<br>Shoulders y105 (rows 105-107).<br>Flanks: x449 / 1268 at y160, then they **fade out**: right flank #B79335 at y150 → #5B612B at y182 → background by y≈220. The left flank is already dim at y150 (#585926).<br>Visible bbox ≈ x430-1293, y15-≈220 | Apex y17 at x874 (rail 812).<br>Shoulders **y123** (rows 123-128).<br>Flanks stay full gold (#BD922C at y230) down to **y252** at x445 / 1302.<br>Bbox x445-1302, y17-252 | Shoulders +18 px. Flanks +32 px longer and not faded. Apex→shoulder distance 106 vs 90 px (vertical scale 1.18) | **high** | code | Box height 31.1u → **26.4u** (keep `width` 102.8u, `top` 0.6u, `BoxFit.fill`). This puts the shoulders at ≈ y106 and the flank ends at ≈ y220. Wrap the SVG in a `ShaderMask` (`BlendMode.dstIn`, vertical `LinearGradient` white → transparent, stops **0.45 → 0.92**) so the flanks fade as in the reference |
| A2 | Header arch: line weight and colour | Line 3-4 px. Top segment peak #FEE989 (pale gold) | Line **6 px** (rows 72-77 at x740). Peak #E7C159 | 2x thicker, more saturated | **medium** | asset | The filled path cannot be thinned in code. Prompt **P-A2** |
| A3 | Header centre axis | Apex 808, emblem 810, title 807, divider diamond 810 from the rail (mean ≈ 808.5) | Apex 812, emblem 812, title 814, diamond 812 | 4 px further from the rail | low | code | `headerCenterX`: `w − 95.2u` → **`w − 94.8u`** |
| A4 | **Open-Quran emblem** | x803-921, y67-126, **119x60**, centre y96.5. Filled gold pages with a thick rim and a base, p97 #FBD35A | x816-932, y72-121, **117x50**, centre y96.5. Thin outline book, p97 #FDCD47 | 10 px shorter (−17%); top +5, bottom −5. Asset aspect 2.2 vs 2.0 | **medium** | asset + code | Interim code: `width` 14.3u → **14.0u**, `height` 6.5u → **7.0u**, `top` = 11.4u − **3.55u** (= 7.85u, y67), `BoxFit.fill`. Final: prompt **P-A4** (filled pages, aspect 2:1) |
| A5 | **Mosque silhouette: position and size** | Minaret x205-245, finial y107 at x225.<br>Dome finial at x≈320.<br>Visible body ends at **y≈273** and fades out between y255 and y275 (row coverage 186 → 130 → 0). No ground strip | Minaret x180-220, finial y107 at x200.<br>Dome finial x≈290.<br>**Solid ground strip** y≈290-309 across x≈101-440 (row coverage 332 at y295) | 25-30 px too far left. 5% small. The bottom extends 36 px lower and does not fade | **medium** | code | `width` 40u → **42.2u**, `left` 11.75u → **14.0u**, `top` 12.3u (unchanged). Add a `ShaderMask` (`dstIn`, vertical, opaque until **0.66**, transparent at **0.80** of the box height); this hides the ground strip |
| A6 | Mosque brightness | Dome #2B5433 on a background of #022C21 (ΔG +40) | Dome #355C3E (ΔG +48) | +20% | low | code | Wrap it in `Opacity(0.83)` |
| A7 | **Crescent and star: size and shape** | Bbox x1369-1451, y66-143, **83x78** (wider than tall). Rail 221-303 | Bbox x1381-1465, y59-150, **85x92**. Rail 221-305 | 14 px taller. Asset aspect 0.93 vs 1.06 | **medium** | asset + code | Interim code: `width` 10.7u → **9.75u**, `height` 11.5u → **9.15u**, `top` 6.55u → **7.75u**, `right` 25.45u → **25.9u**, `BoxFit.fill`. Final: prompt **P-A7** |
| A8 | Crescent: star colour | Star dim olive, median **#7A7129** (≈ 55% gold). Crescent median #BD952D | Star full gold #CC9824. Crescent #CF9C26 | Star too bright; crescent +1 step | **medium** | asset | Prompt **P-A7**: star separate at about 55% opacity. Alternatively, put `opacity="0.55"` on the star path in `crescent_star.svg` |
| A9 | **Corner ornament, top left: size** | Lattice reaches x+y = **213**: (208,0) to (0,≈205). Bbox x17-208, y0-189 | Reaches x+y = **180**. Bbox x5-177, y3-172 | −16% | **medium** | code | `width` 24.7u → **29.2u** (height follows 924/1096) |
| A10 | Corner ornaments: style | Thick embossed strokes: runs of 8-11 px at row 100. Dark inner shadow and bright gold edge, p97 #94883A | Flat 1-4 px lines (opacity 0.75), p97 #7F7426 | Different look: carved vs wire | **medium** | asset | Prompt **P-A10** |
| A11 | Corner ornament, top right: size and opacity | Inner diagonal at 158 px from the rail at y0, reaches the rail band at y≈130. p97 #897A38 | 135 px from the rail at y0, reaches it at y≈113. p97 #666525 (opacity 0.6) | −15%, dimmer | low | code | `width` 17.6u → **20.6u**, opacity 0.6 → **0.8** (`right` 1.4u is correct: 16 vs 18 px) |
| A12 | **Title divider: gradient** | Brightest next to the diamond and fading outward:<br>#F0C348 (−55), #E8B840 (−115), **#B2983A (−155)**, #878136 (−175), #4F5E2F (−195).<br>Right side peak #F8D053. Diamond p97 #FFC546 | **Flat #D5A52C** from −175 to +175, then a hard end (#394E28 at ±195). Diamond flat #D5A52C | No fade, and too dark next to the diamond | **medium** | code | Wrap `title_divider.svg` in a `ShaderMask` (`BlendMode.srcIn`), horizontal `LinearGradient`:<br>colours `[#00B2983A, #B2983A, #EFC246, #F8D053, #EFC246, #B2983A, #00B2983A]`<br>stops `[0, 0.12, 0.33, 0.5, 0.67, 0.88, 1]`<br>Move the colours to `RateelColors` |
| A13 | Title divider: geometry | Line y266-268, gold span x680-1051, diamond 27x26 | y266-268, x685-1062, diamond 26-28 px tall | — | — | — | matches |
| A14 | Title | Bbox 669x75, cy 199, stroke 10 px | 663x81, cy 200, stroke 11 px | +6 px tall (Readex ascenders) | low | code | Weight 560 → **530** |

### Cards, path, glyphs, icons

| # | Element | Reference | Flutter v4 | Δ | Sev. | Type | Fix |
|---|---|---|---|---|---|---|---|
| B1 | **Connector lines and nodes** | **Every segment is gold.**<br>Active → card 2: gradient #A3852E (at card 2) → #FDC651 (at the node).<br>Card 2 → card 3: #A3852F → #E8BC4D, node **Ø30, core #FBBE23**, 5 px from card 2, gold glow | Active → card 2: **dim #204739 → #49643E**; only the node is gold.<br>Card 2 → card 3: **#265343 flat**, node #265343 Ø22, no glow | Both visible segments and the second node differ | **high** | code / owner | To match the reference: draw every segment and node in the "on" style: `lineOn`/`nodeOn` true for all `i`. Use the gradient #A3852E → #F5C04C toward the node; this replaces the flat `pathLine`. The "dim until completed" rule is 🟡 in DECISIONS: **ask the owner** (Q1) |
| B2 | Percent text | «**0%**», with the bar fill at 107/351 px (≈ 30%) | «**30%**», fill 101/338 | Different text. The reference is internally inconsistent | **medium** | owner | Q2. To match the reference literally the text must read «0%» while the bar shows 30%; recommended instead: keep the real value and make the demo bar and text agree |
| B3 | Progress bar length | 351 px, 115-465 from the card's right edge | **338** px, 128-465 | 13 px shorter (v2 N1 trade-off) | low | code | Bar `width` 38.9u → **40.4u**. Percent slot `right` 6.3u → **6.2u**, `width` 7.6u → **6.0u**, wrapped in `FittedBox(scaleDown)`. «0%»/«30%» keep their size; «100%» shrinks to ≈ 51 px and keeps an 11 px gap |
| B4 | **Breathing gold glow** on the active rim | None: the background above the card is flat #013327 up to 2 px from the rim | `BoxShadow` gold, alpha 0 → 0.10, blur 2.4u, looping | Motion and glow absent from the reference | **medium** | owner / code | Q3. Until it is approved, remove it: alpha `t * lerpDouble(0, 0.10, breath)` → **0**, and stop `_breath` |
| B5 | **Toast** on a locked tap («أكمل «…» أولًا لفتح هذه الدورة») and the lock shake | Not in the reference (no feedback is drawn) | Toast y772-831, 2 px rim, cream text; the lock shakes | UI element not in the reference, built without asking | **medium** | owner | Q4. Ask before keeping it. Alternative without a new element: only the lock shake plus a gold pulse on the lock disc |
| B6 | Active rim colour | 4 px: #998439 / **#CEA03B** / #C79B34 / #958439 (muted gold); right side #C69F3D / #D3A436 / #E1B446 | 3.4 px: #F2B132 / #D1B95B / **#FFDA6B** | Brighter and paler | low | code | Inner line `goldHighlight` → **#D3A436** on the active card; outer line #C69F3D; total 4 px |
| B7 | Locked rim outer line (top) | 1 px #00291C above the rim | None (#042920 background) | missing | low | code | Draw a 1 px #00291C stroke outside the top rim in `_RimPainter` |
| B8 | Horizontal sheen | Locked: #03372A at the edges, #023227 in the middle. Active: #033628 at the left, #012F25 in the middle | Flat #033529 / #033428 | missing | low | code | Horizontal overlay: `LinearGradient` #0A4A36 at 25% → transparent at 0.15 and 0.85 → #0A4A36 at 25% |
| B9 | Active card height | 430 | 434 | +4 px | low | code | Focus scale only on x (`Matrix4.diagonal3Values(1.016, 1.009, 1)`) |
| B10 | Active description colour | #D9DAC6 (p97 #E8EFD7, median #CFD0BA) | #F4EAD0 | warmer and brighter | low | owner | Token conflict (cream). See C4 |
| B11 | Locked title / description | Title right inset 49, +130/+178. Description line pitch 42 | 52, +130/+184. Pitch 44.5 | 3 px / 6 px / 2.5 px | low | code | Title `right` 5.7u → **5.35u**. Description line height → **4.95u** |
| B12 | Card bottom pattern | Locked, bottom 30 px: luminance mean/std 44.1/4.6 → 46.9/6.2 → 48.4/9.8. p99 #2B523A | 43.1/4.6 → 43.7/4.6 → 46.3/11.1. p99 #18523C | 25% fainter 40-60 px above the bottom | low | code | `cardPattern` opacity ×**1.3**, or the fade mask stop 0.5 → **0.35** |
| B13 | Course 01 icon (Quran on rehal) | 102x65, 51-152 from the card's right edge, +38-+102. Clean gold, cream pages | 107x61, 53-159, +41-+101. **Dark brown outline** around the shape (median #F6C7AA includes it) | 5 px wider, 4 px shorter, halo | low | asset + code | Code: `height` 8.1u → **7.6u**, `width` 14u → **12.0u**, `right` 5.5u → **5.9u**. Asset: prompt **P-B13** |
| B14 | Course 02 icon (voice profile) | 71x75, 285-355 from the right, +31-+105. **Cream → gold gradient** along the face line | 66x81, 289-354, +26-+106. Flat gold | 6 px taller, flat | low | asset + code | Locked icon height → **8.8u** (75 px). Prompt **P-B14** |
| B15 | Lock glyph colour | #EDE3CB | #DAD7BF | −8 L | low | code | `lockGlyph` → **#EDE3CB** |
| B16 | Star / play glyph colour | Gradient: star p97 #FFC72F, median #EFB527. Play #FAC752 | Flat #F2B623 | flat | low | code | `SvgTheme` colour → `goldHighlight` (#FFDA6B) on top, or a 2-stop `ShaderMask` #FFD556 → #EFB527 |
| B17 | Background | y5: #063127 at x250 / #063429 at x500. y840: #002D23. Above the active card (y300): #013327 | y5: #032D22 / #043125. y840: #00271D. y300: #032D23 | top −3 L, bottom −4 L | low | code | `contentTop` stop radius 0.9 → **1.2**. Add a bottom lift: a vertical overlay #002D23 at 0.85 → 1.0 |
| B18 | Course 3 text | «دورة متقدمة …», «العربية وقوو…» | «دورة متخصصة …», «العربية وصفا…» (`courses.json`) | different text | low | owner | Q5: keep the real data, or use the reference copy |
| B19 | Level pill text | «مستوى مبتدئ» | Hard-coded for every course | — | low | code | Add `level` to `Course` |
| B20 | Path line runs into the active card | 8 px dark gap between the node and the card (#273F1E at x978-982) | Gap ≈ 4 px (#3E5838 at x991) | −4 px | low | code | Stop the line at `nodeFromRight + 1.3u` |

## Completion sequence (k-00 … k-11), glitches only

| Frames | Finding | Sev. | Fix |
|---|---|---|---|
| k-00 → k-02 | The bar fills 30 → 65 → 100%; «100%» keeps a 16 px gap. No glitch | — | — |
| k-03 → k-04 | The cross-fades overlap, so there is no blink. The **icon jumps** from the centre (locked layout) to the top right (active layout), and the title shifts 3 px. This is a cross-fade between two layouts, not a move | low | Lerp the icon position with `t` (centre → right 5.5u), or keep it as is |
| k-04 → k-05 | **The node next to the new active card pops** from #265343 to gold in one frame when `_current` changes (v2 N3, still open) | low | Lerp the node colour with `_unlock.value` for `i == _completing + 1` |
| k-05 | During the glide the outgoing card is cut cleanly at the nav edge (x1686), the same as a normal scroll | — | — |
| k-06 … k-11 | Settled. No overlaps, cut-offs or flicker | — | — |

If the owner approves all-gold lines (Q1), the "light runs along the line" step needs a new visual. The line would already be gold, so the light could run as a white-gold spark on top of it.

## Conflicts with DESIGN-SYSTEM.md

These are for the owner; none is fixed silently.

1. **Locked rim: 4 px gradient vs the glass rim token** (2 px #245843).
2. **Active rim vs the selected rim token** (#DAA42A 1.2 px + #FFDA6B 1 px). B6 would move it further away: the reference wants a 4 px muted #C69F3D / #D3A436.
3. **Gold pill text vs "text on gold" #132C1A.** The pill is an outline pill, so this is probably a new token, `pill.outline.text = gold`.
4. **Active description #D9DAC6 vs label/cream.**
5. **Path line all gold (reference) vs the proposed dim track #265343.**

Hard-coded values remain in the screen code:
- `Colors.black` 0.40
- `Color(0x00F2B623)` ×2
- decor opacities 0.75 / 0.6
- rim and line widths 2 / 2.6 / 3

They should move to `rateel_theme.dart`.

## Owner questions

- **Q1.** Path lines: all gold, as in the reference, or dim until a course is completed (built that way, 🟡)?
- **Q2.** Percent on the active card: «0%» as in the reference (its bar shows 30%) or the real value («30%»)?
- **Q3.** Breathing gold glow on the active card: keep it or remove it? The reference is static.
- **Q4.** Locked-card tap: toast plus lock shake (built), or something else? The reference shows no feedback.
- **Q5.** Course 3 description: the reference copy or the `courses.json` text?
- **Q6.** The token conflicts 1-5 above.

## ChatGPT prompts for the asset items

Attach `ref-03.png` (reference screen) and the current asset each time.

- **P-A2 (header arch):** "Redraw this mihrab header arch as the same onion-dome outline, but as a single thin gold line half as thick as now (about 0.35% of the arch width). Pale gold #FEE989 at the apex, darker #C79B34 on the flanks. The lower 40% of both flanks fades to fully transparent. Transparent background, SVG, same proportions as the attached reference."
- **P-A4 (emblem):** "Open Quran emblem in front view, like the book above the title in the attached reference: filled gold page blocks with a thick gold rim and a small base under the spine. Width:height exactly 2:1. Gold #FBD35A to #E3B03B. Transparent background, SVG."
- **P-A7 (crescent and star):** "Crescent and five-point star as in the attached reference, top right. The whole crescent is slightly wider than tall (1.06:1), opening to the right. The star is smaller (about 40% of the height) and sits inside the opening. Crescent gold #BD952D with a soft highlight. The star is a muted olive gold #7A7129, as if 55% transparent. Transparent background, SVG, star as a separate path."
- **P-A10 (corner ornaments):** "Top-left corner ornament: an interlaced Islamic star lattice filling a right triangle (the two legs run along the top and left edges). Thick carved gold strokes (about 3% of the width), each with a dark inner shadow and a bright gold top edge, like embossed metal. The strokes fade slightly toward the inner diagonal. Match the corners in the attached reference. Transparent background, SVG or PNG at 1100 px. Also provide the top-right version with its own larger cells, as in the reference."
- **P-B13 (course 01):** "Same gold Quran on a rehal, but without the dark brown outline around the shape. Clean gold edges, cream pages. Width:height 1.57:1. Transparent background, SVG."
- **P-B14 (course 02):** "Same speaking-profile icon (face profile with sound waves). The face line has a gradient from cream #FBEAA6 at the top to gold #E1AC36 at the chin; the waves stay gold. Transparent background, SVG."

## Summary

**High (2)**

- **A1 arch geometry (code).**
  - Box height 31.1u → **26.4u**.
  - Add a vertical `ShaderMask` fade, stops **0.45 → 0.92**.
- **B1 connector lines.** Every segment and node should be gold, with a gradient #A3852E → #F5C04C. This needs owner Q1 first.

**Medium (10)**

| Item | Type | Fix |
|---|---|---|
| A2 arch line weight | asset | Prompt P-A2 |
| A4 emblem | code + asset | Interim code 14.0u x 7.0u, `top` 7.85u, `BoxFit.fill`; then prompt P-A4 |
| A5 mosque | code | `width` **42.2u**, `left` **14.0u**, `dstIn` fade 0.66 → 0.80 |
| A7 / A8 crescent | code + asset | Interim code 9.75u x 9.15u, `top` 7.75u, `right` 25.9u, `BoxFit.fill`; star at 55% opacity; then prompt P-A7 |
| A9 left corner | code | `width` **29.2u** |
| A10 corner style | asset | Prompt P-A10 |
| A12 divider | code | `srcIn` gradient: stops 0 / 0.12 / 0.33 / 0.5, colours transparent / #B2983A / #EFC246 / #F8D053, mirrored |
| B2 «30%» vs «0%» | owner | Q2 |
| B4 breathing glow | owner / code | Remove until approved (Q3) |
| B5 toast | owner | Q4 |

**Low (24):** A3, A6, A11, A14, B3, B6-B20, and the two completion glitches (icon jump, node pop).
