# Style conflicts: screens 03 / 05 / 06 vs the confirmed tokens (2026-11-24)

Audit of the code on `master` (all four screens merged) against `DESIGN-SYSTEM.md`. **Nothing was changed**:
the owner postponed the unification ("save everything for now, no interventions, we do it in the future").
Take this list when the unification session starts, ask the owner, then apply in `rateel_theme.dart` and the screens,
and run the critic without exclusions (desktop 1844×853 and phone 915×412).

| # | What | Confirmed token | Value in the screens | Proposal |
|---|---|---|---|---|
| C1 | Page background | `bgTop #063728 → bgBottom #00281C` | 03/05/06 `contentTop #07362A → contentBottom #00271D` (1–2 levels apart) | one token: `bgTop/bgBottom` |
| C2 | Glass rim | 2 px `#245843`, no fill | locked course card 4 px gradient `#2F6954→#559174`; «قريبًا» chips and toasts (05/06): solid `cardMid` fill + `cardRim #27654F` 0.23u | chips/toasts → `rowRim`; card rim = documented «card» token (to decide) |
| C3 | Gold rim | `#DAA42A` 1.2 px + `#FFDA6B` 1 px | active course card `#C69F3D/#D3A436` 4 px; unit ring `#EAAA16`, `#F8BC2C`, `#FFD54A`; lesson running light `cardRimGold` | lines = `goldEdge/goldHighlight`; card and unit ring as documented tokens (to decide) |
| C4 | Gold fill | `amber #E2A51E`, pills `#EDB120` | `badge #E5A416` (+`badgeTop #F8C343`), `progressFill #EBB335`, active lesson `#F1C23E→#D9A11C`, `gold #F2B623` as fill | badge → `amber`; progress → `amberPill`; active lesson → `amberPill→amber`; `gold` only for lines/glows |
| C5 | Text on gold | `countText #132C1A` | `badgeText #062016`, `origCardText #13261A`, `playGlyph #013321` | one `onGold #132C1A` |
| C6 | Text | labels `label #FFFDF5` w340 4u; titles `titleCream` ✅; descriptions `cream` ✅ | toasts/chips `titleCream` w450 4u; screen titles 9.3u (03) and 7.5u (05/06) | toasts → `label` w340; title scale 9.3u / 7.5u |
| C7 | Radii | row 4.1u, tile 3.0u, menu button 2.4u, pills h/2 | course card 4.7u (also lesson page); toast 3u; empty chip 4u; lesson card 3.2u; course pill 3.05u fixed | toast 3.0u; chip 4.1u; lesson card 3.0u; pill h/2; course card 4.7u «card» token |
| C8 | Shadows | `railShadows` | cards black 40% blur 2.2u y 0.6u (03 = 06); discs/badges black 35% blur 0.8–1.2u; toasts 35% | tokens `cardShadow`, `smallShadow` |
| C9 | Line widths | – | side nav (04) uses fixed px (1.2 / 1.7 px), screens use u | nav → u |
| C10 | Content dimming under the open menu | 12% black (🟡, reference has none) | unchanged | owner to confirm |
