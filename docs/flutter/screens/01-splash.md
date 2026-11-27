# Screen 01: splash / start-up (شاشة البداية)

Status: implemented on `flutter/01-splash` from the current app and the owner's landscape and motion references.
[Phone-size recording](01-splash/startup-phone.mp4). Physical phone review pending.

## References (owner, 2026-11-26)
| File | What |
|---|---|
| `01-splash/01-avvio.webp` | **the reference**, landscape 1844x853, dark |
| `01-splash/01-avvio-square.gif` | **motion reference**, 356x356, 12 frames at 270 ms: the logo's gold glow swells and fades (dim → bright → dim), the bar fills with the «n%» counting (60 → 75%); the way back down in the GIF is only its loop |

Layout of the reference: background as screen 14 (gold arcs, girih corners top left / top right, waves at the bottom,
mosque bottom right); logo (gold arch with «رَتِّل», open book at its foot, soft glow) centred at the top, about
35% of the height; «رتل» large cream; «تعلم أحكام التجويد» gold; gold divider with the diamond; glass capsule with the
gold fill; «60%» cream; «جار تحميل المحتوى…» muted green.

## Artwork and layout

The app uses three small WebP layers derived from the supplied landscape art. The backdrop retains the original arcs,
corner lattice, lower waves and mosque. Its plain central field is reconstructed behind the moving elements.
The emblem and the two-line Arabic wordmark retain the original lettering and proportions. The wordmark has an
Arabic accessibility label. The shared Flutter gold divider, live progress capsule, percentage, status and retry
control are separate widgets. The square GIF supplies the motion and never changes the landscape aspect ratio.

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

## Startup behaviour

The halo brightens and dims over 1.5 seconds; a reduced-motion preference skips the pulse and transition.
On each cold launch the header images are decoded and the existing settings are restored. The bar advances towards
90% during this work and finishes only after success. A 300 ms fade reveals the existing initial destination,
including when opened with a review link. A failed asset load offers an Arabic retry. The settings store retains
its existing offline/default fallback. Android, iOS and web use the splash green behind the first Flutter frame.
