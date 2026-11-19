# 05. Punti aperti

## Urgente

| # | Punto | Dettaglio | Fonte |
|---|-------|-----------|-------|
| OP-01 | Chiave di firma Android nel repository | `rateel-key.keystore`, `android/rateel-key.keystore` e `android/keystore.properties` sono tracciati da git anche se elencati in `.gitignore` (sono stati aggiunti prima della regola). Il repo GitHub è pubblico (API GitHub, `private: false`, 2026-11-19), quindi chiave e password sono già esposte. Va tolta dal tracking con `git rm --cached`, ripulita dalla history, e va chiesto il reset della upload key su Play Console | `git ls-files` su master e API GitHub, 2026-11-19 |
| OP-02 | Trascrizioni integrali delle chat | Su questo branch ci sono sintesi e link; il testo completo va ricavato dall'export di claude.ai con `tools/claude_export_to_md.py` prima di lasciare la piattaforma | [README](README.md) |
| OP-03 | Brief non recuperati per intero | I brief di U1.L2 e della serie idghām / lām al-taʿrīf (8 lezioni) e i prompt ChatGPT per U1.L2 sono solo nelle chat. Salvarli dall'export | [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011), [Structured lesson for pages 231-256](https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba) |

## Curriculum

| # | Punto | Dettaglio | Fonte |
|---|-------|-----------|-------|
| OP-04 | Due numerazioni in conflitto | Nella lista a 13 unità U6 è il madd e U7 sono vocali e sukūn; nella chat delle pp. 231–256 le stesse sigle U6/U7 indicano idghām dei due incontri di lettere e lām al-taʿrīf. Serve una numerazione unica prima di usare gli ID come nomi file | [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011), [Structured lesson for pages 231-256](https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba) |
| OP-05 | Quale struttura è quella ufficiale | Esistono tre schemi: 13 unità / ~60 lezioni dal libro, 12 corsi per argomento, e la fusione a 3 livelli con 29 unità. Nessuna chat dice quale entra nell'app | [06-curriculum.md](06-curriculum.md) |
| OP-06 | Granularità | Claude ha diviso makhārij e madd in una lezione per punto; ha chiesto se tenerle più grosse o più fini. Nessuna risposta | [Lesson structure planning](https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011) turno 1 |
| OP-07 | Scalare la produzione dei brief | Come produrre in modo sistematico i brief per ~60 lezioni | memoria del progetto (overview) |
| OP-08 | Revisione religiosa dei contenuti | I testi coranici e le regole Ḥafṣ/Shāṭibiyyah generati con l'AI non risultano rivisti da un docente qualificato | nessuna fonte: non emerge in nessuna chat |

## Video e design

| # | Punto | Dettaglio | Fonte |
|---|-------|-----------|-------|
| OP-09 | Video introduttivo fermo al secondo frame | Primo frame generato, prompt del secondo pronto, poi stop | [Journey-Inspired Style](https://claude.ai/chat/9876fbd3-0e6b-4e52-bb1f-50f170e95bd2) |
| OP-10 | Raffigurare il Profeta | Il primo prompt mostra il Profeta di spalle senza volto; per Nano Banana il riferimento è stato tolto. Va deciso se e come rappresentarlo | [Journey-Inspired Style](https://claude.ai/chat/9876fbd3-0e6b-4e52-bb1f-50f170e95bd2), [Tajweed Arabic lesson prompt](https://claude.ai/chat/df05070c-d91e-4bec-96a0-70d885707dec) |
| OP-11 | Strumento di animazione | Valutati After Effects, Canva, CapCut, Runway, Kaiber, DaVinci Fusion; Photoshop scartato. Non c'è una scelta finale | [Minimalist Illustration Animation Tools](https://claude.ai/chat/04da8065-eeda-459b-8e66-fdcc16a5a4ca) |
| OP-12 | Logo definitivo | C'è il prompt per ChatGPT, non risulta un logo scelto | [Tajweed Learning App "Rateel"](https://claude.ai/chat/2e255beb-2748-4b41-86fa-5ceae2cad9d8) |

## App

| # | Punto | Dettaglio | Fonte |
|---|-------|-----------|-------|
| OP-13 | Pubblicazione in produzione | L'app è passata in closed testing; la release pubblica su Play Store non risulta fatta | [Publishing to Google Play](https://claude.ai/chat/aedc6338-9a43-4620-9767-e11705e021a8) |
| OP-14 | Nome nel listing | Nelle chat compaiono sia "Rattil" (package `com.novavista.rattil`) sia "Rateel". Va scelta una grafia per store, sito e materiali | [Publishing to Google Play](https://claude.ai/chat/aedc6338-9a43-4620-9767-e11705e021a8) |
| OP-15 | Dati reali per la gamification | Leaderboard e achievements usano utenti mock; servono backend, account, amici e regione per i filtri | [Islamic-Inspired Leaderboard](https://claude.ai/chat/a83812b7-6509-49af-bf19-27a16c37c1f8) |
| OP-16 | Asset mancanti richiesti dal codice | `assets/badges/[type]_[status].png`, `assets/images/coin-icon.png`, `islamic-ornament.png`, medaglie in `assets/images/medals/`, pattern SVG dark/light. Da verificare nel repo | [Implementing Achievements Page](https://claude.ai/chat/1fd51d18-1f0b-43f1-8ffb-c8f217d593d5), [Daily Tajweed Challenges](https://claude.ai/chat/9db9da27-71d7-4c7f-a018-f7c86a1f406b), [Updating Leaderboard Styling](https://claude.ai/chat/481910b3-c9a2-4db2-b0a7-6d8fafb4e8ad) |
| OP-17 | Errore animazioni sfide quotidiane | Claude ha semplificato le animazioni per un errore a runtime; non risulta confermato che sia risolto | [Gamify Daily Challenges](https://claude.ai/chat/fc2ef8cd-efc6-4720-9630-c621976e6169) |
| OP-18 | Refactor della lettura | Dopo tre tentativi di estrazione dei componenti della reading lesson (stili persi), non risulta un esito finale | [Modular Reading Lesson Component Refactor](https://claude.ai/chat/f75369ed-faea-43fe-a1d0-5d3e21f3d927), [Refactoring Reading Lesson Component](https://claude.ai/chat/58d56b11-ba0a-43f3-9f48-523316dd262f), [Modularizing Reading Lesson](https://claude.ai/chat/38e612d4-d4d9-42dd-847d-7ef9c09b9ae1) |
| OP-19 | Flutter e backend Node.js | Previsti nella descrizione del progetto, nessuna chat ne parla | descrizione del progetto |
| OP-20 | Privacy policy e funzioni future | La policy dice che l'audio non lascia il dispositivo; l'analisi lato server prevista nella roadmap AI la contraddirebbe. Va aggiornata prima di attivare il server | [Privacy Policy](https://claude.ai/chat/382f9a1b-ff2b-4433-bae0-e049e08390ca), [sources/ai-recognition-roadmap.md](sources/ai-recognition-roadmap.md) sez. 11 |

## AI

| # | Punto | Dettaglio | Fonte |
|---|-------|-----------|-------|
| OP-21 | Ibrido o modello su misura | La roadmap chiede di scegliere architettura, tempi e risorse | [sources/ai-recognition-roadmap.md](sources/ai-recognition-roadmap.md) sez. 12 |
| OP-22 | Dataset | Fare un audit della quantità e qualità delle registrazioni disponibili e della loro annotazione | [sources/ai-recognition-roadmap.md](sources/ai-recognition-roadmap.md) sez. 12 |
| OP-23 | Costi | Stime di 30–50K$ (ibrido) o 80–120K$ (custom), mai validate | [sources/ai-recognition-roadmap.md](sources/ai-recognition-roadmap.md) sez. 9 |
