# Rateel UI/UX design lines

Two official design guidelines, made by the owner with ChatGPT.
Source: Google Drive «Tajweed → app → new» (folder `1Bc9jbJQ4EpdX3wbgPzd7NQnkfyPAVpWD`).
Files are stored as **lossless WebP** (pixel-identical to the PNG originals).

| Line | Folder | Screens | Use |
|---|---|---|---|
| **Glassy / liquid 3D gamified** | `glassy-gamified/screens/` | 22 | **First wave**: replicate one to one |
| **Flat** | `flat/screens/` | 10 | Alternative guideline for the future |

## Rules (see `docs/production/RULES-AND-LESSONS-LEARNED.md`, section 0)
- Show the owner a mockup or visual plan and get confirmation **before** implementing anything visual.
- **Never invent assets.** Every graphic element in these mockups (3D icons, arches, mosque
  silhouettes, ribbons, frames, badges…) must be supplied by the owner (ChatGPT / Google Flow) as
  separate files. Ask for them; do not redraw them in code.

## Screen index

Numbers follow the app screenshots in `docs/production/screenshots-app/`.

| # | Screen | Glassy | Flat |
|---|---|---|---|
| 03 | Courses / learning paths | ✅ | — |
| 04 | Side menu open | ✅ | — |
| 05 | Units of a course | ✅ | — |
| 06 | Lessons of a unit | ✅ | — |
| 07 | Lesson player: video unavailable state | ✅ | — |
| 07-dark / 07-light | Reading lesson card (named «video» in the file, content is «آداب تلاوة القرآن الكريم») | ✅ dark + light | — |
| 09 | Recitation practice | ✅ dark + light | ✅ dark |
| 10 / 10b | Test: question / answer selected | ✅ | ✅ |
| 11 | Leaderboard | ✅ | ✅ |
| 12 | Daily challenges | ✅ | ✅ |
| 13 | Achievements | ✅ | ✅ |
| 14 | Coming soon | ✅ | — |
| 15 | Guided lesson: start | ✅ | — |
| 16 | Guided lesson: concept | ✅ | — |
| 17 | Guided lesson: definition | ✅ | — |
| 18 | Guided lesson: quiz | ✅ | ✅ |
| 19 | Guided lesson: comparison | ✅ | ✅ |
| 20 | Guided lesson: listen to the verse | ✅ | ✅ |
| 21 | Guided lesson: summary | ✅ | ✅ |

Not designed yet in either line: 01 splash, 08 reading lesson (covered by 07-dark/light).

## Open questions for the owner
- **Light mode:** the glassy line has light variants for 07 and 09. Is light mode part of the
  first wave, or dark only?
- **Flat line:** it covers 10 screens; the missing ones are not needed now (flat is for the future).

## ChatGPT redesign of lesson 10.1 (reference, not final)
`glassy-gamified/chatgpt-lesson-10-1/`: 15 screens ChatGPT made from our lesson screenshots and the prompt
`docs/production/prompts/lesson-10-1/chatgpt-redesign.txt`. The owner likes: positions, sizes, **large type**,
**variety of colours** (gold key words, two-tone titles, coral rule letters, vivid quiz states). Too much glow:
tone it down. **The Arabic text in these images has errors** (e.g. «سورة الأنعام» for 8:43, «للغنة» for «للغنن»):
take layout and styling from them, never the text.
