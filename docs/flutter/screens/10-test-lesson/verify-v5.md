# Screen 10 v5: element-by-element verification (2026-11-25)

Reference `reference.webp` / `reference-answer.webp` (1842×854) vs capture `capture-v5-q` / `-sel` at the same size
(web build, question 5 «حدد الآية التي تحتوي على إخفاء:», the same question as the reference; its options come from
the data, so their texts differ). Boxes from colour masks (`/tmp` script modelled on `reading-verify.py`), in px at 854
high (u = 8.54 px). Target: ±4 px. Pixels sampled as medians.

| Element | Reference (x, y) | Flutter v5 | Δ / note |
|---|---|---|---|
| Arch (gold line, upper part) | y at x 700/800/1000/1100/1150: 47, 40, 36, 44, 48 | 48, 39, 36, 43, 49 | ≤ 1 px. Lower right lobe: x 1250 y 92 vs 81, x 1280 y 105 vs 98 (asset shape, see below) |
| Title (gold) | 600–1239 × 55–118 | 609–1239 × 55–119 | ≤ 1 px (left edge: arch pixels in the mask) |
| Subtitle | 627–1214 × 133–164 | 622–1218 × 133–168 | ≤ 5 px (descenders); median colour #C3DBC2 (ref) vs #C8DDC6 |
| Header divider | 738–1103 × 176–199 | 746–1095 × 174–199 | 8 px shorter visible ends (shared `GoldDivider` taper) |
| Crescent (+ arch end in the box) / star | 1285–1327 × 38–111 / 1332–1361 × 51–78 | 1285–1327 × 39–111 / 1333–1360 × 51–78 | ≤ 1 px; star at 55% and crescent gold as the app (08) |
| Moon button | glyph 81–115 × 168–205 | 80–114 × 170–205 | ≤ 2 px |
| Question circles (circle 10 with its rim) | 453–514 × 211–270 | 451–512 × 210–271 | ≤ 2 px; step 11.42u |
| Card rim | 42–1800 × 295–810 | 43–1798 × 297–807 | ≤ 3 px |
| Card fill (x 1000, y 330/400/520/620) | #002F23 #012A20 #02271F #00251E | #023126 #012D22 #002920 #00281F | ≤ 3 levels (own darker fill, conflict T3) |
| Badge | 1679–1789 × 300–399 | 1681–1789 × 300–396 | ≤ 3 px |
| Question text | 1140–1653 × 336–380 | 1139–1650 × 336–383 | ≤ 3 px |
| «+10 نقطة» pill | 80–314 × 325–391 | 80–313 × 335–390 (the pale top rim is outside the mask) | ≤ 1 px on x and bottom; star on the right as the reference |
| Option row 1 | 84–1757 from y 423, fill #0C3A29, rim top #70A685 | 84–1757 from y 423, #0B3A2A, #6FA584 | ≤ 1 level; height 9.5u by design |
| Radio | 1682–1735, ring #BBD7BD | 1681–1733, #BBD7BD | ≤ 2 px |
| Option text | 1443–1642 × 441–480 | 1443–1639 × 441–481 | ≤ 3 px (after the 0.9u lift) |
| Selected row (10b) | rim rows 527–529 / 610–612, fill #1E4B2B → #1A4829, dot #FDCF2E | 529–530 / 607–609, #204D2C → #1A4728, #FED74F | ≤ 3 px |
| «تأكيد الإجابة» | 733–1107 × 692–782, text 805–1040 × 713–756 | 734–1107 × 705–780 (pale top rim outside the mask), text 807–1034 × 715–757 | ≤ 6 px (text width: font) |
| Diamond lines | 521–694 and 1154–1329, y 724–748 | 524–683 and 1157–1317, y 724–747 | ≤ 12 px at the faded outer ends |
| Lattice band | from y 655, faint | from y 655, faint (20%) | visual check on zoomed crops |
| Capsule, pause | 02 bar | **shared 02 bar** (approved standard, not the reference's) | deliberate |

Not in the reference, built from the owner's choices: feedback bar A (mockups `feedback-mockups/feedback-a-*.jpg`,
polished references `reference-feedback-{correct,wrong}.webp` used as inspiration only, owner), end popup
(`reference-completion-{pass,fail}.webp`, inspiration only), results and details (Angular content, same style).

Remaining differences:
- Arch: the reference's lower right lobe runs ≈ 1u lower and ≈ 4u further right than the R4 asset (asset shape); a
  new arch asset would be needed for an exact match.
- Header divider and the diamond lines: the shared `GoldDivider` tapers its ends (08 style), the reference's lines
  end square.
- Moon button: the shared compact round button (08), the reference's ring is a little heavier.
- Capsule and pause button: the approved 02 bar.
