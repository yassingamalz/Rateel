# Screen 03 (courses, المسارات التعليمية): history of the work

Chronology of everything done, found and decided for screen 03, so the next sessions do not repeat it.
Branch `flutter/03-courses` (also carries the approved side navigation, screen 04). Plan: `../03-courses.md`.
Decisions: `../../DECISIONS.md` (rows from 2026-11-20). Assets: `../../ASSETS.md`. Lessons: `../../LESSONS-LEARNED.md`.

**Status: approved by the owner on 2026-11-24, APK 1.0.301** (illustrated cards, style D as background, no arc).

## 1. Plan and first build (2026-11-20)
- Plan updated (layout in u, u = 8.51 px on the 1847×851 reference), prompts P1–P6 for the missing art.
- v1: header (arch, emblem, title, divider), path of glass cards with a gold line and nodes, active and locked
  cards, entry motion, horizontal snap scroll (mouse drag enabled for web), locked tap = shake + toast.
- Pulled the side-nav update (lighter glass close button, swipe to open/close) into the branch.

## 2. Critic loop and the "no exclusions" rule
- Critic v1 7.5 (code only), v2 8.5 (code only). The owner noticed that the critic was given a list of accepted
  differences: rule added to `CRITIC.md` (no exclusions, only owner-approved ✅ differences are skipped, any
  deviation is asked before building). Critic v3 (no exclusions) 7.5 for the whole screen, v4 8.5, no high items.
- Owner's assets placed (v4): arch, emblem, mosque, crescent, corners, divider, card pattern, 12 course icons,
  lock/star/play glyphs. Refinements later (course 01/02 icons, filled emblem kept as spare).

## 3. Course completion and haptics (owner)
- Progress always starts at 0%. Line between courses: dim track with a node in the middle; first half lights at
  50% of the course, second half on completion, reaching the next course.
- Completion sequence (when the last lesson of a course ends, the app returns here by itself): bar to 50%, half
  line + node pop, bar to 100%, light to the next course, lock pops, card turns gold, path glides. Hook
  `courseCompleted`; demo with a long press. App-wide haptics vocabulary `lib/core/haptics.dart`.

## 4. Owner corrections on the phone (2026-11-21)
- Top-right corner larger and under the rail; rail shadow (made on `flutter/04-side-nav`, PR #38, merged here).
- Mosque larger and higher with a transparent fade; titles cream with a soft shadow; pill text centred and kept
  clear of the rim.
- Corner ornaments: Claude's own trellis, then the owner's sets; final: the owner's glowing lattice with a radial
  fade (`corner_glow_left/right.webp`).
- Text ignores the phone's text zoom (a text-size option will live in the app settings); all line widths in u.
- Progressive APK version on every build; one-command build `tools/flutter-review/build-apk.sh`.
- References are visual only: texts and data come from the app (`LESSONS-LEARNED.md`).

## 5. Illustrated cards (2026-11-21 → 2026-11-24)
- Owner's mockup `owner-card-mockup.png`: art on the left fading into the card, text on the right.
- Four art sets tried (green, gold 3D, abstract gold, emblems); SVG traces rejected by the owner (PNG only).
  References in `card-styles/`. HTML mockups (no app build) for the variants: emblem + arc (V1/V2/V3), art as a
  background with and without the arc.
- **Chosen: style D (emblems) as a translucent background from the left (45%, fading towards the text), no gold
  arc.** Fixes from the mockup: title aligned to the right edge like the description, pill text lifted in line
  with the star. Lock: the owner's badge from the course assets (CR-10), not a drawn one.
- Built as the default card (v14): `final-v14.png`, `final-v14-phone.png`. Review aid: `?cards=classic|gold|...`.

## 6. Build notes
- APK versionCode = the highest of: commits on any `origin/flutter/*` branch, versions logged as "APK 1.0.N" in
  any branch's `DECISIONS.md`; +1. Needed because screens 05/06 (other branches) were shipped as 1.0.106/1.0.299.
- Signing: debug key of the container; a stable key for all containers is an open owner decision
  (committing a dev keystore was blocked as sensitive).

## Open points (not blocking)
- Colours of this screen vs the central tokens (one style for the whole app).
- Course 03 icon (classic style) reads weakly; gold-3D art for courses 08–12 has a baked-in card frame.
- Branch `flutter/05-units` (from this branch at ce7ebc9) also edits `courses_screen.dart` and `main.dart`:
  merge this branch first, then resolve there.
