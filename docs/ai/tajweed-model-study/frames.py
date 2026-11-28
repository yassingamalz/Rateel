"""Print CTC greedy segments (phoneme, start s, end s) of the phonemes head for an audio file."""
import sys, librosa, torch
from transformers import AutoFeatureExtractor
from quran_muaalem.modeling.modeling_multi_level_ctc import Wav2Vec2BertForMultilevelCTC
from quran_muaalem.modeling.multi_level_tokenizer import MultiLevelTokenizer
M = "obadx/muaalem-model-v3_2"
wave, _ = librosa.load(sys.argv[1], sr=16000, mono=True)
proc = AutoFeatureExtractor.from_pretrained(M)
model = Wav2Vec2BertForMultilevelCTC.from_pretrained(M).eval()
tok = MultiLevelTokenizer(M)
f = proc([wave], sampling_rate=16000, return_tensors="pt")
with torch.no_grad():
    lg = model(f["input_features"], f["attention_mask"], return_dict=False)[0]["phonemes"][0]
ids = lg.argmax(-1).tolist()
dur = len(wave) / 16000
fs = dur / len(ids)
print(f"frames {len(ids)}, {fs*1000:.1f} ms/frame, features {f['input_features'].shape}")
v = tok.id_to_vocab["phonemes"]
prev = None
for i, t in enumerate(ids):
    if t != prev:
        if t != 0:
            print(f"{v[t]}\t{i*fs:.2f}")
    prev = t
