# Next session: unify the style (03–06), then screen 07

State on 2026-11-24:
- **Consolidation done:** PR #38 (04 side nav), #42 (03 courses), #39 (05 units, conflicts resolved) and #43 (06 lessons, opened in
  this session) are merged into `master` (merge commits, in this order); `flutter analyze` and `flutter test` (6 tests) pass.
- Screens 03–06 are approved by the owner; histories in `docs/flutter/screens/<nn>-<slug>/HISTORY.md`.

## Open tasks
1. **Stable signing key:** the owner chose to keep it **outside the repo** (file kept by the owner or an environment secret) and has
   not supplied it yet. Until then every container signs with its own debug key: the phone may ask to uninstall before updating.
   Never commit a key without the owner's explicit OK. Ask the owner how to hand the keystore over (environment secret is best).
2. **Style unification: postponed by the owner** ("we do it in the future"). Conflict list: `docs/flutter/STYLE-CONFLICTS.md`
   (C1–C10 with proposals). Ask the owner (card rim/ring as documented tokens, gold fills, text, radii), apply in
   `rateel_theme.dart` and the screens, then run the critic without exclusions per screen (`CRITIC.md`), desktop and phone (915×412).
3. Leftovers of screen 03 (optional): gold-3D art for courses 08–12 has a baked-in card frame; classic card course 03 icon weak.
4. **Screen 07** (video lesson): prompt below (from `flutter/06-lessons`). Its first step is the final critic v4 of screen 06.

Build: `tools/flutter-review/build-apk.sh`. Log every APK given to the owner as "APK 1.0.N" in `DECISIONS.md`.

## Prompt to start screen 07
```
Lavora sul repo Rateel. Crea il branch flutter/07-video-lesson partendo da master (le schermate 03-06 sono gia' unite).
Leggi prima CLAUDE.md, poi docs/flutter/DECISIONS.md, docs/flutter/PROCESS.md, docs/flutter/DESIGN-SYSTEM.md,
docs/flutter/ASSETS.md, docs/flutter/LESSONS-LEARNED.md, docs/flutter/NEXT-SESSION.md, docs/flutter/STYLE-CONFLICTS.md e
docs/flutter/screens/06-lessons/HISTORY.md (come abbiamo lavorato sulla 06).
Prima cosa: lancia il critico finale della schermata 06 (critic-v4) e dimmi il risultato.
Obiettivo: costruire in Flutter la schermata 07, lezione video (riferimento ChatGPT
docs/design/glassy-gamified/screens/07-lezione-video-dark.webp sul branch lesson-production), insieme alle
animazioni della versione Angular (src/app/features/lessons/video-player e lesson-details), con vibrazioni e luce.
Sostituisce la pagina provvisoria delle lezioni video (lesson_page.dart) e, a lezione finita, torna alla 06
restituendo true, cosi' parte il completamento; il progresso resta condiviso con lezioni, unita' e corsi.
Mostrami anche come era l'originale Angular. Segui la procedura: piano della schermata e domande prima di
costruire, prompt ChatGPT in blocchi copiabili, costruzione, critico con le misure, confronto, video e APK.
Tieni HISTORY.md della schermata aggiornato. Parla con me in italiano.
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
