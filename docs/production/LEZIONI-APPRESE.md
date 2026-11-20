# Lezioni apprese — creazione lezioni Rateel

Tutto quello che abbiamo imparato producendo la lezione 1 («مقدمة في علم التجويد»).
Da rispettare in ogni nuova lezione.

---

## 1. Contenuto e testo arabo

1. **Tashkīl completo ovunque**: titoli, opzioni dei quiz, spiegazioni, riepilogo **e il
   testo della narrazione**. Il testo vocalizzato guida la voce, che così non sbaglia la
   pronuncia (bozza della lezione 1 già pronta: `intro-lesson-1.tashkeel-bozza.json`).
2. **I versetti coranici non vanno mai letti dalla voce sintetica**: li recita sempre un
   lettore vero (al-Ḥuṣarī Muʿallim). La narrazione introduce il versetto, non lo legge.
3. **Testo coranico in grafia uthmani** (fonte: API di quran.com) e font Amiri Quran.
4. **Evitare i nomi propri con iʿrāb incerto** nella narrazione: «الشيخ الحصري» invece del
   nome completo.
5. **Nessuna musica**: solo suoni brevi e discreti (tocco, giusto, sbagliato), per rispetto
   del contesto coranico.
6. **Contenuti di fiqh**: riportare solo affermazioni condivise (es. tajwīd teorico = farḍ
   kifāya, applicazione = wājib) ed evitare le questioni controverse.
7. Il testo si rivolge oggi all'utente al maschile (أنتَ). Più avanti serviranno varianti al
   femminile e per bambini.

## 2. Voce (Gemini TTS)

1. **Mai istruzioni di stile nel testo da leggere** («Say in a warm voice…»): il modello a
   volte le pronuncia ad alta voce, soprattutto nelle frasi brevi. Si invia solo il testo arabo.
2. **Verificare ogni file audio** con una trascrizione (Whisper in locale:
   `scripts/video/check-audio-whisper.py`). Se il servizio di verifica non risponde
   (errore 503), il file va considerato **NON verificato**, mai buono.
3. **Controllo rapido**: il ritmo normale è circa 0,16–0,20 s per lettera. Un file molto più
   lungo contiene quasi sempre parlato in più.
4. **Quota giornaliera limitata**: lo script si ferma subito invece di aspettare ore.
   Rigenerare solo i file cambiati (lo script tiene un manifest).
5. **Voce**: la più naturale possibile, vicina a uno shaykh. Candidate: Algenib (la più
   profonda), Charon (quella attuale), Gacrux (matura). Per le donne: Sulafat, Vindemiatrix.
   Per i bambini Google non ha voci di bambino vere (le più giovanili sono Leda e Zephyr):
   servirà un altro servizio. Provino: `voices/rateel-provino-voci.mp3`.
6. Prevedere dall'inizio **profili voce** (shaykh / donna / bambino) con cartelle audio separate.

## 3. Sincronizzazione

1. **Voce e sottotitoli sincronizzati parola per parola**: i sottotitoli mostrano
   esattamente le parole pronunciate (non un riassunto) e le evidenziano in tempo reale.
   Servono i tempi di ogni parola (allineamento con Whisper).
2. **Recitazione coranica**: si usano i tempi ufficiali di quran.com
   (`/api/v4/recitations/12/by_ayah/<chiave>?fields=segments`), già precisi al millisecondo.
3. **Ogni elemento compare quando la voce lo nomina** (la definizione quando dice «إخراج»,
   la carta «حقّه» quando dice «وحقّ»…), non a percentuali di tempo indovinate.

## 4. Animazione e interattività

1. **Mai mostrare un elemento prima del suo momento**. Bug trovato: passando al passo
   successivo, l'avanzamento della voce restava al 100% del passo precedente e per mezzo
   secondo tutto appariva e poi spariva. Va azzerato all'ingresso di ogni passo.
2. Gli elementi non ancora rivelati sono **completamente invisibili** (non semitrasparenti).
3. **Ogni animazione deve avere un motivo didattico**: comparire quando se ne parla,
   evidenziare la parola recitata, confermare la risposta. Niente effetti decorativi che
   distraggono.
4. **Feedback immediato** nei quiz: verde + «أحسنت» se giusta; scossa + «حاول مرة أخرى» e
   spiegazione se sbagliata. Le stelle si contano solo sulle risposte giuste al primo tentativo.
5. **La registrazione della propria voce non blocca mai l'avanzamento**: si incoraggia
   (il microfono pulsa), ma si può sempre proseguire.

## 5. Video per YouTube

1. Su YouTube non si può toccare: serve una **modalità video** che renda l'interattività in
   modo passivo:
   - domanda → conto alla rovescia «توقّف وفكّر» (5 s) → risposta evidenziata e spiegata;
   - «ردّد معنا»: pausa della durata del versetto, con le parole evidenziate da seguire;
   - capitoli YouTube per ogni passo; schede e schermata finale che rimandano all'app.
2. **Registrazione video**: il registratore integrato di Playwright NON va usato con una
   risoluzione più grande della pagina: lascia la lezione in un angolo e il resto vuoto.
   Si catturano i fotogrammi dal browser a 2× e si montano a 30 fps
   (`scripts/video/record2.js`), poi si aggiunge l'audio (`scripts/video/mix.py`).
3. La registrazione parte **solo quando la lezione è sullo schermo** (niente fotogrammi bianchi).
4. I suoni dell'interfaccia non finiscono nel video (sono generati dal telefono): se servono
   su YouTube vanno aggiunti come file.
5. Formato: 1688×780, 30 fps, H.264 + AAC, `faststart`.

## 6. Grafica e asset

1. **Non ritagliare le icone da un'immagine generata**: ~60 px, sfondo incluso, sfocate su
   schermi 2×. Servono file singoli in alta risoluzione (PNG 512×512 o SVG).
2. Gli strumenti di generazione (Nano Banana, ChatGPT) non producono vera trasparenza: si
   chiede un **fondo magenta pieno #FF00FF**, che poi si rimuove (luci e raggi: fondo nero).
3. **Un asset per richiesta**, sempre con le stesse immagini di riferimento (libreria icone,
   sfondo con arco, schermata della lezione). Per il personaggio, prima il foglio di
   riferimento e poi le pose (stesso personaggio).
4. Il **personaggio è senza volto** (lanterna/fanous), per rispetto del contesto religioso.
5. **Palette** (campionata dal mockup): verde #043226 / #02271E, oro #F7BC15 (luce #FFD95A,
   ombra #B5850A), crema #F6EBCB, segmenti spenti #2B473D.
6. Lo sfondo fornito (arco + reticoli) si usa direttamente. Cornici, etichette e rosoni sono
   ricostruiti in vettoriale finché non arrivano i file originali.
7. Due temi disponibili: `ornate` (v2, predefinito) e `glow` (v1), scelti con `"theme"` nel
   file della lezione.

### Generazione degli asset con ZAPI FLOW (Google Flow)

1. **Formato del file**: un prompt per riga, una riga vuota tra un prompt e l'altro, niente
   titoli né numeri (`prompt-sequenziali.txt`). Si carica con «UPLOAD .TXT FILE».
2. **Il formato immagine va scritto nel prompt** (es. «Aspect ratio 16:9.» alla fine),
   perché il file non ha altri campi.
3. **Immagini di riferimento come asset del progetto Flow**, con lo stesso nome usato nei
   prompt: REF-A (libreria icone), REF-B (sfondo con arco), REF-C (screenshot della lezione),
   REF-D (personaggio). Con «Character Consistency» attivo, ZAPI FLOW aggiunge da solo gli
   asset il cui nome compare nel prompt.
4. **Ordine**: prima il prompt 1 (foglio del personaggio), poi lo si salva come REF-D e solo
   dopo si lanciano i prompt 2–8 (le pose), così il personaggio resta identico.
5. **Nomi dei file**: tenere attivo «Include serial number in filename». Il numero
   corrisponde alla posizione del prompt nel file, e così si ricollega ogni immagine al suo asset.
6. Non usiamo Zapier.

## 7. Processo

1. Provare ogni lezione **dall'inizio alla fine nell'app vera** (landscape da telefono)
   prima di consegnarla, inclusi microfono, stelle e sblocco della lezione successiva.
2. Dopo ogni modifica ai testi: rigenerare l'audio → verificarlo → riallineare i tempi →
   rifare il video.
3. Prima la parte visiva e la scelta della voce; tashkīl completo, sincronizzazione
   parola per parola e modalità YouTube nella fase successiva.

---

## Materiale in questa cartella

- `prompt-sequenziali.txt`: i 49 prompt per ZAPI FLOW (uno per riga, in ordine)
- `voices/elenco-voci.txt`: nomi delle 15 voci nell'ordine del provino
- `rateel-prompt-nano-banana.txt`: guida d'uso manuale con i prompt per sezione
- `intro-lesson-1.tashkeel-bozza.json`: lezione 1 completamente vocalizzata (bozza)
- `videos/`: render della lezione 1 (v1 glow, v2 ornate)
- `voices/rateel-provino-voci.mp3`: 15 voci Google a confronto
- Script: `scripts/generate-guided-audio.mjs`, `scripts/video/`
