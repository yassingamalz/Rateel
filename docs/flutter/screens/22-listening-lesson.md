# Screen 22: listening lesson (درس الاستماع)

Status: **lesson type confirmed by the owner** (2026-11-25): a separate lesson of type `listen`, not part of the tests.
Reference: **to generate** (prompt `prompts/22-listening-lesson/reference-v2.txt`, app screenshots; v1 with the old ChatGPT images is superseded), to be saved as
`screens/22-listening-lesson/22-lezione-ascolto.webp`, 1844x853. Plan to be shown to the owner before building.
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
| `22-listening-lesson/22-lezione-ascolto.webp` (to generate) | **the reference of this screen** once the owner generates it |

## Planned layout (from the prompt)
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
