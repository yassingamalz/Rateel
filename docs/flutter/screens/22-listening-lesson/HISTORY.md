# Screen 22, listening lesson: history

## 1. Start (2026-11-26)
- Owner confirmed the timeline of `NEXT-SESSION.md` («procedi») and asked to use also the visual examples of the
  lesson-production video (`docs/production/videos/rateel-lezione1-v2.mp4`).
- Branch `flutter/22-listening-lesson` from `master` (31732d0).
- Studied: reference `22-lezione-ascolto.webp`; video frames (verse card with reciter/surah, word lit while recited,
  «استمع» / «إعادة الاستماع» pills, wrong answer red with ✕, two-answer rows); ChatGPT lesson images `chatgpt-lesson-10-1/0{6,8,9}-ascolto-*`.
- Audio: lesson-production has 3 Husary (muallim) ayat (001001, 001007, 073004); none with the ghunna of the reference.
  everyayah.com is blocked by the container's network (403).
- Visual plan v1 + questions Q1–Q11 in `../22-listening-lesson.md`, sheet `plan-v1.jpg`.

## 2. Owner's answers (2026-11-26)
Q1 **A** (everyayah.com allowed in the environment, Husary bundled for the mock; streaming with the reciter of the
settings for the release, in the backlog) · Q2 word times by hand OK · Q3 answers side by side · Q4 «tap the word» later
(backlog) · Q5 **+10 per right answer, no pass/fail** · Q6 **feedback as the video** (right answer green ✓, wrong red ✕,
short explanation) · Q7 **Amiri Quran** · Q8 **new headphones asset** (prompt H1) · Q9 «تأكيد» glyph as Claude proposed
(✓) · Q10 **light theme too**.

## 3. Build v1–v5 (2026-11-26)
- Audio: Husary murattal 108:1–3 from everyayah.com (`assets/audio/quran/husary/`, ~370 KB). Word times measured on the
  50 ms energy envelope; waveform = 51 RMS bars per ayah (`tools/flutter-review/gen_listening_data.py`).
- Data: `assets/data/listening/listen-kawthar-ghunna.json` (5 questions: إنّا غنة, وانحر إظهار, إنّ غنة, شانئك مد,
  الأبتر قلقلة). Mock lesson `listen-kawthar-ghunna` added to the unit «النون المشددة» (`noon-mushaddad-theory`, course
  02, unit 2), which has no lessons in the data (`lesson_data.dart`, `_mockLessons`).
- Code: `lib/lessons/listening_lesson_page.dart`, `listening_data.dart`; 08 header with an `emblem` slot
  (`HeaderSpec.emblem`), 08 card / badge / lattice, 02 bar, `LessonRoundButton`, `LessonPill`; font AmiriQuran bundled
  (OFL, from `@fontsource/amiri-quran` 5.3.0, woff → ttf).
- Flow: the verse plays by itself after the entry; the waveform fills gold and the recited word lights in a soft gold box
  (video); play ↔ pause; answers side by side, selected = gold; «تأكيد» before a choice = «denied» haptic; confirm →
  right pill green ✓ / chosen wrong red ✕ with a shake, others faded, test sounds and haptics, the waveform gives way to
  the explanation (with «+10 نقطة» when right) **inside the card** (there is no room above the line without moving the
  reference layout: one line, in place of the waveform), the asked word plays again; «التالي» → next question slides in;
  last → «إنهاء» → passed sound, 02 sweep, lesson completed.
- Performance: the audio position drives only the waveform painter (`repaint:`) and the lit word (`ValueNotifier`);
  `RepaintBoundary` on background, header, card, verse; no endless animation; no blur.
- Verified element by element: `verify-v5.md` (all within 4 px except the font of the verse and the standard header);
  comparison `compare-v5.jpg`, phone states `capture-v5-states-phone.jpg` (default, right, wrong, light), demo
  `demo-v5-phone.mp4` (phone, real audio timing).
