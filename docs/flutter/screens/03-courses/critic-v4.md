# Critic v4: courses (learning paths), Flutter v6

Fidelity score: **8.5/10 for the whole screen** (v3: 7.5). There is no separate "code-only" score.

There is **no exclusion list** (`CRITIC.md`, "No exclusions"). Only owner-approved differences (DECISIONS ✅) are skipped. For each one, this report checks that it is built as described:

| ✅ decision (date) | Built as described? |
|---|---|
| Side nav instead of the reference rail (2026-11-20). Rail shadow on the content (2026-11-21) | Yes. The content's right edge is at x1686 (reference x1672). The shadow darkens the right edge of the content: x1680 is #001D16 at y150 (reference #00241C) |
| Progress always starts at 0% (2026-11-20) | Yes. The bar is empty (track x1161-1510) and the label reads «0%» |
| Two-half line between courses (2026-11-20) | Yes. Dim track #265343, 3 px. The node is exactly in the middle (x957 = (915+999)/2), Ø22. The first half and the node light up at 50%, the second half on completion. Completion frames below |
| Haptics (2026-11-20) | `Haptics.milestone` at 50% and 100%, `unlock` on the passage, `success` at the last course. Not visible in captures |
| Breathing glow removed | Yes. Above the active card the background is flat #032E23 (y299-327) |
| Top-right corner ornament larger, running on under the rail (2026-11-21) | Yes. Bbox x1552-1682, y0-127. It is cut by the rail at x1686. p97 #877927 (reference #897A38) |
| Mosque larger and higher, fading out at the ground (2026-11-21) | Yes. Bbox x42-469, y80-253. It fades out between 0.66 and 0.80 of its box, and there is no ground strip |
| «مستوى مبتدئ» optically centred in the pill (2026-11-21) | Yes. Text y383-404 in a pill y366-417: 17 px above, 13 px below, so the visual centre (without the descenders) is centred |
| Titles in warm cream with a soft shadow, screen title with a cream gradient (2026-11-21) | Yes. Card titles #FAF1D8. Screen title gradient #FFFBEA → #E9D7A8. The shadow adds about 6 px to the measured height of the titles. This is not scored |

## Method

- **Images.** Reference `critic5/ref-03.png` (1847x851) and Flutter v6 `critic5/c-settled.png` (1844x853), not resampled. Other captures: `c-locked-tap`, `c-scrolled`, `c-menu-open`, and the completion frames `k-00`…`k-15`.
- **Scripts.** The round-3 scripts (`a1`…`a8`, `v2a`/`v2b`/`v2c`) are copied to `scratchpad/critic4s/` and re-pointed to `critic5/`. `k.py` is new: it measures, for each frame, the gold runs on the line row y566 and the bar fill. All scripts are run with `python3 -I`.
- **Units.** 1 u = 8.53 px. The masks are the same as in round 3.

## Round-3 items: status

| # | Item | Reference | Flutter v6 | Status |
|---|---|---|---|---|
| A1 | Arch geometry | Shoulders y105-107. Width at y160: 819 px. Flanks fade out by y≈215 (right flank) | Shoulders y104-110. Width at y160: 817 px. Flanks fade out | **Fixed.** Residual (low): the flanks fade about 25 px too early. Right flank at y182: reference warm 48 (#5B612B), Flutter 18 (#3A4D28). The reference also has a faint outward tail to x≈1370, y≈245 that Flutter lacks |
| A2 | Arch line weight | 4 px (x740: rows 61-64) | 5 px (rows 63-67) | Improved, now **low** (asset P-A2 still open) |
| A3 | Header axis (distance from the rail) | Apex / emblem / title / diamond: 808 / 810 / 807 / 810 | 808 / 809 / 810 / 814 | **Fixed** (±4) |
| A4 | Open-Quran emblem | 119x60, filled pages | **115x54**, thin outline book | Still **medium**: 6 px short, and an outline instead of filled pages |
| A5 | Mosque | — | — | Superseded by the ✅ change (see the table above) |
| A6 | Mosque brightness | — | `Opacity(0.83)` | **Fixed** |
| A7 | Crescent and star: size | Bbox 83x78, 221-303 from the rail | 76x73, 226-301 | Now **low**: 7 px narrower, 5 px shorter |
| A8 | Star colour | Dim olive: median #7A7129, p97 #9C8527 | Full gold: median #CA9724, p97 #D7A32B | Still **medium** |
| A9 | Left corner: size | Reaches x+y = 213 | x+y = 213 | **Fixed** |
| A10 | Corner ornament style | Carved strokes: runs of 8-11 px at row 100. p97 #94883A | Wire strokes: runs of 2-3 px. p97 #7F7527 | Still **medium** (asset P-A10) |
| A11 | Right corner | — | — | Superseded by the ✅ change |
| A12 | Divider gradient | −175: #878136, −55: #F0C348 | −175: #626931, −55: #F0C448 | **Fixed.** Residual (low): the gold span is 11-13 px shorter on each side of the diamond: left/right 169/179 px vs 182/189 px |
| A13 | Divider geometry | Line y266-268 | y266-268 | OK |
| A14 | Title size | 669x75 | 658x81 (the shadow adds height) | **Low**: 11 px narrower |
| B1 | Connector lines | — | — | Superseded by the ✅ two-half line. Built as described |
| B2 | «0%» / «30%» | — | — | Superseded by the ✅ "start at 0%" |
| B3 | Bar length | 351 px (x1147-1497), 115 px from the card's right edge | 350 px (x1161-1510), 115 px from the right edge | **Fixed** |
| B4 | Breathing glow | — | Removed | **Fixed** |
| B5 | Toast on a locked tap | Not in the reference | Still built: pill y772-831, «أكمل «أساسيات التجويد» أولًا لفتح هذه الدورة» | Still **medium / owner** (Q1) |
| B6 | Active rim | 4 px #998439 / #CEA03B / #C79B34 | 4 px #C69F3D / #9C8835 / #D3A436 / #C59D35 | **Fixed** |
| B7 | Locked rim outer line | 1 px #00291C above the top rim, then a gradient | No outer line; flat #2F6954 (rows 331-334) | Still **low** |
| B8 | Horizontal sheen | Locked card: edges #03372A, middle #023227. Active card: middle #012F25 | Locked: edges #04392B, middle #033529. Active: middle #033428 | Mostly fixed. Residual (low): the middle is 3-5 levels too bright |
| B9 | Active card height | 430 | ≈430 | **Fixed** |
| B10 | Description colour | Locked median #CBCCB8, active #CFD0BA (p97 #E8EFD7) | #F2E9CF / #F4EAD0 (token `cream`) | Raised to **medium / owner** (Q2). ΔL ≈ 30. Next to the warmer titles, the descriptions in the reference are clearly a dimmer secondary text |
| B11 | Locked title and description | Title inset 49, line pitch 42 | 49, 42 | **Fixed** |
| B12 | Card bottom pattern | Visible from about 40 px above the bottom: luminance std 2.0 / 2.5 at 50 / 40 px | Visible from about 60 px: std 4.4 / 7.0 at 50 / 40 px | **Overshoot, now medium**: the lattice is visibly stronger and taller |
| B13 | Course 01 icon (active) | 102x65, 51-152 from the card's right edge, +38-+102 | **94x54**, 56-149, +46-+99 | **Medium** (overcorrected in v5): 8 px narrower, 11 px shorter |
| B14 | Course 02 icon (locked) | 71x75, cream → gold gradient | 57x71, flat #E7B32E | **Low**: asset aspect 0.80 vs 0.95 (P-B14) |
| B15 | Lock glyph | #EDE3CB | #EDE3CB | **Fixed** |
| B16 | Star and play glyph | Star median #EFB527, play p97 #FFD556 | Median #F7C53E, p97 #FBCD4B (gradient) | **Fixed** |
| B17 | Background | y5, x250: #063127. y300: #013327. y840: #002D23 | #032D23 / #032E23 / #002C22 | Bottom fixed. Residual (low): top and mid are −3 to −4 levels in G |
| B18 | Course 3 text | «دورة متقدمة …» | «دورة متخصصة …» | **Low / owner** (Q3) |
| B19 | Level pill text | — | Still hard-coded (`Course` has no `level`) | **Low** |
| B20 | Gap between the line and the card | 8 px dark gap | 1-2 px: the lit line runs to x997 and x917, touching both rims | **Low** |

## New differences

| # | Element | Reference | Flutter v6 | Sev. | Type | Fix |
|---|---|---|---|---|---|---|
| N1 | Level pill fill | Glass fill: #073C2A at the top, #063324 below, with a soft drop shadow under the pill | Flat #062D20, no shadow | low | code | Pill gradient #073C2A → #063324 (vertical), plus `BoxShadow` black 30%, blur 1.2u, y +0.4u |
| N2 | Node glow during completion | — | The glow behind the node (alpha 0.30) appears in one frame when `half1` reaches 1, after the pop | low | code | Draw the glow with alpha `0.30 * max(nodePop, half1>=1 ? 1 : 0)`, so it grows with the pop |

## Completion sequence (k-00 … k-15)

| Frames | Measured | Finding |
|---|---|---|
| k-00 | Bar empty, «0%», line dim, node dim | OK |
| k-01 | Bar fill to x1314 (46%), «44%» | OK. The ticks run |
| k-02 | 50%. Lit run x946-997, node x957 #FCC24A lit with its glow | OK. Half 1 (from the active card to the node) and the node light up at 50% |
| k-03 | 100%, bar to x1510. Half 1 still lit (x949-997) | OK. The run's start moves 3 px (946 → 949): this is the spark leaving, not a glitch |
| k-04 | Half 2 running: lit x925-997, white-gold spark at the head | OK |
| k-05 | Lit x917-1002 (full line, reaching the next card's rim). Card 2 turns gold, lock gone, active layout | OK. Icon jump between the two layouts: not visible at a 0.3 s frame spacing (v3 low item, unverifiable) |
| k-06 … k-15 | Glide done. New active card «النون والميم المشددتان» at 0%. The line to course 3 is dim, its node dim. The completed course slides under the rail | OK, no flicker or cut-off |

The v3 "node pops in one frame" item is **fixed**: the node now scales with `nodePop` (×1.45 sine). The only glitch left is N2.

## Conflicts with DESIGN-SYSTEM.md

These are still open:

1. Locked rim, 4 px gradient, vs the glass rim token.
2. Active rim, now 4 px #C69F3D / #D3A436, vs the selected rim token.
3. Gold outline pill text vs "text on gold".
4. **Description colour: reference #CFD0BA vs token `cream` #F4EAD0 (B10).**

Hard-coded values remain in the screen code:
- line width `3`
- decor opacities 0.75 / 0.8 / 0.83
- rule colours `0x00F2B623`
- divider gradient colours

## Owner questions

- **Q1.** Locked-card tap: keep the toast (not in the reference) or only the lock shake?
- **Q2.** Card descriptions: use the reference's dimmer grey-cream #CFD0BA (a new token `textSecondary`), or keep `cream` #F4EAD0?
- **Q3.** Course 3 description: the reference copy or the `courses.json` text?

## ChatGPT prompts still open

These are unchanged from v3: **P-A2** (thinner arch, optional), **P-A4** (filled emblem, 2:1), **P-A7** (crescent with a separate dim star), **P-A10** (carved corner lattice), **P-B13** (course-01 icon without the brown outline, 1.57:1) and **P-B14** (voice-profile icon with a gradient, aspect 0.95).

## Summary

**High: none.**

**Medium (7)**

| Item | Type | Fix |
|---|---|---|
| A4 emblem | code + asset | Interim code: `width` 14.0u → **14.45u**, `left` `cx − 7.22u`, `height` 7.0u → **7.8u**, `top` 7.85u → **7.45u** (content ≈ 119x60). Final: prompt P-A4 (filled pages) |
| A8 star colour | code (asset edit) | `crescent_star.svg` has one path with two subpaths. Split the second subpath (bbox x767-1058, y357-628, the star) into its own `<path fill="url(#gold)" fill-opacity="0.55">` |
| A10 corner style | asset | Prompt P-A10 |
| B5 toast | owner | Q1 |
| B10 description colour | owner / code | Q2. If approved: a token `textSecondary` #CFD0BA, used in `_description` |
| B12 card pattern | code | `_pattern` mask stops `[0, 0.65]` → **`[0.35, 0.85]`**. The lattice then starts about 46 px above the card bottom, as in the reference |
| B13 course 01 icon | code | `_icon` on the active card: `width` 12.0u → **13.0u**, `height` 7.6u → **8.3u**, `right` 5.9u → **5.3u**, `top` 4.4u → **3.75u**. This gives ≈ 102x59, 51 px from the right edge, at +38 |

**Low (15):**

| Item | Fix |
|---|---|
| A1 residual | Arch mask stops [0.45, 0.92] → **[0.55, 1.0]** |
| A2 | Asset P-A2 |
| A7 | Crescent `width` **10.65u**, `height` **9.75u**, `right` **25.5u**, `top` **7.5u** |
| A12 | Divider `width` 48u → **50.6u** (`left` cx − 25.3u) |
| A14 | Title |
| B7 | Locked rim outer line |
| B8 | Sheen middle −4 |
| B14 | Locked icon `height` **9.3u** |
| B17 | Background top and mid |
| B18 | Course 3 text (Q3) |
| B19 | Level pill text |
| B20 | Inset the connector **0.9u** at both ends |
| N1 | Pill fill |
| N2 | Node glow |
| Icon jump | During completion (unverified) |
