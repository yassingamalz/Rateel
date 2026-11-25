# Screens of the Flutter app: what is done and what is missing (2026-11-24)

Numbers come from the ChatGPT references (branch `lesson-production`, `docs/design/glassy-gamified/screens/`).
One branch per screen (`flutter/<nn>-<slug>`), owner approval before the next one (`README.md`).

| N° | Screen | Reference | State |
|---|---|---|---|
| 01 | Open: no reference file. Owner will decide later what it is | – | to define |
| 02 | **Shared top bar of every lesson** (progress bar, pause, back). Uses the free number 02 (owner, 2026-11-24) | none: Angular original `src/app/features/lessons/lesson-details` | **approved** (APK 1.0.330), merged into `master`; menu motion as Simply Piano and capsule left → right merged with 07 |
| 03 | Courses (المسارات التعليمية) | `03-corsi.webp` | done, approved, in `master` |
| 04 | Side navigation (rail + open menu) | `04-menu-laterale-aperto.webp` | done, approved, in `master` |
| 05 | Units of the course | `05-unita-del-corso.webp` | done, approved, in `master` |
| 06 | Lessons of the unit | `06-lezioni-dell-unita.webp` | done, approved, in `master` |
| 07 | Video lesson | `07-lezione-video.webp` (not available); playing: full screen as Simply Piano (owner) | **approved** (APK 1.0.366), merged into `master`; sections are mock |
| 08 | Reading lesson (dark / light) | `07-lezione-video-{dark,light}.webp` (they show the reading lesson, owner 2026-11-24) | **in progress** on `flutter/08-reading-lesson` (plan v1, 2026-11-25) |
| 09 | Practice lesson, recitation (dark / light) | `09-lezione-pratica-recitazione-*.webp` | to do |
| 10, 10b | Test lesson, and answer feedback | `10-lezione-test.webp`, `10b-…-risposta.webp` | to do |
| 11 | Leaderboard (classifica) | `11-classifica.webp` | **approved** (APK 1.0.346), merged into `master`; runs on mock data |
| 12 | Daily challenges | `12-sfide-giornaliere.webp` | to do |
| 13 | Achievements (traguardi) | `13-traguardi.webp` | to do |
| 14 | Coming soon | `14-in-arrivo.webp` | **approved** (APK 1.0.375), merged into `master`; shown for القرآن / التدريب / الشهادات; font Cairo (S4) |
| 15–21 | Guided lesson: start, concept, definition, quiz, comparison, verse listening, summary | `15…21-lezione-guidata-*.webp` | to do |

Done: 4 screens (03–06). To do: at least 15 (02, 07, 09, 10/10b, 11, 12, 13, 14, 15–21), plus 01 and 08 once defined.

## Screen 02: shared lesson top bar (owner, 2026-11-24)
- Appears in **every type of lesson** (video, reading, practice, listening, test, guided).
- Source of truth: the Angular original, `src/app/features/lessons/lesson-details/lesson-details.component.{html,scss,ts}`:
  progress bar with fill and «n/100» text, pause button (pause ↔ play) that opens a small menu with «back» and «restart»; the interactive lesson
  has its own bar (`interactive-lesson.component.html`, % inside the bar).
- Same behaviour and structure as the original, with a **small restyle in the classy glass style** of the other screens
  (tokens in `DESIGN-SYSTEM.md`, glass back button as on screen 06, gold progress as `progressFill`/`amberPill`).
- It is a reusable widget: it takes the progress (0–1), a pause/back callback and returns control to the lesson page.

## Screens running on mock data (no real data yet)
Remember to connect these to real data (backend or app progress) before release.

| Screen | What is mock | Where |
|---|---|---|
| 11 Leaderboard | the whole list: 15 demo players (Angular names and avatars), scores, lessons, friends, regions; the user «أحمد عبدالرحمن» at rank 15; rewards 10K/5K/2K. All values are demo, the user's lesson count too. | `app_flutter/lib/leaderboard/leaderboard_data.dart` |
| 07 Video lesson | the **sections** of every video: 3 equal parts (`videoSectionCount`); planned data `sections: [{start, end}]` per video lesson | `app_flutter/lib/lessons/video_lesson_page.dart` |
| 04 Side nav | the counts in the rail/menu (30, 114, 2, 15, 5, 3) are the reference's demo values | `app_flutter/lib/nav/nav_items.dart` |

## Data problems found (fix in the lesson data before release)
| Where | Problem |
|---|---|
| `src/assets/data/lessons/01-tajweed-fundamentals/intro-tajweed.json` | `intro-lesson-2` (c9N4j8IF8mM) and `intro-lesson-3` (_nMiT7QFpIc): YouTube links dead (404) → "video not available". `intro-lesson-1` (BqFxf-WspTc) is an episode about «الإقلاب», not «مقدمة في علم التجويد». |
| `src/assets/data/content/reading/*.json` + Angular `reading-lesson.service.ts` | Tajweed marks use rule ids (adab-taharah, ikhfa, makharij-huruf…) that mostly have **no definition/colour**: only 6 rules exist in the Angular service, and `adab-general` (#1F4037) is invisible on dark green. |
