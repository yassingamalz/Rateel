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
