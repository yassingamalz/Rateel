# Rateel: instructions for Claude sessions (Flutter app stream)

Rateel (رَتِّل) is a Tajweed learning app. On the `flutter/*` branches the app is being rebuilt
natively in Flutter, one screen per branch.

## Read first, every session
1. `docs/flutter/DECISIONS.md`: every decision taken so far (owner ✅ / proposed 🟡).
2. `docs/flutter/README.md`: workflow (one screen at a time, one branch per screen, owner approval).
3. `docs/flutter/PROCESS.md`: the step-by-step procedure (plan → build → critic loop → owner review → APK).
4. The plan of the screen you work on: `docs/flutter/screens/<nn>-<slug>.md`.
5. `docs/flutter/LESSONS-LEARNED.md`: how the owner wants the work done (references are visual only, critic
   without exclusions, building notes).
6. Lesson-production rules, design lines and assets live on branch `lesson-production`
   (`docs/production/RULES-AND-LESSONS-LEARNED.md`, `docs/design/`, `src/assets/images/guided/`).

## Key rules
- **Write every decision and every piece of work in the branch** (`DECISIONS.md`, the screen plan,
  the prompts) in the same commit as the work. Other sessions rely on it.
- **Critic before the owner:** every visual result is reviewed one to one against the reference by a
  separate reviewer and fixed until no high/medium code difference remains (`docs/flutter/CRITIC.md`).
  **Always ask the owner before launching the critic** (it consumes a lot): propose it, wait for a yes.
- Show the owner the visual plan and get a "yes" before any visual work.
- Never invent assets: write ChatGPT prompts, the owner generates the images. **Always paste the prompts in
  the chat, one copyable code block each**, and say which reference images to attach.
- **One style for the whole app** (`docs/flutter/DESIGN-SYSTEM.md`): if a reference conflicts with a confirmed
  token, tell the owner and let them decide.
- Dark theme first, light/dark toggle always present; landscape; RTL Arabic.
- Talk to the owner in **Italian**; write docs in English.

## Build and check (cloud container)
- Flutter is not preinstalled: download stable 3.50.1 to `/opt/flutter` (see `DECISIONS.md`), then
  `cd app_flutter && flutter analyze && flutter test && flutter build web --release --no-web-resources-cdn` (CanvasKit
  served locally: the CDN is not reachable from the headless browser).
- Screenshots: serve `app_flutter/build/web` and capture with Playwright at the reference size
  (1844×853); `?slow=10` slows animations for frame checks.
