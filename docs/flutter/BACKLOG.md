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
- [ ] Settings screen (light/dark toggle, text size) and how it is opened.
- [ ] Screen 01: still to define.
