# Rateel Stories — Visual Bible v0.1

**Project:** حِكَايَاتُ رَتِّل · historical micro-stories about the Qurʾān and tajwīd  
**Status:** art direction for review, not final approval  
**Date:** 2026-11-23  
**Duration:** each episode **≤60 seconds**. Artwork 16:9 landscape master; vertical crops only after shot approval.

## Visual intention

A **new, original stylized cinematic language** informed by the user-provided Journey game references: monumental desert landscapes, lyrical simplicity, sparse figures, painterly 3D shapes, atmospheric haze, soft gradients, monumental geometry, contemplative stillness and a clear sense of a journey. **Do not duplicate any Journey asset, costume, character, location or composition.**

This is **historical Islamic storytelling**, not fantasy: stories of revelation, preservation of the Qurʾān, early Arabic writing, and the development of tajwīd.

## Palette

| Role | Color / family | Use |
| --- | --- | --- |
| Desert | `#D8A25B`, `#E9C58A` | sand / mountains / walls |
| Sunset | `#F0CB82`, `#FBEDD3` | horizon and ambient light |
| Earth clothing | `#70452F`, `#A15E3F` | modest robes, accents |
| Sage sky | `#A3C8A0` | muted green sky as in the user references |
| Shadow | `#5A5043` | gentle, not solid black |
| Sacred/narrative light | `#FFF9E9`, `#F6DBA4` | **symbolic white-gold lighting** only; no representation of Allah, divine substance or the angel |

Palette is adaptable by period, place, and scene. Avoid hard saturation and commercial neon.

## Characters and historical accuracy

- Clothing loosely informed by **early Arabian everyday garments**, not modern Gulf national costumes or fantasy gear; modest loose tunics, head coverings, woven shawls, natural fibers, muted earth colors.
- Figures should be **dignified, still, proportional, small in the landscape**. For scenes with sensitive identifiable historical figures, default to **no figure at all**; tell the event via architecture, landscape, objects and light.
- If a human is used as an atmospheric scale marker, **clearly label it generic/anonymous**. Do not caption such a model as the Prophet ﷺ, Jibrīl, Khadīja or a Companion.
- **Never show or personify Allah**. **Never depict Jibrīl in human or creature form**. For the Prophet ﷺ, avoid direct depiction even from behind in ST01; editorial approval is required before changing this.
- No invented Arabic inscriptions, sacred calligraphy, Qurʾān text, faces, modern objects, anachronistic monumental buildings, pharaonic ruins or fantasy clothing.

## Spiritual lighting

White-gold backlight, diffuse shafts, mist and sunlight **stand for a reverent visual mood**, not a claimed physical appearance of revelation. Do not present light rays as a documented historical event. Treat them as an explicitly artistic metaphor.

## Composition, camera, motion

- 16:9, no title baked into image; maintain safe negative space for later code-rendered Arabic captions.
- Wide shots showing scale and reflective quiet; restrained camera movements (gentle dolly, slow crane, delicate parallax).
- Subtle cloth drift and floating dust, **no flashing**, magical particle storms or forced spectacle.
- Scene transitions: continue natural shapes, light and geography; smooth dissolves or spatial transitions rather than abrupt appearance.
- Text must be typeset separately with a verified Arabic font and fully reviewed tashkīl. Qurʾānic audio only from a permitted authentic recitation, never TTS or synthesized imitation.
- No music by default; optional wind/room-tone to be evaluated separately.

## Asset policy and review

- Source PNG/WEBP are **reference images**, not historical reconstructions.
- Keep prompts, generation metadata, and review status beside each visual.
- Each image is **DRAFT**, until user art review and separate historical/religious accuracy review.
- No generated artwork may be treated as a photographic document.
- The source visual language comes from **user-attached images in the Rateel conversation (2026-11-23)**; those images are **not redistributed** here.

## Repo organization

Proposed standalone repository name: `yassingamalz/rateel-stories` (not yet created). Current work is staged in `yassingamalz/Rateel` branch `stories/st01-visual-pack-20261123`, ready to migrate. No app code changed.


## Approved direction: time of day as a narrative device (owner review, 2026-11-23)

The user approved the **poetic desert-journey visual direction** and explicitly requested variable times of day: **dawn, daylight, sunset, blue hour, full night and moonlight**, while preserving one visual language. The light should shift to express contemplation, return, beginning, mystery and reassurance; never add temporal claims to the historical narration without a source.

- **Dawn:** revelation story opening or new beginning; warm pale gold on sandstone.
- **Day:** educational and travel sequences; sage-green sky, broad atmospheric perspective.
- **Sunset / blue hour:** reflective solitude; muted amber contrasted with blue-violet.
- **Night / moon:** quiet, reverent desert and cave setting; indigo shadows with subdued warm practical light.
- **White-gold sacred metaphor:** one restrained shaft or diffuse wash where appropriate. Not a representation of how revelation physically appeared, unless explicitly supported by a source.
- **Interior refuge:** warmth and simple materials, not ornate fantasy settings.

The clock time of the first encounter is **not specified by Ṣaḥīḥ al-Bukhārī 3**. All time-of-day cuts in ST01 are visual direction, not documentary claims.

**Current ST01 sequence:** [Eight-shot shotlist](ST01/SHOTLIST-v2.md) · [Eight-shot prompts](ST01/SCENE-PROMPTS-v2.md) · [Image inventory](ST01/ASSETS.md).

## Artwork quality / reuse gate

The user-approved starting style is not blanket approval of every generated element. Some existing drafts contain invented depictions or inaccurate AI-rendered Arabic writing: retain these as research frames labeled **DRAFT**, replace all Qurʾānic lettering with verified typography, and use figure-free imagery for the specific revelation event and for Khadīja's personal reassurance. User feedback governs further refinements.
