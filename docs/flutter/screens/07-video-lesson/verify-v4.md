# Screen 07 verification v4 (2026-11-24)

Element-by-element check of `capture-v4-unavailable.png` against `reference.webp` and of `capture-v4-playing.png` against
`reference-playing.webp` (both 1842×854, u = 8.54 px), with `tools/flutter-review/video-verify.py` (same masks and search
regions on both images; boxes in px, dx/dy/dw/dh = app − reference). Before this pass: zoomed side-by-side crops of the
icon/mosque, the corners, the skip button, the bottom band, contrast-enhanced whole screens, and line/brightness profiles
(arch line, divider, corner bands). Captures at phone size: `capture-v4-*-phone.png`.

## Fixed during the verification (v1 → v4)
- Icon 30% too small (the PNG kept transparent margins: trim threshold alpha > 60) and too yellow (tone #E1CEB3 vs #F1E0BA).
- Arch line: the reference is bright only at the apex and dims down the lobes (#FFE48F → #B68C2D → #404622): vertical mask.
- Corners: cells 15% too large, far too bright (#FBDF48 vs #9D8F38), fading too late: 39u, olive-gold tone, fade
  from 0.7 to 0.97 of the box; per-25-px band brightness now within a few levels of the reference.
- Top corners (faint lattice in the reference, x ≤ 18u, y ≤ 21u): bottom corners flipped at 38%.
- Skip glow too strong (box +19 px), text too bold; player glow too strong; playing title 16% too wide; divider fade.
- Divider left half had its gradient reversed.
- Poster/arch popped in after the entry: assets precached before the entry.

## Numbers (v4)
```
=== unavailable
element            REF box                  APP box                  dx dy dw dh (px @854)
arch top (gold)    (532, 43, 1305, 199) (534, 43, 1305, 199)   2   0  -2   0
mosque             (553, 157, 829, 449) (460, 215, 849, 446) -93  58 113 -61 <<
icon gold          (811, 212, 1051, 384) (811, 269, 1050, 390)   0  57  -1 -51 <<
icon play cream    (894, 271, 943, 325) (895, 272, 947, 317)   1   1   3  -9 <<
title              (689, 420, 1152, 491) (688, 420, 1149, 497)  -1   0  -2   6 <<
divider            (716, 514, 1153, 542) (717, 510, 1123, 544)   1  -4 -31   6 <<
sentence           (667, 577, 1176, 619) (666, 577, 1174, 623)  -1   0  -1   4
skip rim           (1493, 649, 1780, 759) (1493, 649, 1799, 758)   0   0  19  -1 <<
skip text+glyph    (1550, 688, 1722, 732) (1552, 690, 1717, 736)   2   2  -7   2 <<
corner L gold      (19, 658, 135, 754) (0, 620, 134, 751) -19 -38  18  35 <<
corner R gold      (1493, 649, 1780, 759) (1493, 635, 1841, 758)   0 -14  61  13 <<

background medians (ref | app)
  (150,300) #01261D | #01261D
  (150,500) #01271E | #01261D
  (1700,300) #01261E | #01261D
  (921,640) #012D22 | #012B21
  (921,800) #012D22 | #012A20
  (400,800) #01291F | #01271E
  (300,150) #01261E | #01271D
  (921,30) #012A20 | #01291F
  girih ref (60,200) p95-med 2.7  girih app (60,200) p95-med 2.7
  girih ref (1600,200) p95-med 2.7  girih app (1600,200) p95-med 2.7

brightest colours (ref | app)
  arch top (gold)    #D4B96B | #D4BE71
  mosque             #E6D5AD | #E8D7B8
  icon gold          #F1E0BA | #E1CEB3
  icon play cream    #EBD6A6 | #E0CBA4
  title              #F6E8CA | #FAF1D8
  divider            #D5A63F | #E1AC3F
  sentence           #D2D0C2 | #C8C8B0
  skip rim           #F6EDD6 | #FAF1D8
  skip text+glyph    #FAF4DF | #FAF1D8
  corner L gold      #73742E | #9A8637
  corner R gold      #E4CD98 | #EACC8F
=== playing
element            REF box                  APP box                  dx dy dw dh (px @854)
arch top (gold)    (643, 44, 1192, 159) (273, 43, 1192, 159) -370  -1 370   1 <<
title              (698, 170, 1154, 222) (692, 168, 1148, 228)  -6  -2   0   8 <<
player rim         (504, 236, 1358, 678) (504, 253, 1333, 677)   0  17 -25 -18 <<
line gold          (576, 709, 833, 732) (576, 716, 819, 724)   0   7 -14 -15 <<
knob               (803, 709, 827, 733) (819, 708, 844, 732)  16  -1   1   0 <<
time L             (501, 711, 554, 730) (502, 710, 552, 729)   1  -1  -3   0
time R             (1289, 711, 1339, 730) (1292, 710, 1338, 729)   3  -1  -4   0
skip rim           (1492, 649, 1780, 759) (1493, 649, 1799, 758)   1   0  18  -1 <<
skip text+glyph    (1550, 688, 1722, 732) (1552, 690, 1717, 736)   2   2  -7   2 <<
corner L gold      (0, 626, 143, 764) (0, 620, 134, 751)   0  -6  -9  -7 <<
corner R gold      (1492, 649, 1780, 759) (1493, 635, 1841, 758)   1 -14  60  13 <<

background medians (ref | app)
  (150,300) #012B1C | #01261D
  (150,500) #012B1D | #01261D
  (1700,300) #012A1E | #01261D
  (921,640) #462206 | #638589
  (921,800) #002C1E | #012A20
  (400,800) #002B1D | #01271E
  (300,150) #012A1D | #01271D
  (921,30) #002C1D | #01291F
  girih ref (60,200) p95-med 4.7  girih app (60,200) p95-med 2.7
  girih ref (1600,200) p95-med 4.7  girih app (1600,200) p95-med 2.7

brightest colours (ref | app)
  arch top (gold)    #E1CD88 | #F6DD8B
  title              #FAF3D1 | #FAF1D8
  player rim         #EED5AB | #EAE5DB
  line gold          #F8E5BA | #F8E5C1
  knob               #FDF3DE | #FDF1DA
  time L             #FBFCE4 | #FFFBDC
  time R             #FCFCDE | #FFFBDC
  skip rim           #F6F0D3 | #FAF1D8
  skip text+glyph    #F9F7DC | #FAF1D8
  corner L gold      #7F8039 | #9A8637
  corner R gold      #F0DFA2 | #EACC8F
```

Rows marked `<<` that are not real differences:
- `mosque`, `icon gold`, `icon play cream`: the masks catch different parts (the reference's mosque mask includes the
  crescent and the arch lobe; the icon's cream top bar falls under the gold threshold after the tone). Checked on the
  zoomed crops: icon and mosque coincide within ~1u.
- `skip rim` dw +19: the right corner lattice under the button passes the gold mask at x 1780–1799 (the rim itself
  matches: 1493–1779 × 649–758).
- `corner R gold`: same box as the skip button in the reference (its corner lattice is under the mask threshold).
- `arch top` (playing) x 273: our capsule fill (screen 02, fills from the right) is inside the search region.
- `player rim` top 236 / right 1358: the reference box includes the arch line; the frame itself is 504–1333 × 253–677
  in both.
- `line gold` / `knob`: the demo position differs (38% vs 37%); line thickness and colours match.
- `title` dh +6/+8: Readex Pro's descenders; width and top within 6 px.

## Real differences left
1. **Top bar (screen 02, approved ✅ 2026-11-24)**: capsule and pause button keep the approved 02 geometry; the capsule
   fills from the right (RTL) and reads «0/100» without spaces. The reference fills from the left, and the video line under
   the player fills from the left too (as the reference): question for the owner (same direction everywhere?).
2. **Bottom lattice band** (two rows of the corners' star-cross lattice across the whole bottom, y ≈ 83–97u): missing,
   needs an asset (prompt V5).
3. Girih: the playing reference shows it a little stronger (p95 − median 4.7 vs 2.7); the unavailable reference matches.
4. Background tone: the playing reference is slightly greener (#012B1C vs #01261D at the edges); the unavailable
   reference matches within one level (one background for both states).
