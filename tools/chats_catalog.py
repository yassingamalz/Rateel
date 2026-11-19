"""Catalogo delle chat del progetto claude.ai "tajweed".

Genera docs/knowledge-base/chats/INDEX.md, una scheda per chat e ids.txt.
Uso: python3 tools/chats_catalog.py
"""
from pathlib import Path

# (uuid, data ultimo aggiornamento, titolo, area, sintesi)
CHATS = [
    ("1e125dd1-64c7-4d61-9578-4ac6636b634b", "2026-07-17", "Comprehensive Tajweed Curriculum Structure", "curriculum",
     "Curriculum a 12 corsi per argomento con tabella bilingue, diagramma Mermaid e commit message; poi fusione con i 3 livelli del Mumtaz Institute in 29 unità fino all'Ijāzah."),
    ("56987cb3-59a5-42aa-8bf7-f59da44422ba", "2026-06-27", "Structured lesson for pages 231-256", "contenuti",
     "Lettura delle pp. PDF 231–256 (stampate 229–254) di Al-Tajwīd Al-Muṣawwar rasterizzando le pagine. Due unità, 8 micro-lezioni su idghām e lām al-taʿrīf, motivi Fusion e Luna/Sole, regole Ḥafṣ segnalate."),
    ("2582fa56-c9fa-4caf-9ea6-4dad2173b011", "2026-06-22", "Jaweed course lesson structure planning", "curriculum",
     "Dal PDF del libro (584 pp., 24 capitoli) un curriculum di 13 unità / ~60 micro-lezioni con ID U#.L#. Brief di produzione U3.L1 (sifāt) e U1.L2 (organi dell'articolazione, con foto), prompt ChatGPT per le immagini."),
    ("c4bd4731-0cfa-40c2-bc82-1e0af24b9a69", "2026-01-16", "Kurzgesagt's Minimalist Animation Style", "video",
     "Stile Kurzgesagt per i video su nūn e mīm mushaddada; passaggio a micro-lezioni da 15–45 s; animazione di fusione stile Yu-Gi-Oh; strumenti di animazione; prompt Midjourney 16:9."),
    ("df05070c-d91e-4bec-96a0-70d885707dec", "2026-01-16", "Tajweed Arabic lesson prompt", "video",
     "Recupero del prompt Sora del video introduttivo stile Journey e adattamento per Nano Banana, togliendo i riferimenti che potrebbero essere bloccati."),
    ("bb025c49-a2eb-4996-adb4-3e470efcbb84", "2025-05-18", "Rateel Academy - Bilingual Website", "business",
     "Prototipo React di un sito Rateel Academy arabo/inglese con percorsi, insegnanti dal vivo, certificati, pacchetti e vetrina dell'app."),
    ("358b5a49-4820-4950-a67a-05c19e6df870", "2025-04-26", "Showcase Your App with Professional Arabic Voiceover", "marketing",
     "Script del voiceover arabo, titolo e descrizione YouTube per la presentazione dell'app rivolta a partner e investitori."),
    ("d404cf16-a750-40d8-973c-403e6440eab6", "2025-04-26", "Presentation Images for Tajweed Learning App", "marketing",
     "Titoli e descrizioni arabi per le immagini della presentazione, slide finale per invitare a partecipare, titolo e descrizione YouTube."),
    ("e979b1cc-1ed6-4f05-9740-4da2ed4ab801", "2025-04-25", "Floating 3D Badge Enhancement for Modal", "app",
     "Badge PNG che fluttua fuori dal modale dettaglio achievement con effetto 3D, grigio per i bloccati; titolo e punti sulla stessa riga."),
    ("6a794279-d109-4ec3-aa40-2655a8e5b92c", "2025-04-25", "Gamifying App Badges in Landscape Mode", "app",
     "Collezione badge a due pannelli per l'orizzontale: carosello a destra, dettagli a sinistra, rispettando le tab."),
    ("fa853e85-1c44-4f5d-9823-1c9add06f254", "2025-04-24", "Optimizing Achievement Details Modal for Mobile", "app",
     "Punti e data di completamento fuori dai box come icone; il box dei requisiti resta."),
    ("7558dbcc-188e-4e86-95da-75be6032e342", "2025-04-24", "Redesigning Achievement Modal for Landscape and Badge Focus", "app",
     "Descrizione per prima, sotto data e stelle come tag; badge più grande senza cerchio."),
    ("6e623470-b618-4d32-ac81-6f9cd7893e3a", "2025-04-24", "Customizing Achievement Details Modal", "app",
     "Piano di modifica del modale e posizionamento verso destra con justify-content: flex-end."),
    ("791de383-950c-4efa-a5b7-37e774180482", "2025-04-23", "Vibrant Game-Style Badge Details Modal", "app",
     "Modale achievement più largo, senza scroll, come una carta da gioco, simile al modale di feedback delle valutazioni."),
    ("afb7e139-a416-473b-990a-3488882c9030", "2025-04-23", "Gamified Achievement Modal for Landscape Mobile App", "app",
     "Modale achievement sul sistema modale centralizzato, sfondo sfocato, badge personalizzati nella loro forma."),
    ("41025190-4351-4133-88ab-c5b1ddc1e544", "2025-04-23", "Gamifying the Achievements Component", "app",
     "Tab metalliche in stile gioco, swipe RTL tra le tab, suggerimento di swipe temporaneo."),
    ("9936b589-3da3-46b0-b6e5-1003748de22f", "2025-04-23", "Modernize Badges Collection UI", "app",
     "Collezione badge con scroll RTL corretto, badge grandi, bloccati in grigio con lucchetto, anello di progresso."),
    ("8a59b4fc-6eb8-4653-9b5a-040444e31aa8", "2025-04-23", "Enhancing Achievements for Landscape Tajweed App", "app",
     "Header achievements con livello e barra di progresso, poi collezione badge orizzontale senza scroll verticale."),
    ("2a4ebee2-0fd6-4c40-941c-f286ef7c7a69", "2025-04-22", "Modularize Achievements Component", "app",
     "Comandi ng g per dividere la pagina achievements senza esagerare; i componenti condivisi della gamification restano."),
    ("1fd51d18-1f0b-43f1-8ffb-c8f217d593d5", "2025-04-22", "Implementing Achievements Page for Rateel App", "app",
     "Pagina achievements a caroselli con modale di dettaglio e badge da assets/badges."),
    ("11aab0a3-6984-448e-b976-d59069ae8d7e", "2025-04-22", "Gamification Components in Tajweed App", "app",
     "Analisi del modulo gamification (leaderboard, badge, punti, punteggio, sfide quotidiane e servizi) e proposta della pagina achievements."),
    ("aae99337-66c3-4c5d-9dcd-b30b2bfacbd7", "2025-04-21", "Improving Leaderboard Ribbon and User Position", "app",
     "Titolo del nastro su arco SVG (lettere arabe non separabili); riga dell'utente sticky in fondo finché non si raggiunge; fix per le tab."),
    ("fc2ef8cd-efc6-4720-9630-c621976e6169", "2025-04-21", "Gamify Daily Challenges with Rich Visuals", "app",
     "Restyling delle sfide quotidiane come percorso islamico; distinzione da una futura ricompensa quotidiana; fix di un errore delle animazioni."),
    ("9db9da27-71d7-4c7f-a018-f7c86a1f406b", "2025-04-21", "Daily Tajweed Challenges Gamification", "app",
     "Nuovo componente e servizio تحديات التجويد اليومية con nodi, streak e bonus finale."),
    ("a3f68cbc-31c0-44e1-9ad9-0b1f5d2a8b6c", "2025-04-20", "Customizing Leaderboard Component Appearance and Behavior", "app",
     "Monete del colore della medaglia senza bagliore; posizione dell'utente dentro la tabella al posto della sezione separata."),
    ("01fb180e-1416-401c-8f5a-ca70d9f4cc40", "2025-04-20", "Optimizing Leaderboard Coin Styling", "app",
     "Lista di correzioni della leaderboard affrontate una alla volta: header a nastro, poi medaglie PNG."),
    ("481910b3-c9a2-4db2-b0a7-6d8fafb4e8ad", "2025-04-19", "Updating Leaderboard Styling", "app",
     "Medaglie olimpiche con nastro e monete Font Awesome; tab dei filtri più alte."),
    ("0588602c-8616-400f-9784-c8dfe47b5875", "2025-04-19", "Enhancing Leaderboard Styling for Game-Themed App", "app",
     "Header di gioco per المتصدرين nei colori dell'app, filtri, medaglie al posto delle coppe, monete per le ricompense."),
    ("9131c592-7598-4797-a5ca-6e7c1fc19284", "2025-04-19", "Gamifying the Leaderboard for Landscape-Focused App", "app",
     "Leaderboard più da gioco, solo la lista scorre, servizio di gamification centralizzato, avatar PNG."),
    ("a83812b7-6509-49af-bf19-27a16c37c1f8", "2025-04-18", "Islamic-Inspired Leaderboard Component", "app",
     "Prima leaderboard con utenti mock in stile islamico, poi adattata all'orizzontale senza scroll."),
    ("5be5a0e3-925e-4307-a7fd-5d2185392d12", "2025-04-18", "(senza titolo)", "altro",
     "Chat vuota o senza contenuto restituito dallo strumento."),
    ("d57e6e83-5d08-4c37-8192-a80fbfd2d294", "2025-04-17", "Rateel: Mastering Quranic Recitation", "marketing",
     "Coppie titolo/descrizione arabe per ogni schermata; tono più commerciale; titoli di tre parole."),
    ("2e255beb-2748-4b41-86fa-5ceae2cad9d8", "2025-04-16", "Tajweed Learning App \"Rateel\"", "marketing",
     "Riepilogo del progetto, prompt per il logo con ChatGPT in un paragrafo, prompt per la Mecca preislamica."),
    ("04da8065-eeda-459b-8e66-fdcc16a5a4ca", "2025-03-26", "Minimalist Illustration Animation Tools", "video",
     "Strumenti per animazioni minimaliste con trasformazioni fluide; After Effects consigliato, Photoshop sconsigliato."),
    ("ad9a0d6c-759d-4df7-a912-5cfe5fb00b5b", "2025-03-22", "Prompts for Tajweed Lesson Images", "video",
     "Cinque prompt per immagini di lezione su nūn e mīm mushaddada (Leonardo/Canva) e metodo per animarle."),
    ("9876fbd3-0e6b-4e52-bb1f-50f170e95bd2", "2025-03-22", "Visualizing the Quran's Revelation in a Journey-Inspired Style", "video",
     "Seguito del video stile Journey: primo frame, narrazione inglese e araba, revisione senza anno e con lessico islamico."),
    ("37ad5f1c-f2f3-4289-beb7-44ba923df909", "2025-03-22", "Tajweed App Interactive Video", "video",
     "Prompt arabo per un video introduttivo di 2–3 minuti su cos'è il tajweed e come recitava il Profeta; prompt del secondo frame."),
    ("aedc6338-9a43-4620-9767-e11705e021a8", "2025-03-19", "Publishing Rattil Tajweed Learning App to Google Play", "distribuzione",
     "Passi per pubblicare su Play Store; dopo il closed testing l'app non è cercabile finché non va in produzione."),
    ("382f9a1b-ff2b-4433-bae0-e049e08390ca", "2025-03-19", "Rateel Mobile App Privacy Policy", "distribuzione",
     "Privacy policy dell'app e versione HTML scorrevole da incorporare in Google Sites."),
    ("754917af-ebd5-4eff-b42c-f0cd05d69578", "2025-03-18", "Preserving Scroll Position in Unit List Navigation", "app",
     "Issue #12: la lista unità riapre sull'ultima unità completata, con scroll animato."),
    ("38e612d4-d4d9-42dd-847d-7ef9c09b9ae1", "2025-03-17", "Modularizing Reading Lesson Component with Consistent Theming", "app",
     "Riestrazione della barra di controllo della lettura con temi :host-context come nella lezione interattiva."),
    ("58d56b11-ba0a-43f3-9f48-523316dd262f", "2025-03-17", "Refactoring Reading Lesson Component", "app",
     "Nuova estrazione dei componenti della lettura da zero, temi dark/light e variabili mushaf."),
    ("f75369ed-faea-43fe-a1d0-5d3e21f3d927", "2025-03-17", "Modular Reading Lesson Component Refactor", "app",
     "Confronto fra componenti della lettura nuovi e vecchi per recuperare gli stili persi."),
    ("3e36b3cd-53ae-440b-ba79-bf293d2d22c3", "2025-03-17", "Modularizing Reading Lesson Components", "app",
     "Prima verifica dei componenti della lettura divisi, con passaggio a classi theme-dark/theme-light."),
    ("90158d6b-e3f1-45ee-93c3-1beb37f1ecdf", "2025-03-17", "Adding Islamic Pattern to Lesson List", "app",
     "Pattern islamico nello sfondo di lista lezioni e lista unità, ruotato e ripetuto."),
    ("fcdef8b7-a92b-4c4b-81c1-5e7519b57033", "2025-03-17", "Pendulum-Style Animation for Islamic Decorations", "app",
     "Animazione a pendolo da destra a sinistra per la decorazione SVG."),
    ("96516fc2-d735-4b0c-a1fc-dade07e76a69", "2025-03-17", "Fixing Islamic Decoration Display and Animation", "app",
     "Decorazione invisibile in light mode e spostata al cambio tema: fix e oscillazione 'a filo'."),
    ("2e77222a-a3ad-47f9-ad3e-f86242986e6e", "2025-03-17", "Adaptive Islamic SVG Background for Interactive Lesson", "app",
     "SVG islamico nello sfondo della lezione interattiva, due file pre-colorati per i temi."),
    ("c5b56261-e77a-4893-a516-8602824c4f3b", "2025-03-16", "Developing an Original Roblox Map", "altro",
     "Domanda su una mappa Roblox, non legata al progetto."),
    ("2edf6394-1843-4a32-a110-da7d9744eb9b", "2025-03-16", "Enhancing Modular Lesson Feedback", "app",
     "Verse card più islamica: cifre arabe, decorazioni ondulate, variabili da root, nessuna legenda."),
    ("8ecfe7e4-b685-4c16-8f08-2a6c511d9a25", "2025-03-16", "Modularizing Interactive Lesson Components", "app",
     "Estrazione di verse card e container senza perdere la logica di drag e i pixel di compensazione."),
    ("01cd7af5-74ae-4ac8-9684-4b11614545d5", "2025-03-15", "Verifying Modular Components for Interactive Lesson", "app",
     "Verifica dei componenti della lezione interattiva contro l'originale; stili di container e modali."),
    ("5b85c39e-0820-42b7-a44b-89d4bdbaf147", "2025-03-15", "Refactoring Interactive Lesson into Modular Components", "app",
     "Proposta e scelta dei sottocomponenti della lezione interattiva; fix del tipo dell'evento di registrazione."),
    ("e25e095c-4e04-4a20-959e-dd5583e6e06a", "2025-03-15", "Resolving TypeScript Type Error in Recording Controls", "app",
     "Errore void/Event su recordingToggle e quattro modi per risolverlo."),
    ("3e4ba75a-1af1-4e05-ac0f-cda917a012db", "2025-03-15", "Automating Tajweed Rule Verification", "ai",
     "Analisi della proposta di DeepSeek per riconoscere il tajweed; approccio ibrido; pipeline Python di training partendo dal madd."),
]


def main() -> None:
    root = Path(__file__).resolve().parent.parent / "docs" / "knowledge-base" / "chats"
    root.mkdir(parents=True, exist_ok=True)
    rows = []
    for uuid, date, title, area, summary in CHATS:
        url = f"https://claude.ai/chat/{uuid}"
        name = f"{date}-{uuid[:8]}.md"
        (root / name).write_text(
            f"# {title}\n\n"
            f"- Data (ultimo aggiornamento): {date}\n"
            f"- Area: {area}\n"
            f"- Link: {url}\n"
            f"- UUID: `{uuid}`\n\n"
            f"## Sintesi\n\n{summary}\n\n"
            f"## Testo completo\n\n"
            f"Vedi `full/` dopo aver lanciato `tools/claude_export_to_md.py` sull'export di claude.ai.\n",
            encoding="utf-8",
        )
        rows.append(f"| {date} | [{title}]({name}) | {area} | {summary} |")
    (root / "ids.txt").write_text("\n".join(c[0] for c in CHATS) + "\n", encoding="utf-8")
    (root / "INDEX.md").write_text(
        "# Chat del progetto tajweed\n\nTesto completo di ogni chat in [full/](full/) (stesso UUID nel nome del file). Chat di Claude Design in [design/](design/).\n\n"
        f"{len(CHATS)} chat, dalla più recente. Il link originale è in ogni scheda.\n\n"
        "| Data | Chat | Area | Sintesi |\n|------|------|------|---------|\n"
        + "\n".join(rows) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
