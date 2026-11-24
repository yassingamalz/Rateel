# Screen 02 (shared lesson top bar): critic v2 (2026-11-24)

Reviewer: separate critic sub-agent (did not write the code). Rules: `docs/flutter/CRITIC.md` (measured, no exclusions).
Same reference (`reference/`, mockup v3) and the same measuring scripts as `critic-v1.md`, run on
`capture-v2-*.png` (v2 = commit 069ee92). Extra capture by the critic at 16/16 from the v2 web build (scratchpad).
Code re-read: `app_flutter/lib/lessons/lesson_shell.dart`, `lesson_page.dart`.
u = 8.53 px at 1844×853. Not scored (owner ✅, DECISIONS 2026-11-24): same list as v1 (option A full fill, «n/N»,
rail hidden, restart kept, motion + sweep + haptic, 9u button / 41×6.2u capsule / 3.2u number, strong veil with
blur 0.55u, code-drawn icons). The placeholder card is not scored.

## 1. v1 items: verification

| v1 # | Item | Reference | v1 | v2 | Status |
|---|---|---|---|---|---|
| 1 (high) | Glass fill of pause / back / restart | centre `#14331F`, edge `#2E431E`; menu items centre `#1A3018`, edge `#2E3B19` | `#455020`…`#525920` | pause centre `#15341F`, edge `#2D4320`; items centre `#1A2C16`, edge `#2D3817` | **fixed** |
| 2 (med) | Static 1.2u halo on the gold button | ring y 15–25 `#454719`→`#5B561A` | none | ring y 16–24 `#464518`→`#5A5119`, outer edge y≈15 | **fixed** |
| 3 (med) | Capsule inner shadow | ~5 px (y39 `#02231B` → y44 `#023226`) + faint bottom shade (y86–88) | 21 px | ~3 px (y39 `#022920` → y41 `#033125`); bottom only y88 `#012E24` | **fixed** in the empty part (slightly too short, low #L3) — but see new #N1 |
| 4 (med) | Gold glow into the empty part | x176 `#264524` (y50), 2u ramp | none | x176 `#264223`, ramp from x162 | **fixed** |
| 5 (med) | Capsule rim weight | 1 px crisp `#2F6954` | ~2 px | 0.12u = 1.02 px split over two rows: y37 `#154033`, y38 `#1B4B3C`; left x26 `#205443`; bottom y89 `#1E5242`. Phone: 1.3 device px (0.5 dp) `#235846` vs reference 1 css px `#2F6954` | **over-corrected** → new #N2 |
| 6 (med) | Completion race (double pop) | — | second `pop` could close the lessons screen | `_leave()` pops once and only when the route `isCurrent`; `celebrate()` closes the menu and sets `_locked` (bar `IgnorePointer`, Android back ignored) | **fixed** (a 320 ms unlocked window remains, low #L1) |
| 7 (med) | Android back with hidden controls | Angular hides the controls | veil without buttons | `PopScope` returns when `!controlsVisible` or `_locked` | **fixed** |
| 8 (med) | Tap target on the phone | ≥ 48 dp | 37 dp | `_GlassButton.extra(u)` = (48 − 9u)/2 → 5.5 dp padding on 412 dp, 0 on desktop; `HitTestBehavior.opaque`; drawn size unchanged (positions identical, ±0.5 px) | **fixed** (adjacent targets overlap, low #L4) |
| 9 (low) | Number position / weight | centre y 65.5, 381 ink px | 63.0, 443 | centre y **65.0**, w500, 436 ink px | position fixed; still ~14% more ink (renderer, low #L5) |
| 10 (low) | Sheen relative to the fill | top y43 | y41.5, capsule-relative | fill-relative (4%–96% of fw), top y43 (`#F9DC7E`) | **fixed** |
| 11 (low) | Leading light at 16/16 | left end `#FAE49E` (x29) → `#E9AF23` (x44) | missing | `#F2D98F` (x29) → `#E9AE1F` (x44) | **fixed** |
| 12 (low) | Veil on the background | G 37 at (900,150) | G 32 | G 32 (unchanged) | not fixed (low, #L6) |
| 13 (low) | Glass button glow | bg reached at x≈1726 | wider (`#022B1F` at 1722) | `#012A1F` at 1722, `#15351F` at the rim | **fixed** |
| 14 (low) | Glass → gold jump | — | radial → linear switch | cross-fade of both layers by goldness | **fixed** |
| 15 (low) | Pulse alpha | Angular 0.7 | 0.55 | 0.7 × goldness, outside the circle only | **fixed** |
| 16 (low) | Completion exit 300 ms | Angular 300 ms | 500 ms | 500 ms | not changed (low, #L7) |
| 17 (low) | Restart closes the menu | Angular keeps it open | closes | closes | not changed (owner info, #L8) |
| 18 (low) | Haptic on the veil tap | — | none | `Haptics.tap()` | **fixed** |

Unchanged and still matching (re-measured): capsule bounds x 26–374 / y 38–89, gold gradient (top `#F9DC7E` under the
sheen, 55% `#EDB120`, bottom `#DCA31C`), fill edge x179, leading light `#FDEAA9`→`#F9D878` over 2u, number split,
pause glyph 18×20 px at (1779.5, 63.5) vs 17×21 at (1780, 64), play 18×22 vs 19×23, back 27×24 at (1689.0, 63.5)
identical, restart 26×27 at (1598.5, 63.0) vs 27×27 at (1599.0, 63.0), gold disc `#F7C141`→`#E3A620`, rim
`#FFDA6B`, gaps 1.6u, blur on the content, veil on the content.

## 2. Differences in v2

| # | Severity | Type | Element | Reference | Flutter v2 | Fix |
|---|---|---|---|---|---|---|
| N1 | **medium** (new) | code | Inset shadow now drawn **over the gold** | gold top rows y39–42 `#FFD859` / `#FED757` / `#FED655` / `#FCD452` (the CSS inset shadow is on the track, under the fill); right end x372–373 `#EFB526` / `#E1AD26` | y39 `#CAAA44`, y40 `#DDB949`, y41 `#ECC64C`, y42 `#F4CE56`: a dark olive line along the top of the fill (visible in the crops at 9/16 and 16/16); right end x372–373 `#E2AC24` / `#D6A323` | Draw the inset-shadow path **before** the gold glow and fill (or clip it to `Rect.fromLTRB(0, 0, fill.left, h)`), so it only shades the empty glass. |
| N2 | **medium** | code | Capsule rim too faint | 1 px crisp `#2F6954` (desktop); on the phone reference 1 css px | 0.12u = 1.02 px straddling two rows → peak `#1B4B3C` (≈45% contrast); phone 1.3 device px = 0.5 dp, `#235846` | Use a width that renders as one solid logical pixel at both sizes: `strokeWidth = math.max(1.0, u * 0.12)` (logical px) and align the stroke to the pixel grid (deflate by half the width from a capsule whose top is rounded to whole px, e.g. `top: (u * 4.4).roundToDouble()`); or 0.17u as a compromise. |
| L1 | low | code | 320 ms unlocked window at completion | — | `_finish` waits 320 ms before `celebrate()` sets `_locked`; in that window the menu can open, restart sets step 1 (then the sweep plays and the page leaves with `true` showing 1/16), and back leaves the page while `celebrate()` still fires `Haptics.milestone` on the leaving page | Lock at the start of `_finish` (a public `LessonShellState.lock()` called before the delay), and skip `celebrate()` if `_left`. |
| L2 | low | code | Lock never released | — | if `_leave(true)` is refused (route not current, e.g. a dialog on top) the page stays locked | Release `_locked` (or retry the pop) when the route becomes current again; acceptable for the placeholder. |
| L3 | low | code | Inner shadow of the empty part | ~5 px at the top, faint shade at the bottom (y86–88 `#002E24`→`#002B22`) | ~3 px at the top, bottom only at y88 | Blur 0.35u instead of 0.25u (once N1 is fixed). |
| L4 | low | code | Tap areas of adjacent buttons overlap on the phone | — | padding 5.5 dp each vs gap 6.6 dp → 4.4 dp overlap; the later-painted button wins (pause > back > restart) | Acceptable; or cap the side padding at gap/2. |
| L5 | low | code | Number ink | 381 px | 436 px (w500, Flutter rendering) | Optional: weight 470–480 to match the mockup's stroke. |
| L6 | low | code | Veil on the background | G 37 at (900,150) | G 32 (background is inside the filtered content) | As v1 #12: acceptable for real lessons. |
| L7 | low | code | Completion exit | Angular 300 ms | 500 ms | Optional. |
| L8 | low | code | Restart closes the menu | Angular keeps it open | closes and resumes | Improvement; tell the owner. |

No asset items. Behaviour re-checked in the code: step/total and 300 ms fill; pause ↔ play swap; pulse 2 s with the
static halo; items slide out from under the button (300 ms easeOutCubic) and only take taps above 0.5; restart →
step 1; back → `_leave(false)` once; veil tap resumes with a haptic; Android back toggles the menu, ignored while
locked or with hidden controls; entry slide down / exit slide right 500 ms; completion: fill → sweep +
`Haptics.milestone` → `_leave(true)`; `controlsVisible` fades and blocks the bar. Phone captures: same proportions as
`F-2-phone.png`, number legible (3.2u ≈ 13 dp), same glass fill as the reference now.

## 3. Conflicts with confirmed tokens (unchanged from v1, still for the owner)
- **C1** Glass button ✅: the 02 buttons now follow the token and the mockup (glow outside only); the **04 close
  button and the 06 back button still draw the glow under the translucent fill**, so they look brighter than the 02
  buttons. Owner to decide: align 04/06 with `_GlassPainter`, or keep the brighter look as the token.
- **C2** Ring 1.7 px ✅ (buttons keep it; the mockup shows 1 px). **C3** capsule rim `#2F6954` vs glass rim token
  `#245843` 2 px (approved on the mockup). **C4** strong veil vs 12% dimming 🟡 (owner chose the strong veil for
  lessons). **C5** gold gradients of the capsule and of the paused button not yet in `DESIGN-SYSTEM.md`.

## 4. Scores

| Area | v1 | v2 | Why |
|---|---|---|---|
| Bar look | 7.0 | **8.5** | Buttons, halo, glow, sheen, 16/16 light, number position now match within 1 px; the inset shadow darkens the top of the gold (N1) and the rim is too faint, especially on the phone (N2). |
| Behaviour | 7.5 | **8.8** | Race, Android back, tap targets fixed; only a 320 ms unlocked window remains (low). |
| **Overall** | 7.2 | **8.6** | No high item; two medium code items (N1, N2); no asset items. |
