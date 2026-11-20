const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();const p=await b.newPage({viewport:{width:1844,height:853}});
await p.goto('http://localhost:8765/',{waitUntil:'networkidle'});await p.waitForTimeout(3500);
await p.screenshot({path:d+'/a-closed.png'});await p.mouse.click(1844-9.2*8.53,6.4*8.53);await p.waitForTimeout(1200);await p.screenshot({path:d+'/a-open.png'});await b.close()})();
