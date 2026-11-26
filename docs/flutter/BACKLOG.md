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
- [x] **Order of the remaining screens**: timeline of `NEXT-SESSION.md` confirmed by the owner (2026-11-26).
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

## Screen 22, listening lesson (v5 built 2026-11-26)
- [ ] **Headphones asset H1** from the owner (placeholder today: the 06 «listen» icon).
- [ ] **Audio for the release** (owner, Q1): stream the ayat from everyayah.com (or another host) with the **reciter of
      the settings** (23), cached; the word times per reciter come with the data (today: Husary only, times by hand).
- [ ] **«Tap the word where you heard the ghunna»** question type (owner, Q4: later).
- [ ] **Real listening lessons** in the data (today one mock lesson, سورة الكوثر, in the unit «النون المشددة»).
- [ ] Points (+10) are counted in the lesson only: show them at the end of the lesson (screen 24) and save them.
- [ ] The same audio question as a question type inside tests (10), idea of 2026-11-25.

## Screen 01, splash (merged into `master` 2026-11-26)
- [ ] Owner review on a physical phone, including the native launch handoff. Browser capture:
      [startup-phone.mp4](screens/01-splash/startup-phone.mp4).
- [ ] Small differences from `01-avvio.webp` seen at the merge check (Claude, 2026-11-26): the gold divider is
      wider than the reference (x ≈ 660–1180 vs 693–1150); the status reads «جارٍ» with tanween, the reference «جار».
      Owner to decide whether to align them. The critic was not run on screen 01.
