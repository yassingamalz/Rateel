// Screen 06 captures (node tools/flutter-review/lessons-capture.js <outdir> [tag]), web build served on :8765.
// Look B (the owner's choice) at the reference size and at phone size, with 0 and 1 lessons done.
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],tag=process.argv[3]||'v1';const b=await chromium.launch();
const shots=[['orig','0',1844,853,1,''],['orig','1',1844,853,1,'-done1'],['orig','0',915,412,2.625,'-phone'],
 ['orig','1',915,412,2.625,'-phone-done1']];
for(const [s,done,W,H,dpr,suf] of shots){const p=await b.newPage({viewport:{width:W,height:H},deviceScaleFactor:dpr});
 await p.goto(`http://localhost:8765/?lessons=0,0&lessonDone=${done}`,{waitUntil:'networkidle'});await p.waitForTimeout(3500);
 await p.screenshot({path:`${d}/capture-${tag}-${s}${suf}.png`});await p.close();}
await b.close()})();
