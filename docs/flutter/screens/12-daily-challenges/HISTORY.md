# Screen 12, daily challenges: history

## 1. Plan (2026-11-25)
- Branch `flutter/12-daily-challenges` from `master`, opened in parallel with the sessions on 10/10b and 22 (owner:
  start the screens that are easy to get).
- Plan `../12-daily-challenges.md` with questions Q1–Q6, prompts D1–D4 `../../prompts/12-daily-challenges/images-v1.txt`
  (crops in `attach/`).

## 2. Owner's answers and assets (2026-11-25)
- Q1 B (streak chip on 03), Q2 darker locked tiles, Q3 OK + keep the wiring written, Q4 OK, Q5 Readex Pro, Q6 OK
  (details in the plan).
- Instead of D1–D4 the owner sent a whole **icon collection** (21 icons): all stored in the shared library
  (`ASSETS.md`); green-line variants preferred; flame and calendar as the reference; header decoration from the
  library (one asset direction for the whole app, future note in `ASSETS.md`).

## 3. v1 (2026-11-25)
Code: `app_flutter/lib/challenges/challenge_data.dart` (mock data), `daily_challenges_screen.dart` (screen, `StreakChip`
for 03). Review links: `?challenges=1`, `&chalDone=3`, `&streak=4`, `&slow=3`.

Geometry measured on the reference (u = 8.53 px, offsets from the centre of the 1683 px content box), `ChalMetrics`:
| Element | Reference (px at 853) | Built |
|---|---|---|
| Tiles | centres 199 … 1508.5, pitch ≈ 218; normal 172×179, open 187×184; centre y 465.5 | pitch 25.6u, 20.2×21.0u, open ×1.07, y 54.6u |
| Connector | y 454–461, pale core #FFE451 + glow | y 53.6u, 0.55u core + blurred glow, lit up to the open tile, dim track after (lines B of 03/05) |
| Icon / pill / coin | icon centre y ≈ 444; pill 111×44 at y 515; coin Ø 36 | 8.2u box at 51.7u; 13×5.2u at 60.4u; coin 4.2u |
| Streak capsule | 637–1064 × 615–778; disc Ø 103 at x 968 | 50×19.1u at 81.65u; disc 12u at +14.9u |
| Side lines | 410–615 and 1085–1275, y 694 | `GoldDivider` 24u at −38.3u / +39.4u |
| Title / divider / subtitle | ink 592–1202 × 166–229; diamond (895, 262); ink 630–1154 × 286–324 | 7.4u at 23.15u; 33.2u at 30.7u; 4.4u at 35.75u |
| Arch | dome apex ≈ 885, tails 330–1440 | 03 `header_arch.svg` 128×36u, top 0.6u, bottom fade (library arch: shape not identical) |
| Mosque, crescent | mosque 215–492 px, crescent 1250–1401 px | **screen 03 standard** (owner, v2): mosque 10.5u from the content's left edge, top 8u, 49u wide, 83% with the 03 ground fade; crescent + star 25.5u from the right edge, top 7.5u, 10.65×9.75u |

Check: overlay of the 1844×853 capture on the reference (50/50 blend): tiles, pills, connector, capsule, side lines and
title coincide; mosque and crescent moved by overlay. Library arch and lattice differ in shape from the reference by
the owner's rule (one asset direction). Phone 915×412 checked (arch shoulder clear of the crescent after the fit).

Motion (PERFORMANCE.md): one entry controller (header fades down, tiles pop from the right 60 ms apart, scale 0.8 → 1
as Angular, light runs to the open tile, capsule rises); only the open tile's glow breathes, in its own builder;
completion (long press, review) 1.5 s: check badge pops, coin flies in an arc to the flame disc, light runs to the next
tile, its veil lifts, `Haptics.success` + `Sounds.fill`, `Haptics.unlock` at 62%; locked tap: shake + toast +
`Haptics.denied`. Widget test `daily challenges …` (12 tests pass).

## 4. v2 (2026-11-25)
- Owner: crescent + star and mosque must be **standard**: same place, size and treatment as the current screens.
  Now exactly as screen 03 (`ChalMetrics.mosque*`, `crescent*`, anchored to the content edges, as `courses_screen.dart`).
  The reference draws them a little differently (mosque ≈ 8u further right, crescent larger and lower): library standard
  wins (one asset direction, `ASSETS.md`).
