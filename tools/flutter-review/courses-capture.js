// Screen 03 states at the reference size: settled, locked tap (toast), scrolled, menu open.
// Usage: node courses-capture.js <outdir>   (build/web served on :8765)
const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();
const p=await b.newPage({viewport:{width:1844,height:853}});const u=8.53;
await p.goto('http://localhost:8765/',{waitUntil:'networkidle'});await p.waitForTimeout(4000);
await p.screenshot({path:d+'/c-settled.png'});
await p.mouse.click(600,500);await p.waitForTimeout(600);await p.screenshot({path:d+'/c-locked-tap.png'});
await p.waitForTimeout(2500);
await p.mouse.move(400,500);await p.mouse.down();for(let i=1;i<=20;i++){await p.mouse.move(400+i*30,500);await p.waitForTimeout(16)}
await p.mouse.up();await p.waitForTimeout(1200);await p.screenshot({path:d+'/c-scrolled.png'});
await p.mouse.click(1844-9.2*u,6.4*u);await p.waitForTimeout(1200);await p.screenshot({path:d+'/c-menu-open.png'});
await b.close()})();
