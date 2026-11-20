# Shared UI asset library

Every graphic element supplied by the owner (generated with ChatGPT) is stored twice:

1. **Source** (as delivered, with variants and previews): `docs/design-assets/<group>/`. Common property of
   the project: other streams (lesson videos, future screens) take elements from here.
2. **In the app** (cleaned: transparent margins trimmed, fixed colours removed so `currentColor` works):
   `app_flutter/assets/ui/<kind>/`, registered in `pubspec.yaml`.

SVG icons use `currentColor`; the app sets the colour from `RateelColors` (flutter_svg `SvgTheme`).

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/nav/lessons.svg` | `sidebar/navigation/lessons/` | side nav (الدروس) | |
| `ui/nav/quran.svg` | `sidebar/navigation/quran/` | side nav (القرآن) | outline open book, both states |
| `ui/nav/training.svg` | `sidebar/navigation/training/` | side nav (التدريب) | |
| `ui/nav/leaderboard.svg` | `sidebar/navigation/leaderboard/` | side nav (المتصدرين) | trophy with star |
| `ui/nav/achievements.svg` | `sidebar/navigation/achievements/` | side nav (الإنجازات) | |
| `ui/nav/certificates_two_tone.svg` | `sidebar/navigation/certificates/` | side nav (الشهادات) | gold seal #E9B020 kept; root `color` removed |
| `ui/nav/certificates.svg` | same | spare (one colour) | |
| `ui/controls/menu.svg`, `close.svg` | `sidebar/controls/` | library | the nav draws ☰→✕ with a painter (same geometry) to morph between them |
| `ui/decor/arch.svg` | `ornaments-svg-kit/vector/rateel_top_arch.svg` | open menu, above the rows | stroke 4.1→7.2, filter glow removed; PNG arches kept as spare |
| `ui/decor/cap_left.png`, `cap_right.png` | `sidebar/decorative/filigree/row_end_caps_pair.png` | selected row end caps (owner's choice) | split and trimmed 267×442; vector caps in `ornaments-svg-kit/` are spares |
| `ui/decor/star_tile.svg` | `ornaments-svg-kit/vector/rateel_bottom_geometric_tile.svg` | bottom of the open menu, 38% opacity, repeated | seamless; PNG band kept as spare |
| `ui/decor/bottom_pattern.svg` | `sidebar/decorative/bottom_pattern/` | spare | seamless tile 256×96 (replaced by the star band) |
| `images/lattice-corner-*.webp` | `lesson-production: src/assets/images/guided/frames/` | screen corners | |
