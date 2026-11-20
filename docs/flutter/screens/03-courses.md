# Screen 03: courses / learning paths (المسارات التعليمية)

Status: 🟡 plan waiting for the owner's confirmation
Branch: `flutter/03-courses`
Reference: `docs/flutter/screens/03-courses/reference.webp` (1847×851, glassy gamified, dark)
Current app: `src/app/features/courses/` (Angular), data `src/assets/data/courses.json` (12 courses).

## Layout (landscape, RTL)
| Zone | Content |
|---|---|
| Right rail (~9% width) | Menu button; five stat items with gold count bubbles: courses (30), Quran/reading (114), recitation (2), leaderboard (15), achievements (5). The active item has a gold ring. |
| Header (top ~35%) | Arch outline with an open book on its apex, title «المسارات التعليمية» in cream, small gold divider with a diamond. Mosque silhouette on the left, crescent and star on the right, lattice corners at the top edges. |
| Path (bottom ~60%) | Horizontal track of course cards, right to left, joined by a thin gold line with glowing nodes. The first card is active; the others are locked. |

### Course card
- Rounded glass panel, dark emerald, soft shadow, faint geometric pattern along the bottom.
- **Active**: gold rim with soft glow; level pill «مستوى مبتدئ» with a star; course icon (gold);
  title (large, cream); thin gold rule; description (2 lines); play button + progress bar + percentage.
- **Locked**: green-grey rim, lock button in the top corner, dimmed icon and text, no progress row.

## Built in code (Flutter)
Background gradient and vignette, cards (glass, rims, glow, shadows), title and texts, divider,
level pill, progress bar, play and lock buttons, path line with nodes, right rail, count bubbles,
light/dark toggle (in the rail, light mode disabled for now). Simple UI glyphs (menu, lock, play, star,
graduation cap, book, microphone, trophy, medal) come from an icon font.

## Image assets
| # | Asset | Source |
|---|---|---|
| A1 | Header arch outline with open book on the apex | **to generate** (existing `header-arch` is a filled glass shape, not this thin outline) |
| A2 | Mosque silhouette, faint, left of the header | **to generate** (existing `mosque-skyline` is a bright glowing skyline) |
| A3 | Gold crescent and star | **to generate** |
| A4 | Lattice corners, top left / top right | existing `frames/lattice-corner-left/right` (to verify on screen, shown faded) |
| A5 | Seamless geometric pattern strip for the card bottoms | **to generate** |
| A6 | Course icons, one per course (12) | **to generate**: 01 open Quran on rehal, 02 head with sound waves, others below |

Course icons (A6), flat gold line style as in the reference:
01 أساسيات التجويد: open Quran on a rehal · 02 النون والميم المشددتان: head profile with sound waves from the
nose · 03 مخارج الحروف: head cross-section with articulation points · 04 النون الساكنة والتنوين: letter-free
symbol of a small circle with a flowing link · 05 الميم الساكنة: closed lips · 06 المد الطبيعي: short
stretching wave · 07 المد الفرعي: longer double wave · 08 مد البدل: wave with a turning arrow ·
09 المد العارض للسكون: wave ending in a stop dot · 10 المد اللازم: long wave with a lock bar · 11 القلقلة:
bouncing echo rings · 12 تجويد متقدم: crown over an open book.
These are proposals: the owner may change them.

## Motion and UX (to confirm)
- **Entry**: header fades and settles from above (300 ms); cards slide in from the right one after the
  other (60 ms stagger); the path line draws itself from right to left; the nodes light up.
- **Scroll**: horizontal drag with snapping to the card centre; the card in the centre scales to 1.0, the
  others to 0.94 and dim slightly (parallax on the header ornaments).
- **Active card**: slow breathing glow on the gold rim (4 s, very soft). Progress bar fills on entry.
- **Tap on active card / play**: press-down scale 0.97 with haptic tap, then a morph transition into the
  units screen (05): the card expands to fill the screen.
- **Tap on locked card**: small horizontal shake of the lock and a light haptic; a toast explains what
  to complete first.
- **Rail**: tap feedback with gold ripple; the active ring morphs between items.
- No music; optional short UI tap sound.

## Open questions for the owner
1. Course icon list A6: approve or change the proposals.
2. Motion proposal above: OK?
(Rail icons and theme toggle moved to screen 04, side navigation.)
