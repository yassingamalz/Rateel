# Animazioni delle lezioni (Claude Design)

Le lezioni animate sono state costruite nel progetto di Claude Design "Animation for non-Mushdada taskeel", in due chat. Le trascrizioni sono in [../../chats/design/](../../chats/design/). I file in questa cartella sono ricostruiti dall'export riapplicando in ordine le scritture e le modifiche fatte in quelle chat.

| File | Lezione | Durata, formato | Chat |
|------|---------|-----------------|------|
| `Noon Mushaddadah.dc.html` + `noon-anim.jsx` | U5.L1, nūn mushaddada e ghunna con il conteggio dei 2 tempi | 40 s, 16:9 | 2026-06-22 |
| `Sifat al-Huruf.dc.html` + `sifat-anim.jsx` | U3.L1, panoramica delle ṣifāt | dal brief U3.L1 | 2026-06-22 |
| `Articulation Organs.dc.html` + `articulation-anim.jsx` | U1.L2, con segnaposto per le immagini | dal brief U1.L2 | 2026-06-22 |
| `Articulation Organs (Illustrated).dc.html` + `articulation-photo.jsx` | U1.L2 con le tre illustrazioni di Yassin | dal brief U1.L2 | 2026-06-23 |
| `Idgham (U6).dc.html` + `idgham-anim.jsx` | tutta l'unità idghām in un solo video (7 scene), con la fusione come motivo centrale | 60 s | 2026-07-02 |

Scelte di Yassin nelle domande iniziali (chat del 2026-06-22): solo la regola della nūn mushaddada con ghunna, adulti principianti, 40 s, 16:9 per YouTube, solo arabo, stile islamico tradizionale caldo con motivi geometrici, conteggio dei 2 tempi animato. Per l'idghām (chat del 2026-07-02): tutta l'unità, stile deciso da Claude "con la stessa sensazione delle altre lezioni", fusione come elemento centrale, 60 s, voiceover a scelta di Claude.

Le lezioni hanno un pannello Tweaks con tema (es. "Manuscript"), scrittura (es. "Naskh") e motivo (es. "Girih").

## Cosa manca per farle girare fuori da Claude Design

- `animations.jsx` e `image-slot.js`: componenti starter copiati dal sistema di Claude Design, non presenti nell'export.
- Il runtime dei Design Component (`DCLogic`, `x-import`): i file `.dc.html` qui sono template, logica e props messi in sequenza, non pagine pronte.
- Le immagini: `assets/lips.jpg`, `assets/head.jpg`, `assets/head-glow-sm.png` (ricavate da tre PNG caricati da Yassin), non incluse nell'export.
- L'ultima richiesta nella chat dell'idghām ("add more font types on the tweaks") si è fermata per limite di quota: la versione salvata qui potrebbe non includerla.

Per avere le versioni definitive e funzionanti conviene esportarle direttamente dal progetto di Claude Design.
