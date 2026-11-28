"""Run Muaalem once over many (file, sura, aya); report phoneme errors and sifat errors.
For each recording, also try aared/monfasel/mottasel lengths and keep the best (fewest phoneme errors)."""
import sys, time, itertools, resource, librosa, torch
sys.path.insert(0, "/home/user/work")
from quran_transcript import Aya, MoshafAttributes, explain_error, quran_phonetizer
from quran_transcript.phonetics.error_explainer import align_phonemes_groups
from quran_muaalem import Muaalem

def sifat_errs(ref, out, pmin):
    n = []
    for al in align_phonemes_groups([s.phonemes for s in ref.sifat], [s.phonemes_group for s in out.sifat]):
        if al.op_type != "equal": continue
        r, p = ref.sifat[al.ref_idx], out.sifat[al.pred_idx]
        for lvl in ["hams_or_jahr","shidda_or_rakhawa","tafkheem_or_taqeeq","itbaq","safeer","qalqla","tikraar","tafashie","istitala","ghonna"]:
            u = getattr(p, lvl)
            if u is not None and u.text != getattr(r, lvl) and u.prob >= pmin:
                n.append(f"{lvl}@{r.phonemes}:{getattr(r,lvl)}->{u.text}({u.prob:.2f})")
    return n

m = Muaalem(device="cpu", dtype=torch.float32)
items = [l.split() for l in open(sys.argv[1]) if l.strip()]
tot = {"files":0,"ph_default":0,"ph_best":0,"sifat":0,"audio":0.0,"infer":0.0}
for path, sura, aya in items:
    sura, aya = int(sura), int(aya)
    uth = Aya(sura, aya).get().uthmani
    w, _ = librosa.load(path, sr=16000, mono=True)
    results = []
    for aared, mon, mot in itertools.product([4,2,6],[4,2,5],[4,5,6]):
        mo = MoshafAttributes(rewaya="hafs", madd_monfasel_len=mon, madd_mottasel_len=mot, madd_mottasel_waqf=mot, madd_aared_len=aared)
        ref = quran_phonetizer(uth, mo, remove_spaces=True, sura_idx=sura)
        if not results:
            t0 = time.time(); out = m([w], [ref], sampling_rate=16000)[0]; dt = time.time()-t0
            pred = out.phonemes.text
            first = (ref, out)
        errs = explain_error(uthmani_text=uth, ref_ph_text=ref.phonemes, predicted_ph_text=pred, mappings=ref.mappings)
        results.append(((aared,mon,mot), errs))
    default = results[0][1]
    best = min(results, key=lambda r: len(r[1]))
    sf = sifat_errs(first[0], first[1], 0.7)
    tot["files"]+=1; tot["ph_default"]+=len(default); tot["ph_best"]+=len(best[1]); tot["sifat"]+=len(sf); tot["audio"]+=len(w)/16000; tot["infer"]+=dt
    name = path.split("/")[-1]
    print(f"{name} {sura}:{aya} {len(w)/16000:.1f}s infer {dt:.1f}s | default(4,4,4): {len(default)} | best{best[0]}: {len(best[1])} | sifat>=0.7: {len(sf)}")
    for e in best[1]:
        print(f"    best-err {e.error_type}/{e.speech_error_type} exp «{e.expected_ph}» got «{e.preditected_ph}» rules {[r.name.en for r in (e.ref_tajweed_rules or [])]}")
    for s in sf: print("    sifa", s)
print(tot, f"RTF {tot['infer']/tot['audio']:.2f}", f"peak RSS {resource.getrusage(resource.RUSAGE_SELF).ru_maxrss/1024:.0f} MiB")
