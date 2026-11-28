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
| `ui/coming_soon/quran_emblem.webp` | `01_quran_emblem.png` (E1), tone **B** (owner 2026-11-25: gold saturation ×1.3 value ×0.86, green value ×0.72, cream ×0.96) | big emblem above the title | 549×640; `02_quran_emblem_alternative.png` kept as a spare (almost identical) |
| `ui/coming_soon/badge_frame.webp` | `03_empty_gold_frame.png` (E2) | lobed gold frame of the 4 feature badges | 296×320, filled with #06352A |
| `ui/coming_soon/glyph_headphones.webp` | `04_headphones.png` (E3) | دروس صوتية | cream glyph, 256 px |
| `ui/coming_soon/glyph_group.webp` | `05_group.png` (E4) | جلسات جماعية | cream glyph, 256 px |
| `ui/coming_soon/glyph_certificate.webp` | `06_certificate_seal.png` (E5) | شهادات إتمام | cream seal, green check, 256 px |
| `ui/coming_soon/glyph_microphone.webp` | `07_microphone.png` (E6) | تدريب النطق | cream glyph, 256 px; its base is tilted by about 1° |
| `ui/coming_soon/background.webp` | `08_emerald_background.png` | background of screen 14 (owner: faithful to the reference) | 1843×853 WebP q88, drawn over the content box (`BoxFit.fill`), darkened with `soonBgTone` |
| not used | `09_mosque_silhouette.png` | rejected | broken alpha (ragged opaque blob around the mosque); `ui/decor/mosque.webp` is reused |
| `fonts/Cairo.ttf` | google/fonts `ofl/cairo/Cairo[slnt,wght].ttf` (OFL, `fonts/OFL-Cairo.txt`) | screen 14 texts (`cairo()`) | variable wght 200–1000 |

## Screen 08, reading lesson (2026-11-25)
Source: `docs/design-assets/reading-lesson/` (owner's ChatGPT zip, prompts `prompts/08-reading-lesson/images-v1.txt`,
magenta background). Processing: `tools/assets/reading_lesson_assets.py`.

| App file | Source | Used in | Notes |
|---|---|---|---|
| `ui/reading/lattice_tile.webp` | `01_moroccan_gold_lattice.png` (R1) | top corners, toolbar patches, band along the bottom of the verse card | stepped quatrefoil lattice; one period measured by autocorrelation (313.5 px), 2×2-cell seamless tile (seam diff x 1.0, y 2.5 /255), 512 px; gold line + dark carved offset; tinted per theme in code |
| `ui/reading/badge_line.webp`, `badge_fill.webp` | `02_emerald_gold_badge.png` (R2) | verse-number badge | split into the gold line and the inner emerald (flat #023D27, no shadow ring), so the light theme can tint each layer; 250×256 |
| `docs/flutter/screens/08-reading-lesson/reference-panel.png` | `03_lesson_screen_rules_and_typography.png` (R3) | reference of the rules panel and the «A» menu | not an app asset |
| `data/reading/*.json` | `src/assets/data/content/reading/` (Angular data) | sentences of the 5 reading lessons | copied as they are |
| reused | `decor/header_arch.svg`, `header_book.svg`, `crescent_star.svg`, `mosque.webp`, `GoldDivider`, `LessonPill`, `LessonRoundButton`, `SkipButton` | screen 08 | arch: upper part fits the reference, lower lobes ≈ 6u wider (see `screens/08-reading-lesson/HISTORY.md`) |
| `ui/reading/arch.webp` | `04_reading_header_arch.png` (R4, owner 2026-11-25) | header arch of screen 08 | magenta un-mixed, trimmed, 2048×483; fitted by correlation on the reference (F1 0.88, 102.1×21.5u); left part hidden behind the mosque as the reference |
| `ui/reading/crescent.svg`, `star.svg` | `decor/crescent_star.svg` (CR-04) split into its two paths, viewBox trimmed | screen 08 header | placed separately on the reference (IoU 0.85 / 0.93): the reference's star sits apart, in the crescent's opening; star at 55% as 03/05 |


## Screen 10, test lesson (2026-11-25)
No new art: the reference's elements come from the library (08 arch R4, badge R2, lattice R1, mosque, crescent and
star, `glyphs/star.svg`) or are drawn in code (circles, rows, radios, ✓/✕ discs, arrow, ↻, buttons).

| App file | Source | Used in | Notes |
|---|---|---|---|
| `data/test/assessment-lesson-1.json` | `src/assets/data/content/assessments/` (Angular data) | the 10 questions of «اختبار أساسيات التجويد» | copied as it is; the second test (`assessment-lesson-2`) has no content |
| `sounds/test_correct.mp3`, `test_wrong.mp3`, `test_streak.mp3`, `test_passed.mp3` | **plinkfx** (CC0, release `plinkfx-wav-ogg.zip`): `gem-1`, `error-1`, `sparkle-1`, `level-up-1`, converted to mp3; sources, licence and the sampler in `docs/design-assets/test-lesson/sounds/` | correct / wrong answer, streak banner, test passed (`Sounds.correct/wrong/streak/passed`) | owner's choice from the sampler (C3, W2, S3, P2), 2026-11-26; the first uisfx «dreamy» set (2026-11-25) kept there as spares |
| `ui/test/trophy.webp` | `test-lesson/icons/01_trophy.png` (owner's ChatGPT T4) | trophy next to «أحسنت» in the results | magenta un-mixed on the edge only (inside opaque), trimmed, 384 px (`tools/assets/test_lesson_assets.py`) |
| `ui/test/flame_medallion.webp` | `test-lesson/icons/02_flame_medallion.png` (T5) | medallion of the streak banner | same processing, 384 px |
| `ui/test/flame.webp` | `test-lesson/icons/03_flame_glyph.png` (T6) | the three flames of «n إجابات متتالية» in the feedback bar | same processing, 192 px |
| `ui/test/star_coin_gold.webp` | `test-lesson/icons/04_star_coin_gold.png` (owner, 2026-11-26) | points in the results («نقطة») | all-gold coin with a gold star; same processing, 256 px |
| `ui/test/star_coin_emerald.webp` | `test-lesson/icons/05_star_coin_emerald.png` | library (not used yet) | emerald coin, gold rim and star |
| `ui/test/star_coin_mint.webp` | `test-lesson/icons/06_star_coin_mint_glow.png` | library (not used yet) | mint glass coin, cream star, soft glow (the glow beyond 6 px of the edge is cut) |
| Material icons `lightbulb`, `refresh` | Flutter Material icon font | recommendations, ↻ (not passed) | **placeholders** in the lesson gold until drawn assets exist (prompt T4) |
| `docs/flutter/screens/10-test-lesson/reference-feedback-{correct,wrong}.webp`, `reference-completion-{pass,fail}.webp` | owner's ChatGPT images from prompts T1/T3 | inspiration only (owner: different from the lesson style, not to replicate exactly) | not app assets |

Shared code from screen 10: `lib/lessons/lesson_decor.dart` (moved from 08 unchanged: `LessonPal`, `LessonBackground`,
`LatticeField`, `LessonHeader` + `HeaderSpec` (subtitle, gold title, optional book), `LessonBadge`, `GoldCardPainter(fill:)`,
`ToolRimPainter`, `MoonPainter`, `lessonMosqueTone`).
## Owner's icon collection (2026-11-25, screen 12)
Source: `docs/design-assets/icon-collection/` (owner's zip `Rateel_Icon_Collection`, 21 flat icons on magenta, 1254 px,
stored as lossless WebP, plus `original_sheet.webp`). Processing: `tools/assets/icon_collection.py` (alpha from the
distance to magenta only: the blue/green model of `key-magenta.py` tinted the cream towards green), app copies 512 px
WebP in `app_flutter/assets/ui/icons/`. **All of them are in the shared library**, for the whole app.

**Owner's rules for icons (2026-11-25):**
- Where a cream icon comes with and without **dark green inner lines**, use the variant **with the green lines**:
  it goes in the same visual direction as the rest of the app.
- The **gold icons** (`*_gold_*`, `lantern_gold`) are for **decoration** of the app.
- Exceptions on screen 12: **flame and calendar** are used exactly as the reference (gold).

| App file | Used in | Notes |
|---|---|---|
| `ui/icons/calendar_gold.webp` | 12, header emblem | as the reference |
| `ui/icons/flame_gold_01.webp` (`_02`, `_03` spares) | 12, streak disc; 03, streak chip | as the reference |
| `ui/icons/document_01.webp` (`_02` spare) | 12, lesson challenge | green lines |
| `ui/icons/quran_rehal_01.webp` (`_02`, `_03` spares) | 12, recitation challenge | green lines |
| `ui/icons/trophy_cream_01.webp` (`_02` spare) | 12, trophy challenge | |
| `ui/icons/trophy_gold_01/02.webp`, `lantern_cream/gold.webp`, `mosque_dome_01/02.webp`, `mosque_full.webp`, `prayer_beads_01/02/03.webp` | library | not used yet |
| `ui/icons/coin_gold.webp` | 12, «50» pills and the flying coin | Angular `src/assets/images/coin-icon.png`, trimmed, 256 px |

Screen 12 also reuses: `decor/header_arch.svg` (03), `decor/mosque.webp`, `decor/crescent_star.svg`,
`video/corner_bottom_*.webp` (top corners), `video/bottom_band.webp` (bottom band, under a gold wave drawn in code),
`coming_soon/glyph_microphone.webp`, `glyphs/check.svg`.

**Future note (owner, 2026-11-25): one asset direction for the whole app.** The header decoration of the references
(stars, crescent, mosque, arch, the lattice of the top corners) is taken from the shared library, the same standard
set on every screen, even where a reference draws them better (more three-dimensional). If they are improved, they are
**regenerated once with ChatGPT for the whole app** and replaced everywhere, never per screen. Their **place and size are standard too**: mosque and crescent + star as on screen 03
(mosque 10.5u from the content's left edge, top 8u, 49u wide; crescent 25.5u from the right edge, top 7.5u, 10.65×9.75u).

Comparison of the reference's header assets with the library (owner, 2026-11-26): `ASSET-STYLE-COMPARISON.md`.

## Screen 22, listening lesson (2026-11-26)
| Asset | Source | App copy | Note |
|---|---|---|---|
| Husary recitation, سورة الكوثر 108:1–3 and سورة الناس 114:1–6 | everyayah.com `Husary_128kbps` (owner, Q1 A) | `assets/audio/quran/husary/10800{1,2,3}.mp3`, `11400{1..6}.mp3` | mock lesson; release: stream with the reciter of the settings (`BACKLOG.md`) |
| Font Amiri Quran (verses) | `@fontsource/amiri-quran` 5.3.0 (OFL), arabic subset, woff → ttf | `assets/fonts/AmiriQuran.ttf`, `OFL-AmiriQuran.txt` | first Quran verse of the app (DECISIONS 2026-11-20 🟡 → ✅) |
| Headphones emblem (H1) | owner's H1 v2 (ChatGPT, 2026-11-27): `docs/design-assets/listening-lesson/h1-headphones.png` | `assets/ui/listening/headphones.webp` | magenta keyed (`tools/assets/key-magenta.py`; pinkish spill between the two band lines set to the key first), trimmed, 600 px; header of 22, box 9×7.9u at 5.2u (matches the reference top/bottom, 67 vs 73 px wide at 853) |
Reused: `ui/reading/{arch,badge_fill,badge_line,lattice_tile}.webp`, `reading/{crescent,star}.svg`, `decor/mosque.webp`.
| Guided voice, 8 lines | Gemini TTS `gemini-3.1-flash-tts-preview`, voice Orus, calm style (owner's F) | `assets/audio/narration/orus/*.mp3` + `manifest.json` | `tools/flutter-review/gen_listening_narration.py`; texts with full tashkīl, each take transcribed |

## Badges (screen 27, 2026-11-27)
Sources: `docs/design-assets/badges/` (owner's ChatGPT medals M01–M12 + locked L1 on magenta; `dark-green/` = second engraving
of M01–M12). Processing: `tools/assets/badge_assets.py` (same magenta key as the leaderboard), **one common trim box** for all
medals so they line up when swapped, 512 px, WebP.
| Asset | Source | App copy | Note |
|---|---|---|---|
| Earned medals M01–M12 | `badges/m<nn>_*.png` | `ui/badges/m<nn>.webp` | brown engraving, default (as the reference) |
| Earned medals, dark green | `badges/dark-green/m<nn>_*.png` | `ui/badges/green/m<nn>.webp` | off by default (`?medals=green`), owner chooses |
| Locked medal L1 | `badges/l1_locked.png` | `ui/badges/l1.webp` | shared by every locked badge, grid and detail panel |
Reused from 11: `ui/leaderboard/{ribbon,lattice,coins_gold}.webp`.
Progress-fill kit from the owner (2026-11-27, ChatGPT, 1254 px, on magenta): sources `docs/design-assets/badges/`
`blank_olive.png`, `blank_gold.png` (empty medals), `l1_locked_v2.png` (locked medal with a solid cream padlock, replaces `l1_locked.png`),
`padlock.png` (closed), `padlock_open.png`. App copies (`tools/assets/badge_assets.py`): `ui/badges/blank_olive.webp`, `blank_gold.webp`,
`l1.webp` (the three share one trim box and the 487×512 size of the medals), `padlock.webp` + `padlock_open.webp` (one common box, keyhole filled
dark olive; the open one overlays the closed one exactly). **Used by screen 27:** the two padlocks (position on the medal measured from `l1`).
Spare: `blank_olive`, `blank_gold`, `l1`.


## Screen 24, end of lesson: stars (owner, 2026-11-27)
Sources: `docs/design-assets/end-of-lesson/` (owner's ChatGPT images on magenta, 2000×667). Processing:
`tools/assets/end_of_lesson_assets.py` (magenta key of `key-magenta.py`; the earned row's warm glow, blended by the generator with
the magenta, is re-keyed as gold over magenta so it does not turn pink), trimmed, longest side 1024 px, WebP. Common library: any
screen that rates something with stars (results of 10, 12, 13…) can reuse them.
| Asset | Source | App copy | Note |
|---|---|---|---|
| Three earned stars on a gold arc, with sparkles | `end-of-lesson/s1_stars_row_earned.webp` | `ui/end_of_lesson/stars_row_earned.webp` | as in `screens/24-end-of-lesson/reference-dark.webp` |
| Three empty (cream) stars on the gold arc | `end-of-lesson/s3_stars_row_empty.webp` | `ui/end_of_lesson/stars_row_empty.webp` | base for 1–2 stars: single stars drawn over it |
| One earned star, one empty star | `end-of-lesson/s2_star_earned_and_empty.webp` (split in halves) | `ui/end_of_lesson/star_earned.webp`, `star_empty.webp` | single stars, to compose 1/3 and 2/3 |
**Used by screen 24** (`lib/lessons/lesson_end.dart`): `stars_row_earned` (3 stars, cut in three slices that pop), `stars_row_empty` + `star_earned` (1–2 stars); `star_empty` spare. Also reused: `ui/test/star_coin_gold.webp`, `ui/test/flame.webp`, `ui/reading/lattice_tile.webp`.
References of the screen (not assets): `screens/24-end-of-lesson/reference-dark.webp` (24-A), `reference-light.webp` (24-B), owner 2026-11-27.
A second empty row (cream stars with a stronger gold rim) was shown in the chat but not received as a file: to add when the owner sends it.

## Screen 29, profile (2026-11-27)
| File | Source | Used for | Notes |
|---|---|---|---|
| reused | `decor/header_arch.svg` (with a blurred glow copy), `decor/header_book.svg` (header emblem and the «الدروس» glyph), `decor/mosque.webp`, `decor/crescent_star.svg`, `decor/corner_glow_*`, `video/bottom_band.webp` (lattice), `glyphs/star.svg`, `icons/flame_gold_01.webp`, `leaderboard/avatar_5.webp` | screen 29 | light theme: tinted with `profL*` |
| (was placeholder) | `courses/course_01.webp` | Quran on the stand until 2026-11-28 | replaced by `decor/quran_mihrab_*` |

### Common library additions from screen 29 (owner, 2026-11-28: «metti tutto nella libreria comune»)
Sources in `docs/design-assets/profile/` (owner's `Rateel_Assets_Complete.zip` + 4 images); processed by
`tools/assets/profile_assets.py` (magenta key as `badge_assets.py`). Any screen may reuse them.
| File | Source | Used for | Notes |
|---|---|---|---|
| `ui/decor/quran_mihrab_dark.webp` | `04_quran_mihrab_dark.png` (A1) | 29 identity card, dark | full-bleed art on #00271A (arch, glow, floor light baked); edges faded in code |
| `ui/decor/quran_mihrab_light.webp` | `03_quran_mihrab_light.png` (A1b) | 29 identity card, light | full-bleed on cream, green book |
| `ui/icons/quran_rehal_gold.webp` | `01_quran_rehal.png` | spare (any screen) | gold book on the wooden rehal, keyed |
| `ui/icons/quran_rehal_gold_glow.webp` | `02_quran_rehal_glow.png` | spare | same with its glow |
| `ui/glyphs/rank_rosette.webp` | `05_award_rosette.png` (A2) | 29 tile «الترتيب» | gold rosette, brown star |
| `ui/glyphs/open_book.webp` | `06_open_book_white.png` (A3) | 29 tile «الدروس» | white, tinted in code |
| `ui/glyphs/layers.webp` | `07_stacked_layers_gold.png` (A4) | 29 level bar | |
| `ui/decor/lattice_star_tile.webp` | `08_islamic_lattice.png` (A5) | 29 avatar arch, level bar | seamless, 2×2 cells, white lines (tinted), not trimmed |
| `ui/decor/mosque_light.webp` | `09_mosque_skyline_light.png` (A6) | 29 header, light theme | beige skyline |
| `ui/icons/flame_gold_04.webp` | `10_streak_flame.png` (A7) | 29 tile «أيام متتالية» | the reference's flame (12 keeps `flame_gold_01`) |
| `ui/decor/mosque_v2_dark.webp`, `mosque_v2_light.webp` | `12_…`, `13_mosque_light_magenta.png` | spare | new mosque drawing, green / beige (`11_mosque_dark_original.png` on black: source only) |
| `ui/decor/avatar_ring_gold.webp` | `16_avatar_ring_magenta.png` | spare (29 draws the reference's thin ring in code, owner 2026-11-28) | glow keyed from the green channel (no magenta spill); solid ring 95.1% of the width, 5.5% thick |
| — | `14_…`, `15_quran_mihrab_*_checker.png`, `17_avatar_ring_checker.png` | not used | the checkerboard is painted into the image (RGB, no alpha): cannot be keyed cleanly |
| `ui/leaderboard/avatar_1…10.webp` | (edited) | every avatar of the app | yellow background darkened #FCC300 → #E7AF03 (owner, 2026-11-28: all avatars, critic v1 of 29) |

## Screen 30 onboarding: references (owner, 2026-11-28)
Generated by the owner with ChatGPT from `prompts/30-onboarding/reference-v1.txt` (zip `Rateel_Onboarding_Daily_Practice.zip`,
PNG 1843–1844×853). Owner: «questi riferimenti devono fare parte della libreria comune». Saved as webp q90 in the common
library and, per `PROCESS.md`, in `docs/flutter/screens/30-onboarding/` (same files).

| File (`docs/design-assets/…`) | Source PNG | Content |
|---|---|---|
| `onboarding/reference-a-welcome-{dark,light}.webp` | `01_welcome` | 30-A: emblem, «أهلاً بك في رتّل», name field, six avatars, «التالي», step dots |
| `onboarding/reference-b-level-{dark,light}.webp` | `02_tajweed_level` | 30-B: three level cards (مبتدئ selected), back button |
| `onboarding/reference-c-goal-{dark,light}.webp` | `03_daily_goal` | 30-C: four daily-goal cards (10 دقائق selected), «ابدأ التعلّم» |

Note seen on the images (to check in the plan): the light 30-A title reads «رتل» without the shadda (dark has «رتّل»).

## Owner's white icon set (2026-11-28, screen 30)
Zip `rateel_white_icons` (ChatGPT, 1024 px, cream #FCF1D0-like line icons, each on magenta and transparent; numbered and
unnumbered files are two framings of the same drawing). Common library: sources (lossless webp) in
`docs/design-assets/icons-white/{transparent,magenta}/` + `preview.webp`; app copies from the transparent PNGs, trimmed,
512 px, in `app_flutter/assets/ui/icons_white/` (`tools/assets/white_icons.py`).

| App file | Used in | Notes |
|---|---|---|
| `icons_white/stopwatch.webp` | 30-C goal cards; 23 row «الهدف اليومي» | G1 of `prompts/30-onboarding/images-v1.txt` |
| `icons_white/open_book.webp` | 30-B «مبتدئ» | |
| `icons_white/checkmark.webp` | 30 check disc of the selected card | |
| `icons_white/chevron_right.webp` | 30 round back button | |
| all the others (`chevron_left`, `headphones`, `question_circle`, `hamburger`, `trophy`, `medal`, `document_search`, `settings_gear`, `13_open_book_sidebar`, numbered copies) | library | not used yet |

| App file | Source | Used in | Notes |
|---|---|---|---|
| `splash/emblem_inner.webp` | derived from `splash/emblem.webp` (2026-11-28) | 30 light emblem fill (Q7) | the emblem's inner area: gold outline closed (9 px), flood fill from the centre, grown 2 px under the gold; white + alpha, tinted in code |
