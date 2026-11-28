"""Run try_muaalem.main() and report wall time and peak RSS (Linux ru_maxrss is KiB)."""
import resource, sys, time
sys.path.insert(0, "/home/user/work")
import try_muaalem
sys.argv = ["try_muaalem.py"] + sys.argv[1:]
t0 = time.time()
try_muaalem.main()
print(f"\n[measure] total wall {time.time()-t0:.1f}s, peak RSS {resource.getrusage(resource.RUSAGE_SELF).ru_maxrss/1024:.0f} MiB")
