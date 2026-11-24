// Screen 14 captures: node tools/flutter-review/coming-soon-capture.js <outdir> [tag]; web build on :8765.
// Reference size 1844x853 and phone 915x412 (dpr 2.625), section 1 (Quran).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],tag=process.argv[3]||'v1';const b=await chromium.launch();
for (const [W,H,dpr,suf] of [[1844,853,1,''],[915,412,2.625,'-phone']]) {
 const p=await b.newPage({viewport:{width:W,height:H},deviceScaleFactor:dpr});
 await p.goto('http://localhost:8765/?section=1',{waitUntil:'networkidle'});await p.waitForTimeout(4500);
 await p.screenshot({path:`${d}/capture-${tag}${suf}.png`});
 await p.close();}
await b.close()})();
