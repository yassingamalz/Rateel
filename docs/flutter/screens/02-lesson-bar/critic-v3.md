# Screen 02 (shared lesson top bar): critic v3 (2026-11-24)

Reviewer: separate critic sub-agent (did not write the code). Rules: `docs/flutter/CRITIC.md` (measured, no exclusions).
Same reference (`reference/`, mockup v3) and the same scripts as `critic-v1.md` / `critic-v2.md`, run on
`capture-v3-*.png` (v3 = commit 2d0a9ec). Code re-read: `lesson_shell.dart`, `lesson_page.dart` (diff 069ee92 → 2d0a9ec).
u = 8.53 px at 1844×853. Owner-approved (✅ 2026-11-24) choices not scored, as in v1/v2; the placeholder card is not scored.

## 1. v2 items: verification

| v2 # | Item | Reference | v2 | v3 | Status |
|---|---|---|---|---|---|
| N1 (med) | Inset shadow over the gold | gold y39–42 `#FFD859` `#FED757` `#FED655` `#FCD452`; right end x372–373 `#EFB526` `#E1AD26` | `#CAAA44` `#DDB949` `#ECC64C` `#F4CE56`; right end `#E2AC24` `#D6A323` | `#F9D457` `#FDD555` `#FDD453` `#FCD251`; right end x372–374 `#EFB627` `#F0B628` `#E7B32A`; sheen from y43 as the reference | **fixed** |
| N2 (med) | Capsule rim too faint | 1 px crisp `#2F6954` (top y38, left x26); phone 1 css px | split over two rows, peak `#1B4B3C`; phone 0.5 dp `#235846` | top y38 `#2F6954`, left x26 `#2E6853`, bottom y90 `#2F6954`, right x375 `#336A53`; phone 1 dp: rows 47–49 `#245746` `#2F6954` `#29614D`, columns 32–33 `#2F6954` | **fixed** |
| L1 | 320 ms unlocked window | — | lock only in `celebrate()` | `_finish` calls `LessonShellState.lock()` first (menu closed, bar `IgnorePointer`, Android back ignored), then the delay and `celebrate()` | **fixed** |
| L2 | Lock never released if `_leave(true)` is refused | — | yes | unchanged | open (low) |
| L3 | Inner shadow of the empty part | y39 `#02231B`, y40 `#02271E`, y41 `#022B21`, full at y43–44; faint bottom shade y86–88 `#002E24`→`#002B22` | ~3 px, bottom y88 only | y39 `#03291F`, y40 `#022B21`, y41 `#032F24`, full at y43; no bottom shade (y86–89 `#012F25`) | open (low), unchanged |
| L4 | Adjacent tap areas overlap (phone) | — | 4.4 dp | unchanged | open (low) |
| L5 | Number ink | 381 px | 436 px | 416 px | open (low) |
| L6 | Veil darker on the background | G 37 at (900,150) | G 32 | G 32 | open (low) |
| L7 | Completion exit 500 ms vs Angular 300 ms | 300 ms | 500 ms | 500 ms | open (low) |
| L8 | Restart closes the menu | Angular keeps it open | closes | closes | open (owner info) |

Re-measured and still matching: gold gradient (y44 `#FCDD7F`, 55% `#EDB120`, y88 `#DBA21C`), fill edge x179–180,
leading light `#FDEBAC`→`#F9D776` over 2u, gold glow into the empty part (x176 `#244124` / x178 `#2E4823` vs reference
`#264524` / `#314B25`), glass button fill (centre `#15351F`, inner edge `#2D4320` vs `#14331F` / `#2E431E`), glow
(`#15351F` at the rim → `#012A1F` at x1722), gold halo (y15–23 `#303817`→`#565018` vs `#182C15`→`#55511A`), gold disc
`#F6C140`→`#E8AD27`, glyphs (pause 18×20 px at (1779.5, 63.5), play 19×22 at (1782.0, 63.5), back 27×24 at
(1689.0, 63.5), restart 26×27 at (1598.5, 63.0)) within 1 px of the reference, blur and veil on the content.

## 2. Differences in v3

| # | Severity | Type | Element | Reference | Flutter v3 | Fix |
|---|---|---|---|---|---|---|
| R1 | low (new) | code | Capsule size after rounding to whole pixels | x 26–374, y 38–89 (349×52 px) | x 26–375, y 38–90 (350×53 px); vertical centre 64.5 vs button centre 64; phone 26 dp tall vs 25.5 | `floorToDouble()` for the height and width (52 / 349 px at 853), or round the bottom edge instead of the height. |
| R2 | low (new) | code | Number position | centre (200.0, 65.5) | (201.0, 66.0): follows the 1 px larger capsule | Goes away with R1. |
| L2 | low | code | Lock never released if the final pop is refused | — | page stays locked | Release on route current again; fine for the placeholder. |
| L3 | low | code | Inner shadow of the empty part a little short, no bottom shade | ~5 px top + faint bottom | ~3 px top, none at the bottom | Blur 0.35u. |
| L4 | low | code | Adjacent tap areas overlap on the phone | — | 4.4 dp | Acceptable. |
| L5 | low | code | Number ink | 381 px | 416 px | Optional weight 480. |
| L6 | low | code | Veil on the background | G 37 | G 32 | Acceptable for real lessons. |
| L7 | low | code | Completion exit | 300 ms | 500 ms | Optional. |
| L8 | low | code | Restart closes the menu | stays open | closes | Tell the owner (improvement). |

No high or medium item. No asset item. Behaviour re-checked: `_finish` locks at once; `lock()` closes the menu and
blocks the bar and Android back; `celebrate()` (sweep + `Haptics.milestone`) then `_leave(true)` once; back → `_leave(false)`;
PopScope toggles the menu otherwise, ignores back with hidden controls; tap targets ≥ 48 dp; entry/exit slides unchanged.
No regression found in the buttons, menu, veil or glyphs.

## 3. Conflicts with confirmed tokens (unchanged, for the owner)
- **C1** Glass button ✅: 02 follows the token and the mockup; the 04 close button and the 06 back button still draw the
  glow under the translucent fill (brighter). Owner to decide whether to align them.
- **C2** Ring 1.7 px ✅ vs 1 px in the mockup (buttons keep the token). **C3** capsule rim `#2F6954` vs glass rim token
  `#245843` 2 px (approved on the mockup). **C4** strong veil vs 12% dimming 🟡. **C5** capsule / paused-button gold
  gradients to add to `DESIGN-SYSTEM.md`.

## 4. Scores

| Area | v1 | v2 | v3 | Why |
|---|---|---|---|---|
| Bar look | 7.0 | 8.5 | **9.3** | Every element within 1 px and a few RGB steps of the reference; only the 1 px rounding of the capsule and a slightly short inner shadow remain. |
| Behaviour | 7.5 | 8.8 | **9.2** | Completion fully locked, single pop, back handling and tap targets correct; only low notes. |
| **Overall** | 7.2 | 8.6 | **9.2** | No high or medium item: ready for the owner, with conflicts C1–C5. |
