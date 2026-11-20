# Critic v2: side navigation

Fidelity score: 8.5/10 (open menu), 9/10 (closed rail)

**How the numbers were measured**
- Script: `scratchpad/critic/measure.py`, run as `python3 -I measure.py . v2` (reference folder, Flutter folder). Anchor overrides for this round are in `OVERRIDES['v2']`.
- Spot checks (arch, caps, pattern, ring profiles, menu button) were made with direct pixel probes.
- Frame: 1844x853. The reference rail is scaled by 853/941 and right-aligned. u = 1% of screen height = 8.53 px.
- Radius: the measured value is where the rim straightens within 1 px; the value in brackets is corrected for that tolerance.
- "Ink density" is filled px / bbox area, used as a stroke-weight proxy.

**What already matches (within ±3 px or the same hex)**
- **Panel:** panel width 667 vs 669, edge band 4 px #265C42 vs #295F45.
- **Close button:** Ø70 vs 70, rim 3 px #F2B132 on both.
- **Rows:**
  - Row extents x1245-1793 vs 1244-1794, row h 89 vs 88, pitch 95.
  - Selected row 1241-1792 x 138-239 vs 1240-1793 x 138-236. Selected fill #3B4C1F.
  - Pills 67x43 flat #EDB120, inset 41 vs 42, text #132C1A, no shadow. Dividers x1380, 2 px, #2C5845.
  - Labels: right edge 1639 vs 1643, height 33 vs 34, #FFFDF5.
  - Menu icons: 31-44 x 45-48 px at centre x 1723 vs 1725.
- **Rail:**
  - Rail width 156 vs 158.
  - Active disc 74 vs 73, flat #E2A51E. Ring Ø105 vs 103. Gap 14 px.
  - Tiles 104x94 vs 105x94, rim 2 px #1C4E38 vs #1B4C37.
  - Bubbles 55x39 #E2A51E at (-7,+1) vs (-7,+1), 114-bubble 64x39 vs 64x40.
  - Hamburger 35 px wide #EFEACF.

## Differences

| # | Region | Reference | Flutter v2 | Severity | Type | Fix suggestion |
|---|---|---|---|---|---|---|
| 1 | Morph: left filigree cap | — | In s2 the left cap floats **outside the panel** (x≈832-868 in the 1280 frame, panel edge 880, selected row left 920), over the content. It snaps to the row only near the end (s3) | high | code | Position the caps relative to the morphing selected-row rect (`rect.left - capW + overlap`), not the final `rowRect`. Or fade them in only when the row is at its final position (t > 0.85). Same class of bug as the v1 dividers |
| 2 | Thin gold arch (brightness) | Apex stroke ≈ 6 px (y28-34 at x1515), **#FAD371**. Flanks 3-4 px **#BB982A** (x1400 y82-85). Gold bbox x1375-1646 y28-92 | Apex ≈ 4 px **#A88A49**, flanks 2 px **#A38645**. Gold bbox x1344-1687 y31-112, so wider and 20 px lower | medium | code | Draw the PNG at full opacity, with no dimming tint (target apex ≈ #FAD371). Scale to ≈ 272 px span at the gold-bright part, top at y≈28 (u*3.3). If the PNG is inherently thin or dull, ask for a brighter export (asset) |
| 3 | Filigree end caps | Left x1203-1244, right x1790-1827: **42x74 px**. Solid gold, median **#CE9E2B**, max #FFC83E | Left x1197-1244, right x1790-1836: **48x94 px** (+27% tall). Median **#A3833C**, max #E2C560 (thin and dull) | medium | code (+asset) | Size 42x74 (u*4.9 x u*8.7), vertically centred on the row (y150-223). Opacity 1.0. If the SVG is outline-only, ask for the filled version (asset) |
| 4 | Bottom pattern strip | Band ≈ **93 px** (y760-853) with a soft vertical fade. Mean luminance 25 → 34; contrast std **6.3**; p99 colour **#294D2F** (barely visible) | Band ≈ **48 px** (y805-853), hard top. Mean luminance 23 → 43; contrast std **24.6**; p99 **#68805C** (3-4x too strong) | medium | code (+asset motif) | Height u*11 (93 px). Opacity ≈ 0.25-0.3. Add a top-to-bottom fade mask (0 → 1). The motif shape differs slightly (lattice vs overlapping stars): low, asset |
| 5 | Selected row rim colour | Top rim: #686E32 (outer AA), **#FFDB6B** 1 px, #C0A34D, then fill. Reads as a **bright light-gold 2 px line**. Ends (left) 4 px #DAA42A | Top rim: #3D5326, **#DAA42A** 2 px, #C0A849, #7C7C38, then fill (4 px, darker) | medium | code | Use a gradient or 2-stroke border: outer 1 px #DAA42A, then 1 px #FFDA6B highlight on top and bottom. Total 2-2.5 px, not 4 |
| 6 | Active ring and glow | Gap brightens **toward** the ring: #455525 → #5A6528 → #73772C. Ring (bottom) **#C8C059**. Outer glow 3 px #2D4B22, gone after ≈ 20-35 px | Gap darkens **away from** the disc: #4C5B23 → #2C4823. Ring **#8C7A2B** (≈ 35% dimmer). Outer glow 3 px **#153B23**, gone after ≈ 12 px | medium | code | Put the glow on the ring, not the disc. The ring BoxShadow gold @ 0.30, blur u*2.4, plus an inner glow (gold @ 0.15 radial, ring → disc). Ring colour #D8C35A at 1.5-2 px. Reduce the disc's own shadow |
| 7 | Unselected row radius | Measured 23-24 (**r ≈ 31**) | Measured 20 (**r ≈ 27**) | low | code | Radius u*3.6 (31 px). Check the value actually applied |
| 8 | Unselected row fill | #012D1F = panel bg #012B1D (no fill) | #043124 / #042E22 on #012D20 (+3 L) | low | code | Fill alpha → 0 |
| 9 | Selected row fill shading | Slight inner glow: top #3A4B20, middle #30461F, bottom #394B1E | Flat #3B4C1F | low | code | Optional: inner shadow gold @ 0.08, blur u*1.5 |
| 10 | Labels: weight | Ink density 0.19-0.22 | 0.24-0.27 (about 20% heavier) | low | code | Weight 400. If it is already 400, the face differs. Try a lighter Arabic face for labels only after owner OK |
| 11 | Menu icon القرآن size | 61x37 px | 53x36 px | low | code | Book icon width u*7.1 (61 px) |
| 12 | Close X stroke | 27x26, stroke ≈ 4.8 px | 28x28, stroke ≈ 4.2 px | low | code | Stroke u*0.56 |
| 13 | Menu button tile | y26-86 (61 px tall), ≈ 72 wide. Fill #043726 = bg #063826. Rim 1-2 px #144833 | y29-83 (55 px tall), ≈ 70 wide. Fill #0B3A2B on bg #053526 (+5 L). Rim #134531 / #184C35 | low | code | 72x61 (u*8.4 x u*7.2). Fill alpha → 0.01 |
| 14 | Hamburger bars | 5 px thick | 4 px thick | low | code | Stroke u*0.59 |
| 15 | Rail tile radius | Measured 15-16 (**r ≈ 22**) | Measured 12-13 (**r ≈ 19**) | low | code | Radius u*2.6 (22 px). Check the value actually applied |
| 16 | Rail tile fill | #012F1F on #002E20 (none) | #053325 / #043023 on #012E20 (+3 L) | low | code | Fill alpha → 0 |
| 17 | Morph: hamburger→X midpoint | — | s1 shows 3 converging bars ("<" shape). This is the intended rotation and reads acceptably | low | code | Optional: fade the middle bar out faster (by t=0.3) |
| 18 | Content dimming | No scrim; content stays at its normal brightness | Scrim alpha 0.12 (content darkens ≈ 12%) | — | owner conflict | Kept by owner decision. Not a defect |
| 19 | Rail/menu icon glyphs | Reference: closed book in the rail, outline open book in the menu, etc. | Owner SVG set (open book in both states) | — | owner decision | Not flagged. Sizes, positions and colours match (rail icons 30-52 x 35-47, offset +8,+6 vs +7…9,+2…7; colour #F4EAD0 vs #F6EACC) |

## Animation notes (s1-s3)

- **Fixed since v1:**
  - Dividers now travel inside their rows (no leak).
  - Pills stay vertically centred in the rows during the morph.
  - Icons no longer double-expose (the same SVG is used in both states).
  - The arch and the bottom pattern travel with the panel.
- **New bug:** the left filigree cap is detached from the selected row mid-morph (#1). It floats over the content about 50 px left of the panel edge in s2.
- s1: the tiles widen inside the moving panel with no overhang. The active disc shrinks into the selected-row icon circle cleanly.
- The scrim fades in progressively. This is accepted by the owner (#18).

## Design tokens

These are final measured reference values, proposed as shared tokens (u = 1% of screen height).

| Token | Value |
|---|---|
| `panel.bg` | top #013525 (left) / #012D1F (right) → bottom #012A1E |
| `rail.bg` | #073928 → #002E20 → #00281C |
| `edge.highlight` | 4 px band, peak #295F45 (on #002E20) |
| `glass.fill` | transparent (alpha 0); the capsules and tiles are outline-only |
| `glass.rim` | 2 px, #235641 (rows) / #1B4C37 (tiles) ≈ one token #1F5240 |
| `gold.rim` | #DAA42A (selected-row ends, 4 px at the caps) |
| `gold.highlight` | #FFDA6B (1 px top/bottom highlight on the selected row) |
| `gold.ring` | #F2B132, 3 px (close button); #ECBE3B, 2 px (selected icon circle); #C8C059, 1.5-2 px (rail active ring) |
| `gold.fill` | #E2A51E (active disc, rail bubbles); pill #EDB120 (flat, no gradient) |
| `gold.tint.selected` | #3B4C1F (selected row fill = gold ≈ 25% over the panel) |
| `ring.gap` | #415423 → #73772C (inner glow brightening toward the ring) |
| `text.label` | #FFFFFF / #FFFDF5; weight regular (ink density ≈ 0.21) |
| `text.onGold` | #132C1A (pill and bubble digits); glyph on gold disc #06291C |
| `icon.cream` | #FCF1D0 (menu), #F6EACC (rail) |
| `divider` | 2 px x 36 px, #2C5845 |
| `radius.row` | ≈ 31 px = u*3.6 |
| `radius.tile` | ≈ 22 px = u*2.6 |
| `radius.menuButton` | ≈ 20 px = u*2.4 |
| `radius.pill` / `radius.bubble` | h/2 |
| `size.row` | h 88 = u*10.3; selected 99 = u*11.6; pitch 95 = u*11.1; width 550 |
| `size.tile` | 105x94 = u*12.3 x u*11.0 |
| `size.closeButton` | Ø70 = u*8.2; X 27 px, stroke 4.8 = u*0.56 |
| `size.selectedIconCircle` | Ø76 = u*8.9; glyph 54 = u*6.3 |
| `size.activeDisc` / `size.activeRing` | 73 = u*8.5 / 105 = u*12.3 |
| `size.pill` | 67x43 = u*7.9 x u*5.0 (3 digits: 73 = u*8.6) |
| `size.bubble` | 55x39 = u*6.4 x u*4.6 (3 digits: 64 = u*7.5); offset from tile top-left (-7, +1) |
| `size.rail` / `size.panel` | 158 = u*18.5 / 669 = u*78.4 |
| `size.icon` | menu ≈ 47 px tall = u*5.5; rail ≈ 44 px = u*5.2 |
| `size.hamburger` | 35x31, bars 5 px = u*0.59 |
| `type.label` | glyph bbox 34 px ≈ font u*4.0 |
| `type.count` | digit height 17 px ≈ font u*2.5, bold |
| `glow.selectedRow` | gold @ ≈ 0.15, blur ≈ u*2 (17 px). Peak #1C3E1E at 4 px, gone by 16-20 px |
| `glow.activeRing` | gold @ ≈ 0.25-0.30, blur ≈ u*2.4. #2D4B22 at 3 px, gone by 20-35 px |
| `shadow.pill` / `shadow.bubble` | none |

## Summary

Every v1 code item landed with the requested numbers. The open menu and the rail now match the reference within a few px on geometry and to the hex on the main fills (selected fill, pills, bubbles, disc, rims).

What remains:
- **One high bug:** the left filigree cap floats outside the panel during the morph.
- **Four medium polish items on the new assets:** the arch is about 40% too dim, the caps are 27% too tall and dull, and the bottom pattern is 3-4x too contrasty and half as tall. The selected-row rim also lacks its bright #FFDA6B highlight.
- **One medium item on the active ring:** the glow runs the wrong way and the ring is about 35% too dim.
- Everything else is low.

The scrim and the icon set are owner decisions and are not counted.
