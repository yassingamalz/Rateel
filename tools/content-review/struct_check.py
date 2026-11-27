import json,glob,collections,re
ids=collections.defaultdict(list); issues=[]; types=collections.Counter(); qs=[]
def walk(x,f,path):
    if isinstance(x,dict):
        if 'id' in x and isinstance(x['id'],str): ids[x['id']].append(f)
        if 'correctAnswer' in x or 'correct' in x or 'correctId' in x:
            qs.append((f,x))
        for k,v in x.items(): walk(v,f,path+'/'+k)
    elif isinstance(x,list):
        for v in x: walk(v,f,path)
for f in sorted(glob.glob('**/*.json',recursive=True)):
    walk(json.load(open(f)),f,'')
for i,fs in ids.items():
    if len(fs)>1: issues.append(('DUP_ID',i,sorted(set(fs)),len(fs)))
for f,q in qs:
    t=q.get('type'); types[t]+=1
    ca=q.get('correctAnswer',q.get('correct',q.get('correctId')))
    opts=q.get('options')
    if isinstance(opts,list) and opts and isinstance(opts[0],dict):
        oid=[o.get('id') for o in opts]; otx=[o.get('text') for o in opts]
        if len(set(otx))<len(otx): issues.append(('DUP_OPTION_TEXT',q.get('id'),f,otx))
        if len(set(oid))<len(oid): issues.append(('DUP_OPTION_ID',q.get('id'),f))
        cas=ca if isinstance(ca,list) else [ca]
        for c in cas:
            if str(c) not in [str(o) for o in oid]: issues.append(('KEY_NOT_IN_OPTIONS',q.get('id'),f,ca,oid))
        if t=='singleChoice' and isinstance(ca,list) and len(ca)!=1: issues.append(('SINGLE_WITH_MULTI',q.get('id'),f))
    elif t=='trueFalse':
        if not isinstance(ca,bool) and str(ca).lower() not in ('true','false'): issues.append(('TF_KEY',q.get('id'),f,ca))
    elif opts is None and t in('singleChoice','multipleChoice'): issues.append(('NO_OPTIONS',q.get('id'),f))
print(types)
c=collections.Counter(i[0] for i in issues); print(c)
for i in issues: print(json.dumps(i,ensure_ascii=False)[:300])
