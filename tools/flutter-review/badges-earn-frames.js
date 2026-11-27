// Screen 27, celebration frames: node tools/flutter-review/badges-earn-frames.js <outdir> [slow]; web build on :8765.
// Opens `?earn=5&slow=<n>` and saves a frame every 400 ms (default slow 4).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],slow=process.argv[3]||'4';const b=await chromium.launch();
const p=await b.newPage({viewport:{width:1844,height:853}});
await p.goto(`http://localhost:8765/?section=4&earn=5&slow=${slow}`,{waitUntil:'networkidle'});
for (let i=0;i<22;i++){await p.waitForTimeout(400);await p.screenshot({path:`${d}/earn-${String(i).padStart(2,'0')}.png`});}
await b.close()})();
