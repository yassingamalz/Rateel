# Screen 31: daily practice (التدريب اليومي)

Branch `flutter/31-daily-practice` (base `3211b3b`, `master` with screen 30 merged in). Plan v1 answered by the owner
(2026-11-28, section «Owner's answers» at the end); Q5 detail, Q11 and the light background still open.

## References (owner, 2026-11-28)
`31-daily-practice/reference-a-practice-{dark,light}.webp` (31-A, the screen of the rail item «التدريب»),
`reference-b-reminder-{dark,light}.webp` (31-B, popup over a lesson), `reference-b-reminder-calendar-light.webp` (31-B variant
with a calendar). 1843×853, u = 8.53 px. Prompts `prompts/31-daily-practice/reference-v1.txt`.

**Owner's main rule (from screen 30):** the result is **almost identical to the reference**, dark and light. The app's standard
style is kept **only** for elements that already exist as standards: side rail 04, header arch / mosque / crescent of 03/12,
`LessonButton` / `LessonRoundButton`, gold card of 08/10, emblem, avatars, Readex Pro. Everything else (rims, fills, glows,
text colours, lines, sizes) is sampled on the reference and kept as the screen's own tokens (`prac*` in `rateel_theme.dart`),
logged in `STYLE-CONFLICTS.md` (P31-n), reviewed at the end of the project.

Already decided (DECISIONS 2026-11-27): own screen of the rail item «التدريب» (today it opens 14); short session mixing what
was learnt (the 22 listening quiz is one exercise; exercises reuse 22 / 10 / 08); popup after 1 day without practice when a
lesson is opened, skippable; reminder also as the phone notification (23).

## 1. Reference ↔ common library (sheet `31-daily-practice/library-compare-v1.jpg`)
| Element in the reference | Library / standard | Match | Use |
|---|---|---|---|
| Whole dark background (top-corner lattices, big arc touching the edges, bottom swoosh) | `coming_soon/background.webp` (14, also 23), drawn over the content box 0–1686 px | **same image** (blend check: single arcs, single lattice) | as 14 / 23 |
| Light background | none: `splash/background_light.webp` (30) has a different arc (doubled lines in the blend) | no | **missing asset A1** (light version of the 14 background), prompt below |
| Flame (week panel, popup) | `icons/flame_inner.webp` (owner, 30) | same drawing (flame-shaped hole) | glow in code (dark), amber in light as 30 |
| Calendar (31-B variant) | `icons/calendar_gold.webp` (12) | different style (thin outline, 4×2 dots; ref filled tan, 3×2 dots) | only if the owner picks the calendar (Q3) |
| Tile glyphs: headphones, question, open book | `icons_white/headphones`, `question_circle`, `open_book` (owner's white set) | same drawings | cream in dark, tinted brown in light (single-colour glyphs) |
| Emblem on the arch apex | `splash/emblem.webp`; light: emblem B (`emblem_inner` filled #0B5A2B, 30) | same (light ref also has the green centre) | standard |
| Mosque (header left) | `decor/mosque.webp`, light `decor/mosque_light.webp` | same drawings | standard (place: Q1) |
| Crescent + star, header arch | `decor/crescent_star.svg`, `decor/header_arch.svg` (03/12) | same drawings; ref arch is **flatter** (Q1) | standard |
| Ogee lattice band (bottoms of card, panel, tiles, popup) | `decor/card_pattern.svg` (03 card bottoms) | same cells | tinted per theme |
| Rail icons (book, headphones, trophy, medal, document, gear, menu) | the owner's white set `icons_white/*` was made from these; app rail 04 uses `nav/*.svg` | ref ≠ app rail (Q2) | rail 04 as it is (Q2) |
| Diamond dividers and the two «line–diamond–line» ornaments by the button | `GoldDivider` (07/08) | same shape | standard, widths from the reference |

The dark mosque at the bottom right of the 14 background shows on the right of the card (as on 23); the reference has none
there. Proposal: keep the background as it is (library image).

## 2. Layout 31-A, measured (dark; light within ±3 px unless said)
x in px on the 1843 reference; the content box is 0–1686 px (197.7u), the rail 1686–1843. u values from the top / from the
content's left edge. Horizontal places use the content width as on 29 (wider phones keep the proportions).

### Header
| Element | Reference | 03/12 standard | Plan |
|---|---|---|---|
| Header axis (x) | 896 px | 897 px | 896 px (centre + 6.2u, as 12) |
| Arch (`header_arch.svg`) | apex y 9–13 (1.3u), shoulders y 82–92 (10.2u), ends ≈ y 215 | apex y 14–21 (2.0u), shoulders y 106–112 (12.7u) | Q1 |
| Emblem | 840–949 × 15–119: 12.9 × 12.3u, top 1.8u (on the apex) | 12: calendar 6.2–17.2u; 03: book on the apex | 12.9u, top 1.8u |
| Title «التدريب اليومي» | ink 651–1199 × 95–204, cy 17.5u, ≈ 9.7u bold, #EFE7C5 | 12: cy 22.4u, 7.4u | Q1 |
| Divider (diamond) | 741–1063, cy 25.2u, w 37.9u, #E7C142 | 12: cy 30.7u, w 38u | Q1 |
| Mosque | ink 215–499 × 35–188: ≈ 33u wide, 25.2u from the left, top 4.1u | 49u box at 10.5u / 8u | Q1 |
| Crescent + star | 1345–1422 × 73–148 (9.1 × 8.9u), right edge 31.0u from the content's right | 12: 1381–1460 × 67–143 (right 26.5u) | Q1 |

### Week panel «هذا الأسبوع» (left)
| Element | Reference | Plan |
|---|---|---|
| Panel | 109–536 × 253–788: left 12.8u, 50.1 × 62.7u, top 29.7u, radius ≈ 2.7u | box as ref |
| Rim / fill (no standard) | rim ≈ 0.35u mint: top #70B892, sides #447C65–#5B9E7C, bottom #63B580; fill #023E2A → #002E1E → #00291B; light: rim #E1C7B0 ≈ 2 px, fill #FEF7EE | `pracPanel*` (P31-1) |
| Title | cy 35.4u, ≈ 5.6u bold, #EFE6C5 (light #613C18) | Readex 600 |
| Divider | cy 41.4u, w 25.0u | `GoldDivider` |
| Day discs, row 1 (4) | Ø 8.9u, cy 49.9u, centres 10.8u apart (x 465 / 372 / 280 / 187 px, RTL) | as ref |
| Day discs, row 2 (3) | Ø 8.2u, cy 60.4u, x 417 / 325 / 232 px | as ref |
| Done day | gold disc #FFF4C0 core → gold, letter + small check, warm glow | code, `pracDay*` (P31-2); check = `icons_white/checkmark` |
| Today | gold ring ≈ 0.4u #F3EC81 / #FFDC4D, glow, letter cream | code |
| Other days | dark disc, rim ≈ 0.25u #42785F, letter #C9D4BA; light: beige disc, letter #654729 | code |
| Separator | y 582 (68.3u), ≈ 1 px #8EA667, inset ≈ 4u | code |
| Flame | 298–347 × 598–657: 5.9 × 7.0u, cy 73.6u | `flame_inner` |
| «4 أيام متتالية» | cy 80.5u, ≈ 4.5u bold #EFEAC9 | Readex 600 |
| Bottom divider | cy 85.9u, w 24.4u | `GoldDivider` |
| Lattice band | bottom ≈ 9u of the panel | `card_pattern.svg` |

### Session card «تدريب اليوم» (centre)
| Element | Reference | Plan |
|---|---|---|
| Card | 562–1555 × 251–787: left 65.9u, 116.4 × 62.8u, top 29.4u, radius ≈ 2.8u; gap to the panel 3.0u | **gold card of 08/10** (`GoldCardPainter`, standard) in this box |
| Card rim / fill seen in the ref | rim ≈ 0.4u core #F7FAB2 / #F9E688, dark line each side, glow ≈ 1.8u; fill #0B4B2A (top) → #013121 (middle) | standard values (differences in P31-3 for the end-of-project review) |
| Title | cy 35.2u, ≈ 7.4u bold, #ECE4C1 | Readex 600 |
| Subtitle «راجع ما تعلّمته في 5 دقائق تقريباً» | cy 42.1u, ≈ 3.8u, #E7E6C5 | Readex 400 |
| Divider | cy 47.0u, w 32.1u | `GoldDivider` |
| Three tiles (R → L: قراءة، أحكام، استماع) | x 1223–1511 / 922–1201 / 609–897, y 424–643: 33.5 × 25.7u, top 49.7u, gap 2.9u, radius ≈ 2.9u | box as ref |
| Tile rim / fill (no standard) | rim ≈ 0.3u #73B991 (top) / #4C966F (sides); fill #0B4F34 → #023926, ogee band at the bottom; light: rim #E3C9B2 ≈ 2 px, fill #FFF5EB | `pracTile*` (P31-4) |
| Tile glyph | cy 54.8u, h ≈ 6.0u (headphones 7.0 × 6.2u, ? 6.2 × 6.0u, book 9.1 × 5.2u) | white set |
| Tile name | cy 61.4u, ≈ 4.8u bold, #EFEBCD | Readex 600 |
| Tile divider | cy 65.7u, w 19.0u | `GoldDivider` small |
| Count «3 أسئلة» | cy 69.4u, ≈ 3.6u, #EAE9C9 | Readex 500, number grammar (§4) |
| Button «ابدأ التدريب» ‹ | 838–1255 × 671–764: 48.9 × 10.9u, cy 84.1u, text ≈ 5.2u | **`LessonButton`** (dark: luminous outline; light: filled gold, white text, as the ref) |
| Two ornaments by the button | 641–788 and 1319–1464, cy 84.1u, w 17.3u | `GoldDivider` (line–diamond–line) |
| Lattice band | bottom ≈ 9u of the card | `card_pattern.svg` |

### Light 31-A
Same composition. Text ink: title #603A17, texts #5E3C1B–#613D1B (P31-5, as O2 of 30); card rim gold #EDB02E ≈ 3 px on cream
#FEF6F0; panel / tile rims tan; day discs: done gold, today pale ring, others beige. Rail: Q2.

## 3. Layout 31-B (popup over a lesson), measured
The lesson has no rail: x from the screen centre (921.5 px).
| Element | Reference dark | Plan |
|---|---|---|
| Veil over the lesson | the lesson at ≈ 24% brightness: ≈ #001A0C at 76%, **no blur** (texts stay sharp); light: cream veil | `pracVeil` (P31-6: the 24 end card veil is `lessonVeil` 45% + blur) |
| Card | 498–1346 × 197–662: 99.4 × 54.5u, top 23.1u, centred, radius ≈ 3.9u | gold card of 08/10 (standard); light ref draws it bigger (104.5 × 56u): same box as dark (as 30) |
| Flame (Q3) | 880–965 × 219–320: 10.1 × 12.0u, cy 31.6u, warm halo | `flame_inner` + glow |
| Title «لم تتدرّب منذ يوم» | cy 42.7u, ≈ 7.4u bold, #F0E2BB (light #603E1B) | Readex 600; days in §4 |
| Divider | cy 49.5u, w 37.6u | `GoldDivider` |
| Line «خمس دقائق من التدريب تثبّت ما تعلّمته» | cy 55.3u, ≈ 4.0u, #E8E6C6 (light #69471E) | Readex 400 |
| «اذهب إلى التدريب» (right) | 864–1285 × 528–620: 49.4 × 10.8u, cy 67.3u, text ≈ 4.8u | `LessonButton` gold |
| «لاحقاً» (left) | 559–838 × 529–620: 32.7 × 10.7u, gap 3.0u; dark: rim ≈ 0.3u #478D65, dark fill, cream text; light: cream fill, tan rim #E1BB8D, brown text #4E3012 | no standard «quiet» button: reference values `pracLater*` (P31-7) |
| Lattice band | bottom of the card | `card_pattern.svg` |
The dark spots of the light calendar variant are a generation defect: not copied (the lesson behind is the real app lesson).

## 4. Content and data
### One session (proposal, owner to confirm: Q4–Q6)
Three exercise kinds, in this order, inside **one lesson frame** (02 top bar, progress n/9, pause menu), opened above the rail
like a lesson:
| Tile | Exercises | Source (only lessons the user has completed: Q5) | Reused widget |
|---|---|---|---|
| استماع «3 أسئلة» | 3 listening questions («ماذا سمعت في كلمة …؟») | `ListenQuestion`s of the completed listening lessons (today: `listen-kawthar-ghunna` 5, `listen-ghunna` 3) | 22 quiz (ayah card, waveform, answer pills, feedback) |
| أحكام «4 أسئلة» | 4 rule questions | `TestQuestion`s of the completed tests (today: `assessment-lesson-1`, 10 questions) | 10 question card, option rows, feedback A |
| قراءة «2 آيات» | read 2 ayat, play the recitation, «التالي» | Q6 | 08 verse card |
Random pick, no repeat of the previous day's items when the pool allows. End: the **24 end card** (stars by right answers as
the listening lesson: 3 = all, 2 ≥ 70%, 1 below; points +10 per right answer; streak tile = practice streak) → back to 31,
today's disc fills gold, the check pops, the streak counts up.
**Technical note:** the three pages today run whole lessons; their question / verse widgets must be extracted so one frame
can show them in sequence (refactor of 22 / 10 / 08 with the same look; their tests must stay green).
Arabic numbers: «سؤال واحد / سؤالان / 3–10 أسئلة / 11+ سؤالاً», «آية واحدة / آيتان / 3–10 آيات» (the ref's «2 آيات» is
ungrammatical: **suggestion** «آيتان»), «يوم واحد / يومان / 3–10 أيام / 11+ يوماً».

### Saved data
New `practice.v1` in `ProgressStore` (shared_preferences, as `progress.v1` / `profile.v1`): days with a completed practice
(dates `yyyy-mm-dd`, last 60), the day the popup was last shown, the first day of use (from 30). Practice streak = consecutive
days up to today (or yesterday if today is not done yet). «إعادة ضبط التقدم» clears it. Review aids: `?practiceDays=`,
`?practiceToday=1`, `?remind=1`.

### Week panel
Week Saturday → Friday (as the ref: س on the right). **The ref's second row is in the wrong order** (ج خ ر right → left; the
week continues ر خ ج): data order is used (texts from the app, LESSONS-LEARNED). Initials: س ح ن ث ر خ ج. Done days gold with
check; today gold ring; past days without practice and future days dim (**suggestion**: same dim look for both).

### Popup rules (proposal, Q7)
Opening any lesson (07, 08, 10, 22, placeholder) when **no practice yesterday and none yet today** (≥ 1 full day without
practice) and the popup was not already shown today: the lesson opens and waits (no audio / video start) under the veil with
the popup. «اذهب إلى التدريب» → leaves the lesson and opens 31 (rail «التدريب»); «لاحقاً» or Android back → the popup closes,
the lesson starts. Title by days: «لم تتدرّب منذ يوم / يومين / 3 أيام …». Not shown before the first full day of use, nor
inside the practice session itself.

### Phone notification (23)
The daily reminder of 23 is only stored today (BACKLOG). **Suggestion:** wire the real notification (package, Android
permission, time from 23, text inviting to the practice) on its own branch after 31 (it also serves 12): Q8.

## 5. States and motion (PERFORMANCE.md: no endless animation over the whole screen)
- States: practice to do (the references); **done today** (not in the refs: Q9); nothing learnt yet (Q5).
- Entry: header, panel and card rise and fade in (one controller, 450 ms), tiles staggered 80 ms.
- Today's ring: soft glow breathing (own small `AnimatedBuilder`, `RepaintBoundary`); **suggestion**, can be static.
- Done: disc fills gold 350 ms, check pops (scale 0.6 → 1), streak number counts up, flame glow pulses once; `Sounds.passed`
  is played by the 24 card already.
- Popup: veil fades in 250 ms, card scales 0.92 → 1 with fade 300 ms, flame pops; out: 200 ms fade.
- `RepaintBoundary` around the background, the header, the panel and each tile.

## 6. Code vs assets
- **Code:** layout (`PracMetrics` = the tables above), panel, tiles, day discs, ring, separator, glows, veil, «لاحقاً», session
  frame, data (`lib/practice/`), popup hook in the lesson routes, `prac*` tokens.
- **Reused standards:** rail 04, `coming_soon/background.webp`, `header_arch.svg`, `mosque(_light).webp`, `crescent_star.svg`,
  splash emblem (+ light emblem B), `GoldCardPainter`, `LessonButton`, `GoldDivider`, `card_pattern.svg`, `flame_inner`,
  white icons, 24 end card, 02 frame.
- **Missing asset:** A1, the light background (prompt below, `prompts/31-daily-practice/images-v1.txt`); A2 calendar only if
  Q3 = calendar.
- Checks: 1844×853 and phone 915×412 (dpr 2.625), text at 110 % (`?textScale=1.1`), dark and light, comparison sheets
  `compare-v<k>.jpg`.

## 7. Questions for the owner
- **Q1 Header.** The ref's header is the 12 header pressed upwards: arch flatter (shoulders 10.2u vs 12.7u), emblem on the
  apex, title 9.7u at 17.5u (12: 7.4u at 22.4u), mosque smaller (≈ 33u wide at 25u / 4u; standard 49u at 10.5u / 8u),
  crescent 4.5u more to the left. (a) **as the reference** (logged as P31-8, like P6 of 29); (b) 12's places and sizes: then
  the card and the panel must start ≈ 5u lower and be ≈ 5u shorter (tiles smaller). **Suggestion: (a)**, the only way to keep
  the card as the reference.
- **Q2 Rail.** The ref's rail is the app rail scrolled (lessons item hidden under the menu, as on 23) but **without count
  bubbles**, with **headphones** for «التدريب» (app: microphone) and the owner's white icons, and a **light rail** in light (the
  app rail is dark everywhere). (a) **rail 04 as it is** (standard, «التدريب» active), light rail stays a BACKLOG item; (b)
  change the rail for the whole app (white icons, headphones, no bubbles, light version) on its own branch. **Suggestion: (a)
  now**, (b) later if wanted.
- **Q3 Popup icon:** flame (dark and light refs, library asset) or calendar (light variant only; the library calendar has a
  different style, would need A2)? **Suggestion: flame.**
- **Q4 Session size:** fixed 3 + 4 + 2 («about 5 minutes») or scaled with the daily goal of 30 (5 / 10 / 15 / 20 min)?
  **Suggestion:** fixed for v1, goal later.
- **Q5 Source:** only lessons already completed (true «review»)? A new user has none: (a) the tiles show «—» and the button
  becomes «ابدأ أول درس» (new text) → opens 03; or (b) take the items of the first lessons of course 1. **Suggestion: (b)**
  while the data is mock (only 2 listening lessons and 1 test exist).
- **Q6 Reading «2 آيات»:** (a) 2 real ayat of the listening data (الكوثر / الناس, with Husary audio and tajweed colours) in the
  08 verse card; or (b) 2 sentences of the reading lessons (they are not ayat: label «جملتان»). **Suggestion: (a)**.
- **Q7 Popup rules** as in §4 (no practice yesterday nor today, once a day, not on the first day)? Or every day until the
  practice is done?
- **Q8 Phone notification** now in this branch, or on its own branch after 31 (**suggestion**)?
- **Q9 Done-today state** (no reference): **suggestion** subtitle «أحسنت! أكملت تدريب اليوم», today's disc gold, button
  «تدرّب مرة أخرى» (new practice, does not change the streak). Or a new reference from ChatGPT?
- **Q10 Streak:** the week panel shows the **practice** streak; 03 chip, 12, 24 and 29 show the mock streak of 12. One streak
  for the whole app (days with a practice), or two separate? **Suggestion:** one, the practice streak (12 keeps its
  challenges).
- **Q11** Do the practice challenges of 12 open 31 (today they open 14)? **Suggestion:** yes, the «التدريب» ones; recitation
  stays on 14 until 09.
- **Q12** Count bubble «2» of «التدريب» in the rail (demo value): **suggestion** «1» while today's practice is not done,
  no bubble when done.

## Prompt for the missing asset A1 (owner generates it)
Attach: `app_flutter/assets/ui/coming_soon/background.webp` (structure), `app_flutter/assets/ui/splash/background_light.webp`
(light style), `docs/flutter/screens/31-daily-practice/reference-a-practice-light.webp` (target). Text in
`prompts/31-daily-practice/images-v1.txt`.

## Owner's answers (2026-11-28)
Q1 **(a)** header as the reference (STYLE-CONFLICTS P31-8) · Q2 **(a)** rail 04 as it is · Q3 **calendar** (new asset A2: the
library calendar has another style; prompt in `images-v1.txt`) · Q4 fixed 3 + 4 + 2; **future: session size variable with the
user's progress and use of the app** (BACKLOG) · Q5 «from the lessons» (exercises come from the lessons; what a new user with no
completed lesson sees: asked again) · Q6 **(a)** 2 ayat of the listening data, label «آيتان» · Q7 as proposed (no practice
yesterday nor today, once a day, not on the first day of use) · Q8 **one dedicated branch for all the notifications**
(BACKLOG) · Q9 done-today state as proposed · Q10 **one streak** for the whole app (the practice streak) · Q11 explained again,
waiting · Q12 yes («1» while today's practice is not done, no bubble after).
Light background: the light background of 30 (`splash/background_light.webp`, light version of the 01 splash background) is in
the library, but its drawing differs from the 14 background used by 31 dark (arc and swoosh in other places: overlay in
`31-daily-practice/light-background-check.jpg`). Owner to choose: A1 (light version of the 14 background) or the 30 one.
