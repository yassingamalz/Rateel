# Design system (single source of style for the whole app)

The app must have **one consistent style direction**. Once the owner confirms a token here (colour,
gradient, shadow, glow, radius, rim, type size), every screen uses it.

**Conflict rule (owner, 2026-11-20):** when a reference screen asks for a value that differs from a
confirmed token (e.g. a different shadow or gold on screen 11 than on screen 04), Claude **does not copy it
silently**: it tells the owner "this conflicts with token X", shows both, and the owner decides (keep the
token, or change the token everywhere). The critic flags these conflicts in its report.

Code: `app_flutter/lib/theme/rateel_theme.dart` (`RateelColors` and the shared decorations). Every value
below must exist there under the same name; screens never hard-code a style value.

| Token | Value | Source | Status |
|---|---|---|---|
| (filled from the side-nav critic measurements, then confirmed by the owner) | | | 🟡 |
