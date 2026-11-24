# Next session: 08 reading lesson (and the 06 final critic)

**Update 2026-11-24:** screen 07 (video lesson, `lib/lessons/video_lesson_page.dart`) is **approved** (APK 1.0.366) and merged
into `master` with the 02 changes (Simply Piano menu motion, capsule left → right). Shared lesson widgets for the next lesson
screens: `LessonPill`, `LessonRoundButton`, `SkipButton` (bottom left), `PillGlyph` (`lib/lessons/lesson_widgets.dart`),
`GoldDivider`, `ScreenGirih(fadeTop:)` (`lib/core/screen_decor.dart`), `LessonShell(waiting:, onPlay:)`.

Open: YouTube link of `rateel-lezione1-v2.mp4` and the real section times (mock: 3 equal parts); final critic of 06 (phone
only, ask first); old video links dead/mismatched (`SCREENS.md`).

## Next steps (proposal, confirm with the owner)
0. **Performance fix** (owner: animations feel heavy): `PERFORMANCE.md`, branch `flutter/perf` from `master`, if the owner
   says yes before 08. New screens follow its rules.
1. **Screen 08, reading lesson** on the dark/light pair `07-lezione-video-{dark,light}.webp` (they show the reading lesson),
   Angular `reading-lesson`. Branch `flutter/08-reading-lesson` from `master`.
2. Final critic of 06 when the owner says so; then 09, 10/10b.

## Prompt to start the next session
```
Lavora sul repo Rateel. Leggi CLAUDE.md, poi docs/flutter/DECISIONS.md, PROCESS.md, DESIGN-SYSTEM.md, LESSONS-LEARNED.md,
NEXT-SESSION.md, SCREENS.md, STYLE-CONFLICTS.md, ASSETS.md e docs/flutter/screens/07-video-lesson/HISTORY.md.
Obiettivo: schermata 08, lezione di lettura, uno a uno con i riferimenti 07-lezione-video-dark/light (branch lesson-production,
docs/design/glassy-gamified/screens/: mostrano la lezione di lettura), con la barra 02 e i widget condivisi della 07.
Branch flutter/08-reading-lesson da master. Prima piano e domande, poi prompt ChatGPT per gli elementi mancanti (uno per
blocco copiabile), costruzione, verifica elemento per elemento con i numeri, confronto, video e APK. Conflitti nel registro
STYLE-CONFLICTS.md. Crea HISTORY.md della schermata. Parla con me in italiano.
```

---

## Archive: hand-off that started the 06 final critic and screen 07 (2026-11-24)

# Next session: final critic of screen 06, then screen 07 (video lesson)

**Update 2026-11-24:** screen 11 (leaderboard, `lib/leaderboard/`) is **approved** (APK 1.0.346), PR
`flutter/11-leaderboard` → `master` (merge it before starting). It runs on **mock data** (`SCREENS.md`); its conflicts
K1–K11 are in the project-wide register `STYLE-CONFLICTS.md` (decided at the end of the project).

**Rules learned on screen 11 (read `LESSONS-LEARNED.md`):**
- **Critic at phone size only (915×412)**, and **ask the owner before launching it**.
- **Verify element by element with numbers before showing anything**: boxes of every element (±4 px at 853), gradient and
  line profiles, zoomed side-by-side per region, overlays for titles (`tools/flutter-review/leaderboard-verify.py` as a model).
  Whole-screen looks hid many errors on screen 11 (title arch, lattice scale, tab orientation, row spacing, gold brightness).
- `Image(repeat: ...)` needs `fit: BoxFit.none`.

## Next steps, in order (owner, 2026-11-24)
1. **Final critic of screen 06** (lessons of the unit, look B) on `master`, phone size only, after asking the owner; fix the
   high/medium items on a branch `flutter/06-lessons-final`, verify element by element, APK.
2. **Screen 07, video lesson** (`07-lezione-video-{dark,light}.webp`, branch `lesson-production`), using the approved top bar
   of screen 02 (`lib/lessons/lesson_shell.dart`). Branch `flutter/07-video-lesson` from `master`. Procedure in `PROCESS.md`.
3. Then 09 (practice / recitation), 10 and 10b (test), and the rest in `SCREENS.md`.

## Prompt to start the next session
```
Lavora sul repo Rateel. Prima unisci la PR di flutter/11-leaderboard in master se non e' gia' unita (chiedimelo).
Leggi CLAUDE.md, poi docs/flutter/DECISIONS.md, docs/flutter/PROCESS.md, docs/flutter/DESIGN-SYSTEM.md,
docs/flutter/LESSONS-LEARNED.md, docs/flutter/NEXT-SESSION.md, docs/flutter/SCREENS.md, docs/flutter/STYLE-CONFLICTS.md,
docs/flutter/screens/06-lessons/HISTORY.md e docs/flutter/screens/11-leaderboard/HISTORY.md (soprattutto la verifica
elemento per elemento, verify-v6.md).
Obiettivo 1: critico finale della schermata 06 (lezioni dell'unita', look B) solo in formato telefono 915x412: chiedimelo
prima di lanciarlo. Correggi i punti alti/medi su un branch flutter/06-lessons-final da master, verifica elemento per
elemento con i numeri (posizioni, dimensioni, sfumature, linee) prima di mostrarmi qualcosa, poi confronto, video e APK.
Obiettivo 2: schermata 07, lezione video, uno a uno con il riferimento ChatGPT 07-lezione-video (dark/light, branch
lesson-production, docs/design/glassy-gamified/screens/), con la barra in alto della 02 gia' approvata. Branch
flutter/07-video-lesson da master. Prima piano e domande, poi prompt ChatGPT per gli elementi mancanti (uno per blocco
copiabile, dimmi quali immagini allegare), costruzione, verifica elemento per elemento, confronto, video e APK.
Conflitti con i token nel registro STYLE-CONFLICTS.md. Crea HISTORY.md della schermata e tienilo aggiornato.
Parla con me in italiano.
```

---

## Archive: hand-off that started screen 11 (2026-11-24)

# Next session: leaderboard (11), then back to the main line

**Update 2026-11-24:** screen 02 (shared lesson top bar, `lib/lessons/lesson_shell.dart`) is **approved and merged into
`master`** (APK 1.0.330). Next: **screen 11**, branch `flutter/11-leaderboard` from `master`. Conflict C1 closed (keep
04/06). **New rule: ask the owner before launching the critic** (it consumes a lot).

---


Screens done and missing: `docs/flutter/SCREENS.md`.

State on 2026-11-24:
- **Consolidation done:** PR #38 (04), #42 (03), #39 (05) and #43 (06) are merged into `master` (merge commits, in this order);
  `flutter analyze` and `flutter test` (6 tests) pass. Screens 03–06 are approved; histories in `screens/<nn>-<slug>/HISTORY.md`.
- APK 1.0.302 built from `master` (logged in `DECISIONS.md`).

## Next steps, in order (owner, 2026-11-24)
1. **Screen 02, shared lesson top bar** (uses the free number 02; 01 is decided later). The bar at the top of **every kind of lesson**:
   progress bar, pause and back. Take it from the Angular original (`src/app/features/lessons/lesson-details`, and the bar of
   `interactive-lesson`): same structure and behaviour, restyled a little in the classy glass style of the other screens.
   Branch `flutter/02-lesson-bar` from `master`. Built as a reusable widget; the placeholder `lesson_page.dart` (screen 06) uses it
   straight away, so it can be tested on the phone. Procedure in `PROCESS.md`: plan and questions first, ChatGPT prompts for any
   missing art, build, critic with numbers, comparison, video, APK. No ChatGPT reference exists: show the owner the Angular
   original and a visual proposal before building.
2. **Screen 11, leaderboard (classifica)**, reference `11-classifica.webp` (branch `lesson-production`). Branch `flutter/11-leaderboard`.
3. **Then back to the main line:** final critic v4 of screen 06, then screen **07** (video lesson, with the bar of 02), then 09, 10/10b, and
   the rest in `SCREENS.md`. (Interpreted from "tornare alla diretta": confirm with the owner if another meaning was intended.)

## Open items, whenever the owner decides
- **Stable signing key:** owner chose to keep it **outside the repo** (file or environment secret); not supplied yet. Until then each
  container signs with its own debug key and the phone may ask to uninstall before updating. Never commit a key without explicit OK.
- **Style unification of 03/05/06: postponed by the owner.** List C1–C10 with proposals: `STYLE-CONFLICTS.md`. When done: apply in
  `rateel_theme.dart`, critic without exclusions per screen, desktop and phone (915×412). The new screens (02, 11) use the confirmed
  tokens of `DESIGN-SYSTEM.md` and report any conflict instead of copying silently.
- Screen 03 leftovers: gold-3D art for courses 08–12 has a baked-in card frame; classic-card course 03 icon weak.
- Data gaps: lessons exist only for course 01 and part of 02; courses 08–11 have no units; progress lives only in the session.

Build: `tools/flutter-review/build-apk.sh` (re-run if Gradle hits a 429 from the proxy). Log every APK as "APK 1.0.N" in `DECISIONS.md`.

## Prompt to start the next session (screen 02)
```
Lavora sul repo Rateel. Crea il branch flutter/02-lesson-bar partendo da master (le schermate 03-06 sono gia' unite).
Leggi prima CLAUDE.md, poi docs/flutter/DECISIONS.md, docs/flutter/PROCESS.md, docs/flutter/DESIGN-SYSTEM.md,
docs/flutter/LESSONS-LEARNED.md, docs/flutter/NEXT-SESSION.md, docs/flutter/SCREENS.md, docs/flutter/STYLE-CONFLICTS.md e
docs/flutter/screens/06-lessons/HISTORY.md.
Obiettivo: costruire in Flutter la barra in alto comune a tutti i tipi di lezione (schermata 02): barra di avanzamento,
pausa e ritorno indietro, come nel progetto Angular di origine (src/app/features/lessons/lesson-details e
interactive-lesson), con lo stesso comportamento ma uno stile un po' rivisto, "classy" come le altre schermate (token di
DESIGN-SYSTEM.md; se un valore confligge con un token, dimmelo e decido io). Widget riutilizzabile, da usare subito nella
pagina provvisoria delle lezioni (lesson_page.dart) per provarlo sul telefono.
Prima mostrami come e' l'originale Angular e una proposta visiva, con le domande, prima di costruire. Poi: prompt ChatGPT
per eventuali elementi mancanti in blocchi copiabili, costruzione, critico con le misure (anche formato telefono
915x412), confronto, video e APK. Crea HISTORY.md della schermata e tienilo aggiornato. Dopo la 02 si passa alla 11
(classifica), poi si torna alla linea principale (07 lezione video e le altre). Parla con me in italiano.
```

---

## Archive: hand-off that started screen 03 (2026-11-20)

Branch: `flutter/03-courses` (contains the approved side navigation, the rules, the tools and the logs).

## State at hand-off (2026-11-20)
- Side navigation (screen 04) done: closed rail approved; open menu v5 being tested on the phone.
- Design tokens confirmed: `DESIGN-SYSTEM.md`. Shared assets: `ASSETS.md`.
- Screen 03 plan: `screens/03-courses.md` (written before the nav work; update it first). Open points:
  course icons for the 12 courses and the screen animations were deferred to now.
- Assets already available that fit screen 03 (reuse = one style): vector arch
  (`assets/ui/decor/arch.svg`, header arch), outline open-book icon (`assets/ui/nav/quran.svg`, emblem on the
  arch apex), star tile (`assets/ui/decor/star_tile.svg`, faint pattern at the bottom of the cards), lattice
  corners. Still missing: mosque silhouette, crescent and star, the 12 course icons (prompts in
  `prompts/03-courses/images.txt`, to be re-checked and pasted in the chat).
- Data: `src/assets/data/courses.json` (Angular app) has the 12 courses.

## Prompt to start the session
```
Lavora sul branch flutter/03-courses del repo Rateel. Leggi prima CLAUDE.md, poi docs/flutter/DECISIONS.md,
docs/flutter/PROCESS.md, docs/flutter/DESIGN-SYSTEM.md, docs/flutter/ASSETS.md e docs/flutter/NEXT-SESSION.md.
Obiettivo: costruire in Flutter la schermata 03 dei corsi (المسارات التعليمية) uno a uno con il riferimento
ChatGPT (docs/flutter/screens/03-courses/reference.webp), accanto alla navigazione laterale già approvata.
Segui la procedura: aggiorna il piano della schermata, dammi i prompt ChatGPT per gli elementi mancanti in
blocchi copiabili, poi costruisci, fai passare il critico con le misure, e mandami confronto e video.
Parla con me in italiano.
```
