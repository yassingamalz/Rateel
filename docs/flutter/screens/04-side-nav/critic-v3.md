# Critic v3: side navigation

Fidelity score: 9/10 (open menu), 9.5/10 (closed rail)

## Method

- Numbers come from `scratchpad/critic/measure.py`, run as `python3 -I measure.py . v3` (anchors in `OVERRIDES['v3']`; raw output in `out-v3.txt`), plus direct pixel probes for the arch, caps, star band, selected rim, active ring and menu button.
- Frame is 1844x853. The reference rail is scaled by 853/941 and right-aligned. u = 8.53 px.

## Already matching (within ±3 px or the same hex)

**Panel and close button**
- Panel 667 vs 669 px; edge band 4 px #265C42 vs #295F45.
- Close button Ø70, rim 3 px #F2B132, X 28 px with stroke 4.3 px (ref 4.8).

**Rows**
- Unselected rows x1245-1793, h 89 vs 88, pitch 95, radius about 31 on both (measured 23).
- Rim 2 px #245843 vs #235641. Fill equals the panel background on both (#012D20 vs #012D1F).
- Selected row 1242-1792 x 140-238 vs 1240-1793 x 138-236. Fill #3B4C1F. Selected icon circle 75 px at (1723,189) vs 76 px at (1723,187); glyph 54x54 on both.

**Labels and pills**
- Labels end at x1639 vs 1643, colour #FFFDF5, ink density 0.20-0.24 vs 0.19-0.22 (weight now matches).
- Pills 67x43, flat #EDB120, inset 41 vs 42 px. Dividers at x1380.

**Rail**
- Rail width 156 vs 158.
- Menu button 73x64 vs 70x58, hamburger 33 px wide with 5-6 px bars (ref 5).
- Active disc 74 px #E2A51E vs 73 px. Ring Ø105 vs 103, colour #D8C35A vs #C8C059.
- Tiles 104x92-93 vs 105x94, radius about 20-22 vs 22, rim 2 px #1C4E38, no fill.
- Bubbles 55x39 #E2A51E at offset (-7,+1).

## Differences

| # | Region | Reference | Flutter v3 | Severity | Type | Fix suggestion |
|---|---|---|---|---|---|---|
| 1 | Morph: icon/row mapping | — | **s3: the icons are shifted down by one row.** The selected row الدروس shows the open-book icon inside its gold circle. القرآن shows the mic, التدريب the trophy, المتصدرين the medal, الإنجازات the certificate, and الشهادات has no icon. s2 and the final frames are correct, so this is a transient during the last part of the morph (or the capture caught a selection change). | high | code | Check the icon list index during t≈0.85-1.0. Also check the new cap/selected-row code path, which may have changed the order of the children or of `navItems` in `_icon`. If s3 was taken while the selection was changing to القرآن, re-capture a clean open morph and confirm |
| 2 | Arch colour and fade | Apex at y28-34 (≈6 px), pale gold **#FAD371** (from #F0CB6A). Flanks at x1400 y82-85 (4 px) **#BB982A**. Gold part ends at y≈92 and the flanks fade out (no gold pixels at y110). Gold bbox x1375-1646 y28-92 | Apex at y36-41 (≈6 px), deeper orange-gold **#D09B0B** to #D8A517. Flanks at x1400 y89-95 (**7 px**) **#B38201**. Stays fully bright to the ends (gold at y110, x1344 and x1677). Gold bbox x1329-1693 y29-122 | medium | asset (+ optional code) | Asset: ask for a paler gold (#F6D06A apex), thinner flanks (4 px) and ends that fade out. Code: a vertical ShaderMask fading the lower 30% of the arch to about 35% opacity, and moving it up by 7 px, get most of the way |
| 3 | Bottom star band | Visible pattern on a background that brightens toward the bottom. Mean luminance rises from 25 to 34 over y720-852; contrast std 5.8; p99 **#294D2F** | Almost invisible. Mean luminance is flat at 23-24, contrast std **3.5**, p99 **#1A3926** (30% opacity, no bottom glow) | medium | code | Opacity 0.30 → ≈0.5. Add a bottom-up emerald glow under the band (#0E4630 at 0 → 0.5 alpha over u*11 ≈ 93 px) so the panel bottom reaches luminance ≈ 34 |
| 4 | Filigree caps (size) | Left x1203-1244, right x1790-1827: **42x74**. Gold median #CE9E2B | Left x1196-1244, right x1790-1839: **49x80**; the right cap reaches 12 px further out. Median #CCA431 (colour now matches) | low | code | Scale the caps to 42x74 (u*4.9 x u*8.7) and anchor the right cap's inner edge at the row's right rim |
| 5 | Selected row bottom rim | Bottom rim, inside to outside: #A68D3E, **#FFD069** (highlight), #857A38. Mirrors the top rim | Bottom rim: #827F3A, **#CBB150**, #B79128. The highlight is about 20% dimmer and the stroke order is reversed | low | code | Apply the 1 px #FFDA6B highlight symmetrically: inner on top, and also as the brightest line on the bottom |
| 6 | Selected row outer glow | 3 px **#1C3E1E**; still above background at 6 px (#163920). Warm olive | 3 px **#133C24**; 6 px #0C3824. Weaker and greener | low | code | Glow gold 0.15 → 0.22 |
| 7 | Active ring gap | Brightens toward the ring: #455525 → #5A6528 → #73772C | Flat **#5F6523** across the 14 px gap | low | code | Use a radial gradient with stops at the disc edge (alpha 0.05) and the ring (alpha 0.25), not a uniform fill |
| 8 | Active outer glow | 3 px **#2D4B22**, fades over about 35 px | 3 px **#1D4023**, fades over about 29 px | low | code | Glow opacity 0.28 → 0.38 |
| 9 | Menu button fill | Equals the background (#043725 on #053826) | #0A3A2B on #043526 (+5 L) | low | code | Fill alpha → 0 |
| 10 | Content dimming | No scrim | Scrim at alpha 0.12 | — | owner conflict | Owner decision, not a defect |
| 11 | Icon set | Reference glyphs | Owner SVG set; size, position and colour match | — | owner decision | — |

## Animation notes (s1-s3)

- **s1:** clean. The tiles widen inside the moving panel, the disc shrinks toward the row circle, and the hamburger→X bars rotate.
- **s2:** clean. There are no caps (t < 0.85), as intended, and nothing renders outside the panel. Pills are centred and dividers stay inside their rows. The arch and band travel with the panel.
- **s3:** the caps are attached to the selected-row ends (the v2 bug is fixed). However, **the icons are shifted by one row** (#1).

## Design tokens

These are unchanged from v2 except where noted. The reference values remain the target. The v3 Flutter values now meet every token within ±3 px or the same hex, except where this table says otherwise.

| Token | Value |
|---|---|
| `panel.bg` | #013525 / #012D1F → #012A1E; bottom glow to luminance ≈ 34 (#0E4630 @ 0.5, u*11) — **new** |
| `rail.bg` | #073928 → #002E20 → #00281C |
| `edge.highlight` | 4 px band, peak #295F45 |
| `glass.fill` | transparent |
| `glass.rim` | 2 px #1F5240 (rows #235641, tiles #1B4C37) |
| `gold.rim` / `gold.highlight` | #DAA42A 1-1.2 px outer + #FFDA6B 1 px highlight (top **and** bottom) |
| `gold.ring` | close #F2B132 3 px; selected icon circle #ECBE3B 2 px; active ring #C8C059-#D8C35A 1.7 px |
| `gold.fill` | #E2A51E (disc, bubbles); pill #EDB120 flat |
| `gold.tint.selected` | #3B4C1F |
| `ring.gap` | radial #455525 (disc edge) → #73772C (ring) |
| `text.label` | #FFFDF5, weight ≈ 340-400 (ink density ≈ 0.21) |
| `text.onGold` | #132C1A; glyph on disc #06291C |
| `icon.cream` | #FCF1D0 menu / #F4EAD0-#F6EACC rail |
| `divider` | 2 px x 36 px #2C5845 |
| `radius.row` / `radius.tile` / `radius.menuButton` | ≈ 31 px (u*3.6, which renders like the applied u*4.1) / ≈ 22 px (u*2.6-3.0) / ≈ 20 px (u*2.4) |
| `size.row` | h 88 (u*10.3), selected 99 (u*11.6), pitch 95 (u*11.1) |
| `size.tile` | 105x94 (u*12.3 x u*11.0) |
| `size.closeButton` | Ø70 (u*8.2), X stroke 4.8 (u*0.56) |
| `size.selectedIconCircle` | Ø76 (u*8.9), glyph 54 (u*6.3) |
| `size.activeDisc` / `size.activeRing` | 73 (u*8.5) / 103-105 (u*12.2) |
| `size.pill` | 67x43 (u*7.9 x u*5.0); 3 digits 73 |
| `size.bubble` | 55x39 (u*6.4 x u*4.6); 3 digits 64; offset (-7,+1) |
| `size.cap` | 42x74 (u*4.9 x u*8.7) — **new** |
| `size.arch` | gold span ≈ 272x64 px, apex y28 (u*3.3), flanks ≤ 4 px fading out — **new** |
| `type.label` / `type.count` | ≈ u*4.0 / ≈ u*2.5 bold |
| `glow.selectedRow` | gold ≈ 0.22, blur ≈ u*2 (#1C3E1E at 3 px) |
| `glow.activeRing` | gold ≈ 0.38, blur u*2.4 (#2D4B22 at 3 px, gone by ≈ 35 px) |
| `starBand` | opacity ≈ 0.5, height u*11, over the bottom glow — **new** |
| `shadow.pill` / `shadow.bubble` | none |

## Summary

The static screens are now very close: every geometry, fill and type value is within ±3 px or the same hex, and the rail is essentially done.

What is left:
- **One high code item:** a transient icon/row index shift at the end of the morph (s3). It needs a fix, or a clean re-capture if the frame caught a selection change.
- **One medium code item:** the star band is too faint (std 3.5 vs 5.8, no bottom glow).
- **One medium asset item:** the new arch is deeper orange (#D09B0B vs #FAD371), its flanks are 7 px instead of 4, and its ends do not fade.
- **Low items:** cap size (49x80 vs 42x74), bottom rim highlight, glow strengths, ring-gap gradient and the menu-button fill.
