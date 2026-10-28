"""
تجربة سريعة لموديل المعلم القرآني (Quran Muaalem) على تسجيل صوتي لآية واحدة.

الاستخدام:
    python try_muaalem.py recording.wav --sura 1 --aya 2
    python try_muaalem.py recording.m4a --sura 112 --aya 1 --madd-monfasel 4

السكربت بيعمل الآتي:
  1. يجيب نص الآية بالرسم العثماني.
  2. يحوّله لـ "الرسم الصوتي" (Quran Phonetic Script) حسب إعدادات القراءة (طول المدود...).
  3. يشغّل الموديل على الصوت فيطلع الأصوات اللي اتقالت فعلًا + صفات كل حرف.
  4. يقارن اللي اتقال بالمرجع ويطبع أخطاء الحروف والحركات والتجويد والصفات.
"""

import argparse
import time

import librosa
import torch
from quran_transcript import Aya, MoshafAttributes, explain_error, quran_phonetizer
from quran_transcript.phonetics.error_explainer import align_phonemes_groups

from quran_muaalem import Muaalem
from quran_muaalem.modeling.vocab import SIFAT_ATTR_TO_ARABIC_WITHOUT_BRACKETS

SAMPLING_RATE = 16000

ERROR_TYPE_AR = {
    "tajweed": "خطأ تجويد",
    "normal": "خطأ في الحرف",
    "tashkeel": "خطأ في الحركة",
}
SPEECH_ERROR_AR = {"insert": "زيادة", "delete": "نقص", "replace": "إبدال"}
SIFA_NAME_AR = {
    "hams_or_jahr": "الهمس والجهر",
    "shidda_or_rakhawa": "الشدة والرخاوة",
    "tafkheem_or_taqeeq": "التفخيم والترقيق",
    "itbaq": "الإطباق",
    "safeer": "الصفير",
    "qalqla": "القلقلة",
    "tikraar": "التكرار",
    "tafashie": "التفشي",
    "istitala": "الاستطالة",
    "ghonna": "الغنة",
}


def word_at(text: str, start: int, end: int) -> str:
    """Return the whole Uthmani word(s) covering text[start:end]."""
    left = text.rfind(" ", 0, start) + 1
    right = text.find(" ", end)
    return text[left : right if right != -1 else len(text)]


def print_phoneme_errors(uthmani: str, ref, predicted_phonemes: str) -> int:
    errors = explain_error(
        uthmani_text=uthmani,
        ref_ph_text=ref.phonemes,
        predicted_ph_text=predicted_phonemes,
        mappings=ref.mappings,
    )
    for err in errors:
        word = word_at(uthmani, *err.uthmani_pos)
        line = (
            f"- [{ERROR_TYPE_AR[err.error_type]} / {SPEECH_ERROR_AR[err.speech_error_type]}]"
            f" في «{word}»: المتوقع «{err.expected_ph}» والمنطوق «{err.preditected_ph}»"
        )
        if err.expected_len is not None:
            line += f" (الزمن المتوقع {err.expected_len} حركات، المنطوق {err.predicted_len})"
        if err.ref_tajweed_rules:
            line += " ← الحكم: " + "، ".join(r.name.ar for r in err.ref_tajweed_rules)
        print(line)
    return len(errors)


def print_sifat_errors(ref, out, min_prob: float) -> int:
    """Compare predicted sifat to the reference for each aligned phoneme group."""
    ref_groups = [s.phonemes for s in ref.sifat]
    pred_groups = [s.phonemes_group for s in out.sifat]
    count = 0
    for al in align_phonemes_groups(ref_groups, pred_groups):
        if al.op_type != "equal":
            continue  # missing/extra letters are already reported as phoneme errors
        ref_sifa = ref.sifat[al.ref_idx]
        pred_sifa = out.sifat[al.pred_idx]
        for level, name_ar in SIFA_NAME_AR.items():
            pred = getattr(pred_sifa, level)
            expected = getattr(ref_sifa, level)
            if pred is None or pred.text == expected or pred.prob < min_prob:
                continue
            print(
                f"- [صفة: {name_ar}] في «{ref_sifa.phonemes}»: المتوقع"
                f" «{SIFAT_ATTR_TO_ARABIC_WITHOUT_BRACKETS[expected]}» والمنطوق"
                f" «{SIFAT_ATTR_TO_ARABIC_WITHOUT_BRACKETS[pred.text]}» (ثقة {pred.prob:.0%})"
            )
            count += 1
    return count


def main():
    parser = argparse.ArgumentParser(description="Quran Muaalem quick test")
    parser.add_argument("audio", help="ملف الصوت (wav / mp3 / m4a / ogg)")
    parser.add_argument("--sura", type=int, required=True, help="رقم السورة 1-114")
    parser.add_argument("--aya", type=int, required=True, help="رقم الآية")
    parser.add_argument("--madd-monfasel", type=int, default=4, choices=[2, 3, 4, 5])
    parser.add_argument("--madd-mottasel", type=int, default=4, choices=[4, 5, 6])
    parser.add_argument("--madd-aared", type=int, default=4, choices=[2, 4, 6])
    parser.add_argument(
        "--min-sifa-prob",
        type=float,
        default=0.7,
        help="متبلّغش عن خطأ صفة إلا لو ثقة الموديل أعلى من القيمة دي",
    )
    parser.add_argument("--model", default="obadx/muaalem-model-v3_2")
    args = parser.parse_args()

    # 1. نص الآية
    uthmani = Aya(args.sura, args.aya).get().uthmani
    print(f"الآية ({args.sura}:{args.aya}): {uthmani}\n")

    # 2. الرسم الصوتي المرجعي (اللي المفروض يتقال)
    moshaf = MoshafAttributes(
        rewaya="hafs",
        madd_monfasel_len=args.madd_monfasel,
        madd_mottasel_len=args.madd_mottasel,
        madd_mottasel_waqf=args.madd_mottasel,
        madd_aared_len=args.madd_aared,
    )
    ref = quran_phonetizer(uthmani, moshaf, remove_spaces=True, sura_idx=args.sura)

    # 3. تشغيل الموديل
    device = "cuda" if torch.cuda.is_available() else "cpu"
    # bfloat16 بطيء على أغلب الـ CPUs، فبنستخدم float32 هناك
    dtype = torch.bfloat16 if device == "cuda" else torch.float32
    t0 = time.time()
    muaalem = Muaalem(model_name_or_path=args.model, device=device, dtype=dtype)
    print(f"تحميل الموديل على {device}: {time.time() - t0:.1f}s")

    wave, _ = librosa.load(args.audio, sr=SAMPLING_RATE, mono=True)
    seconds = len(wave) / SAMPLING_RATE
    if seconds > 20:
        print(f"تنبيه: التسجيل {seconds:.0f} ثانية؛ الموديل متدرّب على مقاطع قصيرة (وقف بوقف).")

    t0 = time.time()
    out = muaalem([wave], [ref], sampling_rate=SAMPLING_RATE)[0]
    print(f"زمن التحليل لـ {seconds:.1f} ثانية صوت: {time.time() - t0:.1f}s\n")

    print(f"المرجع : {ref.phonemes}")
    print(f"المنطوق: {out.phonemes.text}\n")

    # 4. الأخطاء
    print("== أخطاء الحروف والحركات والتجويد ==")
    n_ph = print_phoneme_errors(uthmani, ref, out.phonemes.text)
    if n_ph == 0:
        print("لا يوجد")
    print("\n== أخطاء صفات الحروف ==")
    n_sifat = print_sifat_errors(ref, out, args.min_sifa_prob)
    if n_sifat == 0:
        print("لا يوجد")

    print(
        "\nتنبيه: هذا نموذج ذكاء اصطناعي قد يخطئ، وهو للإعانة فقط وليس بديلاً عن معلّم متقن مُجاز."
    )


if __name__ == "__main__":
    main()
