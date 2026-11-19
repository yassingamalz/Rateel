# Video introduttivo: storyboard in stile *Journey*

Fonti: [Tajweed App Interactive Video](https://claude.ai/chat/37ad5f1c-f2f3-4289-beb7-44ba923df909) (prima versione del concept), [Visualizing the Quran's Revelation in a Journey-Inspired Style](https://claude.ai/chat/9876fbd3-0e6b-4e52-bb1f-50f170e95bd2) (frame, scene, prompt Runway, narrazione), [Tajweed Arabic lesson prompt](https://claude.ai/chat/df05070c-d91e-4bec-96a0-70d885707dec) (adattamento per Nano Banana). Tutti i prompt sono riportati com'erano nelle chat.

## Concept

Prima versione (marzo 2025): video di 2–3 minuti in arabo su cos'è il tajweed, come recitava il Profeta e cosa offre l'app. Yassin ha poi chiesto di togliere l'app e farne una storia, "a video of making the user feel apart of journey like the journey game style": come il Corano è stato rivelato al Profeta, come è stato raccolto nel muṣḥaf, poi il tajweed. Durata obiettivo circa 2 minuti.

Il Profeta è sempre una silhouette di spalle senza tratti del volto (chat 9876fbd3, turni 9 e 23). Vedi OP-10.

Flusso di lavoro: key frame generati con Leonardo.ai o Midjourney, animati in Runway ML (consigliato) o Pika Labs, montati in DaVinci Resolve o Premiere con narrazione e musica. Canva non ha dato risultati soddisfacenti (turno 6).

## Scena 1: alba nel deserto (frame 1, versione rivista sugli abiti)

```
A reverent silhouette representing Prophet Mohammed in simple, flowing white robes and a modest turban, standing at the base of a sand dune at dawn. The figure deliberately has no visible facial features, maintaining proper Islamic respect while showing only a humble silhouette. His loose, flowing garments (thobe/jubba) and turban (imama) billow gently in the desert breeze. A simple cloak (burda) drapes from his shoulders, and a long cloth trails behind like the signature scarf from the Journey game. The Prophet appears to float slightly above the sand, surrounded by a subtle ethereal glow. In the distance stands a majestic mountain with divine white light emanating from its peak (representing Mount Hira). Art style exactly like the video game Journey - minimalist design with warm orange-gold sand dunes extending to the horizon and an amber sky transitioning to soft green-blue. Soft warm lighting with long shadows creates a deeply spiritual atmosphere. Faint rays of divine light beginning to appear, suggesting the sacred moment of first revelation. Painterly, stylized look with smooth gradients and simplified forms. Not photorealistic. Cinematic golden hour lighting. Low-poly aesthetic with smooth shading. Desert landscape bathed in spiritual light.
```

Il primo frame (versione precedente, con vesti ricamate d'oro) è stato generato con successo.

Animazione Runway (turno 19), personaggio fermo, si muovono solo vestiti, sabbia, nuvole e luce:
```
Desert scene with gentle wind effects causing the character's robes and cloak to flow rhythmically from right to left. Sand particles drift across dunes with subtle movement patterns. Distant clouds slowly drift across the sky. Gradual transition from golden daylight to deeper amber sunset tones as animation progresses. The character remains stationary but their clothing responds naturally to the desert breeze. Maintain Journey game aesthetic with warm color palette. Add heat distortion rising from distant sands. Journey-inspired minimalist style with smooth animation.
```

Parametri suggeriti: 3–5 s per clip, intensità di movimento 25–40%, smoothness e style fidelity al massimo.

## Frame 2: verso la montagna (scritto da Yassin)

```
Prophet Mohammed halfway up the sand dune, moving toward the mountain, his flowing orange-red robes and scarf billowing dramatically in the wind. His silhouette is viewed from behind, turban clearly visible. The mountain now emits a stronger white light from its peak, with subtle rays beginning to emerge upward into the sky. The sun/light behind the mountain is more intense, creating a halo effect. Same Journey game art style as the first image, with warm amber-orange desert landscape, rolling sand dunes with mist between them. Low-angle perspective showing the Prophet ascending toward the glowing mountain. Long shadows cast across the sand. The sky is transitioning from amber near the horizon to a soft green-blue higher up. Small particles of light are beginning to float in the air around the mountain peak. Minimalist, spiritual atmosphere, painterly non-photorealistic style with smooth gradients. A sense of anticipation and divine presence increasing.
```

## Scena: Ghār Ḥirāʾ con le parole che scendono dal cielo (turno 13)

```
Ghar Hira scene: A reverent silhouette representing Prophet Mohammed in simple white robes and modest turban stands near the entrance of a mountain cave (Ghar Hira), his form glowing with subtle divine light. The cave entrance on Mount Nur emits a brilliant golden-white radiance. Streams of light carrying luminous Arabic calligraphy descend from the night sky like gentle rain, each letter pulsing with divine energy. The letters specifically form the first revealed verse "اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ" (Read in the name of your Lord who created), appearing gradually in the air around the Prophet. The Arabic script glows with an otherworldly light, each letter beautifully stylized yet clearly legible. The mountain and cave are rendered in the distinctive Journey game aesthetic - simplified forms with smooth gradients in warm amber tones contrasting with the deep blue-purple of the night sky. Stars twinkle above, some elongating into streams of light that carry more Arabic letters. Small particles of light hover around the Prophet's silhouette as he receives the revelation, his posture showing humble acceptance. The entire scene captures the profound moment of first revelation with the Journey game's signature minimalist, spiritual style. No facial features are shown, only the dignified silhouette, maintaining proper Islamic respect.
```

Nota: i generatori sbagliano l'arabo; il versetto andrebbe aggiunto in post-produzione (regola di [07-content-production.md](../07-content-production.md)).

## Scena 2: insegnamento ai compagni e scrittura (turno 11)

```
Second scene: A reverent silhouette representing Prophet Mohammed in simple white robes and modest turban now seated at the center of a small gathering, surrounded by attentive companions (Sahabah) in varying earth-toned garments. All figures are portrayed without facial features, respecting Islamic tradition, with only dignified silhouettes visible. Rays of light with Arabic calligraphy emerge from the Prophet's silhouette, flowing toward the companions like gentle streams of divine knowledge. Some companions are hunched over various writing materials - palm fronds, shoulder blades, and parchment pieces - which glow softly when touched. Journey game aesthetic with warm amber lighting and minimalist design creates a spiritual atmosphere. Small particles of light hover around the written materials, symbolizing the preservation of revelation. The scene takes place in a simple Madinan setting with subtle architectural elements in the background. Long shadows stretch across the sand floor, creating geometric patterns. Companions' postures show deep reverence and concentration as they receive and record the Quranic teachings. Art style maintains the Journey game's smooth gradients, stylized forms, and non-photorealistic rendering. The entire scene is bathed in a warm golden light representing divine guidance being transmitted and preserved.
```

Animazione Runway, con l'indicazione esplicita di non mostrare i volti (turno 23):
```
Sacred indoor scene with golden divine light pulsating gently through the archway, casting subtle moving shadows. The figures should remain as they are - without detailed facial features, maintaining the respectful stylized silhouette approach seen in the image. Small particles of light float in the beam, resembling dust motes in sunlight. The central standing figure's robes sway very subtly as if touched by the divine presence. Seated companions make minimal movements - slight shifts in posture, gentle hand movements as they write in their books. Soft, barely visible streams of light occasionally flow from the central figure to the companions, representing the transmission of Quranic knowledge. Pages in the books subtly turn. The light intensity breathes - slightly brightening and dimming in a slow, meditative rhythm. Journey game aesthetic with warm golden color palette maintained throughout.
```

## Scene alternative proposte e non scelte

Nella stessa chat (turni 1–5) Claude ha proposto un terzo e quarto frame con la figura avvolta dalla luce e il versetto nel cielo, e una scena all'oasi al tramonto con palette fredda (blu, viola, argento) e tavolette luminose. Yassin ha chiesto "different scene with different colors" dopo il quarto frame; la scena all'oasi non risulta poi usata.

## Narrazione della scena 1 (araba, rivista su richiesta di Yassin: niente anno, testo islamico)

```
*[بصوت ذكوري خاشع مع صدى خفيف]*

"في سكون الصحراء المباركة، كانت لحظة ستغير مسار البشرية إلى الأبد على وشك أن تتجلى بإذن الله."

*[وقفة قصيرة مع صوت الرياح الخفيفة]*

"في ليلة القدر المباركة، حين كان خاتم النبيين في خلوته بغار حراء. هناك، على جبل النور، أكرمه الله بنزول أولى آيات الوحي المبين:"

*[يتحول الصوت إلى نبرة أكثر خشوعاً]*

"اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ"

*[ثم بنبرة خاشعة مع تدرج في الصوت]*

"وهكذا بدأ نزول القرآن الكريم من اللوح المحفوظ - نورٌ من الله يهدي به من يشاء من عباده، فكان رحمةً للعالمين."
```

## Adattamento per Nano Banana

Il prompt di Sora è stato adattato togliendo i riferimenti che il servizio potrebbe bloccare (la figura del Profeta) e mantenendo stile Journey, deserto e atmosfera. Consigli: clip brevi, scene complesse divise in più prompt. Il testo dell'adattamento è nella chat [Tajweed Arabic lesson prompt](https://claude.ai/chat/df05070c-d91e-4bec-96a0-70d885707dec) e non è stato recuperato qui (export completo, OP-02).

## Copione della prima versione (con l'app), marzo 2025

Dalla chat [Tajweed App Interactive Video](https://claude.ai/chat/37ad5f1c-f2f3-4289-beb7-44ba923df909), turno 1. Struttura: introduzione con «وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا» e logo (15–20 s) → definizione del tajweed (30–40 s) → come recitava il Profeta, con la descrizione di ʿĀʾisha «ترتيلاً، يبين الحروف تبييناً» (30–40 s) → funzioni dell'app (40–60 s) → chiusura con Fāṭir 29 (15–20 s). Stile: verde-turchese `#1F4037`, `#2D6A4F`, marrone chiaro, oro `#DAA520`, font Cairo, natura stilizzata (alberi, nuvole, uccelli). Musica senza strumenti, voce maschile in fuṣḥā. Questa versione è stata superata dal concept "Journey" senza l'app, ma il copione può servire per lo spot dell'app.
