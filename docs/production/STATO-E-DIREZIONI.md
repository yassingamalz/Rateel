# Rateel: stato attuale e direzioni

Documento di passaggio tra sessioni. Leggerlo per primo.

---

## 1. Stato attuale (in attesa)

| Tema | Stato | Cosa serve per sbloccare |
|---|---|---|
| Asset grafici, batch 2 | ✅ Importati 9 su 11 | Scartati 2 (personaggio con volto) |
| Asset grafici, batch 3 | ✅ Importati 3 su 3 | **Set di asset completo** |
| **Voce della narrazione** | ⏳ In fase di scelta | Campioni in `voices/samples/` (01–15), provino unico in `voices/rateel-provino-voci.mp3`, nomi in `voices/elenco-voci.txt` |
| Asset grafici, batch 1 | ✅ Importati | 50 asset WebP in `src/assets/images/guided/`, stato in `ASSET-CATALOGO.md` |
| Lezione 1 (prototipo) | ✅ Funzionante | Motore «guided» in `src/app/features/lessons/guided-lesson/`, render in `videos/` |
| Tashkīl completo + sincronizzazione parola per parola | 🕒 Rimandati | Bozza vocalizzata: `intro-lesson-1.tashkeel-bozza.json` |

**Voci, preselezione:**
- **Stile shaykh (maschili gravi):** 02 Algenib, 01 Charon (attuale), 03 Gacrux.
- **Donne:** 09 Sulafat, 10 Vindemiatrix.
- **Bambini:** Google non ha vere voci di bambino; le più giovanili sono 13 Leda e 14 Zephyr. Servirà valutare un altro servizio.

---

## 2. Due direzioni separate

Il prototipo attuale mescola due cose: la lezione è *dentro l'app* e il video è una
*registrazione dell'app*, con i tocchi simulati. Da ora le separiamo.

### Direzione A: l'applicazione (l'interattività vive qui, fatta una volta sola)

- Tutto ciò che è **interazione** appartiene all'app ed è costruito **una sola volta**, come
  componente riutilizzabile per tutte le lezioni:
  - pulsanti avanti/indietro, barra di avanzamento, pausa;
  - quiz (scelta multipla, vero/falso), feedback giusto/sbagliato, stelle e punti;
  - registrazione della propria voce e confronto con il lettore;
  - stile visivo (tema «ornate»: oro su verde, cornici, etichette).
- Le lezioni diventano **dati** (video + punti di sosta + domande), non codice.
- **Obiettivo tecnico da valutare: passare da HTML/JS/CSS (Angular + Capacitor) a un'app
  Android nativa.**
  - Oggi: Angular 19 in una WebView tramite Capacitor 6.
  - Da analizzare: Kotlin + Jetpack Compose (nativo puro), oppure Flutter / React Native come
    via di mezzo; cosa si riusa (dati JSON delle lezioni, audio, asset WebP) e cosa va riscritto
    (UI, navigazione, salvataggio dei progressi, gamification).
  - Requisiti nativi chiave: player video con sosta a tempi precisi, registrazione audio,
    funzionamento offline, landscape, prestazioni delle animazioni.

### Direzione B: i video (contenuto lineare, anche per YouTube)

- Il video è **solo video**: spiegazione animata + voce + recitazione, **senza** pulsanti, tocchi
  o schermate «clicca qui». Quelle parti appartengono all'app (direzione A).
- Ogni video è diviso in **sezioni** (capitoli) con tempi precisi:
  - **nell'app**, il player si ferma alla fine di una sezione e l'app mostra l'interazione nativa
    (quiz, ripeti il versetto…), poi riprende il video;
  - **su YouTube**, le stesse sezioni diventano i capitoli del video.
- Formato proposto per ogni lezione (da definire insieme):

```json
{
  "lessonId": "intro-lesson-1",
  "video": "intro-lesson-1.mp4",
  "sections": [
    { "id": "s1", "title": "التَّجْوِيدُ لُغَةً", "start": 0.0, "end": 24.5 },
    { "id": "s2", "title": "التَّجْوِيدُ اصْطِلَاحًا", "start": 24.5, "end": 61.0,
      "after": { "type": "quiz", "questionId": "q1" } }
  ],
  "questions": [
    { "id": "q1", "type": "trueFalse", "text": "...", "answer": true }
  ]
}
```

- **Da valutare dopo:** se nella versione YouTube inserire anche segmenti di domanda
  «passivi» (domanda → conto alla rovescia «توقّف وفكّر» → risposta, vero/falso), con la stessa
  struttura del prototipo attuale.

### Cosa si riusa dal prototipo

- **Contenuto e copione** della lezione 1 (testi, quiz, versetti con tempi di al-Ḥuṣarī).
- **Pipeline audio**: Gemini TTS + verifica Whisper (`scripts/generate-guided-audio.mjs`,
  `scripts/video/check-audio-whisper.py`).
- **Asset grafici** e tema visivo «ornate».
- **Registrazione video**: `scripts/video/record2.js` + `mix.py`. Andrà adattata per produrre
  video senza parti interattive, oppure sostituita da un vero strumento di montaggio o animazione.

---

## 3. Prossimi passi (quando si riprende)

1. ✅ Asset completi (batch 1–3).
2. Scegliere la voce (o le voci: shaykh / donna / bambino).
3. **Direzione A:** analisi per il passaggio ad Android nativo + design dei componenti interattivi
   comuni.
4. **Direzione B:** definire il formato delle sezioni del video e produrre la lezione 1 come
   video lineare con capitoli.
5. Poi: tashkīl completo e sincronizzazione parola per parola (vedi `LEZIONI-APPRESE.md`).

Riferimenti: `LEZIONI-APPRESE.md` (regole), `ASSET-CATALOGO.md` (grafica),
`prompt-sequenziali*.txt` (prompt), branch `ccr-db05bd01-tmb3a3`.
