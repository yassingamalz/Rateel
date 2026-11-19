# 03. Strategie

## Contenuto didattico

Una lezione insegna un solo concetto e dura 15–45 secondi. Il pubblico vuole capire in fretta, quindi niente introduzioni lunghe e pochissimo testo sullo schermo; i dettagli vanno nelle lezioni successive. Fonti: [Kurzgesagt's Minimalist Animation Style](https://claude.ai/chat/c4bd4731-0cfa-40c2-bc82-1e0af24b9a69), brief [U3.L1](lessons/U3.L1-sifat-overview.md) note di produzione.

Il libro *Al-Tajwīd Al-Muṣawwar* è la spina dorsale. Si lavora a blocchi di pagine: si rasterizzano le pagine, si leggono, e ogni capitolo diventa un'unità con le sue micro-lezioni. Le regole in cui Ḥafṣ diverge da altre letture vanno segnalate esplicitamente nel brief. Fonte: [Structured lesson for pages 231-256](https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba).

L'unità sulle regole di nūn e mīm (النون والميم) è il cuore dell'app e il terreno più ricco per le animazioni. Fonte: [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011).

Ogni unità ha un motivo visivo ricorrente che lega le lezioni: la "fusione" di due carte-lettera per l'idghām, luna/sole per qamariyya/shamsiyya. Fonte: [Structured lesson for pages 231-256](https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba).

Le lezioni "panoramica" riusano lo stesso schema a 5 scene; le lezioni su una singola coppia sostituiscono la scena 4 con la coppia, le sue lettere e un esempio dal Corano. Fonte: brief [U3.L1](lessons/U3.L1-sifat-overview.md).

## Produzione con l'AI

Le immagini si generano senza testo; le etichette arabe si aggiungono in post-produzione, perché i generatori sbagliano l'arabo. Fonte: [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011) (sintesi della chat).

Per i video lunghi: key frame generati con l'AI, poi interpolazione o After Effects. Fonte: [Journey-Inspired Style](https://claude.ai/chat/9876fbd3-0e6b-4e52-bb1f-50f170e95bd2).

I prompt si adattano a ogni strumento: per Nano Banana si tolgono i riferimenti che il servizio potrebbe bloccare (la figura del Profeta) mantenendo lo stile. Fonte: [Tajweed Arabic lesson prompt](https://claude.ai/chat/df05070c-d91e-4bec-96a0-70d885707dec).

## UX e gamification

L'app deve sembrare un gioco: medaglie, monete, badge come carte di personaggi, particelle, bagliori. Resta però coerente con lo stile islamico dell'app (stessi colori, pattern, nomi islamici). Fonti: le chat di aprile 2025 sulla gamification, ad es. [Gamifying the Leaderboard](https://claude.ai/chat/9131c592-7598-4797-a5ca-6e7c1fc19284) e [Gamify Daily Challenges](https://claude.ai/chat/fc2ef8cd-efc6-4720-9630-c621976e6169).

Layout pensato per il telefono in orizzontale: niente scroll della pagina, al massimo una lista che scorre; caroselli e swipe RTL al posto dello scroll verticale. Fonte: [Implementing Achievements Page](https://claude.ai/chat/1fd51d18-1f0b-43f1-8ffb-c8f217d593d5).

La gamification passa da servizi centralizzati (`GamificationService`, `DailyChallengesService`); i componenti leggono da lì. Fonte: [Gamification Components in Tajweed App](https://claude.ai/chat/11aab0a3-6984-448e-b976-d59069ae8d7e).

## Metodo di lavoro sul codice

Si lavora una parte alla volta ("part per part"); si chiede prima il piano, poi il codice; si conserva tutto lo stile esistente che Yassin apprezza e si cambia solo il punto indicato. Nei refactor il componente vecchio resta nel codebase finché i nuovi non sono verificati. Fonti: [Customizing Achievement Details Modal](https://claude.ai/chat/6e623470-b618-4d32-ac81-6f9cd7893e3a), [Verifying Modular Components](https://claude.ai/chat/01cd7af5-74ae-4ac8-9684-4b11614545d5).

## Riconoscimento della recitazione

Partire dall'approccio ibrido (regole acustiche + modelli pre-addestrati, in parte nel browser) e iniziare dalla regola più facile da misurare, il madd (durata). Passare a modelli addestrati su misura solo con 100+ ore di audio annotato. Il server serve solo per i casi complessi, così l'app funziona anche offline. Fonti: [Automating Tajweed Rule Verification](https://claude.ai/chat/3e4ba75a-1af1-4e05-ac0f-cda917a012db) (raccomandazione di Claude) e [sources/ai-recognition-roadmap.md](sources/ai-recognition-roadmap.md) sezione 12. È una raccomandazione: la scelta finale fra ibrido e custom è ancora aperta.

## Go-to-market

- Google Play prima, iOS dopo. Fonte: [Publishing to Google Play](https://claude.ai/chat/aedc6338-9a43-4620-9767-e11705e021a8).
- Presentazione video su YouTube con voiceover arabo per attirare partner e investitori. Fonte: [Professional Arabic Voiceover](https://claude.ai/chat/358b5a49-4820-4950-a67a-05c19e6df870).
- Un sito "Rateel Academy" bilingue con percorsi, insegnanti dal vivo, certificati, pacchetti di prezzo, e l'app in vetrina, sul modello delle accademie citate da Yassin ("zadul muslimito ecc"). Fonte: [Rateel Academy website](https://claude.ai/chat/bb025c49-a2eb-4996-adb4-3e470efcbb84).
