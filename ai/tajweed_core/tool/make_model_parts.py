"""Split the int8 ONNX model into parts < 30 MB and write manifest.json (SHA-256 of each part and of the whole).

The int8 model comes from the branch's export script (ai/tajweed-poc/export_onnx.py, branch
claude/quran-tajweed-correction-model-l36l1y): obadx/muaalem-model-v3_2 -> ONNX opset 17 -> dynamic int8.
Usage: python make_model_parts.py onnx_model/int8/muaalem.onnx out_dir
Upload every file of out_dir (manifest.json + *.part*) to one GitHub release; the app downloads
<release>/manifest.json and then the parts next to it.
"""

import hashlib
import json
import os
import sys

PART = 28_000_000

src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
whole = hashlib.sha256()
parts = []
with open(src, "rb") as f:
    k = 0
    while chunk := f.read(PART):
        k += 1
        name = f"muaalem-v3_2-int8.onnx.part{k:02d}"
        with open(os.path.join(out, name), "wb") as g:
            g.write(chunk)
        whole.update(chunk)
        parts.append({"name": name, "size": len(chunk), "sha256": hashlib.sha256(chunk).hexdigest()})
manifest = {
    "file": "muaalem-v3_2-int8.onnx",
    "model": "obadx/muaalem-model-v3_2, ONNX opset 17, dynamic int8 (onnxruntime 1.32)",
    "licence": "Quran Muaalem License (QML) 1.0",
    "size": sum(p["size"] for p in parts),
    "sha256": whole.hexdigest(),
    "parts": parts,
}
with open(os.path.join(out, "manifest.json"), "w") as f:
    json.dump(manifest, f, indent=1)
print(len(parts), "parts,", manifest["size"], "bytes, sha256", manifest["sha256"])
