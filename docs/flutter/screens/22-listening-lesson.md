# Screen 22: listening lesson (درس الاستماع)

Status: **lesson type confirmed by the owner** (2026-11-25): a separate lesson of type `listen`, not part of the tests.
Reference: **`screens/22-listening-lesson/22-lezione-ascolto.webp`** (owner, 2026-11-25, generated with
`prompts/22-listening-lesson/reference-v2.txt` from the app screenshots; v1 with the old ChatGPT images is superseded). Plan to be shown to the owner before building.
Build order: after 10/10b (test and answer feedback), reusing their widgets.

## Idea (owner)
The student listens to an audio (a verse, a word), then answers questions on what was heard, Simply Piano style:
«what was in the word X? a ghunna?», «this one: a ghunna?». The same audio question can later also be one question
type inside tests (10).

## References used (visual only, `LESSONS-LEARNED.md`)
v2 (current): app screenshots `docs/flutter/app-references/app-08-reading-dark.webp`, `app-14-coming-soon.webp`, `app-11-leaderboard.webp`.
v1 (superseded, layout idea only):
| File | Used for |
|---|---|
| `22-listening-lesson/20-lezione-guidata-ascolto-versetto.webp` (lesson-production, screen 20) | verse card with reciter and surah, highlighted word, «إعادة الاستماع» replay pill |
| `22-listening-lesson/10b-lezione-test-risposta.webp` (screen 10b) | question line with star number badge, «+10 نقطة» pill, answer rows with radio, «تأكيد الإجابة» button |
| `22-listening-lesson/08-reference-dark.webp` (screen 08, approved) | app style and the shared top bar of 02 |
| `22-listening-lesson/22-lezione-ascolto.webp` | **the reference of this screen** (owner, 2026-11-25) |

## Layout of the reference
- 02 top bar: pause top right, capsule «4/10» top left; arched header of 08 with mosque, crescent, gold headphones
  and the title «الاستماع: الغنة».
- Glass card (as the 08 sentence card): badge «1» right, «سورة الكوثر · الحصري» left, verse with the asked word in
  gold, waveform (played part gold, rest dim green).
- Round gold-rimmed play/replay button under the card.
- Bottom row: question on the right, three answer pills (selected = gold fill, dark text), «تأكيد» left in the style
  of «تخطي».

## Planned layout (from the prompt, superseded by the reference above)
- Top: shared lesson bar of screen 02 (pause, progress capsule «n / 10»).
- Chip «استمع ثم أجب»; verse card (surah, reciter, verse with the asked word in gold, waveform).
- Large gold play (listen again) + «إعادة الاستماع».
- Question with number badge and points pill; 2–3 answer pills in a row; «تأكيد الإجابة».
- After confirming: feedback as 10b (correct / wrong), the word plays again, next question.

## Flow (proposed, to confirm)
1. The audio plays by itself at start; the asked word lights up in gold while it is heard.
2. The question appears when the audio ends; the student can replay as often as wanted.
3. Confirm → feedback (reuses 10b) → next question; the 02 capsule advances per question.
4. Last question → lesson completed.

## Data (proposed)
`listen` lesson: `audio` (url), `surah`, `reciter`, `text`, `questions: [{word, wordStart, wordEnd (ms), prompt,
options[], correct}]`. No real data yet: mock with one verse.

## Open questions for the owner
- Answers side by side (prompt) or stacked as in 10b?
- Can the question also be «tap the word where you heard a ghunna» (tap on the verse) besides multiple choice?
- Points per question as in tests (+10) or no points in listening lessons?

---

## Visual plan v1 (2026-11-26, Claude; waiting for the owner's yes)
Sheet: `22-listening-lesson/plan-v1.jpg` (reference with numbered elements + frames of the lesson-production video
`docs/production/videos/rateel-lezione1-v2.mp4`, which the owner asked to use as a visual example too).
Branch `flutter/22-listening-lesson` from `master`. Geometry in u (1% of the height) measured on the reference at 1844×853.

| # | Element | Built with |
|---|---|---|
| 1 | Pause button top right | 02 `LessonShell` / `LessonTopBar` (unchanged) |
| 2 | Capsule «n/N», top left | 02 capsule, N = questions of the lesson |
| 3 | Gold headphones at the arch apex | **new asset H1** (outline gold headphones, as the reference) in the `HeaderSpec` book slot |
| 4 | Arch, mosque, crescent + star, title «الاستماع: الغنة», divider with diamond | `LessonHeader` + `HeaderSpec` (arch R4 of 08/10; mosque and crescent in the standard place, rule of 12 v2); title cream as 08 |
| 5 | Badge «1» (question number) | 08 `LessonBadge` |
| 6 | «سورة الكوثر · الحصري» | lesson text style of 08; reciter name from the settings (23) |
| 7 | Verse, asked word in gold | verse font (Q7); the word currently recited lights up (video A), the asked word stays gold |
| 8 | Waveform, played part gold, rest dim green | code (`CustomPainter`, peaks precomputed from the audio, `repaint:` = player position only) |
| 9 | Round gold-rimmed play / replay | `LessonRoundButton` |
| 10 | Question on the right | 10 question style, single line |
| 11 | Answer pills side by side, selected = gold fill | 10 option logic, pill look of the reference (Q3) |
| 12 | «تأكيد» bottom left | `SkipButton` look (glyph Q9) |
Card: gold-rimmed glass card of 08 (`GoldCardPainter`) with the faint lattice band at its bottom; thin line above the bottom row.

### Flow (proposed)
1. The page enters as 08/10; the audio of the verse starts by itself; the waveform fills gold with the position and each
   word lights up while it is recited (video A, karaoke). Play ↔ pause on button 9; replay as often as wanted.
2. The question and the answers are visible from the start; «تأكيد» is enabled once an answer is chosen (before: «denied»
   haptic, as 10).
3. Confirm → feedback (Q6), sound + haptic of 10, the asked word plays again; «تأكيد» becomes «التالي».
4. Next question: card and row slide as 08; capsule +1. Last question → lesson completed (02 sweep), as the other
   lessons, until screen 24 (end of lesson) exists.

### Mock data (until real data)
One `listen` lesson on **سورة الكوثر** (3 ayat), 4 questions: «إنّا» → غنة (108:1); «إنّ» → غنة (108:3); «الأبتر» →
قلقلة (108:3); «شانئك» → مد (108:3). Audio of الحصري (source: Q1); word times measured by hand on the audio.
Data shape: `{surah, ayah, audio, words: [{text, startMs, endMs}], question: {wordIndex, prompt, options[], correct}}`.

### Performance (PERFORMANCE.md)
The player position drives only the waveform painter and the lit word (`ValueListenable` + small builders);
`RepaintBoundary` around background + header, card, bottom row; no endless animation; no blur.
Text at 110% (`?textScale=1.1`) checked on the bottom row and the verse.

### Open questions v1 (for the owner)
Q1 audio source (everyayah.com is blocked in the container) · Q2 word times by hand for the mock · Q3 answers side by side ·
Q4 «tap the word» questions now or later · Q5 points · Q6 feedback style · Q7 verse font · Q8 headphones asset ·
Q9 glyph of «تأكيد» · Q10 light theme · Q11 assets list.
