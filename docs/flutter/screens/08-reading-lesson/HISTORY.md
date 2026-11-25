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

## 2. Owner answers and assets (2026-11-25)
- Answers: Q1 dark **and** light (moon switches); Q2, Q3, Q4 «standard» (skip bottom left as 07; capsule = sentence n/N
  as 02; completion as Angular/07: the last sentence completes the lesson by itself after 1.5 s); Q5 B (reference R3);
  Q6 «A» menu as the reference (size, spacing), fonts later; Q9 badge from ChatGPT; Q10 swipe yes. Q7 (tajweed colours) and
  Q8 (lattice) not understood: built as the reference (text all cream; one new lattice tile).
- Owner's zip: R1 lattice, R2 badge, R3 screen with the panel and the menu open (`reference-panel.png`). Processing
  `tools/assets/reading_lesson_assets.py` (see `ASSETS.md`). R3 shows the panel **pushing** the content, not covering it.

## 3. Build v1–v6 and verification (2026-11-25)
- Code: `lib/lessons/reading_lesson_page.dart` (`ReadingLessonPage`, `readingLessonRoute`, `ReadMetrics`),
  `reading_data.dart` (content loader, the 6 Angular rules, session preferences); `lesson_page.dart` routes
  `LessonType.read` here. Light theme through the whole lesson chrome: `LessonShell(light:)` (capsule, pause, menu
  buttons), `LessonPill`/`LessonRoundButton`/`SkipButton(light:)`. Review aids `?readTheme=light&verse=3&rules=1&fontMenu=1`
  with `?lessons=0,1&openLesson=0`. Scripts `reading-capture.js`, `reading-verify.py`, `reading-demo.js`.
- Arch fit: `header_arch.svg` correlated on the reference's gold line (F1 0.79 at 119.4×26.9u, top −0.35u); the upper
  part overlaps, the lower lobes are ≈ 6u wider/lower (prompt R4 for an exact arch). The 07 frame V2 fits worse.
- Verification (reference px at 1842×854, capture v6, `reading-verify.py`): title (0,0,−5,+10: descender of the font),
  verse (−3,+4,−3,+1), rules pill (0,0,0,0), counter (−1,+2,+3,+3), card rim (+1,+1,−3,0), badge (+4,+1,−4,−1), badge
  number (0,+2,0,+1), book (0,0,0,−4), divider (+4,−2,−8,+2), active dot (+3,0,+2,0), moon/‹/› sides and bottoms within
  3 px (their top edge is darker than the reference's, so the gold mask starts 9–11 px lower: the ring gradient, not the
  size). Lattice contrast (p97 − median): card band 13/44 (ref) vs 54/59 in v1 → fade moved down and opacity lowered in v2;
  corners and toolbar patches lowered the same way. Deliberate: «تخطي» bottom left (standard), mosque/crescent boxes
  polluted by the arch tail (checked on zoomed crops instead).
- Zoomed side-by-side found: ⓘ on the wrong side of the label, chevrons dimmed at the ends (the reference shows them lit:
  now always lit, a tap past the end gives the «denied» haptic), divider too short with a big diamond (78u, diamond 1.5u),
  verse 4.5% small, rings too orange with a strong glow (now thin olive → light gold ring, `compact`), counter rim
  cream-gold, «A» disc lighter; light theme: pause disc cream (no gold glass), ⓘ dark brown with a white «i».
- Panel: the text no longer re-wraps when the panel narrows the card (laid out at full width, scaled), rule descriptions
  on one line (the selected rule shows all of it), long titles shrink.
- Tests: `flutter analyze` clean, `flutter test` 11/11 (new: sentences, moon, rules panel, «تخطي» completes).
- Captures `capture-v6-*` (reference size and phone 915×412), comparison `compare-v6-phone.jpg`, demo `demo-v6-phone.mp4`.
- Differences left: «A» and the verse number are serif in the reference (Readex here, R7), «الله» ligature, arch lower
  lobes (R4 asset), the 02 pause button keeps its approved style (the reference's is a heavier gold ring).

## 4. v7: owner's arch, crescent and star on the reference, tajweed colours (2026-11-25)
- Owner on v6: tajweed colours for the marked words; crescent and star not positioned as the reference («get closer to
  the reference, at least for the positions»); colours standard with the app; arch R4 delivered.
- Arch R4 (`ui/reading/arch.webp`): correlation on the reference's line F1 0.88 (03 arch: 0.79), 102.1×21.5u, top 0.94u.
- Crescent/star: the reference's star sits apart in the crescent's opening, the 03 asset has it high and close: the SVG
  split into `crescent.svg` + `star.svg`, each fitted on the reference (IoU 0.85 / 0.93). Check v7: crescent left/top/bottom
  exact (1345, 82, 159), horn tips 18 px further right (shape of the asset); star (1392–1423 × 101–130) vs (1392–1423 ×
  100–131). The dark tone filter on the crescent removed (app colours).
- Tajweed colours: marks parsed from the data; 38/45 indices are wrong, so the mark text is searched in the sentence;
  colours (provisional, classic mushaf scheme) for idgham/ikhfa/iqlab/ghunnah/shaddah (green), qalqalah (blue), madd (red);
  topic marks keep the text colour. Rules panel dots use the same colours (other rules: app gold).
- Mosque checked by landmarks on the zoomed crop (minaret x ≈ 502, dome 525–610 as the reference); the IoU fit is not
  reliable there (the green mask also takes the capsule and the arch).
- Divider 72u. Tests 11/11. Captures `capture-v7-*`.

- APK 1.0.382 (v7), after 16 build attempts (Maven Central 429).

## 5. v8: the owner's tajweed colour wheel (2026-11-25)
- Owner on v7: «why green? I did not understand which» → sentence 2 of «أحكام التجويد الرئيسية» has two marks, idgham and
  a generic shadda; v7 had put the shadda in the ghunna green too, so the whole sentence was green. Owner sent the wheel
  «قواعد ألوان التجويد» (stored in `docs/design-assets/reading-lesson/`), sampled into `TajweedColors` (10 groups, table in
  `DESIGN-SYSTEM.md`). Now only the idgham part is green; izhar keeps the text ink (black on the wheel).
- Owner: token conflicts at the end of the project (one choice everywhere); critic later.
- Tests 11/11.

## 6. v9: lesson text in its own colour (2026-11-25)
- Owner: the wheel colours are for the ayat, not for the lessons; lessons keep their colour. The marks of the lesson data are
  no longer coloured (still parsed, with the text lookup, for later). Wheel kept in `DESIGN-SYSTEM.md` («ayat only»).

- APK 1.0.385 (v9).

## 7. v10: owner's phone test of 1.0.385 (2026-11-25)
- Light «A» hard to see → dark ink (`readLInk`), as the moon and the chevrons.
- Capsule rim around «3/8» a little more visible: shared 02 bar, rim 0.18u `cardRimBottom` (was 0.12u `cardRimTop`).
- Line spacing control removed (it collided with large text sizes); menu with the text size only (17.6u high), sentences
  at a fixed line height 1.4. Capture `capture-v10-menu-light-phone.png`.

