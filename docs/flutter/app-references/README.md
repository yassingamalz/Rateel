# Screenshots of the approved app (style references for ChatGPT)

Captured from `master` (web build, 1844x853, dark unless named `-light`) on 2026-11-25; refreshed and completed on
2026-11-27 (all files recaptured; 10, 12, 22, 23 and two light screenshots added) with
`node tools/flutter-review/app-references-capture.js <outdir>` (PNG, then saved as webp q90). Attach these to every ChatGPT prompt for a new
screen so the generated reference stays in the app's style (`LESSONS-LEARNED.md`, References). Refresh after each
approved screen (same review query parameters as below).

| File | Screen | Query |
|---|---|---|
| `app-03-courses.webp` | 03 courses | – |
| `app-05-units.webp` | 05 units | `?units=0` |
| `app-06-lessons.webp` | 06 lessons | `?lessons=0,1` |
| `app-08-reading-dark.webp` | 08 reading lesson with the 02 top bar | `?lessons=0,1&openLesson=0` |
| `app-08-reading-rules.webp` | 08 rules panel | `?lessons=0,1&openLesson=0&rules=1` |
| `app-11-leaderboard.webp` | 11 leaderboard | `?section=3` |
| `app-14-coming-soon.webp` | 14 coming soon | `?section=1` |
| `app-08-reading-light.webp` | 08 reading lesson, light theme | `?lessons=0,1&openLesson=0&readTheme=light` |
| `app-10-test-question.webp` | 10 test lesson, an option selected | `?lessons=0,4&openLesson=0&testQ=3&testPick=1` |
| `app-10-test-results.webp` | 10 results in the card (screen 25) | `?lessons=0,4&openLesson=0&testState=results` |
| `app-10-test-results-light.webp` | 10 results, light theme | `…&testState=results&readTheme=light` |
| `app-12-daily-challenges.webp` | 12 daily challenges | `?challenges=1&chalDone=3&streak=4` |
| `app-22-listening-rule.webp` | 22 rule lesson, a word lit | `?lessons=1,1&openLesson=0&listenAt=0.6` |
| `app-22-listening-question.webp` | 22 quiz, right answer feedback | `?lessons=1,1&openLesson=1&listenState=ok` |
| `app-23-settings.webp` | 23 settings | `?section=6` |
