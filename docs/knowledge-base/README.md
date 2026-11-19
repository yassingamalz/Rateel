# Rateel (رَتِّلِ): knowledge base del progetto

Questa cartella raccoglie tutto quello che è stato deciso, pensato e lasciato aperto nelle 55 chat del progetto "tajweed" su claude.ai (da marzo 2025 a luglio 2026), più il documento di progetto sulla roadmap AI. Serve per portare il progetto su un altro cloud senza perdere contesto.

Ogni voce riporta la fonte: il link alla chat da cui viene, o il file di progetto. Dove una cosa è stata proposta da Claude e non confermata da Yassin, è scritto "proposta" e non "decisione".

Stato della migrazione, cosa manca e cosa chiedere: [MIGRATION-STATUS.md](MIGRATION-STATUS.md).

## File

| File | Contenuto |
|------|-----------|
| [01-overview.md](01-overview.md) | Cos'è Rateel, pubblico, stack tecnico, stato attuale |
| [02-decisions.md](02-decisions.md) | Registro delle decisioni prese, con data e fonte |
| [03-strategies.md](03-strategies.md) | Strategie di prodotto, contenuto, UX, AI e go-to-market |
| [04-ideas.md](04-ideas.md) | Idee e backlog non ancora realizzati |
| [05-open-points.md](05-open-points.md) | Punti aperti, domande irrisolte, rischi |
| [06-curriculum.md](06-curriculum.md) | Struttura del curriculum (13 unità / ~60 lezioni, schema a 12 corsi, fusione a 29 unità) |
| [07-content-production.md](07-content-production.md) | Formato dei brief video, design system, strumenti AI, lezioni apprese |
| [08-ai-recognition.md](08-ai-recognition.md) | Sintesi della strategia di riconoscimento automatico del tajweed |
| [09-app-engineering-log.md](09-app-engineering-log.md) | Storico del lavoro sul codice Angular, componente per componente |
| [10-marketing-publishing.md](10-marketing-publishing.md) | Play Store, privacy policy, presentazione, sito Academy |
| [11-video-style-guide.md](11-video-style-guide.md) | Stile dei video: cosa vuole Yassin, principi di animazione, pipeline |
| [lessons/PRODUCTION-PLAN.md](lessons/PRODUCTION-PLAN.md) | Tutte le 66 lezioni del curriculum con lo stato del brief |
| [videos/intro-journey-storyboard.md](videos/intro-journey-storyboard.md) | Storyboard e prompt del video introduttivo stile Journey |
| [chats/INDEX.md](chats/INDEX.md) | Elenco delle 55 chat con data, link e sintesi |
| [lessons/animations/](lessons/animations/) | Codice delle lezioni animate in Claude Design (noon mushaddada, ṣifāt, organi, idghām) |
| [lessons/](lessons/) | Brief completi: U1.L2, U3.L1, serie idghām / lām al-taʿrīf (8 lezioni), piano della serie nūn e mīm mushaddada |
| [sources/](sources/) | Documenti di progetto copiati da claude.ai |

## Trascrizioni complete delle chat

Dall'export di claude.ai del 19/11/2026: le 55 chat del progetto sono in [chats/full/](chats/full/), un file per chat con tutti i messaggi, gli artefatti e il testo estratto degli allegati (le immagini e i file caricati non sono nell'export). Le due chat di Claude Design in cui sono state costruite le lezioni animate sono in [chats/design/](chats/design/), e i file ricostruiti in [lessons/animations/](lessons/animations/).

### Come rigenerarle

Da un nuovo export:

1. claude.ai → Settings → Privacy → Export data. Arriva una mail con uno zip.
2. Estrai `conversations.json`.
3. Lancia `python3 tools/claude_export_to_md.py conversations.json docs/knowledge-base/chats/full --ids docs/knowledge-base/chats/ids.txt` (il file `ids.txt` contiene gli UUID delle 55 chat del progetto)
4. Lo script crea un file MD per ogni chat del progetto, con tutti i messaggi in ordine.

Per le chat di Claude Design: `python3 tools/design_export_to_md.py <design_chats> docs/knowledge-base/chats/design docs/knowledge-base/lessons/animations --project "Animation for non-Mushdada taskeel"`.
