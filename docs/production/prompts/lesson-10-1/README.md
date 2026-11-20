# Lesson 10.1 «النُّونُ وَالْمِيمُ الْمُشَدَّدَتَانِ»: element prompts (approved by the owner)

Owner decisions (2026-11-20): script approved; ghunna definition taken from the book (ch. 07, p. 203);
the نّ → نْ + نَ split is wanted (done in code, as text morph); long verses play only the needed fragment;
free voice F1 ar-SA-HamedNeural. `glass-card` and `ghunna-levels` were dropped (cards are CSS);
`meem-lips` and `noon-tongue` GIFs moved to lessons 10.2 / 10.6.

References to attach in Flow (project assets, named exactly):
- **REF-G**: the glassy lesson screens 15–21 (`docs/design/glassy-gamified/screens/`)
- **REF-H**: `src/assets/images/guided/illustrations/makharij-head.webp` (line style for the head)

## `images.txt`: still images (ZAPI FLOW, in this order) → save as
| # | File | Use in the lesson |
|---|---|---|
| 1 | `glassy/header-arch` | top arch on every step |
| 2 | `glassy/emblem-quran` | emblem on the arch (intro, summary) and the round coach button |
| 3 | `glassy/label-pill` | section label behind the text |
| 4 | `icons/ghunna-glassy` | ghunna icon (definition, summary); replaces the broken `icons/ghunna` |
| 5 | `illustrations/khayshum-head` | step 2, definition of ghunna (also the base of the GIF) |
| 6 | `glassy/shadda-3d` | steps 3–4, the shadda that splits / glows |
| 7 | `glassy/bg-glassy` | full background (not on magenta) |
| 8 | `glassy/mosque-skyline` | bottom of intro and summary |
| 9 | `icons/hourglass` | summary badge «تطويل» |
| 10 | `icons/crown` | levels step («أكمل») and summary badge |

Images 1–6 and 8–10 are on magenta: keyed with `scripts/assets/key-magenta.py`.

## `gifs.txt`: animated GIF (ChatGPT)
1. `ghunna-nose-flow`: attach image 5 (`khayshum-head`) so the drawing is identical. Converted to animated WebP.
