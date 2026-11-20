# Rateel — Islamic UI Ornaments (SVG kit)

All SVGs under `vector/` contain native editable SVG paths, gradients and/or a vector pattern. They do not embed any PNG.

Included:
- `rateel_top_arch.svg`: pointed Islamic arch (header decoration), transparent background.
- `rateel_side_filigree_left.svg` and `_right.svg`: individual mirrored ornaments.
- `rateel_side_filigrees_pair.svg`: both ornaments in a single canvas.
- `rateel_bottom_geometric_border.svg`: repeated lower border, transparent background.
- `rateel_bottom_geometric_tile.svg`: one reusable repeating ornament unit.

`original_png/` preserves the original AI-rendered raster images byte-for-byte (exact gradients / pixel detail at original dimensions).
`exact_appearance_svg/` preserves the **exact original PNG appearance** inside an SVG container. Those SVGs are NOT pure vector and do NOT gain infinite resolution, although they match every original pixel.
`previews/` contains test raster renders of the editable SVGs.

**Important tradeoff:** The vector set is crisp and scalable but is a manual vector recreation of the supplied PNG assets rather than an exact mathematical recovery of the original raster brush texture. Small decorative texture and glow details can differ. The embedded set retains exact pixel appearance at native resolution but is raster-backed.

Use in HTML/CSS:
```html
<img src="rateel_top_arch.svg" alt="" />
```
Or use the tile as a CSS background with `background-repeat: repeat-x`.
