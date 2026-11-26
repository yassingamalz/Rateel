# Screen 12, daily challenges: critic v1 (phone 915×412)

Reviewer: separate critic sub-agent (did not write the code), 2026-11-26.
Build: web build on `localhost:8765`, re-captured for this review (`?challenges=1`, `&chalDone=3&streak=4`, screen 03
default route). The re-capture of the default state is pixel-identical to `critic-v1/phone-open0.png` except the
breathing glow of the open tile, so the captures are current.

## Method
- Reference: `critic-v1/reference-phone-height.png` (2339×1082). Flutter: 2402×1082 (dpr 2.625). Both are 1082 px high, so
  **1u = 10.82 px in both**.
- Content box: reference 0–2135 px (197.3u, centre x 1067 px = 98.65u); Flutter 0–2202 px (rail bevel at 2202, 203.6u,
  centre x 1101 px = 101.8u). The phone content is 6.3u wider.
- **Anchor: x is measured from the content centre** (+ = right) for everything in the middle (header, tiles, capsule,
  lines); the corner lattices, mosque, crescent and bottom band are anchored to the content edges, as the code does.
  y is from the top of the screen.
- Every number is sampled from pixels (scripts in the session scratchpad: `arch.py` row scans of the arch stroke,
  `tail.py` faded tail tracking, `prof.py`/`hprof.py` vertical/horizontal colour profiles, `bbox2.py` ink boxes,
  `corner.py` lattice brightness, `wave.py` band edge).
- Owner-approved differences (not scored, only checked for placement/collisions), from `DECISIONS.md`:
  - 2026-11-25 ✅ locked tiles **darker** than the reference (veil, no padlock) (Q2).
  - 2026-11-25 ✅ mosque and crescent + star in the **standard place of screen 03** (v2).
  - 2026-11-25 ✅ header decoration (arch, crescent, mosque, corner lattice) **from the shared library** (one asset
    direction).
  - 2026-11-25 ✅ owner's icon collection, green-line variants; flame and calendar as the reference.
  - 2026-11-25 ✅ Readex Pro (Q5). Icons follow the data, not the reference's order (LESSONS-LEARNED, references are
    visual only): microphone instead of headphones on tile 2 is not a defect.
  - Side rail = screen 04 (approved, shared), not scored.

## 1. Header (owner: «the upper part, the symbols and the arch, are not placed well»)

### 1.1 Arch geometry (stroke centre, u; reference vs Flutter vs screen 03)
Row scans of the gold stroke. Screen 03 uses the **same SVG** at 102.8×26.4u, top 0.6u, centred +7.0u; screen 12 draws it at
**128×36u** (×1.245 wide, ×1.364 tall: the aspect changes from 3.89 to 3.56, i.e. the library arch is **stretched
vertically**), centred at **+5.1u**, bottom fade stops [0.6, 1.0] (03: [0.55, 1.0]).

| Feature | Reference | Flutter 12 (now) | Screen 03 (same SVG) |
|---|---|---|---|
| Apex | x +6.1, y 1.0 | x +5.1, y 2.0 | x +7.0, y 2.3 |
| Dome width at y 6 | −9.7…+21.0 (30.7) | −0.5…+10.7 (**11.2**, spire) | −1.7…+15.7 (17.4) |
| Dome width at y 10 | −20.3…+31.4 (51.7) | −14…+24 (38) | −20…+34 (54) |
| Dome base notch | y 20, x −36 / +47 (83 wide) | y 17, x −31.5 / +41.6 (73) + a flat ledge to −42.5 / +52.3 | y 12.7, x −23 / +37 (60) |
| Flank at y 22 | −41.9 / +52.8 | −51.8 / +60.9 | −42.6 (fading) |
| Flank at y 24 | −45.9 / +57.1 | −53.5 / +63.0 | gone |
| Tail visible end (r−b ≥ 30) | y ≈ 30, x −55.9 / +66.7, curving outwards | **y ≈ 33–34**, x −57.4 / +67.5, **almost vertical below y 26** (x −55.0 → −57.5) | y ≈ 22, x −42.6 / +55.6 |
| Stroke colour | 3-tone: #FFFDD3 core, #F8DB55, #FFF558, olive halo #1F3A17 ≈ 1u | flat #E6C159, no halo | flat, as 12 |
| Stroke (vertical run on the dome) | ≈ 0.75u incl. highlight | ≈ 0.65u | — |

### 1.2 Elements relative to the arch

| Element | Reference | Flutter | Finding |
|---|---|---|---|
| Calendar ink | x 0.6…11.6 (11.0), y 6.5…17.1 (10.6), centre +6.1 = apex x | x 0.2…9.7 (**9.5**), y ≈ 6.2…15.7 (9.5), centre **+4.9** | 14% smaller, 1.3u left of the title; its ring tabs sit in the narrow spire (dome only 11.2u wide at y 6), ≈ 1.5u from the strokes: the calendar looks **jammed into the spire** instead of sitting in a broad dome (ref: 5.5u apex→tabs, ≥ 8u to the side strokes) |
| Apex → calendar top | 5.5u | 4.2u | — |
| Calendar → title gap | 17.1 → 19.5: 2.4u | 15.7 → 20.2: 4.5u | loose |
| Title ink | x −29.3…+42.3 (71.6), y 19.5…26.9, centre (+6.5, 23.2) | x −29.7…+42.1 (71.8), y 20.2…27.7, centre (+6.2, **23.98**) | width exact; **0.75u low** |
| Title vs arch | arch centre (apex) +6.1, title +6.5 (0.4u) | arch +5.1, title +6.2 (**1.1u off-axis**) | arch not on the title's axis |
| Title inside the arch | flanks at y 22 are 12.6u (left) / 10.5u (right) outside the ink | 22.1u / 18.8u | Flutter arch is too wide around the title: loose frame |
| Divider | ink −10.5…+24.3 (34.8), y 30.7, bright #FFF94B…#FFF8AC along the whole length, plain lines + hollow diamond | `GoldDivider` 33.2u but bright only ±6u around the diamond: −2 #C29837, 0 #DDA83D, +2…+10 #E7B142, −8 #2D472A, +18 #5E622F; visible ≈ −8…+18 (26); small lozenges beside the diamond | dimmer, shorter, more orange |
| Subtitle ink | x −24.8…+36.8 (61.6), y 33.5…38.0 (4.4), mean #DEDEC8 | x −28.4…+41.0 (**69.4**), y 33.1…38.4 (**5.3**), #DADBBC | **12.7% too large** |
| Arch tails vs subtitle | tails end y ≈ 30–31, above the subtitle (33.5) | tails visible to y 33–34, **beside the subtitle** (x −57/+67) | the frame runs down past the divider |
| Left tail vs mosque | ref mosque further right (owner moved it), tail passes behind its faded ground | tail x −55.0…−57.5 at y 26–34; mosque dome right edge −55.7 at y 24, base rectangle to −53 at y 27.5–30, pinnacle −50 at y 29; the mosque's ground fade (66–80%) leaves the tail **fully visible across the mosque base** | **collision** (none on 03: its tail ends at −42.6, y 22, 10u clear) |
| Right flank vs crescent | crescent x +54…+66, y 8…18.5; flank at y 18 +46: gap 8u | crescent (03 standard ✅) x +65.6…+76.3, y 7.5…17.3; flank at y 17 +52.3: gap 13u, flank passes 5u below-left of the crescent at y 22 (+61) | no collision; placement approved |
| Mosque | ref x ≈ −72…−44 | 03 standard ✅ (x −91.3…−42.3 box, 83%) | approved; only the collision above is a defect |

**Why it looks wrong:** the 03 arch is stretched only vertically (36 vs the 32.9u a uniform ×1.245 would give), so the
dome becomes a spire (11u wide where the calendar's tabs are), the base ledge drops to y 17 and the flanks become long
vertical tails that reach the subtitle and cut through the mosque base. The arch is also 1.1u off the title axis.

### 1.3 Header fixes (ChalMetrics)
**Fix A (recommended: the 03 standard, as the owner asked for mosque and crescent):**
- `archW = 102.8`, `archH = 26.4`, `archTop = 0.6` (same as 03, no stretch); `archDx = 6.2` (arch on the title axis; the
  code's arch centre = content centre + `archDx`); arch fade stops **[0.55, 1.0]** as 03.
  Result (from the 03 capture): apex (6.2, 2.3); dome 17u wide at y 6, notch y 12.7 at −23.8/+36.2; flanks at y 20
  −42/+54.6 (title margin 12u each side, as the reference's 12.6/10.5); tails fade out by y ≈ 22–23 at −36/+49:
  **≥ 10u clear of the mosque, nothing beside the subtitle**.
- Calendar: `calendarDx = 6.2`, `calendarH = 11.6`, `calendarTop = 5.8` → ink ≈ 11.0×10.6 at x 0.7…11.7, y 6.2…17.2
  (reference 0.6…11.6 × 6.5…17.1); tabs inside the dome with ≥ 2u margin; its lower part sits below the dome base
  between the flanks exactly like the 03 book.
- `titleCentre = 22.4` (ink centre 23.98 → 23.2; also the 03 title centre). Calendar → title gap becomes 2.3u (ref 2.4).
- `subtitleSize = 3.9` (ink 69.4 → ≈ 61.5u wide, 4.7u high).
- Divider: replace `GoldDivider` by the **03 title divider** (`title_divider.svg` with the 03 gradient
  #B2983A → #F8D053, full-length bright) at `dividerW = 38` (ink ≈ 35u), centre 30.7 (unchanged).
- Top corners: the **03 standard corners** (`corner_glow_left/right.webp`, 03's positions and sizes, opacity 0.75, radial
  fade), see §3.

**Fix B (if the owner wants the reference's bigger arch):** uniform scale ×1.09 of the 03 arch: `archW = 112.0`,
`archH = 28.8`, `archTop = 0.6`, `archDx = 6.2`, fade [0.55, 1.0]. Apex y 2.5, notch y 13.8 at −26/+38.9, 50%-alpha
point of the tail at y ≈ 23 x −47.7 (8u from the mosque dome). Do **not** go above ×1.1: the tail's physical end reaches
the mosque base (x −53) and pinnacle (−50) at y 27–30. Calendar as in A, `calendarTop = 6.0`.

## 2. Table of differences

Severity: high / medium / low. Type: code / asset / owner (needs an owner decision before building).

| # | Element | Reference | Flutter | Sev. | Type | Fix |
|---|---|---|---|---|---|---|
| H1 | Arch size/shape | see §1.1; tails end y ≈ 30 | 128×36u (non-uniform stretch of the 102.8×26.4 03 arch), tails visible to y 33–34 beside the subtitle, through the mosque base | **high** | code | Fix A: 102.8×26.4, top 0.6, fade [0.55, 1] (or B ×1.09) |
| H2 | Arch ↔ mosque collision | — | left tail x −55…−57.5, y 26–34 over the mosque base (−53, y 27.5–30) | **high** | code | solved by H1 (tail ends −36, y 22) |
| H3 | Arch axis | apex +6.1 vs title +6.5 | arch +5.1 vs title +6.2 | medium | code | `archDx = 6.2` |
| H4 | Calendar size / place | 11.0×10.6u, centre +6.1, tabs ≥ 8u from strokes | 9.5×9.5u, centre +4.9, tabs ≈ 1.5u from the spire strokes | medium | code | `calendarDx 6.2`, `calendarH 11.6`, `calendarTop 5.8` (with Fix A) |
| H5 | Title vertical | ink centre 23.2 | 23.98 | medium | code | `titleCentre 22.4` |
| H6 | Subtitle size | ink 61.6×4.4u | 69.4×5.3u | medium | code | `subtitleSize 3.9` |
| H7 | Title divider | 34.8u, #FFF94B…#FFF8AC full length, plain line + hollow diamond | bright ±6u only, peak #E7B142, visible 26u, extra lozenges | medium | code (+ conflict C3) | 03 title divider (`title_divider.svg`, gradient #B2983A→#F8D053), 38u |
| H8 | Top corner lattices | gold lines, p98 #666518, max #A58F24, TL reaches x 24u at y 2, fades by y 30 | 07 *bottom* corner flipped, 30u at 30%: grey-green lines max #4E632C, p98 #495A29 | medium | code | use the 03 standard corners (`corner_glow_*`, 03 Positioned values, opacity 0.75, radial fade): p98 #686116, matches the reference |
| H9 | Arch stroke colour | 3-tone #FFFDD3 / #F8DB55 / #FFF558 + olive halo ≈ 1u | flat #E6C159, no halo | low | asset (library ✅, conflict C1) | none per screen; regenerate once for the app if the owner wants |
| H10 | Title colour | flat #F5EDCA top and bottom | #F6EED5 → #EBDCB2 (`titleTop → titleBottom`) | low | conflict C2 | token decision |
| H11 | Crescent / mosque | crescent 8u from the flank | 13u from the flank (17u with Fix A) | — | approved ✅ 2026-11-25 | none (placed well, no collision) |
| T1 | Connector, default state | **all six links lit**: core ≈ 0.9u (y 53.2–54.1), #FEFCD6 top edge, #FFE340 core, olive glow #58590F at 1u, #283E12 at 3u | links after the open tile are a dim track #354F24 0.55u with no glow; in the default state **no link is lit** | medium | owner | the progress behaviour (lit only up to the open tile) was in the plan but is not an owner-approved (✅) deviation: ask the owner; if kept, see T2 for the lit look |
| T2 | Connector, lit look | core 0.9u, pale top edge, glow ±3u | core 0.55u flat #FFE451, glow ±2.5u weaker (#3B4E1C at 1.2u) | medium | code | core `u*0.9` (keep #FFE451, add a 0.25u #FEFCD6 top line), glow alpha 0.55→0.75, blur 0.9u→1.3u |
| T3 | Open tile rim | ≈ 0.8u 3-tone: outer #E9DD97, core #FDFBD1, inner #EBC952→#B47F01 | 0.5u flat #F7E185 (run 0.4u) | medium | code | rim 0.8u: outer `chalRimLight`, 0.35u pale core #FDFBD1 inside, inner 0.2u #B47F01 |
| T4 | Open tile glow | above rim #334413 at 0.5u; below #7A5702 at 0.5u → #19290C at 2.2u (warm, tight) | #213E1E at 0.5u above, #2A3A15 below (greener, weaker) | medium | code | glow `chalRim` alpha 0.55–0.75 (breathing), blur 1.6–2.0u, spread 0.3u |
| T5 | Open tile fill | #2B3C10 (near rim) → #1B300F (middle) → #4D4A01 (above the bottom rim) | #2A3A10 → #1C2D0C, flat | low | code | add the warm bottom rise (inner radial already there; raise its alpha 0.22→0.35) |
| T6 | Tile boxes | open y 43.9…65.2 (21.3), locked 44.1…65.0 (20.9) | open 43.5…65.5 (22.0), locked 44.1…64.9 | low | code | `openScale 1.07 → 1.04` |
| T7 | Pills | open pill y 57.8…63.0 (centre 60.4, h 5.2), fill #525B13 / #343802 mid / #5B590C | 58.1…63.3 (centre 60.7), fill flat #4A4D0E | low | code | keep the pill at `pillCy` for the open tile too (do not scale its y with `openScale`), fill gradient |
| T8 | Side margins | first/last tile 13.3u / 9.6u from the content edges | 16.3u / 12.5u (phone 6.3u wider, centre-anchored) | low | code | optional: `pitch 25.6 → 26.1` to fill the wider phone |
| T9 | Locked tiles | bright rim #ECE999/#FDC907, cream glyph #FAECC4 | veiled: rim #7D6208, glyph #7E7A6B, fill #02150B | — | approved ✅ (Q2) | none |
| T10 | Check badges (state not in the reference) | — | 5.4u gold disc on the top-right corner, 1.4u outside the rim, as screen 05 | — | — | consistent with 05, no collision with neighbours (gap to next tile 4.4u) |
| S1 | Streak capsule rim | top #F9F6CC/#F7E470/#FFFE64, sides #FFB201, bottom #FEE04E/#FAC102/#B98E04: warm saturated gold | symmetric #C79A14 / #FFF5C0 / #E1C362, sides #EED98B: pale cream | medium | code | rim gradient: outer `#FFB201` sides/bottom, core pale only on top (vertical gradient #FFFE64 → #FAC102), 0.6u |
| S2 | Capsule box | y 71.9…91.3 (19.4), x −24…+32 | y 72.1…90.9 (18.8), x −24…+32 | low | code | `capsuleH 19.6` |
| S3 | Flame disc | Ø 12.7 (x 8.8…21.5), ring #AD8301 / #ECC401, fill #3E4007…#454205 | Ø 12 (9…20.5), ring #F5CC02, fill #2A3207 | low | code | `discD 12.6`, `chalDisc #454205` |
| S4 | Side lines | x −51…−27 / +30…+50, bright #FFFF69 / #FFF682 (near white) full length, plain line + diamond | `GoldDivider` peak #E7B142, fades to #5E5F2B at the ends, extra lozenges | medium | code (+ C3) | same treatment as H7 (03 divider art or a bright full-length line) |
| S5 | Streak texts | «0 يوم» x −11…+3, label −13…+3 | number −11…+3, label −14.5…+3 | low | code | `streakLabelSize 3.6 → 3.3` |
| B1 | Bottom wave edge | shape: y 83.0 / 86.0 / 89.5 / 91.2 at 16 / 20 / 25 / 30u from the edge; colour #FFCA17 bright in the middle (30–40u), #A58516 at the side, glow | 86.3 / 88.1 / 89.6 / 90.4 (shape within 1–3u), flat #B8932E 0.3u, no glow | low | code | stroke gradient along the wave (#A58516 → #FFCA17), 0.35u, soft glow 0.6u |
| B2 | Bottom lattice band | olive-gold lines, p95 #3E4B14 | greener, p95 #2D4927 | low | code | opacity 0.2 → 0.3 with a warm tint (or the 03/07 gold band asset) |
| G1 | Background | #002418…#002819 (G 36–40, B 24–25) | #032E23…#063328 (bluer, ~10 levels lighter) | low | conflict C4 | token decision (03 background) |
| M1 | Entry, 2 s frame (?slow=10) | — | the full-length dim connector track is already drawn across the empty row before any tile pops in (a bare line from −75 to +78) | low | code | fade the track in with the first tile (`_entry` 0.18–0.3) |
| M2 | Entry, 5/9/14 s | — | header fades down, tiles pop from the right, capsule rises: order and timing fine; no collision during the motion | — | — | none |

## 3. Conflicts with DESIGN-SYSTEM tokens (for `STYLE-CONFLICTS.md`, owner decides)
- **C1 Header arch stroke**: library `header_arch.svg` flat #E6C159 vs the reference's luminous 3-tone stroke with halo.
  Library rule ✅ 2026-11-25: regenerate once for the whole app if wanted.
- **C2 Title gradient** `titleTop #FFFBEA → titleBottom #E9D7A8` vs the reference's flat #F5EDCA.
- **C3 `GoldDivider`** (shared since 07/08): peak #E7B142, fades from the centre, lozenges; the reference draws bright
  pale-lemon lines (#FFF94B…#FFF8AC, highlights #FFFF69) at full brightness. 03 uses a different divider art
  (`title_divider.svg`): two divider styles live in the app.
- **C4 Content background** (🟡 #07362A → #00271D) vs reference #002418…#002819.
- **C5 Screen-specific golds `chal*`** (`chalRim #FBC411`, `chalRimLight #FFE98A`, `chalLine #FFE451`, `chalCapsuleRim
  #FFF5C0`/`#C79A14`, `chalDiscRim #F5CC02`, `chalPillRim #B9A52E`) vs confirmed gold rim #DAA42A + #FFDA6B, gold fill
  #E2A51E, active ring #D8C35A; and the tile rim (0.32/0.5u gold) vs the glass tile token (2 px #1C4E38, no fill).
- **C6 Pills**: 03 pill token (🟡 outline gold 2 px, fill #062D20, text gold 3.3u) vs here fill #0E4422→#0B3519, rim
  #B9A52E, cream number.
- **C7 Corner lattice**: two library corners in use for the same header (03 `corner_glow_*` at 75% vs 12 the 07 bottom
  corner flipped at 30%). Fix H8 removes it.
- **C8 Connector**: 03/05 path token (line 3 px #D1A93C on track #265343) vs here #FFE451 core on #2C4A25 track.

## 4. Score
- **Code score: 6.8 / 10.** Tiles, pills, capsule, side lines and band are placed within 1u, but the header composition
  (stretched arch, collision with the mosque, calendar in the spire, arch off-axis, title low, subtitle large) and the
  dim gold lines (divider, side lines, connector, open-tile rim, capsule rim) are clear code differences.
- **Whole score: 6.5 / 10** (adds the library arch stroke and corner lattice colour, which are asset/library
  differences).

High: H1, H2. Medium code: H3, H4, H5, H6, H7, H8, T2, T3, T4, S1, S4. Medium owner: T1.
