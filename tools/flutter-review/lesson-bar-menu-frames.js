// Screen 02 pause-menu motion frames (Simply Piano style): node tools/flutter-review/lesson-bar-menu-frames.js <outdir>
// [port]; web build served on :8766 by default. Opens lesson 1 of course 0 unit 0, ?slow=12, opens and closes the
// menu, a frame every 200 ms (phone 915x412). Output: menu-open-NN.png, menu-close-NN.png.
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],port=process.argv[3]||'8766';const b=await chromium.launch();
const W=915,H=412,u=H/100;const p=await b.newPage({viewport:{width:W,height:H},deviceScaleFactor:1});
await p.goto(`http://localhost:${port}/?lessons=0,0&slow=12`,{waitUntil:'networkidle'});await p.waitForTimeout(15000);
await p.mouse.click(W*1350/1844,H*460/853);await p.waitForTimeout(15000);
const clip={x:W-60*u,y:0,width:60*u,height:22*u};
await p.mouse.click(W-10.75*u,10.75*u);
for(let i=0;i<22;i++){await p.screenshot({path:`${d}/menu-open-${String(i).padStart(2,'0')}.png`,clip});await p.waitForTimeout(200);}
await p.waitForTimeout(1500);await p.mouse.click(W-10.75*u,10.75*u);
for(let i=0;i<22;i++){await p.screenshot({path:`${d}/menu-close-${String(i).padStart(2,'0')}.png`,clip});await p.waitForTimeout(200);}
await b.close()})();
