# Helper scripts of the tajweed model study (2026-11-28)

Used for `docs/ai/TAJWEED-MODEL.md` §4. Not app code. Paths are the ones of the cloud container (`/home/user/...`):
adapt them before running elsewhere.

Environment that worked (CPU):
```
python3 -m venv venv && . venv/bin/activate
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install "quran-muaalem[engine]==0.3.0" "transformers==4.55.2" "fastapi==0.116.1" librosa onnx onnxruntime pandas pyarrow
```
(`transformers` 5.x breaks the import of quran-muaalem 0.3.0; FastAPI 0.165 breaks the API app.)

| Script | What it does |
|---|---|
| `run_measured.py` | runs `try_muaalem.py` (branch `claude/quran-tajweed-correction-model-l36l1y`) and prints wall time and peak RSS |
| `frames.py` | prints the CTC phoneme segments with their start time (used to place the cuts) |
| `cut.py` | removes a time span from a recording with a 20 ms crossfade (to make "errors") |
| `batch.py` | loads the model once and runs a list `file sura aya`; tries every allowed madd length; counts phoneme and sifat errors |
| `onnx_check.py` | `torch` or `int8` mode: phonemes and timing per file, to compare PyTorch with the int8 ONNX model |

Audio: `https://everyayah.com/data/<Reciter>/<sss><aaa>.mp3` (Husary_128kbps, Minshawy_Murattal_128kbps,
Husary_Muallim_128kbps, Alafasy_128kbps). Cuts used: `madd_short` 4.30–4.95 s, `madd_veryshort` 4.12–5.15 s,
`shadda_rabbi` 2.62–2.76 s, `shadda_rabbi_long` 2.58–2.79 s, `drop_lillahi` 1.42–2.30 s of Husary 001002.
