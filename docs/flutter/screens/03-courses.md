# Screen 03: courses / learning paths (المسارات التعليمية)

Status: 🟡 v1 built, critic loop done, waiting for the owner's review and the assets P1–P6
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

| # | Asset | State |
|---|---|---|
| P1 | Wide header arch (thin gold line with tails) | **to generate** (placeholder: side-nav `arch.svg`, shape differs) |
| — | Open-book emblem on the arch | reused `ui/nav/quran.svg` in gold (to confirm) |
| P2 | Mosque silhouette, faint, left | **to generate** (absent for now) |
| P3 | Gold crescent and star | **to generate** (absent for now) |
| — | Lattice corners | reused (`images/lattice-corner-*.webp`, 32% opacity) |
| — | Card bottom pattern | reused (`ui/decor/star_tile.svg`, tinted emerald) |
| — | Course 01 icon (Quran on rehal) | reused from `lesson-production` (`icons/mushaf.webp`) → `ui/courses/course_01.webp` |
| P4, P5 | Course icons 02–12 | **to generate** (placeholder: outline book) |
| P6 | Lock, star, play glyphs (SVG, currentColor) | **to generate** (placeholder: Material icons; play drawn in code) |

Prompts: `docs/flutter/prompts/03-courses/images-v1.txt` (also pasted in the chat).

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

## Open points for the owner
1. Progress text: the reference shows a ~30% bar with the text «0%»; the build shows 30% / 30%.
2. Emblem on the arch: reuse the nav's outline book (one style) or a new gold book from ChatGPT?
3. Course icon list (above) and the motion proposal.
4. New tokens proposed for this screen (`RateelColors` section "Screen 03"): card fills, card rim, path line,
   progress, play, lock, pill. Conflicts with confirmed tokens: see the last critic report.
