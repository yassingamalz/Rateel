# Style conflicts register (whole project)

**Single register of every conflict between a reference and the confirmed tokens** (owner, 2026-11-24): every screen adds
its conflicts here, with the value built provisionally. The owner decides them **one by one at the end of the project**;
until then nothing is unified. Sections: screens 03/05/06 (C1–C10), screen 11 (K1–K6).

## Screens 03 / 05 / 06 vs the confirmed tokens (2026-11-24)

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

## Screen 11, leaderboard (2026-11-24)
Measured on `screens/11-leaderboard/reference.webp`. **Owner, 2026-11-24 (v5): the leaderboard matches the reference**
(gold brightness, title, text): K1, K3, K6, K7, K8, K9, K10, K11 are built with the **reference values** (`leader*` tokens);
the last column below is the original proposal. Decide at the end of the project whether the tokens or the reference win app-wide.

| # | What | Confirmed token | Reference value | Built provisionally |
|---|---|---|---|---|
| K1 | Panel rim | gold rim 1.2 px #DAA42A + 1 px #FFDA6B, glow 15% | ≈ 4 px gold, core #FFF878/#FDE55F, edge #A18C34, soft gold glow outside | token rim in u (thinner than the reference) |
| K2 | Current-user bar fill | selected row fill #3B4C1F (olive) | green #185727 → #0A4322 → #14431C, gold rim + glow | reference green as `meRowTop/meRowMid/meRowBottom`, rim = gold rim token |
| K3 | Active tab | flat gold #E2A51E | vertical gradient #A47915 → #E5A71C | flat `amber` + gold rim token |
| K4 | Background | `bgTop #063728 → bgBottom #00281C` | flat #00251C … #0A2F1E + gold lattice | `bgTop/bgBottom` + lattice (same as C1) |
| K5 | Rows | glass rim 2 px #245843, no fill | fill #052B1D/#02291E getting lighter downwards, light edge at the **bottom** (#7CA078, critic v1), no visible rim | `rowRim` in u, fill `cardTop → cardMid` |
| K6 | Rank disc «15» | `amber #E2A51E`, `countText #132C1A` | #EEB326, text #0B2315 | tokens (critic option: the screen 02 paused-button gold `badgeTop → amber`) |
| K7 | Glow of the panel and the pinned bar | gold glow 15% | ≈ 35% gold over ≈ 2.5u (critic v1) | token 15% |
| K8 | Chevron button | glass button: ring 0.2u #D8C35A, gold radial fill | ring 0.5u #FFDC4A, dark inside (critic v1) | glass button token |
| K9 | Text cream | `titleCream #FAF1D8` | #FDFBDB … #FFFEDE (critic v1) | **reference value** `leaderText #FFFBDC` (owner 2026-11-24: brightness as the reference) |
| K10 | Title in the ribbon | screen-title gradient `titleTop #FFFBEA → titleBottom #E9D7A8` | warm gold-cream ≈ #F5E9B4 | **reference value** `leaderTitleTop #F8F0C6 → leaderTitleBottom #F1DFA2` (owner 2026-11-24) |
| K11 | Gold glyphs and art | star `glyphGoldTop #FFD556 → glyphGoldBottom #EFB527`; medals/coins as drawn | star #F0B42C → #F4B81C; medals/coins warmer and darker | **reference**: `leaderStar`, `leaderArtTone` modulation |
