# Screen 24: end of lesson (points, stars, continue)

Branch `flutter/24-end-of-lesson` from `master` (2026-11-27). Shared by **every lesson type** (video 07, reading 08,
test 10, listening 22, later guided 15–21 and practice 09), like the top bar of screen 02. History: `24-end-of-lesson/HISTORY.md`.

## Sources
- **No ChatGPT reference exists.** Reference prompts 24-A (dark) and 24-B (light): `prompts/24-end-of-lesson/reference-v1.txt`,
  generated from the app screenshots (`app-references/`, refreshed 2026-11-27). Waiting for the owner's images.
- Angular originals (layout idea only):
  - `interactive-lesson/components/completion-screen`: overlay fading in (500 ms), particles, ✓ circle and
    «أحسنت! أكملت الدرس». Shown at the end of every interactive lesson.
  - `assessment/components/completion-modal` (`24-end-of-lesson/angular-completion-modal.jpg`): veil, card with graduation
    cap / ✓, title «مبروك» / «انتهى الاختبار», score %, «n نقطة» with a star, pass/fail message, auto-close countdown
    (6 s passed, 8 s failed), 30 / 15 gold-green particles flying out, success / warning vibration, items staggered 100 ms.
- Already in the app: the end of the lesson today = 02 capsule full + light sweep (`LessonShell.celebrate`), then the page
  pops and screen 06 plays the lesson completion (rim light, fill sound, `Haptics.lessonDone`, next lesson unlocks and opens
  by itself after 0.8 s). Screen 10 has its own results in the card (screen 25); its end popup was removed by the owner
  (designs in `10-test-lesson/end-popup-variants-v6.jpg`). Screen 22 counts +10 per right answer but shows them nowhere
  at the end (`BACKLOG.md`).

## Visual plan v1 (proposal, waiting for the reference and the owner's yes)
- **Where:** an overlay of the lesson page itself, built once in `LessonShell` (`LessonShell.finish(result)`), so every
  lesson type gets it with one call: after the 02 sweep the lesson dims under the `lessonVeil` (no blur: performance rule,
  the content may be a WebView on 07) and the end card rises in the centre. The 02 capsule stays visible and full; the
  pause button is hidden.
- **Card:** the lesson gold card (`GoldCardPainter`, 08/22 style), ~60% of the width, lattice at the bottom.
- **Content, top to bottom:** three stars on an arc (middle one larger), title «أحسنت، أكملت الدرس» + `GoldDivider(diamond:)`,
  row of up to three stat tiles in the 10 results style (points with the gold star coin `ui/test/star_coin_gold.webp`;
  right answers «n / N» when the lesson had questions; the streak day with the 10 flame glyph), buttons «متابعة» (main) and
  «إعادة الدرس» (secondary), in the 10 button styles (dark: outlined luminous rim; light: filled, white text).
- **Motion:** veil 300 ms; card rises 30 px + fades (600 ms, delay 150 ms, Angular); stars pop one after another
  (scale 0 → 1.15 → 1, 120 ms apart) with a tick haptic each and a short gold burst of sparkles (painter, one controller,
  stops at the end: no endless animation); points count up from 0 with the coin; tiles and buttons staggered 100 ms;
  sound `Sounds.passed` once, `Haptics.success`.
- **Continue:** «متابعة» → the page pops with `done = true` and screen 06 plays its lesson completion as today;
  «إعادة الدرس» → the lesson restarts from step 1 (the 02 «restart»). Android back = «متابعة».
- **Light theme:** follows the lesson's theme (08 / 10 / 22 light), tokens `lessonL*` / `testL*`.
- **Performance:** `RepaintBoundary` around the veiled lesson (a still layer while the card animates), the sparkles and
  the card; one controller per small `AnimatedBuilder`; nothing runs after the entry.
- **Text 110%:** checked with `?textScale=1.1`; the card grows with the text (no fixed art).

## Questions for the owner (Q1–Q7)
1. **Overlay over the lesson** (proposal) or a separate full screen after the lesson?
2. **Stars:** lessons without questions (video, reading) always 3 stars at the end; lessons with questions (listening,
   guided quiz): 3 = all right, 2 = at least 70%, 1 = below; test: 3 ≥ 90%, 2 ≥ 70% (pass), the failed test does not reach
   24 (it keeps the next lesson locked, owner 2026-11-26). OK?
3. **Points:** video / reading +10 for finishing; listening +10 per right answer (as now); test = the points of its results.
   OK, or other values?
4. **Test (10):** show 24 after «إنهاء الدرس» of the results (consistent with the other lessons, the score is already in
   the results), or skip 24 for tests?
5. **No auto-close** (Angular closed by itself after 6 s): the learner taps «متابعة». OK?
6. **«إعادة الدرس»** as a second button: keep it, or only «متابعة»?
7. **Streak tile** (day of the daily streak of 12, mock today): show it, or only points and answers?

## Assets
- Reused: gold star coin, flame glyph (10), gold card, divider, lattice, 02 bar, buttons of 10.
- **Stars:** the app has only the small star glyph (`ui/glyphs/star.svg`) and the 3D star CR-11 (SVG filter, unusable).
  Three large polished stars (earned / not earned) will likely need a ChatGPT asset: prompt written **after** the reference
  arrives, matching the stars it shows.
