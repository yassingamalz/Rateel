# Rateel tajweed lab (test app, not Rateel)

Shared code (features, comparison, timings, model files) lives in `ai/tajweed_core/` since 2026-11-28; the PC version
is `ai/tajweed_desk/`.

A small Android app to try the Quran Muaalem model **on the phone** (owner's request, 2026-11-28). It is separate from
`app_flutter/` (own package `it.rateel.tajweed_lab`, installs next to Rateel). Study: `docs/ai/TAJWEED-MODEL.md`.

What it does:
1. Downloads the int8 ONNX model (~610 MB, 22 parts with SHA-256, resumable) or imports it from a file.
2. Loads it with ONNX Runtime (1, 2 or 4 CPU threads) and shows load time and RAM.
3. For 28 ayat (Al-Fatiha, Al-ʿAsr, Al-Kawthar, Al-Ikhlas, Al-Falaq, An-Nas): listen to al-Husary (everyayah.com),
   record yourself (16 kHz WAV, max 15 s), analyse **on the phone**: features → model → phonemes → comparison with every
   allowed reading (or the fixed reading ʿarid 4 · munfasil 4 · muttasil 4, switch on the page).
4. Shows the errors (word in red, Arabic explanation), the timings (features, model, × real time) and RAM.
5. Saves every take (`.wav` + `.json` with the result) in `Android/data/it.rateel.tajweed_lab/files/takes/` for the
   evaluation with real learners.
6. AI notice (QML 2.1, Arabic + Italian) before first use and from the ⓘ button; QML licence and NOTICE inside the app.

## Code
| File | What |
|---|---|
| `../tajweed_core/lib/features.dart` | port of `SeamlessM4TFeatureExtractor` (window and mel bank from the Python extractor, `assets/*.f32`) |
| `../tajweed_core/lib/explain.dart` | port of quran-transcript 0.6.4 `explain_error` + greedy CTC decode + choice of the reading |
| `../tajweed_core/lib/model_store.dart` | download in parts / import of the model |
| `android/.../MainActivity.kt` | runs ONNX Runtime 1.28 (official package) on a background thread; device RAM and last exit reason |
| `lib/main.dart` | the two pages |
| `../tajweed_core/assets/ayat.json` | reference phonemes of the 28 ayat × every allowed reading (57 distinct references) |
| `../tajweed_core/tool/build_assets.py` | makes the assets and the test vectors (Python env of `docs/ai/tajweed-model-study/README.md`) |
| `../tajweed_core/tool/make_model_parts.py` | splits the int8 model into parts + `manifest.json` |

## Checks done in the cloud container (2026-11-28)
- `flutter analyze`: no issues. `flutter test`: features equal to Python on al-Husary 1:2 (max difference 6.7e-6);
  comparison equal to Python `explain_error` on **728/728** cases; download in parts from a local server: 609,538,052 bytes,
  SHA-256 equal to the manifest.
- Dart features → int8 ONNX (Python onnxruntime) → same phonemes as PyTorch on the 5 edited recordings of the study.
- **Not checked:** the app itself on a phone or emulator (no emulator in the container): recording, ONNX Runtime on Android,
  timings and memory are the owner's test.

## Build
```
cd ai/tajweed_lab
flutter build apk --release --target-platform android-arm64 --build-name=0.1.2 --build-number=3   # ~19 MB
```
Only arm64 phones; native libraries compressed (`android/app/build.gradle.kts`). In the cloud container Maven Central
answers 429: a container-only Gradle init script that puts Google's mirror first was used (see `DECISIONS.md`).

## Model hosting
The default download address is `https://github.com/yassingamalz/Rateel/releases/download/tajweed-lab-model-v1/manifest.json`:
a GitHub release `tajweed-lab-model-v1` with `manifest.json`, the 22 `muaalem-v3_2-int8.onnx.partNN` files, `LICENSE.txt`
and `NOTICE.txt` (QML: the licence goes with every copy of the model). Another address can be typed in the app.
Publishing the release makes the model public: it is a redistribution under QML 1.0.
