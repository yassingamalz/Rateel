# Screen 01: splash / start-up (شاشة البداية)

Status: added by the owner (2026-11-26, the free number 01). **References delivered by the owner** (2026-11-26),
generated with `prompts/01-splash/reference-v1.txt`. **Not started yet**: the owner will say when. The screen must be
**identical** to the references; the first step, when we start, is the list of what to ask ChatGPT for.

## References (owner, 2026-11-26)
| File | What |
|---|---|
| `01-splash/01-avvio.webp` | **the reference**, landscape 1844x853, dark |
| `01-splash/01-avvio-square.gif` | **motion reference**, 356x356, 12 frames at 270 ms: the logo's gold glow swells and fades (dim → bright → dim), the bar fills with the «n%» counting (60 → 75%); the way back down in the GIF is only its loop |

Layout of the reference: background as screen 14 (gold arcs, girih corners top left / top right, waves at the bottom,
mosque bottom right); logo (gold arch with «رَتِّل», open book at its foot, soft glow) centred at the top, about
35% of the height; «رتل» large cream; «تعلم أحكام التجويد» gold; gold divider with the diamond; glass capsule with the
gold fill; «60%» cream; «جار تحميل المحتوى…» muted green.

## To prepare when we start (probable, check against the code first)
- Logo emblem as its own transparent image (ChatGPT, from the reference), without the glow (glow drawn in code).
- Background: check whether `assets/ui/coming_soon/background.webp` (screen 14) matches; otherwise ask for it.
- Divider, capsule, texts: drawn in code (shared `GoldDivider`, lesson capsule of 02).

## Angular original (behaviour and content, not style)
- `src/app/core/splash-screen/` (view) + `src/app/core/initialization/` (logic, route `initialization`, guard
  `core/guards/initialization.guard.ts`). Render of the view: `01-splash/angular-original.webp` (the Font Awesome
  `fa-book-quran` icon does not load in the container: the empty glass square is where it sits).
- Content: logo box (120 px glass square, gold book icon), title «تجويد القرآن» (Cairo 600), 4 px progress bar in
  gold with «n%», the current task under it (English in Angular: «Initializing core services…» 10%, «Loading
  essential content…» 30%, «Syncing offline changes…» 60% when online, «Finalizing setup…» 90%, «Ready!» 100%), then
  `/courses`. Error state: red icon, message, «إعادة المحاولة» retry pill. Leaves with a 300 ms fade.
- Native splash (Capacitor): background #1B4332, 3 s, then fades in 500 ms; its image `android/.../splash.png` is
  the Capacitor placeholder (blue X on white), not used.
- The real logo is the launcher icon: `01-splash/logo-ic-launcher.png` (gold arch, «رَتِّل», green disc).

## Proposed (to confirm)
- Title «رتّل» (app name) with «تعلّم أحكام التجويد» under it, instead of Angular's «تجويد القرآن».
- Task texts in Arabic; in Flutter the real work is short (fonts, images, settings): the bar runs over ~1.5 s and
  the screen fades into 03.
- Error state kept (retry), drawn in the same style.
- Android native splash: same background colour so there is no flash before Flutter starts.
