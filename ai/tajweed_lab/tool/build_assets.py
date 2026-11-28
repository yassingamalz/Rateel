"""Build the data assets of the tajweed lab app (run once, output is committed).

Needs the Python environment of docs/ai/tajweed-model-study/README.md
(quran-muaalem 0.3.0, quran-transcript 0.6.4, transformers 4.55.2).

Writes into ai/tajweed_lab/assets/:
  ayat.json      reference phonemes of the test ayat, one entry per allowed reading (madd lengths),
                 with the phoneme->Uthmani map and the tajweed rules of every phoneme group
                 (quran-transcript 0.6.4, the version tested in docs/ai/TAJWEED-MODEL.md)
  vocab.json     id -> phoneme of the model's phonemes head
  window.f32     povey window (400 float32)
  mel.f32        kaldi mel filter bank (257 x 80 float32, row-major [frequency][mel])
With --tests DIR also writes test vectors for the Dart unit tests:
  explain_cases.json   random mutated predictions + the errors of quran_transcript.explain_error
  husary_001002.wav    16 kHz PCM16 recording, and husary_001002_features.f32 (+ shape) from the Python extractor
"""

import argparse
import itertools
import json
import os
import random

import numpy as np

from quran_transcript import Aya, MoshafAttributes, explain_error, quran_phonetizer
from quran_transcript.phonetics.error_explainer import (
    extract_ref_phonetic_to_uthmani,
    get_ref_phonetic_groups_tajweed_rules,
)
from quran_transcript.phonetics.sifa import chunck_phonemes

MODEL = "obadx/muaalem-model-v3_2"
# Al-Fatiha, Al-Asr, Al-Kawthar, Al-Ikhlas, Al-Falaq, An-Nas
SURAS = {1: 7, 103: 3, 108: 3, 112: 4, 113: 5, 114: 6}
SURA_NAMES = {1: "الفاتحة", 103: "العصر", 108: "الكوثر", 112: "الإخلاص", 113: "الفلق", 114: "الناس"}
# Every reading allowed for Hafs that the owner accepts (2026-11-28: «tutto»)
AARED = [2, 4, 6]
MONFASEL = [2, 3, 4, 5]
MOTTASEL = [4, 5, 6]


def rule_to_json(rule):
    return {
        "kind": type(rule).__name__,
        "ar": rule.name.ar,
        "en": rule.name.en,
        "golden_len": rule.golden_len,
        "correctness": rule.correctness_type,
        "tag": rule.tag,
        "offset": getattr(rule, "offset", 0),
    }


def reference(uthmani, sura, aared, monfasel, mottasel):
    moshaf = MoshafAttributes(
        rewaya="hafs",
        madd_monfasel_len=monfasel,
        madd_mottasel_len=mottasel,
        madd_mottasel_waqf=mottasel,
        madd_aared_len=aared,
        madd_alleen_len=aared,
    )
    return quran_phonetizer(uthmani, moshaf, remove_spaces=True)


def variant_json(uthmani, ref, label):
    ph = ref.phonemes
    groups = chunck_phonemes(ph)
    ph_to_uth = extract_ref_phonetic_to_uthmani(ref.mappings)
    rules = get_ref_phonetic_groups_tajweed_rules(groups, ref.mappings, ph_to_uth)
    return {
        "label": label,
        "ph": ph,
        "ph_to_uth": [ph_to_uth[i] for i in range(len(ph))],
        "uth_has_rules": [i for i, m in enumerate(ref.mappings) if m.tajweed_rules],
        "group_rules": [[rule_to_json(r) for r in rs] for rs in rules],
    }


def error_json(e):
    return {
        "uthmani_pos": list(e.uthmani_pos),
        "ph_pos": list(e.ph_pos),
        "error_type": e.error_type,
        "speech_error_type": e.speech_error_type,
        "expected_ph": e.expected_ph,
        "predicted_ph": e.preditected_ph,
        "expected_len": e.expected_len,
        "predicted_len": e.predicted_len,
        "ref_rules": [r.name.en for r in (e.ref_tajweed_rules or [])],
        "replaced_rules": [(r.name.en, r.tag) for r in (e.replaced_tajweed_rules or [])],
    }


def mutate(ph, rng, alphabet):
    s = list(ph)
    for _ in range(rng.randint(1, 4)):
        op = rng.choice(["del", "ins", "rep", "dup", "cut"])
        if not s:
            break
        i = rng.randrange(len(s))
        if op == "del":
            del s[i]
        elif op == "ins":
            s.insert(i, rng.choice(alphabet))
        elif op == "rep":
            s[i] = rng.choice(alphabet)
        elif op == "dup":
            s.insert(i, s[i])
        else:
            j = min(len(s), i + rng.randint(2, 6))
            del s[i:j]
    return "".join(s)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(os.path.dirname(__file__), "..", "assets"))
    ap.add_argument("--tests", default=None)
    ap.add_argument("--wav-source", default=None, help="Husary 001002 audio (any format) for the feature test")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)

    ayat = []
    for sura, n in SURAS.items():
        for aya in range(1, n + 1):
            uthmani = Aya(sura, aya).get().uthmani
            variants, seen = [], {}
            for aared, monfasel, mottasel in itertools.product(AARED, MONFASEL, MOTTASEL):
                ref = reference(uthmani, sura, aared, monfasel, mottasel)
                label = {"aared": aared, "monfasel": monfasel, "mottasel": mottasel}
                if ref.phonemes in seen:
                    seen[ref.phonemes]["labels"].append(label)
                    continue
                v = variant_json(uthmani, ref, label)
                v["labels"] = [label]
                seen[ref.phonemes] = v
                variants.append(v)
            ayat.append({"sura": sura, "aya": aya, "sura_name": SURA_NAMES[sura], "uthmani": uthmani, "variants": variants})
    with open(os.path.join(args.out, "ayat.json"), "w", encoding="utf-8") as f:
        json.dump({"source": "quran-transcript 0.6.4", "ayat": ayat}, f, ensure_ascii=False, separators=(",", ":"))

    from quran_muaalem.modeling.multi_level_tokenizer import MultiLevelTokenizer
    from transformers import AutoFeatureExtractor

    tok = MultiLevelTokenizer(MODEL)
    vocab = tok.id_to_vocab["phonemes"]
    with open(os.path.join(args.out, "vocab.json"), "w", encoding="utf-8") as f:
        json.dump({str(k): v for k, v in sorted(vocab.items())}, f, ensure_ascii=False)

    proc = AutoFeatureExtractor.from_pretrained(MODEL)
    np.asarray(proc.window, dtype="<f4").tofile(os.path.join(args.out, "window.f32"))
    mel = np.asarray(proc.mel_filters, dtype="<f4")
    assert mel.shape == (257, 80), mel.shape
    mel.tofile(os.path.join(args.out, "mel.f32"))
    print("ayat", len(ayat), "variants", sum(len(a["variants"]) for a in ayat))

    if args.tests:
        os.makedirs(args.tests, exist_ok=True)
        rng = random.Random(7)
        alphabet = list("ءبتدرسصعلمنهويا") + ["ۦ", "ۥ", "َ", "ُ", "ِ", "ڇ", "ں", "۾"]
        cases = []
        for a in ayat:
            for v in a["variants"][:3]:
                ref = reference(a["uthmani"], a["sura"], v["labels"][0]["aared"], v["labels"][0]["monfasel"], v["labels"][0]["mottasel"])
                preds = [ref.phonemes] + [mutate(ref.phonemes, rng, alphabet) for _ in range(12)]
                for p in preds:
                    try:
                        errs = explain_error(a["uthmani"], ref.phonemes, p, ref.mappings)
                    except Exception as ex:  # the Python explainer can fail on odd inputs: record it
                        cases.append({"sura": a["sura"], "aya": a["aya"], "ref": ref.phonemes, "pred": p, "exception": type(ex).__name__})
                        continue
                    cases.append({"sura": a["sura"], "aya": a["aya"], "ref": ref.phonemes, "pred": p, "errors": [error_json(e) for e in errs]})
        with open(os.path.join(args.tests, "explain_cases.json"), "w", encoding="utf-8") as f:
            json.dump(cases, f, ensure_ascii=False)
        print("explain cases", len(cases), "exceptions", sum("exception" in c for c in cases))

        if args.wav_source:
            import librosa
            import soundfile as sf

            w, _ = librosa.load(args.wav_source, sr=16000, mono=True)
            pcm = np.clip(np.round(w * 32767), -32768, 32767).astype("<i2")
            wav_path = os.path.join(args.tests, "husary_001002.wav")
            sf.write(wav_path, pcm, 16000, subtype="PCM_16")
            w16 = pcm.astype(np.float32) / 32768.0
            feat = proc([w16], sampling_rate=16000, return_tensors="np")
            x = feat["input_features"][0].astype("<f4")
            x.tofile(os.path.join(args.tests, "husary_001002_features.f32"))
            with open(os.path.join(args.tests, "husary_001002_features.json"), "w") as f:
                json.dump({"shape": list(x.shape), "mask": feat["attention_mask"][0].tolist()}, f)
            print("features", x.shape)


if __name__ == "__main__":
    main()
