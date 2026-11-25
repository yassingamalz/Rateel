# Screen 08: reading lesson (درس قراءة), plan v1 (2026-11-25)

Branch `flutter/08-reading-lesson` from `master` (49406b6, screens 02–07, 11, 14 merged).
References (branch `lesson-production`, `docs/design/glassy-gamified/screens/07-lezione-video-{dark,light}.webp`), copied
here: `08-reading-lesson/reference-dark.webp`, `reference-light.webp`; Angular original `angular-original.png`
(`src/app/features/lessons/reading-lesson/`). History: `08-reading-lesson/HISTORY.md`.

## 1. What the reference shows (dark, 1842×854, u = 8.54 px)
First reading of the reference (boxes in u, x from the left edge, y from the top); measured precisely, element by element, during the build.

| # | Element | Reference | Build |
|---|---|---|---|
| 1 | Capsule «0 / 100», top left | x 4.7–50.6u, y 7.8–14.4u | **shared 02 bar** (approved size 46×7u, left → right fill) |
| 2 | Pause button, top right | Ø 13.8u | **shared 02 bar** (15.5u, Simply Piano menu motion) |
| 3 | Lobed arch with open-book emblem, centre top | arch x 72–160u, peak y 1u, tails to y 23u; asymmetric: the right tail runs longer and lower | reuse `decor/header_arch.svg` (03) + `header_book.svg`, fitted by correlation; if the shape does not fit ±4 px → new asset |
| 4 | Mosque silhouette, left of the title | x 46–72u, y 5–25u, green, fading down | reuse `decor/mosque.webp` (tone in code, as 07) |
| 5 | Crescent and star, right of the title | x 157–167u, y 9–19u, gold, star full gold | reuse `decor/crescent_star.svg` (star at 100% instead of 55%) |
| 6 | Lesson title «آداب تلاوة القرآن الكريم» | centre x 108u, y 18u, cap ≈ 6u, cream with shadow | `titleCream` + `titleShadows`, text from the data |
| 7 | Gold divider with diamond | y 24.6u, x 84–132u | shared `GoldDivider` (07) |
| 8 | Toolbar panel | x 4.7–211u, y 27.9–40.4u, radius ≈ 4u, thin green rim, faint lattice inside | code (glass panel), lattice = asset R1 |
| 9 | «قواعد التجويد ⓘ» pill (left) | x 8.4–44.3u, h 7.9u, gold rim, gold ⓘ disc | shared `LessonPill` (glass) + gold ⓘ disc in code |
| 10 | Moon button, «A» button and a thin separator (centre) | Ø 8.2u each, moon = gold rim; «A» = green filled disc | shared `LessonRoundButton`; glyphs in code (crescent, serif «A») |
| 11 | ‹ «8 / 1» › (right): previous, counter pill, next | Ø 7.9u buttons, pill 15.6×6.9u | `LessonRoundButton` + small `LessonPill`; chevrons in code (as 02) |
| 12 | Verse card | x 4.7–211u, y 43.8–78.8u, radius ≈ 3.5u, gold rim ≈ 0.35u with soft gold glow, dark green glass fill, lattice band along its bottom (≈ 9u, fading up) | code + asset R1 (same lattice as the corners) |
| 13 | Verse number badge «1» | lobed 4-point star frame, gold line, x 195–205u, y 47–57u | asset R2 (or code, see Q9) |
| 14 | Verse text, right aligned | right edge at 194u, baseline ≈ 63u, cap ≈ 6u, bold cream with shadow | Readex Pro w600, `titleCream`, shrinks to fit 1–3 lines |
| 15 | Line under the card (shadow / reflection) | y ≈ 83u, faint | card shadow (check by profile) |
| 16 | Dots, one per verse | 8 dots Ø 2.6u, gap 5.5u, centred x 108u, y 90u; current = gold, others muted green | code |
| 17 | «تخطي ⏩» | x 175–211u, y 83–94u (bottom **right**) | shared `SkipButton` (07, bottom **left**, see Q2) |
| 18 | Lattice corners top left and top right | stepped quatrefoil lattice, fading inwards and down | asset R1 (tile) masked in code, or the 07 corners (see Q8) |
| 19 | Background | radial dark emerald, no girih over the whole screen (only corners and bands) | shared background with the `video*` tones (V1) |

## 2. Behaviour (from the Angular original, `reading-lesson.component.*`)
- Content: `src/assets/data/content/reading/<lessonId>.json` (5 reading lessons: recitation-basics 1–3, rules-overview 1–2;
  3, 4 or 8 verses, 40–116 characters). Bundled as JSON assets, parsed at open.
- One verse at a time on the card (reference); ‹ › , the dots and a horizontal swipe change the verse. Proposed motion: the
  card slides out and the next one slides in (RTL: next comes from the left), 300 ms easeOutCubic, verse badge pops, dot
  glides; haptic `tick`.
- Progress (Angular `updateProgress`): (verse index + 1) / verses. Reaching the last verse completes the lesson after
  1.5 s (Angular). See Q3/Q4.
- «تخطي»: completes the lesson immediately (Angular `handleSkip`); the 02 capsule fills, light, leave with `true`
  (screen 06 plays the completion, as 07).
- Pause / back / restart: shared 02 bar. Restart → verse 1.
- «قواعد التجويد»: Angular opens a side panel (slides in from the right, 300 ms) with search and the list of rules
  (colour, name, description, example). See Q5.
- «A»: Angular opens a menu: font (عثماني / القرآن / القاهرة / نسخ), size 18–36 px (default 24), line spacing 1–3×.
  See Q6.
- Moon: Angular switches the reading between light and dark (app theme service). See Q1.
- Tajweed marks: the data marks parts of each verse with a rule id; Angular colours them. Only 6 rules have a colour in the
  Angular service (`adab-general` is #1F4037, invisible on dark green); the other ids (adab-taharah, ikhfa…) have no
  definition. The reference shows all text cream. See Q7.

## 3. Performance (`PERFORMANCE.md` rules)
- No endless animation: the only loop would be the gold dot's soft breathing → proposed **none** (static glow).
- One controller per effect (verse change, panel, menu), each with its own small `AnimatedBuilder`.
- `RepaintBoundary` around the static header (arch, mosque, crescent, title), the toolbar, the background with corners,
  and the card; the card's glow and lattice are static (cached).
- No blur over live content (the rules panel uses a dark veil, no `ImageFilter`).

## 4. Questions for the owner
- **Q1 Light theme.** The reference has a light version and the moon button switches theme in Angular. A: build dark only
  now, the moon switches only the reading area later (button present, disabled toast «قريبًا»); B: build both now, the
  moon switches this lesson between dark and light (first light screen of the app). *Proposal: B for this screen only*,
  since the toggle is on screen and the light reference exists.
- **Q2 «تخطي» position.** Reference: bottom right. On 07 you moved it bottom left (forward = left in Arabic). *Proposal:
  bottom left as 07* (one rule for all lessons).
- **Q3 Capsule counter.** A: verses «n / N» (same as 07 sections; the toolbar also shows the verse); B: «n / 100» as the
  reference. *Proposal: A* (02 decision: steps n/N).
- **Q4 Completion.** A (Angular): reaching the last verse completes the lesson by itself after 1.5 s; B: on the last verse
  «تخطي» becomes a gold «إكمال ✓» and the lesson completes when tapped (no surprise exit while reading the last verse).
  *Proposal: B.*
- **Q5 Rules panel.** No reference. A: side glass panel as Angular (search + list), I make a mockup to approve first;
  B: a ChatGPT reference image of the open panel (prompt R3); C: drop the button for now. *Proposal: B, then build 1:1.*
- **Q6 Typography menu «A».** A: as Angular (font, size, spacing); B: only size and spacing (fonts: one Quranic font is
  still an open decision, Amiri Quran 🟡). *Proposal: B, with the menu style from the R3 reference.*
- **Q7 Tajweed colours.** A: all text cream as the reference (marks ignored for now); B: colour the marks with a
  palette that reads on dark green. *Proposal: A* (the rule data is incomplete, logged in `SCREENS.md`).
- **Q8 Lattice.** The corners and the band inside the card are a **stepped quatrefoil lattice** that is not in the library
  (11 has a smooth ogee lattice, 07 a star band). *Proposal: one new seamless tile R1, used for both (masked in code).*
- **Q9 Verse badge.** A: ChatGPT asset R2 (lobed 4-point frame); B: drawn in code (simple geometric shape, exact
  measurements). *Proposal: R2* (rule: art from ChatGPT).
- **Q10 Swipe.** Swipe left/right on the card to change verse, in addition to ‹ › and the dots? *Proposal: yes.*

## 5. Assets (prompts in `../prompts/08-reading-lesson/images-v1.txt`)
- R1 seamless stepped-quatrefoil lattice tile (corners + card band; light variant tinted in code).
- R2 verse-number badge frame.
- R3 reference image of the open rules panel and the «A» menu (only if Q5 = B).
- Reused: `header_arch.svg`, `header_book.svg`, `mosque.webp`, `crescent_star.svg`, `GoldDivider`, `LessonPill`,
  `LessonRoundButton`, `SkipButton`, 02 bar.
