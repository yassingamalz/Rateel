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
