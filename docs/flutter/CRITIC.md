# Critic review (mandatory, owner's rule 2026-11-20)

Every piece of visual work passes a **critic** before it is shown to the owner. The critic compares the
Flutter result one to one with the ChatGPT reference and lists every difference.

## How
1. Capture the Flutter build at the **same size as the reference** (web build + Playwright), every state
   (e.g. closed / open / selected) and, for animations, frames with `?slow=10`.
2. A separate reviewer (a sub-agent that did not write the code) compares reference and result region by
   region: layout and proportions, spacing, sizes, colours, gradients, rims and glow, typography (font,
   weight, size), icons, ornaments and assets, alignment for RTL, states.
   **Measured, not eyeballed** (owner, 2026-11-20): for every element the critic gives numbers for both
   images: size and position in px at the reference size, corner radius, rim width and colour (hex),
   fill colours (hex, top and bottom of gradients), **shadows and glows** (colour, opacity, blur radius,
   offset, spread), text size/weight/colour. Colours are sampled from the pixels
   (`tools/measure.py` in `app_flutter/` or an equivalent script), not guessed.
3. Output: `docs/flutter/screens/<nn>-<slug>/critic-v<k>.md`, a table of differences, each with severity
   (high / medium / low), whether it is **code** (fix it) or **asset** (ask ChatGPT, give the prompt), and a
   fidelity score 0–10.
4. The critic also checks every value against `DESIGN-SYSTEM.md` and lists **conflicts** with confirmed
   tokens separately: these go to the owner, they are not fixed silently.
5. Fix all code items, re-run the critic, repeat until no high/medium code item remains.
6. Only then show the owner: result, comparison image, last critic report, and the asset list.

## No exclusions (owner, 2026-11-20)
- Whoever launches the critic **must not give it a list of "accepted" differences**. The critic scores the
  whole screen one to one, placeholders included: a missing or placeholder asset is a defect (type: asset,
  with its prompt), not an exception. Screen 03 critic v1/v2 were run with such a list; that was wrong.
- The only differences that are not scored are the ones the **owner has already approved** in
  `DECISIONS.md` (✅), quoted with their date.
- Any choice that differs from the reference (layout, colour, motion state, data shown) is **asked to the
  owner before it is built**, not built and then listed as "owner decision".

Elements that cannot be matched without art (ornaments, illustrations, special icons) are generated with
ChatGPT; everything else must match in code. **Icons that differ from the reference are generated with
ChatGPT** (prompts in `docs/flutter/prompts/`), not replaced with a similar icon-font glyph.
