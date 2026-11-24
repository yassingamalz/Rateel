# Screen 11 verification: element boxes, reference vs app capture (1844x853).
# Usage: python3 -I tools/flutter-review/leaderboard-verify.py <reference.webp> <capture.png>
import sys, numpy as np
from PIL import Image
ref=np.asarray(Image.open(sys.argv[1]).convert('RGB')).astype(int)
app=np.asarray(Image.open(sys.argv[2]).convert('RGB')).astype(int)
U=8.53
def bbox(I,box,cond):
  x0,y0,x1,y1=box; c=I[y0:y1,x0:x1]; m=cond(c); ys,xs=np.where(m)
  if len(xs)<5: return None
  return (int(xs.min()+x0),int(ys.min()+y0),int(xs.max()+x0),int(ys.max()+y0))
yellow=lambda c:(c[...,0]>200)&(c[...,1]>140)&(c[...,2]<100)
cream=lambda c:(c[...,0]>215)&(c[...,1]>210)&(c[...,2]>150)
red=lambda c:(c[...,0]>180)&(c[...,1]<80)&(c[...,2]<80)
silver=lambda c:(abs(c[...,0]-c[...,2])<25)&(c[...,0]>150)
goldline=lambda c:(c[...,0]>200)&(c[...,1]>170)&(c[...,2]<150)
S=21  # app content is 21 px wider: right-anchored elements shift +21
items=[ # name, ref box, shift, cond
 ('ribbon gold',(450,0,1250,150),10,goldline),
 ('title cream',(690,40,990,128),10,cream),
 ('header R text',(1150,190,1530,245),S,cream),
 ('header pts',(290,190,420,245),0,cream),
 ('header rew',(70,190,250,245),0,cream),
 ('medal1 (red ribbon)',(1400,290,1500,410),S,red),
 ('avatar1 disc',(1265,290,1385,410),S,yellow),
 ('name1',(1030,295,1260,342),S,cream),
 ('lessons1 text',(1090,360,1215,398),S,lambda c:(c[...,0]>170)&(c[...,1]>170)&(c[...,2]>140)),
 ('book1',(1215,355,1260,400),S,yellow),
 ('star1',(260,320,330,385),0,yellow),
 ('pts1',(330,325,440,380),0,cream),
 ('coins1',(150,315,235,390),0,yellow),
 ('rew1 text',(80,325,160,380),0,cream),
 ('medal2 red',(1400,440,1500,560),S,red),
 ('avatar2',(1265,440,1385,560),S,yellow),
 ('name2',(1030,440,1260,490),S,cream),
 ('star2',(260,465,330,530),0,yellow),
 ('coins2 silver',(140,460,240,540),0,silver),
 ('disc15',(1400,680,1520,775),S,yellow),
 ('avatar me',(1265,670,1395,790),S,yellow),
 ('name me',(960,665,1260,715),S,cream),
 ('pts me',(310,695,420,750),0,cream),
 ('star me',(250,695,320,755),0,yellow),
 ('chevron ring',(85,675,195,780),0,goldline),
 ('tab gold',(1545,160,1640,400),S,lambda c:(c[...,0]>200)&(c[...,1]>140)&(c[...,2]<90)),
]
print(f"{'element':22s} {'REF box':28s} {'APP box (shifted back)':28s}  dx  dy  dw  dh (px @853)")
for n,b,sh,cond in items:
  r=bbox(ref,b,cond); a=bbox(app,(b[0]+sh,b[1],b[2]+sh,b[3]),cond)
  if r is None or a is None: print(n,r,a); continue
  a=(a[0]-sh,a[1],a[2]-sh,a[3])
  dx=a[0]-r[0]; dy=a[1]-r[1]; dw=(a[2]-a[0])-(r[2]-r[0]); dh=(a[3]-a[1])-(r[3]-r[1])
  flag=' <<' if max(abs(dx),abs(dy),abs(dw),abs(dh))>=5 else ''
  print(f"{n:22s} {str(r):28s} {str(a):28s} {dx:4d}{dy:4d}{dw:4d}{dh:4d}{flag}")
