# Critic v1: side navigation

Fidelity score: 6/10 (open menu), 7/10 (closed rail)

Measured on 1844x853 screenshots. The reference rail (ref-05-rail.png, 1672x941) is scaled by 853/941 = 0.906, so the rail values below are normalised to the 853 px height. `u` = 1% of the screen height = 8.53 px. Pixel values come from colour-transition scans and are accurate to about ±2 px.

## Differences

| # | Region | Reference | Flutter | Severity (high/medium/low) | Type (code/asset) | Fix suggestion |
|---|---|---|---|---|---|---|
| 1 | Open menu: row icons (style) | Line-art / outline glyphs: open book drawn as an outline, trophy with a star emblem, medal with a star, certificate = document **with a gold ribbon seal** | Solid FontAwesome glyphs: filled `bookOpen`, plain `trophy` with no star, plain `fileLines` with no seal | high | code (+ asset for a custom certificate glyph) | Use outline glyphs (FA regular, or Phosphor/Lucide line). Trophy should have a star. Certificate needs a document plus ribbon seal (custom SVG). The ribbon seal is gold, not cream |
| 2 | Open menu: row icon size | about 57 px wide (book), mic about 30x50, trophy about 50 | about 36-37 px wide (u*4.2), mic about 26x40 | high | code | Icon size in menu about u*5.6 (≈48 px glyph box), book about 57 px wide |
| 3 | Open menu: count pill horizontal position | Pill left edge 40 px inside the row's left rim (row 1244, pill 1284) | Pill left edge only 12 px inside the rim (row 1264, pill 1276), so it nearly touches the rim | high | code | Move `pillX` about 25 px to the right (≈ +u*3), or derive it from rowRect.left + u*4.6 |
| 4 | Open menu: selected row fill | Flat warm olive-gold tint, ≈ rgb(52,73,32) top and bottom | Green vertical gradient rgb(46,81,53) to rgb(24,60,41), reads green rather than gold | high | code | Use a uniform gold tint ≈ gold @ 22-25% over the panel (no fade to 4%) |
| 5 | Open menu: selected row size | Taller than the others: 97 px (y 139-235), about 4 px wider on the left (1240 vs 1244) | Same 83 px as every other row | medium | code | Selected row height ≈ u*11.3 (96 px) and inflate the rect by about 4 px horizontally |
| 6 | Open menu: selected rim | About 3 px bright gold rim (218,164,42 / 255,211,110 highlight), tight glow that fades within about 8 px | 2 px rim; glow spreads about 20 px and tints the gap above the row (40,76,44 at 2 px vs ref 19,54,24) | medium | code | Border width 3. Glow blur ≈ u*1.2, alpha ≈0.35. Optionally add an inner 1 px light-gold highlight |
| 7 | Open menu: selected icon circle | Diameter ≈ 76 px, centre x≈1724, double gold ring with glow | Diameter ≈ 64 px (u*7.6), centre x≈1736 | medium | code | Ring size about u*8.9 (76 px). Move centre about 12 px left (rowIconCenter w - u*14) |
| 8 | Open menu: row radius | Corner radius ≈ 32 px on an 87 px row (sides straight from y+32 to y+56): rounded rectangle, not a stadium | Radius = height/2 ≈ 42 px: a full stadium capsule | medium | code | Use radius ≈ u*3.8 (32 px) in the open state instead of `rect.height / 2` (row, selected row and their lerp) |
| 9 | Open menu: row height | Unselected about 87 px | about 83-84 px (u*9.8) | low | code | Half-height u*5.1 instead of u*4.9. Keep the 95 px pitch (already matches) |
| 10 | Open menu: row horizontal extent | Rows x 1244-1795 (551 px wide), 69 px gap from panel edge, 49 px right margin | Rows x 1264-1799 (535 px), 86 px from panel edge, 45 px right margin | medium | code | `rowRectAt.left = w - panelWidth + u*8.1`, `right = w - u*5.7` |
| 11 | Open menu: unselected row fill | Essentially transparent: interior rgb(1,49,35) ≈ panel bg, the capsule reads as an outline only | Visible white glass fill (5.5% to 1.5%) → rgb(17,64,50), lighter than the bg (≈8,57,43) | medium | code | Drop the white fill to ≈ 1.5-2% flat, or use a very slight dark tint |
| 12 | Open menu: unselected row rim | About 2-3 px, rgb(35,89,64), clearly visible | About 1 px, similar colour | low | code | Rim width 1.5-2 px |
| 13 | Open menu: labels (size and colour) | "الدروس" is 118 px wide; pure white (255,255,255) | 105 px wide (u*3.6 ≈ 31 px font), cream (244,234,208) | medium | code | Font size about u*4.0 (34 px). Colour near-white (#FFFDF5) |
| 14 | Open menu: label position | Label right edge x≈1645, about 41 px gap to the icon circle | Label right edge x≈1676, 28 px gap | medium | code | `labelRight = w - u*23.1` (about 31 px further left) |
| 15 | Open menu: label weight | Medium, slightly lighter strokes | Readex 500 renders slightly heavier and rounder; acceptable | low | code | Keep 500, or try 400-500 after the size bump. Check that the face matches the reference's Kufi style |
| 16 | Open menu: count pill size and colour | 67-73 px wide (wider for 114) x ≈30 px; saturated amber (255,193,38) to (234,174,32) | Fixed 62x32 for every count; lighter lemon (248,198,61) gradient | medium | code | Width depends on the digit count (≈ u*7.9 for 1-2 digits, u*8.6 for 3). Deepen goldLight toward #FFC126 |
| 17 | Open menu: divider | At x≈1379, 23 px from the pill, about 36 px tall, soft gold-grey | At x≈1364, 25 px from the pill, cream @ 25% effective | low | code | Follows #3 and #10. Tint toward gold (gold @ 35%) |
| 18 | Open menu: close button size | Circle ≈ 70 px, centre (1257,57) | ≈ 63 px (u*7.4), centre (1253,54) | medium | code | Size u*8.2 and centre y u*6.7 |
| 19 | Open menu: close button X | Bold white X, 26x26 px, stroke ≈ 6 px, rounded caps | Thin cream X, 20x20 px, stroke ≈ 3 px (AnimatedIcons.menu_close) | high | code | Custom-painted X (stroke ≈ u*0.7, round caps, white), cross-faded or rotated from the hamburger instead of the stock AnimatedIcon |
| 20 | Open menu: close button rim | Bright gold ring ≈ 2.5 px (242,181,52) | Dim 1.6 px ring at 85% alpha (172,146,40) | medium | code | Ring width 2.5, full-opacity gold |
| 21 | Open menu: panel edge | 3-4 px bevel: dark line then a lighter emerald highlight (24,70,51) | 1.2 px line; a dark shadow is cast onto the content instead | low | code | Add a 3 px light-emerald inner highlight line on the left edge |
| 22 | Open menu: panel background | Deep emerald, almost flat: (1,52,36) top to (0,44,31) bottom | Lighter and more teal at the top (10,62,47), to (5,46,34) | low | code | `panelTop` ≈ #03382A, `panelBottom` ≈ #012C1F |
| 23 | Open menu: content scrim | The content area stays at full brightness, with no dimming | The content is dimmed by the shadow/scrim (bg 2,21,16; the title turns grey) | medium | code | Remove or greatly reduce the scrim. If you keep one for focus, use alpha ≤ 0.15 |
| 24 | Open menu: icon colour | Near-white cream (255,255,219) | Cream (244,234,208), slightly duller | low | code | Match the label colour (#FFFDF0) |
| 25 | Open menu: thin gold arch above the rows | Present (y≈30-130) | Missing | medium | asset | Add the asset |
| 26 | Open menu: filigree end caps on the selected row | Present on both ends | Missing | medium | asset | Add the asset |
| 27 | Open menu: geometric pattern strip at the bottom of the panel | Present (y≈760-853) | Missing; the lower 150 px of the panel is empty | medium | asset | Add the asset |
| 28 | Closed rail: tile fill | Nearly transparent, interior (1,48,38) ≈ bg (1,45,31) | Lighter glass (16,64,50) vs bg (8,55,41) | medium | code | Same as #11 (shared decoration) |
| 29 | Closed rail: tile rim | About 2 px, crisp | 1 px | low | code | Width 1.5-2 |
| 30 | Closed rail: tile radius | ≈ 22-24 px (scaled) | ≈ 20 px (u*2.4) | low | code | u*2.7 |
| 31 | Closed rail: tile pitch | ≈ 121 px (scaled; 5 items) | 111 px (6 items) | low | code | An accepted consequence of the 6th item. Fine as long as the tiles stay 105x92 |
| 32 | Closed rail: tile size | ≈ 105x92 px (scaled) | 104x89 px | low | code | Height u*10.8 → u*10.9. Negligible |
| 33 | Closed rail: hamburger glyph | 3 white bars, ≈ 34 px wide (scaled), stroke ≈ 5 px, round caps | 28 px wide, ≈ 3 px stroke (stock AnimatedIcon), thinner and smaller | medium | code | Custom painter: bars u*4.0 wide, stroke u*0.6, round caps, white |
| 34 | Closed rail: menu button tile | ≈ 72x71 px (scaled), almost transparent fill, radius ≈ 22 | 71x72, white 4% fill, radius ≈ 20 | low | code | Lower the fill to ≈ 2% |
| 35 | Closed rail: active circle (disk) | Disk ≈ 73 px (scaled), deeper amber (232,164,30), soft top highlight | Disk ≈ 80 px (u*9.2), lemon radial goldLight to gold | medium | code | Inner u*8.6. Darken the gradient: #F5B92E to #D9961C |
| 36 | Closed rail: active circle (ring and gap) | Thin bright ring ≈ 106 px; the gap between ring and disk is dark emerald with only a faint halo, which gives a clear "target" look | Ring 107 px, but the gap is filled with gold @10% plus a 30% glow, so it reads as an olive smudge and the ring is less distinct | medium | code | Ring fill alpha → 0. Move the glow to outside the ring (blur u*1.5, alpha 0.35). Ring opacity 1.0, width 1.6-2 |
| 37 | Closed rail: active glyph | Graduation cap ≈ 54 px wide (scaled), centred | Cap ≈ 45 px wide | low | code | Active icon size about u*6.0 |
| 38 | Closed rail: "30" bubble overlap | Sits on the ring's top-left and only touches the disk edge; the cap glyph is fully visible | Covers the left third of the disk and hides the cap's tassel | medium | code | For the active item, anchor the bubble to the ring's top-left (offset about -u*1 x, -u*1 y) instead of to the tile rect |
| 39 | Closed rail: bubble colour | Flat amber (224,163,30), no visible gradient | Lemon gradient (254,214,86) to (243,185,40) with a dark drop shadow | medium | code | Flat amber #E0A31E. Softer shadow (alpha 0.2) |
| 40 | Closed rail: bubble size and text | ≈ 54x39 px (2 digits), 63x40 (114); text dark, weight ≈ 600 | 53x36, 63x37; weight 700 | low | code | Height u*4.6. Weight 600 |
| 41 | Closed rail: icon offset in tile | The glyph sits about +8 px right and +6 px down of the tile centre (bottom-right bias, leaving room for the bubble) | About +4 px right and +6 px down | low | code | Offset u*0.9 horizontally |
| 42 | Closed rail: rail edge | 3-4 px bright emerald bevel (53,114,82) | 1.2 px line (45,99,78) | low | code | Same as #21 |
| 43 | Closed rail: rail width | ≈ 159 px (scaled) | 162 px | low | code | Fine |
| 44 | Closed rail: certificate glyph (6th item) | n/a (item not in the reference) | FA `award` rosette. Consistent with the style, but it doesn't match the menu's document glyph | low | code | Use the same certificate-with-seal glyph in the rail and the menu, for continuity in the morph |
| 45 | Closed rail: lattice corner ornaments | Present (content corners) | Only the top-left one | low | asset | Add the asset |

## Animation notes

Frames s1, s2 and s3 (1280x592), slowed.

1. **Dividers leak outside the panel (bug, high).** In s2 the six vertical dividers are drawn at x≈947, to the left of the panel's leading edge (x≈951) and floating over the content. Cause: `_item` places the divider at the absolute final `g.dividerX` (`left: g.dividerX - rect.left`, with `Clip.none`) while the panel and rows are still mid-slide. Fix: position it relative to the morphing rect (for example `rect.left + (dividerX - rowRect.left) * t`), or fade it in only once the panel edge has passed it.
2. **Labels are placed absolutely as well.** `right: rect.right - g.labelRight` uses the final screen-space x, so the labels don't travel with their row. This hides at the current stagger timing, but the same class of bug applies.
3. **Icons double-expose.** The rail glyph and the menu glyph cross-fade at equal size (book vs open book, award vs document). At t≈0.5 both are visible at about 50% opacity, as a smeared ghost (visible in s2 on القرآن and الشهادات). Either use the same glyph in both states or switch at t=0.5 with a quick scale-down/scale-up.
4. **Pills are not anchored to the rows.** The pills interpolate from tile to final pill position independently of the row rect. In s2 they ride the top-left corner of the rows (pill centre y≈120 vs row centre 127) and touch the row's left rim.
5. **The hamburger-to-X midpoint looks glitchy.** The stock `AnimatedIcons.menu_close` midpoint in s1/s2 renders as scratchy diagonal strokes inside a small square. With the thin stroke it reads as an artefact. Use a custom painter (bars rotate to ±45° while the middle bar fades), with the heavier stroke from the reference.
6. **Tiles widen before the panel opens.** In s1 the tiles are already about 130 px wide while the panel edge has barely moved, and the active gold disk is shrinking inside a wide empty tile. Consider easing the tile width with the panel (same curve), so the tiles never overhang the rail visually.
7. **The scrim darkens the content progressively.** The reference shows no dimming (see #23).
8. **What works:** the selected-row capsule growing out of the active tile, the staggered label fade, and the close button travelling from the rail top to the panel corner all read well and are worth keeping.

## Summary

The structure is right: panel width (666 vs 669 px), row pitch (95 px), row count/order, rail width (162 vs 159 px), tile size and the active-circle concept all match. The open menu loses most fidelity on **icon style and size** (solid and small vs outline and large), the **count pill hugging the row rim**, a **green rather than gold selected-row fill**, a **stadium radius instead of a 32 px rounded rectangle**, and a **thin cream close X** instead of a bold white one. Rows and tiles in both states have a visible white glass fill, while the reference is near-transparent and outline-driven. The rail's active circle loses its crisp "target" look because the ring gap is filled with gold. Bubbles are lemon-gradient instead of flat amber. The morph has one real bug: the dividers render outside the panel mid-animation. It also has two polish issues: the icon double-exposure and the menu_close midpoint. The missing assets (arch, filigree caps, bottom pattern, corner lattice) account for much of the remaining "bare" feeling of the open panel.
