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

### Courses (screen 03), delivered by the owner 2026-11-20
Sources: `docs/design-assets/courses/screen-assets/` (CR-01…CR-12, PNG originals + traced SVG, `manifest.json`),
`tajweed-icons/` (two icon sheets, vector, one group per icon), `ui-glyphs/` (4 SVG glyphs, currentColor).
App copies: SVG viewBox trimmed to the drawn area (+20 px), fixed width/height removed; sheets split into one SVG per icon.

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/decor/header_arch.svg` | CR-01 | screen 03 header arch | traced, faithful; no outward tails at the bottom (the reference has them) |
| `ui/decor/header_book.svg` | CR-02 | emblem on the arch apex | matches the reference |
| `ui/decor/mosque.webp` | CR-03 PNG | header, left | PNG kept (it has the fade to transparent; the SVG has none); 900 px |
| `ui/decor/crescent_star.svg` | CR-04 | header, right | star split into its own path at 55% opacity (muted olive star, as in the reference) |
| `ui/decor/corner_ornament.svg` | CR-05 SVG | top-left corner, mirrored top-right | SVG without the pale haze of the PNG; replaces `images/lattice-corner-*` on screen 03 |
| `ui/decor/title_divider.svg` | CR-06 | under the title | replaces the code painter |
| `ui/decor/card_pattern.svg` | CR-07 | card bottoms, tinted `cardPattern` | one strip per card width (not seamless, not needed) |
| `ui/courses/course_01.svg` | CR-08 | course 01 icon | traced, two gradients; replaces the lesson-production mushaf |
| `ui/courses/course_02.svg` | CR-09 | course 02 icon | exactly the reference icon |
| `ui/courses/course_03…12.svg` | `tajweed-icons/` sheets (6: icons 2–6 → 03–07; 5: icons 1–5 → 08–12) | courses 03–12 | two-tone gold #FFD95A/#F2B623, fixed colours; sheet icon 1 (profile) is a spare of CR-09 |
| `ui/glyphs/lock.svg`, `star.svg`, `play.svg`, `check.svg` | `ui-glyphs/` | lock disc, level pill, play button; check spare (completed course) | currentColor |
| spares | CR-10 lock badge, CR-11 3D star (SVG filter: not usable in flutter_svg), CR-12 gradient play | — | kept in the sources |

### Courses refinements, delivered by the owner 2026-11-21
Sources: `docs/design-assets/courses/refinements-2026-11-21/` (5 PNG + SVG). Evaluation and use:

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/courses/course_01.webp` | `04_open_quran_rehal` PNG | course 01 icon | clean, no brown outline; PNG used (the SVG reconstruction differs); trimmed, 500 px |
| `ui/courses/course_02.svg` | `05_speaking_profile` SVG | course 02 icon | cream → gold gradient on the face line; viewBox trimmed |
| `ui/decor/header_book_filled.webp` | `01_open_quran_emblem` PNG | spare | filled pages: the reference's emblem has dark pages with a gold rim, so CR-02 (outline) stays on the arch |
| `ui/decor/corner_top_left.webp`, `corner_top_right.webp` | `02`, `03` PNG | spares | carved lattice, but denser and brighter than the reference; their SVGs use masks/CSS (not rendered by flutter_svg) |
| `ui/decor/trellis_corner_left.svg`, `trellis_corner_right.svg` | drawn by Claude (`tools/assets/corner_trellis.py`) on the owner's request | spares (replaced by the owner's corners below) | Moroccan lobed trellis, brighter towards the diagonal, dark offset line (carved look) |

### Corner ornaments, delivered by the owner 2026-11-21 (second set)
Sources: `docs/design-assets/courses/corners-2026-11-21/` (`rateel_ornamento_sinistro/destro`, PNG 1254 px + traced SVG).

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/decor/corner_owner_left.webp` | `rateel_ornamento_sinistro.png` | screen 03, top-left corner | diagonal band of lobed cells with small sparkles and a thin frame; PNG used (the SVG is a stair-step trace); trimmed, 700 px; placed 1.2u off-screen so the frame sits on the screen edges |
| `ui/decor/corner_owner_right.webp` | `rateel_ornamento_destro.png` | screen 03, top-right corner | fades out towards the left; runs 3u under the side rail |

### Corner ornaments, third set (owner, 2026-11-21) — in use
| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/decor/corner_glow_left.webp`, `corner_glow_right.webp` | `courses/corners-glow-2026-11-21/` (PNG 1254 px with a soft glow) | screen 03 corners | faint fringe pixels (alpha < 90) recoloured gold to avoid red/yellow edges; trimmed, 800 px; frame corner on the screen corner, glow spilling off-screen; right one under the rail; radial fade |
| `ui/decor/corner_geo_left.svg`, `corner_geo_right.svg` | `courses/corners-geometric-2026-11-21/` (octagons + 8-point stars, scalloped edge) | spares | clean vector, uses clipPath |
| `ui/decor/corner_owner_left/right.webp` | second set (lobed lattice) | spares | used in v10–v11 |

### Course card art (owner, 2026-11-21), under review
Sources: `docs/design-assets/courses/card-art-2026-11-21/` (PNG only: the owner rejected the traced SVGs).

| App folder | Source | Notes |
|---|---|---|
| `ui/course_art/green/course_01..03.webp` | `green/` (first pack) | emerald glass with gold, courses 1–3 only (others fall back to gold) |
| `ui/course_art/gold/course_01..12.webp` | `01_original_gold/` | rich gold, "3D"; courses 08–12 have a card frame and green background baked in: to regenerate or crop before use |
| `ui/course_art/abstract/course_01..12.webp` | `02_abstract_gold_png/` | minimal gold line art |
