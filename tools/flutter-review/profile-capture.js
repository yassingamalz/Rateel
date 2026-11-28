// Screen 29 captures: node tools/flutter-review/profile-capture.js <outdir> [tag]; web build on :8765.
// Reference size 1844x853 and phone 915x412 (dpr 2.625), dark and light (?theme=light).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],tag=process.argv[3]||'v1';const b=await chromium.launch();
for (const theme of ['dark','light'])
for (const [W,H,dpr,suf] of [[1844,853,1,''],[915,412,2.625,'-phone']]) {
 const p=await b.newPage({viewport:{width:W,height:H},deviceScaleFactor:dpr});
 await p.goto(`http://localhost:8765/?profile=1${theme==='light'?'&theme=light':''}`,{waitUntil:'networkidle'});await p.waitForTimeout(6000);
 await p.screenshot({path:`${d}/capture-${tag}-${theme}${suf}.png`});
 await p.close();}
await b.close()})();
