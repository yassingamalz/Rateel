import json,glob,re,sys,unicodedata,collections
Q=json.load(open(sys.argv[1]))
V={(s['id'],v['id']):v['text'] for s in Q for v in s['verses']}
def nt(w):
    w=unicodedata.normalize('NFC',w)
    w=''.join(c for c in w if not unicodedata.category(c).startswith('M') and c not in 'ـ')
    w=re.sub('[اأإآٱءى]','',w)  # drop alifs/hamza/alif maqsura (rasm variance)
    w=w.replace('ؤ','و').replace('ئ','ي').replace('ة','ه')
    w=re.sub(r'[^ء-ي]','',w)
    w=w.replace('لل','ل')  # الليل vs اليل
    return w
def toks(t): return [x for x in (nt(w) for w in re.split(r'\s+',t)) if x]
def parse(ref):
    m=re.match(r'^\s*(\d+):(\d+)(?:\s*[-–]\s*(\d+))?',str(ref))
    if not m: return None
    s=int(m.group(1));a=int(m.group(2));b=int(m.group(3) or a)
    return [(s,x) for x in range(a,b+1)]
KEYS=['excerptAr','text','textAr','arabic','excerptCandidate']
seen=set();bad=[];ok=0
def walk(x,f):
    global ok
    if isinstance(x,dict):
        r=x.get('verseRef')
        if isinstance(r,str):
            p=parse(r)
            t=next((x[k] for k in KEYS if isinstance(x.get(k),str) and re.search('[ء-ي]',x[k])),None)
            if p and t and all(k in V for k in p):
                vt=toks(' '.join(V[k] for k in p))
                parts=[toks(s) for s in re.split(r'\s*(?:\.\.\.|…|[،,])\s*',t)]
                def found(pt):
                    n=len(pt)
                    for i in range(len(vt)-n+1):
                        if all(vt[i+j]==pt[j] or (j==0 and vt[i].endswith(pt[0]) and len(vt[i])-len(pt[0])<=2 and n>=1) for j in range(n)): return True
                    return False
                if all(found(pt) for pt in parts if pt): ok+=1
                else:
                    key=(r,t)
                    if key not in seen:
                        seen.add(key); bad.append((r,t,x.get('id'),f))
        for v in x.values(): walk(v,f)
    elif isinstance(x,list):
        for v in x: walk(v,f)
for f in sorted(glob.glob('**/*.json',recursive=True)): walk(json.load(open(f)),f)
print('ok',ok,'distinct bad',len(bad))
for b in bad: print(json.dumps(b,ensure_ascii=False))
