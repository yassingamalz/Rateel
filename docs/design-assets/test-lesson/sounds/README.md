# Test lesson sounds (screen 10), chosen by Claude on the owner's request (2026-11-25)

Source: npm package `uisfx` (romainsimon/uisfx, MIT code; **audio dedicated to the public domain, CC0 1.0**).
Family «dreamy» chosen (warm, mid-frequency, soft attack): measured pitch contour of each file.

| File | Use | Contour |
|---|---|---|
| `success.mp3` (dreamy/success, 1.18 s) | correct answer → `assets/sounds/test_correct.mp3` | rising 409 → 516 → 613 Hz |
| `error.mp3` (dreamy/error, 1.02 s) | wrong answer → `assets/sounds/test_wrong.mp3` | descending 441 → 301 Hz |
| `achievement.mp3` (dreamy/achievement, 1.54 s) | test passed → `assets/sounds/test_passed.mp3` | arpeggio 312 → 775 Hz |
| `organic-*.mp3` | spares (same roles, softer, «organic» family) | |

## In use since 2026-11-26 (owner's choice from `sampler-2026-11-26.mp4`)
plinkfx (maximilianfeix/plinkfx, sounds **CC0 1.0**, `LICENSE-plinkfx-SOUNDS.txt`), from the release zip:
C3 `plinkfx-gem-1.ogg` → `test_correct.mp3`, W2 `plinkfx-error-1.ogg` → `test_wrong.mp3`, S3 `plinkfx-sparkle-1.ogg` →
`test_streak.mp3`, P2 `plinkfx-level-up-1.ogg` → `test_passed.mp3`. The uisfx files above are spares.
Sampler list: `sampler-2026-11-26.txt`.

## In use since 2026-11-27 (owner's choice from `sampler-2026-11-27.mp4`)
New pass on «correct» and «passed» (owner's backlog item). Candidates C1–C8 / P1–P8 from uisfx 0.4.0 and plinkfx 0.3.0
(npm, audio **CC0 1.0**), list with sources in `sampler-2026-11-27.txt`. Owner picked:
- **C8 plinkfx checkpoint** (`plinkfx render checkpoint`, file `plinkfx-checkpoint.mp3`) → `test_correct.mp3`
- **P7 plinkfx level-complete** (`plinkfx render level-complete`, file `plinkfx-level-complete.mp3`) → `test_passed.mp3`
App copies: mono 48 kHz 64 kbps (as before), level matched to the previous files (max momentary loudness ≈ −17 / −16 LUFS).
`passed` is also the celebration of 27 (badges) and of 24 (end of lesson). Wrong (W2) and streak (S3) unchanged; the
previous gem / level-up files stay here as spares.
