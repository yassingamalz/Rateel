# Rateel — Courses Screen Assets (CR-01 → CR-12)

This package contains **12 original PNGs** generated during the conversation and **12 traced SVG versions** with true editable vector paths (no embedded bitmaps).

```
assets/courses/
  decorations/   CR-01 to CR-07, each .png and .svg
  icons/         CR-08 to CR-12, each .png and .svg
manifest.json
```

## Fidelity notes
- **PNG:** original generated files, copied without altering their pixels or transparency. They retain the original full canvas, including any extra transparent margins and any subtle halo effects.
- **SVG:** vector reconstructions based on traced silhouettes/visible colored regions, **not pixel-exact reproductions**. All SVGs contain geometry/path data; they scale without pixelation. Complex multi-tone artwork and soft light effects may differ from the PNG originals.
- CR-05 SVG retains the geometric ornament but omits the pale diffuse haze present in its source PNG, keeping its background transparent and suitable as an app overlay.
- CR-07 reflects the original horizontal artwork but its edges have not been mathematically reworked into a guaranteed seamless tiling unit. For pixel-perfect tiling a dedicated tile should be authored.
- The SVG viewport matches each original PNG. Apply sizing and cropping/positioning via app styles.
- CR-10 includes the circle/badge as seen in the generated PNG. If you need only the padlock glyph, extract or mask that group in the app.

## Rendering examples

Web: `<img src="assets/courses/icons/cr-11-level-star.svg" width="28" height="28" alt="Level" />`

Flutter (flutter_svg): `SvgPicture.asset('assets/courses/icons/cr-11-level-star.svg', width: 28, height: 28)`

## Files
See `manifest.json` for names, sizes and SHA-256 hashes of the original PNG sources.
