// Screen 02 pause-menu motion demo: node tools/flutter-review/lesson-bar-menu-demo.js <outdir> [port] [slow]
// Opens lesson 1 of course 0 unit 0 and opens/closes the pause menu three times (phone 915x412), at ?slow=<slow>.
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],port=process.argv[3]||'8766',slow=process.argv[4]||'3';
const b=await chromium.launch();const W=915,H=412,u=H/100;
const c=await b.newContext({viewport:{width:W,height:H},recordVideo:{dir:d,size:{width:W,height:H}}});const p=await c.newPage();
await p.goto(`http://localhost:${port}/?lessons=0,0&slow=${slow}`,{waitUntil:'networkidle'});await p.waitForTimeout(1500*slow);
await p.mouse.click(W*1350/1844,H*460/853);await p.waitForTimeout(900*slow);
for(let i=0;i<3;i++){await p.mouse.click(W-10.75*u,10.75*u);await p.waitForTimeout(700*slow);
 await p.mouse.click(W-10.75*u,10.75*u);await p.waitForTimeout(600*slow);}
await c.close();await b.close()})();
