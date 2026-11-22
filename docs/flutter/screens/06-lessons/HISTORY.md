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

## 3. Owner: two trials (2026-11-22)
- Owner: build **two trials**, one as the ChatGPT reference (look **A**, `ref`) and one as the original Angular
  screen, improved (look **B**, `orig`); reuse the original decoration (`src/assets/images/islamic-pattern-2-dark.svg`:
  an SVG wrapping a gold PNG pattern; extracted to `docs/design-assets/lessons/angular-original/`, app copy
  `assets/ui/decor/angular_pattern_2.webp`, 700 px tiles turned 50°, 6%). The 9 plan questions were not answered:
  built with the proposals (unit title, green padlock + veil, ✓ on done, placeholder lesson page, course 02 mapping,
  no duration in A, no sound on lessons) and listed for the owner.
- Code `lib/lessons/`: `lessons_screen.dart` (both looks, review chip «A ChatGPT / B الأصلي» on the screen, custom
  drag track, entry, locked tap shake + toast, completion sequence, last lesson → `unitCompleted`),
  `lesson_card.dart` (card per look, rim painter with the running light, sparkles, veil + padlock),
  `lesson_page.dart` (placeholder lesson with «أكملت الدرس»), `lesson_data.dart` + generated
  `lesson_data_gen.dart` (`tools/flutter-review/gen_lesson_data.py`, course 02 aliases). Shared background widgets
  moved from screen 05 to `lib/core/screen_decor.dart` (no visual change).
- Screen 05: `_openLessons` opens screen 06 (toast removed); back from a lesson the ring catches up with the lessons
  done (fill, ticks, half line at 50%).
- Look B: small glass cards (44×31u), lesson in progress filled gold with dark text (Angular), done = 15% gold tint
  + ✓, duration with a drawn clock, type icon added, diamonds on the connectors, cream title + glass back button +
  divider; the first lessons stay on screen (no glide while all cards fit).
- Found: when screen 06 is opened by a review link nobody awaits its route, so the last lesson did not start the
  unit completion → screen 06 sets `unitCompleted` itself. The placeholder page had left-aligned text
  (`CrossAxisAlignment.end` is left in RTL) → `start`.
- Review aids: `?lessons=<course>,<unit>`, `?lessonDone=<k>`, `?completeLesson=<k>`, `?lessonsStyle=orig`.
  Scripts: `lessons-capture.js`, `lessons-complete-frames.js`, `lessons-demo.js`.
- Files: captures `capture-v2-{ref,orig}[-done1|-phone].png`, `compare-v1.jpg`, `completion-frames-{ref,orig}-v1.jpg`,
  `demo-{ref,orig}-v1.mp4`. Widget test: finishing the 3 lessons of unit 1 completes it and opens unit 2's lessons.

## 4. Critic loop (2026-11-22)
- Critic v1 (`critic-v1.md`, on v2 captures): look A **6.8** (code 7.6, assets 4), look B **6.0**. High: title
  divider 11u off the title axis and too short (the SVG kept its aspect). Medium: no inner gold glow, teal faint
  card pattern, mosque too dark, arrow twice as heavy, done card sliver at the rail, thin flat locked rim; look B:
  text washed out at the flash and during unlock, done card pushed under the rail.
- v3 fixes: divider drawn in code (62.7u, open diamond), inner glow 3u, locked rim 0.47u gradient + hairline, olive
  pattern, sage mosque, arrow 3.2×2.8u stroke 0.35u, card radius 5.6u, arch and emblem resized, path faded at the left
  edge and before the rail; look B: gold fill/ink switch at mid-fill, ✓ in gold on the dark pill, cards stay at the
  start while they fit (`_pageFor`).
- Critic v2 (`critic-v2.md`): look A **7.3** (code 8.1), look B **6.5**; remaining medium: mosque flat tint and hard
  bottom edge (the fade was on a box taller than the image), done-card sliver, pattern contrast.
- v4 fixes: mosque gradient tint (#7D8E54 → #2F5331) and fade on the image box, cards dropped once only their edge
  is left before the rail, fade 6u, pattern #5F8541 stronger, pill number/✓ cross-fade overlapped, icon ink on the
  gold card switches with the text.
- APK **1.0.290** (the shallow clone first gave 1.0.5: fetch the branch history before `build-apk.sh`, now in
  LESSONS-LEARNED). Demos `demo-ref-v2.mp4`, `demo-orig-v2.mp4` (full loop: locked tap, 3 lessons, unit completion,
  next unit's lessons open). Comparison `compare-v2.jpg`.
- Critic v3 (`critic-v3.md`, on v4): **no high/medium code item left**. Look A **7.5** (code 8.4; assets 4 until
  L1–L5), look B **6.6**. Low items left (mosque ground tone, pattern cell 9.5u vs 8.2u, line step at the rail, …).
  Sent to the owner: `compare-v2.jpg`, completion frames v2, demos v2, APK 1.0.290.

## 5. Look B larger (owner, 2026-11-22)
- Owner: look B cards and title larger, about ×1.35–1.40; show the screens before implementing. Review parameter
  `?origScale=<k>` (default 1, unchanged): card, text, pill, icons, gaps and title/back button scale; the first card
  stays 8u from the rail. Previews `orig-scale-preview-pc.jpg`, `orig-scale-preview-phone.jpg` (×1, ×1.35, ×1.4,
  lesson 1 done). At ×1.35/×1.4 two cards and a half fit: the third fades out at the left edge.
- Owner chose **×1.4** → default `origScale = 1.4`. Seen in the demo: long titles («القواعد الأساسية للتلاوة الصحيحة»)
  were cut with «…» → they now shrink to fit (`capture-v5-orig-phone-unit2.png`). Captures `capture-v5-*`, frames
  `completion-frames-orig-v3.jpg`, demo `demo-orig-v3.mp4` (demo script updated to the ×1.4 geometry).
