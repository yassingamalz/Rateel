// Screen 05 demo (node tools/flutter-review/units-demo.js <outdir>), web build served on :8765.
// Courses → tap course 1 → units entry; tap a locked unit; long press the unit in progress
// (completion); «تغيير المقرر» back. Recorded at ?slow=2, speed up ×2 with ffmpeg.
const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();
const W=1280,H=592,u=H/100,k=2,rail=W-(1672-1497)/9.41*u;
const c=await b.newContext({viewport:{width:W,height:H},recordVideo:{dir:d+'/vid',size:{width:W,height:H}}});const p=await c.newPage();
const w=ms=>p.waitForTimeout(ms*k);
await p.goto('http://localhost:8765/?slow=2',{waitUntil:'networkidle'});await w(2200);
await p.mouse.click(W-(1672-1497)/9.41*u-43.8*u*1.1,63.8*u);await w(2600);          // open course 1
await p.mouse.click(rail-(51+66.5)*u,58.2*u);await w(1800);                          // locked unit
const x=rail-51*u,y=58.2*u;await p.mouse.move(x,y);await p.mouse.down();await w(650);await p.mouse.up();
await w(9000);                                                                        // completion
await p.mouse.click(22*u,17*u);await w(2200);                                         // change course
await c.close();await b.close()})();
