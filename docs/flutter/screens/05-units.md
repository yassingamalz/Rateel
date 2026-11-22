# Screen 05: course units (وحدات المقرر)

Status: 🟡 v1 built with placeholders (owner said yes to the plan 2026-11-22); waiting for assets U1–U6; critic v1
Branch: `flutter/05-units`, from `flutter/03-courses` (contains the side nav and the courses screen)
Reference: `docs/flutter/screens/05-units/reference.webp` (1672×941, glassy gamified, dark;
lesson-production `docs/design/glassy-gamified/screens/05-unita-del-corso.webp`)
Angular original: `src/app/features/units/` (`units-list`, `unit-card`), `shared/directives/border-fill.directive.ts`
Data: `src/assets/data/units/<nn>-<course>.json` (5–7 units per course; files exist for courses 01–07 and 12,
**courses 08–11 have no units file yet**). Unit types in the data: `video`, `reading`, `practice`, `test`.
Code: `app_flutter/lib/units/` (`units_screen.dart`, `unit_circle.dart`, `unit_data.dart`, generated `unit_data_gen.dart` from `tools/flutter-review/gen_unit_data.py`); navigation `lib/core/learn_flow.dart`; sound `lib/core/sounds.dart`.
Review: `?units=<course>` opens the units, `?unit=<i>` sets the unit in progress, `?completeUnit=<i>` plays a completion; long press on the unit in progress plays it too. Captures `capture-v1.png`, `phone-v1.png`, `compare-v1.jpg`, `completion-frames-v1.jpg`, video `demo-v1.mp4` (`tools/flutter-review/units-demo.js`).

## Layout (landscape, RTL), u = 1% of the screen height (u = 9.41 px on the reference)
The right rail of the reference is **not** built: the approved side navigation (screen 04) stays.
First measures (eyeballed on the reference, the critic will measure them with numbers):

| Zone | Content | Geometry (first estimate) |
|---|---|---|
| Header | title «وحدات المقرر» with the gold divider and diamond; arch, mosque silhouette, crescent and star | title centre y 17.5u, size ≈ 8u; divider y 24u |
| Change course | glass pill «تغيير المقرر» with a swap-arrows icon, top left | 30.5u × 7.8u, centre y 17u, 7u from the left edge |
| Path | horizontal track of **circular unit nodes**, right to left (first unit on the right), joined by a thin gold line with a **gold diamond** node in the middle | outer ring Ø 46u, inner glass disc Ø 41u, centre y 58u, pitch ≈ 66.5u |
| Corners | lattice ornaments **top left and bottom right** (screen 03: top left and top right) | |
| Background | the screen-03 background **plus a large, very faint geometric line pattern** over the whole screen | |

### Unit node (circle)
- Outer ring: thin gold line (≈ 0.35u) on the active unit; dim emerald/gold on locked ones (to measure).
  The ring is also the **progress ring** (as in the Angular app): it fills clockwise from the top with the unit progress.
- Inner disc: glass, radial emerald (lighter at the top), soft inner shadow, faint star lattice along the bottom
  (shared `star_tile.svg`/`card_pattern.svg`, clipped to the circle).
- **Active / in progress**: cream play disc Ø 11.7u with a dark triangle; title 2 lines, cream, ≈ 4.7u;
  progress badge «0%» (gold disc Ø 9.8u, dark text) sitting on the top of the ring.
- **Locked**: the unit-type icon (book for `reading`) in cream-gold with an emerald **padlock** on it; title; no badge.
- **Completed**: gold check badge on the ring, ring full gold, icon on a gold disc (Angular app); look to confirm.
- Icon per unit type: `video` play disc · `reading` open book · `practice` microphone · `test` scroll with a check.

## Code vs assets
Code: background gradient, rings, glass discs, play disc, badge, connector line and diamond, pill, texts, motion,
haptics. Reused from the library (one style, `ASSETS.md`): `header_arch.svg`, `mosque.webp`,
`crescent_star.svg`, `title_divider.svg`, `corner_glow_left/right.webp` (bottom right = top left turned 180°),
`star_tile.svg`/`card_pattern.svg`, `glyphs/play.svg`, `glyphs/check.svg`, `glyphs/lock.svg` (fallback).

Assets to ask (prompts `prompts/05-units/images-v1.txt`, pasted in the chat):
U1 open book (reading) · U2 emerald padlock (locked overlay) · U3 microphone (practice) · U4 scroll with check
(test) · U5 swap-arrows icon (change course) · U6 faint geometric background pattern (seamless tile).

## Motion and UX (Angular original → Flutter, upgraded with haptics and light)
The Angular app already had these animations; each one is kept and made richer (owner, 2026-11-22: completion
animations get vibration and light).

| Angular original | Flutter |
|---|---|
| Page slides in from the left (500 ms), slides out on unit tap | Entry 1.4 s: header settles from above; circles pop in right to left (scale 0.85→1, 90 ms stagger); the line draws itself and the diamonds light up; rings fill to their progress; badge counts up. Exit on tap: the tapped circle grows towards the centre (morph into screen 06), the others fade |
| Hover scale 1.05, radial glow, icon ripple, shine sweep | Press: scale 0.96 + haptic `tap`; release: glow pulse + ripple ring + shine sweep across the icon. Active unit: slow breathing glow on the ring (2 s, same as the active course card) |
| Lock fades in (scale 0.8→1) | Locked tap: padlock shakes + haptic `denied` + toast «أكمل «<previous unit>» أولًا» |
| Progress badge shine every 3 s | kept, softer (every 4 s) |
| Progress ring fills (stroke-dasharray) | ring fills with a light head (bright dot at the tip) |
| Connector: 100% if done, progress/2 while in progress, 0 if next locked | Same rule as the course path (owner, 2026-11-20): first half lit at 50%, diamond pops; second half lit on completion |
| **Unit completion** (border-fill 1.5 s, fill sound, 4 vibrations 75 ms, scroll to unit, highlight, unlock next, open its lessons after 0.8 s; last unit → back to courses with `completedCourseId`) | **Completion sequence**, automatic when the last lesson of a unit ends (lesson screen → this screen): 1) the path centres the unit; 2) the ring fills to 100% with a gold light head, one haptic `tick` every 10%, the badge counts up; 3) at 100% gold flash + sparkles around the ring, haptic `milestone`, the play disc morphs into a check with a bounce, pulse ring; 4) the light runs along the line to the diamond (pop) and on to the next unit, haptic `unlock`; 5) the padlock pops off, the ring turns from dim to gold with a flash, the badge «0%» drops in; 6) the path glides to the new unit, haptic `success`, then it opens its lessons (screen 06) after 0.8 s. **Last unit of the course** → back to the courses screen, which plays the course completion (`courseCompleted`, already built). Optional: the Angular fill sound (`public/sounds/fill-sound.mp3`) |

- Until screens 06–07 exist: long press on the unit in progress plays the completion (demo), `?complete=<i>` on web.
- From screen 03: tapping the active course opens this screen (replaces the «الوحدات: قريبًا» toast);
  «تغيير المقرر» and the system back go back to the courses screen.

## Owner answers (2026-11-22)
1. Title on the right; the arch is centred on the title. 2. Corners top left + bottom right. 3–7. As proposed: background pattern yes, check badge, next unit's lessons open by themselves, fill sound yes, «قريبًا» for courses without units.

## Questions asked (before building)
1. **Header**: the reference puts the arch between the mosque and the title (title on the right). Keep it as in
   the reference, or use the same centred arch + title as screen 03 (one style)?
2. **Corners**: top left + bottom right as in the reference (screen 03 has top left + top right)?
3. **Background pattern**: add the large faint geometric pattern of the reference (screen 03 has none)?
4. **Completed unit look**: gold check badge on the ring + gold icon disc (Angular), ok?
5. **After a unit is completed**: open the next unit's lessons automatically (Angular) or stay on this screen?
6. **Sound** on completion (the Angular fill sound), yes or no?
7. Courses 08–11 have no units in the data: show an empty state «قريبًا» for now?
