# Screens 10 / 10b (test lesson, اختبار): history of the work

Branch `flutter/10-test-lesson`, created on 2026-11-25 from `master` (8cbe223: PR #49 of screen 08 merged; screens 02–08,
11, 14 in `master`). Plan: `../10-test-lesson.md`. Decisions: `../../DECISIONS.md`.

## 1. Start, references and plan (2026-11-25)
- References copied from `lesson-production`: `10-lezione-test.webp` → `reference.webp`, `10b-lezione-test-risposta.webp`
  → `reference-answer.webp` (1842×854, dark only). 10b shows the **selected** state of a multiple-choice question, not a
  correct/wrong feedback.
- Angular original read (`assessment-lesson/`, `assessment/`): navigator (circles, ✓/✕, sequential unlock), question card
  (single, multiple, true/false, text input; points pill; hint), «تأكيد الإجابة» → «السؤال التالي» / «إنهاء الاختبار»,
  feedback modal (points, streak, correct answer, explanation), completion modal (score, 70% pass, countdown), results
  (score ring, stats, answers list, details, restart, finish).
- Data: only `assessment-lesson-1.json` has content (10 questions: 5 single, 3 multiple, 1 true/false, 1 text input).
- Library check: arch R4, badge R2, lattice R1, mosque, crescent/star, star glyph, 02 bar and the 08 lesson widgets cover
  every element of the reference; no new app art needed. Missing references: feedback (T1), results (T2), light (T3).
- Plan v1 with questions Q1–Q8; prompts T1–T3 (`../../prompts/10-test-lesson/images-v1.txt`, attachments in `attach/`).
