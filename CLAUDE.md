# Rateel: instructions for Claude sessions

Rateel (رَتِّل) is a Tajweed learning app (Angular 19 + Capacitor 6, Arabic RTL, landscape).
Current focus: **producing the lessons** of the book «التجويد المصور».

## Read first, every session
1. `docs/production/RULES-AND-LESSONS-LEARNED.md`: owner's rules + everything learned. Mandatory.
2. `docs/production/LESSONS-TRACKER.md`: the lesson list with ✅ status and source PDFs.
3. `docs/production/STATO-E-DIREZIONI.md`: current status, waiting items, the two directions
   (A = app with interactivity built once, possibly native Android; B = linear videos with sections).

## Key rules (summary; the rulebook wins on conflicts)
- Work on the branch **`lesson-production`**. Commit and push all production material there.
- Mark each lesson in `LESSONS-TRACKER.md`: ⬜ → 🟡 → ✅. **Only the owner approves ✅.**
- Content source: Google Drive «Tajweed → التجويد المصور» (22 PDFs, public links in the tracker).
  Never invent content.
- Voice: a **free voice** until the owner confirms the graphic style; then the **Google male
  voice** chosen by the owner from `docs/production/voices/samples/`. Never choose it yourself.
- Hard animations or illustrations: **do not hand-code them**. Write prompts for ChatGPT /
  Google Flow (ZAPI FLOW format: one prompt per line, blank line between).
- **Design lines:** `docs/design/glassy-gamified/` (first wave, replicate 1:1) and
  `docs/design/flat/` (alternative, future). Keep both.
- **Ask first:** show a mockup / visual plan and get the owner's confirmation before any visual work.
- **Never invent assets:** ask the owner for missing elements (made with ChatGPT / Google Flow).
- Professional, consistent design is the priority. The mascot lantern never has a face.
- Full tashkīl in all Arabic text, including narration. Quran verses are recited only by a real
  reciter (al-Ḥuṣarī), never by TTS. No music.
- Talk to the owner in **Italian**; write docs in English.

## Useful paths
- Guided lesson engine: `src/app/features/lessons/guided-lesson/`
- Lesson content: `src/assets/data/content/guided/<lessonId>.json`
- Graphic assets (WebP): `src/assets/images/guided/` (catalogue: `docs/production/ASSET-CATALOGO.md`)
- Audio generation: `scripts/generate-guided-audio.mjs`; video: `scripts/video/`; asset keying: `scripts/assets/`
