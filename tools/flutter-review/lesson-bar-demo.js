// Screen 02 demo (node tools/flutter-review/lesson-bar-demo.js <outdir>), web build served on :8765.
// Lessons of unit 1 → lesson 1 slides down (rail hidden) → 3 steps → pause (veil, gold play, back/restart) →
// resume by tapping the veil → restart → 2 steps → pause → resume → «أكملت الدرس»: fill to the end, light along
// the capsule, slide out → lesson completion on screen 06 → lesson 2 opens → pause → «back».
const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();
const W=1280,H=592,u=H/100;
const c=await b.newContext({viewport:{width:W,height:H},recordVideo:{dir:d+'/vid-bar',size:{width:W,height:H}}});const p=await c.newPage();
const w=ms=>p.waitForTimeout(ms);
const next=()=>p.mouse.click(W/2+31.7*u,H/2+12*u), done=()=>p.mouse.click(W/2+7.5*u,H/2+12*u);
const pause=()=>p.mouse.click(W-7.5*u,7.5*u), back=()=>p.mouse.click(W-(3+9+1.6+4.5)*u,7.5*u),
      restart=()=>p.mouse.click(W-(3+2*(9+1.6)+4.5)*u,7.5*u);
await p.goto('http://localhost:8765/?lessons=0,0&steps=8',{waitUntil:'networkidle'});await w(2500);
await p.mouse.click(W*1350/1844,H*460/853);await w(1600);   // open lesson 1
for(let i=0;i<3;i++){await next();await w(900);}
await pause();await w(2600);                                // paused: veil, pulse
await p.mouse.click(W*0.5,H*0.8);await w(1200);             // tap the veil: resume
await pause();await w(1400);await restart();await w(1400);  // restart → 1/8
for(let i=0;i<2;i++){await next();await w(900);}
await done();await w(9000);                                 // finish → sweep → exit → completion, lesson 2 opens
await w(1000);await pause();await w(1800);await back();await w(2500);
await c.close();await b.close()})();
