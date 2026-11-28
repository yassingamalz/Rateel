# Next session (from 2026-11-28, after the merges)

**State.** `master` holds screen 24 (PR #68), the decisions of 2026-11-27 (PR #69) and screen 29 v1 (PR #70), plus the merge log.
**APK 1.0.647** (that `master`) sent to the owner: verdict pending on 24, 29 and the new sounds. GitHub push / PR worked in this
session: check the mode at the start (`CLAUDE.md`, "GitHub access: two modes"). Open items: `BACKLOG.md` (24 leftovers,
29 critic code items, 13, 31). No new screen without the owner's go.

---

## Archive: hand-off of 2026-11-27 night (before the merges)

**State.** `master` = `c2dec63` (APK 1.0.635). Two branches wait to be merged, **both only after the owner's approval**:
- **`flutter/24-end-of-lesson`** (7 commits on `c2dec63`, on GitHub): screen 24 v1, **APK 1.0.640 not yet tested** on the phone by
  the owner (2026-11-27). Details in the archived hand-off below and in `screens/24-end-of-lesson.md`.
- **`docs/decisions-2026-11-27`** (7 commits on `c2dec63`, handed over as patches; the owner applies and pushes them): the
  decisions session, all ✅ in `DECISIONS.md`: 26 = tab «النقاط» of 13; 28 «؟» = third item of the 02 pause menu; 30 onboarding
  without a required account (local data primary, optional account and sync later); 31 daily practice = own screen of the rail
  item «التدريب», phone reminder + skippable in-app popup after 1 day; 12 connector lit up to the open tile; **new test sounds**
  C8 plinkfx checkpoint (correct) and P7 plinkfx level-complete (passed, also used by 24 and 27), not yet heard in an APK.

**GitHub (temporary): no push from the cloud** (`CLAUDE.md`; the proxy answers 403 and adding the repository with push access is
denied). Clone the public repo, `git fetch` the branches above, check the commits are there, work on a local branch and hand the
commits as `git format-patch` files (one dedicated folder per group, PowerShell commands for `git am` and the push).

**Next steps:**
1. Check on GitHub that `docs/decisions-2026-11-27` exists with its 7 commits (if not, ask the owner to apply the patches).
2. Ask the owner the verdict on **APK 1.0.640** (screen 24). Corrections → on `flutter/24-end-of-lesson`, new APK.
3. **When the owner approves 24, and only after asking:** merge into `master`. Order: `flutter/24-end-of-lesson` first (fast-forward
   from `c2dec63`), then `docs/decisions-2026-11-27` rebased on it. Expected conflicts only in `DECISIONS.md` and `BACKLOG.md`
   (both branches append: keep every row, 24's first) and `NEXT-SESSION.md` (keep this version, updated). Hand the result as
   patches; log the merge in `DECISIONS.md` and tick 24 in `BACKLOG.md` / `SCREENS.md`.
4. APK from the merged `master` so the owner hears the new sounds (C8, P7) in the app, also at the end of a lesson (24).
5. Then 13 (and 29 after it), or the plan of 31: **only with the owner's go**. No new screen without it.

## Prompt to start the next session
```
Lavora sul repo Rateel (https://github.com/yassingamalz/Rateel, pubblico), da master. Il connettore GitHub è bloccato:
segui la sezione "GitHub access without the connector" di CLAUDE.md (clone in sola lettura, niente push né PR dal cloud,
lavori su un branch locale e mi mandi spesso i commit come file .patch con git format-patch; io li applico con git am e
faccio il push; dammi i comandi PowerShell, una cartella dedicata per ogni gruppo di patch). Leggi CLAUDE.md e tutti i file
che indica (DECISIONS.md, README.md, PROCESS.md, LESSONS-LEARNED.md, PERFORMANCE.md, BACKLOG.md), poi
docs/flutter/NEXT-SESSION.md (prima sezione) dal branch docs/decisions-2026-11-27, SCREENS.md e
docs/flutter/screens/24-end-of-lesson.md. Primo: controlla che i branch flutter/24-end-of-lesson e docs/decisions-2026-11-27
siano su GitHub e chiedimi com'è andata la prova dell'APK 1.0.640. Se approvo la 24, chiedimi conferma e preparami l'unione in
master di tutti e due (prima la 24, poi le decisioni), come patch, poi l'APK da master per sentire i nuovi suoni. Non
iniziare nessuna schermata nuova senza il mio via. Parlami in italiano, documenti in inglese.
```

---

## Archive: hand-off of 2026-11-27 evening (after screen 24 v1)

**State.** `master` = `c2dec63`: everything of the previous hand-off plus the **22 header variant g** (line with the diamond under
the title, owner-approved) and the GitHub patch workflow (`CLAUDE.md`). APK 1.0.635 = that `master`.
**Screen 24 (end of lesson) v1 built** on `flutter/24-end-of-lesson` (owner's go, Q1–Q7 and follow-up answers in `DECISIONS.md`,
plan `screens/24-end-of-lesson.md`, comparison `screens/24-end-of-lesson/compare-v1.jpg`), **APK 1.0.640**, waiting for the
owner's phone test and approval; the owner pushes the branch from the patches. Critic not run (ask first).
Open on 24: «passed» sound at the card only for video / reading (🟡), colours E1–E4 decided at the end of the project.
Screen 13 v1 waits on `claude/flutter-13-achievements-xa7myj`; 29, 28, 15–21 as before (archive below).

**GitHub (temporary): no push from the cloud.** Clone the public repo, work on a local branch, hand the commits to the owner as
`git format-patch origin/master` files (sent with the file tool, often); the owner applies them in PowerShell with
`git am (Get-ChildItem <folder>\*.patch | Sort-Object Name | ForEach-Object FullName)` from a dedicated folder, then pushes.
Before building on a branch the owner pushed, `git fetch` and check the commits are there. Procedure: `CLAUDE.md`.

**Next steps (proposal):**
1. Check that `flutter/24-end-of-lesson` is on GitHub with the 24 commits; owner's verdict on APK 1.0.640; corrections; when
   approved, merge into `master` (owner applies/pushes) and log it.
2. **Decisions session, remaining points** (interactive questions, one topic at a time): 26 points history inside 13,
   28 «؟» button place, 30 onboarding (account or not), 31 daily practice (own screen or inside 12), 12 connector (lit up to
   the open tile or all), **test sounds** (numbered candidates for «correct» and «passed», owner listens and picks; the
   badges' celebration and 24 reuse «passed»). Each answer in `DECISIONS.md` + `BACKLOG.md` in the same commit.
3. Then 13 (and 29 after it), only with the owner's go.

## Prompt to start the next session
```
Lavora sul repo Rateel (https://github.com/yassingamalz/Rateel, pubblico), da master. Il connettore GitHub è bloccato:
segui la sezione "GitHub access without the connector" di CLAUDE.md (clone in sola lettura, niente push né PR dal cloud,
lavori su un branch locale e mi mandi spesso i commit come file .patch con git format-patch; io li applico con git am e
faccio il push; dammi i comandi PowerShell, una cartella dedicata per ogni gruppo di patch). Leggi CLAUDE.md e tutti i file
che indica (DECISIONS.md, README.md, PROCESS.md, LESSONS-LEARNED.md, PERFORMANCE.md, BACKLOG.md), poi
docs/flutter/NEXT-SESSION.md (prima sezione), SCREENS.md, STYLE-CONFLICTS.md e docs/flutter/screens/24-end-of-lesson.md.
Primo: controlla che il branch flutter/24-end-of-lesson sia su GitHub con i commit della schermata 24 e chiedimi com'è
andata la prova dell'APK 1.0.640; se la approvo, preparami l'unione in master (patch, chiedimi prima). Secondo: sessione
delle decisioni sui punti rimasti (26, 28, 30, 31, connettore della 12, suoni dei test): domande interattive, una alla
volta, con il problema, le opzioni e la tua raccomandazione; scrivi ogni risposta in DECISIONS.md e BACKLOG.md nello
stesso commit. Per i suoni dei test preparami campioni numerati da ascoltare. Non iniziare nessuna schermata nuova senza
il mio via. Parlami in italiano, documenti in inglese.
```

---

## Archive: hand-off of 2026-11-27 (after the performance fix and the saved progress)

**State.** In `master`: 01, 02, 03, 04, 05, 06, 07, 08, 10/10b (+25), 11, 12, 14, 22 (with the owner's H1 headphones),
23, 27, plus **#66 performance fix** (same look) and **#67 progress saved on the device** (merged 2026-11-27, owner).
Screen **13** v1 waits on `claude/flutter-13-achievements-xa7myj` («a particular screen, we come back to it»). **15–21**
postponed to the future. Built outside the process, waiting for the owner: `flutter/29-profile-approved` (APK 1.0.490),
`flutter/28-help` (reading help overlay), `flutter/15-21-guided-lesson` (APK 1.0.445). Splash checked on the phone: OK
(heartbeat for later, `BACKLOG.md`). No APK yet with #66/#67/H1.

**Next steps (proposal):**
1. APK from `master` for the phone test (lighter animations, progress kept after closing the app, 22 headphones).
2. **Decisions session** (owner, 2026-11-27: «another session»): 24 end of lesson (keep or drop; the +10 points of 22),
   26 points history inside 13, 28 «؟» button place, 30 onboarding (account or not), 31 daily practice (own screen or
   inside 12), 12 connector (lit up to the open tile or all), **test sounds** (new candidates for «correct» and
   «passed», owner listens and picks by number; the badges' celebration reuses «passed»).
3. Then: back to 13 (and 29 after it), or what the owner chooses.

## Prompt to start the next session
```
Lavora sul repo Rateel, da master. Leggi CLAUDE.md e tutti i file che indica (DECISIONS.md, README.md, PROCESS.md,
LESSONS-LEARNED.md, PERFORMANCE.md, BACKLOG.md), poi docs/flutter/NEXT-SESSION.md (prima sezione), SCREENS.md e
STYLE-CONFLICTS.md. Per prima cosa fammi l'APK da master (tools/flutter-review/build-apk.sh): contiene il fix delle
prestazioni, i progressi salvati e le cuffie della 22, lo provo sul telefono. Poi facciamo la sessione delle decisioni:
per ogni punto aperto della lista in NEXT-SESSION.md (24, 26, 28, 30, 31, connettore della 12, suoni dei test) spiegami
in breve il problema e le opzioni con la tua raccomandazione, una domanda alla volta, e scrivi ogni mia risposta in
DECISIONS.md e BACKLOG.md nello stesso commit. Per i suoni dei test preparami dei campioni numerati da ascoltare. Non
iniziare nessuna schermata nuova senza il mio via. Parlami in italiano, documenti in inglese.
```

---

## Archive: timeline from 2026-11-26 (confirmed by the owner)

State on `master` (2026-11-27): approved and merged **01 splash, 02 lesson bar, 03 courses, 04 side nav, 05 units,
06 lessons, 07 video, 08 reading, 10/10b test (with 25 results inside), 11 leaderboard, 12 daily challenges,
14 coming soon, 22 listening lesson (PR #56 and its follow-up), 23 settings**; timeline confirmed by the owner
(2026-11-26); 24 end of lesson postponed by the owner (2026-11-27); 28 help overlay postponed (BACKLOG); **27 badges** started on `flutter/27-badges` (waiting for the medals M01–M12, L1); settings gear centred in the rail (PR #54). Open items: `BACKLOG.md`.

## Timeline (Claude's proposal, 2026-11-26; owner to confirm or reorder)
**Phase A: lessons (the core of the app)**
1. **22 listening lesson**: reference and plan ready (`screens/22-listening-lesson.md`), reuses the 10/10b widgets.
2. **24 end of lesson** (points, stars, continue): shared by every lesson type, as 02.
3. **15–21 guided lesson** (start, concept, definition, quiz, comparison, verse listening, summary): reuses 08, 10, 22.

**Phase B: progress and rewards**
4. **13 achievements**, with **27 badges / achievement detail** and **26 points history** (may live inside 13).
5. **29 profile** (may merge with 23).

**Phase C: first use**
6. **28 help / tips overlay** (first use of each lesson type).
7. **30 onboarding** (first start: name, level, goal).

**Phase D: the hardest screen**
8. **09 practice lesson / recitation** (postponed by the owner, maybe last).

**Phase E: before release**
9. Performance fix (`PERFORMANCE.md`, owner's yes), real data instead of mock (rail counts, leaderboard, challenges,
   video sections), saved progress (and reset), daily reminder notification, remove the long-press completion,
   stable signing key, style conflicts (`STYLE-CONFLICTS.md`), asset standardisation, critics still open (06, 08, 23, 01),
   phone check of the splash.

## Prompt to start the next session
```
Lavora sul repo Rateel, da master. Leggi CLAUDE.md e tutti i file che indica (DECISIONS.md, README.md, PROCESS.md,
LESSONS-LEARNED.md, PERFORMANCE.md, BACKLOG.md), poi docs/flutter/NEXT-SESSION.md, SCREENS.md, DESIGN-SYSTEM.md,
STYLE-CONFLICTS.md, ASSETS.md e docs/flutter/screens/22-listening-lesson.md. Mostrami prima la timeline di
NEXT-SESSION.md e chiedimi se confermo l'ordine. Poi schermata 22, lezione di ascolto, branch flutter/22-listening-lesson
da master: identica al riferimento screens/22-listening-lesson/22-lezione-ascolto.webp, riusando i widget di 10/10b e la
barra 02. Prima piano visivo e domande aperte (aspetta il mio sì), poi prompt ChatGPT per gli asset mancanti (un blocco
copiabile ciascuno, dimmi quali immagini allegare), costruzione, verifica elemento per elemento, video e APK. Regole di
PERFORMANCE.md, controllo a testo 110%, tutto ciò che resta per dopo in BACKLOG.md. Il critico solo quando te lo dico.
Crea HISTORY.md della schermata. Parla con me in italiano.
```

---

## Archive: hand-off after screens 10 / 10b (2026-11-26)

**Update 2026-11-25:** PR #49 (screen 08) is **merged into `master`**. Screen **09 (practice / recitation) is postponed**
by the owner (one of the hardest, done later, maybe last). Screens **10 / 10b (test lesson + answer feedback)** started on
`flutter/10-test-lesson` from `master`: plan `screens/10-test-lesson.md` (questions Q1–Q8), prompts T1–T3, history
`screens/10-test-lesson/HISTORY.md`. **approved (v13) and merged into `master`**. Backlog in `SCREENS.md`
(long-press completion to remove before release, test sounds, end popup). Next screen: ask the owner (09 is postponed;
candidates 12, 13, 15–21).

**Backlog (owner, 2026-11-26):** end-of-test popup (removed from screen 10: the results show the same); designs A/B in
`screens/10-test-lesson/end-popup-variants-v6.jpg` if it comes back.

## Prompt to continue
```
Lavora sul repo Rateel, branch flutter/10-test-lesson. Leggi CLAUDE.md, poi docs/flutter/DECISIONS.md, PROCESS.md,
DESIGN-SYSTEM.md, LESSONS-LEARNED.md, PERFORMANCE.md, NEXT-SESSION.md, SCREENS.md, STYLE-CONFLICTS.md, ASSETS.md,
docs/flutter/screens/10-test-lesson.md e docs/flutter/screens/10-test-lesson/HISTORY.md. Continua le schermate 10/10b
dal punto in cui è rimasta la storia. Il critico solo quando te lo dico. Parla con me in italiano.
```

---

## Archive: hand-off after screen 08 (2026-11-25)

## Merge 08, performance fix, then screen 09 (practice / recitation)

**Update 2026-11-25:** screen 08 (reading lesson, `lib/lessons/reading_lesson_page.dart`) is **approved** (v12) on branch
`flutter/08-reading-lesson`, not yet merged. History `screens/08-reading-lesson/HISTORY.md`. New shared pieces: light theme
for the lesson chrome (`LessonShell(light:)`, `LessonPill`/`LessonRoundButton`/`SkipButton(light:)`), `LessonRoundButton(
compact:)`, `GradientRimPainter`, `GoldDivider(diamond:)`, tajweed colour wheel `TajweedColors` (for the **ayat only**,
`DESIGN-SYSTEM.md`). APK builds: Maven Central may answer 429 through the proxy; retry with long pauses (the Gradle cache
then fills and later builds take ~1 min).

## Next steps (proposal, confirm with the owner)
1. PR `flutter/08-reading-lesson` → `master` and merge (ask the owner first).
2. Performance fix (`PERFORMANCE.md`), branch `flutter/perf` from `master`, if the owner says yes.
3. Screen 09, practice lesson / recitation (`09-lezione-pratica-recitazione-*.webp`, dark/light), Angular original, with
   the bar of 02 and the shared lesson widgets (light theme ready). Branch `flutter/09-practice-lesson` from `master`.
4. Later: critic of 08 and final critic of 06 (phone only, ask first); conflicts R1–R7 with the others at the end.

## Prompt to start the next session
```
Lavora sul repo Rateel. Leggi CLAUDE.md, poi docs/flutter/DECISIONS.md, PROCESS.md, DESIGN-SYSTEM.md, LESSONS-LEARNED.md,
PERFORMANCE.md, NEXT-SESSION.md, SCREENS.md, STYLE-CONFLICTS.md, ASSETS.md e docs/flutter/screens/08-reading-lesson/HISTORY.md.
Prima chiedimi se unire la PR di flutter/08-reading-lesson in master. Poi schermata 09, lezione pratica / recitazione, uno a
uno con i riferimenti 09-lezione-pratica-recitazione dark/light (branch lesson-production, docs/design/glassy-gamified/screens/)
e l'originale Angular, con la barra 02 e i widget condivisi delle lezioni (tema chiaro compreso). Branch
flutter/09-practice-lesson da master. Prima piano e domande, poi prompt ChatGPT per gli elementi mancanti (uno per blocco
copiabile, dimmi quali immagini allegare), costruzione, verifica elemento per elemento con i numeri, confronto, video e APK.
Segui le regole di PERFORMANCE.md. Conflitti nel registro STYLE-CONFLICTS.md (si decidono a fine progetto). Il critico solo
quando te lo dico. Crea HISTORY.md della schermata. Parla con me in italiano.
```

---

## Archive: hand-off that started screen 08 (2026-11-24/25)

**Update 2026-11-25 (screen 08):** reading lesson v6 built on `flutter/08-reading-lesson` (dark + light, rules panel, «A»
menu; `lib/lessons/reading_lesson_page.dart`), waiting for the owner's phone test. Open: arch asset R4, conflicts R1–R7,
«A»/number serif font. History `screens/08-reading-lesson/HISTORY.md`.

**Update 2026-11-25:** screen 14 (coming soon, `lib/coming_soon/coming_soon_screen.dart`) is **approved** (APK 1.0.375)
and merged into `master`. It uses the Cairo font (owner's choice, conflict S4) and the owner's baked background. Next
steps unchanged: performance fix (`PERFORMANCE.md`, if the owner says yes), then screen 08.

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
