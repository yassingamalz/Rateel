# Critic review (mandatory, owner's rule 2026-11-20)

Every piece of visual work passes a **critic** before it is shown to the owner. The critic compares the
Flutter result one to one with the ChatGPT reference and lists every difference.

## How
1. Capture the Flutter build at the **same size as the reference** (web build + Playwright), every state
   (e.g. closed / open / selected) and, for animations, frames with `?slow=10`.
2. A separate reviewer (a sub-agent that did not write the code) compares reference and result region by
   region: layout and proportions, spacing, sizes, colours, gradients, rims and glow, typography (font,
   weight, size), icons, ornaments and assets, alignment for RTL, states.
3. Output: `docs/flutter/screens/<nn>-<slug>/critic-v<k>.md`, a table of differences, each with severity
   (high / medium / low), whether it is **code** (fix it) or **asset** (ask ChatGPT, give the prompt), and a
   fidelity score 0–10.
4. Fix all code items, re-run the critic, repeat until no high/medium code item remains.
5. Only then show the owner: result, comparison image, last critic report, and the asset list.

Elements that cannot be matched without art (ornaments, illustrations, special icons) are generated with
ChatGPT; everything else must match in code.
