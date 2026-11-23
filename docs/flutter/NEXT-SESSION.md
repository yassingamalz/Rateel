# Next session: screen 07, video lesson (درس فيديو)

Screen 06 is approved (2026-11-23, look B, APK 1.0.299): read `docs/flutter/screens/06-lessons/HISTORY.md`.
Its final critic (v4) is still to run: start the session with it (prompt in `HISTORY.md` §7 / `CRITIC.md`).
Branch `flutter/07-video-lesson` from `flutter/06-lessons`. Reference: `docs/design/glassy-gamified/screens/07-lezione-video-dark.webp`
(also `-light`) on `lesson-production`. Screen 07 replaces the placeholder `lib/lessons/lesson_page.dart` for `video` lessons
and must keep its contract: return `true` when the lesson is finished (screen 06 then plays the completion).
Angular original: `src/app/features/lessons/video-player`, `lesson-details`. Data: `videoUrl` in `src/assets/data/lessons/*/*.json`.

## Prompt to start the session (screen 07)
```
Lavora sul repo Rateel. Crea il branch flutter/07-video-lesson partendo da flutter/06-lessons.
Leggi prima CLAUDE.md, poi docs/flutter/DECISIONS.md, docs/flutter/PROCESS.md, docs/flutter/DESIGN-SYSTEM.md,
docs/flutter/ASSETS.md, docs/flutter/LESSONS-LEARNED.md, docs/flutter/NEXT-SESSION.md e
docs/flutter/screens/06-lessons/HISTORY.md (come abbiamo lavorato sulla 06).
Prima cosa: lancia il critico finale della schermata 06 (critic-v4) e dimmi il risultato.
Obiettivo: costruire in Flutter la schermata 07, lezione video (riferimento ChatGPT
docs/design/glassy-gamified/screens/07-lezione-video-dark.webp sul branch lesson-production), insieme alle
animazioni della versione Angular (src/app/features/lessons/video-player e lesson-details), con vibrazioni e luce.
Sostituisce la pagina provvisoria delle lezioni video (lesson_page.dart) e, a lezione finita, torna alla 06
restituendo true, così parte il completamento; il progresso resta condiviso con lezioni, unità e corsi.
Mostrami anche come era l'originale Angular. Segui la procedura: piano della schermata e domande prima di
costruire, prompt ChatGPT in blocchi copiabili, costruzione, critico con le misure, confronto, video e APK.
Tieni HISTORY.md della schermata aggiornato. Parla con me in italiano.
```

---

# Next session: screen 06, lessons of the unit (دروس الوحدة)

Screen 05 is approved (2026-11-22, PR open): read `docs/flutter/screens/05-units/HISTORY.md`.
Branch `flutter/06-lessons` from `flutter/05-units`. Reference: `docs/design/glassy-gamified/screens/06-lezioni-dell-unita.webp`
on `lesson-production`. Screen 06 replaces the toast «دروس الوحدة: قريبًا» in `units_screen.dart` (`_openLessons`) and
sets `unitCompleted` when the last lesson of a unit ends. Cloud environment "Rateel" has the hosts for the APK build.

## Prompt to start the session (screen 06)
```
Lavora sul repo Rateel. Crea il branch flutter/06-lessons partendo da flutter/05-units.
Leggi prima CLAUDE.md, poi docs/flutter/DECISIONS.md, docs/flutter/PROCESS.md, docs/flutter/DESIGN-SYSTEM.md,
docs/flutter/ASSETS.md, docs/flutter/LESSONS-LEARNED.md, docs/flutter/NEXT-SESSION.md e
docs/flutter/screens/05-units/HISTORY.md (come abbiamo lavorato sulla 05).
Obiettivo: costruire in Flutter la schermata 06, lezioni dell'unità (riferimento ChatGPT
docs/design/glassy-gamified/screens/06-lezioni-dell-unita.webp sul branch lesson-production), insieme alle
animazioni della versione Angular (src/app/features/lessons), con vibrazioni e luce sui completamenti.
Deve sostituire il toast «دروس الوحدة: قريبًا» delle unità e chiamare unitCompleted quando finisce l'ultima
lezione di un'unità; il progresso è condiviso con unità e corsi.
Segui la procedura: piano della schermata e domande prima di costruire, prompt ChatGPT in blocchi copiabili,
costruzione, critico con le misure, confronto, video e APK. Tieni HISTORY.md della schermata aggiornato.
Parla con me in italiano.
```

---

# Next session: screen 03, courses (المسارات التعليمية)

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
