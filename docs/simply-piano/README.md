# Rateel stile Simply Piano: nota di passaggio

Stato al 20/11/2026. Questa cartella raccoglie il lavoro della thread "Design Simply Piano-style tajweed lessons": la proposta di design, il mockup UI/UX e la prima lezione animata. Chi riprende il lavoro (persona o Claude Code) parta da qui.

## Cosa c'è

| Percorso | Cosa |
|---|---|
| [proposal.md](proposal.md) | La proposta: modello di interazione, feedback sulla recitazione, riuso dei componenti, ordine di costruzione |
| [mockup/](mockup/) | 6 schermate in orizzontale 844×390 (corsi, unità, lezioni, lezione animata, pratica, risultato). Sono file Design Component di Claude Design: si vedono nel canvas su claude.ai, non da soli nel browser |
| [lessons/intro-lesson-1/index.html](lessons/intro-lesson-1/index.html) | Prima lezione animata «مقدمة في علم التجويد», 42 s, file HTML autonomo: si apre direttamente nel browser |
| [lessons/intro-lesson-1/voiceover.md](lessons/intro-lesson-1/voiceover.md) | Copione del voiceover arabo con i tempi |
| `lessons/intro-lesson-1/shots/` | Tre fotogrammi di riferimento |

Versioni online (private, accesso di Yassin): documento della proposta https://claude.ai/artifact/QSHRmpxBc34v6miCr42cfK, mockup https://claude.ai/artifact/L3ZE1uZMJgov85EwiZo5ub, lezione https://claude.ai/artifact/KoXFCpSkCebfbRroKevbA8.

## Regole decise da Yassin

- **Mai riusare né prendere a riferimento le vecchie lezioni** (le animazioni di Claude Design sul branch `docs/knowledge-base`, `lessons/animations/`). Le lezioni si rifanno da zero come video professionali in morphing.
- Stile video: "morph, never pop" (gli oggetti si trasformano, non spariscono), ritmo alla Kurzgesagt, testo e lettere che si trasformano. Micro-lezioni da 15–45 s in 5 scene: titolo → concetto → contenuto → sintesi → aggancio alla lezione successiva.
- Easing: entrate `cubic-bezier(0.22, 1, 0.36, 1)`, tra scene `cubic-bezier(0.4, 0, 0.2, 1)`, sfalsamento 120–150 ms, la scena successiva parte circa 0,3 s prima della fine della precedente. Sfondo e pattern fermi.
- Colori dell'app: smeraldo `#1F4037` → `#0B1C17`, oro `#DAA520` / `#FFD700`, bagliore `#FFE355`, testo `#95D5B2` e `#DFC298`. Colori delle regole in `src/styles/_variables.scss` (`$tajweed-rules`); per il madd il mockup usa `#8EC5FF` e `#4D9DE0` (nuovi).
- L'app è bloccata in orizzontale (`PlatformService` → `ScreenOrientation.lock('landscape')`): tutte le schermate e i video sono landscape, 16:9.
- Il testo arabo si genera in codice, non con generatori video: questi sbagliano le lettere. Google Flow o ChatGPT servono solo per scene "cinematiche" senza testo (sfondi, sezioni anatomiche); Yassin li produce su richiesta.
- Ogni lezione nuova ha un cursore dorato stile Simply Piano che scorre da destra a sinistra sulle parole, e barre "nota tenuta" che si riempiono una haraka per battito.

## Decisioni precedenti che vincolano il lavoro

Dal branch `docs/knowledge-base` (le chat da marzo 2025 a luglio 2026):

- Privacy policy pubblicata: l'audio è elaborato e salvato solo sul telefono. Mandare la recitazione a un server (Quran Muaalem) richiede di aggiornare la policy e chiedere il consenso (OP-20).
- AI: approccio ibrido, iniziare dal madd (durata). Coincide con il "livello 1" della proposta.
- Curriculum: tre schemi in concorrenza, quello ufficiale non è deciso (OP-05). ID lezione stabili `U#.L#`.
- Il voiceover arabo lo registra Yassin. In alternativa si può generare con un TTS (vedi sotto).
- Urgente, a parte: la chiave di firma Android è tracciata nel repo pubblico (OP-01).

## Prossimi passi

1. Yassin guarda la lezione 1 e dà il suo parere su ritmo, stile e quantità di testo.
2. Voiceover: registrarlo, oppure generarlo da `voiceover.md` con un TTS arabo, e sincronizzarlo con la timeline (`CAPS` in `index.html`).
3. Far controllare la vocalizzazione e la semplificazione حقه = كيف, مستحقه = كم (pensata per i principianti) da un insegnante.
4. Decidere il formato finale delle lezioni nell'app: pagina HTML animata dentro un nuovo componente `animated-lesson` (leggera, offline) oppure export MP4. La lezione è guidata da un unico orologio (`window.__lesson.seek(t)`), quindi si può registrare fotogramma per fotogramma con Playwright.
5. Poi le lezioni successive, una alla volta, e la schermata di pratica (ordine di costruzione in [proposal.md](proposal.md)).
