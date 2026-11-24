# Screen 07 (video lesson, درس فيديو): history of the work

Branch `flutter/07-video-lesson`, created on 2026-11-24 from `master` (1ab56a1: PR #46 of screen 11 merged with the
owner's OK). Plan: `../07-video-lesson.md`. Decisions: `../../DECISIONS.md`.

## 1. Start, references and plan (2026-11-24)
- PR #46 (`flutter/11-leaderboard`) merged into `master` (owner OK).
- Final critic of screen 06 proposed (phone 915×412, against the Angular original, the 06 ChatGPT reference and the
  approved screens): **owner: "not yet"**, so screen 07 comes first.
- References copied from `lesson-production`: `07-lezione-video.webp` (video lesson, "video not available"),
  `07-lezione-video-dark.webp` / `-light.webp`; Angular captures `angular-07-lezione-video.png`, `angular-08-lezione-lettura.png`.
- Found: the dark/light pair is **the reading lesson** (Angular 08: «آداب تلاوة القرآن الكريم», toolbar, sentence cards
  1/8), not the video lesson. No reference shows a video playing. Video lessons in the data are YouTube links
  (course 01 unit 1 lessons 1–3, course 02 intro).
- Plan v1 with 7 questions (Q1–Q7) for the owner.

## 2. Owner answers and prompts (2026-11-24)
- Q1 07 = video lesson on `07-lezione-video.webp`, dark/light pair → screen 08 (reading). Q2 ChatGPT reference for the
  playing state (V4). Q3 counter «n / 100». Q4 dark only now. Q5 arch frame from ChatGPT (V2). Q6 new corners from
  ChatGPT (V3). Q7 the end of the video completes the lesson by itself.
- Prompts V1 (icon), V2 (arch), V3 (corners), V4 (playing reference) pasted in the chat; crops in
  `../../prompts/07-video-lesson/attach/`.

## 3. Owner's assets, build v1–v4, verification (2026-11-24)
- Owner delivered V1–V4 (zip) and a second icon closer to the reference (V1 v2, used); asked to keep every asset in the
  shared library («librerie comuni»): sources `docs/design-assets/video-lesson/`, app copies `assets/ui/video/`, `ASSETS.md`
  section "Video lesson"; shared code `SkipButton`, `GoldDivider`, `ScreenGirih(fadeTop:)`.
- Found: two of the four video links in the data are dead (c9N4j8IF8mM, _nMiT7QFpIc: 404 on YouTube) → those lessons show
  the "not available" state; BqFxf-WspTc (lesson «مقدمة في علم التجويد») is a video about «الإقلاب» (episode 06), not an
  introduction. The release manifest had no INTERNET permission (added).
- Code: `lib/lessons/video_lesson_page.dart` (`VideoLessonPage`, `videoLessonRoute`), YouTube through
  `youtube_player_iframe` 6.0.4 (YouTube controls hidden; tap on the video = pause/play; drag/tap on the line = seek; the 02
  pause button and menu pause/resume/restart it; poster on top while paused, since the platform view cannot be blurred);
  `lesson_page.dart` routes `LessonType.video` to it (`completed` → «إكمال ✓»); `videoUrl` added to `Lesson` (generator).
  States: no link / error / not playing after 15 s → "not available". End of the video and «تخطي» → fill 100, 02 light,
  leave with `true` (screen 06 plays the completion, next lesson opens).
- Review aids: `?lessons=0,0&openLesson=0&video=demo|none&videoAt=0.37`. Scripts `video-capture.js`, `video-demo.js`,
  `video-verify.py`. Widget test: unit 1 completed through three video lessons with «تخطي».
- Geometry fitted on the reference (arch by correlation of the line, corners/icon/mosque on zoomed crops); verification
  v1 → v4 in `../07-video-lesson/verify-v4.md` (all boxes within ±4 px except the explained mask cases).
- Delivered: `compare-v4-phone.jpg`, `demo-v4-phone.mp4` (video ends → completion → lesson 2 → «تخطي»; "not available" →
  «تخطي»), APK 1.0.353 (first Gradle run hit a 429 from Maven Central; the re-run passed).
- Open for the owner: capsule (02) direction vs the video line; bottom lattice band (asset V5); data links.

## 4. Bottom band and full-screen video with sections (v5, 2026-11-24)
- Owner delivered V5 (bottom lattice band): cut between two crossings of the middle row into a seamless 4-cell tile
  (`tools/assets/video_lesson_assets.py` `band()`, edge alpha difference 3/255); matched on contrast-enhanced crops:
  period 89 px = 10.4u, ends at 96u, upper row fading, contrast p97 − median 31 vs reference 28.
- Owner: «while the video plays it should not be a container, it should be the whole screen, as Simply Piano's courses».
  Mockup `proposal-fullscreen-v1.jpg` (A controls visible, B auto-hidden). Answers: the **whole video** visible (bands
  at the sides), **no time line** because each video will be split into **sections** that can be repeated (also earlier
  ones), **controls always visible**. Then: section end → «أعد» / «تابع»; mock sections (3 equal parts); capsule = section
  n/N; the way back to earlier sections: «show me both» → A dots, B ‹ button (`?sectionNav=dots|button`).
- Code: `_playingLayer` rebuilt (black full screen, 16:9 at full height, top/bottom dark gradients, title centred between
  capsule and pause, dots centred on the «تخطي» line or the ‹ round button, section-end veil with two pills); shared
  `LessonPill` (glass / gold), `LessonRoundButton`, `PillGlyph` (`lib/lessons/lesson_widgets.dart`, «تخطي» is now a
  `LessonPill`). Player frame, time line and their metrics removed (conflicts V3/V4 no longer apply). Widget test: section
  end → «تابع» → 2/3 → dot 1 → 1/3.
- Captures `capture-v5-*` (unavailable with band, playing A/B, section end), sheet `compare-v5-phone.jpg`, demo
  `demo-v5-phone.mp4`, APK 1.0.354 (section 1 ends → «تابع» → 02 pause → dot of section 1 → «تخطي» → 06 completion; B variant: last
  section → «تابع» completes; not available → «تخطي»).

## 5. v6: section end on the 02 play, one back button, brighter «تخطي» (2026-11-24)
- Owner on APK 1.0.354 (with a Simply Piano screen recording): the pause menu should animate as Simply Piano (→ separate
  02 branch); no «أعد / تابع» since pause/play already exists; repeating / going back = a small button like the ‹ arrow,
  only for the video; dots not needed; «تخطي» brighter as the reference.
- Answers: section end → the 02 button waits as the pulsing gold play (tap → next section); dots removed.
- Code: `LessonShell(waiting:, onPlay:)` (gold play + pulse without menu/veil, `_wait` controller); `_endSection` finishes
  the lesson after the last section; `_back()` (restart the section, or previous section in its first 2 s);
  «أعد / تابع» overlay, dots and `?sectionNav` removed; `LessonPill`/`LessonRoundButton` glow 42% σ 2.2u + inner light
  (`_InnerGlowPainter`), measured on the reference column through the rim: outside #2E3F21 vs #2F431F.
- Web check (`t07.js`): section end 1/3 gold play → tap → 2/3 pause → ‹ → 1/3. The widget test checks the waiting play
  and 2/3 (frames stop in the test after the section change, see the comment there).
- Captures `capture-v6-*`, demo `demo-v6-phone.mp4`, APK 1.0.357.

## 6. v7: corners faded towards the inside (2026-11-24)
- Owner: the side lattices, above all the right one, should be faded, otherwise they compete with the button.
- Horizontal masks on top of the vertical fade: left corner full at the edge → 70% at 45% → 0 at 80% of its box; right
  corner → 50% at 22% → 0 at 50%. Before/after `corners-v6-v7.png`, captures `capture-v7-*`, APK 1.0.359.

## 7. v8: YouTube inside the page, native look (2026-11-24)
- Owner on APK 1.0.359 (screenshot): the video appeared above the buttons (capsule and «تخطي» cut), and after a tap the
  app's "video not available" state appeared. The lesson videos will be the app's lessons rendered as linear videos with
  sections (lesson-production `docs/production/STATO-E-DIREZIONI.md`, «Direzione B»); they go on YouTube to count views from
  the app; the app must not bundle them (weight) and the player must look native. Test video: `rateel-lezione1-v2.mp4`.
- Cause 1: `youtube_player_iframe`'s `YoutubePlayer` on mobile shows the WebView through an `OverlayPortal`, i.e. above the
  whole route, ignoring our Stack. Fix: `_InlineYoutube` puts `WebViewWidget(controller.webViewController)` in the page
  (web keeps the package's inline player); `webview_flutter` is now a direct dependency.
- Cause 2: "not available" came from the 15 s timeout when the stream did not report `playing`. Now buffering/cued/position
  > 0 count as working, timeout 20 s.
- Poster: maxres 16:9 thumbnail from the network, high-quality fallback, bundled thumbs only for offline review.
- Captures `capture-v8-*`. To verify on the phone (platform views cannot be checked in the headless browser).
