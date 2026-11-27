# Screen 22 v5: element-by-element check (2026-11-26)

Reference `22-lezione-ascolto.webp` vs capture at 1844×853 (`?lessons=1,1&openLesson=0&listenAt=0.415&listenPick=0`),
tool `tools/flutter-review/listening-verify.py`. Target ±4 px. Boxes = ink found with the same colour rule on both images.

| Element | Reference x0,y0–x1,y1 | Flutter | Δ max (px) |
|---|---|---|---|
| capsule | (27, 62, 416, 121) | (26, 62, 417, 121) | 1 |
| pause ring | (1686, 26, 1817, 157) | (1686, 26, 1817, 157) | 0 |
| title | (729, 123, 1113, 188) | (729, 123, 1111, 194) | 6 ⚠ |
| crescent+star | (1320, 83, 1405, 173) | (1320, 83, 1412, 179) | 7 ⚠ |
| card | (39, 210, 1804, 589) | (39, 210, 1804, 589) | 0 |
| badge | (1670, 260, 1752, 342) | (1672, 261, 1749, 339) | 3 |
| surah · reciter | (81, 264, 418, 307) | (82, 263, 420, 309) | 2 |
| verse | (575, 315, 1266, 438) | (597, 315, 1242, 449) | 24 ✗ |
| asked word (gold) | (1188, 310, 1266, 438) | (1151, 314, 1242, 449) | 37 ✗ |
| wave played (gold) | (368, 474, 861, 525) | (362, 474, 816, 516) | 45 ✗ |
| wave rest (green) | (862, 476, 1476, 516) | (827, 466, 1481, 524) | 35 ✗ |
| play ring | (869, 576, 973, 679) | (870, 576, 973, 678) | 1 |
| question | (1314, 732, 1783, 791) | (1316, 731, 1779, 792) | 4 |
| pill 1 (gold) | (993, 725, 1225, 805) | (993, 723, 1224, 804) | 2 |
| pill 2 | (728, 723, 960, 805) | (728, 723, 958, 804) | 2 |
| pill 3 | (464, 723, 696, 805) | (462, 723, 693, 804) | 3 |
| confirm | (58, 709, 335, 810) | (58, 709, 334, 808) | 2 |

## Notes on the differences
- **Title** (+6 px at the bottom) and **crescent + star** (+7 px): the standard header of 08 (owner's rule since 12 v2:
  same decoration and place on every screen); the title size was raised to 7.0u to match the reference's width (±2 px).
- **Verse** and **asked word**: font **Amiri Quran** with the Uthmani text (owner, Q7) instead of the reference's bold
  naskh; it is 46 px narrower and 11 px taller, centred on the same axis. Not a defect to fix in code.
- **Waveform**: the state differs (reference ≈ 44% played, capture 41.5%: chosen in the gap between two words so that no
  word is lit, as in the reference); bars: 51, step 2.6u, width 1.4u, height 1.9–7u, gold #EAB00B / green #3B6C39 as
  measured. The bar heights come from the real recitation (RMS), so their pattern differs from the reference's drawing.
- Everything else within 4 px (capsule, pause, card, badge, surah line, play ring, question, the three answers, «تأكيد»).
- **Headphones**: placeholder (the 06 «listen» icon) until the owner's asset H1.
- Text at 110% (`?textScale=1.1`, `capture-v5-states-phone.jpg` and the captures): question and answers fit (FittedBox),
  the verse scales down inside its box.
