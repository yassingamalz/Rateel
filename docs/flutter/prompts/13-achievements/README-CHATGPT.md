# Screen 13 (achievements, الإنجازات): instructions for ChatGPT

Rateel is an Arabic (RTL) Tajweed learning app, landscape, dark emerald and gold style. Screen 13 is the page with the
points, the level and the achievement cards. **Do not invent a new style**: every image must look like the approved app
(screenshots in `docs/flutter/app-references/`) and like the gold medals of screen 27.

- 7 images: **P1** points medal (empty), **P2** level emblem (empty), **C1–C5** card emblems (one per achievement).
- Prompts: `images-v1.txt` in this folder. Generate P1, P2 and C1 first; attach the accepted C1 to C2–C5.
- Rules: one object, centred, large, 2048×2048, flat pure magenta `#FF00FF` background (keyed out by `scripts/assets/key-magenta.py`),
  no shadow on the background, no text, no digits (numbers are drawn by the app), no watermark.
- Output: PNG named `p1_points_medal.png`, `p2_level_emblem.png`, `c1_journey.png` … `c5_master.png` in `docs/design-assets/achievements/`.
