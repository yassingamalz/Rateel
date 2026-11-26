# Screen 01 implementation and review

## 2026-11-26

The splash references from `c698fff` were combined with the app at `a259ae9`.
The decorative background, emblem and calligraphic wordmark come from the supplied landscape image.
The progress control, loading text, retry and transition are Flutter widgets. The original image and motion GIF remain in this directory.

- At 1844 × 853 the visible emblem spans x 772–1071, y 37–347 in both the reference and the build. The title spans y 364–438 and the subtitle y 453–513 in both. The diamond spans y 528–570 in the build and 528–571 in the reference.
- [Phone recording](startup-phone.mp4) from the release web build at a 915 × 412 viewport includes the handoff into courses. The capture uses the app's review slowdown and plays at normal speed.
- Flutter 3.50.1 static analysis passed, all 15 widget tests passed and the release web build succeeded. The startup tests cover progress held during a slow load, completion and retry. A browser check failed the first course-header asset request, tapped the Arabic retry and reached the courses with the 110% text-size override.
- Physical Android and iOS launch appearance still needs device review.
