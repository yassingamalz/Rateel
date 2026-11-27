# Backlog: things to do later (Flutter app)

One list of the work left for later, so nothing is forgotten. Add a line here (with date and owner/Claude) whenever
something is postponed; remove it (and log it in `DECISIONS.md`) when it is done. Details live in the linked files.

## Screen 12, daily challenges (approved 2026-11-26)
- [ ] **Back gesture not intuitive** (owner, 2026-11-26): today the finger dragged to the right closes 12 (plus Android
      back and the courses icon of the rail). Find a clearer way back, still without a button if possible.
- [ ] **Wire the challenges to real progress** (plan Q3): complete a challenge when the user comes back having done
      its activity (lesson, practice, recitation); reset the path at midnight; save challenges and streak; streak +1
      per day with at least one challenge, 0 after a missed day. Today: mock, in memory, completion by long press.
- [ ] Connector between the tiles: lit only up to the open tile (as 03/05) or all six links lit as the reference?
      Asked to the owner, not answered yet.
- [ ] Practice / recitation challenges open screen 14 «coming soon» until screen 09 exists.
- [ ] Courses icon of the rail tapped inside the learning section goes back to the courses only from 12: decide if
      units (05) and lessons (06) should do the same.

## App-wide
- [ ] **Screen 28, help / tips overlay** (owner 2026-11-27: future improvement). Reference `screens/28-help-overlay/reference.webp`,
      notes `screens/28-help-overlay.md`. Owner's answers: shown the **first time** each lesson type opens, then remembered
      (saved); reopened by a small **«؟» button** (place to decide: maybe the 02 pause menu); which lesson first: later
      (it serves every lesson type). Fix of the reference: each tip must describe the control it points at.
- [ ] **Screen 24, end of lesson** (postponed by the owner 2026-11-27: «probably not needed»): plan v1, questions Q1–Q7
      and reference prompts in `screens/24-end-of-lesson.md`, `prompts/24-end-of-lesson/reference-v1.txt`. Decide whether to
      drop it; the +10 points of 22 are still shown nowhere at the end.
- [ ] **Screens 15–21, guided lesson** (owner 2026-11-27: future, not now): a mixed lesson, video in sections with other
      activities between them (Angular prototype `guided-lesson`, references `15…21-lezione-guidata-*.webp`); today covered by
      07 + 08 + 10 + 22. Owner's preview on `flutter/15-21-guided-lesson` (APK 1.0.445, from an old `master`, outside the
      process: no plan, verification or critic).
- [ ] **Asset standardisation** (owner, 2026-11-26): the references' header assets (mosque, crescent + star, calendar,
      arch, divider) are candidates to regenerate once for the whole app: `ASSET-STYLE-COMPARISON.md`, `ASSETS.md`.
- [ ] **Style conflicts** to decide at the end of the project, one choice for the whole app: `STYLE-CONFLICTS.md`.
- [ ] **Mock data** to connect before release (leaderboard, video sections, rail counts, daily challenges):
      `SCREENS.md`, «Screens running on mock data»; data problems in the same file.
- [x] **Performance fix** (`PERFORMANCE.md`, branch `flutter/perf`): done 2026-11-27 (same look). Still to do: frame times
      measured on the owner's phone (APK).
- [ ] **Stable signing key** for the APKs, kept outside the repo (owner to supply).
- [ ] Critic of screen 08 and final critic of screen 06 (phone only, ask first).
- [ ] Screen 07: YouTube link of `rateel-lezione1-v2.mp4` and the real section times.
- [ ] Screen 08: tajweed colours for the ayat (wheel in `DESIGN-SYSTEM.md`), audio example of the rules.
- [x] **Refresh the app screenshots** used as ChatGPT references (`app-references/`): done 2026-11-27 (12, 22, 23, 10 and
      light added; refresh again after each approved screen).
- [x] **Order of the remaining screens**: timeline of `NEXT-SESSION.md` confirmed by the owner (2026-11-26).
- [ ] **Daily practice (screen 31)**: forgotten in the lists until 2026-11-26 (owner); define it (own screen or inside 12)
      and design it; it reuses the listening quiz of 22.
- [ ] **Screens still to build**, numbers in `SCREENS.md`: 09 (postponed, maybe last), 13, 15–21, 22, and the ones
      added on 2026-11-26 in the agreed order: 24 end of lesson, 25 test results, 26 points history,
      27 badges / achievement detail, 28 help overlay, 29 profile, 30 onboarding.

## Screen 10/10b, test lesson (approved 2026-11-26)
- [ ] **Long press completes** a course / unit / lesson at once (review aid for testing; owner 2026-11-26: fine for
      now, **remove before release**): `courses_screen.dart` (onLongPress ≈ l. 384), `units_screen.dart` (≈ l. 452),
      `lessons_screen.dart` (≈ l. 442), and the same on the challenges of 12.
- [ ] **Test sounds to improve** (owner, 2026-11-26), above all the **completion (passed)** and the **correct answer**
      (now plinkfx level-up / gem, CC0): `assets/sounds/test_*.mp3`, sampler in `docs/design-assets/test-lesson/sounds/`.
- [ ] **End-of-test popup** (score, points, pass/fail, countdown) removed from 10 (owner: the results show the same);
      designs A/B in `screens/10-test-lesson/end-popup-variants-v6.jpg` if it comes back.
- [ ] Lightbulb (recommendations) and ↻ (not passed) are still Material icons in the lesson gold: drawn ones if wanted.
- [ ] Star coins emerald and mint (`ui/test/star_coin_{emerald,mint}.webp`) in the library, not used yet.

## Screen 23, settings (approved 2026-11-26)
- [ ] **Daily reminder**: today only stored; wire the real notification with screen 12 (owner, 2026-11-26):
      notifications package, Android permission, the time chosen in settings.
- [ ] **Reciter**: today only stored; use it for the audio of the listening lessons (22) and the rules' audio
      examples (08). The 4 names (الحصري، المنشاوي، عبد الباسط، العفاسي) are OK **for now** (owner).
- [ ] **Light theme** changes only lesson 08 (owner OK for now): every other screen follows it once its light design
      exists.
- [ ] **Text size** 90–110%: course cards and screen 14 do not scale; every new screen must be checked at 110%
      (`?textScale=1.1`) and opt out the same way if a fixed art layout breaks.
- [ ] **Reset progress** clears the in-memory progress only: when progress is saved for real, the reset must clear
      the saved data too.
- [ ] **Critic of 23**: the owner launches it himself when he wants.
- [ ] Side rail with 7 items scrolls: check on small / tall phones that the gear is easy to find.

## Screen 22, listening lesson (approved 2026-11-27)
- [ ] **Headphones asset H1** from the owner (placeholder today: the 06 «listen» icon).
- [ ] **Audio for the release** (owner, Q1): stream the ayat from everyayah.com (or another host) with the **reciter of
      the settings** (23), cached; the word times per reciter come with the data (today: Husary only, times by hand).
- [ ] **«Tap the word where you heard the ghunna»** question type (owner, Q4: later).
- [ ] **Real listening lessons** in the data (today one mock lesson, سورة الكوثر, in the unit «النون المشددة»).
- [ ] **Word light as a user setting** (owner, 2026-11-26): glowing letters (default) or the light box around the word
      (`listenWordLight`, `?wordLight=box`; look in `screens/22-listening-lesson/word-light-variants.jpg`); add the switch
      to the settings (23).
- [ ] **Loudness normalisation of the recitations** (owner, 2026-11-26: later, to hear first): same level for every
      ayah, fuller on phone speakers; today the Husary files are bundled as downloaded.
- [x] Guided voice for the listening lessons (Gemini 3.1 TTS, Orus, calm style): done 2026-11-26 (DECISIONS).
- [ ] **Rotate the API keys pasted in the chat** on 2026-11-26 (Gemini, YouTube, Plainsight): owner. The narration
      script reads `GEMINI_API_KEY` from the environment; no key is stored in the repo.
- [ ] Points (+10) are counted in the lesson only: show them at the end of the lesson (screen 24) and save them.
- [ ] **Listening quiz** (owner, 2026-11-26): the first version of 22 (listen, then «what did you hear in the word X?»)
      stays on the branch as the lesson «اختبار الاستماع»; later it becomes part of the **practice after several rules**,
      of the **daily practice** (screen 31) and possibly a question type of the tests (10).
- [ ] Rule lessons for the other rules (qalqala, madd, ikhfa, …) with their wheel colours: data only (the page reads
      `rule.colour`).

## Screen 01, splash (merged into `master` 2026-11-26)
- [ ] Owner review on a physical phone, including the native launch handoff. Browser capture:
      [startup-phone.mp4](screens/01-splash/startup-phone.mp4).
- [ ] Small differences from `01-avvio.webp` seen at the merge check (Claude, 2026-11-26): the gold divider is
      wider than the reference (x ≈ 660–1180 vs 693–1150); the status reads «جارٍ» with tanween, the reference «جار».
      Owner to decide whether to align them. The critic was not run on screen 01.

## Screen 27, badges (approved 2026-11-27, merged into `master`; **still has placeholders**)
Placeholders to replace before release:
- [ ] **Mock data**: the 12 badges, their requirements, rewards and progress (4 earned, M05 34/50…) are invented (`lib/badges/badge_data.dart`) and live in memory only. Wire them to real progress (lessons, units, tests, streak, recordings): set `badgeEarned.value = id` when a requirement is reached; save progress; M09 needs screen 09 (recordings).
- [ ] **Rewards** («5K», «100»…) are display only: add the coins to the points when real data exists.
- [ ] **Rail count bubble** of «الإنجازات» (5) is a demo value: use the number of earned badges.
- [ ] **Celebration sound and haptics** reuse the test «passed» sound (`Sounds.passed`): choose a dedicated sound with the other test sounds.
- [ ] **Review aids** to remove or keep hidden at release: `?earn=`, `?medals=`, `?section=`.
- [ ] **Unused kit** in the library: `blank_olive`, `blank_gold`, `l1` (locked medal) are spare.
- [ ] Phone checks at text size 110% (`?textScale=1.1`): the detail panel text.
- [ ] **More variety between the badges** (owner, 2026-11-27): today every medal is the same rosette with a different icon. Generate **other badges in other styles** (other shapes, metals, ribbons, frames), so that the user is curious to see what the next ones look like and wants to earn them. Needs: a plan of the style families (e.g. by level or theme), ChatGPT prompts (pasted in the chat, with the app screenshots and the current medals as style references), the progress-fill kit (empty medal + filled one + padlock) for each style, and a choice of which badge gets which style.

## Screen 13, achievements (to do): 27 is part of it
**Owner, 2026-11-27: 13 and 27 are different screens.** 13 is the achievements page with the **levels** (points, level, progress bar, tabs الإنجازات / الأوسمة / النقاط / المجموعة, achievement cards; reference `13-traguardi`, copy in `screens/27-badges/ref-13-traguardi.png`). **27 (badges) is reached from 13** (tab «الأوسمة»). Until 13 exists, the rail item «الإنجازات» opens 27 directly; when 13 is built, the rail opens 13 and 27 opens from its «الأوسمة» tab.
- [ ] Build screen 13 (plan, levels, tabs) and link it to 27.

## Lesson content (`docs/content/`, branch of the content review)
- [x] **Check the content against the book PDFs** «التجويد المصور» page by page (Claude, 2026-11-27): transcribe each
      chapter into `docs/content/sources/musawwar/` and compare. **Done: all 22 chapters (2026-11-27).** PDFs download with `https://drive.usercontent.google.com/download?id=<ID>&export=download&confirm=t`
      (ids in `lesson-production:docs/production/LESSONS-TRACKER.md`).
- [ ] Rewrite or drop the weak "app policy" questions and expand the 3-line narrations 58–70 into full lesson scripts
      (`REVIEW-2026-11-27.md`, «Still open»).
- [x] Optional tashil/ibdal (آلذكرين، آلآن، آلله) written from the book ch. 19 (pool 99, 2026-11-27); الاسم is in ch. 15 p. 471.
