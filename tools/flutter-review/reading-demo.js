// Screen 08 demo (node tools/flutter-review/reading-demo.js <outdir>), web build on :8765, phone size 915x412.
// Lesson «آداب تلاوة القرآن الكريم» (course 0, unit 1, lesson 0): ‹ twice → swipe → moon (light) → rules panel → ✕ →
// «A» menu, size + + → close → moon (dark) → last dot → the lesson completes by itself 1.5 s later (screen 06).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();
const W=915,H=412,u=H/100;
const c=await b.newContext({viewport:{width:W,height:H},recordVideo:{dir:d+'/vid-08',size:{width:W,height:H}}});const p=await c.newPage();
const w=ms=>p.waitForTimeout(ms);const tap=(x,y)=>p.mouse.click(x,y);
await p.goto('http://localhost:8765/?lessons=0,1&openLesson=0',{waitUntil:'networkidle'});await w(3000);
const mid=34.3*u, next=W-43.45*u, moon=W/2-8.9*u, A=W/2+7.6*u, rules=26.35*u;
await tap(next,mid);await w(1100);await tap(next,mid);await w(1300);
await p.mouse.move(W/2-25*u,61*u);await p.mouse.down();await p.mouse.move(W/2+25*u,61*u,{steps:12});await p.mouse.up();await w(1400);
await tap(moon,mid);await w(1600);
await tap(rules,mid);await w(2200);
await tap(W-54*u,30.1*u);await w(1200);
await tap(A,mid);await w(1000);
await tap(A+9.45*u,53.6*u);await w(600);await tap(A+9.45*u,53.6*u);await w(1200);
await tap(W/2,12*u);await w(800);
await tap(moon,mid);await w(1500);
await tap(W/2-19.25*u,90.2*u);await w(6500);
await c.close();await b.close()})();
