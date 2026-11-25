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

## 2. Owner answers, Angular capture, feedback proposals (2026-11-25)
- Answers: dark + light (08 light as the reference), no skip, options/navigation/counter/end as the Angular original,
  sounds needed (details in the plan's header).
- Angular original run locally (`npm ci`, `ng serve --port 4300`) and captured at 915×412 with
  `tools/flutter-review/test-angular-capture.js` (answers right/wrong alternately): `angular/` question, selected,
  feedback correct/wrong (modal over a blurred veil, confetti on correct), after-feedback rows (green ✓ / red ✕, the
  correct ones shown), completion popup (pass/fail), results, question details. The reference 10 is the Angular screen
  restyled. Notes: Angular shuffles the questions; its capsule stays «0/100» (bug); one column of options scrolling
  inside the card.
- Feedback proposals drawn over the reference (`tools/flutter-review/test-feedback-mockup.{html,js}`,
  `feedback-mockups/`): **A** bar inside the card in place of «تأكيد الإجابة» (medallion, title, points or the correct
  answer, explanation, «السؤال التالي»), no veil; **B** Angular-style glass modal with a gold rim over a dark veil (no live
  blur), medallion on the top edge, points + streak or the correct answer, explanation, «متابعة». Recommended: A.
- Prompts v2 (`images-v2.txt`): T1 polish of the chosen feedback, T2 results, T3 completion (passed / not passed);
  sounds S1/S2 (+S3) described for the owner.
