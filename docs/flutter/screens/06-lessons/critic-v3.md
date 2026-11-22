# Screen 06 (lessons of the unit): critic v3 (on Flutter v4 captures, quick verification)

Date: 2026-11-22. Branch `flutter/06-lessons` at `23e6eae` (v4 = `c95ea1c`, critic v2 fixes).
Reviewer: separate critic sub-agent (did not write the code). No code was changed by this review.

Compared: `reference.webp` 1844×853 (u = 8.53 px) against `capture-v4-ref*.png` (look A) and `capture-v4-orig*.png`
(look B), with `capture-v3-*.png` as the baseline. Method: Python/PIL (scripts `critic3/*.py` in the session
scratchpad, `python3 -I`): same band medians / p97 / column profiles as critic v2, plus a full-frame v3 → v4
difference. Motion items A26, B7 checked in `app_flutter/lib/lessons/lesson_card.dart` (no new frames).
Not scored: the owner-approved items listed in critic v2 (unchanged).

## 1. Verification of the v2 items

| # | Item (v2 sev.) | Reference | v3 capture | v4 capture (now) | Status |
|---|---|---|---|---|---|
| A5 | Card pattern (medium) | active band median lum 37, p97 81 (#3E5F38), **contrast +44**; locked p97 **#283C22** (lum 51); cell **8.2u** | contrast +27 (p97 #2D5833); locked p97 #172F1C (lum 38); cell 9.4u | active p97 **#46703B** (lum 93), **contrast +49** (111 % of ref); locked p97 **#253D20** (lum 51 = ref); cell **9.5u** | **fixed** (residual low: cell still 16 % larger, tile scale 0.85 not applied; active contrast 5 lum above ref) |
| A6 | Mosque tint / base (medium) | band medians y110 #697A4D, y150 #6E7F47, y190 **#617A45**, y230 **#375934**, y255 **#274C2D**, y270 #174028; visible to **y 291 (34.1u)**, soft fade | flat #7C8D53 to y230, hard edge at y 270 | y110 #738636, y150 #627947, y190 **#506C40**, y230 **#21472E**, y255 #113B29 (≈ bg); visible to **y 259 (30.4u)**; row max over bg: y200 +60 (ref +90), y240 +21 (ref +50), y264 +5 (ref +31); **no hard edge** | **fixed** for the medium causes (gradient top→bottom, soft fade, no cut). Residual **low** (A6b): the gradient overshoots: lower half 14–18 lum darker than ref, base domes fade out 32 px (3.8u) too early. Fix: bottom stop ≈ #375934 at y 230 and fade reaching 0 at y ≈ 291 |
| A8 | Done-card sliver at the rail (medium) | content ends at the rail, nothing under it | rim #5B5A29 / #404925 at x 1668–1671, y 345–777 (+45 lum) | x 1668–1671: **#00231A / #012219** (= bg); column p97−median at x 1672 **4** (v3: 42); done card no longer visible | **fixed**. Residual low (A8b): the lit line fades from x 1636 (#FED866) to #586135 at x 1666, then steps to bg (#052419) at x 1668–1670, a small hard end 2u before the rail |
| A26 | Look A pill number → ✓ blank at the flash (low, motion) | — | text out 0.30–0.40, ✓ in 0.40–0.50 (sum ≤ 0.5) | code: text `1 − seg(d, 0.30, 0.45)`, ✓ `seg(d, 0.33, 0.48)`: summed opacity ≥ 0.8 at every d; both glyphs at ≈ 0.5 for ≈ 0.36–0.42 (≈ 50 ms of 800 ms) under the pop scale | **fixed** |
| B7 | Look B icon gold-on-gold during unlock (low, motion) | — | icon lit gold on the gold fill for ≈ 0.5 s, dark only at unlock = 1 | code: `onGold = _orig && _goldFill > 0.5` (same rule as the text ink), so the icon turns dark at unlock ≈ 0.70 together with the text; before that it is at most half-lit on a ≤ 50 % gold fill | **fixed** (switch is a snap, as for the ink: acceptable) |

## 2. Regression check (v3 → v4, whole screen)

Full-frame difference (threshold 3/255): look A changes only inside the mosque box (x 150–600, y 100–330), the
card pattern band (y 620–780) and the done-card zone at the rail (x 1590–1690, done1). Phone: same zones scaled,
plus +3–5 lum of pattern on the card-3 remnant at the left edge (x 112–116, y 900–950; A10 unchanged, low).
**Look B captures (all three) are pixel-identical to v3.** No regression found.

## 3. New items

| # | Element | Reference | Flutter v4 | Sev. | Type | Fix |
|---|---|---|---|---|---|---|
| A6b | Mosque base | see A6 | lower half too dark, visible to y 259 | low | code | see A6 |
| A8b | Lit line end at the rail (done1) | — | step #586135 → bg at x 1668 | low | code | let the line fade reach 0 at x 1668, or clip it with the card |

All other v2 items (A2 high asset, A3 asset, A4b, A4c, A10, A11, A14, A16, A18, A23, A25 low; owner questions Q1
A21, Q4 A22, A17; token conflicts critic-v2 §3) are unchanged.

## 4. Scores

| Area (look A) | v1 | v2 | v3 | Main reasons |
|---|---|---|---|---|
| Layout | 8.0 | 8.6 | **8.8** | done-card sliver gone (A8), mosque base no longer cut; mosque fades 3.8u early (A6b) |
| Colours | 7.0 | 7.8 | **8.3** | pattern contrast and locked pattern match (A5), mosque gradient; mosque lower half too dark (A6b), A4b |
| Typography | 8.0 | 8.5 | **8.5** | unchanged (A18) |
| Assets | 4.0 | 4.0 | **4.0** | lesson icons placeholders (A2 high, A3), corner from 05 (A23) |
| Motion | 7.5 | 7.8 | **8.0** | blank pill fixed (A26) |
| **Overall look A** | **6.8** | **7.3** | **7.5** | **8.4 for code alone** |

**Look B overall: 6.6** (was 6.5; B7 fixed, family-consistency remark of v1 stands).

### Remaining high / medium code items
None, for look A and look B. Remaining: asset items (A2 high, A3, B5: lesson icons L1–L5), owner questions
(Q1, Q4, A17, token conflicts), low code items (A4b, A4c, A5 cell size, A6b, A8b, A10, A11, A14, A16, A18).
