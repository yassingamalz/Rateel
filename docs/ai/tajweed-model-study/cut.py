"""Remove [a,b) seconds from an audio file with a 20 ms crossfade; write 16 kHz mono wav."""
import sys, numpy as np, librosa, soundfile as sf
src, dst, a, b = sys.argv[1], sys.argv[2], float(sys.argv[3]), float(sys.argv[4])
w, sr = librosa.load(src, sr=16000, mono=True)
ia, ib, x = int(a*sr), int(b*sr), int(0.02*sr)
fade = np.linspace(1, 0, x)
mid = w[ia-x:ia]*fade + w[ib:ib+x]*(1-fade)
out = np.concatenate([w[:ia-x], mid, w[ib+x:]])
sf.write(dst, out, sr)
print(f"{dst}: {len(w)/sr:.2f}s -> {len(out)/sr:.2f}s")
