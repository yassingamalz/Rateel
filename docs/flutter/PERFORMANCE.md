# Flutter app: performance (animations feel heavy)

**Status (2026-11-27): fix applied** on branch `flutter/perf` (owner's yes, 2026-11-27), same look and same animations.
Diagnosis of 2026-11-24 kept below; what was done and the measurements are in «Fix applied» at the end.

The look must not change: every fix below is about *how much is redrawn*, not *what is drawn*.

## What is NOT the cause
- Build mode: the APK is `--release` (`tools/flutter-review/build-apk.sh`).
- Assets: about 6 MB in total, the largest image is 442 KB (`assets/ui/decor/angular_pattern_2.webp`), none above
  1.5 Mpx.
- Covered routes: pages are opaque `PageRouteBuilder`s, so the Navigator stops the tickers of the screens underneath.

## Causes found (by weight)
1. **Endless `_ambient` controllers redraw whole screens.** `units_screen.dart:61` and `lessons_screen.dart:66` run a
   4 s `AnimationController(..)..repeat()` forever (breathing glow of the open unit/lesson, badge shine, check pulse).
   It rebuilds and repaints the **whole path** (up to ~7 `UnitCircle` / `LessonCard` with blurred shadows, `Opacity`,
   images) every frame (60–120 fps), also when the user does nothing. The effect is visible on one element only.
2. **One `AnimatedBuilder` for every controller.** `units_screen.dart:353` (and the same in `lessons_screen.dart:334`)
   merges `_entry, _ambient, _shake, _fill, _half, _flash, _flow, _unlock, _scroll` in one `Listenable.merge`: a drag
   of the path rebuilds every circle with all its effects every frame.
3. **Many blurs repainted every frame.** 33 `BoxShadow(blurRadius: …)` and several `MaskFilter.blur` in custom
   painters (`lesson_card.dart:593,610`, `lessons_screen.dart:812,827,850`, `lesson_shell.dart:452,476`). Blurs are
   among the most expensive GPU operations on a phone.
4. **No `RepaintBoundary` anywhere in `lib/`.** Whatever moves drags the background, the girih decor and the static
   parts into the same repaint.
5. **Pause menu blurs the live lesson.** `lesson_shell.dart:192` wraps the whole lesson in `ImageFiltered` (blur) +
   `ColorFiltered` + `Transform.scale` while the menu animates; on screen 07 the content is the YouTube WebView
   (platform view), which makes the blur very expensive.

## Proposed fixes (same look)
- `_ambient` drives only the open unit/lesson (its own small `AnimatedBuilder` or a painter with `repaint:`), never the
  whole path; stop it when the screen is not visible or nothing breathes.
- Split the merged listenable: scroll moves positions only (`Transform.translate` of cached children); entry,
  completion and shake rebuild only the element they touch.
- `RepaintBoundary` around each circle/card, around `ScreenBackground` + decor, and around the top bar.
- Static shadows and glows: paint once and cache (boundary or pre-rendered), do not recompute per frame; pass
  `repaint:` listenables to `CustomPainter`s and keep `shouldRepaint` strict.
- Pause menu: blur a still snapshot of the lesson (or a dim + scale without blur over the WebView) instead of the live
  tree.
- Measure before and after: frame build/raster times and janky frames on screens 05, 06, 07 (profile build /
  `flutter run --profile` on the phone, or web `?slow=` frame checks in the container), log the numbers here.

## Rule for every new screen (from now on)
- No endless animation may rebuild more than the element it animates.
- One controller → one small `AnimatedBuilder`; never merge all controllers above a whole list.
- Put a `RepaintBoundary` around each repeated item and around static backgrounds.
- Avoid blur on live content and on platform views; prefer cached glows.

## Fix applied (2026-11-27, branch `flutter/perf`)
Rule kept: **nothing of the look or of the animations changes**; only how much is rebuilt and repainted.
- **Cause 1 (endless `_ambient`), 05 and 06:** the 4 s loop is no longer in the path's merged `AnimatedBuilder`. It is
  passed as an `Animation` to `UnitCircle` / `LessonCard`, and only what it animates follows it: the breathing ring of the
  open unit repaints from the animation without a rebuild (`_RingPainter(repaint:)`), the badge shine and the check pulse
  are small `AnimatedBuilder`s, the glow of the lesson in progress is the only builder on 06. `_RimPainter` of the lesson
  card no longer repaints on every frame (it compared `ambient` without using it).
- **Cause 2 (merged builder):** the entry / completion / scroll controllers stay merged (they run only during those short
  sequences), but each unit circle, lesson card and course card now paints in its own layer, so a drag moves layers.
- **Cause 4 (no `RepaintBoundary`):** boundaries around each circle / card, the ring painter, the shared
  `ScreenBackground`, the 03 background and `ScreenGirih`.
- **Cause 5 (pause menu blur):** while the menu is fully open the lesson is shown as a **still picture baked once** with the
  same blur σ 0.55u, brightness 80 % and scale 98 % (`LessonShell.stillBlur`), instead of blurring the live lesson on every
  frame of the button's pulse. During the 300 ms opening / closing the live blur runs as before. The lesson stays mounted
  (keyed boundary, so its state survives the filters). The video lesson (07) keeps the live blur: its WebView cannot be
  captured.
- Cause 3 (many blurred shadows) is reduced by the layers above (static shadows are no longer repainted each frame); the
  shadows themselves are unchanged (look).

**Measurements** (widget rebuilds per second with the screen idle, flutter_test probe at phone size 915×412):
| Screen | `master` | `flutter/perf` |
|---|---|---|
| 05 units (course 0, unit 1 open) | 6180 | 360 |
| 06 lessons (course 0, unit 0) | 4680 | 60 |

**Look check** (Playwright, master vs perf, same URL): courses, units, lessons (desktop and phone), settings and the paused
reading lesson (desktop and phone) are pixel-identical (p99 difference ≤ 3/255); the only differences are the phase of the
breathing glows and of the pause button's pulse (time-dependent). The baked still is 2402×1082 on a 915×412 dpr 2.625 phone;
resuming restores the live lesson with its state. Frame times on the phone itself are still to be measured by the owner
(APK).
