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
| 08 | Reading lesson (dark / light) | `07-lezione-video-{dark,light}.webp` (they show the reading lesson, owner 2026-11-24) | **approved** (v12) on `flutter/08-reading-lesson` (dark + light, rules panel with rule detail, text-size popup); PR to `master` pending |
| 09 | Practice lesson, recitation (dark / light) | `09-lezione-pratica-recitazione-*.webp` | to do |
| 10, 10b | Test lesson, and answer feedback | `10-lezione-test.webp`, `10b-…-risposta.webp` | to do |
| 11 | Leaderboard (classifica) | `11-classifica.webp` | **approved** (APK 1.0.346), merged into `master`; runs on mock data |
| 12 | Daily challenges | `12-sfide-giornaliere.webp` | **approved** (2026-11-26), merged into `master`; opened from the streak chip D2 of 03; mock data; leftovers in `BACKLOG.md` |
| 13 | Achievements (traguardi) | `13-traguardi.webp` | to do |
| 14 | Coming soon | `14-in-arrivo.webp` | **approved** (APK 1.0.375), merged into `master`; shown for القرآن / التدريب / الشهادات; font Cairo (S4) |
| 15–21 | Guided lesson: start, concept, definition, quiz, comparison, verse listening, summary | `15…21-lezione-guidata-*.webp` | to do |
| 22 | **Listening lesson** (owner, 2026-11-25): an audio plays (verse / words), then questions on what was heard, Simply Piano style (e.g. «what was in the word X: a ghunna?», «this one: a ghunna?»). Own lesson type `listen` (already in the data and in the 06 icons, headphones). Confirmed: separate lesson (owner). Build it **after 10/10b** and reuse their question + answer-feedback widgets; the same audio question can later also appear as one question type inside tests | `screens/22-listening-lesson/22-lezione-ascolto.webp` (from the app screenshots); plan `screens/22-listening-lesson.md` | to do (after 10/10b) |
| 23 | **Settings** (owner, 2026-11-25; **v1 built** on `flutter/23-settings`, 2026-11-26): theme dark/light, text size (already promised in `main.dart`), sound effects, vibration, reciter, daily reminder, about, reset progress. Gear at the bottom of the rail; list full width, «about» and «reset» are rows of the list (owner) | `screens/23-settings/23-impostazioni.webp`; plan `screens/23-settings.md` | **approved** (v1, APK 1.0.402) on `flutter/23-settings`; PR #50 → `master`, merge after 10 and 12 |

Done: 4 screens (03–06). To do: at least 16 (02, 07, 09, 10/10b, 11, 12, 13, 14, 15–21, 22, 23, 01, 24–30), plus 01 and 08 once defined.

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
| 12 Daily challenges | the 7 challenges (Angular list), completed count and streak live in memory only; completion only by the review long press; no midnight reset; the 03 streak chip shows the same mock streak. To wire: completion on return from the activity, reset, saving (plan Q3) | `app_flutter/lib/challenges/challenge_data.dart` |
| 04 Side nav | the counts in the rail/menu (30, 114, 2, 15, 5, 3) are the reference's demo values | `app_flutter/lib/nav/nav_items.dart` |

## Data problems found (fix in the lesson data before release)
| Where | Problem |
|---|---|
| `src/assets/data/lessons/01-tajweed-fundamentals/intro-tajweed.json` | `intro-lesson-2` (c9N4j8IF8mM) and `intro-lesson-3` (_nMiT7QFpIc): YouTube links dead (404) → "video not available". `intro-lesson-1` (BqFxf-WspTc) is an episode about «الإقلاب», not «مقدمة في علم التجويد». |
| `src/assets/data/content/reading/*.json` + Angular `reading-lesson.service.ts` | Tajweed marks use rule ids (adab-taharah, ikhfa, makharij-huruf…) that mostly have **no definition/colour**: only 6 rules exist in the Angular service, and `adab-general` (#1F4037) is invisible on dark green. |
| `src/assets/data/content/reading/*.json` | **38 of the 45 marks have wrong startIndex/endIndex** (Angular coloured cut words, e.g. «لاوة الط» for «الطهارة»); the app looks up the mark's text instead. Only 4 marks are tajweed rules (idgham, ikhfa, izhar, shaddah); the others are topics (adab-*, intention…). |

## Screens added on 2026-11-26 (owner: «all of them, in the suggested order»)
Found by comparing the Angular original (`src/app`) with this list. Built in this order, after the screens above;
each one gets its reference from the app screenshots (`docs/flutter/app-references/`) before building.
| N° | Screen | Comes from | Note |
|---|---|---|---|
| 01 | Splash / start-up (loading) | Angular `splash-screen`, `initialization` | uses the free number 01 |
| 24 | End of lesson (points, stars, continue) | Angular `completion-screen`, `completion-modal` | shared by every lesson type, like 02 |
| 25 | Test results (score, correct / wrong, retry) | Angular `assessment-results` | after 10/10b |
| 26 | Points history | Angular `points-history`, `points-card` | may live inside 13 or 29 |
| 27 | Badge collection and achievement detail | Angular `badges-collection`, `achievement-details-modal` | may be part of 13 |
| 28 | Help / tips overlay | Angular `help-tips` | first use of each lesson type |
| 29 | Profile (name, avatar, level, streak) | the leaderboard shows the user; no screen yet | may merge with 23 |
| 30 | Onboarding (first start: name, level, goal) | not in Angular | needed before release if there is an account |
Not a new screen: unit / course completion celebrations, already inside 03/05.
