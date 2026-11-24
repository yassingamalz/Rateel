// Screen 02 captures: node tools/flutter-review/lesson-bar-capture.js <outdir> [tag]; web build on :8765.
// Opens lesson 1 of course 0 unit 0, steps forward, pauses; desktop 1844x853 and phone 915x412 (dpr 2.625).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],tag=process.argv[3]||'v1';const b=await chromium.launch();
for (const [W,H,dpr,suf] of [[1844,853,1,''],[915,412,2.625,'-phone']]) {
 const p=await b.newPage({viewport:{width:W,height:H},deviceScaleFactor:dpr});
 await p.goto('http://localhost:8765/?lessons=0,0&steps=16',{waitUntil:'networkidle'});await p.waitForTimeout(3500);
 await p.mouse.click(W*1350/1844,H*460/853);await p.waitForTimeout(1200);
 await p.screenshot({path:`${d}/capture-${tag}-step1${suf}.png`});
 // «الخطوة التالية»: the gold button of the placeholder card.
 const u=H/100;const clickNext=async()=>{ await p.mouse.click(W/2+31.7*u,H/2+12*u); await p.waitForTimeout(450); };
 await clickNext();await p.waitForTimeout(400);
 await p.screenshot({path:`${d}/capture-${tag}-step2${suf}.png`});
 for(let i=0;i<7;i++) await clickNext();
 await p.waitForTimeout(400);
 await p.screenshot({path:`${d}/capture-${tag}-step9${suf}.png`});
 await p.mouse.click(W-7.5*u, 7.5*u);await p.waitForTimeout(700);
 await p.screenshot({path:`${d}/capture-${tag}-paused${suf}.png`});
 await p.close();}
await b.close()})();
