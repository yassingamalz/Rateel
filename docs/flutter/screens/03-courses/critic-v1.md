# Critic v1: courses (learning paths)

Fidelity score: **7.5/10** for the parts code controls, **6/10** for the whole screen (the arch, mosque, crescent and course icons are still placeholders).

## Method

- The scripts are `scratchpad/critic/m.py` to `m15.py`, run with `python3 -I`. Each image is measured in its own pixels: reference 1847x851 (u = 8.51 px), Flutter 1844x853 (u = 8.53 px). The size difference is 0.2%, so the images are not resampled.
- The content's right edge is x1672 in the reference and x1686 in Flutter. "from rail" means the distance to that edge.
- Bounding boxes come from colour masks: gold is R>140 and R-B>70; cream text is L>150-170 and R-B<60. Colours are medians or 97th percentiles of the masked pixels. Rim and glow colours come from 1 px profiles.
- Captures: `c-settled.png` (main), `c-locked-tap.png`, `c-scrolled.png` and `c-menu-open.png`.

## Already matching (within ±3 px or the same hex)

**Active card content.** Every element is within ±3 px of the reference.
- **Pill:** 245x55 vs 245x53, inset 328-572 px from the card's right edge in both. Rim 2-3 px #EECC54 vs #F2B623.
- **Title:** 353x58 vs 348x58. Right inset 55 vs 58, top 119 vs 120 from the card top. Colour p97 #FFFBE8 vs #FFFDF5.
- **Gold rule:** y = card top +204 in both.
- **Description:** right inset 57 vs 58. Baselines at 575/618 vs 578/621, line pitch 43 in both. Wraps after «وقواعد» in both.
- **Play button:** Ø71 in both, at 502-572 vs 503-573 from the right edge. Rim 3 px (#F9D45E vs #FFDA6B), fill #42552B vs #43552A.
- **Progress bar:** 351 px wide in both, at 115-465 from the right edge. Track #275341 vs #265343. Fill 107 vs 105 px, #ECB536 vs #EBB335.
- **Percent text:** right inset 53 vs 56, text height 18 vs 17.

**Card sizes.** Locked cards are 616x426 vs 617x426. The active card is 627x430 vs 628x434. Card tops are 329/328 vs 331/327.

**Locked card details**
- **Lock disc:** 68x64 vs 66x66, at 35-102 vs 36-101 from the right edge and 32-95 vs 31-96 from the top. Rim #1A533F in both, fill #00271E vs #01261E. The glyph is 22x28 vs 20x26.
- **Description:** baselines are +247/+289 vs +249/+294 from the card top.

**Path**
- **Line:** y = card centre +23.5 vs +23 px (2.76u), 3 px thick in both.
- **Nodes:** Ø20 vs Ø19. The glow fades to the background over about 25 px in both.

**Drop shadow.** Below the card: #02221C at 1-3 px, reaching the background (#002920) by about 30 px. Flutter: #012119, reaching the background by about 28 px.

**Title divider.** The line is at y267-268 (2 px) in both, and the diamond centre is 810 vs 812 px from the rail.

## Differences

| # | Region | Reference | Flutter v1 | Δ | Severity | Type | Fix |
|---|---|---|---|---|---|---|---|
| 1 | Card pitch / horizontal track | Pitch **704.5 px (82.8u)**. Active centre 373 from rail. Card 2 centre 1077.5 from rail. Card 3 right edge 1468 from rail | Pitch **696.5 px (81.65u)**. Active centre 369.5. Card 2 centre 1066. Card 3 right edge 1455 | −8 px per card (−3.5, −11.5, −13 px from rail) | medium | code | Bug: `viewportFraction = g.pitch / g.w`, but the PageView viewport is `w − trackRightInset` wide, so each page is 696.6 px instead of 705.4. Use `pitch / (g.w − trackRightInset)` and keep `trackRightInset = firstCenterFromRight − pitch/2` |
| 2 | Card corner radius | ≈ 42 px fitted on the outer rim, both cards (≈ 4.6-4.9u) | ≈ 32.5 px fitted (code 3.5u = 30 px) | −10 px | medium | code | `radius` 3.5u → **4.7u** |
| 3 | Title divider: gradient and length | Both halves are brightest next to the diamond (#EFC043-#F7CF52) and fade outward. Visible span x667-1067 (**400 px**, ±200 from the diamond) | **The left half is reversed**: bright at its outer end (#A78D24 at x635, #C69E24 at 675) and fading toward the diamond (#153D28 at 835). The right half is correct. Span 635-≈1100 (≈ 476 px) | left half inverted; +38 px per side | medium | code | `_DividerPainter`: for s = −1, build the gradient from `inner` to `outer` explicitly (`LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft)` for the left half, or one shader over the full width with stops). Width 56u → **47u** |
| 4 | Divider ornament | Diamond 23 px wide x 26 px tall. Bars 3 px wide at ±25 px from the centre. Peak #F7CF52 | Diamond 16 x 20, dots at ±20 px, peak #DDAB24 | −7 px, −5 px | low | code | Diamond half-size 1.0u → **1.35u**; `gap` 2.6u → **3.15u** |
| 5 | Header title position | Bbox x531-1199 y162-236 (669x75), centre y199 = **23.4u**. Baseline band y210-217 | Bbox x543-1200 y168-248 (658x81), centre y208 = **24.4u**. Baseline band y220-228 | +9 px (1.0u) lower | medium | code | Title centre 23.4u → **22.4u** (Readex sits low with height 1) |
| 6 | Header title size and weight | Width 669 px, stroke runs 10 px, colour median #F9F0DA (p97 #FFFBE8) | Width 658 px, stroke 11 px, #FFFDF5 | −1.6% width; strokes +1 px | low | code | Size 9.15u → **9.3u**, weight 600 → **560** |
| 7 | Pill text «مستوى مبتدئ» | **Gold** p97 #FFDD2E (median ≈ #FBCA30), 168 px wide (31 px including dots) | Cream #FFFDF5, 155 px wide (22 px) | wrong colour; −8% size | medium | code | Text colour → `RateelColors.gold`; size 3.0u → **3.3u** |
| 8 | Locked card title position | Right inset **49 px**, top/bottom +130/+178 from the card top (centre 154 = 18.1u) | Right inset **58 px**, +138/+185 (centre 161.5) | 9 px too far left, 7.5 px too low | medium | code | Locked cards: title right 6.4u → **5.7u**, centreY 18.1u → **17.2u** |
| 9 | Locked card gold rule | **Full gold**, p97 #FFDF65. Visible 78-479 px from the right edge (402 px). y = +202-204 | Opacity 0.55, p97 **#8C8B47**. Visible 90-424 px (335 px). y = +206-207 | much dimmer, −67 px, +3 px | medium | code | Opacity 0.55 → **1.0**. Width 51.5u → **54.8u**, right 6.5u → **6.4u**, centreY 24.3u → **23.9u** |
| 10 | Card fill gradient (locked and active) | Top #023328. Darkest **plateau #012F25 from 0.43 to 0.72** of the height, then rising to #03382B (0.8), #043D2E (0.9) and **#053F30** (0.96) | Top #033428. Minimum #012E23 at 0.43, then a linear rise: #013528 at 0.66 (ref #023126) and #023C2D at the bottom (ref #053F30) | lower middle too light, bottom too dark | medium | code | Stops [0, 0.5, 0.72, 1] = [#033428, **#012F25**, **#023126**, **#053F30**] |
| 11 | Bottom star pattern | Visible: luminance std in the bottom 30 px **6.2 / 9.8**, mean rising 37 → 48, p99 **#2B523A** | Almost invisible: std **1.7 / 3.1**, mean 38 → 42, p99 #094534 | about 3x too faint | medium | code | Tint `0x8C1A6046` → **`0xFF2E6A4C`** (opaque, lighter). Keep the fade mask. Move the tint to a theme token |
| 12 | Locked card rim | 4 px: #134333 / #27634D / #26624D / #215C46, with a 1 px dark line outside (#001F14). **Top and bottom carry a highlight**: top #2F6954, **bottom #559174 → #458165**, then a dark contact line #00160C | 3 px: #154A38 / #27654F / #225F4A. Top and bottom are the same as the sides, bottom peak #27654F | bottom highlight missing (ΔL ≈ +35) | medium | code | Draw the rim with a vertical gradient: #2F6954 (top) → #27654F (sides) → **#559174** (bottom), 3 → **4 px**. Add a 1 px #00160C outer contact line at the bottom |
| 13 | Inner sheen (horizontal) | Locked card: columns brighten toward the left edge (#03382A at x+8) against #012F24 in the centre, ΔL ≈ 6. Active card: #033A2A at the left edge vs #012A20 at the right | Flat across the width (#023327) | missing | low | code | Add a horizontal radial overlay at the card edges: emerald #0A4A36 at 25% alpha, 0 → 0.15 of the width |
| 14 | Active rim outer glow | **No gold glow**. Outside the rim: 1 px #0C2217, then a dark halo #02211C-#07231B over about 6 px, back to the background (#012A20) by 8 px. Top: #01251F 1 px, then the background | Gold glow (alpha 0.08-0.22 breathing, blur 2.4u). #102E1C at 1 px, still above the background at 20-25 px | warm halo of about 25 px instead of a dark 6 px halo | low | code / owner | Breath alpha 0.08-0.22 → **0.0-0.10**, plus a dark contact shadow (black 45%, blur 0.6u). The breathing glow is a motion feature: owner decides |
| 15 | Active rim colour | 4 px. Left #998439 / **#CEA03B** / #C79B34 / #958439. Top pale #E9DE87 / #F0D673 / **#FBE283**. Bottom #FADA6E | 3.4 px. Left #907C2C / #C2A545 / **#FFDA6B** / #AEA556. Top #EBAD32 / **#FFDA6B** | close; the reference sides are slightly deeper gold | low | code | Optional: inner line #FFDA6B → #E9C35A on the sides |
| 16 | Background | Top band brighter: y5 = #063127-#073429 (x250-1250), y60 = #043328. Bottom y840 = #002D23. Left edge x20 = #012B23 | y5 = #012B21-#013025, y60 = #012E23. Bottom #002A20. Left edge #00281E | top −5 L, bottom −3 L | low | code | Radial centre Alignment(0, −0.5) → **(0, −1.0)**, `contentTop` #023328 → **#07362A**. Add a faint bottom lift to #002D23 |
| 17 | Lattice corners | Left corner: straight diagonal from (209,0) to (0,≈205), p95 **#6B6D2F** (gold). Right corner: x1517-1656 (155-16 from rail), y0-136, p95 #756B2E, cover 6% | Left corner: concave arc (203 → 14 px at y180), p95 #4A5934 (grey-green). Right corner: x1535-1677 (151-9 from rail), y0-143, p95 #465C39, cover 19% | Flutter is dimmer and greener; the left shape differs | low | code + asset | Opacity 0.32 → **0.45**. Right corner `right` 1u → **1.2u**. The left shape belongs to the shared asset (owner) |
| 18 | Path nodes | Node next to the active card: Ø20, centre **22 px** from the card, core **#FDC651**. Next node: **Ø28**, core #FBBE23, 19 px from card 2. The line brightens toward the node (#A3852E → #FDC651) and stops at the node, leaving a dark gap of about 8 px before the active card | Both nodes Ø19-21, core **#DDA832 / #E4AD33**. Node 1 is **12 px** from the active card because the card's 1.016 focus scale grows into the gap. The line is flat #D2A93C and runs up to the card | −10 px gap, duller core | low | code | `nodeFromRight` 2.4u → **2.6u** + (focusScale − 1)·cardW/2. Node fill → **#FCC24A**. Line: gradient #A3852E → #F5C04C toward the node, ending at the node. The different node sizes in the reference are probably accidental: owner decides |
| 19 | Active card gold rule | Visible 87-473 px from the right edge (387 px), median #BFA64A | Visible 79-453 px (375 px), median #E8B938 | 8 px too far right, 20 px short at the left end, brighter | low | code | Right 6.5u → **7.3u**, width 51.5u → **52u**. Optional opacity 0.85 |
| 20 | Active card description colour | p97 **#D9DAC6** (greyer). The locked card description is p97 #F0E6CB | #F4EAD0 on both | inconsistent within the reference | low | owner | Keep `cream`, or add `text.bodyActive` #D9DAC6: owner decides |
| 21 | Locked card description | Right inset **50**, width 424, line pitch 42 | Right inset **56**, width 415, line pitch 44 | −6 px, +2 px | low | code | Locked cards: right 6.4u → **5.7u** (same as #8), line height 5.1u → **4.95u** |
| 22 | Lock glyph | 22x28, #EDE3CB | 20x26, #DAD7BF | −2 px | low | asset (+code) | Size 3.4u → **3.7u**. Material glyph pending (P6) |
| 23 | Active card vertical size | 430 px (scale y ≈ 1.009) | 434 px (uniform scale 1.016) | +4 px, bottom 3 px lower | low | code | Acceptable, or scale X only |
| 24 | Pill fill | #072A1C → #073121 (dark, slightly warm) | #063324 flat | ΔL ≈ +3 | low | code | `pillFill` → **#062D20** |
| 25 | Toast (locked tap) | — | Toast y760-818 sits 4 px below the cards' bottom edge (756) | nearly touching | low | code | Toast bottom 4u → **2.5u** |

## States

- **Locked tap:** the toast reads «أكمل «أساسيات التجويد» أولًا لفتح هذه الدورة». It is centred on the content, with a 2 px rim and cream text; see #25 for its position. The lock shake is not visible in the still capture.
- **Scrolled:** after dragging one card, course 2 is in the focus slot at 1005-1630 (the same slot as the active card). The pitch error (#1) is present here too, and the path nodes keep their offsets.
- **Menu open:** the side panel overlays the header and the active card. This is approved behaviour (side-nav critic) and was not reviewed here.

## Assets pending / owner decisions (not scored as code defects)

| Item | Reference | Flutter now | Note |
|---|---|---|---|
| Right rail | Reference rail from x1672 | Owner-approved side nav (style C, 6 items) from x1686 | Approved; the content is 14 px wider |
| Header arch | Wide, low onion arch: apex y≈12 at x864, flanks at y≈60 near x760 and x990, then running down to the title ends | Side-nav arch stretched, apex y≈8, much steeper. Ends at x≈450 and 1300, y≈245 | Asset P1 |
| Emblem (open book on stand) | 120x60 px, thin strokes (≈ 4-6 px), centre (864, 97) = 808 from rail | Nav Quran glyph, 124x84 px, strokes ≈ 16 px, centre (874, 98) = 812 from rail | Asset. When it is replaced, size the box so the drawn book is **60 px tall (≈ 7u)**: the current box is 15.7u |
| Mosque silhouette | Left of the title, x≈100-440, y≈105-300 | absent | Asset |
| Crescent and star | x≈1365-1455, y≈65-145 | absent | Asset |
| Course icons 2-12 | Bespoke gold icons (for example, a head with sound waves, 71x75) | Outline book 74x51 | Assets P4/P5 |
| Course 1 icon | Quran on rehal, 102x65, right inset 51 | Owner asset, 83x73, right inset 62 | Existing owner asset; aspect differs |
| Lock and star glyphs | Custom | Material `lock_rounded` and `star_rounded` | Asset P6 |
| Progress text | Bar ≈ 30% but text "0%" | 30% bar, "30%" | Reference inconsistency; owner decides |
| Lattice left-corner shape | Straight diagonal | Concave arc (shared asset) | Shared library asset |

## Token conflicts with DESIGN-SYSTEM.md

These go to the owner. They are not fixed silently.

1. **Gold rim (selected)**: the token is 1.2 px #DAA42A + 1 px #FFDA6B, glow gold 15% blur 2u. The active card uses 1.4 px `goldRim` #F2B132 + 2 px #FFDA6B with a breathing glow of 8-22%, blur 2.4u. The reference card has a 4 px rim (#CEA03B sides, #F0D673-#FBE283 top) and **no glow**. Either keep the token for cards or add `gold.rim.card`.
2. **Glass rim**: the token is 2 px #245843 (rows) / #1C4E38 (tiles). The locked card rim is 3 px `cardRim` #27654F / `cardRimDark` #144837, and the reference card rim is 4 px #27634D-#2F6954 with a #559174 bottom highlight. New token needed: `glass.rim.card`.
3. **Radius**: the tokens are tile 3.0u and row 4.1u. The card uses 3.5u in code, while the reference is ≈ 4.7u. New `radius.card` (≈ 4.7u, close to `radius.row`).
4. **Background**: the panel/rail token is #053627 → #012E20 → #00281C (vertical). The content background is a new radial `contentTop` #023328 → `contentBottom` #00271D, and the reference has a brighter top (#073429). New tokens.
5. **Text**:
   - The `label` token is #FFFDF5 at weight 340, size 4u. The title, card title and pill use weights 600/560/400 at 9.15u, 5.3u and 3.0u: new type tokens (`type.screenTitle`, `type.cardTitle`, `type.body` 3.4u/340).
   - The reference pill text is **gold**, while the only "text on gold" token is #132C1A. New `text.gold`.
   - The reference active description is #D9DAC6, while the cream token is #F4EAD0.
6. **Pill**: the token pill is flat #EDB120 with #132C1A text. This screen's level pill is outline-only: 2 px gold rim, dark fill #063324, gold text. New `pill.outline`.
7. **The proposed 03 tokens are not in DESIGN-SYSTEM.md yet**: `contentTop/Bottom`, `cardTop/Mid/Bottom`, `cardRim`, `cardRimDark`, `pathLine`, `progressTrack/Fill`, `playFill`, `lockDisc/Rim/Glyph` and `pillFill` exist only in `rateel_theme.dart` (marked "proposed").
8. **Hard-coded style values in screen code** (the rule is that screens never hard-code):
   - Star-tile tint `Color(0x8C1A6046)`
   - Rule fade `Color(0x00F2B623)`
   - `Colors.black` at 0.40 / 0.35 for the shadows, plus shadow blur and offset
   - Rim widths 1.4 / 2 / 2.6 / 1.6 px
   - Line stroke 3 px
   - Lattice and arch opacities 0.32 / 0.85

   Move them to `rateel_theme.dart`.

## Summary

The active card is very close to the reference: every content element is within ±3 px and the hex values match. The main gaps are geometric and decorative.

**Medium code items (10):**
- #1 the pitch bug (−8 px per card)
- #2 corner radius
- #3 divider half reversed and too long
- #5 title 1u low
- #7 pill text should be gold and larger
- #8 locked title position
- #9 locked rule too dim
- #10 fill gradient
- #11 bottom pattern too faint
- #12 locked rim missing its bottom highlight

**No high code items.**

**Asset items:** header arch, mosque, crescent, emblem, course icons 2-12, lock and star glyphs.
