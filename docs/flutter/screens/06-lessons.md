# Screen 06: lessons of the unit (دروس الوحدة)

Status: 🟡 plan, waiting for the owner's answers. History: `06-lessons/HISTORY.md`
Branch: `flutter/06-lessons`, from `flutter/05-units` (contains side nav, courses, units)
Reference: `docs/flutter/screens/06-lessons/reference.webp` (1844×853, u = 8.53 px; lesson-production
`docs/design/glassy-gamified/screens/06-lezioni-dell-unita.webp`)
Angular original: `src/app/features/lessons/` (`lessons-list`, `lesson-card`), `shared/directives/border-fill.directive.ts`
Data: `src/assets/data/lessons/<course>/<unit>.json` (fields: id, title, description, type, duration, order,
stepNumber, totalSteps). Lesson types in the data: `video`, `read`, `practice`, `listen`, `assessment`, `test`.

## Data coverage (found 2026-11-22)
| Course | Units | Lessons files | Match |
|---|---|---|---|
| 01 tajweed-fundamentals | 5 | 5 (2–3 lessons each, 13 lessons) | all units, ids match |
| 02 noon-meem-mushaddad | 5 | 3 (`intro-noon-meem-unit`, `intro-noon-meem-unit2`, `practical-noon-meem-unit`) | ids **do not match** the units (`intro-noon-meem`, `noon-meem-practical`…); 2 units without lessons |
| 03–07, 12 | 5–7 each | none | — |
| 08–11 | none | none | already «قريبًا» on screen 05 |

## Layout (landscape, RTL), first estimate on the reference (the critic measures)
The right rail of the reference is **not** built: the approved side navigation stays.

| Zone | Content | Geometry (u = 8.53 px) |
|---|---|---|
| Header | **centred** arch with the gold open-book emblem on the apex (as screen 03), title in cream gradient, gold divider with diamond | arch apex y ≈ 2u, emblem y 9.5–17u, title centre y 23.4u, size ≈ 7.5u; divider y 32u, ≈ 62u wide |
| Back | glass circle with → to the right of the title (goes back to the units) | Ø ≈ 9u, centre (162.8u, 24.4u) |
| Mosque | olive silhouette left of the arch, fading at the ground (reused) | x 30–64u, y 12–35u |
| Corner | lattice ornament **top left only** | ≈ 27u × 25u |
| Background | screen-03 background + faint girih pattern (as screen 05) | |
| Path | horizontal track of **lesson cards**, right to left (lesson 1 on the right), joined by a thin gold line with a gold diamond between cards; the line runs on off-screen towards the next card | cards ≈ 75u × 51u, radius ≈ 4.7u, top y 40u, line y 65.7u, pitch ≈ 88u |

### Lesson card
- Same family as the course card of screen 03 (fill, shadow, card pattern along the bottom).
- **Step pill** «1/3» (stepNumber/totalSteps from the data), gold, dark text, top left of the card (≈ 12.7u × 6u).
- Title (≈ 5u, cream, weight 600) and description (≈ 3.3u, 2 lines) right-aligned; **lesson-type icon** at the
  bottom centre (≈ 25u × 12u), gold line art.
- **Active (in progress)**: gold rim + gold glow (breathing, like the active course card), icon gold.
- **Locked**: muted rim #325C46-ish, dim text, icon muted green, **padlock** on the icon (reference: gold body,
  grey-teal shackle). Screen 05 uses the all-green padlock and the 45% dark veil (owner ✅): see question 4.
- **Completed**: step pill becomes a gold ✓ (Angular), gold-tinted rim, icon lit (question 5).

## Code vs assets
Code: background, cards, rims, glows, pill, texts, line and diamond, back button (glass circle token + arrow
painter, like the ☰/✕ painter), motion, haptics, sound.
Reused (one style): `header_arch.svg`, `header_book.svg`, `mosque.webp`, `title_divider.svg`, `card_pattern.svg`,
`girih_tile.svg`, `corner_units_top_left.webp`, `glyphs/check.svg`, `ui/units/padlock*.svg`, `fill-sound.mp3`.
Assets to ask (prompts `prompts/06-lessons/images-v1.txt`, pasted in the chat): a set of **gold line-art
lesson-type icons** in the reference style: L1 open book with bookmark (read), L2 video, L3 microphone (practice),
L4 listening (headphones), L5 test, plus L6 the same five as solid muted-green silhouettes for the locked state
(or tint in code, question 3).

## Motion and UX (Angular original → Flutter, with haptics and light)
| Angular original | Flutter |
|---|---|
| Page fades/slides in (300 ms), cards scale 0.95→1 (200 ms) | Entry ≈ 1.2 s, same choreography as screen 05: header settles, cards pop in right to left (stagger 90 ms), the line draws itself, diamonds light up, the active card's rim lights. Opening from screen 05: the tapped unit circle grows into the screen |
| Hover lift −4 px, gold title | Press: scale 0.97 + haptic `tap`; release: shine sweep across the card |
| Focus highlight on the active lesson (scale 1.05 + gold glow, 1.5 s), scroll to it | Path glides to the lesson in progress, then one gold glow pulse on its rim |
| Locked card: overlay + 🔒 | Locked tap: padlock shake + haptic `denied` + toast «أكمل «<previous lesson>» أولًا» |
| Drag-scroll of the list | Custom drag track with snap and rubber band (as screen 05) |
| **Lesson completion**: rectangular border fill 1.5 s (top → right → bottom → left) with gold glow, then scroll to the next lesson and open it after 0.8 s; **last lesson** → units with `completedUnitId` | **Completion sequence**, automatic when a lesson ends (lesson screen → this screen): 1) path centres the card; 2) a **gold light runs around the rim** (light head, one haptic `tick` per side), fill sound; 3) gold flash + sparkles, the pill «1/3» turns into ✓ with a bounce, haptic `milestone`; 4) the light runs along the line to the diamond (pop) and on to the next card, haptic `unlock`; 5) its padlock flies off and the veil lifts (as approved on 05), the rim turns gold; 6) glide, haptic `success`, the next lesson opens after 0.8 s. **Last lesson of the unit** → back to screen 05 and `unitCompleted.value = <unit>`: screen 05 plays the unit completion (already built), which opens the next unit's lessons (this screen) |

## Shared progress (owner: one progress for lessons, units, courses)
- New `lib/lessons/lesson_data.dart` (generated `lesson_data_gen.dart` from the JSON, like the units) and
  `LessonProgress` per unit: lessons completed so far.
- **Unit progress = completed lessons / lessons of the unit** → `CourseUnitsProgress.progress[unit]`; the course
  bar already follows the units (`courseProgressFromUnits`).
- Back on screen 05 after a lesson (not the last), the unit ring **catches up** with fill and ticks, and at 50%
  the half line and diamond light up (as the course bar does on screen 03).

## Until the lesson screens (07+) exist
Tapping an open lesson needs a way to "finish" it. See question 6.
Review aids (web): `?lessons=<course>,<unit>`, `?lesson=<i>`, `?completeLesson=<i>`; long press on the
lesson in progress plays its completion.

## Questions for the owner (before building)
1. **Header title**: the reference (and the Angular app) shows the first lesson's title «مقدمة في علم التجويد».
   Proposed: the **unit title** (e.g. «مقدمة في التجويد»), since the cards already carry the lesson titles.
2. **Header layout**: centred arch with the book emblem + title + back circle, as in the reference (screen 05 has
   the title on the right). Keep as the reference?
3. **Lesson icons**: one icon per lesson type (book, video, microphone, headphones, test), gold line art as in the
   reference (prompts L1–L5); locked = same icon in muted green (tinted in code, no L6). Ok?
4. **Locked card**: reference = gold padlock with grey shackle, dimmed card. Screen 05 (✅) = all-green padlock,
   45% dark veil. Proposed: **same as screen 05** (green padlock 9u centred, dark veil) for one style. Or the
   reference's gold padlock here?
5. **Completed lesson**: pill «1/3» → gold ✓, rim gold-dim, icon lit, no veil. Ok?
6. **Opening a lesson** before screens 07+: (A) a **simple placeholder lesson page** (title, description, button
   «أكملت الدرس») so the whole flow can be tested on the phone: lesson → back → completion → next lesson → …
   → last lesson → unit completion → next unit; or (B) toast «الدرس: قريبًا» + long press as demo.
   Proposed **A**.
7. **Missing data**: course 02 lesson files have unit ids that do not match its units; courses 03–07 and 12 have
   no lessons. Proposed: map course 02 by the obvious names (`intro-noon-meem-unit` → `intro-noon-meem`,
   `practical-noon-meem-unit` → `noon-meem-practical`; `intro-noon-meem-unit2` unused), every unit without lessons
   shows the empty state «قريبًا» on this screen (and on 05 its completion can only be played by the demo).
8. **Duration** (minutes, in the data and on the Angular card) is not in the reference: leave it out?
9. **Sound**: the fill sound on each lesson completion too, or only on the unit completion (05)? Proposed:
   softer, only on the unit completion; lessons get light + haptics only.
