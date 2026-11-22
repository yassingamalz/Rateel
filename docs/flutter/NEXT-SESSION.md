# Next session: screen 06, lessons of the unit (دروس الوحدة)

Screen 05 is done (v5, waiting for the owner's approval and its PR): read `docs/flutter/screens/05-units/HISTORY.md`.
Branch `flutter/06-lessons` from `flutter/05-units`. Reference: `docs/design/glassy-gamified/screens/06-lezioni-dell-unita.webp`
on `lesson-production`. Screen 06 replaces the toast «دروس الوحدة: قريبًا» in `units_screen.dart` (`_openLessons`) and
sets `unitCompleted` when the last lesson of a unit ends. Cloud environment "Rateel" has the hosts for the APK build.

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
