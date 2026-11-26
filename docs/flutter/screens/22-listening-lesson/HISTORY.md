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

## 4. Demo with sound, replay fix (2026-11-26)
- Owner (watching from iOS) asked for a demo video and whether the recitation moves from word to word, lit, as in the
  original: yes, the recited word lights up in a soft gold box and the light moves word by word with the audio (word times).
- Demo with the real sound: `demo-v6-phone-audio.mp4` (H.264 + AAC, 1280×576). Playwright records no audio: the page
  logs its audio events with `?logAudio=1`, `tools/flutter-review/listening-demo-audio.py` mixes the Husary segments and
  the effect sounds back at their times.
- Bug found while rebuilding the sound: after an answer the asked word sometimes did not replay alone, the verse restarted
  from the beginning (a seek before `resume()` was ignored after the end of the verse). Fixed with `play(position:)` and a
  late-start correction in the position listener.

## 5. Redefinition: rule lesson (v7, 2026-11-26)
- Owner: the listening lesson must focus on **one rule** and play **several ayat** that contain it, with the rule's words
  **coloured with the tajweed wheel colour**; what was built (listen, then answer) fits the tests better, keep it.
  Answers: words coloured from the start and every word lit while recited; «التالي» to go on; 2–3 questions at the end;
  quiz in the tests → backlog, but keep it on the branch; no new reference, the style is fine.
- Built: lesson `listen-ghunna` = سورة الناس 1–6 (Husary, word times by hand on the energy envelope) + الكوثر 1, rule words
  النّاس / الخنّاس / الجنّة / إنّا in green; bottom row rule pill + note + «التالي»; then 3 questions (إنّا غنة, الأبتر قلقلة,
  وانحر إظهار). The v5 quiz is lesson 2 «اختبار الاستماع». Capture sheet `capture-v7-rule.jpg`, demo with sound `demo-v7-rule-audio.mp4`.

## 6. Rule letter and «find» questions (v8–v9, 2026-11-26)
- Owner: colour the **letter** of the rule, not the word (a word can hold several rules); the letter glows with its own
  light when its word is recited. Built with spans inside the word (Flutter keeps the Arabic joining across colour runs:
  checked on «الجِنّة»); letters found by `rule_letters()` (doubled nun / meem with its marks).
- Owner: the end questions go the other way: the ayah plays without colours, a pill asks to **tap the word** in the verse,
  then at once **which letter** (pills with the word's letters, Amiri Quran); after the answer the right letter takes the rule
  colour and glows, a wrong one is red; the explanation line says «الغنة في حرف «نّ» من كلمة «النّاس»». Ayat chosen with a
  single rule word (114:2, 108:3, 108:1; 114:4 left out because «مِن شَرّ» has an ikhfa with ghunna too).
- The quiz → practice after several rules and daily practice (screen 31, added to `SCREENS.md`).
- Captures `capture-v9-find.jpg`, demo with sound `demo-v9-rule-audio.mp4`.

## 7. Phone test 1.0.472 and play button (v10, 2026-11-26)
- Owner (screenshots from the phone): the play button below the card eats the room: the waveform is close to the words,
  the light box does not take the whole word, the letters spill out of their circles. Variants A/B/C built behind
  `?playPos=` (sheet `play-variants-v10.jpg`); owner chose **B** (in line with the waveform).
- v10: B by default; light box padded so the whole word is inside it; letter pills centred. Sheet `capture-v10-b-phone.jpg`.
- Voice: the confirmed narration voice is Gemini TTS **08 Orus** (DECISIONS); loudness normalisation and a guided voice → BACKLOG.
