# Screen 29: profile (الملف الشخصي)

Branch `flutter/29-profile-v2` from `master` `c2dec63` (2026-11-27). Replaces the earlier attempts on `flutter/29-profile` and
`flutter/29-profile-approved` (APK 1.0.490, outside the process, from an old `master`).

## References (owner, 2026-11-27)
- `29-profile/reference-dark.webp` and `reference-light.webp` (1844×853), from ChatGPT. Owner: «procedi con
  l'implementazione esatta».
- Texts and data come from the app (LESSONS-LEARNED): the reference's values happen to match the app's mock user.

## What is built (v1)
- **Header:** arch (CR-01) with a soft glow, Quran emblem (CR-02), title «الملف الشخصي» with the cream title gradient,
  divider with the diamond, mosque and crescent + star, top corner lattice (03/12 standard), positions measured on
  the reference (`ProfMetrics`).
- **Identity card** (102–1591 × 218–457 px): pale-gold rim with a glow, avatar with the gold ring of 11 in front of a
  lattice arch, name, city with the gold pin, thin vertical divider, Quran on its stand under a glowing onion arch with a
  **yellow light on the floor** (owner, 2026-11-27).
- **Stats panel**: four glass tiles (glyph, label, divider with a diamond, number): النقاط, الدروس, الترتيب, أيام متتالية.
- **Level bar**: «المستوى» with the layers glyph, separator, pill «مستوى مبتدئ» with the star, lattice on the left.
- **Light theme**: the content follows the app's light setting (23) with the reference-light colours (`profL*`); the
  side rail stays dark (no light rail exists yet).
- **Motion:** header slides down, card and panel rise, tiles one after the other (70 ms), level bar last; one entry
  controller, nothing loops (PERFORMANCE.md).
- **Opened from** the first row of the settings list «الملف الشخصي» (23); back with a drag to the right or Android back
  (as 12). Review aids: `?profile=1`, `?theme=light`.

## Data (all mock today)
| What | Source |
|---|---|
| name, avatar, city, points, lessons, rank | the user of the leaderboard (`leaderboard_data.dart`, `isMe`) |
| streak | `dailyStreak` of screen 12 |
| starting level «مبتدئ» | `userStartLevel` (screen 30 onboarding will ask it) |

## Placeholders and differences from the reference
- **Quran on the stand**: placeholder `courses/course_01.webp` (gold rehal) until the owner's asset Q1
  (`prompts/29-profile/images-v1.txt`). The arch, its light and the floor glow are code.
- Glyphs: star (app), book (CR-02 outline), flame (`icons/flame_gold_01`), rank rosette and layers = Material icons in the
  reference gold (drawn glyphs if wanted).
- Avatar: the app's avatar of the user (`avatar_5`), not the reference's drawing.
- Measured after v1 (`tools/flutter-review/profile-measure.py`): every text and glyph within 4 px of the reference at
  1844×853, except the book glyph (5 px lower edge). Sheets: `29-profile/compare-v1.jpg` (reference left, Flutter right),
  `phone-v1-{dark,light}.jpg`. Critic not run (ask the owner first).
