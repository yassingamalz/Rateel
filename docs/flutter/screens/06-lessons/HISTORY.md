# Screen 06 (lessons of the unit, دروس الوحدة): history of the work

Chronology of everything done, found and decided for screen 06, so the next sessions do not repeat it.
Branch `flutter/06-lessons`, created on 2026-11-22 from `flutter/05-units` (commit 5c0e6ab). Plan: `../06-lessons.md`.
Decisions: `../../DECISIONS.md` (rows dated 2026-11-22 onwards). Assets: `../../ASSETS.md`.

## 0. Starting point (2026-11-22)
- Screen 05 approved (APK 1.0.106), PR `flutter/05-units` → `master` open.
- Goal: replicate the ChatGPT reference (`reference.webp`, 1844×853) **and** the animations of the Angular lessons
  screen (`src/app/features/lessons/lessons-list`, `lesson-card`, border-fill), with haptics and light on the
  completions. Replace the toast «دروس الوحدة: قريبًا» on screen 05 (`_openLessons`), set `unitCompleted` when the
  last lesson of a unit ends; one progress shared by lessons, units and courses.

## 1. Plan and questions
- Plan `../06-lessons.md`: layout in u (u = 8.53 px), card states, Angular → Flutter motion table, shared
  progress, asset prompts L1–L5 (`../../prompts/06-lessons/images-v1.txt`), 9 questions for the owner.
- Found in the Angular app: lesson completion = rectangular border fill 1.5 s (top → right → bottom → left), then
  scroll to the next lesson and open it after 0.8 s; last lesson → units with `completedUnitId`; page title =
  first lesson's title; card shows `stepNumber/totalSteps` or ✓, duration in minutes.
- Found in the data: lessons only for course 01 (all 5 units, 13 lessons) and 3 files of course 02 whose unit ids
  do not match its units; lesson types `video`, `read`, `practice`, `listen`, `assessment`, `test`.
- Reference: locked card has a **gold** padlock with a grey-teal shackle on a muted green book; screen 05 (✅)
  uses the all-green padlock and a dark veil → asked (question 4).

## 2. Original Angular screen captured (owner asked to see it)
- The Angular app runs in the container: `npm ci --ignore-scripts`, `npx ng serve --port 4300`; route
  `/courses/01-tajweed-fundamentals/units/intro-tajweed/lessons` (course ids carry the `01-` prefix); progress
  set in `localStorage` (`tajweed_lesson_<course>_<unit>_<lesson>` = `{"isCompleted":true}`); completion replayed
  with `?completedLessonId=<id>`.
- Sheet `angular-original.jpg`: reference vs Angular (lesson 1 active; lesson 1 done; completion frames).
  Angular look: small flat cards (280×200 px), active card **filled gold** with dark text, locked cards black 50%
  veil + blur + 🔒 emoji, completed card gold 15% tint with ✓ pill, duration «⏱ N دقيقة», plain dim connector,
  title in small text with → at the top right, no header ornaments.
- Sheet `locked-compare.jpg`: reference locked/active card vs the approved 05 locked look and the Angular one.
