# Screens 10 / 10b: test lesson (اختبار) and answer feedback, plan v1 (2026-11-25)

Branch `flutter/10-test-lesson` from `master` (8cbe223: screens 02–08, 11, 14 merged).
References (branch `lesson-production`, `docs/design/glassy-gamified/screens/`), copied here:
`10-test-lesson/reference.webp` (`10-lezione-test.webp`, question, nothing selected) and `reference-answer.webp`
(`10b-lezione-test-risposta.webp`, a multiple-choice question with one option selected). Dark only; no light reference.
Angular original: `src/app/features/lessons/assessment-lesson/` + `assessment/` (navigator, question card, actions,
feedback modal, completion modal, results, question details). History: `10-test-lesson/HISTORY.md`.

**Note:** 10b is **not** a correct/wrong feedback: it is the *selected* state (gold row, filled gold radio). The
correct/wrong feedback, the completion and the results have **no reference** (prompts T1, T2).

## 1. What the reference shows (1842×854, u = 8.54 px; first reading, measured precisely during the build)

| # | Element | Reference | Build |
|---|---|---|---|
| 1 | Capsule «0 / 100», top left | x 6.8–51.8u, y 6.2–12.6u | **shared 02 bar** (46×7u, fills left → right) |
| 2 | Pause button, top right | Ø ≈ 14u | **shared 02 bar** (15.5u, Simply Piano menu) |
| 3 | Arch (no book emblem), centre top | same shape as 08 | reuse `ui/reading/arch.webp` (R4), fitted on this reference |
| 4 | Mosque left, crescent + star right | as 08, slightly different positions | reuse `mosque.webp`, `ui/reading/crescent.svg` + `star.svg`, placed on this reference |
| 5 | Title «اختبار أساسيات التجويد» | centre x 108u, y 10.5u, **gold gradient** (08: cream) | text from the data; gold title colour = new value (conflict T1) |
| 6 | Subtitle (data description) | y 17.3u, cream, ≈ 2.9u | text from the data |
| 7 | Gold divider with diamond | y 21.9u, x 84–132u | shared `GoldDivider(diamond:)` |
| 8 | Moon button under the capsule | centre (11.6u, 22u), Ø ≈ 8.8u, gold ring, cream crescent | shared `LessonRoundButton(compact:)` + 08 moon glyph |
| 9 | Question navigator: 10 circles «1…10» | y 28.2u, Ø ≈ 7.4u, step 11.4u, RTL (1 on the right), current = gold disc with dark number, others = dark green disc, green rim, cream number | code |
| 10 | Question card | x 4.9–211u, y 34.7–94.6u, gold rim ≈ 0.35u with glow, dark green glass fill, lattice band along its bottom (≈ 18u, fading up) | code, as the 08 card (`read*` tokens) + lattice R1 |
| 11 | Question badge «1» | lobed star, centre (201.4u, 41.7u) | asset R2 (`badge_line/fill`), as 08 |
| 12 | Question text | right edge 193.8u, y 41.5u, bold cream ≈ 3.9u | Readex Pro w600 `titleCream`; «(اختر أكثر من إجابة)» appended for multiple choice (Angular), lighter weight |
| 13 | Points pill «⭐ +10 نقطة» (top left of the card) | x 9.6–36.7u, y 38.2–45.7u, gold rim, dark fill, gold star | `LessonPill` + `ui/glyphs/star.svg` |
| 14 | Option rows | x 10.1–205.6u, h 9.5u, gap 2.8u, first at y 49.6u; radio Ø 6u on the right; text cream ≈ 3.7u | code; rows of 08 toolbar glass (`readTool*`) |
| 15 | Selected row (10b) | olive-gold fill, gold rim, radio = gold ring + gold dot | code |
| 16 | Third row cut by the bottom band | the list **scrolls under** the lattice band | see Q3 |
| 17 | «تأكيد الإجابة ←» | x 86–129.6u, y 81.2–91.4u, gold rim + glow, dark fill, bold cream | shared `SkipButton` look (07/08 skip pill) with a left arrow drawn in code |
| 18 | Diamond lines either side of the button | x 59–83u and 133–157.6u, y 86.3u | shared `GoldDivider` halves (diamond at the inner end) |
| 19 | Lattice corners top left / right, background | as 08 | shared 08 decor (`read*` background tones) |
| — | «تخطي» | **not in the reference** (Angular has it, top) | see Q2 |

## 2. Behaviour (from the Angular original)
- Content: `src/assets/data/content/assessments/assessment-lesson-1.json` (the only test with content: 10 questions,
  pass 70%). Types used: single choice (5), multiple choice (3), true/false (1), text input (1). The second test
  lesson (`assessment-lesson-2`) has no content → «قريبًا» (as 08 without content).
- Select an option (single: radio; multiple: several; true/false: صحيح / خطأ) → «تأكيد الإجابة» enabled → result.
- Correct: +10 points (+2 per streak answer after the second, max +10 bonus), success haptic; wrong: warning haptic,
  the correct answer shown. Feedback modal «إجابة صحيحة / خاطئة», points, streak «n إجابات متتالية», explanation,
  «متابعة». Then «السؤال التالي ←», on the last «إنهاء الاختبار 🏁».
- Navigator: answered circles show ✓ / ✕ (green / red); a question opens only after the previous one is answered.
- End: completion modal (score %, points, passed/not passed with the 70% threshold, auto-close countdown), then the
  results screen (score ring, correct / wrong / points, list of answers → details of each, «إعادة الاختبار»,
  «إنهاء الدرس»). «إنهاء الدرس» completes the lesson (screen 06 sequence).
- Progress of the capsule: answered / total.

## 3. Proposed motion (performance rules of `PERFORMANCE.md`)
- Entry as 08 (02 bar slides, header fades, card rises), circles pop in with a short stagger.
- Option tap: row fill and rim cross-fade 180 ms, radio dot scales in (spring), `Haptics.tick`.
- Confirm: correct → row turns green with a light sweep, check disc pops, points fly from the pill to the capsule,
  capsule fills by one step, circle «n» becomes ✓; wrong → row shakes lightly and turns red, the correct row lights up
  green, `Haptics.denied`. Feedback bar slides up from under the button (no full-screen blur).
- Next question: card content slides out to the right and in from the left (RTL), gold dot glides to the next circle.
- End: results card content cross-fades in, score ring fills with a running light, fill sound + `Haptics.lessonDone`
  when passed.
- One controller per element, `RepaintBoundary` around the background/decor, the header, the navigator and each row;
  no endless animation except the 02 pause pulse; no blur on live content.

## 4. Assets
Reused (library): arch R4, badge R2, lattice R1, mosque, crescent/star, star glyph, 02 bar, `LessonPill`,
`LessonRoundButton`, `SkipButton`, `GoldDivider`. **No new app art needed for the reference states.** Prompts (references
for the states that have none): T1 feedback correct/wrong, T2 results, T3 light theme (only if Q1 = yes).
`prompts/10-test-lesson/images-v1.txt`, attachments in `prompts/10-test-lesson/attach/`.

## 5. Questions for the owner
- **Q1 Light theme:** the reference has the moon but no light version. A) dark + light (08 light tokens, optional
  reference T3), B) dark only for now (moon hidden).
- **Q2 «تخطي»:** not in the reference; Angular has it. A) standard skip bottom left as 07/08 (it would sit on the card's
  lattice band, left of the diamond line), B) no skip in tests (a test should be answered), C) skip only in the pause menu.
- **Q3 Option list:** the reference shows 2 rows + a third cut under the band. A) as the reference: the list scrolls
  under the band (4 options: 2.5 visible), B) rows a little lower (h ≈ 8u, gap 2u) so 4 options fit without scrolling;
  6-option questions (حروف القلقلة) in two columns, C) short options always in two columns.
- **Q4 Feedback (no reference):** A) feedback bar inside the card in place of the button (prompt T1, no veil, light),
  B) Angular-style modal over a veil, C) only on the rows (green/red, check/✕) and «السؤال التالي», explanation under the
  question.
- **Q5 Navigation between questions:** A) as Angular: a question opens only after the previous one is answered, answered
  ones can be reviewed by tapping their circle, B) free order.
- **Q6 Capsule counter:** A) standard «n / N» answered questions (as 08: sentence n/N), B) «score / 100» as the reference.
- **Q7 End of the test:** A) results screen inside the card (prompt T2) with «إعادة الاختبار» / «إنهاء الدرس», then the 06
  completion, B) no results screen: completion sound/haptic and back to 06 (score in a toast). Failing (< 70%): the lesson
  is completed anyway (Angular) or must be retaken?
- **Q8 Sounds for correct / wrong:** the app has only `fill-sound.mp3`. A) haptics only for now, B) the owner supplies two
  short sounds.

Token conflicts (gold title T1, …) are **built with the reference values** and logged in `STYLE-CONFLICTS.md`, decided at
the end of the project (as 07/08/11).
