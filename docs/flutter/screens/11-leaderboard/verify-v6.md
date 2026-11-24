# Screen 11 verification v6 (2026-11-24)

Owner: «almost everything does not match the reference: verify everything, gradients, lines, sizes». This pass measures
every element of `capture-v6-start.png` against `reference.webp` (1844×853, u = 8.53 px) with
`tools/flutter-review/leaderboard-verify.py` (boxes) and pixel profiles (gradients, lines). The app's content area is
21 px wider (approved rail 18.5u vs ~21u in the reference): right-anchored elements are compared shifted by 21 px.

## Why earlier rounds missed differences
- Comparisons were whole-screen at small scale, plus a few critic numbers taken as true (row gap 0.5u was right, I
  reverted it to 1.2u by eye; the critic was wrong about nothing there, I was).
- The lattice used `Image(repeat)` without `fit: BoxFit.none`: Flutter's default `scaleDown` shrank the tile to the band
  height, so the cells were 2–3× too small whatever the scale value (v2–v6).
- v4 read the title as straight; it follows the ribbon's arch.

## Element boxes (px at 853 high; dx/dy/dw/dh = app − reference)
```
element                REF box                      APP box (shifted back)        dx  dy  dw  dh (px @853)
ribbon gold            (537, 27, 1128, 138)         (537, 25, 1129, 137)            0  -2   1   1
title cream            (690, 40, 963, 123)          (710, 57, 958, 113)            20  17 -25 -27 <<
header R text          (1189, 205, 1493, 243)       (1209, 209, 1492, 244)         20   4 -21  -3 <<
header pts             (304, 206, 408, 232)         (302, 209, 403, 236)           -2   3  -3   1
header rew             (84, 200, 229, 232)          (79, 200, 226, 237)            -5   0   2   5 <<
medal1 (red ribbon)    (1430, 369, 1457, 394)       (1430, 367, 1455, 392)          0  -2  -2   0
avatar1 disc           (1278, 304, 1370, 394)       (1279, 306, 1370, 388)          1   2  -1  -8 <<
name1                  (1054, 299, 1244, 339)       (1058, 307, 1243, 338)          4   8  -5  -9 <<
lessons1 text          (1109, 367, 1208, 392)       (1110, 368, 1213, 395)          1   1   4   2
book1                  (1224, 362, 1246, 388)       (1225, 363, 1248, 390)          1   1   1   1
star1                  (277, 329, 316, 367)         (275, 326, 315, 364)           -2  -3   1   0
pts1                   (335, 338, 419, 363)         (336, 336, 422, 361)            1  -2   2   0
coins1                 (165, 325, 215, 375)         (165, 322, 218, 371)            0  -3   3  -1
rew1 text              (92, 339, 152, 363)          (92, 336, 156, 360)             0  -3   4   0
medal2 red             (1431, 515, 1457, 537)       (1430, 512, 1455, 538)         -1  -3  -1   4
avatar2                (1278, 450, 1370, 539)       (1279, 451, 1370, 534)          1   1  -1  -6 <<
name2                  (1105, 449, 1244, 486)       (1104, 453, 1242, 489)         -1   4  -1  -1
star2                  (277, 474, 316, 512)         (276, 472, 315, 510)           -1  -2   0   0
coins2 silver          (153, 470, 203, 520)         (140, 468, 206, 517)          -13  -2  16  -1 <<
disc15                 (1416, 687, 1495, 764)       (1418, 689, 1493, 763)          2   2  -4  -3
avatar me              (1276, 682, 1371, 774)       (1277, 683, 1370, 769)          1   1  -2  -6 <<
name me                (998, 674, 1241, 713)        (1001, 677, 1243, 714)          3   3  -1  -2
pts me                 (327, 708, 386, 735)         (327, 709, 386, 734)            0   1   0  -2
star me                (267, 700, 308, 739)         (267, 699, 307, 737)            0  -1  -1  -1
chevron ring           (99, 688, 173, 763)          (99, 689, 173, 763)             0   1   0  -1
tab gold               (1552, 165, 1626, 373)       (1553, 165, 1626, 374)          1   0  -1   1
```
Rows marked `<<` that are not real differences: `title cream` (the mask also catches the ribbon's pale highlights in the
reference; checked on a 3× grid instead: same arch and size within ~2 px), `name1` (the reference draws the ﷲ ligature
with a shadda above; Readex Pro has none), `coins2 silver` (the mask includes «5K»), `avatar` heights (the mask stops at
the figure's clothes). Real remaining differences: `header R text` is 21 px narrower than the reference while the other
two header labels match (ChatGPT drew «المستخدم» wider): kept at the common size 4.5u.

## Gradients and lines (hex sampled at x = 800 unless noted)
| Element | Reference | App v6 |
|---|---|---|
| Background | #00251C … #00261D | #00251C … #01261C |
| Panel header fill | #01251A | #01251A |
| Panel top rim | #A89C48 #FFF878 #FDE55F #FCE75A #A18C34 (5 px) | #C2B34E #FEF26D #FDED64 #8B8840 (4 px) |
| Divider | #DDD88B #FFFFB8 #E7E091 at y 273–275 | #F0EEA5 #FBF9B1 #BFC280 at y 273–276 |
| Row fill | #02281D (top) → #052B1D → #0F3521 (bottom) | #03291C → #052B1D → #0E371E |
| Row bottom light | #83A279 #89A87F (2 px) at y 421–422 | #83A37B at y 420 |
| Rows pitch / gap | 146 px / 2–3 px | 146 px / 2.5 px |
| Bar fill | #205D27 (top) → #0A4423 → #04361B | #175625 → #0A4623 → #05391C |
| Bar glow above the rim | #4C5A1A … #0D3417 over ~25 px | #3D491C … #092D1D |
| Gold tab | #DFAC35 line, #9D7514 → #BE8E19 (to 35%), #E5A71C → #EAAC1F, #FDE66E bottom | same stops |
| Tab container | #01120D, thin pale line | #00150F, thin pale line |

All measured element boxes are within ±4 px (0.5u) except the items explained above.
