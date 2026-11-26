# Screen 23: settings (الإعدادات)

Status: **approved** (v1, APK 1.0.402, 2026-11-26), PR #50 (merge after 10 and 12). Added by the owner (2026-11-25). Reference: **`screens/23-settings/23-impostazioni.webp`** (owner, generated with
`prompts/23-settings/reference-v1.txt` from the app screenshots 14, 11, 08-rules).

## Owner changes to the reference (2026-11-25), not defects
- **The settings list fills the whole content width**: no left column (the left glass panel with the mosque goes).
- **«عن التطبيق» and «إعادة ضبط التقدم» become rows of the list**, same row style as the others (badge with icon,
  label, control on the left: a chevron for «عن التطبيق», the muted-red rim for «إعادة ضبط التقدم», which asks
  for confirmation). With 8 rows the list scrolls under the title (or rows get shorter: to check on the phone).
- Kept from the reference: title «الإعدادات» with the gold divider, the side rail with the **gear at the bottom**
  (selected, gold), rows with lobed badges, segmented dark/light pill, −/100%/+ text size, gold switches, reciter
  picker, reminder time + switch.

## Proposed content
| Row | Control | Why |
|---|---|---|
| المظهر (theme) | dark / light segmented pill | dark first, light/dark toggle always present (CLAUDE.md); today the toggle lives only inside lessons |
| حجم الخط (text size) | − / value / + | promised in `main.dart` (the app ignores the phone's text zoom) |
| المؤثرات الصوتية (sounds) | switch | `core/sounds.dart` |
| الاهتزاز (vibration) | switch | `core/haptics.dart` |
| القارئ (reciter) | picker | listening lessons (22), rule audio examples (08) |
| تذكير يومي (daily reminder) | time + switch | daily challenges (12) |
| عن التطبيق / إعادة ضبط التقدم | buttons | about; reset progress with a confirmation |

## Open questions for the owner
- Entry point: a gear at the bottom of the side rail, an item in the open menu, or both?
- One page, or a profile + settings page together?
- Which rows to keep (reciter and reminder need features not built yet).

## v1 (2026-11-26, branch `flutter/23-settings`)
- Code: `lib/settings/settings_screen.dart`, `lib/core/app_settings.dart`; rail: `lib/nav/side_nav.dart`, `nav_items.dart`.
- Geometry from the reference (u = 8.53 px): title 6.6u Cairo at 1.6u, divider 82u at 10.4u, card 5u from both
  edges, top 17u, bottom 10.4u, rim 0.38u pale gold (#F9F59E → #EFCC5D) with a soft glow, rows 11.2u, badge
  9.8×10u at 3.6u from the right, label 4.4u Cairo 700 at 17u, controls at 4.3u from the left (segmented pill
  46×7.3u, round buttons 8.2u, value pill 20.5×7u, switch 11.7×5.5u, reciter pill 49×7.5u, time pill 26×7u).
- Rows: theme, text size, sounds, vibration, reciter, daily reminder, about (gold chevron, opens a dialog), reset
  progress («إعادة الضبط» pill with the red rim, confirmation dialog, then a small message).
- Review aids: `?section=6` opens settings, `?textScale=1.1`.
- Captures: `23-settings/capture-v1.png` (top), `capture-v1-bottom.png` (scrolled, sounds off), `capture-v1-about.png`.
- Open: text size range and scope (see DECISIONS), reciter list (4 names, owner to confirm), reminder needs the
  notifications of screen 12, light theme only changes lesson 08 for now.
