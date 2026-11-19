# 11. Guida di stile dei video

Riunisce in un posto solo le regole sparse nelle chat. Le regole tecniche (easing, colori) sono in [07-content-production.md](07-content-production.md); qui c'è il perché e come applicarle.

## Cosa vuole Yassin

- Lo stile di Kurzgesagt: animazione minimalista, illustrazioni piatte, colori vivi, transizioni morbide. Fonte: [Kurzgesagt's Minimalist Animation Style](https://claude.ai/chat/c4bd4731-0cfa-40c2-bc82-1e0af24b9a69), turni 0–2.
- Un flusso unico in cui gli oggetti si trasformano nel successivo invece di sparire. Yassin, turno 26: "yes its exactly what i want the transforming objects not disappearing". Stessa richiesta in [Minimalist Illustration Animation Tools](https://claude.ai/chat/04da8065-eeda-459b-8e66-fdcc16a5a4ca).
- Veloce, senza introduzioni lunghe e classiche (turno 10).
- Testo e lettere che si trasformano, come nei canali che spiegano le lingue: Yassin, turno 30, "It should be more like morphing text and language explaining".
- I colori dell'app, smeraldo e oro.

## Principi di animazione

Dal riepilogo che Claude ha scritto su richiesta di Yassin (chat Kurzgesagt, turno 27):

- C'è sempre qualcosa in movimento sullo schermo.
- L'animazione successiva parte prima che finisca la precedente (circa al 70%; nei brief del 2026 è "0,3 s prima").
- Gli elementi si trasformano, non spariscono.
- Tra le scene si usano forme che "spazzano" lo schermo (rettangoli colorati).
- Easy ease su tutti i keyframe, motion blur, morph delle forme.
- Overshoot (l'elemento supera leggermente la posizione e torna), movimento secondario, anticipazione, follow-through.
- Direzione coerente del movimento: per l'arabo, da destra a sinistra (turno 25).
- Leggeri movimenti di camera anche quando gli oggetti sono fermi.
- Sfondo scuro con particelle e pattern geometrico islamico.
- Clip brevi, 15–30 s per concetto; codifica a colori per regola; timer dei 2 tempi; onde e vibrazioni per i suoni nasali; posizioni di bocca e naso.

## Come è fatta ogni lezione

Cinque scene: titolo → concetto → contenuto principale → sintesi → aggancio alla lezione successiva. Ogni fine lezione prepara la successiva, così una serie si guarda come un unico percorso. Fonti: brief [U3.L1](lessons/U3.L1-sifat-overview.md), [U1.L2](lessons/U1.L2-organs-of-articulation.md), [serie idghām](lessons/BOOK-idgham-lam-tarif.md).

Ogni lezione ha un "filo" visivo che attraversa tutte le scene: la linea d'aria in U1.L2, le onde sonore e i cinque punti d'oro in U3.L1, la fusione delle carte nell'idghām, luna e sole nella lām al-taʿrīf.

## Pipeline di produzione

1. Brief della lezione (testo arabo vocalizzato, voiceover, motion, prompt).
2. Immagini senza testo con ChatGPT o Midjourney, partendo dall'immagine "eroe" e chiedendo le altre "in the same style". Fonte: [U1.L2](lessons/U1.L2-organs-of-articulation.md), prompt ChatGPT.
3. Asset vettoriali (carte-lettera, shadda separata) in Figma o Canva, esportati in PNG trasparente, se non ci sono già. Fonte: chat Kurzgesagt, turno 21.
4. Animazione in After Effects, oppure CapCut / DaVinci Resolve Fusion / Cavalry; Runway o Kaiber per animare immagini statiche.
5. Testo arabo aggiunto come livello, ricontrollando la vocalizzazione.
6. Voiceover registrato a parte. Nella chat Kurzgesagt, turno 4, Yassin dice che al voiceover arabo pensa lui.
7. Anteprima opzionale in Claude Design, che non carica foto esterne: lì si usano segnaposto.

## Canali di riferimento citati

Per il morph generale: TED-Ed, After Skool, Primer, Minute Physics, 3Blue1Brown, CGP Grey. Per il testo che si trasforma: Langfocus, NativLang, RobWords, Name Explain, Crash Course Linguistics. Fonte: chat Kurzgesagt, turni 29 e 31. Video tutorial citato da Yassin: https://www.youtube.com/watch?v=pF--YKCCUMw (turno 22).

## Video introduttivo dell'app

Stile diverso dalle lezioni: quello del videogioco *Journey*. Vedi [videos/intro-journey-storyboard.md](videos/intro-journey-storyboard.md).
