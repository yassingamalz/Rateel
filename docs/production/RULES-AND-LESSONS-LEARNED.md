# Rateel lesson production: rules and lessons learned

This is the canonical rulebook for producing Rateel lessons. Every session must read it before
working and follow it. It contains the owner's explicit rules (section 0) and everything learned
while producing lesson 1 («مُقَدِّمَةٌ فِي عِلْمِ التَّجْوِيدِ»).

---

## 0. Owner's rules (non-negotiable)

1. **Track every lesson with a ✅.** `docs/production/LESSONS-TRACKER.md` is the single list of
   lessons to produce. Update it in the same commit as the work: ⬜ to do → 🟡 in progress or
   prototype → ✅ done (approved by the owner). Only the owner approves a ✅.
2. **The source of truth for content is the Google Drive folder «Tajweed → التجويد المصور»**
   (22 PDF chapters, links in the tracker). Every lesson is based on its chapter. Do not invent
   rulings or content that is not in the source.
3. **Voice: free voice first, Google later.**
   - Produce lessons with a **free voice** until the owner confirms the graphic style.
   - Switch to the **Google (Gemini TTS) voice** only after the graphic style is confirmed.
   - For now the Google voice is **male only**. The owner chooses which sample (from
     `voices/samples/`); never pick it yourself.
   - Female and children's voices come later.
4. **Hard animations or graphic elements are not built by hand in code.** When an
   animation, illustration or graphic element is hard to make well, write prompts and the owner
   generates it with **ChatGPT or Google Flow** (via ZAPI FLOW). Code is for layout, timing and
   simple motion, not for drawing complex art.
5. **Professional direction is the priority for the app.** Every screen must look like a premium,
   consistent product (one design system, one style), never a prototype.
6. **Two separate directions** (see `STATO-E-DIREZIONI.md`):
   - **A, the app:** all interactivity (buttons, quizzes, next/back, feedback, stars, recording)
     is built **once**, as shared components, and is evaluated for a move to **native Android**.
   - **B, the videos:** videos are **pure linear videos** (animation + voice + recitation) with
     **sections/chapters**. No fake taps or buttons inside a video. In the app the player
     pauses at section ends and the app shows the interaction; on YouTube the sections become
     chapters.
7. **Two official UI/UX design lines, both kept on GitHub** (`docs/design/`):
   - **Glassy / liquid 3D gamified**: the style of the **first wave**. Replicate it **one to
     one**, exactly as designed with ChatGPT.
   - **Flat**: kept as the second, alternative guideline for the future.
   Design sources are in Google Drive «Tajweed → app → new».
8. **Ask before any visual decision.** Before implementing anything visual (screens, components,
   styles, animations), **show the owner a mockup or explain the visual plan and get explicit
   confirmation**. No visual work starts without a "yes".
9. **Never invent assets or graphic elements.** Claude cannot create real assets/illustrations.
   If an element is missing, **ask the owner** for it (to be produced with ChatGPT / Google Flow)
   and provide the prompts. Do not substitute with self-made drawings, CSS art or placeholders
   presented as final.
10. **Style per direction (owner's decision):**
    - **App (direction A):** glassy gamified, **dark AND light** mode (light already existed in the app).
    - **Lessons (direction B):** glassy gamified, **dark only** for now.
11. **First wave starts with chapter 10.1 «النُّونُ وَالْمِيمُ الْمُشَدَّدَتَانِ»** (see the tracker).
12. **Animation principles:** **morphing** transitions (elements transform into each other instead
    of cutting); a style that is **light on the eye** (calm, few things moving at once, no
    flashing); and **clear explanations** (one idea per scene, the visual always matches the words).
13. **ChatGPT can generate GIFs.** When an element must move (e.g. airflow through the nose,
    lips closing), ask the owner for a GIF and give the exact prompt
    (`docs/production/prompts/<lesson>/gifs.txt`). Still images go to ZAPI FLOW
    (`images.txt`, one prompt per line).
14. **Branches: one branch per lesson.**
    - `lesson-production` is the **base branch**: rules, tracker, design lines, shared assets,
      scripts and the lesson engine.
    - **Every lesson is produced on its own branch**, created from `lesson-production` and named
      `lesson/<tracker-number>-<slug>` (e.g. `lesson/10-1-noon-meem-mushaddad`). All work for that
      lesson (script, audio, elements, video, content JSON) is committed and pushed there.
    - Write the branch name in the tracker row of the lesson.
    - When the owner approves the lesson (✅), merge it back into `lesson-production`.
    - Shared changes (rules, engine fixes, tracker structure) go to `lesson-production` directly,
      then the lesson branch is updated from it.
15. **Communicate with the owner in Italian.** Write documentation and rules in English.

---

## 1. Content and Arabic text

1. **Full tashkīl everywhere**: titles, quiz options, explanations, summaries **and the
   narration text**. Fully vocalised text keeps the voice from mispronouncing anything (draft
   for lesson 1: `intro-lesson-1.tashkeel-bozza.json`).
2. **Quran verses are never read by a synthetic voice.** A real reciter always recites them
   (al-Ḥuṣarī, Muʿallim). The narration introduces a verse but never reads it.
3. Quran text uses the **Uthmani script** (source: the quran.com API) and the **Amiri Quran**
   font.
4. Avoid proper names with uncertain iʿrāb in narration (say «الشيخ الحصري», not the full name).
5. **No music.** Use only short, discreet UI sounds (tap, correct, wrong), out of respect for the
   Quranic context.
6. **Fiqh content:** state only agreed positions (e.g. learning tajwīd theory = farḍ kifāya,
   applying it = wājib). Avoid disputed questions.
7. Text currently addresses a male learner (أنتَ). Female and children's variants come later.

## 2. Voice (TTS)

1. **Never put style instructions in the text to be spoken** («Say in a warm voice…»). Gemini
   TTS sometimes reads them aloud, especially in short lines. Send only the Arabic text.
2. **Verify every audio file by transcription** (local Whisper:
   `scripts/video/check-audio-whisper.py`). If the verifier fails (e.g. HTTP 503), the file is
   **NOT verified**; never treat it as good.
3. **Quick sanity check:** normal pace is about 0.16–0.20 s per letter. A much longer file almost
   always contains extra speech.
4. The daily TTS quota is limited. The script stops immediately instead of waiting for hours, and
   regenerates only changed lines (it keeps a manifest).
5. **Google voice candidates (male, shaykh-like):** 02 Algenib (deepest), 01 Charon (current),
   03 Gacrux (mature). Female for later: 09 Sulafat, 10 Vindemiatrix. Google has no real child
   voice (the most youthful are 13 Leda and 14 Zephyr), so children need another service.
   Audition: `voices/rateel-provino-voci.mp3`; names: `voices/elenco-voci.txt`.
6. **Free voice for now:** Microsoft Edge neural voices via `edge-tts` (no key). Verified samples:
   `voices/free-samples/` (F1 ar-SA-HamedNeural, F2 ar-JO-TaimNeural, F3 ar-QA-MoazNeural).
7. Plan **voice profiles** from the start (shaykh / woman / child) with separate audio folders.

## 3. Synchronisation

1. **Voice and subtitles are synchronised word by word.** Subtitles show exactly the spoken
   words (never a summary) and highlight them in real time, using word timings (Whisper
   alignment).
2. **Quran recitation timing** comes from quran.com
   (`/api/v4/recitations/12/by_ayah/<key>?fields=segments`) and is accurate to the millisecond.
3. **Every element appears when the voice names it** (the definition appears on «إخراج», the
   «حقّه» card on «وحقّ»…), never at guessed percentages of time.
4. **al-Ḥuṣarī Muʿallim files end with several seconds of silence** (room for the learner to
   repeat). Always set `verse.clip` to the end of the last segment (+~300 ms), or the lesson waits in silence.
5. **Long verses: play only the fragment that carries the rule.** Cut it from the ayah file at the
   quran.com segment boundaries (with a short fade) and store it as `<sss><aaa>-p.mp3`; shift the segments.
   Check the cut with Whisper: a cut 100 ms early leaves a syllable of the previous word.
6. **Free voice word timings:** `scripts/generate-free-audio.py` stores `<stepId>.words.json` from the
   TTS word boundaries. Captions then highlight word by word, and `step.reveal` makes each element appear
   on the exact word that names it (rules 3.1 and 3.3). Keep `caption` empty so the caption is the narration.

## 4. Animation and interactivity

1. **Never show an element before its moment.** A bug we hit: the previous step's narration
   progress stayed at 100%, so for half a second everything appeared and then disappeared.
   Reset the state on every step entry.
2. Elements not yet revealed are **fully invisible** (not semi-transparent).
3. **Every animation must have a teaching purpose**: appear when it is mentioned, highlight the
   recited word, confirm an answer. No decorative motion that distracts.
4. **Immediate quiz feedback:** green + «أحسنت» when right; shake + «حاول مرة أخرى» +
   explanation when wrong. Stars count only first-try correct answers.
5. **Recording one's own voice never blocks progress.** It is encouraged (the mic pulses), but
   the learner can always continue.
6. **Engine step types for chapter 10 (glassy):** `definition` (sentence + illustration), `split`
   (a mushaddad letter morphs into sākin + mutaḥarrik), `levels` (ranked bars; `speeds` rescale all bars
   together to show that the proportion is kept). `verse.marks` colours the rule letter inside a Quran
   word (like the red letters of the book) and makes it glow while the reciter is on that word.
7. **Provisional images** are allowed only while the owner produces the final asset, and are tagged
   «مؤقّت» on screen (`media.placeholder`), so they are never mistaken for final art.

## 5. Videos (YouTube)

1. YouTube has no taps, so interactivity there must be passive: question → «توقّف وفكّر»
   countdown (5 s) → highlighted, explained answer; «ردّد معنا» pause the length of the verse;
   chapters per section; cards and end screen pointing to the app. (Whether to include these
   is still to be decided; see direction B.)
2. **Recording:** do not use Playwright's built-in recorder with a video size larger than the
   page. It leaves the lesson in a corner and the rest of the frame empty. Capture frames from
   the browser at 2× and assemble them at 30 fps (`scripts/video/record2.js`), then add the
   audio (`scripts/video/mix.py`).
3. Start recording **only once the lesson is on screen** (no blank frames).
4. UI sounds are synthesised on the device and are not in the recording. If YouTube needs them,
   add them as files.
5. Output: 1688×780, 30 fps, H.264 + AAC, `faststart`.
6. **Video critic, every time (owner's rule).** Before sending any video to the owner, run
   `scripts/video/critic-frames.py <video> <media.json> <out> <lessonId>` (8 frames per step: transition in,
   25/50/75 %, end) and have an independent critic agent compare the sheets with the design screens 15–21 and
   this rulebook: alignment, overflow/clipping of Arabic, transitions (jumps, overlaps, flashes, dead frames),
   reveal timing, consistency. Fix blockers and important points, re-render, then deliver. The owner should
   not be the one spotting problems.
7. **Scene transitions:** a calm cross-fade (old scene dissolves, new one settles in place), never two scenes
   sliding over each other. Consecutive scenes that share elements (splash → intro, levels → tanbīh) keep those
   elements in exactly the same place, so only what changes moves.
8. **End of lesson: a spoken recap of at most 10 seconds** («تَعَلَّمْتَ أَوَّلًا… ثَانِيًا… ثَالِثًا…»), each point
   appearing on its number. No long goodbye. The free-voice generator trims trailing silence.
9. **Never leave the stage empty while the voice talks:** the scene's main visual is visible from the first word.

## 6. Graphics and assets

1. **Do not crop icons out of a generated sheet.** Each one is ~60 px, with the background baked
   in, and blurry on 2× screens. Request single high-resolution files.
2. Generators (Nano Banana / Google Flow, ChatGPT) do not output real transparency. Ask for a
   **flat magenta #FF00FF background** and key it out with `scripts/assets/key-magenta.py`
   (per-pixel un-mixing, not a threshold cut).
3. **Magenta pollutes glows and gradients** (they turn pink). Generate lights, halos, sparkles
   and rays **on black** and use them with `mix-blend-mode: screen`.
4. Generated magenta is not perfectly flat, so keying needs a distance-to-key threshold;
   otherwise a noisy rectangle remains around the image.
5. Ask for subjects **large in the frame, one per image**. Character parts drawn together were
   too small to animate.
6. Illustrations meant to be animated (e.g. the head with articulation points) must have **no
   frame and no background shape**.
7. **The mascot (a fanous/lantern) never has a face**: no eyes, no mouth. State this explicitly
   in every prompt that involves it. Flow added a face twice and both images were rejected.
8. Always attach the same references: REF-A icon library, REF-B arch background, REF-C lesson
   screenshot, REF-D mascot. Generate the mascot sheet first, then the poses.
9. **Palette** (sampled from the mock-up): green #043226 / #02271E, gold #F7BC15 (light
   #FFD95A, shadow #B5850A), cream #F6EBCB, inactive segments #2B473D.
10. In the app, assets are **WebP** (19 MB of PNG became 4.3 MB). Catalogue:
    `ASSET-CATALOGO.md`. The asset set is complete as of batch 3.
11. Two lesson themes exist: `ornate` (v2, default) and `glow` (v1), chosen with `"theme"` in the
    lesson file.

### ZAPI FLOW (Google Flow) prompt files

1. One prompt per line, a blank line between prompts, no titles or numbers
   (`prompt-sequenziali*.txt`). Load with «UPLOAD .TXT FILE».
2. Write the aspect ratio inside the prompt (e.g. «Aspect ratio 16:9.»).
3. Upload the references as Flow project assets named exactly REF-A…REF-D. With «Character
   Consistency» on, ZAPI FLOW attaches the assets whose names appear in the prompt.
4. Generate the mascot sheet first, save it as REF-D, then run the poses.
5. Keep «Include serial number in filename» on, so each file maps to its prompt line.
6. We do not use Zapier.

## 7. Process

1. Test every lesson **end to end in the real app** (landscape phone) before delivering it,
   including microphone, stars and unlocking of the next lesson.
2. After any text change: regenerate audio → verify → re-align timings → re-render the video.
3. Order of work: visual style and voice first. Full tashkīl, word-level sync and the YouTube
   mode come next.
4. Keep the owner informed with short updates; deliver videos and screenshots as files.

---

## Files in `docs/production/`

- `STATO-E-DIREZIONI.md`: current status and the two directions (app / video). Read first.
- `LESSONS-TRACKER.md`: the lesson list, with ✅ status and Drive links.
- `NEXT-SESSION.md`: the command to start the next session.
- `ASSET-CATALOGO.md`: status of every graphic asset.
- `prompt-sequenziali.txt`, `-2.txt`, `-3.txt`: ZAPI FLOW prompt batches.
- `rateel-prompt-nano-banana.txt`: manual prompt guide by section.
- `reference/`: Flow reference images (icon library, lesson mock-up).
- `voices/`: audition, individual samples (01–15) and voice list.
- `videos/`: renders of lesson 1 (v1 glow, v2 ornate).
- `screenshots-app/`: current app screens for the redesign.
- `intro-lesson-1.tashkeel-bozza.json`: fully vocalised draft of lesson 1.
- Scripts: `scripts/generate-guided-audio.mjs`, `scripts/video/`, `scripts/assets/`.
