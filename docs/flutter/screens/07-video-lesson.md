# Screen 07: video lesson (درس فيديو), plan

> **Update v5 (owner, 2026-11-24):** while the video plays it fills the screen (whole 16:9 video at full height, dark
> bands at the sides), controls always visible, **no time line**; the video is split into **sections** (end of a section:
> «أعد» / «تابع»; earlier sections can be watched again: dots or ‹ button, owner to choose); the capsule counts sections.
> Sections are mock (3 equal parts) until the data has `sections: [{start, end}]` (seconds) per video lesson. The playing
> reference V4 (`reference-playing.webp`, framed player) is superseded; the "not available" state stays 1:1 with
> `07-lezione-video.webp`. Sections §3–§5 below describe v1–v4.

Branch `flutter/07-video-lesson`, from `master` (1ab56a1, screens 02–06 and 11 merged). History: `07-video-lesson/HISTORY.md`.
Status: **plan v1 answered** (owner, 2026-11-24): see DECISIONS.md and HISTORY.md §2.

## 1. References and what they really show
Copied from `lesson-production` (`docs/design/glassy-gamified/screens/`, 1842×854, u = 8.54 px) into `07-video-lesson/`:

| File | What it shows | Angular original |
|---|---|---|
| `07-lezione-video.webp` | **video lesson, "video not available" state**: 02 top bar (capsule «0 / 100», pause), large lobed gold arch frame, mosque, clapperboard icon with a gold «!» badge, title «الفيديو غير متاح», divider with a diamond, sentence «عذرًا، هذا الفيديو غير متاح حاليًا.», gold «تخطي ⏩» button bottom right, faint girih background, lattice corners bottom left / right | `angular-07-lezione-video.png` (YouTube «Video unavailable» offline) |
| `07-lezione-video-dark.webp`, `-light.webp` | **not a video lesson**: the **reading lesson** (Angular 08: title «آداب تلاوة القرآن الكريم», toolbar قواعد التجويد / moon / A / ‹ 8/1 ›, sentence card 1 of 8, dots, تخطي) in dark and light | `angular-08-lezione-lettura.png` |

So only `07-lezione-video.webp` is the video lesson; the dark/light pair is the redesign of screen 08 (reading). → question Q1.
No reference shows the **video playing** (the only Angular capture is offline). → question Q2.

## 2. Data and behaviour (Angular `video-player`, `lesson-details`)
- Video lessons in the data: course 01 unit 1 lessons 1–3 (`intro-tajweed.json`: BqFxf-WspTc, c9N4j8IF8mM, _nMiT7QFpIc, 5–7 min),
  course 02 intro (XfDdA9UgOVQ). All **YouTube** links.
- Angular: YouTube iframe (or `<video>` for a file); progress of the top bar = video time %; at the end of the video:
  progress 100, success haptic, completion after 1.5 s; «تخطي» (skip) completes the lesson at once; on a lesson already
  completed the button reads «إكمال» with ✓; no URL → «عذراً، لا يمكن تحميل الفيديو».
- Flutter: the lesson replaces the placeholder `lesson_page.dart` for `LessonType.video` and keeps its contract
  (returns `true` when finished → screen 06 plays the lesson completion). Top bar = **approved screen 02** (`LessonShell`):
  capsule 46×7u, glass buttons 15.5u, pause menu (back / restart), veil.

## 3. Layout on `07-lezione-video.webp` (u = 8.54 px; first reading, measured again element by element in the build)
| Element | Box (px) | In u | Notes |
|---|---|---|---|
| Capsule «0 / 100» | 48–474 × 35–93 | 49.9 × 6.8 | = approved 02 capsule (46×7u), kept as 02 |
| Pause button | 1665–1802 × 22–158 | 16.0 | = approved 02 button (15.5u), kept as 02 |
| Arch frame (gold line) | 300–1545 × 42–420 | 146 × 44 | lobed ogee, thin gold line (~3 px) fading at its bottom ends, darker fill inside |
| Mosque | 520–800 × 220–410 | 33 × 22 | screen 03/05 mosque asset, green tint, fading at the base |
| Clapper icon + «!» | 810–1052 × 203–385 | 28 × 21 | gold outline clapperboard, cream play triangle, gold disc with dark «!» |
| Title «الفيديو غير متاح» | 688–1156 × 415–480 | 55 × 7.6 | cream, bold, centred at x 921 |
| Divider | 560–1285 × 515–540 | 85 × 3 | gold line + open diamond (as screen 06 divider, drawn in code) |
| Sentence | 664–1180 × 578–612 | 60 × 4 | cream 85%, regular |
| «تخطي» button | 1493–1780 × 650–758 | 33.6 × 12.6 | dark glass pill, gold rim 2–3 px with glow, text + ⏩ glyph cream |
| Corners | bottom left 0–200 × 620–854; bottom right 1650–1842 × 640–854 | | gold lattice (screen 05 corners or a new pair) |
| Background | girih lines ~6%, base #052A20 → #021E17 | | screen 05 girih tile |

## 4. Motion / UX (proposal)
- Entry: lesson slides in (02 route); frame and arch draw/fade in 400 ms, icon pops, texts fade up (stagger 60 ms).
- Playing: the capsule fills with the video progress (02 fill, smooth), the counter shows **elapsed % «n / 100»**
  as the reference and Angular (02 shows steps «n/N» for step lessons; a video has no steps). → Q3.
- Pause button of 02 also **pauses the video**; resume resumes it; restart → video at 0.
- End of the video: fill to 100%, 02 light sweep + haptic `milestone`, lesson leaves with `true` (screen 06 plays the completion).
- «تخطي»: press feedback, haptic, completes the lesson as Angular (fill jumps to 100, light, leave).
- Already completed lesson: button «إكمال ✓».
- No network / embed error / no URL: the reference's unavailable state, with «تخطي».

## 5. Code vs assets
| Element | How |
|---|---|
| Top bar | reused, `LessonShell` (02) |
| Video | package `youtube_player_iframe` (YouTube embed, Android WebView + web), no YouTube controls overlay of our own beyond play/pause → Q2 |
| Arch frame | asset from ChatGPT (V2) or drawn in code → Q5 |
| Mosque, girih tile, divider, corners | reused (`mosque.webp`, `girih_tile.svg`, divider of 06, corners of 05) → Q6 |
| Clapperboard + «!» icon | **new asset, ChatGPT (V1)** |
| Skip glyph ⏩, check | drawn in code (as the 02 glyphs) |
| Video playing frame | new ChatGPT reference (V3) if Q2 = ChatGPT reference |

## 6. Questions for the owner
1. **Q1** The dark/light pair is the reading lesson (08). Proposal: 07 = video lesson built 1:1 on `07-lezione-video.webp`;
   the dark/light pair becomes the reference of **08 (reading)**, the next screen.
2. **Q2** Video playing: no reference. Proposal: ChatGPT reference V3 (same frame, 16:9 player with gold glass rim inside
   the arch, «تخطي» below right), then build 1:1 on it.
3. **Q3** Counter in the capsule during the video: «n / 100» (% as reference/Angular) or elapsed time «1:23 / 6:00».
4. **Q4** Light theme: the video reference exists only in dark. Build dark now, light when the app's light mode is enabled
   (as decided 2026-11-20)?
5. **Q5** Arch frame: ChatGPT asset (V2) or drawn in code (thin gold line, like the 06 divider).
6. **Q6** Corners: reuse the screen 05 lattice corners (bottom left / bottom right, mirrored) or new pair from ChatGPT.
7. **Q7** Video end: complete automatically (Angular) or show «إكمال ✓» and wait for the tap.
