# Screen 02 (shared lesson top bar): history of the work

Branch `flutter/02-lesson-bar`, created on 2026-11-24 from `master` (04c9513, screens 03–06 merged).
Plan: `../02-lesson-bar.md`. Decisions: `../../DECISIONS.md`.

## 0. Starting point (2026-11-24)
- `docs/flutter/SCREENS.md`, `STYLE-CONFLICTS.md` and the new `NEXT-SESSION.md` were only on the previous session's
  branch `ccr-d42db0d3-2ls4ag` (3 doc commits not in `master`): merged into this branch (DECISIONS.md conflict:
  both sides kept in date order).

## 1. Angular original and proposal (2026-11-24)
- Angular app run in the container (`npm ci --ignore-scripts`, `npx ng serve --port 4300`); lesson routes
  `/courses/01-tajweed-fundamentals/units/intro-tajweed/lessons/intro-lesson-1` (video) and
  `…/units/pronunciation-practice/lessons/pronunciation-lesson-1` (practice); progress preset in `localStorage`
  (`tajweed_lesson_<course>_<unit>_<lesson>` = `{progress: 42, expiresAt, version: '1.0.0', …}`).
  Script `tools/flutter-review/lesson-bar-angular-capture.js`.
- Found: the menu has **two** items, back **and restart** (SCREENS.md said only back); restart resets the position,
  not the progress. Practice lessons draw **two bars** (lesson-details + interactive-lesson). The bar is 200×24 px and
  hard to read over a video.
- Sheet `angular-original.jpg`; proposal mockup (HTML with the app's tokens, over a capture of the current placeholder
  lesson page) `proposal-v1.jpg`: option A capsule, option B wide line, menu open, phone 915×412.
  Tools: `lesson-bar-mockup.html` + `lesson-bar-mockup.js`, sheet `lesson-bar-sheet.py`.
- 7 questions to the owner (plan §3). Waiting for the answers before building.
