# Screen 06 (lessons of the unit): critic v2 (on Flutter v3 captures)

Date: 2026-11-22. Branch `flutter/06-lessons` (working tree on top of `e245ba3`: `lesson_card.dart`,
`lessons_screen.dart`, `rateel_theme.dart` modified, not yet committed).
Reviewer: separate critic sub-agent (did not write the code). No code was changed by this review.

Compared:
- Reference `reference.webp` 1844×853, u = 8.53 px (content ends at the rail, x ≈ 1675).
- Look A: `capture-v3-ref.png`, `capture-v3-ref-done1.png`, `capture-v3-ref-phone.png` (2402×1082, u = 10.82 px),
  `completion-frames-ref-v2.jpg` (8 frames, reading order). Flutter rail starts at x ≈ 1686–1688.
- Look B: `capture-v3-orig*.png`, `completion-frames-orig-v2.jpg`, against `angular-original.jpg`.
- Previous round: `critic-v1.md` (v2 captures), used as the baseline; v2 captures re-measured with the same scripts.

Method: Python/PIL (scripts `critic2/*.py` in the session scratchpad, run with `python3 -I`): row/column pixel
profiles through the divider, rims, glow, arrow, rail edge; colour masks for extents; band medians/p97 for the card
pattern and the mosque; x autocorrelation for the pattern cell. All x/y in px at 1844×853 unless stated.

Not scored (owner ✅): side rail (2026-11-20); background = screen-03 background (05 decision B, 2026-11-22);
title cream gradient + shadow (2026-11-21); Readex Pro (2026-11-20); texts and data from the app (2026-11-21);
haptics vocabulary (2026-11-20); padlock fly-off and "icon only goes from dark to lit" (05, 2026-11-22).
Still open and scored as **owner question**: Q1 title (A21), Q4 locked look (A22), line brightness (A17).
Lesson icons are placeholders (L1–L5) → **asset**.

## 1. Verification of the v1 high/medium code items

| # | Item (v1 sev.) | Reference | v2 capture (v1 baseline) | v3 capture (now) | Status |
|---|---|---|---|---|---|
| A1 | Title divider (high) | line run x 669–1177 = **59.6u**, diamond 21×29 px (2.5×3.4u), inner line ends 13 px from the diamond centre, no dots | centre x 845 (11.1u left of the title axis), 37.5u, diamond 2.6u + 2 dots | run x 679–1203 = **61.4u**, centre **941.0** = title axis (940), diamond 20×33 px (2.3×3.9u), inner ends 13 px from centre, no dots; thickness 2 px full + 2 partial (ref 3 px) | **fixed** (residual low: line colour #F0C448/#F7CE51 vs ref #FEBA20/#FFD93B, less saturated; diamond 0.5u taller) |
| A4 | Active card inner glow (medium) | inside the left rim: +5 px #1C4025, +14 #103B25, +25 #093724, +50 #053526; top +5 #1A3F25; outer side 2 px #072511, outer top 4 px **#244021** / 6 px #1F3C20 | no inner glow (#023126 right inside), outer sides #1F371E | inside: +5 #244326, +14 #193E26, +25 #0B3526, +50 #023126; top +5 #244628; outer side 2 px **#0E2C1D**; outer top 4 px **#0E3020** | **fixed** (inner glow ≈ ref, +6 lum near the rim). Residual low: top outer glow now weaker than ref (#0E3020 vs #244021), see A4b |
| A5 | Card pattern (medium) | band p97 active **#3E5F38** (contrast vs band median +42 lum), locked #283C22, cell **8.2u** | p97 #18523C (teal, +20 lum), locked #0E2E22, cell 9.4u | p97 **#2D5833** (olive, +24 lum), locked **#172F1C**, cell **9.4u** | **partly**: hue fixed (teal → olive), but contrast is 57 % of the ref (24 vs 42 lum), locked band p97 lum 39 vs 55, cell still 14 % larger (scale 0.85 not applied) → **medium** |
| A6 | Mosque (medium) | visible to y **291 (34.1u)** with a soft fade; band medians y110 **#85925B**, y150 #6F8249, y190 #617A45, y230 **#375934**, y255 #274C2D (top-to-bottom gradient, light to dark) | to y 249, #3C572A flat (half as bright) | visible to y **270 (31.7u)**, then a **hard edge** (row 264: +56 lum over bg, row 272: +3); band medians y110 #7C8D40, y150–y230 **#7C8D53 flat**, y255 #506B42 | **partly**: top tone now matches, but the tint is flat (no vertical gradient: y230 #7C8D53 vs ref #375934, ≈ +50 lum), and the base is cut by the image edge (image is 171 px tall in a 196 px box, the fade 0.72→1.0 of the box only reaches 55 % at the image bottom). The mosque reads as a solid bright cut-out, not the reference's misty silhouette → **medium** |
| A7 | Back arrow (medium) | 27×24 px (3.2×2.8u), stroke 3 px, #FAF5E1 | 37×32 px, stroke 6 px, #F7F8F8 | **29×26 px (3.4×3.05u)**, stroke 2 px full + 1 partial (≈ 0.35u), #F7F8F8 | **fixed** (residual low: 7 % larger, cool white instead of cream #FAF5E1) |
| A8 | Done card sliver under the rail (medium) | content ends at the rail, nothing under it | rim #837331 at x 1667–1670 for the full card height + 15 px body | rim still visible at x **1668–1671 #5B5A29 / #404925** (bg #01241B, ≈ +45 lum) from y 345 to 777, corner arcs at x 1680 (#172A18), lit line running into it (#F4D166 → #5B5B2A at 1668). Cause: the right fade only covers the last 3u (x 1660–1686) and the card's rim sits inside it at ≈ 60–70 % opacity | **partly** (dimmer, still a full-height olive bracket next to the rail) → **medium**. Fix: fade over ≥ 8u before the rail (x 1618–1686) or clip the done card fully, or keep it entirely visible |
| A9 | Locked card rim (medium) | 4 px; top #4E795B, side #3E644E (y 450) / #385F4B (y 640), bottom #395F48; hairline #002016 outside | 2 px flat #325C46 | **4–5 px**; top **#4E795B**, side #466F54 (y 450) / **#3C624C** (y 640), bottom **#395F48**; hairline #002119 outside | **fixed** (residual low: upper side 8 lum lighter than ref because the gradient runs top→mid over the half height) |
| B1 | Look B completion flash (medium) | — | half gold/half tint, lerped ink ≈ 1.5:1, blank pill | frame 5: card fully gold, ink dark #13261A, pill dark with a gold ✓ | **fixed** |
| B2 | Look B unlock, next card (medium) | — | 50 % gold, cream text illegible | frame 8: card gold, title/desc/duration dark and legible. The play icon is still being lit gold **on the gold fill** (visible only as a faint lighter triangle) and snaps to dark at unlock = 1 | **fixed** for the text; icon → new low item B7 |
| B3 | Look B done card disappears under the rail (medium) | Angular keeps the done card in place | lessons 2–3 only | `capture-v3-orig-done1.png`: done card (✓, 15 % gold tint) stays in the first slot x 1243–1615, lesson 2 gold in the middle, line lit between them (`_pageFor` keeps lesson 1 while all cards fit) | **fixed** |

## 2. Other items of v1 re-measured, and new findings

| # | Element | Reference | Flutter look A v3 | Sev. | Type | Fix |
|---|---|---|---|---|---|---|
| A2 | Active lesson icon | book 24.9×12.4u | play placeholder 6.8×7.7u | **high** | asset | L1/L2 (unchanged) |
| A3 | Locked lesson icon | muted book around the padlock | placeholder hidden behind the padlock (`lessonIconMuted` lifted to #4F7E5E, not visible because the glyph is smaller than the padlock) | medium | asset | with L1–L5 |
| A4b | Active card outer glow, top (new residual) | top outer 4 px #244021, 12 px #153820 (stronger on top than on the sides) | top outer 4 px #0E3020, 12 px #093123 (same as the sides): the breathing glow was lowered to 10–18 % everywhere | low | code | keep the sides at 10 %, add ≈ +12 % on the top edge (offset −0.5u) |
| A4c | Dark hairline outside the **active** gold rim (new) | outside the gold rim: 1 px #AA7E1C (antialias), 2 px #072511 | 1 px **#022217** all around the gold rim (the locked-card hairline is drawn for every look-A card) | low | code | draw `lessonRimHairline` only while the card is locked/unlit (fade it out with `lit`) |
| A10 | Third card / line at the left edge | line fades x ≈ 158 → 64, no card | desktop: **no card sliver** (fixed), line visible from x 102 (12u; ref 7.5u). Phone: card-3 rim still visible at x 135–139 (12.5u) #1F4635 over bg #00271D (+25 lum, v2: #325C46) for the full card height | low | code | phone: start the fade at 0 → 1 over 0–22u, or hide cards whose right edge is < 22u |
| A11 | Card size | active 77.3×51.0u, locked 74.6×51.1u | both 75.5×51.0u | low | code | unchanged |
| A13 | Corner radius | straight edge starts 34–35 px from the corner | 36–37 px (v2: 30) | ok | — | **fixed** (5.6u) |
| A14 | Active rim colours | top #FDED82/#FAD967, sides #F6B724 | top #FFDA6B, sides #F0B930/#CDA734 | low | code | unchanged |
| A16 | Connector diamond | 2.6×3.0u, halo | 2.5×2.5u | low | code | unchanged |
| A17 | Connector line | bright gold before completion | dim until done | low | owner question | unchanged |
| A18 | Pill «1/3» | 107×54 px (12.7×6.3u) | 108×51 px (12.7×6.0u) | low | code | unchanged (height +0.3u) |
| A19 | Header emblem | 17.9×8.2u | box 19×8.7u (changed as proposed) | ok | — | fixed |
| A20 | Header arch | apex 1.5u, ends 17.8u | top 0.9u, height 21u (changed as proposed) | ok | — | fixed |
| A21 | Header title | lesson title | unit title | low | owner question (Q1) | open |
| A22 | Locked card look | fill #092820, gold padlock on the book | 45 % veil, fill #011C15, green padlock | medium | owner question (Q4) | open |
| A23 | Corner ornament | 26.8×25.4u, star lattice | 05 corner | low | asset | unchanged |
| A25 | Review chip | — | A/B chip | low | code | remove when the owner chooses |
| A26 | Pill number → ✓ in look A (new, motion) | — | frame 5 of `completion-frames-ref-v2.jpg`: **blank gold capsule** at the flash peak. The text fades out over done 0.3–0.4 and the ✓ fades in over 0.4–0.5 (back to back): at 0.35–0.45 the summed opacity is ≤ 0.5, an empty pill for ≈ 80 ms of the 800 ms flash | low | code | overlap the two (text 0.30–0.42, ✓ 0.36–0.48) or swap instantly at 0.4 under the pop scale |
| B7 | Look B: icon on the unlocking gold card (new) | — | frame 8: play icon lerps from muted to **gold on the gold fill** (≈ invisible) during unlock 0.55–1.0 (≈ 0.5 s), then snaps to dark at unlock = 1 | low | code | use the same rule as the ink: `onGold` when `_goldFill > 0.5`, not `unlock >= 1` |

Phone (`capture-v3-ref-phone.png`): all sizes scale in u, divider centred on the title, arrow and rims as on the
tablet; only the A10 rim sliver at the left edge.

## 3. Conflicts with design tokens (for the owner, not fixed silently)

Unchanged from v1 §2, plus the new proposed values introduced by the fixes (all 🟡, outside the confirmed set):

| Token / value | Status | Reference 06 | Flutter v3 | Note |
|---|---|---|---|---|
| Glass button (close) ✅ 2026-11-20 | ✅ | dark glass, grey-green rim, no glow | token look (#545C23 fill, gold rim) | owner: token or reference |
| Glass rim 2 px #245843 | ✅ | locked rim 4 px #3E644E–#4E795B | **new** `lessonRimLockedTop/Mid/Bottom` #4E795B/#3E644E/#395F48, 0.47u + `lessonRimHairline` #002016 | new colours/width outside the token set (A9 fix) |
| Gold rim (selected) 1.2 px #DAA42A + 1 px #FFDA6B, glow 15 % | ✅ | 3–4 px rim + inner glow | 3 px rim, breathing glow 10–18 %, **new inner glow** gold 22 % 3u blur 1.5u | same open conflict as the course card (🟡 03) |
| Pills flat #EDB120 | ✅ | gradient pill | badge gradient | confirm the unit-badge ✅ extends to lesson pills |
| Path line thin, lit at 50/100 % | ✅ units | bright line | dim line | A17 |
| Course card radius 4.7u | 🟡 | ≈ 5.6u | **5.6u** for lesson cards | radius now differs from the course card (4.7u) |
| `unitMosqueTint` | 🟡 | sage gradient | **new** `lessonMosqueTint` #7D8E54 flat | second mosque tint in the app |
| `cardPattern` #2E6A4C | 🟡 | olive #3D6334 | **new** `lessonPattern` #4E6E36 | second pattern colour |

## 4. Motion (look A, `completion-frames-ref-v2.jpg`)

Same six phases, in order and readable: light head around the rim (frames 2–4), flash with sparkles (frame 5),
pill → ✓ (frame 6), light along the line to the diamond (frame 6), padlock fly-off (frame 7), next card lit
(frame 8). Changes since v1: sparkles now travel outside the card (up to ≈ 3u beyond the rim) and read as a burst
(v1 remark addressed); the inner glow lifts with the flash. Remaining: blank pill at the flash peak (A26, low);
frame 8 still shows the next icon half-lit olive while its rim is muted (low, as v1); the A8 sliver appears after
the glide. Score **7.8**.

Look B frames (`completion-frames-orig-v2.jpg`): frame 5 gold card with dark ink and ✓ (B1 fixed), frame 6 done
card with 15 % tint, frame 7 padlock fly-off, frame 8 next card gold with dark text (B2 fixed); icon lit
gold-on-gold for ≈ 0.5 s (B7, low).

## 5. Look B (Angular original, improved)

The three medium code items B1, B2, B3 are fixed (see §1). Remaining: B4 composition (low), B5 icons (medium,
asset L1–L5), B6 token conflicts (owner, if B is chosen), B7 (low, new). The family-consistency remark of v1
stands: no arch/emblem/mosque/corner header and no card pattern, gold-filled card outside the confirmed tokens;
next to screens 03 and 05 it still reads like another app.

**Look B overall: 6.5/10** (was 6.0; completion flow now clean, no medium code item left).

## 6. Scores (look A, everything scored, placeholders included)

| Area | v1 | v2 | Main reasons |
|---|---|---|---|
| Layout | 8.0 | 8.6 | divider on the axis and 61.4u (A1), no card sliver on the left (desktop), radius, emblem, arch fixed; done-card bracket under the rail (A8), mosque base cut at y 270 (A6) |
| Colours | 7.0 | 7.8 | inner glow, locked rim, olive pattern fixed; mosque flat-tinted (A6), pattern 57 % of the ref contrast (A5), top outer glow weak (A4b) |
| Typography | 8.0 | 8.5 | arrow weight fixed (A7); pill text slightly small (A18) |
| Assets | 4.0 | 4.0 | lesson icons placeholders (A2 high, A3), corner from 05 (A23) |
| Motion | 7.5 | 7.8 | §4 |
| **Overall look A** | **6.8** | **7.3** | **8.1 for code alone** |

**Look B overall: 6.5.**

### Remaining high / medium code items (look A)
- **A6 mosque (medium, partly):** vertical tint gradient ≈ #7D8E54 top → #2F5331 bottom, and fit the fade to the
  image (box height = image height 20.1u, or stops 0.62→1.0 of the image) so the base fades out by y ≈ 291 instead of
  ending on a hard edge at y 270.
- **A8 done-card sliver (medium, partly):** rim still visible at x 1668–1671 (+45 lum) for the full card height:
  widen the right fade to ≥ 8u or clip the card.
- **A5 pattern (medium, partly):** raise the pattern alpha/colour so the band p97 reaches ≈ #3E5F38 (+42 lum over the
  band median) and scale the tile to 0.85 (cell 8.2u).

Look B: none. Assets: L1–L5 (A2 high, A3, B5). Owner questions: Q1 (A21), Q4 (A22), line brightness (A17),
token conflicts §3.
