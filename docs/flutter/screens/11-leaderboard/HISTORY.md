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

## 4. APK, critic v1 (phone only) and v3 (2026-11-24)
- APK 1.0.337 (v2). Owner: critic **at phone size only** (915×412), with his points: brightness of the circles, fonts
  standard with the app, text positioning.
- Critic v1 (`critic-v1.md`): **7.7** (look 7.4, behaviour 8.4). High B1: tabs 36 dp wide. Medium: header labels
  1.15u high and not in the app's style, names too low / too close to «n درس», row gap 1.2u vs 0.5u, star too small,
  avatar rim dark, title low and not the screen-title style, lattice too long and olive, bar glow hidden by its shadow,
  tab container green rim, own row loses the gold rank disc, ribbon band too bright (asset). New conflicts K7–K9
  (logged in `STYLE-CONFLICTS.md`; K5 note corrected).
- v3 fixes: tap area of the tabs +1.4u per side; header 4.4u w560 (course-card title style), 1.15u lower; name ↔
  lessons gap 2.2u; rows gap 0.5u, list top 0.3u; star 6.6u at a fixed place with the number left-aligned; avatar rim
  0.55u lit top/bottom (unit-ring colours); title 6.2u w560 with the `titleTop → titleBottom` gradient, 1.6u higher;
  lattice 16u, tinted `pathLine`; bar shadow downwards so the gold glow shows; tabs dark 45% + gold rim token; own row
  keeps the gold «15»; ribbon band darkened in `tools/assets/leaderboard_assets.py` (#031C0D vs reference #012418).
- Captures `capture-v3-*`, sheet `compare-v3-phone.jpg` (reference above, Flutter phone below), demo
  `demo-v3-phone.mp4` (915×412). Lows of critic v1 left for the owner's review.

## 5. v4: title, text sizes and brightness (2026-11-24)
- Owner on v3: the title in the ribbon, the text sizes and the brightness differ from the reference.
- Measured (desktop capture vs reference): title in the reference is **straight**, warm gold-cream ≈ #F5E9B4, 11% wider
  than v3, which was arched, whiter (#F8F4E3) and showed thin vertical seams from the strip drawing; reference texts are
  brighter (#FFFEDE vs `titleCream` #FAF1D8); «33 درس» 3.5u and #E1E1CF vs 3.1u at 75%; names slightly thinner.
- v4: straight title 6.6u w540 with `leaderTitleTop → leaderTitleBottom` (K10), texts `leaderText` (K9), names w440,
  lessons line 3.5u at 88%, book 3.5u. Measured after: title box and colour, lessons and names within a few px of the
  reference. Captures `capture-v4-*`, sheet `compare-v4-phone.jpg`.
- Not matchable: the reference writes «عبدالله» with the ﷲ ligature, Readex Pro has none (data text, not changed).

## 6. v5: arched title, reference golds (2026-11-24)
- Owner on v4: «it does not match: the title is not curved as in the reference, the gold brightness of the different
  elements does not match, the fonts too». (v4 had made the title straight: wrong reading of the reference.)
- Measured on the reference: title baseline arched, sagitta 1.05u over the text, letters tilted ≈ 7° at the ends;
  rims ≈ 5 px (#A89C48 edges, #FCE75A core, #FFF878 centre; bar #F8F27D/#FFFFA8 with a strong glow); divider 3 px
  #DDD88B/#FFFFB8/#E7E091; gold tab #9A7212 (top) → #E5A71C → #FDE66E (bottom); «15» disc #EBAE1D→#F2B827 with a pale
  rim; star #F0B42C→#F4B81C; chevron ring #FCD542 with a dark inside; avatar rim #FEFEC6/#F0D051; medals and coins
  warmer/darker than our assets (#F3B02E vs #FCBA2D, #F6BB2C vs #FED210); rows 1.2u apart; row 3 half hidden and dimmed
  under the bar.
- v5: title rendered once into an image and mapped on a 48-segment triangle mesh along the arch (no seams), 6.2u;
  all golds above as `leader*` tokens; art modulated by `leaderArtTone`; rows gap 1.2u, list top 0.8u; rows fade
  (to 55%) in the 5u above the pinned bar while it is shown. Captures `capture-v5-*`, `compare-v5-phone.jpg`,
  `demo-v5-phone.mp4`. Conflicts updated (reference values built, K11 added).
