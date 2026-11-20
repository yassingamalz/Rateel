# Screen 04: side navigation (rail closed + menu open)

Status: 🟡 v1 built (`app_flutter/lib/nav/side_nav.dart`), waiting for the owner's test and assets N1, N2, A5
Branch: `flutter/04-side-nav` (first screen to build: every other screen sits next to it)
References: `04-side-nav/reference.webp` (menu open), `04-side-nav/rail-options.jpg` (closed rail, three
glassy variants found in the ChatGPT screens: A = 03/11, B = 13, C = 05).
Owner (2026-11-20): build the navigation first; both states are wanted, the glassy closed rail and the
open menu.

## Closed rail (right edge, ~9% width)
- Menu button (glass circle) at the top.
- Six items: الدروس (30), القرآن (114), التدريب (2), المتصدرين (15), الإنجازات (5), الشهادات (3). Gold count bubble on
  the top-left of each icon. Style C: each item in a rounded-square glass tile; active item is a filled gold circle with a gold ring and glow.
- Thin vertical gold-green divider line on its left edge.

## Open menu (right panel, ~36% width)
- Close button (gold-rimmed glass circle, ✕) top left; thin gold arch at the top.
- Six rows: الدروس 30, القرآن 114, التدريب 2, المتصدرين 15, الإنجازات 5, الشهادات 3. Each row: icon
  (right), label, thin divider, gold count pill (left), inside a glass capsule with a faint rim.
- Selected row: gold rim, warm inner glow, icon in a gold-ringed circle, filigree end caps on both sides.
- Faint geometric pattern along the bottom (shared asset A5 from screen 03).
- The rest of the screen stays visible on the left, slightly dimmed.

## Built in code
Panels, glass capsules, rims, glow, count bubbles and pills, close and menu buttons, dividers, the
active-state highlight, dimming of the content. Flat cream glyphs as in style C (icon font).

## Image assets
| # | Asset | Source |
|---|---|---|
| N1 | Thin arch at the top of the open menu | **to generate** (`prompts/04-side-nav/images.txt`) |
| N2 | Filigree end cap of the selected row (mirrored for the other side) | **to generate** |
| A5 | Bottom geometric pattern strip | shared with screen 03 |
| A4 | Lattice corners | existing (`frames/lattice-corner-*`) |
| I1–I6 | Rail icons (solid cream, as REF-05) | **to generate** (`prompts/04-side-nav/icons.txt`, lines 1–6) |
| I7–I12 | Menu icons (as REF-04) | **to generate** (`prompts/04-side-nav/icons.txt`, lines 7–12) |

## Motion and UX (proposal)
- **Open** (tap ☰): the panel slides in from the right (320 ms, ease-out); each rail icon **morphs** into
  the icon of its row while the labels and pills fade in one after the other (40 ms stagger); the content
  dims; ☰ turns into ✕.
- **Close** (tap ✕, tap on the dimmed content, or swipe right): the reverse morph.
- **Select**: the gold highlight glides to the new row/item, light haptic, then navigation.
- **Count bubbles**: small pop when the value changes.
- Android back button closes the menu first.

## Owner's answers (2026-11-20)
1. Closed rail: **style C**. 2. Icons: **flat, as in style C**. 3. Light/dark toggle: in **settings**, not here.
4. **الشهادات** added to the closed rail (6 items). 5. Motion proposal: **approved**.

## Still open
- Where the settings screen is opened from (no settings entry exists in the references).
- Assets N1 (arch), N2 (filigree caps), A5 (bottom pattern): not in v1, slots ready.

## v1 (2026-11-20)
- Font Readex Pro; icons Font Awesome (rail: graduation cap, book, microphone, trophy, medal, award;
  menu: book-open and file-lines for القرآن and الشهادات).
- Geometry in units of 1% of the screen height, measured on references 05 (rail) and 04 (menu).
- The rail tiles morph into the menu rows, icons and count bubbles glide, ☰ morphs into ✕, the selected
  row grows out of the gold circle. Labels stagger in.
- Review aid: the web build accepts `?slow=10` to play animations 10× slower.
- Demo: `04-side-nav/demo-v1.mp4`; comparison with the references: `04-side-nav/compare-v1.jpg`.
- Known differences: missing assets above; reference icons for القرآن and الشهادات are outline drawings.
