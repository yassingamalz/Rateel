# Screen 02 (shared lesson top bar): critic v1 (2026-11-24)

Reviewer: separate critic sub-agent (did not write the code). Rules: `docs/flutter/CRITIC.md` (measured, no exclusions).

- **Reference:** owner-approved HTML mockup v3 (`reference/F-2.png`, `F-9.png`, `F-16.png`, `F-menu-strong.png`,
  `F-2-phone.png`; source `tools/flutter-review/lesson-bar-mockup-v3.html`). Behaviour reference: Angular
  `lesson-details` (`angular-original.jpg`, `src/app/features/lessons/lesson-details/*`).
- **Result:** `capture-v1-step1/2/9.png`, `capture-v1-paused.png` (paused at 9/16) and the `-phone` captures
  (915×412 @ dpr 2.625 = 2402×1082). Extra captures made by the critic (scratchpad, not committed): 16/16,
  eight frames of the pulse, the completion sweep with `?slow=10`.
- **Code:** `app_flutter/lib/lessons/lesson_shell.dart`, `lesson_page.dart`.
- Units: u = 1% of the image height = 8.53 px at 1844×853 (4.12 px on the 412 px phone reference, 10.82 device px
  on the phone capture). Colours sampled from the pixels with PIL (scripts `m1.py`…`m8.py` in the critic scratchpad).
- Not scored (owner ✅): option A full-fill capsule, step counter «n/N», side rail hidden, restart kept, entry/exit
  slides + light sweep + haptic (DECISIONS 2026-11-24, round 1); button 9u, capsule 41×6.2u, number 3.2u, strong veil
  `#00140E` 45% + blur 0.55u + content 98% / 80% brightness, code-drawn icons (DECISIONS 2026-11-24, approval of v2).
  The central placeholder card is not part of screen 02 and is not scored.

## 1. Measurements (reference vs Flutter, 1844×853)

| Element | Reference (mockup v3) | Flutter v1 | Match |
|---|---|---|---|
| Capsule bounds | x 26–374, y 38–89 (rim pixels) → 41.0×6.1u at left 3.0u, top 4.45u | x 26–374, y 38–89 | ✓ |
| Capsule radius | h/2 = 3.1u | h/2 | ✓ |
| Capsule rim | **1 px** crisp `#2F6954` (0.23u = 1.96 px snapped to 1 px by Chrome) | **~2 px**: `#154334` / `#2F6954` / `#184638` (y 37–39); over the gold it blends to olive `#96A055` / `#7A823C` | ✗ heavier |
| Dark fill, top inner shadow | `#02231B` at y39 → `#023226` at y44: **~5 px (0.6u)**, plus a faint darkening at the bottom (`#002B22` at y88) | `#01231B` at y40 → `#023227` at y61: **~21 px (2.5u)**; none at the bottom | ✗ |
| Dark fill, mid / bottom | `#023327` / `#013025` | `#023126` / `#012F25` | ✓ |
| Capsule drop shadow | below rim `#001D16` (y90) → `#002119` (y95) | `#011F17` (y91) → `#02221A` (y95) | ✓ |
| Gold fill gradient | top `#FFD859`, 55% `#EDB120`, bottom `#D9A11C` | top `#FDD454`, 55% `#EDB120`, bottom `#DCA31C` | ✓ |
| Fill edge (9/16) | x 179 | x 179 | ✓ |
| Leading-edge light | `#FDEBAB` → `#F9D777` over 16–17 px (2.0u) | `#FEEDB3` → `#F9D878` over 17 px | ✓ |
| Fill glow into the dark part | **yes**: 17 px (2.0u) ramp left of the edge, `#023327` → `#314B25` (y50), `#012F25` → `#264324` (y84) | **none** (dark part unchanged up to the edge) | ✗ |
| Leading light at 16/16 | still drawn at the left end (cream fade at the left cap) | not drawn when share = 1 | ✗ (small) |
| Sheen | inside the fill: 4%…96% of the **fill** width, y 43–56 (8%…36% of the inner height), radius 9 px | 4%…96% of the **capsule** width clipped to the fill, y 41.5–55.5 | ~ (1.5 px higher, reaches the leading edge) |
| Number «2/16» | 57×22 px, centre (200.0, 65.5), cream `#F9F8F0`, 381 ink px | 57×23 px, centre (200.0, **63.0**), `#F8F7EF`, **443** ink px | ~ (0.3u higher, ~16% heavier: w520 vs w500) |
| Number split at the fill edge | cream left of x179, `#132C1A` on the gold | same | ✓ |
| Pause button | Ø 76 px (8.9u), centre (1780, 64), top/right 3u | same | ✓ |
| Button ring | 1 px `#CDBB57` (0.2u snapped to 1 px) | ~2 px `#D8C35A` (1.7 px, token) | ~ (token, see §3) |
| Button glass fill | radial: centre **`#14331F`** → inner edge **`#2E431E`** | centre **`#455020`** → edge **`#525920`** (nearly flat, ~3× brighter) | ✗✗ |
| Button outer glow | visible ~14 px (1.6u), `#14341F` at the rim → bg at 1726 | visible ~20 px (2.3u), `#15351F` → still `#022B1F` at 1722 | ~ slightly wider |
| Pause glyph | 17×21 px (2.0×2.5u), centre (1780, 64), `#F8EECD` | 18×20 px, centre (1779.5, 63.5), `#FBF0CF` | ✓ |
| Menu: gold button fill | `#F8C444` top → `#E3A61F` bottom, rim `#FFDA6B` | `#F7C141` → `#E3A620`, rim `#FFDA6B` | ✓ |
| Menu: gold halo ring | **static 1.2u ring** gold 25% (`#454719`…`#5B561A`, crisp outer edge at 1.2u) + glow 2.4u 45% | **no static ring**; glow only (`#2C3617` at the rim, fading); Angular pulse ring visible in ~4 of 8 frames (0→1.8u, alpha 0.55→0) | ✗ |
| Menu: play glyph | 19×23 px, centre (1782, 64), `#152D19` | 18×22 px, centre (1781.5, 63.5), `#132C1A` | ✓ |
| Menu: back (→) | centre (1689.0, 63.5), 27×24 px, `#F5F6F6` | centre (1689.5, 63.5), 28×24 px | ✓ |
| Menu: restart (↻) | centre (1599.0, 63.0), 27×27 px | centre (1598.5, 62.5), 26×28 px | ✓ |
| Menu gaps | 1.6u (13.6 px) between circles | 1.6u | ✓ |
| Menu: glass item fill | centre `#1A3018` → edge `#2E3B19` | flat `#4E4E19`…`#525019` | ✗✗ (same cause as the pause button) |
| Veil on the background | G 51 → 37 (×0.73) at (900,150); 39 → 30 at (100,800) | G 51 → 32 (×0.63); 42 → 28 | ~ 13% darker (background inside the filtered content) |
| Blur on the content | edge spread ~12 px (card rim at y426) | ~13 px | ✓ (0.55u ✅) |
| Bar under the veil | bar not veiled | not veiled | ✓ |
| 16/16 | full gold, «16/16» dark centred | same (except the left-end light) | ✓ |
| Phone 915×412 | capsule 25 px tall, rim 1 px; button Ø 37 px | capsule 25.5 css px; rim 2.5 device px; button Ø 37 css px; same proportions; same bright glass fill | ✓ / ✗ fill |

## 2. Differences

| # | Severity | Type | Element | Reference | Flutter | Fix |
|---|---|---|---|---|---|---|
| 1 | **high** | code | Glass fill of the pause button and of the back / restart items | dark radial: centre `#14331F`, inner edge `#2E431E` (gold 8%→24% over the background) | almost flat olive `#455020`…`#525920`: the `BoxShadow` (gold 22%, blur 2u) is painted as a full disc **under** the translucent fill and shows through it (CSS box-shadow is not drawn under the element) | Paint the outer glow only outside the circle: a `CustomPainter` that clips out the circle (`canvas.clipPath(Path.combine(difference, rect, circle))`) before drawing the blurred disc, or `BoxShadow(blurStyle: BlurStyle.outer)`. Also give the radial gradient `radius: 0.707` (CSS `circle` = farthest-corner) so the edge reaches ~19% as in the mockup. Same problem in the 04 close button and the 06 back button: see §3. |
| 2 | medium | code | Gold (paused) button halo | static ring 1.2u, gold 25%, plus glow 2.4u 45% (mockup `box-shadow: 0 0 0 1.2u …, 0 0 2.4u …`) | no static ring; only the pulse (ring 0→1.8u, filled, alpha 0.55→0, invisible 30% of the cycle) | Draw the static 1.2u ring at `gold` 25% (×goldness) under the button, keep the Angular pulse on top of it (it grows from the ring). |
| 3 | medium | code | Capsule inner shadow at the top | ~0.6u, `#02231B`→`#023226`, plus a faint shadow at the bottom (CSS inset 0 0.2u 0.5u black 45%) | 2.5u black 35%→0 gradient: the top half of the empty part looks hollow | Replace the 45%-height gradient by an inset shadow: stroke the inner rrect offset 0.2u down with black 45%, `MaskFilter.blur(normal, 0.25u)`, clipped to the capsule (or a 0.7u gradient at the top + 0.3u at the bottom). |
| 4 | medium | code | Gold glow into the empty part | 2.0u gold glow left of the fill edge (`#314B25` next to the edge at y50) | none: the edge is cut sharp against the dark glass | Before the fill, draw the fill rect with `MaskFilter.blur(normal, 0.8u)` in gold 45% (mockup `box-shadow 0 0 1.6u rgba(242,182,35,.45)`), clipped to the capsule. |
| 5 | medium | code | Capsule rim weight | 1 px crisp `#2F6954` | ~2 px antialiased (0.23u); olive pixels where it crosses the gold | Rim 0.12u (≈1 px at 853, ≈1.3 px on the phone), still in u (DECISIONS 2026-11-21 line widths in u). |
| 6 | medium | code | Completion race | — | `_finish` waits 320 ms + 900 ms then `pop(true)` if `mounted`; a tap on «back» (or Android back + back item) in that window pops the route with `false` and the delayed `pop(true)` then pops the **lessons screen** too (the state is still mounted during the 500 ms exit). The pause menu can also be opened during the sweep. | Block the controls while finishing (`controlsVisible`-like `IgnorePointer`, PopScope no-op) and guard the pop with a `_left` flag / `ModalRoute.of(context)?.isCurrent`. |
| 7 | medium | code | Android back with hidden controls | Angular: `hideControls` hides the whole control area | `PopScope` still toggles the pause: back shows the veil and blur with no buttons visible (only a tap on the veil resumes) | When `controlsVisible` is false, Android back does nothing (or goes straight to `onBack`). |
| 8 | medium | code | Touch target on the phone | Angular 64 px | 9u = 37 dp on a 412 dp phone (< 48 dp minimum); items the same | Keep the drawn size, enlarge the hit area to ≥ 48 dp (transparent padding around the `GestureDetector`, items included). |
| 9 | low | code | Number position / weight | centre y 65.5 (2 px under the capsule centre), w500, 381 ink px | centre y 63.0, w520, 443 ink px | Lift 0.0u instead of 0.25u (or 0.05u), weight 500. |
| 10 | low | code | Sheen | relative to the fill: 4%–96% of the fill width, top at 8% of the inner height (y43) | relative to the capsule, clipped by the fill; starts at y41.5 and runs up to the leading edge | Compute the sheen rect from the fill rect (`fill.left + 0.04·fw`, width 0.92·fw, top 8% of h−2·rim). |
| 11 | low | code | Leading light at 16/16 | drawn at the left end | omitted when share = 1 | Keep drawing it at the left end (the sweep then runs over it). |
| 12 | low | code | Veil over the background | background not brightness-filtered (G 37 at (900,150)) | background inside the filtered content (G 32) | Acceptable for real lessons (the lesson owns its background); otherwise move `ScreenBackground` out of the filtered child. |
| 13 | low | code | Glow of the glass buttons | ~1.6u visible (CSS sigma = 1u) | ~2.3u (Flutter `blurRadius` 2u → sigma ≈ 1.15u + 0.5 px) | `blurRadius: u * 1.75` (or a `MaskFilter` with sigma 1u when fixing #1). |
| 14 | low | code | Gold ↔ glass transition | — | at goldness > 0 the fill jumps from the radial 8→24% to a linear 14→20% gradient | Lerp both stops of the same radial gradient towards the gold linear one, or cross-fade two layers. |
| 15 | low | code | Pulse | Angular: ring 0→15 px (1.76u) at alpha 0.7, 2 s | 0→1.8u, alpha 0.55 | Alpha 0.7 (× goldness), drawn outside the circle only. |
| 16 | low | code | Completion exit | Angular 100 ms + exit slide 300 ms | sweep 900 ms (✅) + exit slide 500 ms | Optional: 300 ms reverse duration on completion. |
| 17 | low | code | Restart closes the menu | Angular keeps the menu open after restart | closes it and resumes | Improvement; mention to the owner. |
| 18 | low | code | Veil tap | — | resumes without haptic (the buttons give `Haptics.tap`) | Add `Haptics.tap()` for consistency. |

No asset items: all four glyphs are code-drawn by owner decision (✅ 2026-11-24) and match the mockup within 1 px.

Behaviour checked and correct: step/total and the fill tween (300 ms ease-out), pause/play swap (AnimatedSwitcher at
menu 0.5), pulse 2 s loop while paused, items slide out from under the button (300 ms, easeOutCubic, opacity,
1.6u gaps), restart → step 1, back → `pop(false)` with the 500 ms ease-in slide to the right, veil tap resumes,
Android back opens/closes the menu, entry slide down 500 ms ease-out, completion: fill to 100% → light sweep
(right → left, 9u band, captured at `?slow=10`) + `Haptics.milestone` → `pop(true)`, `controlsVisible` fades bar and
buttons (250 ms) and blocks their taps.

## 3. Conflicts with confirmed tokens (for the owner, not fixed silently)

| # | Token (status) | Screen 02 | Note |
|---|---|---|---|
| C1 | Glass button (close) ✅: 1.7 px `#D8C35A`, radial gold 8%→24%, outer glow 22% blur 2u | Flutter 04 close button (and the 06 back button) use the same `BoxShadow` under a translucent fill, so on the phone the approved close button already shows the bright olive fill that #1 removes here | Fixing #1 only on screen 02 makes the 02 buttons darker than the 04 close button. The token text and the approved 02 mockup describe the darker glass: **owner to decide** whether #1 is applied app-wide (04, 06) or the brighter look becomes the token. |
| C2 | Glass ring ✅ 1.7 px / line widths in u ✅ (2026-11-21) | mockup renders rims at 1 px (Chrome snaps 0.2u / 0.23u borders) | The buttons keep the token (low, not listed as a defect); the capsule rim (#5) is not a confirmed token, so it follows the reference. |
| C3 | Glass capsule rim ✅ 2 px `#245843` (rows) | capsule rim `cardRimTop #2F6954` (03 token 🟡), approved with mockup v2 | Informational: approved by the owner on the mockup; to fold into the style unification (`STYLE-CONFLICTS.md`). |
| C4 | Content dimming under the open menu 🟡 12% black | strong veil `#00140E` 45% + blur | Owner chose the strong veil for lessons (✅ 2026-11-24); the side-nav 12% stays a separate token. |
| C5 | Gold fill ✅ flat `#E2A51E`, pills `#EDB120` | capsule gold gradient `#FFD95A → #EDB120 → #D9A11C`; paused button `#F8C343 → #E2A51E` | Approved on the mockup; gradients are not in `DESIGN-SYSTEM.md` yet: add as screen-02 tokens. |

## 4. Scores

| Area | Score | Why |
|---|---|---|
| Bar look | **7.0 / 10** | Geometry, gold gradient, leading light, number split, glyphs and positions match within 1–2 px; the glass buttons are ~3× too bright (high), the paused halo ring, the fill glow and the inner shadow are missing or wrong, rim twice as heavy. |
| Behaviour | **7.5 / 10** | All Angular behaviours present and the approved additions work; completion race (double pop), Android back with hidden controls and the small phone touch target to fix. |
| **Overall** | **7.2 / 10** | One high and seven medium code items; no asset items. |
