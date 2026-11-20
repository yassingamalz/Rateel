// Frames of the course-completion sequence at 1844x853 (?complete=0&slow=3).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();
const p=await b.newPage({viewport:{width:1844,height:853}});
await p.goto('http://localhost:8765/?complete=0&slow=3',{waitUntil:'commit'});await p.waitForTimeout(3000);
for(let i=0;i<12;i++){await p.screenshot({path:`${d}/k-${String(i).padStart(2,'0')}.png`});await p.waitForTimeout(900)}
await b.close()})();
