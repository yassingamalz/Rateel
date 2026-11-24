# Screen 11 (leaderboard): history of the work

Branch `flutter/11-leaderboard`, created on 2026-11-24 from `master` (688e7ed, screens 02–06 merged).
Plan: `../11-leaderboard.md`. Decisions: `../../DECISIONS.md`.

## 1. Reference, Angular original and plan (2026-11-24)
- Reference `reference.webp` copied from `lesson-production` (`docs/design/glassy-gamified/screens/11-classifica.webp`,
  1844×853). Angular original: `src/app/features/gamification/leaderboard/` and the app screenshot
  `docs/production/screenshots-app/11-classifica.png` → `angular-original.jpg`.
- Found: the reference's **medals and avatars are the Angular images** (same drawings) → reused, no new art. New art:
  dark-green ribbon (Angular's is solid gold), gold ogee lattice, coin stacks (Angular uses Font Awesome coins), small
  gold book. The reference's rail is the approved side nav (04).
- The reference draws the vertical tab labels mirrored/garbled (ChatGPT text): the app draws real Arabic rotated −90°.
- Colours sampled from the reference; 6 conflicts with the confirmed tokens (K1–K6, plan §3).
- Proposal sheet `proposal-v1.jpg` (`tools/flutter-review/leaderboard-proposal-sheet.py`), 9 questions (plan §6),
  prompt drafts A1–A4 (`docs/flutter/prompts/11-leaderboard/images-v1.txt`). Waiting for the owner's answers.

## 2. Owner answers and prompts (2026-11-24)
- Owner: mock data (logged in `SCREENS.md`), filters / rows 4+ / pinned bar as Angular, title arched as Angular, lattice
  from ChatGPT, motion approved, Angular medals and avatars. Conflicts K1–K6 moved to the project-wide register
  `STYLE-CONFLICTS.md` (decided at the end of the project; built with the proposals meanwhile).
- Prompts A1, A2, A3a/b/c, A4 pasted in the chat; attachments = `reference.webp` + zoomed crops in
  `docs/flutter/prompts/11-leaderboard/attach/`. Build v1 started with placeholders for the missing art.

## 3. Build v1 (placeholders) and v2 (owner's assets) (2026-11-24)
- Code: `lib/leaderboard/leaderboard_screen.dart` (screen), `leaderboard_data.dart` (**mock** data, 15 players);
  `main.dart` routes rail index 3 to it; review aid `?section=3` (`SideNavScaffold.startSection`). Tokens
  `meRowTop/Mid/Bottom` (K2, provisional). Test `test/leaderboard_test.dart`.
- Layout in u from the reference (plan §2), relative to the content area left of the approved rail. Rows are absolutely
  positioned and keyed by player, so a filter change moves the rows that stay (animated reorder) and fades the others.
  Global rank kept in filtered lists, medals/rewards for the first three rows (as Angular). Title arched as Angular:
  the laid-out text is drawn in 60 thin strips along a parabola (keeps Arabic shaping).
- v1 demo showed the ribbon/avatars popping in after the entry → images are precached before the entry starts.
- Owner delivered A1–A4 (zip): stored in `docs/design-assets/leaderboard/`, processed by
  `tools/assets/leaderboard_assets.py` (`ASSETS.md`). Ribbon variant 02 (darker band) chosen; lattice is seamless.
- v2 captures `capture-v2-*` (start, after tapping the pinned bar, friends, region; desktop and phone), comparison
  `compare-v2.jpg`, demo `demo-v2.mp4` (`tools/flutter-review/leaderboard-{capture,demo}.js`). Critic not run yet:
  to be proposed to the owner first.
