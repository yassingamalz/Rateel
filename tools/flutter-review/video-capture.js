// Screen 07 captures: node tools/flutter-review/video-capture.js <outdir> [tag]; web build on :8765.
// Opens lesson 1 of course 0 unit 0 (video) directly: "not available" (?video=none) and playing (?video=demo at 37%),
// at the reference size 1842x854 and at phone size 915x412 (dpr 2.625).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],tag=process.argv[3]||'v1';const b=await chromium.launch();
for (const [W,H,dpr,suf] of [[1842,854,1,''],[915,412,2.625,'-phone']]) {
 for (const [mode,name] of [['none','unavailable'],['demo&videoAt=0.36','playing']]) {
  const p=await b.newPage({viewport:{width:W,height:H},deviceScaleFactor:dpr});
  await p.goto(`http://localhost:8765/?lessons=0,0&openLesson=0&video=${mode}`,{waitUntil:'networkidle'});
  await p.waitForTimeout(5000);
  await p.screenshot({path:`${d}/capture-${tag}-${name}${suf}.png`});
  await p.close();
 }}
await b.close()})();
