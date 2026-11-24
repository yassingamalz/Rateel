# Screen 02 (shared lesson top bar): history of the work

Branch `flutter/02-lesson-bar`, created on 2026-11-24 from `master` (04c9513, screens 03–06 merged).
Plan: `../02-lesson-bar.md`. Decisions: `../../DECISIONS.md`.

## 0. Starting point (2026-11-24)
- `docs/flutter/SCREENS.md`, `STYLE-CONFLICTS.md` and the new `NEXT-SESSION.md` were only on the previous session's
  branch `ccr-d42db0d3-2ls4ag` (3 doc commits not in `master`): merged into this branch (DECISIONS.md conflict:
  both sides kept in date order).

## 1. Angular original and proposal (2026-11-24)
- Angular app run in the container (`npm ci --ignore-scripts`, `npx ng serve --port 4300`); lesson routes
  `/courses/01-tajweed-fundamentals/units/intro-tajweed/lessons/intro-lesson-1` (video) and
  `…/units/pronunciation-practice/lessons/pronunciation-lesson-1` (practice); progress preset in `localStorage`
  (`tajweed_lesson_<course>_<unit>_<lesson>` = `{progress: 42, expiresAt, version: '1.0.0', …}`).
  Script `tools/flutter-review/lesson-bar-angular-capture.js`.
- Found: the menu has **two** items, back **and restart** (SCREENS.md said only back); restart resets the position,
  not the progress. Practice lessons draw **two bars** (lesson-details + interactive-lesson). The bar is 200×24 px and
  hard to read over a video.
- Sheet `angular-original.jpg`; proposal mockup (HTML with the app's tokens, over a capture of the current placeholder
  lesson page) `proposal-v1.jpg`: option A capsule, option B wide line, menu open, phone 915×412.
  Tools: `lesson-bar-mockup.html` + `lesson-bar-mockup.js`, sheet `lesson-bar-sheet.py`.
- 7 questions to the owner (plan §3). Waiting for the answers before building.

## 2. Owner answers (round 1) and proposal v2 (2026-11-24)
- Owner: **option A**, but the **whole capsule fills** (no inner track/capsule); **side rail hidden** during the lesson
  (full screen as Angular); counter = **step number «2/16»** (current step / steps of the lesson), not a percentage;
  **restart kept**; motion of question 7 approved. Asked to see: the full-fill capsule, **two veil examples**
  (question 5), the **code-drawn icons** (question 6).
- Mockup v2 `proposal-v2.jpg`: capsule rim `cardRimTop #2F6954`, dark card-gradient fill; gold fill clipped by the
  capsule, straight leading edge with a soft light gradient (2.2u), top sheen; the number is cream over the dark part
  and `countText #132C1A` over the gold (split at the fill edge); 2/16, 9/16, 16/16; veil strong (45% + blur + 98%)
  vs light (12%, no blur); icons pause / play / restart / back in the 06 arrow stroke. Phone 915×412.

## 3. Build v1 and critic loop (2026-11-24)
- Owner approved v2 with: button and bar **slightly larger** (button 9u, capsule 41×6.2u, number 3.2u), **strong veil**,
  **code-drawn icons**. Mockup v3 at the new size = critic reference (`reference/`, `tools/flutter-review/lesson-bar-mockup-v3.*`).
- Code: `lib/lessons/lesson_shell.dart` (`LessonShell`, `LessonTopBar`, `lessonRoute`), `lesson_page.dart` now a demo
  lesson of `placeholderSteps` (8; `?steps=16`) with «الخطوة التالية» / «أكملت الدرس». The lesson route is pushed on the
  **root navigator** (rail hidden). Captures: `tools/flutter-review/lesson-bar-capture.js` → `capture-v<k>-*.png`.
- Found while building: a route above the app's Scaffold has no Material → yellow double underlines under every text
  (fixed with a transparent `Material` in `lessonRoute`); blurring + scaling the content showed grey edges (fixed with a
  base colour under the content and `TileMode.clamp`); `Path.combine` in a painter darkened the whole capsule on the
  web build → even-odd paths instead.
- Critic v1 (`critic-v1.md`, on v1): **7.2** (look 7.0, behaviour 7.5). High: glass buttons 3× too bright (the
  BoxShadow glow was drawn under the translucent fill). Medium: no static halo on the gold button, capsule inner shadow
  2.5u instead of 0.6u, no gold glow into the empty part, rim twice too heavy, completion race (double pop), Android back
  with hidden controls, 37 dp tap targets on the phone.
- v2 fixes: `_GlassPainter` (glow outside the circle only, radial radius 0.707, cross-fade glass → gold, static 1.2u
  halo, pulse alpha 0.7), capsule inset shadow 0.2u/0.25u, gold glow 0.8u, rim 0.12u, sheen relative to the fill,
  leading light also at 16/16, number w500 without lift; controls and back locked during the completion, `_leave()`
  pops once; back does nothing with hidden controls; tap area ≥ 48 dp; haptic on the veil tap.
- Conflict C1 for the owner: the 04 close button and the 06 back button have the same over-bright glass as 02 v1.
- Critic v2 (`critic-v2.md`, on v2): **8.6** (look 8.5, behaviour 8.8), no high. New medium: N1 the inset shadow was
  drawn over the gold (olive line at the top of the fill); N2 the 0.12u rim split over two pixel rows (too faint).
- v3 fixes: inset shadow drawn before the glow and the gold; capsule on whole pixels with a rim of max(1 px, 0.12u);
  the controls lock as soon as the lesson starts finishing (`LessonShellState.lock()`).
- Critic v3 (`critic-v3.md`, on v3): **9.2** (look 9.3, behaviour 9.2), **no high/medium item left**. Lows kept: capsule
  1 px larger from the rounding, empty-glass inset shade 3 px vs 5 px, number slightly heavier, background a bit darker
  under the veil, completion exit 500 ms (Angular 300 ms), restart closes the menu (Angular keeps it open), 4.4 dp overlap
  of neighbouring tap areas on the phone.
- Comparison `compare-v3.jpg`, demo `demo-v3.mp4` (`tools/flutter-review/lesson-bar-demo.js`), **APK 1.0.327**.
- For the owner: conflict C1 (04 close / 06 back buttons brighter than the token, same cause as v1 #1).

## 4. Owner phone test of APK 1.0.327 (2026-11-24)
- Owner screenshot `owner-phone-1.0.327.jpg`: the buttons (and the capsule) must become **much larger** on the phone;
  asked to see the Angular original at phone size and examples to choose from.
- Sheet `size-options-phone.jpg` (915×412): Angular original (64 px button = 15.5u on a 412 dp phone, bar 200×24),
  A current (button 9u, capsule 41×6.2u), B +33% (12u, 52×8.2u, number 4.2u), C as Angular (15.5u, 62×10u, number
  5.2u). Mockups `tools/flutter-review/lesson-bar-size/`. Waiting for the owner's choice.
- Owner: the buttons **as Angular** (much larger), the bar only **slightly** larger; and **as Angular, the bar disappears
  while the menu is open** (in Angular the menu veil covers it). v4: button 15.5u (64 px on a 412 dp phone), gaps 2.8u,
  halo and pulse scaled with the button, capsule 46×7u, number 3.6u; the capsule fades out with the menu (300 ms) and
  back in on resume. Captures `capture-v4-*`, sheet `compare-v4-phone.jpg`.

## 5. Approval (2026-11-24)
- Owner: sizes v4 fine, **screen 02 approved** (APK 1.0.330). Conflict C1: keep the 04/06 buttons as they are.
- v4 was not re-critiqued (owner rule from now on: ask before launching the critic).
- Left as low items: restart closes the menu (Angular keeps it open), completion exit 500 ms (Angular 300 ms).
- PR to `master` and merge.

## 6. Pause-menu motion as Simply Piano (2026-11-24, branch `flutter/02-menu-motion`)
- Owner, while testing screen 07, sent a Simply Piano screen recording: the menu buttons should animate like it; done on
  this separate branch from `master`, to be merged into 07 afterwards (owner).
- Seen in the recording (frames at 8 fps): the pause glyph turns into play, the two side buttons slide out from under the
  pause button (the farther one a little later) while fading in, their icons turning into place (the restart arrow spins,
  the menu lines rotate from slanted to straight); closing plays it backwards.
- Built (`lib/lessons/lesson_shell.dart`): `_PausePlayPainter` folds the two bars into the triangle (each bar a quad whose
  corners move onto one half of the triangle, colour cream → dark on gold, ends drawn with the original glyphs); items
  staggered (second item 12% later), opacity and slide on the same 300 ms, glyph rotation from −180° (restart) / −60°
  (back) to 0. Gold, halo and pulse unchanged.
- Review: `tools/flutter-review/lesson-bar-menu-frames.js` (frames at `?slow=12`), `lesson-bar-menu-demo.js` (video at
  `?slow=3`): `menu-motion-v1-slow3.mp4`.
- Owner (2026-11-24, testing 07): the capsule fills **from the left** (was from the right, RTL); the leading light sits at
  the right end of the gold and the light at 100% runs left → right.
