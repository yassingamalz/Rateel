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
- [ ] **Asset standardisation** (owner, 2026-11-26): the references' header assets (mosque, crescent + star, calendar,
      arch, divider) are candidates to regenerate once for the whole app: `ASSET-STYLE-COMPARISON.md`, `ASSETS.md`.
- [ ] **Style conflicts** to decide at the end of the project, one choice for the whole app: `STYLE-CONFLICTS.md`.
- [ ] **Mock data** to connect before release (leaderboard, video sections, rail counts, daily challenges):
      `SCREENS.md`, «Screens running on mock data»; data problems in the same file.
- [ ] **Performance fix** (`PERFORMANCE.md`, branch `flutter/perf`), waiting for the owner's yes.
- [ ] **Stable signing key** for the APKs, kept outside the repo (owner to supply).
- [ ] Critic of screen 08 and final critic of screen 06 (phone only, ask first).
- [ ] Screen 07: YouTube link of `rateel-lezione1-v2.mp4` and the real section times.
- [ ] Screen 08: tajweed colours for the ayat (wheel in `DESIGN-SYSTEM.md`), audio example of the rules.
- [ ] **Refresh the app screenshots** used as ChatGPT references (`app-references/`, rule in `LESSONS-LEARNED.md`)
      after each approved screen: 12 and 23 are not in it yet (2026-11-26).
- [ ] **`NEXT-SESSION.md` is out of date on `master`** (still says «merge 08, then 09»): rewrite it with the real
      order once the owner chooses the order of the remaining screens (asked 2026-11-26).
- [ ] **Screens still to build**, numbers in `SCREENS.md`: 09 (postponed, maybe last), 13, 15–21, 22, and the ones
      added on 2026-11-26 in the agreed order: 01 splash, 24 end of lesson, 25 test results, 26 points history,
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

## Screen 22, listening lesson (reference on `master`)
- [ ] Build after 10/10b, reusing its question and feedback widgets (`screens/22-listening-lesson.md`).
- [ ] Open questions for the owner: answers side by side (reference) or stacked as 10b; also «tap the word where you
      heard the ghunna» questions; points (+10) or no points.

## Screen 01, splash (references on branch `flutter/01-splash`, not started)
- [ ] When it starts: first the list of what to ask ChatGPT (logo emblem without glow, maybe the background), then
      build it **identical** to `01-avvio.webp` with the motion of `01-avvio-square.gif` (`screens/01-splash.md`).
- [ ] Error state with «إعادة المحاولة» (Angular has it): asked to the owner, not answered yet.
- [ ] Android native splash in the same green, so nothing flashes before Flutter starts.

## Lesson content (`docs/content/`, branch of the content review)
- [ ] **Check the content against the book PDFs** «التجويد المصور» page by page (Claude, 2026-11-27): transcribe each
      chapter into `docs/content/sources/musawwar/` and compare. **Done: ch. 02–11.** To do: ch. 01, 12–22. PDFs download with `https://drive.usercontent.google.com/download?id=<ID>&export=download&confirm=t`
      (ids in `lesson-production:docs/production/LESSONS-TRACKER.md`).
- [ ] Rewrite or drop the weak "app policy" questions and expand the 3-line narrations 58–70 into full lesson scripts
      (`REVIEW-2026-11-27.md`, «Still open»).
- [ ] Write the optional tashil/ibdal topic (آلذكرين، آلآن، آلله) and الاسم (49:11).
