const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();const p=await b.newPage({viewport:{width:1280,height:592}});
await p.goto('http://localhost:8765/?slow=12',{waitUntil:'networkidle'});await p.waitForTimeout(3500);
await p.mouse.click(1280-9.2*5.92,6.4*5.92);
for(let k=0;k<8;k++){await p.waitForTimeout(620);await p.screenshot({path:`${d}/s${k}.png`});}
await b.close()})();
