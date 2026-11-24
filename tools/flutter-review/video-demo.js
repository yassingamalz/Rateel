// Screen 07 demo (node tools/flutter-review/video-demo.js <outdir>), web build served on :8765, phone size 915x412.
// a: full-screen video (simulated) reaches the end of section 1 → the 02 button waits (pulsing gold play) → tap →
//    section 2 → ‹ (at the start of a section: back to the previous one) → 02 pause menu → «تخطي» completes the lesson.
// c: the last section ends → the lesson completes by itself (screen 06 completion).
// b: "video not available" → «تخطي».
const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();
const W=915,H=412,u=H/100;
for (const [part,q] of [['a','video=demo&videoAt=0.325'],['c','video=demo&videoAt=0.988'],['b','video=none']]) {
 const c=await b.newContext({viewport:{width:W,height:H},recordVideo:{dir:d+'/vid-07'+part,size:{width:W,height:H}}});const p=await c.newPage();
 const w=ms=>p.waitForTimeout(ms);
 await p.goto(`http://localhost:8765/?lessons=0,0&openLesson=0&${q}`,{waitUntil:'networkidle'});await w(2600);
 const skip=()=>p.mouse.click(W-7.3*u-16.8*u,82.45*u);
 const top=()=>p.mouse.click(W-10.75*u,10.75*u);
 const back=()=>p.mouse.click(W-7.3*u-33.6*u-3*u-6.45*u,82.45*u);
 if(part==='a'){
  await w(4500);await top();await w(2200);    // section end: gold play waits → section 2
  await back();await w(2200);                 // ‹ back to section 1
  await top();await w(1800);                  // 02 pause menu
  await p.mouse.click(W/2,60*u);await w(1200);// resume
  await skip();await w(6000);
 } else if(part==='c'){
  await w(9000);
 } else {
  await w(1500);await skip();await w(5000);
 }
 await c.close();}
await b.close()})();
