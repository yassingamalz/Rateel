# Screen 08 (reading lesson, درس قراءة): history of the work

Branch `flutter/08-reading-lesson`, created on 2026-11-25 from `master` (49406b6: screens 02–07, 11, 14 merged).
Plan: `../08-reading-lesson.md`. Decisions: `../../DECISIONS.md`.

## 1. Start, references and plan (2026-11-25)
- References copied from `lesson-production`: `07-lezione-video-dark.webp` / `-light.webp` → `reference-dark.webp`,
  `reference-light.webp` (they show the reading lesson, owner 2026-11-24); Angular capture `angular-original.png`.
- Angular original read (`src/app/features/lessons/reading-lesson/`): verse list with active verse, ‹ › and dots, progress
  (index + 1) / N, auto-completion 1.5 s after the last verse, «تخطي» completes at once, rules side panel with search,
  typography menu (font, size 18–36, spacing 1–3×), light/dark toggle, tajweed marks coloured by rule.
- Data: 5 reading lessons with content in `src/assets/data/content/reading/<lessonId>.json` (3–8 verses). Only 6 rule ids
  have a colour/definition in the Angular service; most mark ids have none.
- Library check: arch (`header_arch.svg`), book emblem, mosque, crescent/star, gold divider, pills, round buttons, skip and
  the 02 bar are reused; missing: stepped-quatrefoil lattice (corners + card band, R1), verse badge (R2), no reference for
  the rules panel / font menu (R3).
- Plan v1 with questions Q1–Q10; prompts R1–R3 (`../../prompts/08-reading-lesson/images-v1.txt`, crops in `attach/`).
