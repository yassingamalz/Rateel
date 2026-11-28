# Tajweed correction model: study of Quran Muaalem for Rateel

Study of 2026-11-28 (Claude, owner's request). Scope: the AI that listens to a recitation and points out the mistakes,
needed by screen **09** (practice lesson / recitation) and screen **31** (daily practice). No app code was touched and no
screen was started.

Legend used in this document:
- **[read]**: stated in a source I read (file and line, paper table, model card…).
- **[measured]**: I ran it in the cloud container (numbers below are from this container only).
- **[deduced]**: my reasoning from what I read or measured; not stated by the authors.
- **🟡 Proposal**: my suggestion, waiting for the owner. Nothing here is decided.

## 0. Short answer: build our own model or use open source?

**Use the open-source project (Quran Muaalem), do not build a model from scratch** (🟡 proposal).
- It already does what 09/31 need: it compares what the learner said with what the ayah should sound like, and returns
  the wrong letters, harakat and durations (madd, ghunna) with their position in the Uthmani text **[read, measured]**.
- It ran in this container on CPU, unmodified (after pinning two library versions, §4.1), and found the mistakes I put in
  a recording of al-Husary **[measured]**.
- Building our own would mean the same pipeline again: ~850 h of annotated expert audio, a phonetic script of the Quran
  that encodes tajweed, GPU training **[read: paper §4–5]**. The authors released all of it (code, model, dataset).
- What we must still build ourselves is the **integration** (recording in Flutter, sending/running, showing the errors),
  the **teaching logic** (which errors to show a beginner, how), and an **evaluation on real learners' voices**.
- It comes with a licence (QML 1.0) whose conditions apply to **the whole Rateel app** (§7): above all, **no
  advertisements ever** and an **AI notice** before first use.

## 1. Sources

| Source | Version / date | Status |
|---|---|---|
| Branch `claude/quran-tajweed-correction-model-l36l1y`, `ai/tajweed-poc/` (README in Arabic, `try_muaalem.py`, `export_onnx.py`, `requirements.txt`) | commit `e606994` | read; both scripts **run** (§4) |
| `obadx/quran-muaalem` (GitHub) | `main` @ `b310432` (2026-11-03); PyPI `0.3.0` | read: README_EN, LICENSE, NOTICE, `inference.py`, `modeling/`, `engine/`, `app/`, docs |
| `obadx/quran-transcript` (GitHub) | `main` @ `e30c100` (2026-11-19); PyPI `0.6.4` | read: `tajweed_rulses.py`, `error_explainer.py` (structure), README |
| Paper arXiv 2509.00094 v2 ("Automatic Pronunciation Error Detection and Correction of the Holy Quran's Learners Using Deep Learning") | v2, 27 Aug 2026 | read: abstract, §4–7, tables 5–9 |
| Model card `obadx/muaalem-model-v3_2` (Hugging Face) | last modified 2025-09-04 | read: the card is the empty auto-generated template; metadata says `license: mit`, base `facebook/w2v-bert-2.0` |
| Dataset `obadx/muaalem-annotated-v3` (Hugging Face) | last modified 2025-09-04 | read: card, statistics, `moshaf_metadata` and `reciters_metadata` tables |
| QML 1.0 licence | `LICENSE` + `NOTICE` in the repo | read in full |
| **Issue #46 (mobile roadmap)** | – | **not read**: `github.com` issue pages and `api.github.com` are denied by this environment's network policy (403 from the proxy). Everything the old README says about it is unverified. |
| Official Colab, demo link | – | not run; the demo link in the README expired on 2025-08-27 **[read]** |

## 2. How it works

```
learner audio (16 kHz mono, one ayah or one waqf segment, ≤ 15 s in the API)
   │
   ▼
SeamlessM4T feature extractor: 80 mel bins, stride 2 → 160-dim frames
   │
   ▼
Wav2Vec2-BERT encoder (w2v-bert-2.0: 24 layers, hidden 1024, 16 heads) + adapter
   │                                    one output frame ≈ 40 ms [measured: 157 frames for 6.28 s]
   ├── head "phonemes"     (43 classes incl. blank)  ─┐
   └── 10 heads "sifat"    (3–4 classes each)         │ 11 linear CTC heads ("multi-level CTC")
                                                      ▼
                     greedy CTC decode → what was actually pronounced, in the Quran Phonetic Script
                                                      │
Uthmani text of the ayah ──► quran_phonetizer(MoshafAttributes) ──► reference: what should be pronounced
                                                      │
                                                      ▼
                     explain_error(): alignment of the two phonetic strings → list of errors
                     (position in the Uthmani text, expected vs heard, tajweed rule, length in harakat)
```

Sources: `config.json`, `preprocessor_config.json` (HF), `modeling_multi_level_ctc.py`, `inference.py`, paper §5 **[read]**.

### 2.1 The key idea: tajweed written as letters
`quran-transcript` turns the Uthmani text into the **Quran Phonetic Script (QPS)**, where durations and nasalisation are
explicit symbols **[read]**. Example from my runs, Al-Fatiha 1:2 with madd ʿarid of 4:
`ءَلحَمدُلِللَااهِرَببِلعَاالَمِۦۦۦۦن`: the shadda of «رَبِّ» is «بب», the final madd is «ۦۦۦۦ» (4 harakat).
A shortened madd becomes «ۦۦ», so a **tajweed duration error becomes a string difference** that can be counted.

### 2.2 The reference depends on the reading choices (`MoshafAttributes`)
Lengths that Hafs allows in several ways must be set before comparing: madd munfasil 2/3/4/5, muttasil 4/5/6, ʿarid
2/4/6, leen, ghunna of lam/raa, sakt places, etc. (about 40 fields) **[read: README_EN "Moshaf Attributes"]**.
If the reference says 4 and the learner (correctly) reads 2, it is reported as an error (§4.3) **[measured]**.

### 2.3 The comparison (`explain_error`)
- Error types: `normal` (letter added / missing / replaced), `tashkeel` (haraka), `tajweed` **[read: `error_explainer.py`]**.
- Tajweed rules known to the explainer (`tajweed_rulses.py`): madd (natural, lazim, ʿiwad, munfasil, muttasil, ʿarid,
  leen), noon sakin/tanween (izhar halqi, idgham with ghunna, iqlab, ikhfaa), meem sakin (izhar, idgham, ikhfaa), noon and
  meem mushaddad, idgham kamil, tashdeed, qalqalah, tasheel, hamzat al-wasl cases, iltiqaa as-sakinayn **[read]**.
  Madd and ghunna rules are checked by **counting** (`correctness: count`), the others by **match** **[read]**.
- Each error has `uthmani_pos` (character span in the ayah) → the app can colour the exact word **[read, measured]**.

### 2.4 The sifat heads
Ten heads predict for each phoneme group: hams/jahr, shidda/rakhawa, tafkheem/tarqeeq, itbaq, safeer, qalqala, tikraar,
tafashi, istitala, ghunna, each with a probability **[read]**. They are compared with the reference only in the Python
library (`try_muaalem.py` does it); **the HTTP API returns phonemes only** (engine `encode_response` returns
`{"phonemes": …}`; `/transcript` says "sifat: currently always null") **[read]**.

### 2.5 The ready-made API (two processes)
- **engine** (`quran-muaalem-engine`, port 8000, LitServe): audio → phonemes. Rejects audio > 15 s (HTTP 413) and pads
  every request to 15 s (`padding="max_length"`) **[read: `engine/serve.py`]**.
- **app** (`quran-muaalem-app`, port 8001, FastAPI): `/correct-recitation`, `/search`, `/transcript`.
  **`/correct-recitation` does not take the ayah**: it first **searches** the whole Quran for the heard phonemes
  (`error_ratio` 0.1 by default) and corrects against the best match **[read: `app/serve.py` l. 454–509]**.

## 3. What it detects and what it does not

| Detects (by design) | Source |
|---|---|
| Wrong, missing or extra letters; wrong haraka; missing shadda | **[read]** error types; **[measured]** §4.2 |
| Duration errors: every madd type, ghunna length (idgham, ikhfaa, iqlab, mushaddad noon/meem) | **[read]** `count` rules; **[measured]** madd ʿarid |
| Qalqalah, izhar/idgham/ikhfaa/iqlab as phonetic forms | **[read]** |
| Sifat of each letter (tafkheem/tarqeeq, qalqala…) with a probability (Python library only) | **[read]** |
| Which ayah was recited (API search) | **[read]**, **[measured]** |

| Does not detect / weak | Source |
|---|---|
| **Ishmam** (lip movement, not audible) | **[read]** paper §1, §8 |
| Rare rules: imala, rawm, tasheel; istitala of ض and tikraar of ر without them ("we expect our model will be unable…") | **[read]** paper §6.2 / §7 |
| **Ikhfaa** vs clear noon: F1 0.453 on learners | **[read]** paper table 9 |
| Riwayat other than **Hafs** (e.g. Warsh) | **[read]** paper §7 |
| Female / children's voices: trained on **male experts only**; 120 of the 159 benchmark samples are female | **[read]** paper §7, table 9 |
| Real beginners: training is 100% correct expert recitation; learner benchmark = **one verse (5:109), 159 samples, one annotator** | **[read]** paper §4, §7 |
| Melody (maqam), beauty, waqf/ibtida choice, meaning | **[deduced]**: nothing in the model or explainer addresses them |
| Audio > 15 s per request (API) | **[read]** |

## 4. My tests in the container

Container: 4 vCPU Intel Xeon @ 2.10 GHz, 15 GB RAM, no GPU. Python 3.13, torch 2.15.0+cpu, quran-muaalem 0.3.0 (PyPI),
quran-transcript 0.6.4, transformers 4.55.2, onnxruntime 1.32.0. Model `obadx/muaalem-model-v3_2` (safetensors
2,423,124,012 bytes; download ≈ 1.5 min here). Audio: everyayah.com (128 kbps MP3). Hugging Face, PyPI, everyayah.com and
arXiv were reachable; only GitHub issue pages were blocked (§1).

### 4.1 Problems found before it ran **[measured]**
1. **quran-muaalem 0.3.0 from PyPI does not import with transformers 5.x** (`_HIDDEN_STATES_START_POSITION` removed). The fix
   is on GitHub `main` (commit `9572aac`, "fix: import with transformers 5.x") but **not released**. Pinning
   `transformers==4.55.2` (the version in their `uv.lock`) works.
2. **The API app does not start with FastAPI 0.165** (`Form() got an unexpected keyword argument 'enum'`). Pinning
   `fastapi==0.116.1` (their `uv.lock`) works.
3. **API: madd ʿarid = 2 cannot be requested.** `madd_aared_len=2` alone → HTTP 500 (validation: leen 4 > ʿarid 2);
   adding `madd_alleen_len=2` → HTTP 422 ("Input should be 2, 4 or 6": the form sends the string "2"). So readers who use
   ʿarid 2 (al-Minshawi, al-Husary's Muʿallim) always get a false error through the API **[measured; cause deduced from the
   two error messages]**.
4. The branch's `requirements.txt` pins `quran-muaalem==0.2.2` (I used 0.3.0, the current one) and does not pin
   transformers/fastapi: it will hit problems 1–2 as written **[deduced]**.

### 4.2 `try_muaalem.py` on al-Husary, Al-Fatiha 1:2, then with errors **[measured]**
Errors were made by cutting the original audio (20 ms crossfade) at times located with the model's own CTC frames.

| Recording | Heard (QPS) | Reported | Correct? |
|---|---|---|---|
| al-Husary 1:2 original (6.3 s) | identical to the reference | no error | ✔ |
| madd of «ٱلْعَـٰلَمِينَ» cut by 0.65 s | `…ۦۦن` | tajweed: expected 4, heard 2, **madd ʿarid** | ✔ |
| same madd cut by 1.03 s | `…ۦۦن` | same (2 harakat) | ✔ |
| «لِلَّهِ» removed | `ءَلحَمدُرَببِ…` | 4 errors, all in «لِلَّهِ» (letters, madd) | ✔ |
| part of the ب of «رَبِّ» removed (0.14 s) | `…رَببِ…` | none | ✘ not detected (the cut may leave enough gemination: unverified by ear) |
| whole doubled ب of «رَبِّ» removed (0.21 s) | `…رَبِ…` | tashkeel: expected «ببِ», heard «بِ» (shadda missing) | ✔ |

Sifat errors (probability ≥ 0.7): none in any run. Time per ayah: model load 2–4 s, analysis 1.3–1.8 s for 5–6 s of audio;
whole process peak RSS ≈ 3.0 GB.

### 4.3 Clean expert recitations: false positives **[measured]**
44 ayat (Al-Fatiha, Al-Ikhlas, Al-Falaq, An-Nas) × al-Husary and al-Minshawi (murattal), 265.6 s of audio:
- With fixed settings (munfasil 4, muttasil 4, ʿarid 4): **13 errors, all false** — every al-Minshawi ayah ending in a madd
  ʿarid (he reads it with 2).
- Accepting any allowed length (ʿarid 2/4/6, munfasil 2/4/5, muttasil 4/5/6, best fit per ayah): **0 errors**.
- Sifat ≥ 0.7: 0. CPU real-time factor **0.24** (64.4 s for 265.6 s), peak RSS 3.4 GB.
- al-Husary al-Muʿallim (1:2) and al-ʿAfasy (1:2): ʿAfasy 0 errors; Muʿallim gets the same ʿarid false positive.
- **Caveat [read: dataset `moshaf_metadata`]**: al-Husary (moshaf 0.0–0.3, including al-Muʿallim) and al-Minshawi (1.0) are
  **in the training data**, so these clean results are optimistic. Mishary al-ʿAfasy is moshaf 19.0, one of the paper's
  **test** moshafs; whether everyayah's file is the same recording is unknown. The metadata also confirms the ʿarid
  lengths seen above (Minshawi 2, Muʿallim 2, Husary 0.1 = 4).

### 4.4 ONNX export (branch's `export_onnx.py`) **[measured]**
| | Size | Time, 1:2 (6.3 s) | Same phonemes as PyTorch |
|---|---|---|---|
| PyTorch fp32 | 2,423 MB (safetensors) | 1.76 s | – |
| ONNX fp32 (opset 17) | 2,424 MB (external data files) | 1.95 s | ✔ |
| **ONNX int8 (dynamic quantisation)** | **610 MB** (one file) | 1.73 s | ✔ |

Export + quantisation: 42 s, peak RSS 10.3 GB. Then on 49 files (the 44 ayat + 5 edited ones): **int8 output identical to
PyTorch on 49/49**; RTF int8 0.28 vs PyTorch 0.25 on this CPU (int8 is smaller here, not faster); peak RSS 2.7 GB vs
3.5 GB (whole Python process, feature extraction included). **No phone was used**: phone latency and memory are unknown.

**ONNX Runtime alone** (int8, features pre-computed, no torch/transformers in the process; `ort_only.py`), al-Husary 1:2
(6.3 s of audio), median of 3 runs **[measured, container CPU]**:

| CPU threads | Model load | RAM after load | Peak RAM | Time for 6.3 s of audio |
|---|---|---|---|---|
| 1 | 2.1 s | 1,086 MiB | 1,207 MiB | 3.58 s |
| 2 | 1.9 s | 1,071 MiB | 1,191 MiB | 2.94 s |
| 4 | 1.8 s | 1,091 MiB | 1,212 MiB | 1.94 s |

**[deduced]** On a phone the RAM need should be of the same order (≈ 1.1–1.2 GB for the model at work), and the time
likely longer than here, depending on the phone's cores; only a test on the owner's phone gives real numbers.

### 4.5 API server on CPU **[measured]**
`ACCELERATOR=cpu DTYPE=float32 quran-muaalem-engine` + `quran-muaalem-app`, requests with MP3/WAV files:

| Request | HTTP | Time | Result |
|---|---|---|---|
| al-Husary 1:2 | 200 | 2.1–2.4 s | ayah found (1:2), no error |
| madd shortened | 200 | 2.3 s | ʿarid 4 → 2 found |
| «رَبِّ» without shadda | 200 | 2.1 s | tashkeel error found |
| «لِلَّهِ» removed | **404** | 2.0 s | "No results found": with a missing word the search fails, so **no correction at all** |
| al-Minshawi 1:2 | 200 | 2.4 s | false ʿarid error (cannot be fixed through the API, §4.1-3) |
| 112:1, 114:1, al-ʿAfasy 1:2 | 200 | 1.9–2.8 s | correct ayah, no error |
| 1:7 (14.9 s) | 200 | 6.5 s | correct ayah, no error |
| 8 requests at once (1:2) | 200 | all ≈ 14.1–14.8 s | throughput ≈ 0.54 requests/s on 4 vCPU |

Memory: engine ≈ 3.2 GB + 0.4 GB, app ≈ 0.6 GB (RSS).

## 5. Accuracy declared by the authors **[read: paper v2, tables 8–9]**

| Test | Data | Result |
|---|---|---|
| Expert reciters (3 unseen moshafs: 19.0, 29.0, 30.0; male) | – | phoneme PER **0.543%**, average PER over 11 levels 0.21% |
| **Learners (qdat_bench)** | **159 samples of one verse (5:109)**, 120 female / 39 male, one annotator | phoneme PER **5.78%**; tajweed F1 **0.758** = mean of noon mushaddada **0.869**, ikhfaa **0.453**, qalqalah **0.953**; tajweed accuracy 0.847; madd RMSE (harakat) normal 0.46, munfasil 0.68, ʿarid 1.03 |

The paper reports the 0.847 as "84.7% accuracy on female recitations" in the text, while table 9 labels it `avg_tajweed_acc`
over all 159 samples **[read]**. The model card has no evaluation section, and the paper does not name which checkpoint
(v3_0 / v3_2) was evaluated **[read]**. Training: one epoch, H200, 7 h, bfloat16, samples ≤ 30 s **[read]**.

**What this means for Rateel [deduced]:** a madd error of 1 harakah is within the measured RMSE (0.6–1.0), so "4 instead of
6" is reliable only as a trend; ikhfaa feedback would be wrong about half the time; there is **no published number for
beginners making beginner mistakes on many verses**, which is exactly our case.

## 6. Integration options with Flutter

The old README's mobile plan targets the Capacitor app; the app is now Flutter (`app_flutter/`). Today `pubspec.yaml` has
`audioplayers` and `shared_preferences` but **no recording package** **[read]**.

Common to every option (🟡 proposals):
- Record **one ayah or one waqf segment** at a time (≤ 15 s), 16 kHz mono, with a Flutter recording package (to choose).
- Rateel **knows which ayah the learner must recite**: compare against that ayah, not against a search of the whole Quran
  (avoids the 404 of §4.5 and wrong-ayah matches).
- Compare against **every allowed reading** (ʿarid 2/4/6, munfasil 2/4/5…) or the reading the lesson teaches, never a single
  fixed one (§4.3).
- Show only errors the lesson is about (e.g. lesson on madd → madd errors), worded as "listen again / check with your
  teacher", never as a verdict; hide ikhfaa and sifat until measured on our users.

### A. Server (our own endpoint on top of the library)
- **How:** a small Python service wrapping `Muaalem` + `quran_phonetizer` + `explain_error`, taking `{audio, sura, aya,
  reading}` (🟡 proposal: our own endpoint instead of `/correct-recitation`, because of the search step and §4.1-3; the
  official engine can still be used for the model part). Flutter sends the recording (multipart), receives JSON errors.
- **Size in the app:** none. **Latency [measured, CPU 4 vCPU]:** ≈ 2 s per ayah of 5–6 s, plus upload; requests queue
  (≈ 0.54/s). GPU latency/throughput: not measured. Paper/README: "1.5 GB of GPU memory" **[read]**.
- **Cost:** an always-on machine with ≥ 4–6 GB RAM (CPU) or a GPU, plus bandwidth; I did not price providers (no invented
  figures). Requires a backend, which Rateel does not have yet (local-first, `DECISIONS.md` 2026-11-27).
- **Privacy:** the learner's voice leaves the phone → explicit consent, no storage by default, retention policy, HTTPS;
  voice recordings are personal data (GDPR, [deduced]).
- **Offline:** no.

### B. On-device ONNX (int8)
- **How:** ONNX Runtime from Flutter (a plugin or platform channels; to choose), plus in Dart/native: the SeamlessM4T mel
  features (must match the Python extractor), greedy CTC decode, and the comparison. The phonetizer is Python: pre-compute
  the reference QPS + mappings for the ayat used in lessons (every allowed reading) as JSON, and port the alignment of
  `explain_error` to Dart (🟡 proposal).
- **Size [measured]:** 610 MB model file → cannot go in the APK; optional download after install (Wi-Fi).
- **Latency / memory on a phone:** **unknown**; container CPU, ONNX Runtime alone: 1.9–3.6 s for 6.3 s of audio (4→1
  threads), ≈ 1.2 GB RAM at peak (§4.4). Must be measured on the owner's phone before any decision.
- **Cost:** no server; development work (features, decoding, comparison, download manager). **Privacy:** audio never leaves
  the phone. **Offline:** yes. **Licence:** distributing the model inside/with the app = distribution of the Work (§7).

### C. Small distilled / mobile model
- **How:** train a small student model (teacher = Muaalem) on the open dataset (848 h, ≈ 97 GB of parquet **[read: sum of
  `download_size`]**), or wait for the authors' mobile work (issue #46, **not read**, see §1).
- **Size / latency / accuracy:** unknown until trained; GPU training needed. A distilled model is a **Model Derivative**
  under QML (same conditions) **[read: QML §1.4]**.
- **Cost:** the highest in work and risk; only worth it if A and B fail. Audio in the dataset comes from published
  recordings (islamway.net links in the metadata) **[read]**; their own rights are not discussed in the card **[read]**.

### Summary
| | A. Server | B. ONNX on device | C. Distilled |
|---|---|---|---|
| App size | 0 | +610 MB download | unknown (smaller) |
| Latency | ≈ 2 s CPU + network **[measured]** | unknown on phone | unknown |
| Running cost | server, always on | none | none |
| Work | low–medium | high | very high |
| Privacy | voice uploaded | local | local |
| Offline | no | yes | yes |
| Ready to try | **now** | export works, app side to build | no |

🟡 **Proposal:** start with **A** (own endpoint, fixed ayah, all readings) for the 09 prototype and a test with real learners;
in parallel, measure **B** on the owner's phone (a test page outside the app's screens, only with the owner's yes). Decide C
only after B's numbers and after reading issue #46.

## 7. QML 1.0 obligations for Rateel **[read: `LICENSE`]**

The QML is Apache 2.0 plus additional conditions. A **Covered Product** is "any application, website, or service, taken as a
whole, that includes, runs, or is built upon the Work" (also as a Hosted Service, §1.4). Rateel with Muaalem (server or
on-device) is a Covered Product **as a whole**, not only screen 09.

1. **AI advisory notice (2.1)**: shown to every user **before first use** and **always reachable** from the main menu or an
   About/Help screen; in every language of the interface **and always in Arabic**; keeps the four elements (AI may err; for
   assistance only, not to be relied upon; not a replacement for a proficient authorised teacher; the Quran is received only
   by mushafahah). At least as prominent as other legal/About text, not smaller than body text. Never present the feature as
   a substitute for a teacher (2.1 f). The official texts (22 languages, Arabic and Italian included) are in `NOTICE`; using them word for word satisfies the language rule.
2. **No advertisements, ever, anywhere in the app (2.3 a)**: no ads, no ad-serving code, no ad attribution or conversion
   tracking, no cross-app tracking for ads, no selling/sharing user data for ads. General analytics and crash reports are
   allowed if not used for ads. Allowed: own products, donations (donors named without promotion), fees, paid human teachers
   without paid ranking.
3. **Free path if Rateel charges anything (2.3 b)**: automatic free access in World Bank low-income and lower-middle-income
   economies (by IP / store region / locale), and a simple in-app free path for anyone who cannot pay (self-declaration or
   community code), visible **before** any payment request.
4. **Islamic Sharia compliance (2.2)** of every use and deployment.
5. **Apache conditions**: give users a copy of the licence (full QML, including Appendix A) and the NOTICE when the Work is
   distributed (e.g. model downloaded to the phone, or Python code shipped); mark modified files (2.4, Apache §4).
6. **Termination (2.5)**: a breach not cured within 30 days ends the licence.
7. **Licence mismatch to clear [read]**: the Hugging Face metadata of the model and of the dataset say `license: mit`; the code
   repo, its README and `NOTICE` say QML 1.0 and define the Model as part of the Work. 🟡 Proposal: treat the model as QML
   and ask the authors (quran.muaalem@gmail.com) to confirm in writing.

## 8. Risks

| Risk | Why | Source |
|---|---|---|
| False errors that discourage beginners | fixed reading settings (§4.3); ikhfaa F1 0.45; madd RMSE up to 1 harakah | **[measured]**, **[read]** |
| Unknown accuracy on **our** users (beginners, women, children, phone mics, noise) | no benchmark exists for them | **[read]** paper §7 |
| Missing words make the API give **no** feedback | search step (404) | **[measured]** |
| Dependency drift | two breaking pins already (§4.1); fix unreleased on PyPI | **[measured]** |
| Size / speed on phones | 610 MB int8; phone numbers unknown | **[measured]** / unknown |
| Licence spreads to the whole app (ads, pricing, notice) | QML §1.4, 2.1, 2.3 | **[read]** |
| Licence ambiguity (MIT on HF vs QML) | §7.7 | **[read]** |
| Server needed although Rateel is local-first | option A | `DECISIONS.md` 2026-11-27 |
| Voice data handling | uploads in option A | **[deduced]** |
| Small team upstream | most commits by one author (`git shortlog`: 125 of 141 commits in quran-muaalem and 427 of 429 in quran-transcript are by the author's accounts (obadx / Abdullah)); no support commitment | **[measured]** / **[deduced]** |

## 9. Open questions for the owner

**Owner's answers (2026-11-28):** (1) asked whether on-device is heavy → measured §4.4 (ONNX Runtime alone); (2) **ads / paid
plans: «sì»** → conflicts with QML 2.3(a) if ads are meant (ads are forbidden in the whole app with Muaalem); to clarify:
ads, subscription, or both; (3) reading: **«tutto»**, accept every allowed length; (4) the AI notice was explained to the
owner, place still to decide; (5) recording real learners with consent: **yes**.

1. **Server or on-device first?** (my proposal: server for the prototype, phone measurement in parallel, §6).
2. Does Rateel plan **ads, paid plans or ad-tracking SDKs**, now or later? With Muaalem, ads are forbidden for the whole app,
   and any fee needs the free path (§7).
3. Which **reading** does Rateel teach (e.g. munfasil 4 or 2, ʿarid 2/4/6)? Accept every allowed length, or only the taught one?
4. Where should the **AI notice** live (first start / onboarding 30, settings 23 «about», before the first recitation in 09)?
5. Can we record **real learners** (you, family, students) with consent, to measure errors on our users before release?
6. Who writes to the authors (licence MIT vs QML; plans for mobile, issue #46)? I cannot reach GitHub issues from here;
   adding `github.com` to the environment's allowed domains would let a session read issue #46.
7. Which errors does a beginner see in 09 and 31: all, or only the rule of the lesson? Show sifat at all?
8. Budget and owner of a **backend** (option A also opens the door to accounts/sync, `BACKLOG.md` screen 30).

## 10. Reproduce

Scripts used for §4 (helpers, not app code): `docs/ai/tajweed-model-study/` (`run_measured.py`, `batch.py`, `cut.py`,
`frames.py`, `onnx_check.py`, `README.md`). Recordings are downloaded from everyayah.com, not committed.
