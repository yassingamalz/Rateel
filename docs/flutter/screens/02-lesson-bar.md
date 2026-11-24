# Screen 02: shared lesson top bar (plan, v1, 2026-11-24)

Branch `flutter/02-lesson-bar` (from `master` + the consolidation docs of `ccr-d42db0d3-2ls4ag`).
No ChatGPT reference: the source of truth is the Angular original. History: `02-lesson-bar/HISTORY.md`.

## 1. The Angular original (captured, `02-lesson-bar/angular-original.jpg`)
Source: `src/app/features/lessons/lesson-details/lesson-details.component.{html,scss,ts}` and the bar of
`interactive-lesson/interactive-lesson.component.{html,scss}`. Captured with `ng serve` at 1844×853 and 915×412
(`tools/flutter-review/lesson-bar-angular-capture.js`).

| Part | Angular |
|---|---|
| Progress | top-left (20 px, 20 px), **200×24 px** pill, track `rgba(31,64,55,.2)`, fill gradient accent dark → glow with a moving glow (2 s loop), width transition 300 ms; text **«n/100»** centred on the bar, light, 500, glow shadow. Fill grows from the right (RTL). |
| Pause button | top-right (20 px, 30 px), **64 px** circle, white 15% fill, white pause glyph 30 px; hover 25% + scale 1.05 |
| Menu open | the button turns **gold** (`#DAA520`) with a **pulse** ring (0 → 15 px, 2 s loop) and shows **play**; two more 64 px circles slide in from the right (20 px, 300 ms): **back** (← arrow) and **restart** (↻). Gap 12 px. |
| Content under the menu | veil `rgba(11,28,23,.5)` + **blur 5 px**, stronger vignette, content **scale 0.98, brightness 0.8** (300 ms) |
| Back | saves the state, page **slides out to the right** (500 ms ease-in), then returns to the lesson list |
| Restart | resets the lesson position (video time, verse, scroll); progress stays |
| Entry | page slides down from the top (500 ms ease-out) |
| Completion | progress → 100, 100 ms, exit slide (300 ms), back to the list with `completedLessonId` (assessment: only on explicit request) |
| Hidden | `hideControls` (assessment review mode) hides bar and button |
| Practice lessons | a **second** bar of `interactive-lesson` (full width, 8 px, «n%») is drawn under the first one: duplicate |

Seen in the captures: the 200×24 bar gets lost over a video (low contrast), the text sits half on the fill.

## 2. Proposal (mockup `02-lesson-bar/proposal-v1.jpg`, source `tools/flutter-review/lesson-bar-mockup.html`)
Same structure and behaviour; style from the confirmed tokens (u = 1% of the screen height):
- **Pause button**: the glass button token (as the 06 back button and the side-nav close): 7.5u circle, 0.2u
  `ringLine #D8C35A`, radial gold 8% → 24%, outer glow gold 22% blur 2u; pause glyph `iconCream #FCF1D0`.
  Top 3u, right 3u.
- **Menu open**: button filled gold (`badgeTop → amber #E2A51E`, rim `goldHighlight`), play glyph `countText #132C1A`,
  pulse ring gold as in Angular; «back» (→, the 06 arrow) and «restart» (↻) as glass buttons, 1.5u apart, slide in
  from the button (300 ms); content veil + blur + scale 0.98.
- **Option A, capsule** (closer to the original): glass capsule 34×5u at top 4.2u left 3u (rim `rowRim #245843`
  0.23u, dark fill, card shadow), inner track, **gold fill** (`#FFD95A → amberPill #EDB120 → #D9A11C`) growing from
  the right, light head, top sheen, slow glow loop; «42/100» centred, `label` 2.3u w500 with a dark shadow.
- **Option B, wide line**: 1.3u line from the left margin to the button (track `progressTrack`), gold fill with a
  glowing head, counter in a gold pill under its left end; the line shortens when the menu opens.
- One bar only in every lesson type (the practice lesson's second bar is dropped).
- Motion: entry slide down 500 ms, exit (back / completion) slide out 500 ms as in Angular; fill width 300 ms;
  haptic `tap` on the buttons; at 100% a light sweep along the bar + `Haptics.milestone`.
- Widget API: `LessonTopBar(progress: 0..1, paused, onPauseChanged, onBack, onRestart, visible)`; the lesson page owns
  the progress and the pause state (the bar never pauses media itself).

## 3. Questions for the owner (v1)
1. Option **A** (capsule) or **B** (wide line)?
2. Side rail during a lesson: **hidden** (full screen, as Angular; proposed) or kept?
3. Counter: «42/100» (lesson-details) or «42%» (interactive)? Western digits as the rest of the app?
4. Keep **restart** in the menu (Angular) next to back?
5. Veil under the open menu: as Angular (45% + blur, content 98%) or the side-nav token (12% black, 🟡)?
6. Icons pause / play / restart drawn **in code** with the stroke of the approved 06 arrow, or ChatGPT icons
   (prompt LB1, `prompts/02-lesson-bar/images-v1.txt`)?
7. Motion: entry/exit as Angular + light sweep and haptic at 100%: OK?

## 4. Token notes
- Gold fill of the bar: `amberPill #EDB120` (✅) at the centre; `progressFill #EBB335` (03, 🟡) not used
  (STYLE-CONFLICTS C4 proposes the same). Angular's active button gold `#DAA520` → token `amber #E2A51E`.
- Veil: conflicts with the 12% dimming token (🟡) → question 5.
