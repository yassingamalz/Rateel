# Design system (single source of style for the whole app)

The app must have **one consistent style direction**. Once the owner confirms a token here (colour,
gradient, shadow, glow, radius, rim, type size), every screen uses it.

**Conflict rule (owner, 2026-11-20):** when a reference screen asks for a value that differs from a
confirmed token (e.g. a different shadow or gold on screen 11 than on screen 04), Claude **does not copy it
silently**: it tells the owner "this conflicts with token X", shows both, and the owner decides (keep the
token, or change the token everywhere). The critic flags these conflicts in its report.

Code: `app_flutter/lib/theme/rateel_theme.dart` (`RateelColors` and the shared decorations). Every value
below must exist there under the same name; screens never hard-code a style value.

Confirmed by the owner with the side navigation (2026-11-20): the values in
`app_flutter/lib/theme/rateel_theme.dart` (`RateelColors`) and the measured token table in
`docs/flutter/screens/04-side-nav/critic-v3.md` (section "Design tokens"). Summary:

| Token | Value | Status |
|---|---|---|
| Panel / rail background | #053627 → #012E20 → #00281C (vertical) | ✅ |
| Edge bevel | 4 px, #1B4E37 / #295F45 / #134732 | ✅ |
| Glass capsule / tile | outline only, 2 px rim #245843 (rows) / #1C4E38 (tiles), no fill | ✅ |
| Gold rim (selected) | 1.2 px #DAA42A + 1 px inner #FFDA6B, glow gold 15% blur 2u | ✅ |
| Gold fill (count bubbles, active disc) | flat #E2A51E; pills #EDB120; text on gold #132C1A | ✅ |
| Selected row fill | flat #3B4C1F | ✅ |
| Active ring | 1.7 px #D8C35A, inner radial glow, outer glow gold 28% blur 2.4u | ✅ |
| Glass button (close) | same as the active ring: 1.7 px #D8C35A, radial gold glow 8%→24%, outer glow gold 22% blur 2u | ✅ |
| Text | Readex Pro; labels #FFFDF5 weight 340 size 4u; icons #FCF1D0 (menu) / #F4EAD0 (rail) | ✅ |
| Radii | row 4.1u, selected row 4.4u, tile 3.0u, menu button 2.4u, pills h/2 | ✅ |
| Content dimming under the open menu | 12% black (reference has none) | 🟡 |
