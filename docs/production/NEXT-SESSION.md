# Command to start the next session

Start a new Claude Code session on the repository `yassingamalz/Rateel`, branch **`lesson-production`**,
and paste this as the first message:

```
Lavoriamo sulla produzione delle lezioni di Rateel, sul branch lesson-production.
Prima di tutto leggi CLAUDE.md, poi docs/production/RULES-AND-LESSONS-LEARNED.md,
docs/production/LESSONS-TRACKER.md (la lista completa delle lezioni del libro «التجويد المصور»,
22 capitoli, con le sotto-lezioni del capitolo 10), docs/production/STATO-E-DIREZIONI.md
e docs/design/README.md. Rispetta tutte le regole.

Partiamo dalla lezione 10.1 «النون والميم المشددتان» (capitolo 10, PDF pagine 2 e 53–56).
Stile: glassy gamified, SOLO scuro, da replicare 1:1 dalle schermate docs/design/glassy-gamified/screens/15–21.
Animazioni: morphing, leggere all'occhio, spiegazioni chiare (un'idea per scena).
Voce: gratuita finché non confermo lo stile grafico.

Prima di scrivere codice:
1. Riassumimi in 5 righe lo stato e cosa è in attesa.
2. Proponimi il copione della lezione 10.1 (passi, testo con tashkīl completo, versetti
   recitati da al-Ḥuṣarī, quiz) basato SOLO sul libro.
3. Mostrami il piano visivo / mockup di ogni passo e l'elenco degli elementi grafici necessari.
   I prompt proposti sono in docs/production/prompts/lesson-10-1/ (immagini per ZAPI FLOW e GIF per ChatGPT):
   dimmi se vanno bene o cosa cambiare. Non inventare nessun asset: chiedimelo.
4. Aspetta la mia conferma, poi realizza la lezione, provala nell'app e mandami il video.
Aggiorna il tracker (⬜/🟡/✅: solo io approvo il ✅). Parlami in italiano.
Fai commit e push di tutto su lesson-production.
```

## Waiting on the owner
- Confirmation of the lesson 10.1 visual plan and its element prompts (`prompts/lesson-10-1/`).
- Generation of those elements (images with ZAPI FLOW, GIFs with ChatGPT).
- Choice of the Google male voice (samples 01–08 in `voices/samples/`), after the style is confirmed.

## Free voice (to use for now)
Microsoft Edge neural voices via `edge-tts` (free, no API key). Tested and verified with Whisper:
`voices/free-samples/F1-ar-SA-HamedNeural.mp3`, `F2-ar-JO-TaimNeural.mp3`, `F3-ar-QA-MoazNeural.mp3`.
In this environment Python needs the proxy CA appended to certifi's bundle
(`cat /root/.ccr/ca-bundle.crt >> $(python -c "import certifi;print(certifi.where())")`).
`ar-EG-ShakirNeural` returned no audio.

## Reading the book PDFs
The PDFs are image-only (no text layer). Download with
`https://drive.google.com/uc?export=download&id=<FILE_ID>` and render pages with
`pdftoppm -r 110 -f <page> -l <page> -png file.pdf out`, then read the images.
