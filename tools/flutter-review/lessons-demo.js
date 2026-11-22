// Screen 06 demo (node tools/flutter-review/lessons-demo.js <outdir> <style>), web build served on :8765.
// Lessons of unit 1 (course 1) over its units screen: tap a locked lesson; open lesson 1 → placeholder page →
// «أكملت الدرس» → completion → next lesson opens by itself … ×3 → back to the
// units screen: unit completion → the next unit's lessons open by themselves.
const {chromium}=require('playwright');(async()=>{const [d,s='ref']=process.argv.slice(2);const b=await chromium.launch();
const W=1280,H=592,u=H/100,rail=W-18.3*u;
const c=await b.newContext({viewport:{width:W,height:H},recordVideo:{dir:d+'/vid-'+s,size:{width:W,height:H}}});const p=await c.newPage();
const w=ms=>p.waitForTimeout(ms);
const orig=s==='orig';const first=orig?30:52.4,pitch=orig?52:88,cy=orig?52:65.7;
await p.goto(`http://localhost:8765/?lessons=0,0&lessonsStyle=${s}`,{waitUntil:'networkidle'});await w(2500);
await p.mouse.click(rail-(first+pitch)*u,cy*u);await w(2200);                 // locked lesson
await p.mouse.click(rail-first*u,cy*u);await w(1200);                          // open lesson 1
async function finish(){await p.mouse.click(0.619*W,0.639*H);} // «أكملت الدرس» (measured on the page)
for(let k=0;k<3;k++){await w(900);await finish();await w(k<2?7200:2500);}
await w(13000);                                                                  // unit completion + next lessons
await c.close();await b.close()})();
