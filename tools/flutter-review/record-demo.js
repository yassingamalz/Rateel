const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();
const c=await b.newContext({viewport:{width:1280,height:592},recordVideo:{dir:d+'/vid',size:{width:1280,height:592}}});const p=await c.newPage();
await p.goto('http://localhost:8765/?slow=4',{waitUntil:'networkidle'});await p.waitForTimeout(4000);
const u=5.92,W=1280,k=4,w=ms=>p.waitForTimeout(ms*k);
await w(300);
await p.mouse.click(W-9.2*u,6.4*u);await w(1100);                      // open
await p.mouse.click(W-40*u,(22+3*11.1)*u);await w(1100);              // pick المتصدرين (closes)
await p.mouse.click(W-9.2*u,(20.4+1*13)*u);await w(900);              // pick القرآن in the rail
await p.mouse.click(W-9.2*u,6.4*u);await w(1100);                      // open
await p.mouse.click(200,300);await w(900);                             // tap outside: close
await c.close();await b.close()})();
