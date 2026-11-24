// Screen 11 demo (node tools/flutter-review/leaderboard-demo.js <outdir>), web build served on :8765.
// Courses → rail item المتصدرين → entry (ribbon, rows, medals, light on the 1st medal, pinned bar) → drag the list
// → tap the pinned bar (scroll to the user, gold pulse) → friends → region → all.
const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();
const W=1280,H=592,u=H/100;
const c=await b.newContext({viewport:{width:W,height:H},recordVideo:{dir:d+'/vid-lb',size:{width:W,height:H}}});const p=await c.newPage();
const w=ms=>p.waitForTimeout(ms);
await p.goto('http://localhost:8765/',{waitUntil:'networkidle'});await w(2500);
await p.mouse.click(W-8.8*u,21.3*u+3*13.9*u);await w(3200);          // rail: leaderboard
const content=W-18.5*u, panelRight=content-15*u, mx=(4.4*u+panelRight)/2;
await p.mouse.move(mx,60*u);await p.mouse.down();
for(let i=0;i<12;i++){await p.mouse.move(mx,60*u-i*2.5*u);await w(30);}
await p.mouse.up();await w(1500);
for(let i=0;i<12;i++){await p.mouse.wheel(0,-60);await w(30);}await w(1200);
await p.mouse.click(mx,H-6.6*u-8.25*u);await w(2800);               // pinned bar → scroll to me
const tabX=content-8.8*u, tabTop=19.3*u, tabH=(H-6.4*u-tabTop)/3;
for(const i of [1,2,0]){await p.mouse.click(tabX,tabTop+tabH*(i+0.5));await w(2200);}
await c.close();await b.close()})();
