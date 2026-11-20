# Lezioni apprese — creazione lezioni Rateel

Regole raccolte durante la lezione 1 (da applicare nelle prossime fasi).

1. **Voce e sottotitoli sincronizzati** — i sottotitoli devono mostrare esattamente
   le parole pronunciate, evidenziate in tempo reale (allineamento parola per parola).
2. **Animazioni logiche** — ogni elemento compare quando la voce lo nomina, mai prima;
   ogni passo deve dare una sensazione di apprendimento interattivo.
3. **Tashkīl completo ovunque** — testi a schermo E testo della narrazione completamente
   vocalizzati, così la voce non sbaglia mai la pronuncia
   (bozza pronta: `intro-lesson-1.tashkeel-bozza.json`).
4. **Video anche per YouTube** — serve una "modalità video" che renda l'interattività
   senza tocchi (es. domanda → conto alla rovescia "fermati e pensa" → risposta).
5. **Voce** — la più naturale possibile, vicina a uno shaykh; prevedere in futuro
   anche voce femminile e per bambini (provino: `voices/rateel-provino-voci.mp3`).
6. **TTS Gemini** — mai mettere istruzioni di stile nel testo da leggere: a volte
   vengono pronunciate. Verificare ogni file con trascrizione (Whisper).

## Materiale in questa cartella
- `rateel-prompt-nano-banana.txt` — prompt per generare gli asset grafici
- `rateel-zapier-automation.txt` + `rateel-assets-zapier.csv` — automazione Zapier (49 asset)
- `videos/` — render della lezione 1 (v1 glow, v2 ornate)
- `voices/rateel-provino-voci.mp3` — 15 voci Google a confronto
- Script di registrazione video: `scripts/video/`
