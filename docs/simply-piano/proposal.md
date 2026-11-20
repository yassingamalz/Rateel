# Proposta: lezioni di tajweed stile Simply Piano

Versione testuale del documento https://claude.ai/artifact/QSHRmpxBc34v6miCr42cfK (19–20/11/2026). Nessuna modifica al codice dell'app finora.

## Sintesi

Si tiene il look di oggi (smeraldo e oro, card dell'ayah in stile mushaf, traccia orizzontale dei versetti, pulsante del microfono) e ogni lezione diventa uno **spartito dell'ayah**:

- le parole scorrono da destra a sinistra con un cursore dorato, come le note sul pentagramma;
- ogni regola è una "nota" con una durata: il madd è una nota tenuta di 2, 4 o 6 harakat, la ghunnah una nota tenuta di 2 harakat, la qalqalah un rimbalzo;
- ogni lezione ha le modalità **استمع** (il qari recita e il cursore lo segue), **تعلّم** (l'app aspetta che tu reciti ogni pezzo) e **اقرأ** (reciti tutto e prendi le stelle);
- i video diventano animazioni morphing fatte dall'app;
- il feedback arriva in due tempi: subito sul telefono, poi preciso a fine segmento.

## Cosa c'è oggi nel codice

| Pezzo | Dove | Stato |
|---|---|---|
| Lezione pratica | `features/lessons/interactive-lesson` | Traccia RTL di card (`verses-container`), parola corrente e parole "dette" (`verse-card`) |
| Riconoscimento voce | `interactive-lesson.service.ts` | Simulato: una parola ogni 700 ms, successo casuale all'85% |
| Microfono | `recording-controls` | Onde decorative |
| Colori tajweed | `src/styles/_variables.scss` (`$tajweed-rules`) | ghunnah, ikhfa, idgham, iqlab, qalqalah, ikhfa shafawi |
| Evidenziazioni | `assets/data/content/verses/*.json` | Per offset di carattere; alcune sbagliate |
| Video | `video-player` | Iframe YouTube; solo 4 lezioni hanno un link, di terzi |
| Tipo `listen` | `audio-player` | Esiste ma `lesson-details` non lo usa |
| Contenuti | `assets/data` | 4 corsi senza unità; ogni corso apre con un'unità video |

`lesson-details` sceglie il componente in base a `lesson.type`: è il punto dove agganciare il nuovo player.

## Modello di interazione

L'unità di pratica è il segmento fino al waqf (2–6 parole, meno di 15 s), non l'ayah intera (da confermare con Yassin).

| Simply Piano | Rateel |
|---|---|
| Note che scorrono | Parole sulla traccia RTL con cursore dorato |
| Note lunghe | Barra di durata sotto la parola, divisa in harakat |
| Metronomo | Battito della haraka con velocità regolabile |
| Modalità "aspetta" | تعلّم: il cursore si ferma finché non reciti il segmento |
| Mani separate | Lettera → parola → segmento → ayah |
| Stelle | 3 stelle: parole, regole, fluidità |
| Ripeti il passaggio | Il segmento sbagliato torna in loop |

Passi di una lezione: شاهد (micro-lezione animata) → استمع → تعلّم → اقرأ → risultato (stelle, parole da ripassare, punti nella gamification esistente).

## Feedback sulla recitazione

1. **Livello 1, sul telefono, istantaneo.** Web Audio, senza AI: voce attiva, pause, durata dei suoni tenuti. Riempie le barre e stima le harakat ("madd di 2 invece di 4"). Non sa quale parola hai detto.
2. **Livello 2, a fine segmento.** Quran Muaalem (branch `claude/quran-tajweed-correction-model-l36l1y`, script non ancora provati) restituisce errori con posizione nel testo uthmani: lettera, haraka, durata, ghunnah, sifat. L'app colora le parole: verde giusta, arancione da migliorare, rosso sbagliata.

Dove gira il modello: server con GPU (più semplice, ma va contro la privacy policy attuale, vedi README), poi ONNX int8 da circa 0,6–0,7 GB scaricabile, poi un modello distillato da 30–100 MB dentro l'app.

Per استمع servono le recitazioni con i tempi di ogni parola (alcune API pubbliche li danno; verificare la licenza).

## Riuso dei componenti

| Oggi | Diventa |
|---|---|
| `lesson-details` | Contenitore; mostra la lezione animata o il player a passi |
| `verses-container` | Traccia RTL con scorrimento automatico che segue il cursore |
| `verse-card` | Aggiunge la corsia delle regole e i colori per parola |
| `tajweed-legend` | Toccabile: riapre la micro-animazione della regola |
| `recording-controls` | Livello reale del microfono |
| `feedback-overlay`, `completion-screen` | Con stelle e parole da ripassare |
| `interactive-lesson.service` | Il riconoscimento simulato lascia il posto ai due livelli |
| `gamification.service` | Riceve le stelle come punti |

Nuovi: componente `animated-lesson`, servizio di ascolto locale, client verso Muaalem.

## Ordine di costruzione

1. Modello dati dello spartito: parole, segmenti di waqf, regole con durata in harakat, tempi dell'audio del qari. Correggere le evidenziazioni sbagliate.
2. Corsia delle regole e modalità استمع sulla `verse-card`.
3. Componente `animated-lesson` e prima lezione (fatta: `lessons/intro-lesson-1`).
4. Livello 1 di ascolto locale e modalità تعلّم / اقرأ al posto del riconoscimento simulato.
5. Provare il PoC Muaalem, poi collegarlo (dopo la decisione sulla privacy).
6. Stelle e punti nella gamification.
7. Contenuti: le lezioni di tutti i corsi e le unità dei 4 corsi vuoti.
8. Modello sul telefono.

## Domande aperte

- Riwaya Ḥafṣ ʿan ʿĀṣim: quali lunghezze per munfasil, muttasil e ʿarid?
- Quale qari e quale fonte audio, con licenza.
- Struttura ufficiale del curriculum (OP-05).
- Privacy: tutto sul dispositivo o policy aggiornata con consenso (OP-20).
