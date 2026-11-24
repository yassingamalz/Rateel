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
| `ui/course_art/emblem/course_01..12.webp` | `card-art-2026-11-21/emblem/emblem_sheet_original.png` (4×3 sheet) | gold emblems on a green swoosh; split by the transparent gaps, faint fringe recoloured gold, trimmed |

All card art is trimmed to its content and drawn in a 23u box on the left of the card (owner, 2026-11-21: never under the title or description; at most a sliver overlaps the text column).

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/glyphs/lock_badge.webp` | `courses/screen-assets/icons/cr-10-lock.png` | lock on locked course cards (2026-11-24) | owner's badge: cream padlock in a dark disc with a green ring; trimmed, 300 px |

### Units (screen 05), delivered by the owner 2026-11-22
Sources: `docs/design-assets/units/assets-2026-11-22/` (10 elements, PNG + SVG each, README), and
`originals-chatgpt/` (first PNG exports of arrows, scroll, padlock, microphone: same drawing but red/yellow
keying fringes, kept for reference only). PNG and SVG compared on the screen's green: the SVG is used where it is
identical and crisp, the PNG where it is closer to the reference.

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/units/book.webp` | `02_open_book_revised.png` | reading units | PNG: closest to the reference (thin covers, notch); the SVGs and `01_original` are bulkier; trimmed, 600 px |
| `ui/units/padlock.svg` | `03_padlock.svg` | spare (gold shackle and rim) | identical to the PNG; viewBox trimmed |
| `ui/units/padlock_green.svg` | `03_padlock.svg`, recoloured | locked units | all green as in reference 05: shackle #12553C, rim #1A5238, body #2E7350→#245F41, keyhole #DFD08C (owner, 2026-11-22) |
| `ui/units/microphone.svg` | `04_microphone.svg` | practice units | identical to the PNG; viewBox trimmed |
| `ui/units/test_scroll.svg` | `05_test_scroll.svg` | test units | identical to the PNG; viewBox trimmed |
| `ui/glyphs/swap.svg` | `06_change_course_arrows.svg` | «تغيير المقرر» | stroke → currentColor |
| `ui/decor/girih_tile.svg` | `07_girih_background_tile.svg` | background of screen 05, tile = 95% of the height, 40% | stroke → currentColor (`girihLine`); PNG is on magenta (spare) |
| `ui/decor/corner_units_top_left.webp`, `corner_units_bottom_right.webp` | `08`, `09` PNG | screen 05 corners | PNG finer than the traced SVG; trimmed, 800 px; `10_both_corners` is a spare |
| `sounds/fill-sound.mp3` | Angular app `public/sounds/fill-sound.mp3` | unit completion (`Sounds.fill`) | |
| reused | `header_arch.svg`, `mosque.webp` (olive tint), `crescent_star.svg`, `title_divider.svg`, `card_pattern.svg` (disc bottom), `glyphs/play`, `check` | screen 05 | |

### Lessons (screen 06), 2026-11-22 / 2026-11-23
Sources: `docs/design-assets/lessons/` — `angular-original/` (the Angular background pattern) and
`icons-2026-11-23/` (lesson-type icons L1–L5: originals, cleaned full-resolution PNGs in `PNG_puliti/` for any other
use, ChatGPT SVG reconstructions kept as spares; see its README).

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/decor/angular_pattern_2.webp` | `lessons/angular-original/islamic-pattern-2-dark.svg` (Angular `src/assets/images/`, an SVG wrapping a 1000 px gold #DAA520 PNG) | look B background | resized to 700 px; tiled 82u, turned 50°, 6% (Angular: 700 px, 50°, 4%) |
| `ui/lessons/read.webp`, `video.webp`, `practice.webp`, `listen.webp`, `test.webp` | `lessons/icons-2026-11-23/PNG_originali/01…05` (owner's L1–L5, ChatGPT) | lesson-type icon on the cards (gold as drawn; muted green tint when locked, dark on the gold card) | original PNGs: the SVGs and `PNG_1024` are reconstructions with different shapes (book, headphones, mic, clipboard); scattered haze (alpha ≤ 40) removed except within 3 px of the drawing; trimmed, 600 px |

### Leaderboard (screen 11), 2026-11-24
Sources: `docs/design-assets/leaderboard/` (owner's ChatGPT images A1–A4, on magenta; lattice on black) and the Angular
app (`src/assets/images/medals/`, `avatars/`). Processing: `tools/assets/leaderboard_assets.py` (magenta un-mix only near
the key colour, so silver stays opaque; lattice alpha from brightness).

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/leaderboard/ribbon.webp` | `ribbon_emerald_gold_02.png` (A1) | header ribbon, title arched in code | darker band of the two variants, closer to the reference; `_01` kept as a spare |
| `ui/leaderboard/lattice.webp` | `moroccan_ogee_lattice.png` (A2) | background lattice, tile 31.6u (4 cells), fades out by 31u | seamless (edge diff < 5/255); 512 px |
| `ui/leaderboard/coins_{gold,silver,bronze}.webp` | `coins_*.png` (A3) | rewards of rows 1–3 | trimmed, 256 px |
| `ui/leaderboard/book.webp` | `book_gold.png` (A4) | «n درس» | trimmed, 160 px |
| `ui/leaderboard/medal_{gold,silver,bronze}.webp` | Angular `medals/*-medal.png` | rows 1–3 | identical to the reference; trimmed, 400 px |
| `ui/leaderboard/avatar_1…10.webp` | Angular `avatars/avatar-*.png` | rows, pinned bar (circle + gold rim in code) | 256 px |

### Video lesson (screen 07), 2026-11-24
Sources: `docs/design-assets/video-lesson/` (owner's ChatGPT images V1–V4 on magenta, prompts
`docs/flutter/prompts/07-video-lesson/images-v1.txt`). Processing: `tools/assets/video_lesson_assets.py` (full magenta
un-mix: keeps the arch's semi-transparent fill; corners re-coloured from the green channel because ChatGPT faded them
towards pink). Tones measured on the reference are applied in code (`video_lesson_page.dart`, `_iconTone`, `_cornerTone`,
`_mosqueTone`).

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/video/unavailable_icon.webp` | `01b-video-unavailable-icon-v2.png` (V1, second version: closer to the reference) | "video not available" icon | trimmed (alpha > 60), 512 px; `01-…icon.png` kept as a spare |
| `ui/video/arch_frame.webp` | `02-gold-ogee-arch.png` (V2) | lobed arch frame of the lesson screens | **untrimmed** 2048×683 (fitted on the reference as a whole image); dimmed down the lobes in code |
| `ui/video/corner_bottom_left/right.webp` | `03-`, `04-lattice-bottom-*.png` (V3) | bottom corners; flipped at 38% for the top corners | 800 px square, olive-gold tone and bottom fade in code |
| `ui/video/bottom_band.webp` | `06-lattice-bottom-band.png` (V5) | faint lattice band along the bottom (not available state) | seamless tile cut between two crossings (4 cells, 545×256), tone/fade in code |
| `ui/video/thumbs/<videoId>.webp` | YouTube thumbnails of the lesson videos (`i.ytimg.com`, maxresdefault) | poster before the video plays and under the pause veil | only the two live links (BqFxf-WspTc, XfDdA9UgOVQ) |
| `docs/flutter/screens/07-video-lesson/reference-playing.webp` | `05-video-playing-screen.png` (V4) | reference of the playing state | not an app asset |
| reused | `ui/decor/mosque.webp` (tone in code), girih tile (`ScreenGirih(fadeTop: false)`) | screen 07 | |

Shared code from screen 07 (for the next lesson screens): `SkipButton` / `SkipMetrics`, `LessonPill`, `LessonRoundButton`, `PillGlyph` (`lib/lessons/lesson_widgets.dart`),
`GoldDivider` and `ScreenGirih(fadeTop:)` (`lib/core/screen_decor.dart`), `video*` tokens (`rateel_theme.dart`).

## Screen 14, coming soon (2026-11-24)
Source: `docs/design-assets/coming-soon/` (owner's ChatGPT zip, prompts `prompts/14-coming-soon/images-v1.txt`, magenta
background). Cleaned: magenta keyed out with colour unmixing, alpha < 12% cleared, trimmed, WebP q92.

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/coming_soon/quran_emblem.webp` | `01_quran_emblem.png` (E1) | big emblem above the title | 549×640; `02_quran_emblem_alternative.png` kept as a spare (almost identical) |
| `ui/coming_soon/badge_frame.webp` | `03_empty_gold_frame.png` (E2) | lobed gold frame of the 4 feature badges | 296×320, filled with #06352A |
| `ui/coming_soon/glyph_headphones.webp` | `04_headphones.png` (E3) | دروس صوتية | cream glyph, 256 px |
| `ui/coming_soon/glyph_group.webp` | `05_group.png` (E4) | جلسات جماعية | cream glyph, 256 px |
| `ui/coming_soon/glyph_certificate.webp` | `06_certificate_seal.png` (E5) | شهادات إتمام | cream seal, green check, 256 px |
| `ui/coming_soon/glyph_microphone.webp` | `07_microphone.png` (E6) | تدريب النطق | cream glyph, 256 px; its base is tilted by about 1° |
| not used | `08_emerald_background.png` | spare | whole background baked in one image (arcs, girih, mosque): the app keeps the shared `ScreenBackground` + `ScreenGirih`, arcs in code (one style) |
| not used | `09_mosque_silhouette.png` | rejected | broken alpha (ragged opaque blob around the mosque); `ui/decor/mosque.webp` is reused |

