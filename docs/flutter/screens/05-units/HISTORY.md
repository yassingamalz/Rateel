# Screen 05 (units, وحدات المقرر): history of the work

Chronology of everything done, found and decided for screen 05, so the next sessions do not repeat it.
Branch `flutter/05-units`, created on 2026-11-22 from `flutter/03-courses`. Plan: `../05-units.md`. Decisions:
`../../DECISIONS.md` (rows dated 2026-11-22). Assets: `../../ASSETS.md`, section "Units".

## 0. Starting point (2026-11-22)
- Branch state: `lesson-production` (lesson videos), `flutter/04-side-nav` (approved, PR #38 open),
  `flutter/03-courses` (screen 03 v13, illustrated card style D pending the owner).
- Owner: start screen 05 from `flutter/03-courses`; screen 03 goes to its own PR; later corrections on 03 are
  brought here with `git merge origin/flutter/03-courses` (or `master` once 03 is merged).
- Goal: replicate the ChatGPT reference (`reference.webp`) **and** the animations of the Angular units screen
  (`src/app/features/units/`, `shared/directives/border-fill.directive.ts`), with haptics and light on the
  completion.

## 1. Plan and questions (commit 28d354e)
- Plan `../05-units.md`: layout in u (reference 1672×941, u = 9.41 px), states, Angular → Flutter motion table,
  asset prompts U1–U6 (`../../prompts/05-units/images-v1.txt`).
- Found: unit data in `src/assets/data/units/*.json`, 5–7 units per course; **courses 08–11 have no units
  file** (empty state «قريبًا»). Unit types: video, reading, practice, test.
- Owner answers: title on the right, **arch centred on the title**; corners top left + bottom right; background
  pattern yes; completed unit with a check badge; next unit's lessons open by themselves (toast until screen 06);
  Angular fill sound yes.

## 2. v1 (commit 6bef607)
- Code: `lib/units/` (`units_screen.dart`, `unit_circle.dart`, `unit_data.dart`, generated `unit_data_gen.dart`
  from `tools/flutter-review/gen_unit_data.py`), `lib/core/learn_flow.dart` (nested navigator: courses → units,
  side nav stays), `lib/core/sounds.dart` (`audioplayers`, `assets/sounds/fill-sound.mp3`).
- Screen 03 change: tapping the course in progress opens screen 05 (was the toast «الوحدات: قريبًا»).
- Motion: entry choreography, press ripple + shine, locked tap shake + toast, completion sequence (ring fill with
  light head and a tick every 10%, half line + diamond at 50%, flash + sparkles, check badge, light to the next
  unit, padlock pops, glide, success, lessons open); last unit → courses screen plays the course completion.
- Review aids: `?units=<course>`, `?unit=<i>`, `?completeUnit=<i>`, long press on the unit in progress.
- Found: the web build must use `--no-web-resources-cdn` (CanvasKit CDN unreachable from the headless browser:
  blank page). Recorded in `CLAUDE.md` and `LESSONS-LEARNED.md`.
- Found: the APK build needs `dl.google.com`, `maven.google.com`, Gradle hosts. The owner approved a personal
  cloud environment **"Rateel"** with these hosts (the Default environment blocks them).
- Critic v1 (`critic-v1.md`): **6.5/10** (layout 8.5, assets 4: placeholders).

## 3. v2 (commit 97ee1c6)
- Owner's assets (zip, 10 elements PNG + SVG) checked one by one on the screen's green
  (`docs/design-assets/units/assets-2026-11-22/`): book from the PNG "revised" (closest to the reference, SVGs
  bulkier); padlock, microphone, scroll, swap arrows: SVG (identical to the PNG, crisp); girih tile: SVG; corners:
  PNG (finer than the traced SVG). The owner's first PNG exports (`originals-chatgpt/`) had red/yellow keying
  fringes: archived, not used.
- Critic-v1 code fixes: title gradient over the descenders, title size, play triangle, arch size, disc gradient,
  diamond, mosque olive, crescent.

## 4. Owner phone test of v2 → v3 (commit a1e9d5e)
- **Unlock looked like icons swapping** (book and play disc cross-fading, completed unit changing icon too) →
  the unlock plays in sequence; completed units keep the play disc + check badge.
- **Course percentage did not follow the units** → one shared progress: `courseProgressFromUnits` (completed units
  + share of the unit in progress); back on screen 03 the bar catches up with fill, ticks and the line at 50%.
  Widget test checks 1 of 5 units → 20%.
- **Padlock must be green** (reference: all green, no gold) → `ui/units/padlock_green.svg` recoloured from the
  owner's SVG; on narrow icons (microphone, scroll) it sits at the lower right as a badge.

## 5. Critic v2 (on v3: 7.2/10) → v4 (commit d96b827)
- Found: the swap-icon replacement had silently not applied in v2 (still a Material icon) → fixed.
- Fixes: girih fainter (11%) and masked under the header; ring 47.2u with sweep-lit rim and dark hairlines;
  lit disc edge; badge gradient + dark shadow + 3.8u text; play disc cream gradient; diamond; arch warm gold;
  corners tinted gold with relief shadow; raster assets precached (they popped in late); unlock without
  semi-transparent states.
- Found: the U6 prompt asked for an 8-point grid, the reference is a large 10-point girih → prompt U6b written.

## 6. Critic v3 (on v4: 8.1/10, no high item) → v5 (commit 4f9da6a)
- Found: a PageView does not paint pages outside its viewport → the completed unit next to the rail vanished
  after the glide. Replaced by a custom track (`_scroll` controller, drag with snap and rubber band).
- Fixes: no dark ring inside the disc edge; arch 45.4u with a gold gradient along the stroke; unlock without any
  overlap (book shrinks and sinks, play disc from 62%, ring colour with it, padlock solid while it lifts); title,
  divider (colours moved to `RateelColors`), pill, badge, line, padlock, mosque, corners, girih colour.
- APK 1.0.101.

## 7. Owner decisions on the style conflicts (sheet `owner-decisions.jpg`)
1. Line between units: **B**, thin line lit at 50% / 100% like the course path.
2. Background: **B**, same as screen 03.
3. Unit ring and badge: **A**, as in the reference (`unit*` tokens confirmed for the unit circles).
4. Corners: stay different between 03 and 05.
- Background pattern: the owner keeps the current U6 tile. The U6b image delivered later (8-point stars,
  horizontal overlap bands, edges not seamless) is archived as `07b_girih_tile_v2_unused.png`, not used.

## 8. Locked look and unlock (after the v5 phone test)
- Owner: keep the padlock fly-off; the **unit icon never changes** when it opens (book stays a book, video keeps
  the play disc), it only goes from dark to lit with a light ring; padlock **centred on the icon** of every type and
  **larger** (9u); locked units must look closed.
- Angular original checked: locked unit at 70% opacity, frosted disc (`backdrop-filter: blur(4px)`) behind a
  muted lock (`unit-card.component.scss`).
- Four looks shown (`locked-styles.jpg`: A Angular, B dark veil, C desaturated, D veil + glass plate);
  **owner chose B** (45% dark veil that lifts while the padlock flies off). Frames: `unlock-frames-v6.jpg`.

## Open after screen 05
- Owner approval on the phone → pull request `flutter/05-units` into `master` (after #38 and the screen 03 PR).
- Stable APK signing key (each new cloud container signs with a new debug key: the phone asks to uninstall).
- Course 03 icon to redo; courses 08–11 need units data.
- Next screen: **06, lessons of the unit** (`docs/design/glassy-gamified/screens/06-lezioni-dell-unita.webp` on
  `lesson-production`), branch `flutter/06-lessons` from `flutter/05-units`; it replaces the toast
  «دروس الوحدة: قريبًا» and will call `unitCompleted` when the last lesson of a unit ends.

## Files of this screen
Reference `reference.webp`; captures `capture-v1…v5*.png`, `phone-v1…v5.png`; comparisons `compare-v1…v5.jpg`;
completion/unlock frames; videos `demo-v1/v2/v5.mp4`; critic reports `critic-v1…v3.md`; decision sheet
`owner-decisions.jpg`.
