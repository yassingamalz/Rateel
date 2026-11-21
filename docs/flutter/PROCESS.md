# How a screen is built (procedure used for screen 04, side navigation)

Follow these steps for every screen. Decisions go in `DECISIONS.md` in the same commit as the work.

## 1. Plan (before any visual work)
- Branch `flutter/<nn>-<slug>` from the latest approved branch.
- Copy the ChatGPT reference into `docs/flutter/screens/<nn>-<slug>/reference.webp`
  (all references: branch `lesson-production`, `docs/design/glassy-gamified/`).
- Write `docs/flutter/screens/<nn>-<slug>.md`: layout, states, motion/UX, what is code and what is an asset.
- Asset prompts for ChatGPT: **always pasted in the chat, one copyable block each**, with the reference images
  to attach; archive copy in `docs/flutter/prompts/<nn>-<slug>/`. Prefer reusing assets from the shared library
  (`ASSETS.md`) and tokens from `DESIGN-SYSTEM.md` to keep one style.
- Get the owner's "yes" on the plan.

## 2. Build
- Code in `app_flutter/` (Flutter 3.50.1 stable, Readex Pro, RTL, landscape, dark).
- Geometry in units of **u = 1% of the screen height**, measured on the reference at 1844×853 (u = 8.53 px).
- Colours, rims, radii, shadows, glows: only from `RateelColors` / `DESIGN-SYSTEM.md`. A reference value that
  conflicts with a confirmed token is reported to the owner, never copied silently.
- Owner assets: source in `docs/design-assets/<group>/`, cleaned copy in `app_flutter/assets/ui/` (trim
  transparent margins, SVG with `currentColor`, no SVG filters: flutter_svg ignores them), listed in `ASSETS.md`.
- Every layer of an animated Stack gets a stable key (a late layer must not shift the others).

## 3. Check (critic loop, mandatory)
- `flutter analyze && flutter test && flutter build web --release`, serve `build/web` on port 8765.
- Capture: `node tools/flutter-review/capture-states.js <outdir>` (closed/open at 1844×853),
  `capture-morph-frames.js <outdir>` (`?slow=12`), `record-demo.js <outdir>` (video; speed up ×4 with ffmpeg
  `setpts=PTS/4`).
- A separate critic sub-agent compares reference and capture **with numbers** (`tools/flutter-review/measure.py`
  adapted to the screen): sizes, positions, radii, rims, hex colours, shadows/glows, type, icons, morph frames,
  conflicts with tokens. Report: `docs/flutter/screens/<nn>-<slug>/critic-v<k>.md` with scores.
- Fix every high/medium code item, re-run, repeat. Items that need art become ChatGPT prompts.
- Side nav history: v1 6/7 → v2 8.5/9 → v3 9/9.5 (then owner assets and corrections, v4, v5).

## 4. Owner review
- Send the comparison image (`compare-v<k>.jpg`, reference left, Flutter right) and the demo video.
- Apply the owner's corrections; owner choices that differ from the reference are logged as decisions,
  not defects.
- Phone test: APK (see below). Approval → pull request into `master` (only when the owner asks).

## APK for the owner's phone
One command, idempotent (installs Flutter 3.50.1 and the Android SDK only when missing):
```
tools/flutter-review/build-apk.sh
# output: app_flutter/build/app/outputs/flutter-apk/app-release.apk (signed with the debug key: fine for side-loading)
```
- First run in a fresh container: ~5 min (SDK + NDK r28c download through the proxy, Gradle cache). Next runs: ~30 s.
- **Download / "mirror" errors:** Gradle must run with one worker (`app_flutter/android/gradle.properties`:
  `org.gradle.workers.max=1`); parallel downloads hit the proxy's rate limits. If a download still fails (429,
  timeout), re-run the script: Gradle resumes from its cache. Java/Gradle already trust the proxy CA through
  `JAVA_TOOL_OPTIONS`; never disable TLS checks.
- The APK is sent in the chat or published as a GitHub release asset, never committed.
