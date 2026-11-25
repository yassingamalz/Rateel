# Screen 14, coming soon: history

## v1 (2026-11-24)
- Owner: "be faithful to the visual reference, replicate it with what I gave you, go".
  Decisions taken from that: **same texts for Quran, training and certificates** (as the reference and Angular);
  **no floating shapes** (not in the reference); the owner's whole background `08_emerald_background.png` is used
  (arcs, girih corners, waves, mosque), drawn over the content box (`BoxFit.fill`, about 9% narrower at 1844×853)
  and darkened to the reference (`soonBgTone`).
- Code: `lib/coming_soon/coming_soon_screen.dart`, shown for rail items 1 (القرآن), 2 (التدريب), 5 (الشهادات)
  (`main.dart`); item 4 (achievements) stays a placeholder until screen 13. Review link: `?section=1`.
- Motion (Angular): emblem scales 0.5 → 1 and turns −15° → 0 (easeOutBack), titles rise 40 px, cards rise 30 px
  150 ms apart. One controller played once, no repeat; every card and the background in a `RepaintBoundary`
  (`PERFORMANCE.md`).
- Verified element by element (`tools/flutter-review/coming-soon-verify.py`, output `verify-v1.txt`):
  card boxes, rules, descriptions of card 2 within ±2 px; title lines cream y 333–407 (= reference), gold 412–507
  (reference 415–505); subtitle ±3 px; badge frames 112×120 vs 113×123, glyphs within ±4 px.
- Differences left (to show the owner):
  1. Divider ornament: the reference has a small quatrefoil flower with tiny diamonds on the lines; the app uses the
     shared `GoldDivider` of screen 07 (open diamond) at 1.2×.
  2. Title font: Readex Pro (app font) is taller and ~5% narrower than the reference's lettering at the same height.
  3. Card titles/descriptions use one style for all cards; the reference's lettering varies by ±8% between cards.
  4. Emblem inside is the owner's flat green; the reference's is a little more transparent with a soft glow.
- Captures: `capture-v1.png` (1844×853), `capture-v1-phone.png` (915×412), `compare-v1.png` (reference above).
- APK 1.0.373 (2026-11-25).

## v2 (2026-11-25)
- Owner, after APK 1.0.373: (1) Mushaf emblem darker, more saturated gold, darker green, shown before use;
  (2) the top cards feel taller than the bottom ones; (3) font closer to the reference.
- Emblem: three tone proposals (`v2-proposals/emblem-proposals.png`: A light, B medium, C strong; HSV: gold
  saturation ×1.15/1.3/1.45 and value ×0.93/0.86/0.80, green value ×0.85/0.72/0.60, cream ×1/0.96/0.92). **Owner chose
  B**; `ui/coming_soon/quran_emblem.webp` replaced (v1 = the keyed `01_quran_emblem.png` in `docs/design-assets/`).
- Font: 10 Google fonts compared with the reference (`v2-proposals/font-proposals.png`). **Owner chose Cairo**
  (variable, OFL, `assets/fonts/Cairo.ttf`, helper `cairo()`), for this screen only (style conflict S4).
  Sizes re-measured: title 9.6u, card titles 4.9u w700, descriptions 3.3u, subtitle 3.95u height 1.25.
- Cards: measured again, all four are 466×337 px with equal margins (top 77, bottom 76) and gaps (26–27 px), as the
  reference; no geometric difference found. Asked the owner for a phone screenshot of what looks different.
- Verify (`verify-v2.txt`): card texts within ±10 px in width, ±4 px vertically; title cream 334–411 (ref 333–407),
  gold 413–508 (ref 415–505); subtitle ±3 px.
- APK 1.0.375 (2026-11-25).
