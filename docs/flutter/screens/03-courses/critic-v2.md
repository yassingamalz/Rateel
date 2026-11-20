# Critic v2: courses (learning paths)

Fidelity score: **8.5/10** for the parts code controls (v1: 7.5), **6.5/10** for the whole screen (v1: 6; the arch, emblem, mosque, crescent and course icons 2-12 are still placeholders).

## Method

- Same scripts as v1 (`scratchpad/critic/m.py` to `m15.py`, `python3 -I`). Because the pitch fix moved the cards, the Flutter coordinates were re-anchored in `scratchpad/critic2s/v2a.py`, `v2b.py` and `v2c.py`.
- Images: reference 1847x851 (u = 8.51 px), Flutter 1844x853 (u = 8.53 px). They are not resampled.
- The content's right edge ("rail") is x1672 in the reference and x1686 in Flutter.
- Cards in Flutter v2:
  - active card x999-1625, y327-760
  - card 2 x298-915, y331-756
  - card 3 right edge x209
- Colour masks and percentiles are the same as in v1.
- Captures: `c-settled`, `c-locked-tap`, `c-scrolled`, `c-menu-open`, and the completion frames `k-00`…`k-11` (`?complete=0`, slowed x3).

## Round-1 items re-measured

| # | Item | Reference | Flutter v2 | Status |
|---|---|---|---|---|
| 1 | Card pitch | Active centre 373 from rail. Card 2 centre 1077.5. Gaps 84 / 83 px | Active centre 374. Card 2 centre 1079.5. Gaps 84 / 89 px | **fixed**. Card 3's right edge is 1477 vs 1468 (+9) because the reference pitch is not uniform (704.5 then ≈ 698.5). Low, accept |
| 2 | Corner radius | 42.0 (locked) / 41.5 (active) | 41.5 / 42.0 | **fixed** |
| 3 | Divider gradient and length | Bright next to the diamond: #EFC043 at −75, #E8B944 at −35, #E7B840 at −115, **#AF973A at −155**, fading out by ±200. Visible span 667-1067 (**400 px**) | Direction now correct (bright inside, fading outward) and symmetric. But it fades linearly from the diamond: #E3AE23 at −37, #AD9024 at −77, **#767125 at −117**, #405225 at −157. Visible span 716-1032 (**316 px**) | **still off: medium.** The fade starts too early, so the visible span is −84 px |
| 4 | Diamond and bars | Diamond 23 px wide, rows 255-280. Bars at ±25, 3 px | Diamond 22 px, rows 255-280. Bars at ±25, 2 px | **fixed** |
| 5 | Title position | Bbox y162-236, centre 199. Baseline band 210-214 | y159-240, centre 199.5. Band 211-215 | **fixed** |
| 6 | Title size and weight | 669x75, stroke 10 px | 663x82, stroke 11 px | **still off: low.** The stroke is still +1 px at weight 560 |
| 7 | Pill text | Gold, p97 #FFDD2E. 168x31 px, from 393 to 560 px from the card's right edge | Gold, p97 #F2B623 (**colour fixed**). Only **155x21 px**, from 398 to 552 | **still off: medium (size).** The size went to 3.3u, but the `FittedBox` scales the text down: the row has 240 − 2·2.0u padding − 4.4u star − 1.2u gap ≈ 158 px for 168 px of text |
| 8 | Locked title | Right inset 49. Top/bottom +130/+178, centre 154. Width 453 | Right inset 52. +130/+184, centre 157. Width 465 | **mostly fixed; low.** 3 px right and 3 px low. The text is 2.6% larger than the reference |
| 9 | Locked gold rule | 78-479 px from the right edge, y +202-204, p97 #FFDF65 | 73-480, y +203-204, p97 #FDD664 | **fixed** |
| 10 | Card fill (locked) | Rows from the top, every 30 px: #023328 … #012F24 (180) … #023126 (300) → #033529 → #043A2C → #054031 | #033328 … #012F25 (180) … #023126 (270) → #03362A → #043A2C → #053D2F | **fixed.** The reference active card is darker low down (#012F24 at 300 vs #023227): low, accept |
| 11 | Bottom pattern | Luminance mean/std per 10-row band, bottom 70 px: 37/1.5 → 44/4.6 → **47/6.2** → 48/9.8 | 38/0.7 → 43/4.4 → **43/4.1** → 46/11.7 | **improved; low.** It is about 30% fainter in the band 50-60 px above the bottom edge |
| 12 | Locked rim | Top: 1 px #00291C dark line, then #1B533F / #2D6853 / #2F6954 / #1D5843. Bottom: #336F57 / #518E73 / #407B62, then #00140B. Sides at y450 / 650 / 720: #27654F / #27634D / **#3D7861** | Top #2F6954 x3 + #2C6651. Bottom #316C56 / #559174 x3, then #00110A. Sides: #2B6751 / **#39765D** / #4C886C | **fixed (top and bottom).** New low item: the sides brighten too early (+15 L at y650) because the gradient stop is 0.6 |
| 13 | Horizontal sheen | Locked: #03372A at the edges, #023227 in the middle. Active: #033628 at the left edge, #012F25 in the middle | Flat (#033529 / #033428) | not done; low |
| 14 | Active outer glow | Above the top rim the background is flat (#013327) until 2 px out | Warm halo from 25 px out: #032D23 → #0E2E1E (breath 0-10%) | improved; low (owner: motion) |
| 15 | Active rim colour | #998439 / #CEA03B / #C79B34 / #958439 | #F2B132 / #D1B95B / #FFDA6B | unchanged; low |
| 16 | Background | y5: #063127 at x250, #063429 at x500. y840: #002D23 | y5: #032D22 / #043125 (centre #07362A matches). y840: #00281E | top improved. The bottom lift is missing: low |
| 17 | Lattice corners | Left p95 #6B6D2F. Right corner 155-16 from rail | Left p95 #656D40. Right corner 151-9 from rail | opacity **fixed**. Right position unchanged: low |
| 18 | Path nodes | Node 1: Ø22, 12 px from the card, core #FDC651 | Ø22, 12 px, core #F9C049 | **fixed.** The track still runs past the node into the card (the reference has a dark gap of about 8 px): low |
| 19 | Active gold rule | 87-473 px from the right edge | 86-459 | right end fixed. The left end is 14 px short (width 51.5u → 52u was not applied): low |
| 20 | Active description colour | #D9DAC6 | #F4EAD0 | owner decision |
| 21 | Locked description | Right inset 50, width 424, line pitch 42 (rows +247/+289) | Right inset 50, width 415, pitch **44.5** (rows +249.5/+294) | inset fixed. Line height 5.1u → 4.95u was not applied: low |
| 22 | Lock glyph | 22x28, #EDE3CB | 22x28, #DAD7BF | **fixed** |
| 23 | Active card height | 430 | 434 | unchanged; low (accept) |
| 24 | Pill fill | Dark #06…, cool | #062D20 | **fixed** |
| 25 | Toast | — | y772-831, 12 px below the cards (756/760), centred on the content | **fixed** |

## New differences introduced by the fixes / new code

| # | Region | Finding | Severity | Type | Fix |
|---|---|---|---|---|---|
| N1 | Percent text at 100% | «100%» is 58 px wide (x1513-1570). The bar's gold end is at x1510, so there is a **2 px gap**: the text touches the bar (k-03…k-06). The reference gap at «0%» is 28 px | **medium** | code | Put the percent in a fixed right-aligned slot (`right: 6.3u`, `width: 7.0u`, `TextAlign.right`) and shorten the bar from 40.4u to **38.9u**. The bar then ends 128 px from the card's right edge (ref 115) and the gap is ≥ 13 px at 100%. Alternative: keep the bar and set `FittedBox(scaleDown)` on the text with max width 5.4u, so «100%» scales to 46 px |
| N2 | Unlock cross-fade | `lockedOpacity = 1 − t/0.4` and `activeOpacity = (t − 0.5)/0.5`, so for t = 0.4-0.5 (65 ms) **neither layer is visible**: the title blinks out. The title also moves 6 px right and 2 px up between the layouts (right 5.7u → 6.4u, centre 17.2u → 17.0u), and the placeholder icon jumps from the centre to the right | low | code | Overlap the fades: locked `1 − t/0.5`, active `(t − 0.35)/0.5`. Or keep one title widget whose position lerps with `t` |
| N3 | Node turning gold | The node next to the newly current card switches from #265343 to gold in one frame when `_current` changes (k-05 → k-06) | low | code | Lerp the node colour with `_unlock.value` for `i == _completing + 1` |
| N4 | `_RimPainter` side gradient | The stop at 0.6 makes the lower 40% of the side rim brighten (see #12) | low | code | Stops `[0, 0.6, 1]` → **`[0, 0.85, 1]`** |
| N5 | `_ConnectorPainter.shouldRepaint` | Ignores `nodeFromRight`. There is no visible effect today, because the page's repaint boundary repaints with the card's transform | low | code | Add `old.nodeFromRight != nodeFromRight` |
| N6 | Pending completion | `_onCourseCompleted` returns early while `_completing != null`, so a second completion during the sequence stays in `courseCompleted` and is only consumed at the next rebuild of the listener (never) | low | code | When the sequence ends, call `_onCourseCompleted()` again |
| N7 | Level pill text | «مستوى مبتدئ» is hard-coded for every course (course 2 shows it after the unlock) | low | data | Add a `level` field to `Course` |

## Completion sequence (k-00 … k-11)

There is no reference for this; it is the owner's request. The order is correct:

| Frames | What happens |
|---|---|
| k-00 / k-01 | Rest at 30% |
| k-02 | The bar fills to 73% |
| k-03 | 100% |
| k-04 | The light runs right to left from the completed card. Spark: white core with a gold blur. The dim track stays ahead of the spark |
| k-05 | The line is fully gold. The lock pops (larger, fading) and the locked text greys out |
| k-06 | Card 2 has a gold rim, pill, play and 0%. The completed card keeps its gold rim and 100% |
| k-07 | The path glides. The outgoing card is cut cleanly at the nav edge (x1686), the same as a normal scroll |
| k-08 … k-11 | Settled on course 2. Its node is gold and its outgoing line is a dim track, consistent with the rest state |

No jumps in the card positions, no overlaps and no text overflow, apart from these:
- **N1:** the «100%» text touches the bar (medium).
- **N2:** the 65 ms title blink and the icon jump during the unlock (low).
- **N3:** the node pops to gold (low).

## Known / accepted (not scored as code defects)

- **Side nav:** the owner-approved side nav (style C) replaces the reference rail, so the content is 14 px wider.
- **Placeholders:**
  - header arch (P1), which crosses behind the title
  - open-book emblem
  - mosque and crescent (absent)
  - course icons 2-12 (outline book)
  - lock and star glyphs (Material)
  - the left lattice corner shape
- **Progress text:** «30%» vs the reference's «0%» (the reference is inconsistent).
- **Owner decision (deliberate change):** the lines after an unfinished course are a **dim emerald track** (#265343, node #265343). They become gold only after a completed course. The reference shows every line and node gold, so the line between the active card and card 2 and the node at card 2 differ from the reference on purpose.
- **Course 3 description:** the text differs from the reference («دورة متخصصة…» vs «دورة متقدمة…»). The data comes from the Angular `courses.json`.

## Token conflicts with DESIGN-SYSTEM.md

The proposed screen-03 tokens are now listed in DESIGN-SYSTEM.md (🟡), with the glass-rim and selected-rim conflicts marked. Still open for the owner:

1. Locked rim 4 px vs the glass rim token (2 px #245843).
2. Active rim and glow vs the selected-rim token.
3. Gold pill text vs the "text on gold" token.
4. Active description #D9DAC6 vs cream.

Hard-coded style values remain in the screen code:
- `Color(0x00F2B623)` (rule fade, ×2)
- `Colors.black` at 0.40 / 0.35 (shadows)
- stroke widths 1.4 / 2 / 4 (rim), 2 (divider) and 3 (path)
- lattice and arch opacities 0.45 / 0.85

They should move to `rateel_theme.dart`.

## Summary

**Fixed since v1:**
- the 10 medium items #1, #2, #5, #9, #10 and #12, and #11 (now low)
- #7 colour, #8 (now low), and the direction of #3
- the low items #4, #17 (opacity), #18, #22, #24 and #25

**Remaining medium code items (3):**
- **#3 divider fade.** Make the line gradient `stops: [0, 0.6, 1]`, colours `[gold, gold, gold@0]`, and keep the width at 47u. The visible span then returns to ≈ 400 px.
- **#7 pill text scaled down.** Pill `padding` horizontal 2.0u → **1.0u**. The text slot becomes ≈ 175 px, so the text renders at its 3.3u size, about 168 px wide.
- **N1 «100%» touches the bar.** Fixed right-aligned percent slot (`right 6.3u`, `width 7.0u`) and bar width 40.4u → **38.9u**. Or scale the percent down to a 5.4u maximum width.

**No high items.**

**Assets:** the asset list is unchanged.
