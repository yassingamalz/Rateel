# Screen 06 (lessons of the unit): critic v1 (on Flutter v2 captures)

Date: 2026-11-22. Branch `flutter/06-lessons` (working tree on top of `6fdb3f5`, `lib/lessons/` not yet committed).
Reviewer: separate critic sub-agent (did not write the code). No code was changed by this review.

Compared:
- Reference `reference.webp` 1844×853, u = 8.53 px. Content ends at the reference rail, x ≈ 1675.
- Look A (`ref`): `capture-v2-ref.png` (lesson 1 in progress, 2–3 locked), `capture-v2-ref-done1.png`
  (lesson 1 done, 2 in progress), `capture-v2-ref-phone.png` (915×412 @2.625 → 2402×1082, u = 10.82 px),
  `completion-frames-ref-v1.jpg`. Flutter rail starts at x ≈ 1688 (13 px further right than the reference).
- Look B (`orig`): `capture-v2-orig*.png`, `completion-frames-orig-v1.jpg`, against `angular-original.jpg` (sections 2–4).

Method: Python/PIL on both images at the same coordinates: colour masks (gold, cream, muted green, light) for
extents, row/column pixel profiles through rims, line, diamond, back button, pill; patch medians and p97 for fills
and the card pattern. Scripts in the session scratchpad (`critic/*.py`). All x/y are px at 1844×853.

Not scored (owner ✅): the side rail (2026-11-20); background = screen-03 background (05 decision B, 2026-11-22);
title cream gradient + shadow (2026-11-21); Readex Pro (2026-11-20, so glyph widths differ from the reference
font); texts and data from the app (2026-11-21: the descriptions, 3 lessons, lesson 1 being a *video* lesson);
haptics vocabulary (2026-11-20); padlock fly-off sequence and "icon never changes, only goes from dark to lit"
(05, 2026-11-22). Open owner questions are scored but typed **owner question** (plan Q1 title, Q4 locked look,
icons are placeholders until L1–L5 → typed **asset**).

## 1. Look A vs reference: differences

| # | Element | Reference (measured) | Flutter look A (measured) | Sev. | Type | Fix |
|---|---|---|---|---|---|---|
| A1 | **Title divider** | centred on the header axis (diamond x 916), lines x 655–1190 = **62.7u**, fading ends, open diamond **3.5u** tall with a ≈1.2u gap on each side, no dots | centre x **845** (99.0u) = **95 px (11.1u) left of the title centre** (940); x 685–1005 = **37.5u**; diamond 2.6u with two side dots. Cause: `SvgPicture` keeps the viewBox aspect (2046:187) at h 3.6u → ≈ 336 px wide, placed from `cx − 31u` | **high** | code | give the divider a box: `Positioned(left: cx − 31.4u, width: 62.7u, height: 3.6u)`; draw the two lines in code (gradient #B2983A00 → #EFC246 → peak #F8D053 next to the diamond, 0.35u thick) and an outline diamond 3.5u, stroke 0.35u, gap 1.2u, no dots (stretching the SVG would distort its diamond) |
| A2 | Active lesson icon | gold line-art open book with bookmark **24.9×12.4u**, centre (144.3u, 79.2u), outline ≈0.6u, gold #F5B81F | placeholder play triangle **6.8×7.7u**, centre (146.0u, 78.4u) | **high** | asset | L2 (video) / L1 (read) from `prompts/06-lessons/images-v1.txt`; box 25×13u kept |
| A3 | Locked lesson icon | muted green book **24.4×11.7u** #30513A–#3A5C41 clearly visible around the padlock | no type icon visible: the play placeholder (#3E6B4E under the 45% veil ≈ #1C3A2A) is smaller than the 8.6u padlock and hidden behind it | medium | asset (+code) | comes with L1–L5; check the locked tint stays ≥ #30513A after the veil (lift `lessonIconMuted` to ≈ #4F7E5E so it reads #2C4A36 under the veil) |
| A4 | Active card **inner glow** | gold inner glow on all sides: 1 px inside the rim #535B23, 2 px #234626, fading to the fill #0C3C28 over ≈ 25 px (**3u**); outer glow faint on the sides (#092F1D at 2 px), stronger on top (#233F1F at 1 px → bg over 3u) | no inner glow (fill #023126 right inside the rim); outer glow on the sides **#1F371E** at 2 px (stronger than ref), top #203E22 (≈ ref) | medium | code | add an inner glow: stroke 3u wide gold #F2B623 at 22% with blur 1.5u, clipped to the card RRect; lower the side outer glow to ≈ 10% (keep the top) |
| A5 | Card pattern (bottom band) | olive-gold star/arch lattice, lines p97 **#3D6334** (active) / #2C3E25 (locked), cell ≈ **8u**, band from ≈ 62u of the screen to the bottom | teal lines p97 **#18523C** / #0E2E22, cell ≈ 9.5u, much fainter | medium | code (+ low asset for the motif) | lesson-card pattern colour ≈ #4E6E36 (warm olive) instead of `cardPattern` #2E6A4C, tile scale 0.85; motif: reference lattice is closer to the 05 girih than to CR-07 (low) |
| A6 | Mosque | x 328–599, crescent y 103, visible to y ≈ 295 (**34.6u**); top **#798A51** → bottom #315432 (sage, light) | x 327–599, y 101, fades out by y ≈ 255 (**29.9u**); top **#3C562B** → #1D4026 (half as bright) | medium | code | box height 20u → 23u; fade stops 0.62/0.9 → 0.72/1.0; tint for this screen ≈ #7D8E54 top → #2F5331 bottom (gradient srcATop) instead of `unitMosqueTint` |
| A7 | Back button arrow | arrow 27×24 px (**3.2×2.8u**), stroke **3 px (0.35u)**, #FAF5E1 | 37×32 px (4.3×3.8u), stroke **6 px (0.7u)**, #F7F8F8 | medium | code | `_ArrowPainter`: half-length `s` 0.2w → 0.16w, stroke 0.075w → 0.04w (≈ 0.36u), colour `titleCream` |
| A8 | Done lesson under the rail (done1) | (no reference state; content ends at the rail) | completed card 1 sits under the rail with its left rim **#837331** at x 1667–1670 and 15 px of body visible left of the rail: reads as a glitch | medium | code | clip the path at the content's right edge (`ClipRect` to x < rail) **or** anchor the path so the completed card stays fully visible when it fits; never leave a sliver |
| A9 | Locked card rim | **4 px (0.47u)**: sides #3E644E, top #4E795B, bottom #395F48, dark outer hairline #002016 | **2 px** flat #325C46 (`lessonRimMuted`) | medium | code (+ token conflict §2) | 0.47u, vertical gradient #4E795B → #3E644E → #395F48, 1 px #002016 outside |
| A10 | Third card / line off the left edge | line fades from x ≈ 158 to ≈ 40, no card visible | sliver of card 3 at x 0–58 with half of its «3/3» pill; on the phone 116 px with title fragments «مر» | low | code | fade mask on the path 0 → 1 over x 0–12u (cards and line), as the reference line |
| A11 | Card size | active **660×437 (77.4×51.2u)**, locked **636×436 (74.6×51.1u)**: the active card is ≈ 3.7 % wider | both 644×435 (**75.5×51u**) | low | code | active card 77.4u (or scale 1.037 on the lesson in progress, like the Angular focus scale 1.05), others 74.6u; pitch unchanged 88u |
| A12 | Card positions | active right edge 1557 (13.8u from the rail at 1675), gap **104 px (12.2u)**, pitch 751.5 px | right edge 1560 (15.0u from the rail at 1688), gap 108 px (12.7u), pitch 751 px | ok | — | follows from A11 |
| A13 | Corner radius | ≈ 5.6u (same edge test: 39–42 px) | 4.7u (same test: 31–32 px) | low | code | 5.6u for the lesson cards (token conflict note: course card 4.7u 🟡) |
| A14 | Active rim colours | 3–4 px; top **#FDED82 / #FAD967**, sides **#F6B724**, bottom **#F2D64C** (light top and bottom) | 3 px; top #FFDA6B, sides #FACE56, bottom **#EAAA16** (orange) | low | code | gradient top #FBE27A → 50% #F4B826 → bottom #F2D24C |
| A15 | Card fill | top #0C3F2A, mid #063727, bottom #003927 | #033428 → #012F25 → #04392C | low | code | ≈ +8 lum at the top (#0A3D29); mostly comes with A4 |
| A16 | Connector diamond | 22.5×26 px (**2.6×3.0u**), gold halo ≈ 1.5u (#806A1C next to it) | 21.5×21.5 px (2.5×2.5u), halo barely visible | low | code | half-height 1.5u, half-width 1.3u; glow gold 25% blur 1.2u |
| A17 | Connector line | **bright gold #EEAA1E, 4 px (0.47u)** with dark hairlines #001617 / #192E1D, y 558–561, already lit while lesson 1 is in progress | dim #67652B (`unitLine` 55%), 3 px, y 559–561; lit #FFDA6B only after the lesson is done | low | **owner question** | the units line rule (05, ✅ B: dim, lit at 50%/100%) is reused here; ask whether lessons follow it (one style) or the bright reference line |
| A18 | Pill «1/3» | 12.8×6.4u, text 19 px (2.2u) medium weight, 1 px top highlight #F8DC66, soft shadow | 12.8×6.1u, text 17 px (2.0u) weight 600 | low | code | height 6.4u, text `h × 0.6`, weight 520, 1 px top edge #F8DC66 |
| A19 | Header emblem | open book **17.9×8.2u**, x 840–993, y 78–148, dark pages, heavier gold outline + base | 16.6×7.2u, x 870–1012, y 83–144 | low | code | box 19×8.7u (book centred at 13.3u) |
| A20 | Header arch | x 544–1285 (**87.0u**), apex y 13 (1.5u), ends y 152 (17.8u) | x 568–1313 (87.5u), apex y 18 (2.1u), ends y 144 (16.9u) | low | code | top 1.4u → 0.9u, height 20u → 21u |
| A21 | Header title | «مقدمة في علم التجويد» (first lesson's title), centre (109.1u, 24.7u); word «مقدمة» 192×45 px | unit title «مقدمة في التجويد», centre (110.2u, 24.8u); «مقدمة» 184×50 px (Readex: narrower, taller) | low | **owner question** (Q1) | text: owner; size ok within the font ✅ |
| A22 | Locked card look | fill **#092920** (as light as the background), title #A5A088, desc #989B86, pill #8A6F1F, **gold** padlock 6.7×5.2u body + grey-teal shackle, 8.9u tall, centre (55.9u, 80.4u), sitting on the bottom of the book | 45% dark veil: fill **#011C15** (darker than the background #01291F), title #8A8577, desc #868172, pill #886B24 → #7F5C0E; green padlock 8.6×8.7u centred on the icon (57.2u, 78.4u) | medium | **owner question** (Q4) | owner: keep the 05 look (one style) or the reference |
| A23 | Corner ornament | 26.8×25.4u, thin 8-point star lattice with dark relief | 26.8×**20.3u**, the 05 corner (hexagonal cells, heavier strokes) | low | asset | reference-style corner (or confirm reuse of the 05 corner) |
| A24 | Card texts | title right edge 7.7u from the card edge, cap height 5.9u, desc 2 lines 10u | right edge 7.8u, 6.1u, 9.8u; same title 52.8u wide vs 58.3u (font ✅) | ok | — | — |
| A25 | Review chip «A ChatGPT / B الأصلي» | — | 34×6u at (3u, 33u), between mosque and cards | low | code | review aid only; remove when the owner chooses |

Phone (`capture-v2-ref-phone.png`, u = 10.82 px): active card 814 px = 75.2u, all sizes scale in u, no overflow,
pill text centred; same findings as above (A10 is more visible there).

## 2. Conflicts with design tokens (for the owner, not fixed silently)

| Token (`DESIGN-SYSTEM.md`) | Status | Reference 06 | Flutter | Note |
|---|---|---|---|---|
| Glass button (close): 1.7 px #D8C35A, radial gold glow 8→24%, outer glow gold 22% blur 2u | ✅ 2026-11-20 | back button: **dark** glass fill #0B2A1D, 3 px grey-green rim #597554, no glow | follows the token (fill #545C23, rim #D8C35A, gold glow) | owner: token or reference look |
| Glass rim 2 px #245843 | ✅ | locked card rim 4 px #3E644E–#4E795B | #325C46 2 px (`lessonRimMuted`, a new value) | new colour outside the token set (A9) |
| Gold rim (selected) 1.2 px #DAA42A + 1 px #FFDA6B, glow gold 15% blur 2u | ✅ | active card rim 3–4 px #FDED82/#F6B724 + inner glow | 3 px #FFDA6B → #EAAA16, glow gold 22–34% blur 2.6u (breathing) | same open conflict as the course card (🟡 03) |
| Pills: flat #EDB120, text on gold #132C1A | ✅ | step pill gradient #F8DC66 → #E2A41C | badge gradient #F8C343 → #E5A416 (`badge*`) | the unit badge gradient was approved for units (✅ 2026-11-22 "ring and badge: A"); confirm it extends to lesson pills |
| Path / unit line: thin, lit at 50%/100% | ✅ for units (2026-11-22) | bright line before completion | dim line | A17 |
| Course card radius 4.7u, fill #033428… | 🟡 | radius ≈ 5.6u, fill #0C3F2A top | 4.7u, #033428 | A13, A15 |
| Mosque tint `unitMosqueTint` #CC3C5426 | 🟡 | lighter sage #798A51 | the 05 tint | A6 |
| Card pattern `cardPattern` #2E6A4C | 🟡 | olive #3D6334 | token colour | A5 |

## 3. Motion (look A, `completion-frames-ref-v1.jpg`)

All six planned phases are present and readable in order: (1) light head (white core + gold halo ≈ 2u) runs from
the top centre clockwise; (2) the lit trail closes the rim; (3) flash: card glow up, 16 sparkles, pill «1/3» → ✓
with a bounce; (4) the light runs along the line to the diamond (pop) and on; (5) the padlock lifts, tilts and
fades on the still-veiled card 2; (6) card 2's veil lifts, rim turns gold, icon goes from dark to lit.
Remarks: sparkles are small (0.5–1.4u) and sit on an ellipse 6u inside the card's bounds, so most fall on the rim
and read as noise rather than a burst (low: start them on the rim, travel 3–5u outwards); frame 8 shows the next
icon half-lit olive (#B0A03A) while the rim is already fully gold (low: light icon and rim together); no visible
glide to the next card in these frames (it happens after); the sliver of A8 appears after the glide. Haptics
(tick ×4, milestone, unlock, success) follow the plan. Score 7.5.

## 4. Look B (Angular original, improved)

**Improvement assessment.** Yes, a real improvement over the Angular screen (sections 2–4 of
`angular-original.jpg`): cards **43.7×31u** (373×264 px) instead of ≈ 32.8×23.4u (280×200 px); a gold lesson
in progress with a soft glow and readable dark text (#13261A); padlock asset instead of the 🔒 emoji over the
text; lesson-type icon; cream-gradient title 4.8u with the glass back button and a divider; gold diamonds and a
lit line on the connectors; the same completion choreography with haptics. Structure kept: title top right with →,
three small cards right-to-left, duration «N دقيقة» with a clock, ✓ pill on done lessons, faint Angular pattern.
**But** it is not consistent with the app's family: no arch/emblem/mosque/corner header (screens 03/05), no card
pattern, a white-alpha rim and a gradient gold fill outside the confirmed tokens; next to screens 03 and 05 it
reads like another app.

Measured: active card x 1243–1615, y 311–575, rim 2 px white 55% over gold (#F0D48C), fill #F0C13D → #DAA21D;
locked cards rim 2 px #1E342E (white 10%), fill #0A2319 → #011A14 (veil), padlock 5.6u at y 22.6u of the card;
line #63612A 3 px; background #022C21 with the Angular pattern at 6%.

| # | Issue | Sev. | Type | Fix |
|---|---|---|---|---|
| B1 | Completion flash (frame 5): the card is half gold/half tint, text lerps between cream and dark and drops to ≈ 1.5:1 contrast; the pill is a blank dark capsule (number faded out, ✓ not yet in) | medium | code | snap the ink colour at the midpoint instead of lerping; cross-fade number → ✓ over the same window (0.3–0.5); fade the gold fill only after the ✓ is in |
| B2 | Unlock (frame 8): next card at ≈ 50% gold with cream text, illegible | medium | code | same as B1: ink switches to dark when the gold fill passes 50% |
| B3 | After a completion the done lesson disappears under the rail (`capture-v2-orig-done1.png`: only lessons 2–3 visible); Angular keeps the done card on the right | medium | code | when all cards fit in the content, do not glide: keep lesson 1 in the first slot |
| B4 | Composition: cards occupy y 36.5–67.4u, the bottom 32 % and the left 19 % are empty; header 4.8u title is small for a landscape tablet | low | code | track centre 52u → 56u and cards ≈ 50×35u, or keep Angular proportions by intent (owner) |
| B5 | Lesson icons: play glyph 5u placeholders (same type for every lesson of unit 1) | medium | asset | L1–L5 |
| B6 | Tokens: gold fill gradient #F1C23E → #D9A11C vs flat #E2A51E ✅; rim white 10% vs glass rim #245843 ✅; text on gold #13261A vs #132C1A ✅; card radius 3.2u vs 4.7u 🟡; pill on gold = dark fill + gold text without the gold outline of the pill token 🟡; Angular pattern instead of the girih approved for 05 | — | token conflict | owner, if B is chosen |

**Look B overall: 6.0/10** (good upgrade of the original, but off the app's style; three medium code items).

## 5. Scores (look A, everything scored, placeholders included)

| Area | Score | Main reasons |
|---|---|---|
| Layout | 8.0 | positions, pitch, card heights, pill and text placement within 2–4 px; divider 11u off-axis (A1), done sliver (A8), card 3 sliver (A10), mosque short (A6) |
| Colours | 7.0 | no inner glow (A4), teal faint pattern (A5), dark mosque (A6), locked rim (A9); locked veil and line are owner questions |
| Typography | 8.0 | sizes and colours within 0.2–0.3u; arrow twice as heavy (A7), pill text small (A18); font differences ✅ |
| Assets | 4.0 | lesson icons are placeholders (A2, A3), corner from 05 (A23) |
| Motion | 7.5 | §3 |
| **Overall look A** | **6.8** | 7.6 for code alone |

**Look B overall: 6.0.**

### High / medium code items to fix (look A)
A1 divider (high), A4 inner glow, A5 pattern colour, A6 mosque, A7 arrow weight, A8 done-card sliver, A9 locked rim.
Look B: B1, B2, B3. Asset: L1–L5 (A2 high, A3, B5). Owner questions: Q1 title (A21), Q4 locked look (A22),
line brightness (A17), token conflicts §2.
