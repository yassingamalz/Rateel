# Screen 30 (onboarding): critic v1

Reviewer: a separate sub-agent that did not write the code. Date 2026-11-28. Branch `flutter/30-onboarding`, HEAD `1d1483e`.

## Method
- References: `reference-{a-welcome,b-level,c-goal}-{dark,light}.webp` (1844×853; light and C dark are 1843 wide).
- **Captures:** the captures I was given (`scratchpad/cap/`) and the server on :8765 come from a web build made at 12:06,
  **before** commit `1d1483e` (12:15, library mosque A6 + star lattice corners). LESSONS-LEARNED says to review the latest
  build, so I rebuilt HEAD (`flutter build web --release --no-web-resources-cdn` into the scratchpad, served on :8766) and
  recaptured all 12 images (phone 915×412 at dpr 2.625, desktop 1844×853 at dpr 1, a fresh browser context per image so that
  the theme does not carry over). Compared with the old captures, 1.8–2.9% of pixels changed (only the corners and the
  mosque). All numbers below come from the HEAD captures.
- Phone first: the 2402×1082 capture is scaled by height to 853 (1894×853, u = 8.53 px). Centred elements are compared at
  x − 25 and right-anchored ones at x − 50, so every x below is in the reference frame (1844 wide). The desktop captures are
  the same layout in u (identical sizes and positions; only edge-anchored items sit 25 px nearer the edges). So **desktop and
  phone get the same findings and the same scores**.
- Every value was sampled from pixels with PIL/numpy scripts (ink boxes with a luminance threshold, row and column
  profiles for rims and glows, median colours over 5×5–9×9 px). Scripts: `scratchpad/crit/*.py`. Box format: x,y w×h px
  (u). "ph" = build, "ref" = reference.
- **Not scored** (owner ✅ in DECISIONS.md): plan v1 answers Q1 (one place for the shared elements: title/subtitle/dots/
  button/back button positions, same button height in C), Q2 (divider 45u), Q4 (avatars 6, 4, 2, 5, 3, 7 of the library),
  Q5 (library glyphs + owner's stopwatch), Q6 (lattice band on every card), Q8 («التالي» disabled while the name is empty, as
  in the A captures), Q10 (moon button), plan «same composition as dark» for the light theme (the light references draw card
  A and the B/C cards bigger and shifted); and the row of 2026-11-28 «reach the reference almost identically, unless…» which
  keeps as standards: **emblem, avatars, buttons (`LessonButton`, `LessonRoundButton`), gold card rim of A, fonts, title
  colours, library mosque**. Measured deltas on those are given only as information (section "Not scored").
- The light emblem is still the owner's choice (Q7): only a comment.

## Scores (0–10)

| Image | Phone 915×412 | Desktop 1844×853 |
|---|---|---|
| A welcome, dark | **6.5** | 6.5 |
| A welcome, light | **6.0** | 6.0 |
| B level, dark | **7.0** | 7.0 |
| B level, light | **6.5** | 6.5 |
| C goal, dark | **6.0** | 6.0 |
| C goal, light | **6.0** | 6.0 |

Card boxes, field, avatars, glyph places and the card texts' places match the references within 1–3 px. What lowers the
scores: the decor (bottom waves, faint corner lattice, arc ends), the A separator that is not drawn, subtitles and the C
numbers about 15–25% smaller and lighter than the reference, the selected-card rim with no outer gold band, the C card
colours, and the light-theme ink.

## Differences

Severity: H high / M medium / L low. Type: code or asset.

### Shared by the three steps

| # | Element | Reference | Build | Sev | Type |
|---|---|---|---|---|---|
| S1 | **Bottom waves** | A wide swoosh: a lighter band (#1C5A43 at x 10, y 660) under a pale teal line that dips to y 840 near x 900 and climbs steeply to y 778 at x 1300 (under the mosque); a gold line from behind the main button down to the bottom edge near the centre. Light: cream band, gold line #D49B22 | Two thin, almost straight lines: teal at y 656 / 744 / 817 / 802 (x 10 / 400 / 900 / 1300), gold at y 739 / 800 / 846 / 835; band fill teal 8% alpha (bottom stays #053528). Light: two thin tan lines | **H** | code |
| S2 | **Corner lattice** (star lattice A5) | Gold 8-point star lattice, line #7E7A31–#988629, lum contrast vs ground 72–89; radial fade inwards. Light: line #C8A063–#D6A76E, contrast 63–76 | Same pattern and cell, but line #454E16, contrast 34 (≈ 2.4× fainter). Light: #F0DCBA, contrast 20 (≈ 3.5× fainter): almost invisible on the phone | **M** | code |
| S3 | Big arc: ends | Path matches (y 130/65/20 at x 120/200/280 in ref; build 127/69/28). Ref fades to transparent toward the ends: #D19709 at the top, #7B620E at x 60 (y 197), gone at the screen edge | Full gold #C99300 to the edge (#AC8405 at x 1, y 237); FWHM 7–8 px with glow vs 5–6 px. Light: ref gold #D8A240 fading, build pale copper #D9B08A, ≈2 px | M | code |
| S4 | **Subtitle** size and weight | Ink width A 43.4u (light 51.3u), B 56.4u (60.6u), C 61.4u (66.6u); stroke run 4–5 px (≈ weight 450) | A 37.4u, B 45.3u, C 49.2u (−14 to −27%); run 3–4 px (weight 340, size 3.6u). Ref ≈ 4.4–4.6u at weight ≈ 450 | **M** | code |
| S5 | Title size (C) | C ink 68.1u wide (light 70.9u), area 12 232 px | 58.7u (−14%), area 9 852. A (51.0 vs 51.8u) and B (81.1 vs 83.6u) match. One title size for all steps was in the approved plan, so this is the reference drawing C heavier | L | code |
| S6 | Title colour, dark | Cream with a light vertical gradient #F0E8C7 → #EFE4C0, core #F7F4D4 | Flat #FAF1D8, core #FFF7DD | L | code |
| S7 | Divider with diamond | Line FWHM 3–5 px, solid gold #E1C143 / #E9B826 to the tapered tip; diamond ≈ 7×5.7u. Light: gold #D0A43E / #C18A0F | Line ≈ 2 px fading to #62642D 130 px from the centre; diamond slightly larger; light: copper #C99662 / #DFBF9D | L | code (conflict C1) |
| S8 | Emblem glow | Warm olive halo ≈ 8u: #345022 at 4 px, #204222 at 25 px, #143D21 at 45 px from the emblem. Light: white halo #FEFAF2 (lighter than the ground) | Weaker and ≈ 3u: #1C3E25 / #0B3424 / #002D22 (= ground). Light: a tan halo #FAEEDA, darker than the ground | L | code |
| S9 | Step dots | Size and place as plan (7.7×1.9u, 4.5u). Active pill with vertical gradient #FACE64 → #E8AF23 and a soft drop shadow (dots box 2.6u high vs 1.9u) | Flat #F6B62C (light #D39111), no shadow; sizes 7.6×1.8u ✔ | L | code |
| S10 | Background behind title | #0D3823 (warm, part of the emblem glow) | #012F23 | L | code |

### 30-A (name and avatar)

| # | Element | Reference | Build | Sev | Type |
|---|---|---|---|---|---|
| A1 | **Separator** under the field | Light line #559677 over dark line #1E593F at y 497–498 (58.3u), from inset 2.3u to 2.3u | **Not drawn**, in both themes and both sizes: rows 473–513 are uniform #003925 (std 0) across the card. The widget exists (`onboarding_screen.dart` ≈ lines 582–600) but nothing reaches the screen | **M** | code |
| A2 | Selected avatar ring | Ring Ø larger than the picture: core 3 px #FFFEB1 with #E0B940 / #C8A52B edges at y 563–570, then a 0.8u dark green gap (#4C6426) before the picture (y 578); glow to y ≈ 545 | Ring 6 px #FFEB78 directly on the yellow disc #E7AF04 (y 566–571, no gap): ring and disc have nearly the same lightness, so the chosen avatar hardly stands out (brightness check of round elements) | **M** | code |
| A3 | «ما اسمك؟» size | Ink 18.4×3.0u | 16.4×2.8u (−11%); «اختر صورتك» 19.9 vs 20.4u ✔ | L | code |
| A4 | Card A rim and fill | Rim 4 px core #F1EF8D at y 333–337; fill #0D4F27 → #003322 | Rim #FBE47B 3–4 px ✔; fill #0F5028 → #003925 ✔ | — | ok |
| A5 | Name field | Rim 3 px #C3E2AE at y 409–411; fill #003A26; placeholder 20.9×6.4u #ACCA9D | Rim #B0CE94 at 410–412 ✔; fill #003A24 ✔; placeholder 20.5×6.4u #ABBD9E ✔ | — | ok |
| A6 | Light: «ما اسمك؟» / placeholder / «اختر صورتك» | Brown #603A10, placeholder #9C7B52 | #2C1500, placeholder #756351 (see L1) | L | code |

### 30-B (level)

| # | Element | Reference | Build | Sev | Type |
|---|---|---|---|---|---|
| B1 | **Selected card rim** | Core 3 px #F0E589 / #FFF8A3, then an **outer gold band 4 px** #BE9929 → #A27A07 → #7E6E12, then glow ≈ 15 px (#3F591C → #164726); inner glow ≈ 15 px (#4A5E1E) | Core 3 px #FFF193 / #FFFAA4 ✔, then straight to green #435C2C: **no outer gold band**, outer glow cooler (#2F512C → #0D3E2A); inner glow #355728 ✔. Total rim 0.45u vs 0.8u | **M** | code |
| B2 | Rosette glyph (متقدم) | Ink 8.2×9.5u | 6.2×7.9u (−25%); centre ✔ (62.2u vs 62.4u) | **M** | code |
| B3 | Idle card rim | 3–4 px #889D5E with a dark contact line #002815 outside | 2 px #869659, contact line ✔ | L | code |
| B4 | Card texts | name 14.4×4.8u, line 21.2×4.3u (مبتدئ); 14.1u / 29.7u (متقدم) | 13.2×4.5u, 19.7×4.1u; 13.2u / 29.5u (−0 to −8%) | L | code |
| B5 | Check disc | Ø 54 px (6.3u) ✔; ring ≈ 4 px #FCE387 with outer glow; fill translucent (warm green #565A12 → #4B510F); tick thin | Ø 54 px ✔; ring 2–3 px #FEE35C, no glow; fill opaque #3F4A10; tick bolder | L | code |
| B6 | Card boxes, fills | x 355–707 / 746–1098 / 1136–1488, y 362–662; idle fill #0B542D → #013825; selected #2E6125 → #3C551B | 355–706 / 746–1097 / 1138–1488, 362–661 ✔; #0C542D → #013624 ✔; selected #235C2B → #2D5128 ✔ | — | ok |
| B7 | Light: selected rim | Core #DA9514 with #FACB65 / #FFEDB2 halo ≈ 6 px | #E4A72E 3–4 px, lighter halo; idle rim #E4C9AC ✔ (#E5CBAC). Idle cards cast a darker, wider shadow (#EFE2D0 over 17 px vs ref ≈ 8 px) | L | code |

### 30-C (daily goal)

| # | Element | Reference | Build | Sev | Type |
|---|---|---|---|---|---|
| C1 | **Idle card rim and fill (C)** | Teal rim #3A7C61 / #3B7D64, 3–4 px; flat teal fill #04422F → #003626 → #034633 (brighter at the bottom, with the lattice band) | B's olive rim #9DA661 2–3 px; B's fill lit from the top #0C542C → #013624 | **M** | code |
| C2 | **Selected card interior** | Warm olive glow over the whole card: #45551B (top), #373E15, #0D3A22 (middle), #627023 (bottom band) | Green with glow only near the rim: #2A612C, #0B4A27, #043C24, #2D5128 | **M** | code |
| C3 | **«10 دقائق» / «5 دقائق»** | Ink 23.3×5.6u / 19.6u wide, area 3 393 px (bold) | 19.9×5.4u / 16.9u (−15%), area 2 540 (−25%): smaller and lighter | **M** | code |
| C4 | Word (منتظم، خفيف…) | 12.4×4.7u, cy 67.8u | 10.6u (−15%), cy 68.5u (0.7u low) | L | code |
| C5 | Flame on the selected card | Pale gold double flame (#F5C860) with an amber halo, ≈ 5.7u wide | Library `flame_gold_01`, saturated yellow-orange, ≈ 5.0u, no halo | L | code (conflict C2) |
| C6 | Stopwatch | 6.7×7.5u | 6.3×7.4u ✔ | — | ok |
| C7 | Card boxes | x 1309–1641, y 355–649 | 1309–1642, 355–648 ✔ | — | ok |

### Light theme (all steps)

| # | Element | Reference | Build | Sev | Type |
|---|---|---|---|---|---|
| L1 | Body ink (subtitle, labels, card texts, numbers) | Warm brown #52320B – #5B370B | Near-black brown #200900 – #2B1400 | M | code (conflict C3) |
| L2 | Light emblem (owner still choosing, comment only) | Green fill reaches the gold outline, gold bars below | Variant `green` fills well, but at the inner tips of both wings the green spills past the gold outline into the gap above the lower bars (≈ 3×6 px at 853, both sides): mask of `emblem_inner.webp` slightly too big there | L | code/asset |
| L3 | Corner lattice, arc, waves | See S1–S3 | | | |

### Motion and settings
- Step change B → C (`?slow=10`, frames every 450 ms): cards, title and subtitle cross-fade and slide; emblem, dots and
  background stay still ✔. The main button switches width (29.3 → 43.4u) and text at once, with no tween (L, code).
- Text size 110% (`a-phone-text110.png`): title 549 → 605 px (+10%), layout holds, no overflow ✔.

## Not scored (owner ✅), measured for information
- Light title colour: ref #55340D – #643D10, build #9D704A (much lighter, lower contrast). Kept by the owner as an app
  standard; flagged because the difference is large.
- `LessonButton`: ref rim 3 px saturated #D9B219 / #ECBF1D with gold glow; build rim 2 px pale #EFE798 / #FFFFA8 (top),
  text #F9EAAC sits ≈ 0.8u lower in the button than in the ref and is 5.3u high vs 4.7u; C text 24.2u vs 29.3u wide. Light:
  fill #E3B754 vs #ECAF16.
- `LessonRoundButton`: ref ring #F7C820 ≈ 3 px, Ø 92 px; build #EAA733 orange-gold, Ø 89 px.
- Avatars (library, yellow disc #E7AF04) vs the reference's children on green discs; the yellow discs are the brightest
  round elements of the card (see A2 for the selection contrast, which is scored).
- Mosque A6: a different skyline from the reference (ref: one big central dome, three thin minarets, small side domes,
  #013827 on a #085F3B glow; build: two minarets either side of a dome with an arcade, #02331F). Light: #F5E4D0 vs #EACCB0.
- Emblem: 14.8×15.1u, top 2.7u (ref 14.7–15.6u, top 0.7–2.5u).

## Suggested fix for S1, S2, S3 (code, uses an existing app asset)
The splash background `assets/ui/splash/background.webp` (screen 01, approved, 1844×853) already contains the reference's
whole decor: star lattice corners fading inwards, the gold arc fading at its ends, the green swoosh with a gold line, and a
mosque with the **same skyline as the reference** in the same place (≈ 1430–1800 × 600–770 vs ref 1465–1805 × 615–770).
A 50% blend with `reference-b-level-dark` lines up the arc and the mosque almost exactly; the swoosh is ≈ 40 px lower than
the reference. It is an existing app standard (owner's rule 2026-11-28), so using it as the dark background would fix S1–S3
and the mosque at once. To ask the owner (it also replaces the mosque A6 they kept). The light theme has no such asset (see
asset item G-L below) or keeps the code decor with S1–S3 fixed.

## Asset items
**G-L (optional, light background like the splash's).** Attach, in this order: `app_flutter/assets/ui/splash/background.webp`,
`docs/flutter/screens/30-onboarding/reference-b-level-light.webp`, and two light screenshots of the approved app from
`docs/flutter/app-references/`.

```
Same style as the attached app screenshots, do not invent a new style. Make the LIGHT version of the first attached image
(the app's dark splash background), 1844×853, landscape, with the same composition and the same elements in the same
places: fine gold 8-point-star lattice in the two top corners fading inwards, one thin gold elliptical arc over the top that
fades out toward its two lower ends, a soft wide swoosh band at the bottom with one thin gold line, and the mosque skyline
at the bottom right (same silhouette: one large central dome, three thin minarets, small side domes). Colours as the second
attached image (light onboarding reference): cream background #FDF3E8 to #FFF8EF, gold lines #D39D28 to #D8A62A, mosque in
soft peach #F5E4D0 fading to the background at its base, cream swoosh band. No text, no emblem, no cards, no buttons, no
people. Flat, clean, no noise or grain.
```

No other asset is missing: stopwatch, outline star, open book and rosettes are the owner's; the corner lattice A5 already
has the reference's pattern (S2 is opacity and tint in code).

## Conflicts with app standards / DESIGN-SYSTEM (for the owner)
- **C1 `GoldDivider`** (used on other screens): the reference's divider is thicker (3–5 px vs ≈ 2 px), solid gold to the
  tip, and gold in light too (build: copper `readLCopper`). Keep the standard, or thicken it here only?
- **C2 `icons/flame_gold_01`** (flame of 12): the reference's flame is paler, a double flame with an amber halo.
- **C3 Light ink of `LessonPal`** (08/10/24): reference body text is warm brown #52320B – #5B370B, the palette gives
  #200900 – #2B1400. Same family for the light divider and arc (`readLCopper` vs gold #D0A43E).
- **C4 Splash background as the screen's decor** (suggested fix above): it would also replace the kept mosque A6.
- **C5 Documentation gap:** the `onb*` colours (`rateel_theme.dart` 404–451) are screen-local by the owner's rule of
  2026-11-28, but differ from the confirmed tokens (selected rim token 1.2 px #DAA42A + 1 px #FFDA6B glow 15%; glass tile rim
  2 px #1C4E38; no token for step dots). DESIGN-SYSTEM.md does not list them; add a line so later screens do not reuse
  them by mistake.

## High and medium items (to fix before the next round)
1. S1 bottom waves (H, code; or C4).
2. S2 corner lattice too faint (M, code).
3. S3 arc does not fade at its ends; light arc copper (M, code).
4. S4 subtitles 14–27% smaller and lighter than the reference (M, code).
5. A1 separator not drawn (M, code bug).
6. A2 selected avatar ring: no gap, low contrast on the yellow disc (M, code).
7. B1 selected card rim: no outer gold band (M, code).
8. B2 rosette glyph 25% small (M, code).
9. C1 C idle cards: teal rim and flat teal fill (M, code).
10. C2 C selected card: warm interior glow missing (M, code).
11. C3 C minutes 15% smaller and lighter (M, code).
12. L1 light body ink too dark (M, code; conflict C3).
