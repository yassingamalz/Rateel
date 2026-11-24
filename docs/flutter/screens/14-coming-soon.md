# Screen 14: coming soon (ميزات تجويد القرآن قريباً)

Branch `flutter/14-coming-soon` (opened 2026-11-24 from `master` + the performance docs). Status: **assets requested**,
plan to be confirmed by the owner before building.

- Reference: `screens/14-coming-soon/14-in-arrivo.webp` (copied from `lesson-production`,
  `docs/design/glassy-gamified/screens/`), 1844x853. Angular original: `src/app/shared/components/coming-soon/` (texts,
  entry animations). Routes using it in Angular: `quran`, `practice`, `certificates` (rail items 114, 2, 3); in Flutter it
  replaces `lib/screens/section_placeholder.dart` for those items.
- Layout: side rail (04) on the right; emblem + two-line title (cream / gold) + `GoldDivider` + subtitle on the right
  column; 2x2 glass cards on the left (lobed gold badge with a cream glyph, title, short gold rule, description); girih
  corner top left, thin gold arcs, mosque silhouette bottom right.
- Already in the app: side nav, background and girih (`ScreenGirih`), `mosque.webp`, `GoldDivider`, card glass tokens,
  Readex Pro.
- Assets asked to the owner (ChatGPT): `prompts/14-coming-soon/images-v1.txt` E1 emblem, E2 badge frame, E3–E6 glyphs.
  The gold arcs are drawn in code.
- Motion (Angular, light): cards rise in staggered (150 ms), emblem scales in; no endless animation over the whole screen
  (`PERFORMANCE.md`).
- Open questions for the owner: same texts for the three sections or one title each; keep or drop the floating shapes.
