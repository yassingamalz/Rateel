"""
تجربة (المرحلة 3): تصدير الموديل لـ ONNX وضغطه لـ int8، كخطوة أولى للتشغيل على الموبايل.

الاستخدام:
    python export_onnx.py --out onnx_model --test-audio recording.wav

بيطلّع:
    onnx_model/fp32/muaalem.onnx   (float32، أكبر من 2GB فبيتحفظ معاه ملفات أوزان جنبه)
    onnx_model/int8/muaalem.onnx   (int8، حوالي ربع الحجم)
وبيقارن ناتج كل نسخة بناتج PyTorch على نفس التسجيل.

ملحوظة: الموديل بياخد "features" (Mel filterbank) مش الصوت الخام. على الموبايل
لازم نحسب نفس الـ features (SeamlessM4TFeatureExtractor) قبل ما ندّيها للموديل.
"""

import argparse
import os
import time

import librosa
import numpy as np
import onnxruntime as ort
import torch
from onnxruntime.quantization import QuantType, quantize_dynamic
from transformers import AutoFeatureExtractor

from quran_muaalem.modeling.modeling_multi_level_ctc import Wav2Vec2BertForMultilevelCTC
from quran_muaalem.modeling.multi_level_tokenizer import MultiLevelTokenizer

SAMPLING_RATE = 16000


class ExportWrapper(torch.nn.Module):
    """ONNX can't return a dict, so return the level logits as a tuple."""

    def __init__(self, model, levels):
        super().__init__()
        self.model = model
        self.levels = levels

    def forward(self, input_features, attention_mask):
        logits = self.model(input_features, attention_mask, return_dict=False)[0]
        return tuple(logits[level] for level in self.levels)


def greedy_phonemes(logits: np.ndarray, id_to_vocab: dict, blank_id: int) -> str:
    """Plain CTC greedy decode: collapse repeats, drop blanks."""
    ids = logits.argmax(-1)
    out, prev = [], None
    for i in ids:
        if i != prev and i != blank_id:
            out.append(id_to_vocab[int(i)])
        prev = i
    return "".join(out)


def dir_size_mb(path: str) -> float:
    return sum(os.path.getsize(os.path.join(path, f)) for f in os.listdir(path)) / 1e6


def run_onnx(path, features, levels):
    session = ort.InferenceSession(path, providers=["CPUExecutionProvider"])
    t0 = time.time()
    outs = session.run(
        None,
        {
            "input_features": features["input_features"].numpy(),
            "attention_mask": features["attention_mask"].numpy(),
        },
    )
    return dict(zip(levels, outs)), time.time() - t0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="obadx/muaalem-model-v3_2")
    parser.add_argument("--out", default="onnx_model")
    parser.add_argument("--test-audio", required=True)
    args = parser.parse_args()
    fp32_dir = os.path.join(args.out, "fp32")
    int8_dir = os.path.join(args.out, "int8")
    os.makedirs(fp32_dir, exist_ok=True)
    os.makedirs(int8_dir, exist_ok=True)

    model = Wav2Vec2BertForMultilevelCTC.from_pretrained(args.model).eval()
    processor = AutoFeatureExtractor.from_pretrained(args.model)
    tokenizer = MultiLevelTokenizer(args.model)
    levels = list(model.level_to_lm_head.keys())
    blank_id = 0  # same CTC blank the engine server decodes with

    wave, _ = librosa.load(args.test_audio, sr=SAMPLING_RATE, mono=True)
    features = processor([wave], sampling_rate=SAMPLING_RATE, return_tensors="pt")

    # المرجع: PyTorch float32
    t0 = time.time()
    with torch.no_grad():
        torch_logits = model(
            features["input_features"], features["attention_mask"], return_dict=False
        )[0]
    torch_time = time.time() - t0
    torch_text = greedy_phonemes(
        torch_logits["phonemes"][0].numpy(), tokenizer.id_to_vocab["phonemes"], blank_id
    )

    # تصدير float32
    fp32_path = os.path.join(fp32_dir, "muaalem.onnx")
    torch.onnx.export(
        ExportWrapper(model, levels),
        (features["input_features"], features["attention_mask"]),
        fp32_path,
        input_names=["input_features", "attention_mask"],
        output_names=levels,
        dynamic_axes={
            "input_features": {0: "batch", 1: "frames"},
            "attention_mask": {0: "batch", 1: "frames"},
            **{level: {0: "batch", 1: "out_frames"} for level in levels},
        },
        opset_version=17,
        dynamo=False,
    )

    # ضغط int8 (الأوزان بس، والحسابات بتتعمل بـ int8 وقت التشغيل)
    int8_path = os.path.join(int8_dir, "muaalem.onnx")
    quantize_dynamic(
        fp32_path,
        int8_path,
        weight_type=QuantType.QInt8,
        use_external_data_format=False,
    )

    print(f"PyTorch fp32: {torch_time:.2f}s\n  {torch_text}")
    for name, path in (("fp32", fp32_path), ("int8", int8_path)):
        logits, seconds = run_onnx(path, features, levels)
        text = greedy_phonemes(
            logits["phonemes"][0], tokenizer.id_to_vocab["phonemes"], blank_id
        )
        size_mb = dir_size_mb(os.path.dirname(path))
        verdict = "مطابق" if text == torch_text else "مختلف"
        print(f"ONNX {name} ({size_mb:.0f}MB): {seconds:.2f}s [{verdict}]\n  {text}")


if __name__ == "__main__":
    main()
