# Guided lesson preview (15–21)

An Arabic, landscape review of seven scenes from the first guided lesson. The course video remains available.
Open the guided lesson from the first unit’s lessons screen using «الدرس الموجّه». The review APK opens directly
on the intro. Finishing the preview returns to the calling screen without awarding course progress.

| Screen | Scene | Source step in intro-lesson-1 |
|---|---|---|
| 15 | Start, optional spoken welcome | s01-welcome |
| 16 | Meaning of tajweed | s02-lugha |
| 17 | Definition and three pillars | s03-istilah |
| 18 | Question with retry and explanation | s04-quiz-lugha |
| 19 | Comparison of clear and subtle recitation errors | s09-lahn |
| 20 | Listening to the example from al-Fatiha 1:7, with replay and timed words | s10-listen-anamta |
| 21 | Summary of the selected topics | s14-summary |

Text, voice recordings, word timings and art come from the repository's lesson-production branch. Screen 20 bundles
the specified 0.30–4.50 second excerpt from the Husary recording. The seven review scenes are a selection from
the 14-step lesson. The summary tiles cover the topics actually included. The microphone exercise belongs to
the longer lesson. The shared pause menu provides resume, restart and exit.

Web preview: append `?guided=1` to an app build. Android review entry: build with
`--dart-define=RATEEL_GUIDED_PREVIEW=true`. Default builds open the course catalogue.

[Seven phone-size screenshots](preview.jpg). Review APK 1.0.445 targets Android ARM64. The APK uses the same test signing certificate as the screen 01 review build.
