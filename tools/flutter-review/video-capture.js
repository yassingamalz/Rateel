// Screen 07 captures: node tools/flutter-review/video-capture.js <outdir> [tag]; web build on :8765.
// Lesson 1 of course 0 unit 0 (video) opened directly: "not available" (?video=none); full-screen playing in section 2
// (?video=demo&videoAt=0.36, dots); end of section 1 («أعد» / «تابع»); playing with the ‹ previous-section button.
// Reference size 1842x854 and phone 915x412 (dpr 2.625).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],tag=process.argv[3]||'v1';const b=await chromium.launch();
const states=[['video=none','unavailable'],['video=demo&videoAt=0.36','playing'],['video=demo&videoAt=0.325','section-end'],
 ['video=demo&videoAt=0.36&sectionNav=button','playing-button']];
for (const [W,H,dpr,suf] of [[1842,854,1,''],[915,412,2.625,'-phone']]) {
 for (const [q,name] of states) {
  const p=await b.newPage({viewport:{width:W,height:H},deviceScaleFactor:dpr});
  await p.goto(`http://localhost:8765/?lessons=0,0&openLesson=0&${q}`,{waitUntil:'networkidle'});
  await p.waitForTimeout(5000);
  await p.screenshot({path:`${d}/capture-${tag}-${name}${suf}.png`});
  await p.close();
 }}
await b.close()})();
