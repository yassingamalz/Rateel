# Screen 27: badges (الأوسمة)

**Status (2026-11-27): built**, waiting for the owner's review. Code: `app_flutter/lib/badges/`; medals keyed by
`tools/assets/badge_assets.py`; tests `app_flutter/test/badges_test.dart`; captures `tools/flutter-review/badges-capture.js`,
`badges-earn-frames.js`. Two medal engravings arrived (brown = default, dark green via `?medals=green`).

Branch `flutter/27-badges` (2026-11-27), from the screen-24 branch (it carries the refreshed app screenshots and the
owner's references). Reference from the owner: `27-badges/reference.webp` (1843×853). Angular origin:
`gamification/achievements` (`badges-collection`, `achievement-details-modal`, 5 achievements bronze → diamond in
`gamification.service.ts`). History: `27-badges/HISTORY.md`.

## Owner's answers (2026-11-27)
- **Badges: Claude decides** (list below, mock data).
- Medals: **one full medal per badge**, generated with ChatGPT (prompts M01–M12 + locked L1, `prompts/27-badges/images-v2.txt`).
- A **small celebration** the first time a badge is earned.
- More than 8 badges: the grid **scrolls**.
- Q2 (not understood, proposal): the screen opens from the rail item «الإنجازات» (section 4, a placeholder today); 13
  «achievements» and 27 «badges» are the same screen. To confirm.

## Badges (Claude, mock data in `lib/badges/badge_data.dart`)
| # | Name | Requirement (description) | Reward | Mock state |
|---|---|---|---|---|
| M01 | بداية الرحلة | أكمل أول 5 دروس | 50 | earned |
| M02 | خاتم الوحدة | أكمل وحدة كاملة من أي مقرر | 100 | earned |
| M03 | إتقان التلاوة | أكمل 10 دروس استماع | 200 | earned |
| M04 | خبير المخارج | أكمل مقرر مخارج الحروف | 500 | earned |
| M05 | قارئ متقدم | أتمم 50 درسًا في أساسيات التجويد | 5K | 34 / 50 |
| M06 | المواظب | تعلّم 7 أيام متتالية | 300 | 4 / 7 |
| M07 | متقن الغنة | أجب إجابة صحيحة عن 20 سؤالًا في الغنة | 300 | 6 / 20 |
| M08 | محترف الأحكام | أكمل مقرر أحكام النون والميم | 1K | 0 / 1 |
| M09 | صوت جميل | سجّل 10 تلاوات (needs screen 09) | 500 | 0 / 10 |
| M10 | متميز في المراجعة | أعد 10 دروس مكتملة | 300 | 2 / 10 |
| M11 | المتفوق | احصل على علامة كاملة في 5 اختبارات | 1K | 1 / 5 |
| M12 | سيد التجويد | أكمل جميع المقررات | 10K | 0 / 12 |
Order of the grid: earned first, then by progress. Selected at start: the first badge in progress (M05), as the
reference's left panel shows 34 / 50. «+n» earned is not a «!» text (owner: no «!»).

## Layout of the reference
- Header: 11 ribbon with «الأوسمة» (reuse A1 `ribbon.webp`, arched title as 11), subtitle «مجموعة الأوسمة التي تحصل عليها في
  رحلتك في تعلم التجويد» between gold diamond dividers, lattice band at the top (11 `lattice.webp`).
- Right panel (gold rim): filter tabs «الكل / مكتسبة / غير مكتسبة» (selected = gold), grid 4 columns of tiles (medal,
  name, ✓ ring when earned; selected tile: gold rim + glow; locked: olive medal L1), scrolling vertically.
- Left panel with an arch top: selected medal large, name, description, progress «n / N» with the bar, divider,
  reward box «المكافأة» with the 11 gold coins and the value.
- Side rail: the app's rail with «الإنجازات» selected (the reference draws an older rail).

## Motion (proposal, to confirm on the visual plan)
- Entry as 11: header and panels fade/rise, tiles pop in staggered (40 ms).
- Tap a tile: selection rim glides, left panel cross-fades to the badge, progress bar fills to its value, `Haptics.tap`.
- Filter tab: tiles re-order with a short fade.
- Badge earned (first time; review aid `?earn=5`): the locked medal turns gold (padlock flies off as on 05), short gold
  burst, the check ring pops, `Sounds.passed` + `Haptics.success`. No endless animation (PERFORMANCE.md).

## Assets
- Needed from ChatGPT: **M01–M12** earned medals, **L1** locked medal (`prompts/27-badges/images-v2.txt`).
- Reused: ribbon A1, lattice A2, coins A3 (11), check glyph, gold rim tokens, 03 progress bar.

## Screen 28 (help overlay): postponed
Owner 2026-11-27: future improvement (`BACKLOG.md`); answers kept there.
