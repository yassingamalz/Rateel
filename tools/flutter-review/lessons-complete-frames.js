// Screen 06 completion frames (node tools/flutter-review/lessons-complete-frames.js <outdir> <style> [tag]).
// ?completeLesson=0 at ?slow=6: border light, flash + ✓, light along the line, unlock of lesson 2, glide.
const {chromium}=require('playwright');(async()=>{const [d,s,tag='v1']=process.argv.slice(2);const b=await chromium.launch();
const p=await b.newPage({viewport:{width:1844,height:853}});
await p.goto(`http://localhost:8765/?lessons=0,0&completeLesson=0&slow=6&lessonsStyle=${s}`,{waitUntil:'networkidle'});
const t0=Date.now();const at=[3000,6500,9500,12500,15500,19500,24000,28000];
for(let i=0;i<at.length;i++){const w=at[i]-(Date.now()-t0);if(w>0)await p.waitForTimeout(w);await p.screenshot({path:`${d}/f-${s}-${i}.png`});}
await b.close()})();
