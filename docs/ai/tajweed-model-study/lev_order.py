import random, itertools, Levenshtein as lv
def ops(a,b,order):
    pre=0
    while pre<len(a) and pre<len(b) and a[pre]==b[pre]: pre+=1
    suf=0
    while suf<len(a)-pre and suf<len(b)-pre and a[-1-suf]==b[-1-suf]: suf+=1
    A=a[pre:len(a)-suf]; B=b[pre:len(b)-suf]; n,m=len(A),len(B)
    d=[[0]*(m+1) for _ in range(n+1)]
    for i in range(n+1): d[i][0]=i
    for j in range(m+1): d[0][j]=j
    for i in range(1,n+1):
        for j in range(1,m+1):
            d[i][j]=min(d[i-1][j-1]+(A[i-1]!=B[j-1]), d[i-1][j]+1, d[i][j-1]+1)
    i,j=n,m; rev=[]
    while i>0 or j>0:
        for o in order:
            if o=='eq' and i>0 and j>0 and A[i-1]==B[j-1] and d[i][j]==d[i-1][j-1]: rev.append(('equal',i-1,j-1)); i-=1; j-=1; break
            if o=='rep' and i>0 and j>0 and A[i-1]!=B[j-1] and d[i][j]==d[i-1][j-1]+1: rev.append(('replace',i-1,j-1)); i-=1; j-=1; break
            if o=='ins' and j>0 and d[i][j]==d[i][j-1]+1: rev.append(('insert',i,j-1)); j-=1; break
            if o=='del' and i>0 and d[i][j]==d[i-1][j]+1: rev.append(('delete',i-1,j)); i-=1; break
    out=[('equal',k,k) for k in range(pre)]+[(t,x+pre,y+pre) for t,x,y in reversed(rev)]+[('equal',len(a)-suf+k,len(b)-suf+k) for k in range(suf)]
    return out
def split(opc):
    r=[]
    for t,i1,i2,j1,j2 in opc:
        if t in('equal','replace'): r+= [(t,i,j) for i,j in zip(range(i1,i2),range(j1,j2))]
        elif t=='insert': r+=[(t,i1,j) for j in range(j1,j2)]
        else: r+=[(t,i,j1) for i in range(i1,i2)]
    return r
rng=random.Random(1); cases=[]
for _ in range(3000):
    a=[rng.choice('abcdef') for _ in range(rng.randint(0,12))]; b=[rng.choice('abcdef') for _ in range(rng.randint(0,12))]
    cases.append((a,b,split(lv.opcodes(a,b))))
for order in itertools.permutations(['eq','rep','ins','del']):
    ok=sum(ops(a,b,order)==w for a,b,w in cases); print(order, ok)
