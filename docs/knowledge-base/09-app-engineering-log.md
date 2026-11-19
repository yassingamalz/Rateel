# 09. Storico del lavoro sul codice

In ordine cronologico. Il codice completo prodotto in ogni chat è solo nella chat (o già nel repo, se Yassin l'ha committato). L'ultimo commit su master al 2026-11-19 è `718c0d1 enhance(achievement-modal): Improve badge 3D effect with stronger depth perception`.

## Convenzioni

- Commit in stile Conventional Commits: `feat(scope):`, `fix(scope):`, `refactor(scope):`, `enhance(scope):` (dal log del repo e dalle chat).
- Componenti generati con `ng g c ... --standalone=false`, spesso con `--change-detection=OnPush`.
- Percorsi: `src/app/features/gamification/...`, `src/app/shared/components/...`.
- Tema: classi `theme-dark` / `theme-light` sul contenitore, `:host-context(...)` nei figli, variabili da `variables` (`vars.$colors`, `vars.$mushaf-colors`, `vars.$spacing`) e `mixins`.

## Marzo 2025: lezioni

| Data | Lavoro | Fonte |
|------|--------|-------|
| 03-15 | Errore TS `void` non assegnabile a `Event` su `recordingToggle`: soluzione con `EventEmitter<Event>` e controllo `instanceof Event` | [Resolving TypeScript Type Error](https://claude.ai/chat/e25e095c-4e04-4a20-959e-dd5583e6e06a) |
| 03-15 | Lezione interattiva divisa in `VersesContainer`, `RecordingControls`, `FeedbackOverlay`, `CompletionScreen`, `HelpTips` | [Refactoring Interactive Lesson](https://claude.ai/chat/5b85c39e-0820-42b7-a44b-89d4bdbaf147) |
| 03-15 | Verifica componente per componente contro l'originale; stili del container e dei modali feedback/completamento persi e recuperati | [Verifying Modular Components](https://claude.ai/chat/01cd7af5-74ae-4ac8-9684-4b11614545d5) |
| 03-16 | Estrazione di verse card e container mantenendo la logica di drag; centratura progressiva (100 px + 30 px per verso), indici globali delle parole, accelerazione hardware | [Modularizing Interactive Lesson Components](https://claude.ai/chat/8ecfe7e4-b685-4c16-8f08-2a6c511d9a25) |
| 03-16 | Verse card in stile islamico: cifre arabe, angoli e foglie decorative, parole che si "accendono" mentre si leggono | [Enhancing Modular Lesson Feedback](https://claude.ai/chat/2edf6394-1843-4a32-a110-da7d9744eb9b) |
| 03-17 | SVG islamico nello sfondo della lezione interattiva, versioni dark/light; fix visibilità in light mode, posizione a sinistra, animazione a pendolo | [Adaptive Islamic SVG](https://claude.ai/chat/2e77222a-a3ad-47f9-ad3e-f86242986e6e), [Fixing Islamic Decoration](https://claude.ai/chat/96516fc2-d735-4b0c-a1fc-dade07e76a69), [Pendulum](https://claude.ai/chat/fcdef8b7-a92b-4c4b-81c1-5e7519b57033) |
| 03-17 | Pattern islamico ruotato e ripetuto nello sfondo di lista lezioni e lista unità | [Adding Islamic Pattern](https://claude.ai/chat/90158d6b-e3f1-45ee-93c3-1beb37f1ecdf) |
| 03-17 | Reading lesson divisa in `ReadingControlsBar`, `VerseCard`, `TajweedRulesPanel`, `NavigationDots`; tre tentativi per recuperare gli stili | [Modularizing Reading Lesson Components](https://claude.ai/chat/3e36b3cd-53ae-440b-ba79-bf293d2d22c3), [Modular Reading Lesson Refactor](https://claude.ai/chat/f75369ed-faea-43fe-a1d0-5d3e21f3d927), [Refactoring Reading Lesson](https://claude.ai/chat/58d56b11-ba0a-43f3-9f48-523316dd262f), [Consistent Theming](https://claude.ai/chat/38e612d4-d4d9-42dd-847d-7ef9c09b9ae1) |
| 03-18 | Lista unità che riapre sull'ultima unità completata o sulla prossima disponibile, con scroll animato (issue #12) | [Preserving Scroll Position](https://claude.ai/chat/754917af-ebd5-4eff-b42c-f0cd05d69578) |
| 03-19 | Build Android con `npm run build:android`, firma, App Bundle, closed testing | [Publishing to Google Play](https://claude.ai/chat/aedc6338-9a43-4620-9767-e11705e021a8) |

## Aprile 2025: gamification

| Data | Lavoro | Fonte |
|------|--------|-------|
| 04-18 | Leaderboard in stile islamico con utenti mock, adattata all'orizzontale senza scroll | [Islamic-Inspired Leaderboard](https://claude.ai/chat/a83812b7-6509-49af-bf19-27a16c37c1f8) |
| 04-19 | Leaderboard più "da gioco": avatar PNG, servizio centralizzato, header a nastro, filtri الكل/الأصدقاء/المنطقة | [Gamifying the Leaderboard](https://claude.ai/chat/9131c592-7598-4797-a5ca-6e7c1fc19284), [Enhancing Leaderboard Styling](https://claude.ai/chat/0588602c-8616-400f-9784-c8dfe47b5875) |
| 04-19/20 | Medaglie olimpiche con nastro e numero, monete Font Awesome, poi medaglie PNG in `assets/images/medals/` | [Updating Leaderboard Styling](https://claude.ai/chat/481910b3-c9a2-4db2-b0a7-6d8fafb4e8ad), [Coin Styling](https://claude.ai/chat/01fb180e-1416-401c-8f5a-ca70d9f4cc40) |
| 04-20/21 | Posizione dell'utente dentro la tabella, sticky in basso finché non si arriva alla riga reale; sfondo verde pieno `#2E7D32`; titolo su arco SVG | [Customizing Leaderboard](https://claude.ai/chat/a3f68cbc-31c0-44e1-9ad9-0b1f5d2a8b6c), [Improving Leaderboard Ribbon](https://claude.ai/chat/aae99337-66c3-4c5d-9dcd-b30b2bfacbd7) |
| 04-21 | Componente e servizio `DailyChallenges` (percorso a nodi, streak, bonus finale), poi restyling come "رحلة التجويد اليومية" e semplificazione delle animazioni per un errore | [Daily Tajweed Challenges](https://claude.ai/chat/9db9da27-71d7-4c7f-a018-f7c86a1f406b), [Gamify Daily Challenges](https://claude.ai/chat/fc2ef8cd-efc6-4720-9630-c621976e6169) |
| 04-22 | Analisi del modulo gamification (Leaderboard, AchievementBadge, PointsCard, UserScore, DailyChallenges, `GamificationService`); proposta della pagina Achievements | [Gamification Components](https://claude.ai/chat/11aab0a3-6984-448e-b976-d59069ae8d7e) |
| 04-22 | Pagina Achievements a caroselli, badge in `assets/badges/[type]_[status].png` | [Implementing Achievements Page](https://claude.ai/chat/1fd51d18-1f0b-43f1-8ffb-c8f217d593d5) |
| 04-22 | Divisione della pagina Achievements in sottocomponenti sotto `achievements/components/` | [Modularize Achievements Component](https://claude.ai/chat/2a4ebee2-0fd6-4c40-941c-f286ef7c7a69) |
| 04-23 | Header achievements, tab metalliche con swipe RTL, collezione badge con griglia orizzontale e anello di progresso | [Enhancing Achievements](https://claude.ai/chat/8a59b4fc-6eb8-4653-9b5a-040444e31aa8), [Gamifying the Achievements Component](https://claude.ai/chat/41025190-4351-4133-88ab-c5b1ddc1e544), [Modernize Badges Collection UI](https://claude.ai/chat/9936b589-3da3-46b0-b6e5-1003748de22f) |
| 04-23/25 | Modale dettaglio achievement: sistema modale centralizzato, carta da gioco a due colonne, badge più grande, punti e data come tag, posizione a destra, badge che fluttua fuori dal modale in 3D | [Gamified Achievement Modal](https://claude.ai/chat/afb7e139-a416-473b-990a-3488882c9030), [Vibrant Game-Style Modal](https://claude.ai/chat/791de383-950c-4efa-a5b7-37e774180482), [Customizing Achievement Details Modal](https://claude.ai/chat/6e623470-b618-4d32-ac81-6f9cd7893e3a), [Redesigning Achievement Modal](https://claude.ai/chat/7558dbcc-188e-4e86-95da-75be6032e342), [Optimizing Modal for Mobile](https://claude.ai/chat/fa853e85-1c44-4f5d-9823-1c9add06f254), [Floating 3D Badge](https://claude.ai/chat/e979b1cc-1ed6-4f05-9740-4da2ed4ab801) |
| 04-25 | Collezione badge a due pannelli: carosello a destra, dettagli a sinistra | [Gamifying App Badges](https://claude.ai/chat/6a794279-d109-4ec3-aa40-2655a8e5b92c) |
