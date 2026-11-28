# Rateel tajweed desk (PC test app, not Rateel)

Interactive desktop app to try the Quran Muaalem model on the PC (owner's request, 2026-11-28: «super interattivo»,
«audio e fonemi sincronizzati»). Windows (built by GitHub Actions) and Linux (built and checked in the cloud container).

## What it does
- 28 ayat (as the phone lab), searchable list on the left; al-Husary's recitation of each one is bundled (`assets/husary/`).
- **Two tracks, yours and al-Husary's**: waveform + every phoneme group placed in time (CTC frames of the model, ≈ 40 ms),
  coloured by result (green correct, orange tajweed, red letter, violet haraka, grey extra sound); madd groups read
  «ي×4». Time runs from the right like the Arabic text (switchable).
- **Everything is linked**: hover a letter in one track → it lights up in the other track and in the ayah; click a
  letter → selected and played; double-click → the whole word; click on the waveform → play from there; click a word of
  the ayah → plays it; error list and «Mudud» tab (your duration vs al-Husary's per madd) select and play A/B.
- **A/B**: your letter (or word) then al-Husary's, at 0.5× / 0.75× / 1×.
- Record (microphone, 16 kHz WAV) or open a WAV file; every allowed reading accepted, or fixed 4/4/4 (switch).
- Keys: Space you · H al-Husary · R record · ←/→ letter · Enter letter (Shift: al-Husary) · W word · B A/B
  (Shift: word) · F fixed reading · +/− zoom · 1/2/3 speed · Esc stop.
- The model runs on the PC in its own isolate (window never freezes): ONNX Runtime **1.32.0** through the `onnxruntime`
  FFI package, vendored in `third_party/onnxruntime` (its 1.15.1 binaries cannot run the int8 model: no `ConvInteger`
  with int8 weights; 1.32.0 is downloaded from Microsoft's NuGet package at build time, SHA-256 checked).
- AI notice (QML 2.1, Arabic + Italian) at start and from ⓘ; QML licence inside.

## Use (Windows)
1. GitHub → Actions → «Tajweed desk (Windows)» → latest run → Artifacts → `rateel-tajweed-desk-windows` (zip).
2. Unzip, run `tajweed_desk.exe`.
3. «Scegli .onnx» → `muaalem-v3_2-int8.onnx` (same file as the phone app). The choice is remembered.

## Checks done (cloud container, Linux build, 2026-11-28)
- `flutter analyze`: no issues. Engine test (`test/engine_test.dart`, ONNX Runtime 1.32.0 via FFI): al-Husary 1:2 →
  the same phonemes as PyTorch, 0 errors, load ≈ 2 s, run ≈ 2 s (4 threads); final madd ʿarid placed at 3.91–5.27 s.
- Screenshots of the Linux app under Xvfb with the edited recordings of the study (madd shortened, shadda removed):
  the error appears in the track, the ayah and the details (`docs/ai/tajweed-model-study/desk-*.png`).
- **Not checked:** the Windows build (no Windows here; the workflow runs on GitHub), the microphone and the sound
  output (none in the container), keyboard and mouse by hand.

## Review aids
Environment variables: `LAB_MODEL=<model>`, `LAB_DEMO=<sura>:<aya>`, `LAB_DEMO_WAV=<wav>`, `LAB_DEMO_FIXED=1`,
`LAB_DEMO_SELECT=<group>|err`.
