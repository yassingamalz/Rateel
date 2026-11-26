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

## 3. Owner's choices and references (2026-11-25)
- Feedback **A** (bar inside the card). Owner's ChatGPT images for T1 (feedback correct / wrong) and T3 (end popup
  passed / not passed) delivered, stored as `reference-feedback-{correct,wrong}.webp`, `reference-completion-{pass,fail}.webp`;
  owner: «ChatGPT made something quite different from the lessons' standard style: use it only as a reference, do not
  replicate it exactly; your mockups were very good». T2 (results) not delivered: results built from the Angular content
  in the lesson style.
- Sounds: owner «find them online yourself». Chosen from the npm package `uisfx` (CC0 audio), family «dreamy», by
  measured pitch contour (`docs/design-assets/test-lesson/sounds/README.md`).

## 4. Build v1–v5 and verification (2026-11-25)
- Shared decor: the 08 private widgets moved to `lib/lessons/lesson_decor.dart` (renamed public, `HeaderSpec` for the
  header geometry, subtitle, gold title, optional book; `GoldCardPainter(fill:, rimWidth:)`). 08 checked against a
  `master` build: dark/light identical; the panel/long captures differ in a mosque area that also differs between two
  `master` runs (nondeterministic).
- Code: `lib/lessons/test_data.dart` (`TestContent`, `TestRun`: Angular scoring 10 + streak bonus ≤ 10, score %, pass
  70%, sequential unlock, recommendations), `lib/lessons/test_lesson_page.dart` (`TestLessonPage`, `testLessonRoute`,
  `TestMetrics`); `lesson_page.dart` routes `LessonType.test` here; tokens `test*` in `rateel_theme.dart`.
- Header geometry: arch R4 fitted on reference 10 (97.2 × 13.8u, top 1.4u: shoulders within 1 px; the reference's lower
  right lobe runs longer, asset shape), mosque 2.9u higher than 08, crescent and star placed on the reference, gold title,
  subtitle from the data description, divider 78u.
- Fixes found on zoomed side-by-sides: question text 4.3u, option text lifted 0.9u (Readex sits low), points pill star on
  the right, button keeps the reference look before a choice, card fill darker as the reference (T3), subtitle colour,
  lattice band 20%, diamond lines 34u, circles' numbers 4.2u, moon glyph 4.4u; after an answer the list scrolls to the
  correct row (the bar covers the third row); a wrong answer keeps its stake faded in the pill.
- Verification v5 (`verify-v5.md`): every element within ±4 px except the tapered ends of the shared dividers and the
  arch's lower right lobe.
- Tests: `flutter analyze` clean, `flutter test` 13/13 (new: scoring rules, select → confirm → feedback → next with the
  locked circle).
- Captures `capture-v5-*-phone.jpg` (question, selected, correct, wrong, light, results, passed, not passed, details),
  comparison `compare-v5-phone.jpg`, demo `demo-v5-phone.mp4` (questions 8–10, results, popup, light, details,
  «إنهاء الدرس» back to 06). Scripts `tools/flutter-review/test-capture.js`, `test-demo.js`, `test-angular-capture.js`,
  `test-feedback-mockup.{html,js}`.

- APK 1.0.402 (v5), after 3 build attempts (Maven Central 429).

## 5. v6: owner's phone test of 1.0.402 (2026-11-26)
- Owner: the lesson works very well; criticisms: light final buttons should be filled (white text); the right part of the
  results is not well composed; the correct/wrong sounds are not good (search libraries online); the screen of the
  correct answers in a row was lost (Angular); the end popup must be redesigned.
- Light buttons filled for every test button (`testLGold*`, `testLGreen*`), text white.
- Results summary: two layouts for the owner (`?results=a|b`): A one glass panel (ring 18u + trophy title + message,
  divider, three stat columns divided by lines), B ring 20u + medallion title + message, three equal vertical tiles.
  Sheet `results-variants-v6.jpg`.
- End popup: A centred score ring 24u with gold sparks bursting when passed (`_BurstPainter`), chips «⭐ n نقطة» and
  «✓ n / N», one message line; B wide banner with the medallion (trophy / cap) on the right, score, chips, message.
  Both keep the countdown line and tap-to-close. Sheet `end-popup-variants-v6.jpg`.
- Streak (Angular `streak-indicator`, from 2 right answers): banner over the card for 1.9 s (flame medallion,
  «n إجابات متتالية!», the bonus of the next answer) + flames chip in the feedback bar; sound `test_streak.mp3`
  (uisfx soft streak, provisional). Sheet `streak-v6.jpg`.
- Sounds: plinkfx (CC0, 274 sounds) downloaded as the release zip (`plinkfx-wav-ogg.zip`); sampler video of 19
  numbered candidates (C1–C6 correct, W1–W6 wrong, S1–S3 streak, P1–P4 passed) sent to the owner.

## 6. v7: owner's choices on v6 (2026-11-26)
- Sounds from the sampler: C3 gem (correct), W2 error (wrong), S3 sparkle (streak), P2 level-up (passed), all plinkfx
  (CC0, release zip), converted to mp3 (`assets/sounds/test_*.mp3`; sources and the sampler in
  `docs/design-assets/test-lesson/sounds/`).
- Buttons filled with white text in both themes (`_GoldButton` with `_Tone.gold/green/red`); «إعادة الاختبار» green
  after a passed test, red after a failed one.
- Results: layout A kept, B removed; the end popup (A/B) removed, backlog.
- Partly correct answers (`TestRun.partial`): multiple choice with at least one right option chosen but not the exact
  set: amber disc / row / bar («إجابة صحيحة جزئيًا», «الإجابة الكاملة: …»), 5 points, ½ question in the score, streak
  reset; right options not chosen shown as «missed»; results stat «إجابات جزئية» (shown only when there are some).
- Streak banner: width from its content, even padding; «!» removed from every text of the screen.
- Tests 13/13 (scoring test extended with the partial answer). Captures `capture-v7-*-phone.jpg`.

- APK 1.0.422 (v7).

## 7. v8: dark buttons outlined again (2026-11-26)
- Owner: in the dark theme the outlined buttons with the outer glow were better; an APK to compare both. `_GoldButton`
  blends the dark outlined look (reference: olive → dark glass, rim #F7EE9E → #FFD229, cream-gold text; green / red rim
  for «إعادة الاختبار») with the filled light look by the theme; `testDarkFilled` (long press on the moon) forces the
  filled look in the dark theme for the comparison. Captures `capture-v8-*-phone.jpg`.
- Prompts v3 (`prompts/10-test-lesson/images-v3.txt`): T4 trophy, T5 flame medallion, T6 flame glyph.

- APK 1.0.423 (v8).
