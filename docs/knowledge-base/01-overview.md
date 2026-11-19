# 01. Overview

## Cos'è

Rateel (رَتِّلِ, "recita con ritmo misurato", da Al-Muzzammil 4) è un'app per imparare le regole del tajweed, cioè la recitazione corretta del Corano. Segue la lettura Ḥafṣ ʿan ʿĀṣim nella trasmissione della Shāṭibiyyah. Il marchio è di NovaVista (contatto pubblico: novavista.solutions@gmail.com).

Fonti: descrizione del progetto claude.ai; chat [Structured lesson for pages 231-256](https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba); chat [Privacy Policy](https://claude.ai/chat/382f9a1b-ff2b-4433-bae0-e049e08390ca).

## Pubblico e principi

- Interfaccia araba, RTL; altre lingue per non arabofoni previste più avanti (descrizione del progetto).
- L'app si usa soprattutto su telefono in orizzontale, senza scroll verticale della pagina; lo swipe da destra a sinistra è accettato. Il vincolo ritorna in quasi tutte le chat di UI (es. [Gamifying the Achievements Component](https://claude.ai/chat/41025190-4351-4133-88ab-c5b1ddc1e544)).
- Il pubblico preferisce contenuti brevi e veloci alle introduzioni tradizionali lunghe: da qui le micro-lezioni video da 15–45 s ([Kurzgesagt's Minimalist Animation Style](https://claude.ai/chat/c4bd4731-0cfa-40c2-bc82-1e0af24b9a69)).
- Stile visivo islamico: verde smeraldo e oro, pattern geometrici.

## Stack tecnico

Dal README del repository e dalla chat [Tajweed Learning App "Rateel"](https://claude.ai/chat/2e255beb-2748-4b41-86fa-5ceae2cad9d8):

- Angular 19, moduli non standalone (`--standalone=false`)
- Capacitor 6 per Android e iOS; package `com.novavista.rattil` (chat [Publishing to Google Play](https://claude.ai/chat/aedc6338-9a43-4620-9767-e11705e021a8))
- SCSS con variabili e mixin in root (`vars.$colors`, `vars.$mushaf-colors`), temi `theme-dark` / `theme-light`
- RxJS, `ChangeDetectionStrategy.OnPush`
- Dati delle lezioni in JSON sotto `src/assets/data/`
- La descrizione del progetto prevede un backend Node.js e una futura conversione in Flutter (mappatura 1:1 componente→widget, BLoC). Nel codice attuale il backend non c'è.

## Struttura dell'app

Livelli → corsi → unità → lezioni. Tipi di lezione: video, lettura (reading), interattiva con registrazione, ascolto, valutazione. Modulo di gamification con leaderboard, achievements/badge, punti, sfide quotidiane. Dettagli in [09-app-engineering-log.md](09-app-engineering-log.md).

## Stato (ultima chat: luglio 2026)

- App Android passata in closed testing su Google Play (marzo 2025); la produzione pubblica non risulta confermata in nessuna chat.
- Modulo gamification completo nella UI con dati mock (aprile 2025).
- Curriculum definito: 13 unità / 66 micro-lezioni dal libro *Al-Tajwīd Al-Muṣawwar*, più uno schema a 3 livelli e 29 unità (giugno–luglio 2026).
- Brief video pronti per U1.L2, U3.L1 e per le unità U6–U7 (idghām, lām al-taʿrīf) dalla numerazione del libro.
- Video introduttivo in stile *Journey*: primo frame generato, il resto da fare.
- Riconoscimento automatico del tajweed: solo roadmap e codice di training proposto, niente in produzione.
