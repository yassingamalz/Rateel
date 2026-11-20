# Command to start the next session

Start a new Claude Code session on the repository `yassingamalz/Rateel`, branch **`lesson-production`**,
and paste this as the first message:

```
Lavoriamo sulla produzione delle lezioni di Rateel, branch lesson-production.
Prima di tutto leggi CLAUDE.md, poi docs/production/RULES-AND-LESSONS-LEARNED.md,
docs/production/LESSONS-TRACKER.md e docs/production/STATO-E-DIREZIONI.md, e rispetta tutte le regole.

Obiettivo di questa sessione:
1. Riassumimi in 5 righe lo stato attuale e cosa è in attesa.
2. Scarica dal Drive il PDF del capitolo su cui lavoriamo (link nel tracker) e proponimi
   la struttura delle lezioni del capitolo (sotto-lezioni, passi, quiz, versetti),
   aggiornando il tracker con le sotto-lezioni e lo stato ⬜/🟡/✅.
3. Usa la voce gratuita finché non confermo lo stile grafico.
4. Se un'animazione o un elemento grafico è difficile, non farlo nel codice:
   dammi i prompt per ChatGPT / Google Flow nel formato ZAPI FLOW.
Parlami in italiano. Fai commit e push di tutto su lesson-production.
```

## Waiting on the owner
- Choice of the Google male voice (samples 01–08 in `voices/samples/`).
- Confirmation of the graphic style (until then: free voice).
- Which chapter to start from (default: continue with 02 «علم التجويد», then 01 and 03).

## Free voice (to use for now)
Microsoft Edge neural voices via `edge-tts` (free, no API key). Tested and verified with Whisper:
`voices/free-samples/F1-ar-SA-HamedNeural.mp3`, `F2-ar-JO-TaimNeural.mp3`, `F3-ar-QA-MoazNeural.mp3`.
In this environment Python needs the proxy CA appended to certifi's bundle
(`cat /root/.ccr/ca-bundle.crt >> $(python -c "import certifi;print(certifi.where())")`).
`ar-EG-ShakirNeural` returned no audio.
