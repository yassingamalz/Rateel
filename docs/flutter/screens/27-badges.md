# Screen 27: badges (الأوسمة)

Reference from the owner (2026-11-27): `27-badges/reference.webp` (1843×853). Angular origin:
`gamification/achievements` (`badges-collection`, `achievement-details-modal`, 5 achievements bronze → diamond in
`gamification.service.ts`, grouped by lessons / progress / streak). Rail item «الإنجازات» (section 4) is a placeholder
today (`main.dart`). Not started: waiting for the owner's answers; screen 28 is built first.

## Layout of the reference
- Header: 11 ribbon with the title «الأوسمة» (reuse A1 `ribbon.webp`, title drawn as on 11), subtitle with the gold
  diamond dividers, lattice band at the top (reuse 11 `lattice.webp`).
- Right panel (gold rim): filter tabs «الكل / مكتسبة / غير مكتسبة» (11 tabs style), grid 4×2 of badge tiles (medal, name,
  ✓ ring when earned, gold rim + glow on the selected tile; locked = olive medal with padlock).
- Left panel with an arch top: selected badge large, name, description, progress bar «34 / 50», divider, reward box
  «المكافأة» with the 11 gold coins and «5K».
- Side rail: the app's rail (the reference draws an older one with the trophy selected: we keep ours, «الإنجازات» selected).

## Assets
- Needed: **B1** earned medal base (empty disc), **B2** locked medal (prompts `prompts/27-badges/images-v1.txt`);
  the badge icons (Quran on rehal, microphone, open book, ق, …) once the list of badges is decided.
- Reused: ribbon A1, lattice A2, coins A3, check glyph, 11 tabs, progress bar of 03.

## Questions for the owner
1. Which badges: the reference's 8 (قارئ متقدم، إتقان التلاوة، خبير المخارج، خاتم الوحدة، محترف الأحكام، متقن الغنة، صوت جميل،
   متميز في المراجعة) or the Angular 5 (بداية الرحلة … سيد التجويد)? With which requirement and reward each? (mock data)
2. Is this the screen of the rail «الإنجازات» (13 and 27 together), or a part of 13?
3. Medal icons: base B1 + icon added by the app (one base, any number of badges) or one full medal per badge?
4. Tap on a tile selects it in the left panel (as the reference); earned badge: a celebration the first time?
5. More than 8 badges: the grid scrolls, or pages?
