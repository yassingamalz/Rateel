# Screen 27 (badges, الأوسمة): instructions for ChatGPT

**Repository:** `yassingamalz/Rateel` (GitHub), **branch `flutter/27-badges`**. Every path below is relative to the root
of that branch. Browse: https://github.com/yassingamalz/Rateel/blob/flutter/27-badges/  ·  raw files: `https://raw.githubusercontent.com/yassingamalz/Rateel/flutter/27-badges/<path>`
(example: https://raw.githubusercontent.com/yassingamalz/Rateel/flutter/27-badges/docs/flutter/screens/27-badges/attach/medal-unlocked-large.png).

Rateel is an Arabic (RTL) Tajweed learning app, landscape, dark emerald and gold style. This folder lists the images the
app needs for screen 27, the badge collection. **Do not invent a new style**: every medal must look like the medals of the
reference.

## 1. Files to download first
| What | Path |
|---|---|
| Reference of the whole screen (style) | `docs/flutter/screens/27-badges/reference.webp` |
| Earned medal, large crop (the model for every medal) | `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png` |
| Earned medal, small crop | `docs/flutter/screens/27-badges/attach/medal-unlocked.png` |
| Locked medal crop | `docs/flutter/screens/27-badges/attach/medal-locked.png` |
| Screenshots of the real app (style of the whole app) | `docs/flutter/app-references/*.webp` (see its `README.md`) |
| Plan of the screen and badge list | `docs/flutter/screens/27-badges.md` |

## 2. What to generate (13 images)
- **12 earned medals M01–M12** (one per badge, each with its own icon) and **1 locked medal L1** (the same for all).
- Generate **M01 first**; then use the accepted M01 as the model for M02–M12 and L1, so that all medals have the same
  size, rosette, laurel, ribbon, golds and lighting. Only the icon in the centre changes.
- Rules for every image: one object only, centred, large in the frame, 2048×2048, flat pure magenta **#FF00FF**
  background (it is keyed out by the app's tools), no shadow on the background, no text except the Arabic letter where
  the prompt asks for it, no watermark.
- **Output:** PNG files with the names below, in the folder `docs/design-assets/badges/` (create it). If you cannot
  write to the repository, give the 13 PNG files with these names to the owner.

| Code | Badge | Icon in the disc | File |
|---|---|---|---|
| M01 | بداية الرحلة | lantern (fanous) | `m01_bidayat_alrihla.png` |
| M02 | خاتم الوحدة | open book | `m02_khatim_alwahda.png` |
| M03 | إتقان التلاوة | microphone | `m03_itqan_altilawa.png` |
| M04 | خبير المخارج | letter ق | `m04_khabir_almakharij.png` |
| M05 | قارئ متقدم | Quran on a rehal | `m05_qari_mutaqaddim.png` |
| M06 | المواظب | flame | `m06_almuwazib.png` |
| M07 | متقن الغنة | letter نّ | `m07_mutqin_alghunna.png` |
| M08 | محترف الأحكام | scroll | `m08_muhtarif_alahkam.png` |
| M09 | صوت جميل | sound waves | `m09_sawt_jamil.png` |
| M10 | متميز في المراجعة | circular arrows | `m10_mutamayyiz_almuraja.png` |
| M11 | المتفوق | trophy | `m11_almutafawwiq.png` |
| M12 | سيد التجويد | crown | `m12_sayyid_altajweed.png` |
| L1 | locked (all badges) | padlock, olive-grey medal | `l1_locked.png` |

## 3. The prompts (one per image)
Where a prompt says «your accepted M01 image», use the M01 you generated and the owner accepted.

### M01, «بداية الرحلة»
- Attach: 1. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`  2. `docs/flutter/screens/27-badges/reference.webp`
- Save the result as `docs/design-assets/badges/m01_bidayat_alrihla.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1, same style as image 2: polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: a classic Arabic lantern (fanous) with a small flame inside. Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M02, «خاتم الوحدة»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m02_khatim_alwahda.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: an open book seen from the front, pages fanned. Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M03, «إتقان التلاوة»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m03_itqan_altilawa.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: a studio microphone on a short stand. Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M04, «خبير المخارج»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m04_khabir_almakharij.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: the single Arabic letter ق in a bold classic naskh style (only this letter, no other text). Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M05, «قارئ متقدم»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m05_qari_mutaqaddim.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: an open Quran resting on a crossed wooden rehal stand. Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M06, «المواظب»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m06_almuwazib.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: a single flame. Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M07, «متقن الغنة»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m07_mutqin_alghunna.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: the single Arabic letter ن with a shadda above it (نّ), bold classic naskh (only this letter, no other text). Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M08, «محترف الأحكام»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m08_muhtarif_alahkam.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: a rolled scroll with a ribbon. Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M09, «صوت جميل»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m09_sawt_jamil.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: three curved sound waves coming out of a small dot, like a broadcast symbol. Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M10, «متميز في المراجعة»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m10_mutamayyiz_almuraja.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: two circular arrows forming a loop (review / repeat symbol). Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M11, «المتفوق»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m11_almutafawwiq.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: a trophy cup with two handles. Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### M12, «سيد التجويد»
- Attach: 1. your accepted M01 image  2. `docs/flutter/screens/27-badges/attach/medal-unlocked-large.png`
- Save the result as `docs/design-assets/badges/m12_sayyid_altajweed.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background, no shadow on the background. Recreate EXACTLY the gold medal of image 1 (same size, same rosette, laurel, ribbon, golds and lighting): polished gold rosette with a scalloped edge, an inner raised rim, gold laurel branches on both sides, a short green ribbon with a V cut below. In the inner gold disc, embossed in darker gold like the Quran of the reference medal: a crown with three points. Same lighting, same golds, same soft bevels. No other text, no watermark.
```

### L1, locked medal (same for every badge)
- Attach: 1. `docs/flutter/screens/27-badges/attach/medal-locked.png`  2. your accepted M01 image
- Save the result as `docs/design-assets/badges/l1_locked.png`

```
One single object, centred, large in the frame, high resolution (2048x2048), on a flat pure magenta #FF00FF background. Recreate EXACTLY the locked medal of image 1, with exactly the same shape and size as the gold medal of image 2 (rosette, laurel, ribbon), in muted olive-grey with a dark inner disc and a small cream padlock in the centre. No text, no watermark.
```

## 4. Not needed
The title ribbon, the lattice band, the coins, the tabs, the panels and the progress bar already exist in the app
(screen 11 and 03): do not generate them. Screen 24 (end of lesson) and 28 (help overlay) are postponed: no images for them.
