import sys, time, resource, numpy as np, onnxruntime as ort
th = int(sys.argv[1]); so = ort.SessionOptions(); so.intra_op_num_threads = th; so.inter_op_num_threads = 1
t0 = time.time(); s = ort.InferenceSession("/home/user/onnx/onnx_model/int8/muaalem.onnx", so, providers=["CPUExecutionProvider"]); load = time.time()-t0
r0 = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss/1024
x = {"input_features": np.load("/home/user/work/feat.npy"), "attention_mask": np.load("/home/user/work/mask.npy")}
s.run(None, x); ts = []
for _ in range(3):
    t0 = time.time(); s.run(None, x); ts.append(time.time()-t0)
print(f"threads {th}: load {load:.1f}s, RSS after load {r0:.0f} MiB, run 6.3s audio median {sorted(ts)[1]:.2f}s, peak RSS {resource.getrusage(resource.RUSAGE_SELF).ru_maxrss/1024:.0f} MiB")
