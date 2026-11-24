# Flutter app: performance (animations feel heavy)

**Status (2026-11-24):** diagnosis done, **no fix applied yet**. The owner reports that the animations and the app feel
heavy on the phone. Proposed fix branch: `flutter/perf` from `master`, waiting for the owner's yes.

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
