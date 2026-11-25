// Screen 08 captures: node tools/flutter-review/reading-capture.js <outdir> [tag] [phoneOnly]; web build on :8765.
// Reading lesson 1 (course 0, unit 1, lesson 0) opened directly: dark, light, rules panel + «A» menu, verse 5 (long).
// Reference size 1842x854 and phone 915x412 (dpr 2.625).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],tag=process.argv[3]||'v1',phoneOnly=process.argv[4]==='phone';
const b=await chromium.launch();
const states=[['','dark'],['readTheme=light','light'],['rules=1&fontMenu=1','panel'],['readTheme=light&rules=1&fontMenu=1','panel-light'],['verse=4','long']];
const sizes=phoneOnly?[[915,412,2.625,'-phone']]:[[1842,854,1,''],[915,412,2.625,'-phone']];
for (const [W,H,dpr,suf] of sizes) {
 for (const [q,name] of states) {
  const p=await b.newPage({viewport:{width:W,height:H},deviceScaleFactor:dpr});
  await p.goto(`http://localhost:8765/?lessons=0,1&openLesson=0&${q}`,{waitUntil:'networkidle'});
  await p.waitForTimeout(4500);
  await p.screenshot({path:`${d}/capture-${tag}-${name}${suf}.png`});
  await p.close();
 }}
await b.close()})();
