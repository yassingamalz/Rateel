# Rateel (رَتِّلِ): knowledge base del progetto

Questa cartella raccoglie tutto quello che è stato deciso, pensato e lasciato aperto nelle 55 chat del progetto "tajweed" su claude.ai (da marzo 2025 a luglio 2026), più il documento di progetto sulla roadmap AI. Serve per portare il progetto su un altro cloud senza perdere contesto.

Ogni voce riporta la fonte: il link alla chat da cui viene, o il file di progetto. Dove una cosa è stata proposta da Claude e non confermata da Yassin, è scritto "proposta" e non "decisione".

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
| [lessons/](lessons/) | Brief completi: U1.L2, U3.L1, serie idghām / lām al-taʿrīf (8 lezioni), piano della serie nūn e mīm mushaddada |
| [sources/](sources/) | Documenti di progetto copiati da claude.ai |

## Trascrizioni complete delle chat

Lo strumento con cui ho letto le chat restituisce pochi turni per volta e tronca i messaggi lunghi (molte chat contengono file SCSS/TS interi), quindi in `chats/` c'è una scheda per chat con sintesi e link, non il testo integrale.

Per avere il testo completo di tutte le chat:

1. claude.ai → Settings → Privacy → Export data. Arriva una mail con uno zip.
2. Estrai `conversations.json`.
3. Lancia `python3 tools/claude_export_to_md.py conversations.json docs/knowledge-base/chats/full --ids docs/knowledge-base/chats/ids.txt` (il file `ids.txt` contiene gli UUID delle 55 chat del progetto)
4. Lo script crea un file MD per ogni chat del progetto, con tutti i messaggi in ordine.

Lo script è in `tools/claude_export_to_md.py` su questo branch.
