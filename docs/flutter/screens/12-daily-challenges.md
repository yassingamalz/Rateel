# Screen 12: daily challenges (رحلة التحديات اليومية)

Branch `flutter/12-daily-challenges` (opened 2026-11-25 from `master`). Status: **plan, waiting for the owner's yes**.

- Reference: `screens/12-daily-challenges/reference.webp` (copied from `lesson-production`,
  `docs/design/glassy-gamified/screens/12-sfide-giornaliere.webp`), 1844x853.
- Angular original: `src/app/features/gamification/daily-challenges/` + `services/daily-challenges.service.ts`
  (7 challenges: lesson/book, practice/microphone, recitation/quran ×2, then a trophy worth 100; only the first is open,
  completing one unlocks the next and adds its points; final bonus «مكافأة نهائية» 500 when all are done; streak
  «n يوم الاستمرارية»; nodes enter with scale 0.8 → 1, 300 ms). In Angular the screen is routed
  (`/gamification/daily-challenges`) but **no menu item reaches it**.
- Data: **mock**, like screen 11 (logged in `SCREENS.md`, «Screens running on mock data»): the Angular list of 7, streak 0.
  References are visual only: the icons follow the data (book, mic, quran…), not the reference's order.

## Layout (u = 1% of the height, measured at 1844×853; exact values at build time)
- Side rail (04) on the right, as every screen.
- Header: gold arch centred on the title (shared arch, 03/08), gold **calendar** emblem in the apex (D1), title
  «رحلة التحديات اليومية» (title gradient tokens), `GoldDivider(diamond)`, subtitle «أكمل التحديات واحصل على المكافآت».
  Mosque top left (`mosque.webp`), crescent + star top right, lattice corners top left/right, lattice band bottom
  left/right (shared assets).
- Path: **7 rounded-square glass tiles** (≈ 21×21u, radius ≈ 3u) in one row, first challenge on the **right** (RTL),
  joined by a short gold line with a glow. Each tile: cream glyph (≈ 7u) + gold-rimmed pill «50 🪙» (coin from Angular).
  Open tile: bright gold rim + outer glow; other tiles: thin dim gold rim.
- Streak: wide gold-rimmed capsule (≈ 33×14u) at the bottom centre, gold disc with the flame (D4) on the right,
  «n يوم» + «الاستمرارية»; thin gold lines with a diamond on both sides.

## States (Angular behaviour, reference look)
- **Open** (next to do): bright rim + glow, gently breathing (only this tile repaints, `PERFORMANCE.md`).
- **Locked**: as the reference, dim rim; question Q2 (padlock or not).
- **Completed**: gold check badge on the tile (as the 05 units), line to the next tile lit.
- **All done**: final bonus (question Q4).

## Motion and feedback
- Entry: header fades down, tiles pop in one after the other from the right (scale 0.8 → 1, 300 ms, Angular), the line
  lights up to the open tile, streak capsule rises.
- Completion (when returning from the challenge, or a demo long press as on 03): check badge pops, coin flies from the
  tile to the streak/points, light runs along the line, the next tile's rim turns gold (and its padlock pops if Q2 = yes);
  `Haptics.success`, `Sounds.fill`.
- Tap on a locked tile: shake + toast + `Haptics.denied` (as 03/05).

## Code vs assets
- Code: tiles, rims, glows, line, pills, capsule, flame disc, layout, motion.
- Reused assets: arch, mosque, crescent/star, corners, lattice band, coin (`src/assets/images/coin-icon.png`), microphone
  (`nav/training.svg`), trophy (`nav/leaderboard.svg`), headphones (`coming_soon/glyph_headphones.webp`).
- New assets (ChatGPT, `prompts/12-daily-challenges/images-v1.txt`): **D1** calendar, **D2** document glyph, **D3** Quran
  on a stand with crescent, **D4** flame.

## Questions for the owner
1. **How is the screen opened?** It has no rail item (not even in Angular). A) a 7th rail item; B) a streak/flame chip on
   the courses screen (03) that opens it; C) a tab or button on screen 13 (achievements); D) for now only a review link,
   decide later. Proposal: **D now, B later**.
2. Locked tiles: as the reference (dim, no padlock) or with the green padlock of 05/06? Proposal: **as the reference**.
3. What does tapping the open challenge do? Angular completes it at once (demo). Proposal: it opens the matching activity
   (lesson → next lesson to do; practice/recitation → screen 14 «coming soon» until 09 exists) and the challenge is
   completed when the user comes back having done it; for the review, a long press completes it.
4. Final bonus (500) when all 7 are done: Angular shows a «مكافأة نهائية» card; the reference has none. Proposal: the
   trophy tile is the bonus, a short celebration (light + sound) and no extra card.
5. Font: Readex Pro (app standard) or Cairo as on 14 (closer to the reference titles, conflict S4)? Proposal: Readex Pro.
6. Streak rule (mock for now): +1 for each day with at least one completed challenge, back to 0 after a missed day; the
   path resets at midnight. OK?
