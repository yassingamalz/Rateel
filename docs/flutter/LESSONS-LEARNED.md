# Flutter app: lessons learned

Rules learned while building the screens. Read with `DECISIONS.md` before any work; add a line here in the same
commit whenever the owner corrects the way of working. Newest at the bottom of each section.

## References
- **ChatGPT references are visual only** (owner, 2026-11-21). Layout, colours, shapes, sizes and motion come
  from the reference; **texts and data always come from the app** (`src/assets/data/*.json`, later the real
  backend): titles, descriptions, counts, progress, levels. If the reference shows different wording or numbers
  (e.g. screen 03: course 3 description, the «0%» with a 30% bar), keep the app's data and do not flag it as a
  defect.
- **New references are generated from the app, not from the old ChatGPT references** (owner, 2026-11-25): ChatGPT
  drifted out of the app's style when given the old `lesson-production` images. Every prompt for a new screen
  attaches **screenshots of the approved Flutter app** (`docs/flutter/app-references/`, captured from `master` at
  1844x853) and says «same style as the attached app screenshots, do not invent a new style». Old ChatGPT images
  may still be attached only for the layout idea, after the app screenshots, and the prompt says so. Refresh the
  screenshots when a new screen is approved.
- Values in a reference that are only an example (progress 30%) are not design: progress starts from the real
  value (0% for a new user).

## Critic
- **Ask the owner before launching the critic** (owner, 2026-11-24): it consumes a lot. Propose the critic
  round, say why, and wait for a yes; never start it on your own.
- The critic gets **no list of accepted differences**: it scores the whole screen one to one, placeholders
  included. Only owner-approved (✅) decisions are skipped (`CRITIC.md`, 2026-11-20).
- Any deviation from the reference is **asked before it is built**, not built and listed afterwards.
- Re-run the critic on the latest build: captures from an older build give stale findings.
- **Critic at phone size only (915×412)** (owner, 2026-11-24, screen 11): no desktop critic; the owner tests on the
  phone. Always check brightness of round elements (avatars, discs, medals), that every text uses the app's
  standard type styles, and the optical position of every text.

## Building
- **Verify element by element with numbers before showing anything** (owner, 2026-11-24, screen 11): boxes of every
  element (±4 px at 853), gradient and line profiles, zoomed side-by-side per region. Whole-screen looks hide errors.
- `Image(repeat: ...)` needs `fit: BoxFit.none`, or the default `scaleDown` shrinks the tile to the box height.
- Readex Pro sets Arabic low in its line box: in pills and buttons, centre the text optically
  (screen 03: lift 0.45u), and check it in a zoomed comparison.
- Flutter web needs mouse drag enabled explicitly for horizontal scrolling (`ScrollBehavior.dragDevices`).
- Ornaments that should run "under" the side rail: let the screen's Stack overflow (`Clip.none`); the rail panel
  is opaque and drawn on top, with its shadow.
- Traced SVGs from the owner keep their colours; small edits (trim the viewBox, split a sub-path to change its
  opacity) are logged in `ASSETS.md`.
- `flutter_svg` ignores SVG filters: assets with glows (e.g. CR-11) are spares, not used.

- **Performance** (owner, 2026-11-24: "animations feel heavy"): no endless animation may rebuild more than the element
  it animates; one controller per small `AnimatedBuilder`; `RepaintBoundary` around repeated items and static
  backgrounds; no blur on live content or platform views. Diagnosis and fix plan: `PERFORMANCE.md`.

## Assets from the owner
- Evaluate PNG and SVG separately: the SVG "reconstructions" can differ from the PNG (shape, fill). Use the one
  closest to the reference; SVGs with masks, CSS `<style>` or filters do not render correctly in flutter_svg.
- A critic's prompt can be wrong about the reference: before replacing an asset, zoom the reference (screen 03:
  the emblem's pages are dark with a gold rim, not filled).
- Check text in pills on the phone screenshots too: a few px of padding difference shows on small screens.

## Build
- APK: `tools/flutter-review/build-apk.sh`; keep `org.gradle.workers.max=1` (proxy rate limits).

## Phone checks (2026-11-21)
- Every size is in u, **line widths too**: a 4 px rim designed at 853 px height is 0.47u; fixed pixels become
  very thick on a phone (≈ 410 logical px high).
- The phone's system text zoom must not change the layout: the app ignores it (`withNoTextScaling`); text size
  will be an in-app setting.
- Check every build also at phone size: `viewport 915×412, deviceScaleFactor 2.625` (Playwright).
- Every APK gets a higher version (`build-apk.sh`) so it updates the installed app.

## Web build in the cloud container (2026-11-22)
- Build the review web app with `flutter build web --release --no-web-resources-cdn`: the default build loads
  CanvasKit from gstatic.com, which the headless browser cannot reach here (blank page).
- The APK version is the commit count on HEAD: in a shallow clone it is tiny (1.0.5) and the phone refuses to
  update an app with a higher version. Run `git fetch --depth=1000 origin <branch>` before `build-apk.sh`
  (2026-11-22).
- `CrossAxisAlignment.end` in a Column under RTL puts children on the LEFT: use `start` for right-aligned Arabic.
- A screen opened by a review link (initial routes) has nobody awaiting its route result: signal completions through
  the shared notifiers (`unitCompleted`), not only through `Navigator.pop(result)`.
- Signed numbers inside Arabic text («+10 نقطة») flip to «10+» in RTL: wrap them in an LTR isolate (`⁦+10⁩`)
  (screen 22, 2026-11-26).
- Amiri Quran sets tall line boxes (harakat): give the verse a box of ~2× the font size and `height` ≈ 1.3, or a
  `FittedBox` silently shrinks it (screen 22).
