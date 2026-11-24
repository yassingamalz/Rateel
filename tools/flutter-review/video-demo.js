// Screen 07 demo (node tools/flutter-review/video-demo.js <outdir>), web build served on :8765, phone size 915x412.
// Part 1 (?video=demo, simulated video near its end): lesson 1 opens, tap on the video pauses/resumes, the 02 pause
// menu pauses it, the video ends → lesson completes by itself → screen 06 completion → lesson 2 opens → «تخطي».
// Part 2 (?video=none): the "video not available" state, «تخطي» completes the lesson.
const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();
const W=915,H=412,u=H/100;
for (const [part,q] of [['a','video=demo&videoAt=0.955'],['b','video=none']]) {
 const c=await b.newContext({viewport:{width:W,height:H},recordVideo:{dir:d+'/vid-07'+part,size:{width:W,height:H}}});const p=await c.newPage();
 const w=ms=>p.waitForTimeout(ms);
 await p.goto(`http://localhost:8765/?lessons=0,0&openLesson=0&${q}`,{waitUntil:'networkidle'});await w(2600);
 const skip=()=>p.mouse.click(W-7.3*u-16.8*u,82.45*u);
 if(part==='a'){
  await p.mouse.click(W/2,54.5*u);await w(1500);   // tap on the video: pause
  await p.mouse.click(W/2,54.5*u);await w(1200);   // resume
  await p.mouse.click(W-10.75*u,10.75*u);await w(1800); // 02 pause menu
  await p.mouse.click(W/2,60*u);await w(1000);     // tap on the veil: resume
  await w(14000);                                  // video ends → completion → lesson 2 opens
  await w(2500);await skip();await w(6000);
 } else {
  await w(1500);await skip();await w(5000);
 }
 await c.close();}
await b.close()})();
