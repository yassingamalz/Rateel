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
6. `docs/flutter/PERFORMANCE.md`: why the app feels heavy, the fix plan and the performance rules for new screens.
6b. `docs/flutter/BACKLOG.md`: everything left for later.
7. Lesson-production rules, design lines and assets live on branch `lesson-production`
   (`docs/production/RULES-AND-LESSONS-LEARNED.md`, `docs/design/`, `src/assets/images/guided/`).

## Key rules
- **Write every decision and every piece of work in the branch** (`DECISIONS.md`, the screen plan,
  the prompts) in the same commit as the work. Other sessions rely on it.
- **Everything left for later goes into `docs/flutter/BACKLOG.md`** (owner, 2026-11-26), in the same commit;
  read it at the start of each session and tick items off (logging them in `DECISIONS.md`) when done.
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

## GitHub access: two modes (owner 2026-11-28)
Whether a cloud session can write to GitHub depends on the session (the owner's connector was blocked by company IT on
2026-11-27; on 2026-11-28 a session could push, open and merge PRs again). **Check at the start of each session** which mode
applies: push the session's work branch (`git push -u origin <branch>`) or call a GitHub MCP tool (e.g. `list_pull_requests`).
Never bypass the proxy and do not keep retrying a refusal.

**A. GitHub works** (push succeeds, GitHub MCP tools answer): normal workflow.
- Push to the screen's branch; open PRs and merge them **only when the owner asks**, in the order they give.
- Branches made earlier with patches (mode B) are ordinary branches: if the owner asks to merge them, merge `master` into
  each one before its PR; `DECISIONS.md` / `BACKLOG.md` / `SCREENS.md` / `ASSETS.md` / `STYLE-CONFLICTS.md` conflict only by
  appended rows: keep every row (the older branch's first).
- Commits prepared by another session as patch files (zip sent by the owner): apply them with `git am` on a new branch from
  the base named in their README, then push.
- APKs are still sent as files (never committed).

**B. GitHub does not work** (push refused with 403 / "No linked GitHub account", GitHub tools denied):
- The repository is **public**: clone it read-only with no credentials, `git clone https://github.com/yassingamalz/Rateel.git`.
- Network secrets for GitHub hosts are refused by the settings: do not spend time on them.
- Work on a local branch, commit as usual, then hand the commits to the owner as patch files:
  `git format-patch <base> --output-directory <scratchpad>/patches`, with a short README (base commit, target branch,
  `git am` commands, also for PowerShell), and send them with the file-sending tool (zips under 30 MB each). The owner applies
  them on their PC with `git am *.patch` and pushes, or hands them to a session in mode A.
- Send patches often: the container is deleted after inactivity and unsent work is lost.
- APKs and other build outputs are sent the same way (as files).

## Build and check (cloud container)
- Flutter is not preinstalled: download stable 3.50.1 to `/opt/flutter` (see `DECISIONS.md`), then
  `cd app_flutter && flutter analyze && flutter test && flutter build web --release --no-web-resources-cdn` (CanvasKit
  served locally: the CDN is not reachable from the headless browser).
- Screenshots: serve `app_flutter/build/web` and capture with Playwright at the reference size
  (1844×853); `?slow=10` slows animations for frame checks.
