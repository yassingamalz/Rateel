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
| Rail / menu shadow on the content | black 45% blur 3.2u offset x −0.9u + black 30% blur 0.8u offset x −0.25u (`railShadows`) | ✅ |
| Content dimming under the open menu | 12% black (reference has none) | 🟡 |

Proposed with screen 03 (courses), waiting for the owner (`RateelColors`, section "Screen 03"):

| Token | Value | Status |
|---|---|---|
| Content background | radial #07362A (top centre) → #00271D | 🟡 |
| Course card | radius 4.7u; fill #033428 → #012F25 (50%) → #023126 (72%) → #053F30; shadow black 40% blur 2.2u y 0.6u + 1.5 px #00160C contact line | 🟡 |
| Locked card rim | 4 px vertical #2F6954 → #27654F → #559174 | 🟡 (conflict: glass rim token is 2 px #245843) |
| Active card rim | goldRim 1.4 px + goldHighlight 2 px, breathing gold glow 0–10% | 🟡 (conflict: selected rim is #DAA42A 1.2 px + #FFDA6B 1 px) |
| Path | line 3 px #D1A93C on track #265343; node #FCC24A r 1.3u with gold glow | 🟡 |
| Progress | track #265343, fill #EBB335, h 1.4u | 🟡 |
| Pill | outline gold 2 px, fill #062D20, text gold 3.3u | 🟡 |

Proposed with screen 02 (lesson top bar), approved on the mockup by the owner (2026-11-24), `RateelColors` section "Screen 02":

| Token | Value | Status |
|---|---|---|
| Lesson capsule | 41×6.2u, radius h/2, rim max(1 px, 0.12u) `cardRimTop #2F6954`, fill `cardTop → cardMid`, inset shade 0.2u, card shadow | ✅ (mockup) |
| Lesson progress gold | `#FFD95A → amberPill #EDB120 (55%) → #D9A11C`, glow gold 45% σ 0.8u, leading light `lessonBarLight #FFF3C2` 2.2u, sheen white 28% | ✅ (mockup) |
| Lesson glass button | 9u, glass button token with the glow **outside the circle only**; paused: `badgeTop → amber`, rim `goldHighlight`, halo amber 25% 1.2u, pulse 0→1.8u | ✅ (mockup) |
| Lesson veil | `lessonVeil #00140E` 45%, blur σ 0.55u, content 98% and 80% brightness | ✅ |

## Tajweed colours (owner, 2026-11-25), confirmed ✅
Source: the owner's colour wheel «قواعد ألوان التجويد», `docs/design-assets/reading-lesson/tajweed-colours-wheel.jpg`,
sampled. Code: `TajweedColors` in `app_flutter/lib/lessons/reading_data.dart`. Same colours in both themes; black is the
normal text colour, so those words take the theme's ink. Every screen that colours tajweed uses this table.

| Colour | Value | Rules |
|---|---|---|
| Black (text ink) | #2B2321 | الإظهار، مد الطبيعي والعوض والبدل |
| Yellow | #FFD231 | مد الصلة الصغرى، الألف الخنجرية |
| Orange | #F08237 | مد اللين والعارض للسكون |
| Red | #CD1518 | مد الصلة الكبرى، مد الواجب (المتصل، المنفصل) |
| Purple | #8E4590 | مد الفرق، مد اللازم |
| Dark blue | #013ED7 | تفخيم الراء |
| Blue | #0B71BB | تفخيم |
| Cyan | #07D3DA | قلقلة |
| Green | #43B76E | الإدغام بغنة، إدغام المتماثلين بغنة، الإقلاب، النون والميم المشددتين، إخفاء شفوي، إخفاء حقيقي |
| Grey | #AAA4A5 | الإدغام بدون غنة، إدغام المتجانسين، إدغام المتقاربين، المرسوم خلاف اللفظ، همزة الوصل، ألف التفريق، اللام الشمسية |

