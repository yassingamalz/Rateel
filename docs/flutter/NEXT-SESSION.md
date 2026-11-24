# Next session: consolidate screens 03–06 (do this BEFORE screen 07)

State on 2026-11-24:
- Screen 03 (courses) approved, APK 1.0.301, PR #42 `flutter/03-courses` → `master`; history `screens/03-courses/HISTORY.md`.
- Screen 04 (side nav) PR #38; screen 05 (units) PR #39 (approved, APK 1.0.106); screen 06 (lessons) approved
  on `flutter/06-lessons` (APK 1.0.299), PR still to open. Screen 07 (video lesson) is planned in the
  `NEXT-SESSION.md` of `flutter/06-lessons`: it comes after this session.

## Tasks, in order
1. **Merge into `master`, in this order**, each only after the owner's OK in the chat:
   #38 (04 side nav) → #42 (03 courses) → #39 (05 units) → PR of `flutter/06-lessons` (open it first).
   `flutter/05-units` branched from 03 at `ce7ebc9` and also edits `lib/courses/courses_screen.dart` and
   `lib/main.dart`: resolve there (keep 03's illustrated cards, `cardArtSet`, `withNoTextScaling`, haptics, and
   05's navigation to the units). Docs (`DECISIONS.md`, `ASSETS.md`, `LESSONS-LEARNED.md`, `NEXT-SESSION.md`):
   keep the rows of both sides, in date order. After each merge: `flutter analyze && flutter test`.
2. **Stable signing key** (owner decides): today every cloud container signs with its own debug key, so the
   phone may refuse to update an APK built elsewhere. Options: (a) the owner authorises committing a dev
   keystore (debug format, public passwords, side-loading only); (b) keep it outside the repo (file kept by the
   owner, or an environment secret). Ask first; never commit a key without the owner's explicit OK.
3. **One style for the whole app**: compare the colours, rims, radii, shadows and text styles of screens 03, 05
   and 06 (`RateelColors`, sections per screen) with the confirmed tokens in `DESIGN-SYSTEM.md`; list every
   conflict (value, where, proposed token) and let the owner decide; then unify in `rateel_theme.dart` and the
   screens. Critic without exclusions on each screen afterwards (`CRITIC.md`), phone captures too (915×412).
4. Small leftovers of screen 03 (optional): gold-3D art for courses 08–12 has a baked-in card frame (spare set);
   classic-card course 03 icon reads weakly (only used with `?cards=classic`).
5. Then go on with **screen 07** (prompt in `flutter/06-lessons:docs/flutter/NEXT-SESSION.md`).

Build: `tools/flutter-review/build-apk.sh` (versionCode above every APK already shipped from any
`flutter/*` branch). Log every APK given to the owner as "APK 1.0.N" in `DECISIONS.md`.

## Prompt to start the session
```
Lavora sul repo Rateel, partendo dal branch flutter/03-courses. Leggi prima CLAUDE.md, poi docs/flutter/DECISIONS.md,
docs/flutter/PROCESS.md, docs/flutter/DESIGN-SYSTEM.md, docs/flutter/LESSONS-LEARNED.md e docs/flutter/NEXT-SESSION.md,
e le storie delle schermate (docs/flutter/screens/03-courses/HISTORY.md, e sui branch flutter/05-units e
flutter/06-lessons i loro HISTORY.md).
Obiettivo, prima della schermata 07: consolidare le schermate 03–06.
1) Unisci in master le pull request nell'ordine #38 → #42 → #39 → 06 (apri prima la PR di flutter/06-lessons),
   chiedendomi l'ok prima di ogni merge; risolvi i conflitti tenendo il lavoro di entrambe le parti e fai passare
   analyze e test dopo ogni unione.
2) Chiedimi come gestire la chiave di firma unica per gli APK (non salvarla nel repo senza il mio ok esplicito).
3) Confronta colori, bordi, raggi, ombre e testi delle schermate 03, 05 e 06 con i token di DESIGN-SYSTEM.md,
   dammi la lista dei conflitti da decidere, poi uniforma e fai passare il critico senza eccezioni, anche in
   formato telefono.
Alla fine dammi l'APK con la nuova versione. Parla con me in italiano.
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
