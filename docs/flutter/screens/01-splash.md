# Screen 01: splash / start-up (شاشة البداية)

Status: added by the owner (2026-11-26, the free number 01). **Reference to generate** with
`prompts/01-splash/reference-v1.txt`, saved as `screens/01-splash/01-avvio.webp`.

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
