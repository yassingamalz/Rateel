# Catalogo asset grafici — Rateel

Asset pronti per l'app in `src/assets/images/guided/` (WebP con trasparenza, 4,3 MB in totale).
Conversione: `scripts/assets/key-magenta.py` + `scripts/assets/mapping-batch1.csv`.

| Cartella | File | Stato |
|---|---|---|
| mascot/ | mascot-sheet, -hello, -explain, -listen, -cheer, -think, -celebrate | ✅ pronti |
| mascot/ | mascot-parts | ⚠️ parti troppo piccole (sostituite dai file sotto) |
| mascot/ | mascot-arm-left, mascot-arm-right | ✅ batch 2 |
| mascot/ | mascot-mic, mascot-quran, mascot-encourage | ✅ batch 2 |
| mascot/ | mascot-body (senza braccia) | ✅ batch 3 (senza volto) |
| icons/ | izhar, idgham, iqlab, ikhfa, ghunna, madd, qalqala, tafkhim, sifat | ✅ pronti |
| icons/ | mushaf, sharh, listen, record, compare, nutq, trophy, quiz, target, video | ✅ pronti |
| illustrations/ | letter-emerging, shield-tongue, lahn-jali, lahn-khafi, book-light, book-light-rays, medal-lesson | ✅ pronti |
| illustrations/ | makharij-head | ✅ batch 2 (isolata, senza cornice) |
| frames/ | label-frame, flower-ornament, verse-frame, rosette, lattice-corner-left/right, arch | ✅ pronti |
| backgrounds/ | bg-stage, bg-listen, bg-quiz, bg-celebrate, bg-intro | ✅ pronti |
| effects/ | star-gold, confetti-set | ✅ pronti |
| effects/ | sparkle, glow | ✅ batch 2 (su nero: usare `mix-blend-mode: screen`) |
| effects/ | light-rays | ✅ batch 3 (solo raggi, su nero: `mix-blend-mode: screen`) |
| youtube/ | thumbnail-bg | ✅ batch 3 (senza volto, spazio a sinistra per il titolo) |

## Batch 2 — `prompt-sequenziali-2.txt` (11 prompt, da ZAPI FLOW)

1. mascot-body (corpo senza braccia, grande)
2. mascot-arm-left
3. mascot-arm-right
4. mascot-mic (personaggio con microfono, per «دورك الآن»)
5. mascot-quran (personaggio con il Corano, per gli ascolti)
6. mascot-encourage (pollice in su, dopo una risposta sbagliata)
7. makharij-head (testa in sezione, isolata, senza cornice)
8. sparkle (su nero)
9. light-rays (su nero)
10. glow (bagliore della lanterna, su nero)
11. youtube-thumbnail-bg (sfondo per le miniature YouTube)

Riferimenti per Flow: REF-A = `reference/icon-library.webp`, REF-B = `../../src/assets/images/guided/backgrounds/bg-stage.webp`,
REF-C = `reference/lesson-screen-mockup.webp`, REF-D = `mascot-sheet` (personaggio).

## Batch 3: `prompt-sequenziali-3.txt` (3 prompt) ✅ ricevuto e importato

**Set di asset completo: nessun elemento mancante.**

1. mascot-body: senza braccia e **senza volto**
2. youtube-thumbnail-bg: personaggio **senza volto**
3. light-rays: solo raggi, nessun emblema

Regola: il personaggio non deve mai avere occhi o bocca. Va scritto esplicitamente in ogni prompt
che lo riguarda.
