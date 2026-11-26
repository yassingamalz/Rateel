# Asset style: references vs the app's shared library

Owner, 2026-11-26 (after screen 12): the reference's header assets (mosque with yellowish tones, darker gold
calendar, brighter arches…) differ a little from the rest of the app. **Decision now: keep the app's assets** so every
screen speaks the same graphic language. The reference versions are not ugly: they are **candidates for a later,
app-wide standardisation** (regenerated once with ChatGPT and replaced everywhere, never on one screen only; see
`ASSETS.md`, «Future note»).

Image: `asset-style-comparison-12.jpg` (reference 12 on the left, app on the right, same crops).

| Element | Reference 12 (ChatGPT) | App (shared library, today) | Later option |
|---|---|---|---|
| Mosque | lit from the top: yellow-green highlights (#B6C36A…) on a greener body, sharper, more 3D, small domes in front | `decor/mosque.webp`: flat dark green silhouette, faint (83%), fading into the ground (screen 03) | a 3D mosque in the reference style for every header |
| Crescent + star | bright warm gold, both with highlights and a soft shadow, star as bright as the crescent | `decor/crescent_star.svg`: flat gold crescent, star darker olive at 55% (03/05) | 3D gold pair |
| Calendar emblem | darker, deeper gold (#D9A11C…#B8860B), bevelled | owner's `icons/calendar_gold.webp`: brighter flat gold (#FFD54A…#F2B01E) | tone the emblem down, or a bevelled set of emblems |
| Header arch | thick luminous three-tone stroke with halo, wider dome | `decor/header_arch.svg` (03): thinner flat gold #E6C159 | luminous arch for every header (conflict D1) |
| Corner lattice | gold lattice with dark carved offset, fading diagonally | `decor/corner_glow_*.webp` (03): glowing lattice with frame lines | — (03 already close) |
| Title divider | bright pale lemon line at full length | `decor/title_divider.svg` (03) with the 03 gradient | brighter divider (conflict D3) |
| Flame disc | wide soft gold glow, olive inner light | code: disc with gold rim and narrower glow | — (code, can follow the reference) |
