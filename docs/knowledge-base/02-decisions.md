# 02. Registro delle decisioni

Solo ciò che Yassin ha chiesto, scelto o confermato. Le proposte di Claude non accettate esplicitamente stanno in [04-ideas.md](04-ideas.md).

## Prodotto e contenuti

| Data | Decisione | Fonte |
|------|-----------|-------|
| 2025-03 | Nome dell'app: Rateel (رَتِّلِ), brand NovaVista | [Privacy Policy](https://claude.ai/chat/382f9a1b-ff2b-4433-bae0-e049e08390ca), [Logo prompt](https://claude.ai/chat/2e255beb-2748-4b41-86fa-5ceae2cad9d8) |
| 2025-03 | Palette: smeraldo `#1F4037`→`#0B1C17`, oro `#DAA520`/`#FFD700`, testo verde chiaro `#95D5B2` | [Logo prompt](https://claude.ai/chat/2e255beb-2748-4b41-86fa-5ceae2cad9d8), [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011) |
| 2025-03 | Video in stile minimalista dove gli oggetti si trasformano invece di sparire | [Minimalist Illustration Animation Tools](https://claude.ai/chat/04da8065-eeda-459b-8e66-fdcc16a5a4ca) |
| 2025-03 | Video introduttivo sulla rivelazione del Corano nello stile del videogioco *Journey*, con key frame generati dall'AI e animati dopo | [Journey-Inspired Style](https://claude.ai/chat/9876fbd3-0e6b-4e52-bb1f-50f170e95bd2) |
| 2025-03 | Nella narrazione: nessun anno (niente "610 d.C."), lessico islamico autentico | [Journey-Inspired Style](https://claude.ai/chat/9876fbd3-0e6b-4e52-bb1f-50f170e95bd2) |
| 2026-01 | Da un unico video lungo a una serie di micro-lezioni da 15–45 s | [Kurzgesagt's Minimalist Animation Style](https://claude.ai/chat/c4bd4731-0cfa-40c2-bc82-1e0af24b9a69) |
| 2026-01 | Animazione "fusione stile Yu-Gi-Oh" per lettera + shadda = lettera mushaddada | [Kurzgesagt's Minimalist Animation Style](https://claude.ai/chat/c4bd4731-0cfa-40c2-bc82-1e0af24b9a69) |
| 2026-06 | Fonte del curriculum: *Al-Tajwīd Al-Muṣawwar* parti 1 e 2 (584 pagine) | [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011) |
| 2026-06 | ID lezione stabili `U#.L#`, usati come chiave nell'app e come nome file | [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011) |
| 2026-06 | Contenuti delle lezioni generati con Claude Design; Yassin ha già lo stile, chiede contenuto e istruzioni di animazione | [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011) turno 4 |
| 2026-06 | U1.L2 (organi dell'articolazione) con illustrazioni fotografiche, non vettoriali | [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011) turno 6 |
| 2026-06 | Lezioni prodotte leggendo il libro per intervalli di pagine (es. pp. stampate 229–254) | [Structured lesson for pages 231-256](https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba) |
| 2026-07 | Fondere lo schema a 12 corsi con i 3 livelli del Mumtaz Institute in un unico curriculum | [Comprehensive Tajweed Curriculum Structure](https://claude.ai/chat/1e125dd1-64c7-4d61-9578-4ac6636b634b) |

## UI e codice

| Data | Decisione | Fonte |
|------|-----------|-------|
| 2025-03 | Spezzare la lezione interattiva in componenti, senza esagerare: container dei versi, controlli di registrazione, feedback overlay, schermata di completamento, help tips. Progress bar resta nel componente padre | [Refactoring Interactive Lesson](https://claude.ai/chat/5b85c39e-0820-42b7-a44b-89d4bdbaf147) |
| 2025-03 | Durante i refactor tenere il componente originale nel codebase per confrontarlo prima del commit | [Verifying Modular Components](https://claude.ai/chat/01cd7af5-74ae-4ac8-9684-4b11614545d5) |
| 2025-03 | Temi via `:host-context(.theme-light)` / `.theme-dark`, variabili SCSS da root, come nella lezione interattiva | [Modularizing Reading Lesson Component](https://claude.ai/chat/38e612d4-d4d9-42dd-847d-7ef9c09b9ae1) |
| 2025-03 | Numeri dei versi in cifre arabe (١، ٢، ٣), decorazioni islamiche sulle card, niente legenda per ora | [Enhancing Modular Lesson Feedback](https://claude.ai/chat/2edf6394-1843-4a32-a110-da7d9744eb9b) |
| 2025-03 | Decorazione islamica: SVG da `assets`, due file (dark/light), ancorato a sinistra, oscillazione a pendolo | [Adaptive Islamic SVG](https://claude.ai/chat/2e77222a-a3ad-47f9-ad3e-f86242986e6e), [Pendulum animation](https://claude.ai/chat/fcdef8b7-a92b-4c4b-81c1-5e7519b57033) |
| 2025-03 | Pattern `islamic-pattern-1.svg` come sfondo di lista lezioni e lista unità, ruotato e ripetuto | [Adding Islamic Pattern](https://claude.ai/chat/90158d6b-e3f1-45ee-93c3-1beb37f1ecdf) |
| 2025-03 | Lista unità: ripristinare la posizione di scroll come nella lista lezioni (issue GitHub #12) | [Preserving Scroll Position](https://claude.ai/chat/754917af-ebd5-4eff-b42c-f0cd05d69578) |
| 2025-04 | Leaderboard: medaglie olimpiche numerate per i primi tre, monete del colore della posizione senza animazione, header a nastro dorato | [Updating Leaderboard Styling](https://claude.ai/chat/481910b3-c9a2-4db2-b0a7-6d8fafb4e8ad), [Optimizing Leaderboard Coin Styling](https://claude.ai/chat/01fb180e-1416-401c-8f5a-ca70d9f4cc40) |
| 2025-04 | Leaderboard: niente sezione separata "posizione attuale"; l'utente compare come ultima riga visibile finché non si arriva alla sua posizione reale | [Customizing Leaderboard](https://claude.ai/chat/a3f68cbc-31c0-44e1-9ad9-0b1f5d2a8b6c) |
| 2025-04 | Testo arcuato sul nastro: niente split per lettera, perché le lettere arabe devono restare legate; si usa un arco SVG | [Improving Leaderboard Ribbon](https://claude.ai/chat/aae99337-66c3-4c5d-9dcd-b30b2bfacbd7) |
| 2025-04 | "تحديات التجويد اليومية" è una sfida a domande quotidiane, distinta dalla ricompensa quotidiana, che sarà un'altra funzione | [Gamify Daily Challenges](https://claude.ai/chat/fc2ef8cd-efc6-4720-9630-c621976e6169) |
| 2025-04 | Achievements: non dividere troppo i componenti; non cancellare i componenti condivisi in `features/gamification/components` | [Modularize Achievements Component](https://claude.ai/chat/2a4ebee2-0fd6-4c40-941c-f286ef7c7a69) |
| 2025-04 | Badge PNG personalizzati, grandi; quelli bloccati in scala di grigi con lucchetto | [Modernize Badges Collection UI](https://claude.ai/chat/9936b589-3da3-46b0-b6e5-1003748de22f) |
| 2025-04 | Modale dettaglio achievement come carta da gioco, senza scroll, con sfondo sfocato come il modale di feedback; badge che "esce" dal modale in 3D | [Vibrant Game-Style Badge Details Modal](https://claude.ai/chat/791de383-950c-4efa-a5b7-37e774180482), [Floating 3D Badge](https://claude.ai/chat/e979b1cc-1ed6-4f05-9740-4da2ed4ab801) |
| 2025-04 | Collezione badge: a destra carosello per cambiare badge, a sinistra la descrizione, rispettando le tab esterne | [Gamifying App Badges](https://claude.ai/chat/6a794279-d109-4ec3-aa40-2655a8e5b92c) |
| sempre | Ogni modifica di codice va con il suo commit message; prima di implementare cambi grossi Claude spiega il piano e Yassin conferma | molte chat, es. [Improving Leaderboard Ribbon](https://claude.ai/chat/aae99337-66c3-4c5d-9dcd-b30b2bfacbd7) |

## Distribuzione

| Data | Decisione | Fonte |
|------|-----------|-------|
| 2025-03 | Pubblicazione su Google Play, categoria Education, lingua di default araba | [Publishing to Google Play](https://claude.ai/chat/aedc6338-9a43-4620-9767-e11705e021a8) |
| 2025-03 | Privacy policy: registrazioni audio elaborate e salvate solo in locale, nessun upload | [Privacy Policy](https://claude.ai/chat/382f9a1b-ff2b-4433-bae0-e049e08390ca) |
| 2025-04 | Presentazione su YouTube per trovare partner e investitori | [Showcase Your App with Professional Arabic Voiceover](https://claude.ai/chat/358b5a49-4820-4950-a67a-05c19e6df870) |
