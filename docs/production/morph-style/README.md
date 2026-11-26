# Continuous-morph lesson style (proposal 🟡, 2026-11-26)

The owner's feedback on the lesson 10.1 production: "not ugly, but it does not have the Simply Piano
feeling". The lesson must feel like **one continuous shot from the first second to the last**, where
each element turns into the next one (no cuts, no card swaps). Lesson 10.1 v3 is a sequence of
glassy UI cards; this style replaces it for direction B (videos).

This file lives on the session branch `ccr-f5f98ffb-8ih3f7` for now; with the owner's OK it moves to
`lesson-production` (style rules) and `lesson/10-1-noon-meem-mushaddad` (storyboard + prompts).

## Owner's references (`references/`)
| File | What it shows |
|---|---|
| `ref-a-metabrite-storyboard.jpg` | Monochrome blue + one yellow accent. A shape becomes the next shape (gem → dot → hexagon → cube → cards → phone → glass → city). |
| `ref-b-mountain-storyboard.jpg` | Dark violet + peach + one mint accent; the mint circle comes back in every scene and ties the story together. |
| `ref-c-video-night-story-frames.jpg` | (video 1, 45 s) Close-up → pull-out, thought bubble becomes the next scene, camera flies down a road into a door. |
| `ref-d-video-pet-shop-frames.jpg` | (video 2, 16 s, portrait) Laptop screen opens up into a floating world of products, which falls into a box. |

## What makes them feel continuous (rules for our lessons)
1. **One recurring hero element** goes through the whole lesson. For us: a **gold ribbon of sound
   (the ghunna)**, accent `#43B76E` only where the ghunna is.
2. **The last frame of a scene is the first frame of the next**: an object grows until it becomes
   the next environment (window → arch frame), or splits / merges / folds into the next object.
3. **Only camera moves and match-cuts**: push-in, pull-out, pan, rotate. Never a hard cut.
4. **Limited palette**, flat shapes, soft gradients, light film grain, no outlines.
5. **Calm**: one idea per scene, 1–3 things moving at once, a lot of empty space (rule 12 of the
   production rules).
6. **No text in the generated images.** Arabic letters, verses and titles are overlaid in code
   (Amiri Quran / Readex Pro), so they are always correct; the images leave empty space for them.
7. Same world for the whole lesson: night green sky, gold light, mosque at start and end (bookend).

## Palette (from `docs/flutter/DESIGN-SYSTEM.md`)
| Role | Hex |
|---|---|
| Background night | `#00271D` |
| Background deep | `#053627` |
| Glass green (mid tones, shapes) | `#245843` |
| Gold | `#E2A51E` |
| Light gold (glows, highlights) | `#FFD95A` |
| Cream (stars, light details) | `#FFFDF5` |
| Ghunna accent (tajweed green, rare) | `#43B76E` |

## Production pipeline
1. **ChatGPT**: one keyframe image per scene (K1…K9), 16:9, always attaching the previous keyframe
   so the world stays the same.
2. **Google Flow, "Frames to Video"**: start frame = K(n), end frame = K(n+1), the transition prompt
   below. Every clip ends exactly where the next one starts → one continuous film.
3. **Code / editor**: Arabic text overlays, voice, reciter audio, section pauses for the app
   (quizzes and listening stay app interactions, direction A).

Test first: K1, K2, K3 + transition T1 (K1→K2). If the owner likes the feeling, the rest follows.

## Storyboard, lesson 10.1 «النُّونُ وَالْمِيمُ الْمُشَدَّدَتَانِ»
| Key | Script step | Picture | Becomes (transition) |
|---|---|---|---|
| K1 | s01 intro | Night sky, gold crescent, mosque skyline; the central arched window glows. Title space top-centre. | T1: push-in through the window; its arch becomes the frame of K2. |
| K2 | s02 ghunna | Inside the gold arch: big faceless head in profile, nasal cavity (khayshum) glowing green; a gold ribbon of sound leaves the nose. | T2: the ribbon flows to the centre and splits into two tiles; the head slides out left. |
| K3 | s03 split | Two empty glass-gold tiles (letters in code): right one still (sākin), left one with motion lines (mutaḥarrik), linked by the ribbon. | T3: the tiles slide together and merge into one big glowing tile. |
| K4 | s04 hukm | One big glowing tile; the ribbon stretches across the whole width (longest ghunna), passing under two small arches (waṣl and waqf). | T4: the ribbon flows into an open mushaf on a stand. |
| K5 | s05–s09 listening | Open mushaf on a rahl, pages blank (verse overlaid by the app), ribbon rising from it. Section pauses happen here. | T5: the two pages fold up into two glass pillars. |
| K6 | s10 compare | Two equal glass pillars (nūn, mīm), gold filled to the same top level. | T6: the pillars rearrange into a 4-step staircase. |
| K7 | s12 levels | Four descending steps; the top one is gold with a small crown, the others dim glass. | T7: the staircase is copied three times at different sizes. |
| K8 | s13 tanbih | Three identical staircases (big, medium, small) side by side: same proportions at every speed. | T8: the staircases fly back and become the lit windows of the mosque; pull-out. |
| K9 | s16 summary | Same night as K1 (bookend), camera higher, ribbon drawing a soft circle around the mosque; space for the 4 summary points. | end |

## Prompts
Paste the STYLE block at the top of every keyframe prompt. Attach the previous keyframe each time
(and K1 always, for the world).

### STYLE (top of every prompt)
```
STYLE: flat 2D vector illustration for a calm animated explainer, like a modern motion-design storyboard. Big simple shapes, soft gradients, light film grain, no outlines, no 3D render look. Palette ONLY: night green #00271D, deep green #053627, glass green #245843, gold #E2A51E, light gold #FFD95A, cream #FFFDF5, and a rare accent #43B76E. Wide 16:9 landscape, 1920x1080. One main subject, lots of empty space. ABSOLUTELY NO text, letters, numbers, Arabic writing or symbols anywhere in the image. No human faces.
```

### K1 intro
```
[STYLE]
Night scene. Deep green sky with a soft vertical gradient and a few tiny cream stars. A thin gold crescent moon high on the right. Along the bottom third, a flat silhouette skyline of a mosque with domes and two minarets in deep green, small warm light-gold windows. The central arched window of the main mosque is bigger than the others and glows softly with gold light, as if the camera is about to fly into it. Keep the upper centre empty for a title.
```

### K2 ghunna (attach K1)
```
[STYLE]
Same world as the attached image. The camera has flown through the glowing arched window: the same arch shape is now huge and frames the whole picture as a thin gold border. Inside, on a deep green background: a large calm head in side profile facing left, a simple flat silhouette in glass green with no facial features. Inside the head, the nasal cavity behind the nose glows softly in #43B76E. From the nose a smooth, flowing ribbon of light gold sound curls out to the left and fades into empty space. Nothing else.
```

### K3 split (attach K2 and K1)
```
[STYLE]
Same world and arch border as the attached images. The gold sound ribbon from the previous image now flows to the centre and ends in two identical rounded-square tiles side by side, made of dark glass with a thin gold rim, EMPTY inside (letters are added later). The right tile is still and calm, slightly dimmer. The left tile is brighter, with three small motion lines beside it, as if it is moving. A thin gold ribbon links the two tiles. The head silhouette is gone. Lots of empty space above and below.
```

### T1 transition, Google Flow, Frames to Video (start K1, end K2)
```
One continuous camera move with no cut, 5 seconds. Slow, smooth push-in toward the glowing arched window of the mosque. The window grows until its gold arch outline becomes the gold frame border of the end image, and the interior with the head profile fades in from the light. Calm easing, flat 2D style and colours exactly as the two frames, no new objects, no text.
```

Prompts K4–K9 and T2–T8 are written after the owner approves the test (K1–K3, T1).
