# 08. Riconoscimento automatico del tajweed

Fonti: chat [Automating Tajweed Rule Verification](https://claude.ai/chat/3e4ba75a-1af1-4e05-ac0f-cda917a012db) (marzo 2025) e documento di progetto copiato in [sources/ai-recognition-roadmap.md](sources/ai-recognition-roadmap.md).

## Come è nato

Yassin voleva sapere se l'app può capire da sola se l'utente applica bene le regole, e se conviene una soluzione AI esistente o addestrare un modello. Ha chiesto a DeepSeek e poi a Claude di valutarne la risposta. Claude ha giudicato valido l'approccio ibrido di DeepSeek, con due riserve: i modelli nel browser possono essere lenti su telefoni deboli, e un'accuratezza del 70–80% può non bastare per insegnare il tajweed sul serio. Nella stessa chat Claude ha poi scritto una pipeline Python di training, uno script di preparazione del dataset e uno di test, partendo dal madd (questo codice è solo nella chat, OP-02).

## Due approcci (roadmap, sez. 3)

| | Ibrido | Modelli su misura |
|---|---|---|
| Come | Web Audio API + regole + modelli pre-addestrati (Tarteel-STT o Wav2Vec 2.0) in TensorFlow.js | modelli per regola addestrati su un grande dataset di recitazioni |
| Accuratezza stimata | 70–80% sulle regole complesse | 90–95% |
| Tempo | 3–4 mesi | 6–8 mesi |
| Costo iniziale stimato | 30–50K$ | 80–120K$ |
| Requisito | | 100+ ore di audio annotato, GPU |

## Ordine delle regole

Madd (durata) → ghunnah (spettro) → qalqalah (transienti) → idghām (confini dei fonemi) → ikhfāʾ (nasalizzazione parziale). Roadmap sez. 2 e 12.

## Integrazione con l'app (roadmap, sez. 11)

Raccomandata un'architettura ibrida: regole semplici nel browser, analisi complessa su un backend Python (FastAPI) solo quando serve e c'è rete. In seguito un plugin Capacitor nativo con TensorFlow Lite (Android) e CoreML (iOS) per lavorare offline. Fasi: backend e regole base (8–10 settimane), plugin Android (6–8), iOS e offline completo (8–10).

## Prossimi passi indicati (roadmap, sez. 12)

1. Audit dei dati di recitazione disponibili.
2. Prototipo: cattura audio e rilevazione del madd, confrontata con un esperto.
3. Decisione su architettura, tempi e risorse.

Collegati: OP-20, OP-21, OP-22, OP-23 in [05-open-points.md](05-open-points.md).
