# Screens of the Flutter app: what is done and what is missing (2026-11-24)

Numbers come from the ChatGPT references (branch `lesson-production`, `docs/design/glassy-gamified/screens/`).
One branch per screen (`flutter/<nn>-<slug>`), owner approval before the next one (`README.md`).

| N° | Screen | Reference | State |
|---|---|---|---|
| 01 | Open: no reference file. Owner will decide later what it is | – | to define |
| 02 | **Shared top bar of every lesson** (progress bar, pause, back). Uses the free number 02 (owner, 2026-11-24) | none: Angular original `src/app/features/lessons/lesson-details` | built, critic 9.2, **APK 1.0.327 to test** (`flutter/02-lesson-bar`) |
| 03 | Courses (المسارات التعليمية) | `03-corsi.webp` | done, approved, in `master` |
| 04 | Side navigation (rail + open menu) | `04-menu-laterale-aperto.webp` | done, approved, in `master` |
| 05 | Units of the course | `05-unita-del-corso.webp` | done, approved, in `master` |
| 06 | Lessons of the unit | `06-lezioni-dell-unita.webp` | done, approved, in `master` |
| 07 | Video lesson (dark / light) | `07-lezione-video-{dark,light}.webp` | to do (after 02 and 11) |
| 08 | Open: no reference file | – | to define |
| 09 | Practice lesson, recitation (dark / light) | `09-lezione-pratica-recitazione-*.webp` | to do |
| 10, 10b | Test lesson, and answer feedback | `10-lezione-test.webp`, `10b-…-risposta.webp` | to do |
| 11 | Leaderboard (classifica) | `11-classifica.webp` | to do (next after 02) |
| 12 | Daily challenges | `12-sfide-giornaliere.webp` | to do |
| 13 | Achievements (traguardi) | `13-traguardi.webp` | to do |
| 14 | Coming soon | `14-in-arrivo.webp` | to do |
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
