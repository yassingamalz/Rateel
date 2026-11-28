"""Compare greedy phonemes of PyTorch fp32 vs ONNX int8 on many files; time int8; then explain errors with int8 output."""
import sys, time, resource, librosa, numpy as np, torch, onnxruntime as ort
from transformers import AutoFeatureExtractor
from quran_muaalem.modeling.modeling_multi_level_ctc import Wav2Vec2BertForMultilevelCTC
from quran_muaalem.modeling.multi_level_tokenizer import MultiLevelTokenizer
M = "obadx/muaalem-model-v3_2"
proc = AutoFeatureExtractor.from_pretrained(M); tok = MultiLevelTokenizer(M)
v = tok.id_to_vocab["phonemes"]
def greedy(lg):
    out, prev = [], None
    for i in lg.argmax(-1):
        if i != prev and i != 0: out.append(v[int(i)])
        prev = i
    return "".join(out)
mode = sys.argv[1]
files = [l.split()[0] for l in open(sys.argv[2]) if l.strip()]
if mode == "torch":
    model = Wav2Vec2BertForMultilevelCTC.from_pretrained(M).eval()
else:
    so = ort.SessionOptions()
    sess = ort.InferenceSession("/home/user/onnx/onnx_model/int8/muaalem.onnx", so, providers=["CPUExecutionProvider"])
    names = [o.name for o in sess.get_outputs()]
tt = ta = 0
for f in files:
    w, _ = librosa.load(f, sr=16000, mono=True)
    feat = proc([w], sampling_rate=16000, return_tensors="pt")
    t0 = time.time()
    if mode == "torch":
        with torch.no_grad():
            lg = model(feat["input_features"], feat["attention_mask"], return_dict=False)[0]["phonemes"][0].numpy()
    else:
        outs = sess.run(None, {"input_features": feat["input_features"].numpy(), "attention_mask": feat["attention_mask"].numpy()})
        lg = outs[names.index("phonemes")][0]
    dt = time.time() - t0; tt += dt; ta += len(w)/16000
    print(f"{f.split('/')[-1]}\t{dt:.2f}\t{greedy(lg)}")
print(f"# {mode}: audio {ta:.1f}s, model time {tt:.1f}s, RTF {tt/ta:.2f}, peak RSS {resource.getrusage(resource.RUSAGE_SELF).ru_maxrss/1024:.0f} MiB")
