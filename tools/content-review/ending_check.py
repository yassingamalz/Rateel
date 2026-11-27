import json,glob,re,sys,unicodedata
Q=json.load(open(sys.argv[1]))
V={(s['id'],v['id']):v['text'] for s in Q for v in s['verses']}
VOW={'\u064e':'a','\u064f':'u','\u0650':'i','\u064b':'an','\u064c':'un','\u064d':'in','\u0657':'an','\u065e':'un','\u0656':'in','\u08f0':'an','\u08f1':'un','\u08f2':'in'}
LET=re.compile('[ء-يٱ]')
def skel(w):
    w=''.join(c for c in unicodedata.normalize('NFC',w) if not unicodedata.category(c).startswith('M') and c!='ـ')
    w=re.sub('[اأإآٱءى]','',w).replace('ؤ','و').replace('ئ','ي').replace('ة','ه').replace('لل','ل')
    return re.sub(r'[^ء-ي]','',w)
def lastvowel(w):
    # vowel marks on the last consonant that carries one (skip trailing alif/ya/waw maddiyya and small marks)
    vs=[VOW[c] for c in w if c in VOW]
    if not vs: return None
    v=vs[-1]
    if ('\u06e2' in w[-3:] or '\u06ed' in w[-3:]) and len(v)==1: v+='n'
    return v
def parse(ref):
    m=re.match(r'^\s*(\d+):(\d+)(?:\s*[-–]\s*(\d+))?',str(ref))
    if not m: return None
    s=int(m.group(1));a=int(m.group(2));b=int(m.group(3) or a);return [(s,x) for x in range(a,b+1)]
out=set()
def walk(x,f):
    if isinstance(x,dict):
        r=x.get('verseRef'); t=x.get('excerptAr') or (x.get('text') if 'verseRef' in x else None)
        p=parse(r) if isinstance(r,str) else None
        if p and isinstance(t,str) and all(k in V for k in p):
            vw=' '.join(V[k] for k in p).split()
            vsk=[skel(w) for w in vw]
            ew=t.split()
            # align: find start index where skeletons match
            esk=[skel(w) for w in ew]
            for i in range(len(vsk)-len(esk)+1):
                if all(vsk[i+j]==esk[j] or vsk[i+j].endswith(esk[j]) for j in range(len(esk))):
                    for j,w in enumerate(ew):
                        a=lastvowel(w); b=lastvowel(vw[i+j])
                        if a and b and a!=b and not (j==len(ew)-1 and False):
                            out.add((f.split('/')[-1][:30],r,w,vw[i+j],a,b))
                    break
        for v in x.values(): walk(v,f)
    elif isinstance(x,list):
        for v in x: walk(v,f)
for f in sorted(glob.glob('**/*.json',recursive=True)): walk(json.load(open(f)),f)
for o in sorted(out): print(o)
print(len(out))
