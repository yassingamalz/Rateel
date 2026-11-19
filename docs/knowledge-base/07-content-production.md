# 07. Produzione dei contenuti

Brief completi in [lessons/](lessons/), stile in [11-video-style-guide.md](11-video-style-guide.md), stato di tutte le lezioni in [lessons/PRODUCTION-PLAN.md](lessons/PRODUCTION-PLAN.md).

## Formato del brief di lezione

Fonte principale: brief [U3.L1](lessons/U3.L1-sifat-overview.md), dalla chat [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011) turno 5.

Ogni lezione ha cinque scene: titolo → introduzione del concetto → contenuto principale → momento di sintesi → anticipazione della lezione successiva. Per ogni scena il brief dà:

- testo arabo a schermo, con vocalizzazione completa (va ricontrollata a mano, alcuni strumenti la perdono);
- voiceover facoltativo;
- specifiche di animazione;
- prompt d'illustrazione senza testo, da incollare nello strumento.

Intestazione del brief: ID, unità, durata, tipo (panoramica o singolo concetto), obiettivo didattico.

## Regole di animazione

Fonte: brief U3.L1, sezione 0.

- Gli oggetti non spariscono: si trasformano nell'elemento successivo (scala, posizione, forma). Nei brief la regola si chiama "morph, never pop".
- Easing in entrata `cubic-bezier(0.22, 1, 0.36, 1)`; tra le scene `cubic-bezier(0.4, 0, 0.2, 1)`.
- Elementi multipli entrano sfalsati di 120–150 ms.
- Tra le scene cross-fade con leggera scala, mai un taglio netto. Sfondo e pattern restano fermi per tutto il video.
- La scena successiva parte circa 0,3 s prima che finisca la precedente.
- Riferimento di stile: la fluidità di Kurzgesagt ([Kurzgesagt's Minimalist Animation Style](https://claude.ai/chat/c4bd4731-0cfa-40c2-bc82-1e0af24b9a69)).

## Design system

| Token | Valore | Uso |
|-------|--------|-----|
| Sfondo | `#1F4037` → `#0B1C17` | gradiente fisso con stella islamica a 8 punte al ~6% |
| Oro | `#DAA520` / `#FFD700` | termini chiave, linee, accenti |
| Bagliore | `#FFE355` | glow |
| Testo verde chiaro | `#95D5B2` | testo secondario |
| Testo oro chiaro | `#DFC298` | testo secondario caldo |
| Bianco | `#FFFFFF` | |

Fonte: brief U3.L1, sezione 0. Nell'app ci sono anche `#2D6A4F` (primary light) e i colori `mushaf` per il tema chiaro (chat [Verifying Modular Components](https://claude.ai/chat/01cd7af5-74ae-4ac8-9684-4b11614545d5)).

Font arabo usato nel sito e nei prompt: Cairo ([Rateel Academy website](https://claude.ai/chat/bb025c49-a2eb-4996-adb4-3e470efcbb84), [Tajweed App Interactive Video](https://claude.ai/chat/37ad5f1c-f2f3-4289-beb7-44ba923df909)).

## Motivi visivi per unità

| Unità | Motivo | Fonte |
|-------|--------|-------|
| Sifāt (U3) | onde sonore concentriche per la "صفة = كيف"; i cinque punti d'oro diventano un'"impronta" del suono | brief U3.L1 |
| Organi dell'articolazione (U1.L2) | sezione anatomica medio-sagittale realistica della testa, colorata nella palette, con una linea d'aria luminosa che attraversa le scene; tre prompt per ChatGPT (sfondo titolo, sezione anatomica riusata in tre scene, primo piano delle labbra) | [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011) (sintesi) |
| Idghām | "Fusion": due carte-lettera si fondono in una lettera con shadda | [pages 231-256](https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba) |
| Lām al-taʿrīf | luna (qamariyya) e sole (shamsiyya) | [pages 231-256](https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba) |
| Nūn/mīm mushaddada | fusione in stile Yu-Gi-Oh fra lettera e shadda | [Kurzgesagt's Minimalist Animation Style](https://claude.ai/chat/c4bd4731-0cfa-40c2-bc82-1e0af24b9a69) |

## Regole Ḥafṣ da segnalare nei brief

Fonte: [Structured lesson for pages 231-256](https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba).

- I casi controversi di mutaqāribān (es. فَقَد ضَّلَّ) Ḥafṣ li legge con iẓhār.
- ط→ت è idghām incompleto: si conserva il الإطباق.
- Shāṭibiyyah e Ṭayyibah divergono su يَلْهَث ذَّلِك e ٱرْكَب مَّعَنَا.

## Leggere il PDF del libro

Fonte: [Structured lesson for pages 231-256](https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba).

- Il PDF è scansionato: `pypdf extract_text()` restituisce stringhe vuote.
- Funziona rasterizzare e leggere le immagini: `pdftoppm -jpeg -r 130 -f [start] -l [end] "[filename]" [prefix]`.
- Il nome del file ha caratteri non ASCII: va sempre tra virgolette.
- La pagina PDF è circa due avanti rispetto al numero stampato (PDF 231 ≈ stampata 229). Controllare la prima immagine prima di lanciare il batch.
- Il sommario (outline) si estrae con `pypdf` e `reader.outline` ([Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011)).

## Strumenti

| Uso | Strumenti | Fonte |
|-----|-----------|-------|
| Contenuti lezione | Claude Design | [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011) |
| Immagini | ChatGPT, Midjourney (`--ar 16:9` per YouTube), Leonardo, Canva | [Kurzgesagt's style](https://claude.ai/chat/c4bd4731-0cfa-40c2-bc82-1e0af24b9a69), [Prompts for Tajweed Lesson Images](https://claude.ai/chat/ad9a0d6c-759d-4df7-a912-5cfe5fb00b5b) |
| Video AI | Sora, Nano Banana (Discord) | [Tajweed Arabic lesson prompt](https://claude.ai/chat/df05070c-d91e-4bec-96a0-70d885707dec) |
| Animazione valutata | After Effects, Adobe Animate, DaVinci Resolve Fusion, Cavalry, CapCut, Lottie, Runway ML, Kaiber.ai | [Minimalist Illustration Animation Tools](https://claude.ai/chat/04da8065-eeda-459b-8e66-fdcc16a5a4ca) |
| Diagrammi | Mermaid | [Curriculum Structure](https://claude.ai/chat/1e125dd1-64c7-4d61-9578-4ac6636b634b) |

## Video introduttivo stile *Journey*

Fonti: [Journey-Inspired Style](https://claude.ai/chat/9876fbd3-0e6b-4e52-bb1f-50f170e95bd2), [Tajweed App Interactive Video](https://claude.ai/chat/37ad5f1c-f2f3-4289-beb7-44ba923df909), [Tajweed Arabic lesson prompt](https://claude.ai/chat/df05070c-d91e-4bec-96a0-70d885707dec).

- Durata prevista circa 2 minuti: rivelazione a Ḥirāʾ, raccolta del Corano, nascita del tajweed.
- Scena 1 (15 s): figura in vesti arabe ai piedi di una duna all'alba, senza volto, montagna con luce dall'alto. Dune arancio-oro, cielo ambra che sfuma in verde-azzurro, resa pittorica.
- Primo frame generato; il prompt del secondo frame (figura più vicina, luce più forte, particelle) è pronto.
- Narrazione araba della scena 1, rivista su richiesta di Yassin: niente anno, riferimento a ليلة القدر, اللوح المحفوظ, "رحمة للعالمين", con la recitazione di «اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ».
