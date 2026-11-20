# Catalogo asset grafici — Rateel

Asset pronti per l'app in `src/assets/images/guided/` (WebP con trasparenza, 4,3 MB in totale).
Conversione: `scripts/assets/key-magenta.py` + `scripts/assets/mapping-batch1.csv`.

| Cartella | File | Stato |
|---|---|---|
| mascot/ | mascot-sheet, -hello, -explain, -listen, -cheer, -think, -celebrate | ✅ pronti |
| mascot/ | mascot-parts | ⚠️ parti troppo piccole → rifare (batch 2, prompt 1–3) |
| icons/ | izhar, idgham, iqlab, ikhfa, ghunna, madd, qalqala, tafkhim, sifat | ✅ pronti |
| icons/ | mushaf, sharh, listen, record, compare, nutq, trophy, quiz, target, video | ✅ pronti |
| illustrations/ | letter-emerging, shield-tongue, lahn-jali, lahn-khafi, book-light, book-light-rays, medal-lesson | ✅ pronti |
| illustrations/ | makharij-head | ⚠️ dentro una cornice → rifare isolata (batch 2, prompt 7) |
| frames/ | label-frame, flower-ornament, verse-frame, rosette, lattice-corner-left/right, arch | ✅ pronti |
| backgrounds/ | bg-stage, bg-listen, bg-quiz, bg-celebrate, bg-intro | ✅ pronti |
| effects/ | star-gold, confetti-set | ✅ pronti |
| effects/ | sparkle | ⚠️ alone leggermente rosato → rifare su nero (batch 2, prompt 8) |
| effects/ | light-rays, glow | ❌ mancanti (batch 2, prompt 9–10) |

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
