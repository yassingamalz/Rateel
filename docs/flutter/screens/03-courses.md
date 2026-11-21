# Screen 03: courses / learning paths (المسارات التعليمية)

Status: 🟡 v4 with the owner's assets; critic v3 (no exclusions) running; open owner questions below
Branch: `flutter/03-courses` (contains the approved side navigation)
Reference: `docs/flutter/screens/03-courses/reference.webp` (1847×851, glassy gamified, dark)
Code: `app_flutter/lib/courses/` (`courses_screen.dart`, `course_card.dart`, `course_data.dart`)
Data: the 12 courses of `src/assets/data/courses.json` (Angular app), demo progress 30% on course 1.

## Layout (landscape, RTL), measured in u = 1% of the height (u = 8.51 px on the reference)
The right rail of the reference is **not** built: the approved side navigation (screen 04, style C, 6 items)
replaces it. Horizontal positions are measured from the right edge of the content (left edge of the rail).

| Zone | Content | Geometry |
|---|---|---|
| Header | thin gold arch, gold open-book emblem on the apex, title «المسارات التعليمية», gold divider with a diamond; mosque silhouette (left), crescent and star (right), lattice corners top left / top right | arch centre 95.2u from the content edge; emblem centre y 11u; title centre y 23.4u, size 9.15u, weight 600; divider y 31.4u, 56u wide |
| Path | horizontal track of course cards, right to left, joined by a 3 px gold line with a glowing node just outside each card | card 72.4u × 50u, focused card ×1.016, pitch 82.7u, first card centre 43.8u from the content edge, centre y 63.8u; line at card centre + 2.7u |

### Course card
- Glass panel: radius 3.5u, vertical fill `cardTop → cardMid → cardBottom`, drop shadow, faint emerald star
  lattice along the bottom (shared `star_tile.svg`, tinted).
- **Active**: gold double rim (`goldRim` 1.4 px + `goldHighlight` 2 px), breathing gold glow; level pill
  «مستوى مبتدئ» with a star; course icon top right; title 5.3u; gold rule; 2-line description 3.4u;
  play button 8.1u, progress bar 40.4u × 1.4u, percentage.
- **Locked**: emerald rim (`cardRim`), lock disc 7.8u top right, icon at the top centre, title, dim rule,
  description; no progress row.

## Code vs assets
Code: background, cards (glass, rims, glow, shadows), texts, divider, pill, play triangle, progress bar, path
line and nodes, toast, motion.

All assets delivered by the owner (2026-11-20) and placed in v4; list and evaluation in `ASSETS.md`
("Courses (screen 03)"). Prompts P1–P6 are fulfilled.

Prompts: `docs/flutter/prompts/03-courses/images-v1.txt` (also pasted in the chat).
Critic: `03-courses/critic-v1.md`, `critic-v2.md`; comparisons `compare-v1.jpg`, `compare-v2.jpg`; demo `demo-v3.mp4`;
completion frames `completion-frames-v3.jpg`; `compare-v3.jpg` (after critic v2 fixes). Critic v1/v2 ran with an exclusion list (see `CRITIC.md`): to redo without exclusions.

Course icons (owner may change): 02 head with sound waves from the nose (as in the reference) · 03 head
cross-section with articulation points · 04 small circle with a flowing ribbon · 05 closed lips · 06 short wave
· 07 two long waves · 08 wave turning into an arrow · 09 wave ending in a stop dot · 10 wave held by a bar ·
11 echo arcs · 12 crown over an open book.

## Motion and UX (built in v1, to confirm)
- **Entry** (1.5 s): header fades and settles from above; cards slide in from the right one after the other
  (80 ms stagger); the path line draws itself right to left and the nodes light up; the progress bar fills.
- **Scroll**: horizontal drag (touch and mouse) snapping card by card (PageView); the focused card is ×1.016.
- **Active card**: slow breathing glow on the gold rim (2 s each way).
- **Tap**: press-down scale 0.97 and a haptic tick. Active card → toast «الوحدات: قريبًا» until screen 05
  exists (then a morph into the units screen). Locked card → the lock shakes, light haptic, toast
  «أكمل «<previous course>» أولًا لفتح هذه الدورة».
- A horizontal drag on the cards never opens the side menu (the menu swipe starts on the rail only).
- **Progress always starts at 0%** (owner, 2026-11-20; the 30% of the reference was only an example).
- **Line between two courses (owner, 2026-11-20):** a dim track with a node **in the middle**. The first half
  (from the course to the node) lights up gold when the course reaches **50%**; the node pops and glows. The
  second half lights up when the course is **completed**, and the light reaches the next course.
- **Course completion (owner, 2026-11-20, as in the original HTML/Angular app):** when the last lesson of a
  course ends, the lesson, unit and course screens close by themselves (lesson → unit → course → this
  screen). Here, automatically:
  1. the path is on the finished course; the bar fills to 50% (one haptic tick every 10%);
  2. the first half of the line lights up to the node, the node pops (haptic "milestone") — skipped if the
     course was already past 50%;
  3. the bar fills to 100% (ticks), haptic "milestone";
  4. the light runs along the second half to the next course (ticks), haptic "unlock" (heavy);
  5. the next card's lock pops, rim emerald → gold with a flash, locked layout out, course layout in;
  6. the path glides to the new course, haptic "success" (two light taps); the new course starts breathing.
  Hook for the lesson flow: `courseCompleted` (`ValueNotifier<int?>` in `course_data.dart`).
  Until screens 05–07 exist: **long press on the course in progress** plays it (demo), `?complete=0` on web.
- **Haptics vocabulary** (`lib/core/haptics.dart`, app-wide): `tick` (progress step), `tap` (card),
  `milestone` (50%, 100%), `unlock` (next course opens), `success` (double light tap), `denied` (locked card:
  firm tap + soft echo).

## Open points for the owner
1. **Colours vs the central tokens (owner, 2026-11-21: to do, one style for the whole app).** The screen-03
   colours (`RateelColors` section "Screen 03", `DESIGN-SYSTEM.md`) will be compared with the confirmed
   tokens and unified. Conflicts listed in critic-v3 (C1–C5).
2. **Course 03 icon** (head cross-section) reads weakly: to redo later with ChatGPT (owner, 2026-11-21).
