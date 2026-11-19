# Stato della migrazione da claude.ai

Aggiornato il 2026-11-20. Questo file dice cosa è già stato portato fuori dal progetto "tajweed" di claude.ai, cosa manca e cosa chiedere a Yassin se serve. Chi riprende il lavoro, persona o AI, parta da qui.

## Cosa c'è sul branch `docs/knowledge-base`

| Contenuto | Dove | Origine |
|-----------|------|---------|
| Sintesi: decisioni, strategie, idee, punti aperti, curriculum, produzione, AI, codice, marketing, stile video | `docs/knowledge-base/01-…11-*.md` | lettura delle chat, 19/11/2026 |
| Scheda per ognuna delle 55 chat (data, link, sintesi) | `chats/INDEX.md`, `chats/*.md`, `chats/ids.txt` | idem |
| Testo completo delle 55 chat | `chats/full/` | export claude.ai del 19/11/2026, `conversations-000.zip` e `conversations-001.zip` |
| Le 2 chat di Claude Design in cui sono state costruite le lezioni animate | `chats/design/` | export, `design_chats-000.zip`, file `14bf0185…` e `6aff8a8d…` |
| Codice delle lezioni animate, ricostruito dalle chat di Claude Design | `lessons/animations/` | idem |
| Brief completi U1.L2, U3.L1, serie idghām / lām al-taʿrīf, piano della serie nūn e mīm mushaddada, piano di produzione delle 66 lezioni | `lessons/` | chat, verificate sull'export |
| Storyboard del video introduttivo stile *Journey* | `videos/` | chat |
| Roadmap AI (documento del progetto claude.ai) | `sources/ai-recognition-roadmap.md` | documento di progetto, presente anche in `projects-000.zip` |
| Script per rigenerare tutto da un nuovo export | `tools/claude_export_to_md.py`, `tools/design_export_to_md.py`, `tools/chats_catalog.py` | |

Il branch non è unito a master.

## Cosa non c'è e perché

| Cosa | Perché | Come recuperarlo |
|------|--------|------------------|
| File caricati nelle chat: PDF di *Al-Tajwīd Al-Muṣawwar*, screenshot dell'app, PNG dei badge, le tre illustrazioni di U1.L2 (lips, head, head-glow), il PDF delle pp. 231–256 | l'export di claude.ai non include i file originali caricati | chiederli a Yassin; il PDF del libro e gli asset vanno salvati nel nuovo cloud |
| Componenti base di Claude Design (`animations.jsx`, `image-slot.js`) e runtime dei Design Component | copiati dal sistema di Claude Design, non sono nell'export | esportare le lezioni direttamente dal progetto Claude Design "Animation for non-Mushdada taskeel" |
| Ultima modifica alla lezione idghām (più font nel pannello Tweaks) | la chat si è fermata per limite di quota | verificare in Claude Design |
| Ragionamento interno di Claude nelle chat | escluso di proposito dalla conversione | non serve |
| Il resto dell'export: memorie, feedback, artefatti di altri progetti (Quanta, Avio, Lamborghini, Zoom Dental, ecc.), altre chat di Claude Design, chat fuori dal progetto | non riguardano Rateel e il repo è pubblico | restano nello zip dell'export di Yassin |

## Contenuti presenti solo nelle trascrizioni

Sono in `chats/full/` ma non hanno ancora un file dedicato. Se servono, estrarli da lì:

| Contenuto | Chat in `chats/full/` |
|-----------|------------------------|
| Curriculum a 3 livelli e 29 unità (fusione con Mumtaz Institute), tabella di corrispondenza, diagrammi Mermaid | `2026-07-17-1e125dd1-…` |
| Analisi della proposta DeepSeek e codice Python di training, preparazione dataset e test | `2025-03-15-3e4ba75a-…` |
| Adattamento del prompt per Nano Banana | `2026-01-16-df05070c-…` |
| Prompt Midjourney 16:9 e ultimi turni sullo stile | `2026-01-16-c4bd4731-…` |
| Copione "storia" del video introduttivo in arabo | `2025-03-22-37ad5f1c-…`, `2025-03-22-9876fbd3-…` |
| Testi di marketing: titoli e descrizioni arabe delle schermate, voiceover, descrizioni YouTube, slide finale | `2025-04-17-d57e6e83-…`, `2025-04-26-d404cf16-…`, `2025-04-26-358b5a49-…` |
| Privacy policy e versione HTML per Google Sites | `2025-03-19-382f9a1b-…` |
| Passaggi per Google Play | `2025-03-19-aedc6338-…` |
| Codice di UI (leaderboard, achievements, badge, sfide, lezioni) | vedi [09-app-engineering-log.md](09-app-engineering-log.md) |
| Prototipo React del sito Rateel Academy | `2025-05-18-bb025c49-…` |

## Decisioni che spettano a Yassin

1. Chiave di firma Android tracciata nel repo pubblico (OP-01 in [05-open-points.md](05-open-points.md)): toglierla e chiedere il reset della upload key.
2. Le trascrizioni in `chats/full/` contengono il nome di Yassin, percorsi del suo PC e la mail di NovaVista. Il repo è pubblico: decidere se tenerle qui o in un repo privato. Password e chiavi non ci sono (ci sono solo segnaposto come `your_keystore_password`).
3. Se unire il branch a master.
4. Quale dei tre schemi di curriculum adottare e come rinumerare le unità (OP-04, OP-05).

## Prima di chiedere a Yassin

Controllare prima [05-open-points.md](05-open-points.md), [chats/INDEX.md](chats/INDEX.md) e la ricerca testuale in `chats/full/`: quasi tutto quello che è stato detto nelle chat è lì.
